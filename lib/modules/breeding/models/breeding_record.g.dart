// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breeding_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BreedingRecord _$BreedingRecordFromJson(Map<String, dynamic> json) =>
    BreedingRecord(
      serverId: json['id'] as String?,
      eventType: json['eventType'] as String? ?? '',
      eventDate: json['eventDate'] as String? ?? '',
      expectedCalvingDate: json['expectedCalvingDate'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
    );

Map<String, dynamic> _$BreedingRecordToJson(BreedingRecord instance) =>
    <String, dynamic>{
      if (instance.serverId case final value?) 'id': value,
      'eventType': instance.eventType,
      'eventDate': instance.eventDate,
      if (instance.expectedCalvingDate case final value?)
        'expectedCalvingDate': value,
      if (instance.notes case final value?) 'notes': value,
      'createdAt': instance.createdAt,
    };
