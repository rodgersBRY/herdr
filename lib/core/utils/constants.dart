import 'package:flutter/foundation.dart';

class AppConstants {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:8888/v1';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8888/v1';
      default:
        return 'http://localhost:8888/v1';
    }
  }

  static const int defaultPageSize = 100;

  static const String syncCreate = 'create';
  static const String syncUpdate = 'update';
  static const String syncSynced = 'synced';
  static const String syncFailed = 'failed';

  static const String statusActive = 'active';
  static const String statusSold = 'sold';
  static const String statusDead = 'dead';

  static const String sourceBought = 'bought';
  static const String sourceBorn = 'born';

  static const String healthTreatment = 'treatment';
  static const String healthVaccination = 'vaccination';
  static const String healthDeworming = 'deworming';

  static const String breedingHeat = 'heat';
  static const String breedingService = 'service';
  static const String breedingPregnancyCheck = 'pregnancy_check';
  static const String breedingCalving = 'calving';

  static const String milkMorning = 'morning';
  static const String milkEvening = 'evening';

  static const String expenseTreatment = 'treatment';
  static const String expenseDrugs = 'drugs';
  static const String expenseSupplement = 'supplement';
  static const String expenseOther = 'other';

  static const List<String> breeds = [
    'Friesian',
    'Jersey',
    'Ayrshire',
    'Guernsey',
    'Brown Swiss',
    'Holstein',
    'Zebu',
    'Crossbreed',
  ];
}
