import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_status_service.dart';
import '../../../core/utils/constants.dart';
import '../../cows/repository/cow_repository.dart';
import '../models/milk_log.dart';

class MilkRepository {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();
  final CowRepository _cowRepository = CowRepository();

  Dio get _dio => Get.find<ApiClient>().dio;
  bool get _isOnline => Get.find<NetworkStatusService>().isOnline.value;

  Future<List<MilkLog>> getForDate(String date) async {
    final db = await _db.db;
    final maps = await db.rawQuery('''
      SELECT ml.*, c.tag_number AS cow_tag_number, c.breed AS cow_breed
      FROM milk_logs ml
      JOIN cows c ON c.local_id = ml.cow_local_id
      WHERE ml.log_date = ?
      ORDER BY c.tag_number ASC
    ''', [date]);
    return maps.map(MilkLog.fromDb).toList();
  }

  Future<List<MilkLog>> getForCow(String cowLocalId, {bool refresh = true}) async {
    final cow = await _cowRepository.getById(cowLocalId);
    if (refresh && _isOnline && cow?.serverId != null) {
      await syncPending();
      await _refreshForCow(cowLocalId, cow!.serverId!);
    }

    final db = await _db.db;
    final maps = await db.query(
      'milk_logs',
      where: 'cow_local_id = ?',
      whereArgs: [cowLocalId],
      orderBy: 'log_date DESC, created_at DESC',
    );
    return maps.map(MilkLog.fromDb).toList();
  }

  Future<MilkLog?> getForCowAndDate(String cowLocalId, String date) async {
    final db = await _db.db;
    final maps = await db.query(
      'milk_logs',
      where: 'cow_local_id = ? AND log_date = ?',
      whereArgs: [cowLocalId, date],
      limit: 1,
    );
    if (maps.isEmpty) {
      return null;
    }
    return MilkLog.fromDb(maps.first);
  }

  Future<MilkLog> upsert(MilkLog log) async {
    final existing = await getForCowAndDate(log.cowLocalId, log.logDate);
    final now = DateTime.now().toIso8601String();
    final local = (existing ?? log).copyWith(
      localId: existing?.localId ?? _uuid.v4(),
      serverId: existing?.serverId ?? log.serverId,
      cowLocalId: log.cowLocalId,
      logDate: log.logDate,
      litres: log.litres,
      period: log.period,
      notes: log.notes,
      syncAction: existing?.serverId == null
          ? AppConstants.syncCreate
          : AppConstants.syncUpdate,
      createdAt: existing?.createdAt ?? (log.createdAt.isEmpty ? now : log.createdAt),
      updatedAt: now,
      lastError: null,
    );

    await _upsertDb(local);

    if (_isOnline) {
      await _syncLog(local);
      return (await getForCowAndDate(log.cowLocalId, log.logDate)) ?? local;
    }

    return local;
  }

  Future<double> getTodayTotal(String date) async {
    final db = await _db.db;
    final result = await db.rawQuery(
      'SELECT SUM(litres) AS total FROM milk_logs WHERE log_date = ?',
      [date],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<double> getMonthlyTotal(String yearMonth) async {
    final db = await _db.db;
    final result = await db.rawQuery(
      "SELECT SUM(litres) AS total FROM milk_logs WHERE log_date LIKE ?",
      ['$yearMonth%'],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<List<String>> getCowsWithoutLogToday(String date) async {
    final db = await _db.db;
    final maps = await db.rawQuery('''
      SELECT c.local_id FROM cows c
      WHERE c.status = ?
      AND c.local_id NOT IN (
        SELECT cow_local_id FROM milk_logs WHERE log_date = ?
      )
      ORDER BY c.tag_number ASC
    ''', [AppConstants.statusActive, date]);
    return maps.map((map) => map['local_id'] as String).toList();
  }

  Future<List<MilkLog>> getPendingSync() async {
    final db = await _db.db;
    final maps = await db.query(
      'milk_logs',
      where: 'sync_action != ?',
      whereArgs: [AppConstants.syncSynced],
    );
    return maps.map(MilkLog.fromDb).toList();
  }

  Future<void> syncPending() async {
    if (!_isOnline) {
      return;
    }

    final pending = await getPendingSync();
    for (final log in pending) {
      await _syncLog(log);
    }
  }

  Future<void> _refreshForCow(String cowLocalId, String cowServerId) async {
    final response = await _dio.get(
      '/cows/$cowServerId/milk-logs',
      queryParameters: {'limit': AppConstants.defaultPageSize, 'page': 1},
    );

    final items = ((response.data as Map<String, dynamic>)['data'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    for (final item in items) {
      final db = await _db.db;
      final existing = await db.query(
        'milk_logs',
        where: 'server_id = ?',
        whereArgs: [item['id']],
        limit: 1,
      );
      final merged = MilkLog.fromApi(
        item,
        localId: existing.isNotEmpty ? existing.first['local_id'] as String : _uuid.v4(),
        cowLocalId: cowLocalId,
        syncAction: AppConstants.syncSynced,
        lastError: null,
      );
      await _upsertDb(merged);
    }
  }

  Future<void> _syncLog(MilkLog log) async {
    final cow = await _cowRepository.getById(log.cowLocalId);
    if (cow?.serverId == null) {
      return;
    }

    try {
      if (log.serverId == null || log.syncAction == AppConstants.syncCreate) {
        final response = await _dio.post(
          '/cows/${cow!.serverId}/milk-logs',
          data: log.toCreatePayload(),
        );
        final synced = MilkLog.fromApi(
          response.data as Map<String, dynamic>,
          localId: log.localId,
          cowLocalId: log.cowLocalId,
          syncAction: AppConstants.syncSynced,
          lastError: null,
        ).copyWith(createdAt: log.createdAt);
        await _upsertDb(synced);
        return;
      }

      final response = await _dio.patch(
        '/cows/${cow!.serverId}/milk-logs/${log.serverId}',
        data: log.toUpdatePayload(),
      );
      final synced = MilkLog.fromApi(
        response.data as Map<String, dynamic>,
        localId: log.localId,
        cowLocalId: log.cowLocalId,
        syncAction: AppConstants.syncSynced,
        lastError: null,
      ).copyWith(createdAt: log.createdAt);
      await _upsertDb(synced);
    } on DioException catch (error) {
      await _upsertDb(
        log.copyWith(
          lastError: error.message,
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
    }
  }

  Future<void> _upsertDb(MilkLog log) async {
    final db = await _db.db;
    await db.insert(
      'milk_logs',
      log.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
