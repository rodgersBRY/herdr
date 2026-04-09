import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_status_service.dart';
import '../../../core/utils/constants.dart';
import '../../cows/models/cow.dart';
import '../../cows/repository/cow_repository.dart';
import '../models/breeding_record.dart';

class BreedingRepository {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();
  final CowRepository _cowRepository = CowRepository();

  Dio get _dio => Get.find<ApiClient>().dio;
  bool get _isOnline => Get.find<NetworkStatusService>().isOnline.value;

  Future<List<BreedingRecord>> getForCow(
    String cowLocalId, {
    bool refresh = true,
  }) async {
    final cow = await _cowRepository.getById(cowLocalId);
    if (refresh && _isOnline && cow?.serverId != null) {
      await syncPending();
      await _refreshForCow(cowLocalId, cow!.serverId!);
    }

    final db = await _db.db;
    final maps = await db.query(
      'breeding_records',
      where: 'cow_local_id = ?',
      whereArgs: [cowLocalId],
      orderBy: 'event_date DESC, created_at DESC',
    );
    return maps.map(BreedingRecord.fromDb).toList();
  }

  Future<BreedingRecord> insert(BreedingRecord record) async {
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
    }

    return local;
  }

  Future<List<BreedingRecord>> getPendingSync() async {
    final db = await _db.db;
    final maps = await db.query(
      'breeding_records',
      where: 'sync_action != ?',
      whereArgs: [AppConstants.syncSynced],
    );
    return maps.map(BreedingRecord.fromDb).toList();
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
      '/cows/$cowServerId/breeding-records',
      queryParameters: {'limit': AppConstants.defaultPageSize, 'page': 1},
    );

    final items =
        ((response.data as Map<String, dynamic>)['data'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    for (final item in items) {
      final db = await _db.db;
      final existing = await db.query(
        'breeding_records',
        where: 'server_id = ?',
        whereArgs: [item['id']],
        limit: 1,
      );
      final merged = BreedingRecord.fromApi(
        item,
        localId:
            existing.isNotEmpty
                ? existing.first['local_id'] as String
                : _uuid.v4(),
        cowLocalId: cowLocalId,
        syncAction: AppConstants.syncSynced,
        lastError: null,
      );
      await _upsertDb(merged);
    }
  }

  Future<void> _syncRecord(BreedingRecord record) async {
    final cow = await _cowRepository.getById(record.cowLocalId);
    if (cow?.serverId == null) {
      return;
    }

    try {
      final response = await _dio.post(
        '/cows/${cow!.serverId}/breeding-records',
        data: record.toCreatePayload(),
      );

      final payload = response.data as Map<String, dynamic>;
      final breedingMap =
          (payload['breedingRecord'] ?? payload['breeding_record'])
              as Map<String, dynamic>;
      final synced = BreedingRecord.fromApi(
        breedingMap,
        localId: record.localId,
        cowLocalId: record.cowLocalId,
        syncAction: AppConstants.syncSynced,
        lastError: null,
      ).copyWith(createdAt: record.createdAt);
      await _upsertDb(synced);

      final calfPayload = payload['calf'];
      if (calfPayload is Map<String, dynamic>) {
        await _mergeCalf(calfPayload);
      }
    } on DioException catch (error) {
      await _upsertDb(
        record.copyWith(
          lastError: error.message,
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
    }
  }

  Future<void> _mergeCalf(Map<String, dynamic> map) async {
    final db = await _db.db;
    final draftCalf = Cow.fromApi(
      map,
      localId: _uuid.v4(),
      syncAction: AppConstants.syncSynced,
      lastError: null,
    );

    final existing =
        draftCalf.serverId == null
            ? const <Map<String, Object?>>[]
            : await db.query(
              'cows',
              where: 'server_id = ?',
              whereArgs: [draftCalf.serverId],
              limit: 1,
            );

    final calf =
        existing.isNotEmpty
            ? draftCalf.copyWith(
              localId: existing.first['local_id'] as String,
              createdAt:
                  existing.first['created_at'] as String? ??
                  draftCalf.createdAt,
            )
            : draftCalf;

    final updated = await db.update(
      'cows',
      calf.toDbMap(),
      where: 'local_id = ?',
      whereArgs: [calf.localId],
    );

    if (updated == 0) {
      await db.insert('cows', calf.toDbMap());
    }
  }

  Future<void> _upsertDb(BreedingRecord record) async {
    final db = await _db.db;
    await db.insert(
      'breeding_records',
      record.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
