// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farm_alerts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthDueAlert _$HealthDueAlertFromJson(Map<String, dynamic> json) =>
    HealthDueAlert(
      cowId: json['cowId'] as String,
      tagNumber: json['tagNumber'] as String,
      breed: json['breed'] as String,
      recordId: json['recordId'] as String,
      type: json['type'] as String,
      nextDueDate: json['nextDueDate'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$HealthDueAlertToJson(HealthDueAlert instance) =>
    <String, dynamic>{
      'cowId': instance.cowId,
      'tagNumber': instance.tagNumber,
      'breed': instance.breed,
      'recordId': instance.recordId,
      'type': instance.type,
      'nextDueDate': instance.nextDueDate,
      'description': instance.description,
    };

CalvingDueAlert _$CalvingDueAlertFromJson(Map<String, dynamic> json) =>
    CalvingDueAlert(
      cowId: json['cowId'] as String,
      tagNumber: json['tagNumber'] as String,
      breed: json['breed'] as String,
      breedingRecordId: json['breedingRecordId'] as String,
      expectedCalvingDate: json['expectedCalvingDate'] as String,
    );

Map<String, dynamic> _$CalvingDueAlertToJson(CalvingDueAlert instance) =>
    <String, dynamic>{
      'cowId': instance.cowId,
      'tagNumber': instance.tagNumber,
      'breed': instance.breed,
      'breedingRecordId': instance.breedingRecordId,
      'expectedCalvingDate': instance.expectedCalvingDate,
    };

NoMilkTodayAlert _$NoMilkTodayAlertFromJson(Map<String, dynamic> json) =>
    NoMilkTodayAlert(
      cowId: json['cowId'] as String,
      tagNumber: json['tagNumber'] as String,
      breed: json['breed'] as String,
    );

Map<String, dynamic> _$NoMilkTodayAlertToJson(NoMilkTodayAlert instance) =>
    <String, dynamic>{
      'cowId': instance.cowId,
      'tagNumber': instance.tagNumber,
      'breed': instance.breed,
    };

RecentlyTreatedAlert _$RecentlyTreatedAlertFromJson(
  Map<String, dynamic> json,
) => RecentlyTreatedAlert(
  cowId: json['cowId'] as String,
  tagNumber: json['tagNumber'] as String,
  breed: json['breed'] as String,
  recordId: json['recordId'] as String,
  type: json['type'] as String,
  recordDate: json['recordDate'] as String,
  description: json['description'] as String,
);

Map<String, dynamic> _$RecentlyTreatedAlertToJson(
  RecentlyTreatedAlert instance,
) => <String, dynamic>{
  'cowId': instance.cowId,
  'tagNumber': instance.tagNumber,
  'breed': instance.breed,
  'recordId': instance.recordId,
  'type': instance.type,
  'recordDate': instance.recordDate,
  'description': instance.description,
};

FarmAlerts _$FarmAlertsFromJson(Map<String, dynamic> json) => FarmAlerts(
  healthDue:
      (json['healthDue'] as List<dynamic>)
          .map((e) => HealthDueAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
  calvingDue:
      (json['calvingDue'] as List<dynamic>)
          .map((e) => CalvingDueAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
  noMilkToday:
      (json['noMilkToday'] as List<dynamic>)
          .map((e) => NoMilkTodayAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
  recentlyTreated:
      (json['recentlyTreated'] as List<dynamic>)
          .map((e) => RecentlyTreatedAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$FarmAlertsToJson(
  FarmAlerts instance,
) => <String, dynamic>{
  'healthDue': instance.healthDue.map((e) => e.toJson()).toList(),
  'calvingDue': instance.calvingDue.map((e) => e.toJson()).toList(),
  'noMilkToday': instance.noMilkToday.map((e) => e.toJson()).toList(),
  'recentlyTreated': instance.recentlyTreated.map((e) => e.toJson()).toList(),
};
