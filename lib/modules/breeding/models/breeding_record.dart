import '../../../core/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'breeding_record.g.dart';

@JsonSerializable(includeIfNull: false)
class BreedingRecord {
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String localId;
  @JsonKey(name: 'id')
  final String? serverId;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String syncAction;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String cowLocalId;
  final String eventType;
  final String eventDate;
  final String? expectedCalvingDate;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? calfTagNumber;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? calfBreed;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? calfDateOfBirth;
  final String? notes;
  final String createdAt;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String updatedAt;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? lastError;

  const BreedingRecord({
    this.localId = '',
    this.serverId,
    this.syncAction = AppConstants.syncSynced,
    this.cowLocalId = '',
    this.eventType = '',
    this.eventDate = '',
    this.expectedCalvingDate,
    this.calfTagNumber,
    this.calfBreed,
    this.calfDateOfBirth,
    this.notes,
    this.createdAt = '',
    this.updatedAt = '',
    this.lastError,
  });

  factory BreedingRecord.fromJson(Map<String, dynamic> json) =>
      _$BreedingRecordFromJson(json);

  factory BreedingRecord.fromDb(Map<String, dynamic> map) => BreedingRecord(
        localId: map['local_id'] as String,
        serverId: map['server_id'] as String?,
        syncAction:
            (map['sync_action'] as String?) ?? AppConstants.syncSynced,
        cowLocalId: map['cow_local_id'] as String,
        eventType: map['event_type'] as String,
        eventDate: map['event_date'] as String,
        expectedCalvingDate: map['expected_calving_date'] as String?,
        calfTagNumber: map['calf_tag_number'] as String?,
        calfBreed: map['calf_breed'] as String?,
        calfDateOfBirth: map['calf_date_of_birth'] as String?,
        notes: map['notes'] as String?,
        createdAt: map['created_at'] as String,
        updatedAt: map['updated_at'] as String,
        lastError: map['last_error'] as String?,
      );

  factory BreedingRecord.fromApi(
    Map<String, dynamic> map, {
    required String localId,
    required String cowLocalId,
    required String syncAction,
    String? lastError,
  }) =>
      BreedingRecord.fromJson(map).copyWith(
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
        'event_type': eventType,
        'event_date': eventDate,
        'expected_calving_date': expectedCalvingDate,
        'calf_tag_number': calfTagNumber,
        'calf_breed': calfBreed,
        'calf_date_of_birth': calfDateOfBirth,
        'notes': notes,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'last_error': lastError,
      };

  Map<String, dynamic> toCreatePayload() => {
        'event_type': eventType,
        'event_date': eventDate,
        if (expectedCalvingDate != null && expectedCalvingDate!.isNotEmpty)
          'expected_calving_date': expectedCalvingDate,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
        if (eventType == AppConstants.breedingCalving)
          'calf': {
            'tag_number': calfTagNumber,
            'breed': calfBreed,
            'date_of_birth': calfDateOfBirth ?? eventDate,
          },
      };

  Map<String, dynamic> toJson() => _$BreedingRecordToJson(this);

  BreedingRecord copyWith({
    String? localId,
    String? serverId,
    String? syncAction,
    String? cowLocalId,
    String? eventType,
    String? eventDate,
    String? expectedCalvingDate,
    String? calfTagNumber,
    String? calfBreed,
    String? calfDateOfBirth,
    String? notes,
    String? createdAt,
    String? updatedAt,
    String? lastError,
  }) =>
      BreedingRecord(
        localId: localId ?? this.localId,
        serverId: serverId ?? this.serverId,
        syncAction: syncAction ?? this.syncAction,
        cowLocalId: cowLocalId ?? this.cowLocalId,
        eventType: eventType ?? this.eventType,
        eventDate: eventDate ?? this.eventDate,
        expectedCalvingDate: expectedCalvingDate ?? this.expectedCalvingDate,
        calfTagNumber: calfTagNumber ?? this.calfTagNumber,
        calfBreed: calfBreed ?? this.calfBreed,
        calfDateOfBirth: calfDateOfBirth ?? this.calfDateOfBirth,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastError: lastError,
      );
}
