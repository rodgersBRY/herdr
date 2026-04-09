import 'package:json_annotation/json_annotation.dart';

part 'farm_alerts.g.dart';

String _requiredString(dynamic value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }
  if (value is String) {
    return value;
  }
  if (value is num || value is bool) {
    return value.toString();
  }
  if (value is Map<String, dynamic>) {
    for (final key in const [
      'id',
      'value',
      'name',
      'description',
      'date',
      'recordDate',
      'record_date',
      'formatted',
      r'$date',
    ]) {
      final nested = value[key];
      if (nested != null) {
        return _requiredString(nested, fallback: fallback);
      }
    }

    for (final nested in value.values) {
      final resolved = _requiredString(nested, fallback: fallback);
      if (resolved.isNotEmpty) {
        return resolved;
      }
    }
  }
  return fallback;
}

@JsonSerializable()
class HealthDueAlert {
  final String cowId;
  final String tagNumber;
  final String breed;
  final String recordId;
  final String type;
  final String nextDueDate;
  final String description;

  const HealthDueAlert({
    required this.cowId,
    required this.tagNumber,
    required this.breed,
    required this.recordId,
    required this.type,
    required this.nextDueDate,
    required this.description,
  });

  factory HealthDueAlert.fromApi(Map<String, dynamic> map) => HealthDueAlert(
    cowId: _requiredString(map['cowId'] ?? map['cow_id']),
    tagNumber: _requiredString(map['tagNumber'] ?? map['tag_number']),
    breed: _requiredString(map['breed']),
    recordId: _requiredString(map['recordId'] ?? map['record_id']),
    type: _requiredString(map['type']),
    nextDueDate: _requiredString(map['nextDueDate'] ?? map['next_due_date']),
    description: _requiredString(map['description']),
  );
  factory HealthDueAlert.fromJson(Map<String, dynamic> json) =>
      _$HealthDueAlertFromJson(json);

  Map<String, dynamic> toJson() => _$HealthDueAlertToJson(this);
}

@JsonSerializable()
class CalvingDueAlert {
  final String cowId;
  final String tagNumber;
  final String breed;
  final String breedingRecordId;
  final String expectedCalvingDate;

  const CalvingDueAlert({
    required this.cowId,
    required this.tagNumber,
    required this.breed,
    required this.breedingRecordId,
    required this.expectedCalvingDate,
  });

  factory CalvingDueAlert.fromApi(Map<String, dynamic> map) => CalvingDueAlert(
    cowId: _requiredString(map['cowId'] ?? map['cow_id']),
    tagNumber: _requiredString(map['tagNumber'] ?? map['tag_number']),
    breed: _requiredString(map['breed']),
    breedingRecordId: _requiredString(
      map['breedingRecordId'] ?? map['breeding_record_id'],
    ),
    expectedCalvingDate: _requiredString(
      map['expectedCalvingDate'] ?? map['expected_calving_date'],
    ),
  );
  factory CalvingDueAlert.fromJson(Map<String, dynamic> json) =>
      _$CalvingDueAlertFromJson(json);

  Map<String, dynamic> toJson() => _$CalvingDueAlertToJson(this);
}

@JsonSerializable()
class NoMilkTodayAlert {
  final String cowId;
  final String tagNumber;
  final String breed;

  const NoMilkTodayAlert({
    required this.cowId,
    required this.tagNumber,
    required this.breed,
  });

  factory NoMilkTodayAlert.fromApi(Map<String, dynamic> map) =>
      NoMilkTodayAlert(
        cowId: _requiredString(map['cowId'] ?? map['cow_id']),
        tagNumber: _requiredString(map['tagNumber'] ?? map['tag_number']),
        breed: _requiredString(map['breed']),
      );
  factory NoMilkTodayAlert.fromJson(Map<String, dynamic> json) =>
      _$NoMilkTodayAlertFromJson(json);

  Map<String, dynamic> toJson() => _$NoMilkTodayAlertToJson(this);
}

@JsonSerializable()
class RecentlyTreatedAlert {
  final String cowId;
  final String tagNumber;
  final String breed;
  final String recordId;
  final String type;
  final String recordDate;
  final String description;

  const RecentlyTreatedAlert({
    required this.cowId,
    required this.tagNumber,
    required this.breed,
    required this.recordId,
    required this.type,
    required this.recordDate,
    required this.description,
  });

  factory RecentlyTreatedAlert.fromApi(Map<String, dynamic> map) =>
      RecentlyTreatedAlert(
        cowId: _requiredString(map['cowId'] ?? map['cow_id']),
        tagNumber: _requiredString(map['tagNumber'] ?? map['tag_number']),
        breed: _requiredString(map['breed']),
        recordId: _requiredString(map['recordId'] ?? map['record_id']),
        type: _requiredString(map['type']),
        recordDate: _requiredString(map['recordDate'] ?? map['record_date']),
        description: _requiredString(map['description']),
      );
  factory RecentlyTreatedAlert.fromJson(Map<String, dynamic> json) =>
      _$RecentlyTreatedAlertFromJson(json);

  Map<String, dynamic> toJson() => _$RecentlyTreatedAlertToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FarmAlerts {
  final List<HealthDueAlert> healthDue;
  final List<CalvingDueAlert> calvingDue;
  final List<NoMilkTodayAlert> noMilkToday;
  final List<RecentlyTreatedAlert> recentlyTreated;

  const FarmAlerts({
    required this.healthDue,
    required this.calvingDue,
    required this.noMilkToday,
    required this.recentlyTreated,
  });

  const FarmAlerts.empty()
    : healthDue = const [],
      calvingDue = const [],
      noMilkToday = const [],
      recentlyTreated = const [];

  factory FarmAlerts.fromApi(Map<String, dynamic> map) => FarmAlerts(
    healthDue:
        ((map['healthDue'] ?? map['health_due']) as List<dynamic>? ?? const [])
            .map((item) => HealthDueAlert.fromApi(item as Map<String, dynamic>))
            .toList(),
    calvingDue:
        ((map['calvingDue'] ?? map['calving_due']) as List<dynamic>? ??
                const [])
            .map(
              (item) => CalvingDueAlert.fromApi(item as Map<String, dynamic>),
            )
            .toList(),
    noMilkToday:
        ((map['noMilkToday'] ?? map['no_milk_today']) as List<dynamic>? ??
                const [])
            .map(
              (item) => NoMilkTodayAlert.fromApi(item as Map<String, dynamic>),
            )
            .toList(),
    recentlyTreated:
        ((map['recentlyTreated'] ?? map['recently_treated'])
                    as List<dynamic>? ??
                const [])
            .map(
              (item) =>
                  RecentlyTreatedAlert.fromApi(item as Map<String, dynamic>),
            )
            .toList(),
  );
  factory FarmAlerts.fromJson(Map<String, dynamic> json) =>
      _$FarmAlertsFromJson(json);

  Map<String, dynamic> toJson() => _$FarmAlertsToJson(this);
}
