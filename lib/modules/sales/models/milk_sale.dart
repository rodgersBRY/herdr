import '../../../core/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'milk_sale.g.dart';

double _doubleFromJson(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String? _stringFromDynamic(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  if (value is num || value is bool) {
    return value.toString();
  }
  if (value is Map<String, dynamic>) {
    for (final key in const ['id', 'value', 'name']) {
      final nested = value[key];
      if (nested != null) {
        return _stringFromDynamic(nested);
      }
    }
  }
  return null;
}

@JsonSerializable(includeIfNull: false)
class MilkSale {
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String localId;
  @JsonKey(name: 'id')
  final String? serverId;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String syncAction;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? organizationId;
  final String saleDate;
  @JsonKey(fromJson: _doubleFromJson)
  final double litresSold;
  @JsonKey(fromJson: _doubleFromJson)
  final double pricePerLitre;
  @JsonKey(fromJson: _doubleFromJson)
  final double totalAmount;
  final String? buyer;
  final String? notes;
  final String createdAt;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String updatedAt;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? lastError;

  const MilkSale({
    this.localId = '',
    this.serverId,
    this.syncAction = AppConstants.syncSynced,
    this.organizationId,
    this.saleDate = '',
    this.litresSold = 0,
    this.pricePerLitre = 0,
    this.totalAmount = 0,
    this.buyer,
    this.notes,
    this.createdAt = '',
    this.updatedAt = '',
    this.lastError,
  });

  factory MilkSale.fromJson(Map<String, dynamic> json) =>
      _$MilkSaleFromJson(json);

  factory MilkSale.fromDb(Map<String, dynamic> map) => MilkSale(
    localId: map['local_id'] as String,
    serverId: map['server_id'] as String?,
    syncAction: (map['sync_action'] as String?) ?? AppConstants.syncSynced,
    organizationId: map['organization_id'] as String?,
    saleDate: map['sale_date'] as String,
    litresSold: (map['litres_sold'] as num).toDouble(),
    pricePerLitre: (map['price_per_litre'] as num).toDouble(),
    totalAmount: (map['total_amount'] as num).toDouble(),
    buyer: map['buyer'] as String?,
    notes: map['notes'] as String?,
    createdAt: map['created_at'] as String,
    updatedAt: map['updated_at'] as String,
    lastError: map['last_error'] as String?,
  );

  factory MilkSale.fromApi(
    Map<String, dynamic> map, {
    required String localId,
    required String syncAction,
    String? lastError,
  }) => MilkSale(
    localId: localId,
    serverId: _stringFromDynamic(map['id']),
    syncAction: syncAction,
    organizationId: _stringFromDynamic(
      map['organizationId'] ?? map['organization_id'],
    ),
    saleDate: _stringFromDynamic(map['saleDate'] ?? map['sale_date']) ?? '',
    litresSold: _doubleFromJson(map['litresSold'] ?? map['litres_sold']),
    pricePerLitre: _doubleFromJson(
      map['pricePerLitre'] ?? map['price_per_litre'],
    ),
    totalAmount: _doubleFromJson(map['totalAmount'] ?? map['total_amount']),
    buyer: _stringFromDynamic(map['buyer']),
    notes: _stringFromDynamic(map['notes']),
    createdAt:
        _stringFromDynamic(map['createdAt'] ?? map['created_at']) ??
        DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
    lastError: lastError,
  );

  Map<String, dynamic> toDbMap() => {
    'local_id': localId,
    'server_id': serverId,
    'sync_action': syncAction,
    'organization_id': organizationId,
    'sale_date': saleDate,
    'litres_sold': litresSold,
    'price_per_litre': pricePerLitre,
    'total_amount': totalAmount,
    'buyer': buyer,
    'notes': notes,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'last_error': lastError,
  };

  Map<String, dynamic> toCreatePayload() => {
    'sale_date': saleDate,
    'litres_sold': litresSold,
    'price_per_litre': pricePerLitre,
    if (buyer != null && buyer!.isNotEmpty) 'buyer': buyer,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };

  Map<String, dynamic> toJson() => _$MilkSaleToJson(this);

  MilkSale copyWith({
    String? localId,
    String? serverId,
    String? syncAction,
    String? organizationId,
    String? saleDate,
    double? litresSold,
    double? pricePerLitre,
    double? totalAmount,
    String? buyer,
    String? notes,
    String? createdAt,
    String? updatedAt,
    String? lastError,
  }) => MilkSale(
    localId: localId ?? this.localId,
    serverId: serverId ?? this.serverId,
    syncAction: syncAction ?? this.syncAction,
    organizationId: organizationId ?? this.organizationId,
    saleDate: saleDate ?? this.saleDate,
    litresSold: litresSold ?? this.litresSold,
    pricePerLitre: pricePerLitre ?? this.pricePerLitre,
    totalAmount: totalAmount ?? this.totalAmount,
    buyer: buyer ?? this.buyer,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastError: lastError,
  );
}
