import '../../../core/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_record.g.dart';

@JsonSerializable(includeIfNull: false)
class HealthRecord {
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String localId;
  @JsonKey(name: 'id')
  final String? serverId;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String syncAction;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String cowLocalId;
  final String type;
  final String description;
  final String? drugUsed;
  final String recordDate;
  final String? nextDueDate;
  final String? notes;
  final String createdAt;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String updatedAt;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? lastError;

  const HealthRecord({
    this.localId = '',
    this.serverId,
    this.syncAction = AppConstants.syncSynced,
    this.cowLocalId = '',
    this.type = '',
    this.description = '',
    this.drugUsed,
    this.recordDate = '',
    this.nextDueDate,
    this.notes,
    this.createdAt = '',
    this.updatedAt = '',
    this.lastError,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) =>
      _$HealthRecordFromJson(json);

  factory HealthRecord.fromDb(Map<String, dynamic> map) => HealthRecord(
        localId: map['local_id'] as String,
        serverId: map['server_id'] as String?,
        syncAction:
            (map['sync_action'] as String?) ?? AppConstants.syncSynced,
        cowLocalId: map['cow_local_id'] as String,
        type: map['type'] as String,
        description: map['description'] as String,
        drugUsed: map['drug_used'] as String?,
        recordDate: map['record_date'] as String,
        nextDueDate: map['next_due_date'] as String?,
        notes: map['notes'] as String?,
        createdAt: map['created_at'] as String,
        updatedAt: map['updated_at'] as String,
        lastError: map['last_error'] as String?,
      );

  factory HealthRecord.fromApi(
    Map<String, dynamic> map, {
    required String localId,
    required String cowLocalId,
    required String syncAction,
    String? lastError,
  }) =>
      HealthRecord.fromJson(map).copyWith(
        localId: localId,
        cowLocalId: cowLocalId,
        syncAction: syncAction,
        updatedAt: DateTime.now().toIso8601String(),
        lastError: lastError,
      );

  Map<String, dynamic> toDbMap() => {
        'local_id': localId,
        'server_id': serverId,
        'sync_action': syncAction,
        'cow_local_id': cowLocalId,
        'type': type,
        'description': description,
        'drug_used': drugUsed,
        'record_date': recordDate,
        'next_due_date': nextDueDate,
        'notes': notes,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'last_error': lastError,
      };

  Map<String, dynamic> toCreatePayload() => {
        'type': type,
        'description': description,
        if (drugUsed != null && drugUsed!.isNotEmpty) 'drug_used': drugUsed,
        'record_date': recordDate,
        if (nextDueDate != null && nextDueDate!.isNotEmpty)
          'next_due_date': nextDueDate,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };

  Map<String, dynamic> toUpdatePayload() => {
        'type': type,
        'description': description,
        'drug_used': drugUsed,
        'next_due_date': nextDueDate,
        'notes': notes,
      };

  Map<String, dynamic> toJson() => _$HealthRecordToJson(this);

  HealthRecord copyWith({
    String? localId,
    String? serverId,
    String? syncAction,
    String? cowLocalId,
    String? type,
    String? description,
    String? drugUsed,
    String? recordDate,
    String? nextDueDate,
    String? notes,
    String? createdAt,
    String? updatedAt,
    String? lastError,
  }) =>
      HealthRecord(
        localId: localId ?? this.localId,
        serverId: serverId ?? this.serverId,
        syncAction: syncAction ?? this.syncAction,
        cowLocalId: cowLocalId ?? this.cowLocalId,
        type: type ?? this.type,
        description: description ?? this.description,
        drugUsed: drugUsed ?? this.drugUsed,
        recordDate: recordDate ?? this.recordDate,
        nextDueDate: nextDueDate ?? this.nextDueDate,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastError: lastError,
      );
}
