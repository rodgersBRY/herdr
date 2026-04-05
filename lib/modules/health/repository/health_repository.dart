import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_status_service.dart';
import '../../../core/utils/constants.dart';
import '../../cows/repository/cow_repository.dart';
import '../models/health_record.dart';

class HealthRepository {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();
  final CowRepository _cowRepository = CowRepository();

  Dio get _dio => Get.find<ApiClient>().dio;
  bool get _isOnline => Get.find<NetworkStatusService>().isOnline.value;

  Future<List<HealthRecord>> getForCow(String cowLocalId, {bool refresh = true}) async {
    final cow = await _cowRepository.getById(cowLocalId);
    if (refresh && _isOnline && cow?.serverId != null) {
      await syncPending();
      await _refreshForCow(cowLocalId, cow!.serverId!);
    }

    final db = await _db.db;
    final maps = await db.query(
      'health_records',
      where: 'cow_local_id = ?',
      whereArgs: [cowLocalId],
      orderBy: 'record_date DESC, created_at DESC',
    );
    return maps.map(HealthRecord.fromDb).toList();
  }

  Future<HealthRecord> insert(HealthRecord record) async {
    final now = DateTime.now().toIso8601String();
    final local = record.copyWith(
      localId: _uuid.v4(),
      syncAction: AppConstants.syncCreate,
      createdAt: record.createdAt.isEmpty ? now : record.createdAt,
      updatedAt: now,
      lastError: null,
    );
    await _upsertDb(local);

    if (_isOnline) {
      await _syncRecord(local);
      final items = await getForCow(record.cowLocalId, refresh: false);
      for (final item in items) {
        if (item.localId == local.localId) {
          return item;
        }
      }
      return local;
    }
    return local;
  }

  Future<HealthRecord> update(HealthRecord record) async {
    final updated = record.copyWith(
      syncAction: record.serverId == null
          ? AppConstants.syncCreate
          : AppConstants.syncUpdate,
      updatedAt: DateTime.now().toIso8601String(),
      lastError: null,
    );
    await _upsertDb(updated);
    if (_isOnline) {
      await _syncRecord(updated);
    }
    return updated;
  }

  Future<List<HealthRecord>> getPendingSync() async {
    final db = await _db.db;
    final maps = await db.query(
      'health_records',
      where: 'sync_action != ?',
      whereArgs: [AppConstants.syncSynced],
    );
    return maps.map(HealthRecord.fromDb).toList();
  }

  Future<void> syncPending() async {
    if (!_isOnline) {
      return;
    }
    final pending = await getPendingSync();
    for (final record in pending) {
      await _syncRecord(record);
    }
  }

  Future<void> _refreshForCow(String cowLocalId, String cowServerId) async {
    final response = await _dio.get(
      '/cows/$cowServerId/health-records',
      queryParameters: {'limit': AppConstants.defaultPageSize, 'page': 1},
    );

    final items = ((response.data as Map<String, dynamic>)['data'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    for (final item in items) {
      final db = await _db.db;
      final existing = await db.query(
        'health_records',
        where: 'server_id = ?',
        whereArgs: [item['id']],
        limit: 1,
      );
      final merged = HealthRecord.fromApi(
        item,
        localId: existing.isNotEmpty ? existing.first['local_id'] as String : _uuid.v4(),
        cowLocalId: cowLocalId,
        syncAction: AppConstants.syncSynced,
        lastError: null,
      );
      await _upsertDb(merged);
    }
  }

  Future<void> _syncRecord(HealthRecord record) async {
    final cow = await _cowRepository.getById(record.cowLocalId);
    if (cow?.serverId == null) {
      return;
    }

    try {
      if (record.serverId == null || record.syncAction == AppConstants.syncCreate) {
        final response = await _dio.post(
          '/cows/${cow!.serverId}/health-records',
          data: record.toCreatePayload(),
        );
        final synced = HealthRecord.fromApi(
          response.data as Map<String, dynamic>,
          localId: record.localId,
          cowLocalId: record.cowLocalId,
          syncAction: AppConstants.syncSynced,
          lastError: null,
        ).copyWith(createdAt: record.createdAt);
        await _upsertDb(synced);
        return;
      }

      final response = await _dio.patch(
        '/cows/${cow!.serverId}/health-records/${record.serverId}',
        data: record.toUpdatePayload(),
      );
      final synced = HealthRecord.fromApi(
        response.data as Map<String, dynamic>,
        localId: record.localId,
        cowLocalId: record.cowLocalId,
        syncAction: AppConstants.syncSynced,
        lastError: null,
      ).copyWith(createdAt: record.createdAt);
      await _upsertDb(synced);
    } on DioException catch (error) {
      await _upsertDb(
        record.copyWith(
          lastError: error.message,
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
    }
  }

  Future<void> _upsertDb(HealthRecord record) async {
    final db = await _db.db;
    await db.insert(
      'health_records',
      record.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
