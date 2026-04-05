import 'package:get/get.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_status_service.dart';
import '../../../core/utils/app_formatters.dart';
import '../models/farm_alerts.dart';

class AlertsRepository {
  final DatabaseHelper _db = DatabaseHelper();

  bool get _isOnline => Get.find<NetworkStatusService>().isOnline.value;
  ApiClient get _api => Get.find<ApiClient>();

  Future<FarmAlerts> getAlerts() async {
    if (_isOnline) {
      final response = await _api.dio.get('/alerts');
      return FarmAlerts.fromApi(response.data as Map<String, dynamic>);
    }

    return _getOfflineAlerts();
  }

  Future<FarmAlerts> _getOfflineAlerts() async {
    final db = await _db.db;
    final today = AppFormatters.todayApi();
    final recentThreshold =
        DateTime.now().subtract(const Duration(days: 7)).toIso8601String().split('T').first;

    final healthDueRows = await db.rawQuery('''
      SELECT c.server_id AS cowId, c.tag_number AS tagNumber, c.breed,
             hr.server_id AS recordId, hr.type, hr.next_due_date AS nextDueDate, hr.description
      FROM health_records hr
      JOIN cows c ON c.local_id = hr.cow_local_id
      WHERE c.status = 'active' AND hr.next_due_date IS NOT NULL AND hr.next_due_date <= ?
      ORDER BY hr.next_due_date ASC
    ''', [today]);

    final calvingRows = await db.rawQuery('''
      SELECT c.server_id AS cowId, c.tag_number AS tagNumber, c.breed,
             br.server_id AS breedingRecordId, br.expected_calving_date AS expectedCalvingDate
      FROM breeding_records br
      JOIN cows c ON c.local_id = br.cow_local_id
      WHERE c.status = 'active'
        AND br.expected_calving_date IS NOT NULL
        AND br.expected_calving_date <= ?
        AND br.event_type IN ('service', 'pregnancy_check')
      ORDER BY br.expected_calving_date ASC
    ''', [today]);

    final noMilkRows = await db.rawQuery('''
      SELECT c.server_id AS cowId, c.tag_number AS tagNumber, c.breed
      FROM cows c
      WHERE c.status = 'active'
        AND c.local_id NOT IN (SELECT cow_local_id FROM milk_logs WHERE log_date = ?)
      ORDER BY c.tag_number ASC
    ''', [today]);

    final recentRows = await db.rawQuery('''
      SELECT c.server_id AS cowId, c.tag_number AS tagNumber, c.breed,
             hr.server_id AS recordId, hr.type, hr.record_date AS recordDate, hr.description
      FROM health_records hr
      JOIN cows c ON c.local_id = hr.cow_local_id
      WHERE hr.type = 'treatment' AND hr.record_date >= ?
      ORDER BY hr.record_date DESC
    ''', [recentThreshold]);

    return FarmAlerts(
      healthDue: healthDueRows
          .map((row) => HealthDueAlert.fromApi(Map<String, dynamic>.from(row)))
          .toList(),
      calvingDue: calvingRows
          .map((row) => CalvingDueAlert.fromApi(Map<String, dynamic>.from(row)))
          .toList(),
      noMilkToday: noMilkRows
          .map((row) => NoMilkTodayAlert.fromApi(Map<String, dynamic>.from(row)))
          .toList(),
      recentlyTreated: recentRows
          .map((row) => RecentlyTreatedAlert.fromApi(Map<String, dynamic>.from(row)))
          .toList(),
    );
  }
}
