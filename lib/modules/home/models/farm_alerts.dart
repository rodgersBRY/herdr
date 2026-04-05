import 'package:json_annotation/json_annotation.dart';

part 'farm_alerts.g.dart';

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

  factory HealthDueAlert.fromApi(Map<String, dynamic> map) =>
      _$HealthDueAlertFromJson(map);
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

  factory CalvingDueAlert.fromApi(Map<String, dynamic> map) =>
      _$CalvingDueAlertFromJson(map);
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
      _$NoMilkTodayAlertFromJson(map);
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
      _$RecentlyTreatedAlertFromJson(map);
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

  factory FarmAlerts.fromApi(Map<String, dynamic> map) => _$FarmAlertsFromJson(map);

  Map<String, dynamic> toJson() => _$FarmAlertsToJson(this);
}
