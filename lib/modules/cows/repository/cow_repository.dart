import 'package:uuid/uuid.dart';
import '../../../core/database/database_helper.dart';
import '../models/cow.dart';

class CowRepository {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  Future<List<Cow>> getAll() async {
    final db = await _db.db;
    final maps = await db.query('cows', orderBy: 'tag ASC');
    return maps.map(Cow.fromMap).toList();
  }

  Future<List<Cow>> search(String query) async {
    final db = await _db.db;
    final maps = await db.query(
      'cows',
      where: 'tag LIKE ? OR name LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'tag ASC',
    );
    return maps.map(Cow.fromMap).toList();
  }

  Future<Cow?> getById(String localId) async {
    final db = await _db.db;
    final maps = await db.query(
      'cows',
      where: 'local_id = ?',
      whereArgs: [localId],
    );
    if (maps.isEmpty) return null;
    return Cow.fromMap(maps.first);
  }

  Future<Cow> insert(Cow cow) async {
    final db = await _db.db;
    final newCow = cow.copyWith(localId: _uuid.v4());
    await db.insert('cows', newCow.toMap());
    return newCow;
  }

  Future<void> update(Cow cow) async {
    final db = await _db.db;
    await db.update(
      'cows',
      cow.copyWith(isSynced: 0).toMap(),
      where: 'local_id = ?',
      whereArgs: [cow.localId],
    );
  }

  Future<void> delete(String localId) async {
    final db = await _db.db;
    await db.delete('cows', where: 'local_id = ?', whereArgs: [localId]);
  }

  Future<List<Cow>> getUnsynced() async {
    final db = await _db.db;
    final maps = await db.query('cows', where: 'is_synced = 0');
    return maps.map(Cow.fromMap).toList();
  }

  Future<void> markSynced(String localId, String serverId) async {
    final db = await _db.db;
    await db.update(
      'cows',
      {'is_synced': 1, 'server_id': serverId},
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }
}
