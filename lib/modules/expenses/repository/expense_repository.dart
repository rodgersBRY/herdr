import 'package:uuid/uuid.dart';
import '../../../core/database/database_helper.dart';
import '../models/expense_log.dart';

class ExpenseRepository {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  Future<List<ExpenseLog>> getForCow(String cowLocalId) async {
    final db = await _db.db;
    final maps = await db.query(
      'expense_logs',
      where: 'cow_local_id = ?',
      whereArgs: [cowLocalId],
      orderBy: 'expense_date DESC',
    );
    return maps.map(ExpenseLog.fromMap).toList();
  }

  Future<double> getTotalForCow(String cowLocalId) async {
    final db = await _db.db;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expense_logs WHERE cow_local_id = ?',
      [cowLocalId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<double> getMonthlyTotal(String yearMonth) async {
    final db = await _db.db;
    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM expense_logs WHERE expense_date LIKE ?",
      ['$yearMonth%'],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<ExpenseLog> insert(ExpenseLog expense) async {
    final db = await _db.db;
    final newExpense = ExpenseLog(
      localId: _uuid.v4(),
      cowLocalId: expense.cowLocalId,
      category: expense.category,
      amount: expense.amount,
      description: expense.description,
      expenseDate: expense.expenseDate,
      notes: expense.notes,
      createdAt: expense.createdAt,
    );
    await db.insert('expense_logs', newExpense.toMap());
    return newExpense;
  }

  Future<List<ExpenseLog>> getUnsynced() async {
    final db = await _db.db;
    final maps = await db.query('expense_logs', where: 'is_synced = 0');
    return maps.map(ExpenseLog.fromMap).toList();
  }

  Future<void> markSynced(String localId, String serverId) async {
    final db = await _db.db;
    await db.update(
      'expense_logs',
      {'is_synced': 1, 'server_id': serverId},
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }
}
