// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milk_sale.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MilkSale _$MilkSaleFromJson(Map<String, dynamic> json) => MilkSale(
  serverId: json['id'] as String?,
  saleDate: json['saleDate'] as String? ?? '',
  litresSold:
      json['litresSold'] == null ? 0 : _doubleFromJson(json['litresSold']),
  pricePerLitre:
      json['pricePerLitre'] == null
          ? 0
          : _doubleFromJson(json['pricePerLitre']),
  totalAmount:
      json['totalAmount'] == null ? 0 : _doubleFromJson(json['totalAmount']),
  buyer: json['buyer'] as String?,
  notes: json['notes'] as String?,
  createdAt: json['createdAt'] as String? ?? '',
);

Map<String, dynamic> _$MilkSaleToJson(MilkSale instance) => <String, dynamic>{
  if (instance.serverId case final value?) 'id': value,
  'saleDate': instance.saleDate,
  'litresSold': instance.litresSold,
  'pricePerLitre': instance.pricePerLitre,
  'totalAmount': instance.totalAmount,
  if (instance.buyer case final value?) 'buyer': value,
  if (instance.notes case final value?) 'notes': value,
  'createdAt': instance.createdAt,
};
