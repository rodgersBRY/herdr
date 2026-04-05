// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milk_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MilkLog _$MilkLogFromJson(Map<String, dynamic> json) => MilkLog(
  serverId: json['id'] as String?,
  logDate: json['logDate'] as String? ?? '',
  litres: json['litres'] == null ? 0 : _doubleFromJson(json['litres']),
  period: json['period'] as String? ?? AppConstants.milkMorning,
  notes: json['notes'] as String?,
  createdAt: json['createdAt'] as String? ?? '',
);

Map<String, dynamic> _$MilkLogToJson(MilkLog instance) => <String, dynamic>{
  if (instance.serverId case final value?) 'id': value,
  'logDate': instance.logDate,
  'litres': instance.litres,
  'period': instance.period,
  if (instance.notes case final value?) 'notes': value,
  'createdAt': instance.createdAt,
};
