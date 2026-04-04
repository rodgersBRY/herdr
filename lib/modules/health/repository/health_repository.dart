import 'package:uuid/uuid.dart';
import '../../../core/database/database_helper.dart';
import '../models/health_record.dart';

class HealthRepository {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  Future<List<HealthRecord>> getForCow(String cowLocalId) async {
    final db = await _db.db;
    final maps = await db.query(
      'health_records',
      where: 'cow_local_id = ?',
      whereArgs: [cowLocalId],
      orderBy: 'record_date DESC',
    );
    return maps.map(HealthRecord.fromMap).toList();
  }

  Future<List<Map<String, dynamic>>> getDueAlerts(String today) async {
    final db = await _db.db;
    return db.rawQuery('''
      SELECT hr.*, c.tag, c.name FROM health_records hr
      JOIN cows c ON c.local_id = hr.cow_local_id
      WHERE hr.next_due_date <= ?
      ORDER BY hr.next_due_date ASC
    ''', [today]);
  }

  Future<HealthRecord> insert(HealthRecord record) async {
    final db = await _db.db;
    final newRecord = HealthRecord(
      localId: _uuid.v4(),
      cowLocalId: record.cowLocalId,
      recordType: record.recordType,
      description: record.description,
      vetName: record.vetName,
      cost: record.cost,
      recordDate: record.recordDate,
      nextDueDate: record.nextDueDate,
      notes: record.notes,
      createdAt: record.createdAt,
    );
    await db.insert('health_records', newRecord.toMap());
    return newRecord;
  }

  Future<List<HealthRecord>> getUnsynced() async {
    final db = await _db.db;
    final maps = await db.query('health_records', where: 'is_synced = 0');
    return maps.map(HealthRecord.fromMap).toList();
  }

  Future<void> markSynced(String localId, String serverId) async {
    final db = await _db.db;
    await db.update(
      'health_records',
      {'is_synced': 1, 'server_id': serverId},
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }
}
