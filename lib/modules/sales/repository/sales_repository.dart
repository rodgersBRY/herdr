import 'package:uuid/uuid.dart';
import '../../../core/database/database_helper.dart';
import '../models/milk_sale.dart';

class SalesRepository {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  Future<List<MilkSale>> getAll({int limit = 50}) async {
    final db = await _db.db;
    final maps = await db.query(
      'milk_sales',
      orderBy: 'sale_date DESC',
      limit: limit,
    );
    return maps.map(MilkSale.fromMap).toList();
  }

  Future<double> getMonthlyIncome(String yearMonth) async {
    final db = await _db.db;
    final result = await db.rawQuery(
      "SELECT SUM(litres * price_per_litre) as total FROM milk_sales WHERE sale_date LIKE ?",
      ['$yearMonth%'],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<MilkSale> insert(MilkSale sale) async {
    final db = await _db.db;
    final newSale = MilkSale(
      localId: _uuid.v4(),
      saleDate: sale.saleDate,
      litres: sale.litres,
      pricePerLitre: sale.pricePerLitre,
      buyerName: sale.buyerName,
      notes: sale.notes,
      createdAt: sale.createdAt,
    );
    await db.insert('milk_sales', newSale.toMap());
    return newSale;
  }

  Future<List<MilkSale>> getUnsynced() async {
    final db = await _db.db;
    final maps = await db.query('milk_sales', where: 'is_synced = 0');
    return maps.map(MilkSale.fromMap).toList();
  }

  Future<void> markSynced(String localId, String serverId) async {
    final db = await _db.db;
    await db.update(
      'milk_sales',
      {'is_synced': 1, 'server_id': serverId},
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }
}
