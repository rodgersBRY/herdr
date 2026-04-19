import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_error.dart';
import '../../../core/network/network_status_service.dart';
import '../../../core/utils/constants.dart';
import '../../cows/repository/cow_repository.dart';
import '../models/expense_log.dart';

class ExpenseRepository {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();
  final CowRepository _cowRepository = CowRepository();

  Dio get _dio => Get.find<ApiClient>().dio;
  bool get _isOnline => Get.find<NetworkStatusService>().isOnline.value;
  String? get _orgId => Get.find<AuthService>().orgId.value;

  Future<List<ExpenseLog>> getForCow(
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
      'expense_logs',
      where: 'cow_local_id = ?',
      whereArgs: [cowLocalId],
      orderBy: 'expense_date DESC, created_at DESC',
    );
    return maps.map(ExpenseLog.fromDb).toList();
  }

  Future<double> getTotalForCow(String cowLocalId) async {
    final db = await _db.db;
    final result = await db.rawQuery(
      'SELECT SUM(amount) AS total FROM expense_logs WHERE cow_local_id = ?',
      [cowLocalId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<double> getMonthlyTotal(String yearMonth) async {
    final db = await _db.db;
    final result = await db.rawQuery(
      "SELECT SUM(amount) AS total FROM expense_logs WHERE expense_date LIKE ?",
      ['$yearMonth%'],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<ExpenseLog> insert(ExpenseLog expense) async {
    final now = DateTime.now().toIso8601String();
    final local = expense.copyWith(
      localId: _uuid.v4(),
      syncAction: AppConstants.syncCreate,
      organizationId: _orgId,
      createdAt: expense.createdAt.isEmpty ? now : expense.createdAt,
      updatedAt: now,
      lastError: null,
    );
    await _upsertDb(local);

    if (_isOnline) {
      await _syncExpense(local);
    }

    return local;
  }

  Future<List<ExpenseLog>> getPendingSync() async {
    final db = await _db.db;
    final maps = await db.query(
      'expense_logs',
      where: 'sync_action != ?',
      whereArgs: [AppConstants.syncSynced],
    );
    return maps.map(ExpenseLog.fromDb).toList();
  }

  Future<void> syncPending() async {
    if (!_isOnline) {
      return;
    }

    final pending = await getPendingSync();
    for (final item in pending) {
      await _syncExpense(item);
    }
  }

  Future<void> _refreshForCow(String cowLocalId, String cowServerId) async {
    final response = await _dio.get(
      '/cows/$cowServerId/expenses',
      queryParameters: {'limit': AppConstants.defaultPageSize, 'page': 1},
    );
    final items =
        ((response.data as Map<String, dynamic>)['data'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    for (final item in items) {
      final db = await _db.db;
      final existing = await db.query(
        'expense_logs',
        where: 'server_id = ?',
        whereArgs: [item['id']],
        limit: 1,
      );
      final merged = ExpenseLog.fromApi(
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

  Future<void> _syncExpense(ExpenseLog expense) async {
    final cow = await _cowRepository.getById(expense.cowLocalId);
    if (cow?.serverId == null) {
      return;
    }

    try {
      final response = await _dio.post(
        '/cows/${cow!.serverId}/expenses',
        data: expense.toCreatePayload(),
      );
      final synced = ExpenseLog.fromApi(
        response.data as Map<String, dynamic>,
        localId: expense.localId,
        cowLocalId: expense.cowLocalId,
        syncAction: AppConstants.syncSynced,
        lastError: null,
      ).copyWith(createdAt: expense.createdAt);
      await _upsertDb(synced);
    } on DioException catch (error) {
      await _upsertDb(
        expense.copyWith(
          lastError: extractApiErrorMessage(
            error,
            fallback: 'Failed to sync expense',
          ),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
    }
  }

  Future<void> _upsertDb(ExpenseLog expense) async {
    final db = await _db.db;
    await db.insert(
      'expense_logs',
      expense.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
