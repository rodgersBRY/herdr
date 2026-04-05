// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cow.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cow _$CowFromJson(Map<String, dynamic> json) => Cow(
  serverId: json['id'] as String?,
  tagNumber: json['tagNumber'] as String? ?? '',
  breed: json['breed'] as String? ?? '',
  dateOfBirth: json['dateOfBirth'] as String? ?? '',
  source: json['source'] as String? ?? AppConstants.sourceBought,
  status: json['status'] as String? ?? AppConstants.statusActive,
  createdAt: json['createdAt'] as String? ?? '',
);

Map<String, dynamic> _$CowToJson(Cow instance) => <String, dynamic>{
  if (instance.serverId case final value?) 'id': value,
  'tagNumber': instance.tagNumber,
  'breed': instance.breed,
  'dateOfBirth': instance.dateOfBirth,
  'source': instance.source,
  'status': instance.status,
  'createdAt': instance.createdAt,
};
