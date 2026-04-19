import '../../../core/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'milk_log.g.dart';

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
class MilkLog {
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String localId;
  @JsonKey(name: 'id')
  final String? serverId;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String syncAction;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? organizationId;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String cowLocalId;
  final String logDate;
  @JsonKey(fromJson: _doubleFromJson)
  final double litres;
  final String period;
  final String? notes;
  final String createdAt;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String updatedAt;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? lastError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? cowTagNumber;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? cowBreed;

  const MilkLog({
    this.localId = '',
    this.serverId,
    this.syncAction = AppConstants.syncSynced,
    this.organizationId,
    this.cowLocalId = '',
    this.logDate = '',
    this.litres = 0,
    this.period = AppConstants.milkMorning,
    this.notes,
    this.createdAt = '',
    this.updatedAt = '',
    this.lastError,
    this.cowTagNumber,
    this.cowBreed,
  });

  factory MilkLog.fromJson(Map<String, dynamic> json) =>
      _$MilkLogFromJson(json);

  factory MilkLog.fromDb(Map<String, dynamic> map) => MilkLog(
    localId: map['local_id'] as String,
    serverId: map['server_id'] as String?,
    syncAction: (map['sync_action'] as String?) ?? AppConstants.syncSynced,
    organizationId: map['organization_id'] as String?,
    cowLocalId: map['cow_local_id'] as String,
    logDate: map['log_date'] as String,
    litres: (map['litres'] as num).toDouble(),
    period: map['period'] as String,
    notes: map['notes'] as String?,
    createdAt: map['created_at'] as String,
    updatedAt: map['updated_at'] as String,
    lastError: map['last_error'] as String?,
    cowTagNumber: map['cow_tag_number'] as String?,
    cowBreed: map['cow_breed'] as String?,
  );

  factory MilkLog.fromApi(
    Map<String, dynamic> map, {
    required String localId,
    required String cowLocalId,
    required String syncAction,
    String? lastError,
  }) => MilkLog(
    localId: localId,
    serverId: _stringFromDynamic(map['id']),
    syncAction: syncAction,
    organizationId: _stringFromDynamic(
      map['organizationId'] ?? map['organization_id'],
    ),
    cowLocalId: cowLocalId,
    logDate: _stringFromDynamic(map['logDate'] ?? map['log_date']) ?? '',
    litres: _doubleFromJson(map['litres']),
    period: _stringFromDynamic(map['period']) ?? AppConstants.milkMorning,
    notes: _stringFromDynamic(map['notes']),
    createdAt:
        _stringFromDynamic(map['createdAt'] ?? map['created_at']) ??
        DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
    lastError: lastError,
    cowTagNumber: _stringFromDynamic(
      map['cowTagNumber'] ?? map['cow_tag_number'],
    ),
    cowBreed: _stringFromDynamic(map['cowBreed'] ?? map['cow_breed']),
  );

  Map<String, dynamic> toDbMap() => {
    'local_id': localId,
    'server_id': serverId,
    'sync_action': syncAction,
    'organization_id': organizationId,
    'cow_local_id': cowLocalId,
    'log_date': logDate,
    'litres': litres,
    'period': period,
    'notes': notes,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'last_error': lastError,
  };

  Map<String, dynamic> toCreatePayload() => {
    'log_date': logDate,
    'litres': litres,
    'period': period,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };

  Map<String, dynamic> toUpdatePayload() => {
    'litres': litres,
    'period': period,
    'notes': notes,
  };

  Map<String, dynamic> toJson() => _$MilkLogToJson(this);

  MilkLog copyWith({
    String? localId,
    String? serverId,
    String? syncAction,
    String? organizationId,
    String? cowLocalId,
    String? logDate,
    double? litres,
    String? period,
    String? notes,
    String? createdAt,
    String? updatedAt,
    String? lastError,
    String? cowTagNumber,
    String? cowBreed,
  }) => MilkLog(
    localId: localId ?? this.localId,
    serverId: serverId ?? this.serverId,
    syncAction: syncAction ?? this.syncAction,
    organizationId: organizationId ?? this.organizationId,
    cowLocalId: cowLocalId ?? this.cowLocalId,
    logDate: logDate ?? this.logDate,
    litres: litres ?? this.litres,
    period: period ?? this.period,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastError: lastError,
    cowTagNumber: cowTagNumber ?? this.cowTagNumber,
    cowBreed: cowBreed ?? this.cowBreed,
  );
}
