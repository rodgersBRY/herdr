import 'package:get/get.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_status_service.dart';
import '../models/dashboard_summary.dart';

class DashboardRepository {
  final DatabaseHelper _db = DatabaseHelper();

  bool get _isOnline => Get.find<NetworkStatusService>().isOnline.value;
  ApiClient get _api => Get.find<ApiClient>();

  Future<DashboardSummary> getSummary(String month) async {
    if (_isOnline) {
      final response = await _api.dio.get(
        '/dashboard',
        queryParameters: {'month': month},
      );
      return DashboardSummary.fromApi(response.data as Map<String, dynamic>);
    }
    return _getOfflineSummary(month);
  }

  Future<DashboardSummary> _getOfflineSummary(String month) async {
    final db = await _db.db;
    final today = DateTime.now().toIso8601String().split('T').first;
    final recentThreshold =
        DateTime.now()
            .subtract(const Duration(days: 7))
            .toIso8601String()
            .split('T')
            .first;

    final active = await db.rawQuery(
      "SELECT COUNT(*) AS count FROM cows WHERE status = 'active'",
    );
    final pregnant = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT br.cow_local_id) AS count
      FROM breeding_records br
      JOIN cows c ON c.local_id = br.cow_local_id
      WHERE c.status = 'active'
        AND br.event_type IN ('service', 'pregnancy_check')
        AND br.expected_calving_date > ?
    ''',
      [today],
    );
    final inMilk = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT cow_local_id) AS count
      FROM milk_logs
      WHERE log_date >= ?
    ''',
      [recentThreshold],
    );
    final todayMilk = await db.rawQuery(
      'SELECT COALESCE(SUM(litres), 0) AS total FROM milk_logs WHERE log_date = ?',
      [today],
    );
    final monthlyMilk = await db.rawQuery(
      "SELECT COALESCE(SUM(litres), 0) AS total FROM milk_logs WHERE log_date LIKE ?",
      ['$month%'],
    );
    final monthlyExpenses = await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) AS total FROM expense_logs WHERE expense_date LIKE ?",
      ['$month%'],
    );
    final monthlyIncome = await db.rawQuery(
      "SELECT COALESCE(SUM(total_amount), 0) AS total FROM milk_sales WHERE sale_date LIKE ?",
      ['$month%'],
    );

    final milkPerCowRows = await db.rawQuery(
      '''
      SELECT c.server_id AS cowId, c.tag_number AS tagNumber, c.breed,
             COALESCE(SUM(ml.litres), 0) AS totalLitres
      FROM cows c
      LEFT JOIN milk_logs ml
        ON ml.cow_local_id = c.local_id AND ml.log_date LIKE ?
      WHERE c.status = 'active'
      GROUP BY c.local_id, c.server_id, c.tag_number, c.breed
      ORDER BY totalLitres DESC
    ''',
      ['$month%'],
    );

    final expensePerCowRows = await db.rawQuery(
      '''
      SELECT c.server_id AS cowId, c.tag_number AS tagNumber, c.breed,
             COALESCE(SUM(el.amount), 0) AS totalExpenses
      FROM cows c
      LEFT JOIN expense_logs el
        ON el.cow_local_id = c.local_id AND el.expense_date LIKE ?
      WHERE c.status = 'active'
      GROUP BY c.local_id, c.server_id, c.tag_number, c.breed
      ORDER BY totalExpenses DESC
    ''',
      ['$month%'],
    );

    final incomeValue = (monthlyIncome.first['total'] as num?)?.toDouble() ?? 0;
    final expenseValue =
        (monthlyExpenses.first['total'] as num?)?.toDouble() ?? 0;

    return DashboardSummary(
      totalActiveCows: int.parse('${active.first['count']}'),
      pregnantCows: int.parse('${pregnant.first['count']}'),
      cowsInMilk: int.parse('${inMilk.first['count']}'),
      todayTotalMilk: (todayMilk.first['total'] as num?)?.toDouble() ?? 0,
      monthlyMilkTotal: (monthlyMilk.first['total'] as num?)?.toDouble() ?? 0,
      monthlyExpenses: expenseValue,
      monthlyMilkIncome: incomeValue,
      profit: incomeValue - expenseValue,
      milkPerCow:
          milkPerCowRows
              .map((row) => CowMilkStat.fromApi(Map<String, dynamic>.from(row)))
              .toList(),
      expensePerCow:
          expensePerCowRows
              .map(
                (row) => CowExpenseStat.fromApi(Map<String, dynamic>.from(row)),
              )
              .toList(),
    );
  }
}
