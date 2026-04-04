import 'package:uuid/uuid.dart';
import '../../../core/database/database_helper.dart';
import '../models/milk_log.dart';

class MilkRepository {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  Future<List<MilkLog>> getForDate(String date) async {
    final db = await _db.db;
    final maps = await db.rawQuery('''
      SELECT ml.*, c.tag as cow_tag, c.name as cow_name
      FROM milk_logs ml
      JOIN cows c ON c.local_id = ml.cow_local_id
      WHERE ml.log_date = ?
      ORDER BY c.tag ASC
    ''', [date]);
    return maps.map(MilkLog.fromMap).toList();
  }

  Future<List<MilkLog>> getForCow(String cowLocalId) async {
    final db = await _db.db;
    final maps = await db.query(
      'milk_logs',
      where: 'cow_local_id = ?',
      whereArgs: [cowLocalId],
      orderBy: 'log_date DESC',
    );
    return maps.map(MilkLog.fromMap).toList();
  }

  Future<MilkLog?> getForCowAndDate(String cowLocalId, String date) async {
    final db = await _db.db;
    final maps = await db.query(
      'milk_logs',
      where: 'cow_local_id = ? AND log_date = ?',
      whereArgs: [cowLocalId, date],
    );
    if (maps.isEmpty) return null;
    return MilkLog.fromMap(maps.first);
  }

  Future<MilkLog> upsert(MilkLog log) async {
    final db = await _db.db;
    final existing = await getForCowAndDate(log.cowLocalId, log.logDate);
    if (existing != null) {
      final updated = log.copyWith(localId: existing.localId, isSynced: 0);
      await db.update('milk_logs', updated.toMap(),
          where: 'local_id = ?', whereArgs: [existing.localId]);
      return updated;
    } else {
      final newLog = log.copyWith(localId: _uuid.v4());
      await db.insert('milk_logs', newLog.toMap());
      return newLog;
    }
  }

  Future<double> getTodayTotal(String date) async {
    final db = await _db.db;
    final result = await db.rawQuery(
      'SELECT SUM(morning_litres + evening_litres) as total FROM milk_logs WHERE log_date = ?',
      [date],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<double> getMonthlyTotal(String yearMonth) async {
    final db = await _db.db;
    final result = await db.rawQuery(
      "SELECT SUM(morning_litres + evening_litres) as total FROM milk_logs WHERE log_date LIKE ?",
      ['$yearMonth%'],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<List<String>> getCowsWithoutLogToday(String date) async {
    final db = await _db.db;
    final maps = await db.rawQuery('''
      SELECT c.local_id FROM cows c
      WHERE c.status = 'active'
      AND c.local_id NOT IN (
        SELECT cow_local_id FROM milk_logs WHERE log_date = ?
      )
    ''', [date]);
    return maps.map((m) => m['local_id'] as String).toList();
  }

  Future<List<MilkLog>> getUnsynced() async {
    final db = await _db.db;
    final maps = await db.query('milk_logs', where: 'is_synced = 0');
    return maps.map(MilkLog.fromMap).toList();
  }

  Future<void> markSynced(String localId, String serverId) async {
    final db = await _db.db;
    await db.update(
      'milk_logs',
      {'is_synced': 1, 'server_id': serverId},
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }
}
