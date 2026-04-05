import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_status_service.dart';
import '../../../core/utils/constants.dart';
import '../models/cow.dart';

class CowRepository {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  Dio get _dio => Get.find<ApiClient>().dio;
  bool get _isOnline => Get.find<NetworkStatusService>().isOnline.value;

  Future<List<Cow>> getAll({bool refresh = true}) async {
    if (refresh && _isOnline) {
      await syncPending();
      await _refreshFromApi();
    }
    return _readAll();
  }

  Future<List<Cow>> search(String query) async {
    final db = await _db.db;
    final maps = await db.query(
      'cows',
      where: 'tag_number LIKE ? OR breed LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'tag_number ASC',
    );
    return maps.map(Cow.fromDb).toList();
  }

  Future<Cow?> getById(String localId, {bool refresh = false}) async {
    final db = await _db.db;
    final maps = await db.query(
      'cows',
      where: 'local_id = ?',
      whereArgs: [localId],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    final cow = Cow.fromDb(maps.first);
    if (refresh && _isOnline) {
      await syncPending();
      await _refreshSingle(cow);
      return getById(localId);
    }
    return cow;
  }

  Future<Cow> insert(Cow cow) async {
    final now = DateTime.now().toIso8601String();
    final newCow = cow.copyWith(
      localId: _uuid.v4(),
      syncAction: AppConstants.syncCreate,
      createdAt: cow.createdAt.isEmpty ? now : cow.createdAt,
      updatedAt: now,
      lastError: null,
    );
    await _upsertDb(newCow);

    if (_isOnline) {
      await _syncCow(newCow);
      return (await getById(newCow.localId)) ?? newCow;
    }

    return newCow;
  }

  Future<Cow> update(Cow cow) async {
    final updated = cow.copyWith(
      syncAction: cow.serverId == null
          ? AppConstants.syncCreate
          : AppConstants.syncUpdate,
      updatedAt: DateTime.now().toIso8601String(),
      lastError: null,
    );
    await _upsertDb(updated);

    if (_isOnline) {
      await _syncCow(updated);
      return (await getById(updated.localId)) ?? updated;
    }

    return updated;
  }

  Future<void> deleteLocal(String localId) async {
    final db = await _db.db;
    await db.delete('cows', where: 'local_id = ?', whereArgs: [localId]);
  }

  Future<List<Cow>> getPendingSync() async {
    final db = await _db.db;
    final maps = await db.query(
      'cows',
      where: 'sync_action != ?',
      whereArgs: [AppConstants.syncSynced],
    );
    return maps.map(Cow.fromDb).toList();
  }

  Future<void> syncPending() async {
    if (!_isOnline) {
      return;
    }

    final pending = await getPendingSync();
    for (final cow in pending) {
      await _syncCow(cow);
    }
  }

  Future<List<Cow>> _readAll() async {
    final db = await _db.db;
    final maps = await db.query('cows', orderBy: 'tag_number ASC');
    return maps.map(Cow.fromDb).toList();
  }

  Future<void> _refreshFromApi() async {
    final response = await _dio.get('/cows', queryParameters: {
      'limit': AppConstants.defaultPageSize,
      'page': 1,
    });

    final items = ((response.data as Map<String, dynamic>)['data'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    for (final item in items) {
      await _mergeApiCow(item);
    }
  }

  Future<void> _refreshSingle(Cow cow) async {
    if (cow.serverId == null) {
      return;
    }
    final response = await _dio.get('/cows/${cow.serverId}');
    await _mergeApiCow(response.data as Map<String, dynamic>, localId: cow.localId);
  }

  Future<void> _mergeApiCow(
    Map<String, dynamic> map, {
    String? localId,
  }) async {
    final db = await _db.db;
    final serverId = map['id'] as String;
    final existing = await db.query(
      'cows',
      where: 'server_id = ?',
      whereArgs: [serverId],
      limit: 1,
    );

    final merged = Cow.fromApi(
      map,
      localId: localId ?? (existing.isNotEmpty ? existing.first['local_id'] as String : _uuid.v4()),
      syncAction: AppConstants.syncSynced,
      lastError: null,
    );
    await _upsertDb(merged);
  }

  Future<void> _syncCow(Cow cow) async {
    try {
      if (cow.serverId == null || cow.syncAction == AppConstants.syncCreate) {
        final response = await _dio.post('/cows', data: cow.toCreatePayload());
        var synced = Cow.fromApi(
          response.data as Map<String, dynamic>,
          localId: cow.localId,
          syncAction: AppConstants.syncSynced,
          lastError: null,
        );

        if (cow.status != AppConstants.statusActive) {
          final patch = await _dio.patch(
            '/cows/${synced.serverId}',
            data: {'status': cow.status},
          );
          synced = Cow.fromApi(
            patch.data as Map<String, dynamic>,
            localId: cow.localId,
            syncAction: AppConstants.syncSynced,
            lastError: null,
          );
        }

        await _upsertDb(synced.copyWith(createdAt: cow.createdAt));
        return;
      }

      final response = await _dio.patch(
        '/cows/${cow.serverId}',
        data: cow.toUpdatePayload(),
      );
      final synced = Cow.fromApi(
        response.data as Map<String, dynamic>,
        localId: cow.localId,
        syncAction: AppConstants.syncSynced,
        lastError: null,
      ).copyWith(createdAt: cow.createdAt);
      await _upsertDb(synced);
    } on DioException catch (error) {
      await _upsertDb(
        cow.copyWith(
          syncAction: cow.syncAction == AppConstants.syncCreate
              ? AppConstants.syncCreate
              : AppConstants.syncUpdate,
          lastError: error.message,
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
    }
  }

  Future<void> _upsertDb(Cow cow) async {
    final db = await _db.db;
    await db.insert(
      'cows',
      cow.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
