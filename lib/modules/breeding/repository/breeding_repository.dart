import 'package:uuid/uuid.dart';
import '../../../core/database/database_helper.dart';
import '../models/breeding_record.dart';

class BreedingRepository {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  Future<List<BreedingRecord>> getForCow(String cowLocalId) async {
    final db = await _db.db;
    final maps = await db.query(
      'breeding_records',
      where: 'cow_local_id = ?',
      whereArgs: [cowLocalId],
      orderBy: 'created_at DESC',
    );
    return maps.map(BreedingRecord.fromMap).toList();
  }

  Future<List<Map<String, dynamic>>> getDueCalvings(String today) async {
    final db = await _db.db;
    return db.rawQuery('''
      SELECT br.*, c.tag, c.name FROM breeding_records br
      JOIN cows c ON c.local_id = br.cow_local_id
      WHERE br.expected_calving_date <= ?
      AND br.actual_calving_date IS NULL
      ORDER BY br.expected_calving_date ASC
    ''', [today]);
  }

  Future<List<Map<String, dynamic>>> getDuePregnancyChecks(String today) async {
    final db = await _db.db;
    return db.rawQuery('''
      SELECT br.*, c.tag, c.name FROM breeding_records br
      JOIN cows c ON c.local_id = br.cow_local_id
      WHERE br.pregnancy_check_date <= ?
      AND br.pregnancy_result IS NULL
      ORDER BY br.pregnancy_check_date ASC
    ''', [today]);
  }

  Future<BreedingRecord> insert(BreedingRecord record) async {
    final db = await _db.db;
    final newRecord = BreedingRecord(
      localId: _uuid.v4(),
      cowLocalId: record.cowLocalId,
      recordType: record.recordType,
      serviceDate: record.serviceDate,
      sireName: record.sireName,
      sireBreed: record.sireBreed,
      pregnancyCheckDate: record.pregnancyCheckDate,
      pregnancyResult: record.pregnancyResult,
      expectedCalvingDate: record.expectedCalvingDate,
      actualCalvingDate: record.actualCalvingDate,
      calfGender: record.calfGender,
      calfTag: record.calfTag,
      notes: record.notes,
      createdAt: record.createdAt,
    );
    await db.insert('breeding_records', newRecord.toMap());
    return newRecord;
  }

  Future<void> update(BreedingRecord record) async {
    final db = await _db.db;
    await db.update('breeding_records', record.toMap(),
        where: 'local_id = ?', whereArgs: [record.localId]);
  }

  Future<List<BreedingRecord>> getUnsynced() async {
    final db = await _db.db;
    final maps = await db.query('breeding_records', where: 'is_synced = 0');
    return maps.map(BreedingRecord.fromMap).toList();
  }

  Future<void> markSynced(String localId, String serverId) async {
    final db = await _db.db;
    await db.update(
      'breeding_records',
      {'is_synced': 1, 'server_id': serverId},
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }
}
