import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_error.dart';
import '../../../core/network/network_status_service.dart';
import '../../../core/utils/constants.dart';
import '../models/milk_sale.dart';

class SalesRepository {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  Dio get _dio => Get.find<ApiClient>().dio;
  bool get _isOnline => Get.find<NetworkStatusService>().isOnline.value;

  Future<List<MilkSale>> getAll({int limit = 50, bool refresh = true}) async {
    if (refresh && _isOnline) {
      await syncPending();
      await _refreshFromApi(limit: limit);
    }

    final db = await _db.db;
    final maps = await db.query(
      'milk_sales',
      orderBy: 'sale_date DESC, created_at DESC',
      limit: limit,
    );
    return maps.map(MilkSale.fromDb).toList();
  }

  Future<double> getMonthlyIncome(String yearMonth) async {
    final db = await _db.db;
    final result = await db.rawQuery(
      "SELECT SUM(total_amount) AS total FROM milk_sales WHERE sale_date LIKE ?",
      ['$yearMonth%'],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<MilkSale> insert(MilkSale sale) async {
    final now = DateTime.now().toIso8601String();
    final local = sale.copyWith(
      localId: _uuid.v4(),
      syncAction: AppConstants.syncCreate,
      createdAt: sale.createdAt.isEmpty ? now : sale.createdAt,
      updatedAt: now,
      lastError: null,
    );
    await _upsertDb(local);

    if (_isOnline) {
      await _syncSale(local);
    }

    return local;
  }

  Future<List<MilkSale>> getPendingSync() async {
    final db = await _db.db;
    final maps = await db.query(
      'milk_sales',
      where: 'sync_action != ?',
      whereArgs: [AppConstants.syncSynced],
    );
    return maps.map(MilkSale.fromDb).toList();
  }

  Future<void> syncPending() async {
    if (!_isOnline) {
      return;
    }
    final pending = await getPendingSync();
    for (final sale in pending) {
      await _syncSale(sale);
    }
  }

  Future<void> _refreshFromApi({required int limit}) async {
    final response = await _dio.get(
      '/milk-sales',
      queryParameters: {'limit': limit, 'page': 1},
    );
    final items =
        ((response.data as Map<String, dynamic>)['data'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    for (final item in items) {
      final db = await _db.db;
      final existing = await db.query(
        'milk_sales',
        where: 'server_id = ?',
        whereArgs: [item['id']],
        limit: 1,
      );
      final merged = MilkSale.fromApi(
        item,
        localId:
            existing.isNotEmpty
                ? existing.first['local_id'] as String
                : _uuid.v4(),
        syncAction: AppConstants.syncSynced,
        lastError: null,
      );
      await _upsertDb(merged);
    }
  }

  Future<void> _syncSale(MilkSale sale) async {
    try {
      final response = await _dio.post(
        '/milk-sales',
        data: sale.toCreatePayload(),
      );
      final synced = MilkSale.fromApi(
        response.data as Map<String, dynamic>,
        localId: sale.localId,
        syncAction: AppConstants.syncSynced,
        lastError: null,
      ).copyWith(createdAt: sale.createdAt);
      await _upsertDb(synced);
    } on DioException catch (error) {
      await _upsertDb(
        sale.copyWith(
          lastError: extractApiErrorMessage(
            error,
            fallback: 'Failed to sync milk sale',
          ),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
    }
  }

  Future<void> _upsertDb(MilkSale sale) async {
    final db = await _db.db;
    await db.insert(
      'milk_sales',
      sale.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
