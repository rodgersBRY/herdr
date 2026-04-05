// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthRecord _$HealthRecordFromJson(Map<String, dynamic> json) => HealthRecord(
  serverId: json['id'] as String?,
  type: json['type'] as String? ?? '',
  description: json['description'] as String? ?? '',
  drugUsed: json['drugUsed'] as String?,
  recordDate: json['recordDate'] as String? ?? '',
  nextDueDate: json['nextDueDate'] as String?,
  notes: json['notes'] as String?,
  createdAt: json['createdAt'] as String? ?? '',
);

Map<String, dynamic> _$HealthRecordToJson(HealthRecord instance) =>
    <String, dynamic>{
      if (instance.serverId case final value?) 'id': value,
      'type': instance.type,
      'description': instance.description,
      if (instance.drugUsed case final value?) 'drugUsed': value,
      'recordDate': instance.recordDate,
      if (instance.nextDueDate case final value?) 'nextDueDate': value,
      if (instance.notes case final value?) 'notes': value,
      'createdAt': instance.createdAt,
    };
