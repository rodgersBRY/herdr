import '../../../core/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cow.g.dart';

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
class Cow {
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String localId;
  @JsonKey(name: 'id')
  final String? serverId;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String syncAction;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? organizationId;
  final String tagNumber;
  final String breed;
  final String dateOfBirth;
  final String source;
  final String status;
  final String createdAt;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String updatedAt;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? lastError;

  const Cow({
    this.localId = '',
    this.serverId,
    this.syncAction = AppConstants.syncSynced,
    this.organizationId,
    this.tagNumber = '',
    this.breed = '',
    this.dateOfBirth = '',
    this.source = AppConstants.sourceBought,
    this.status = AppConstants.statusActive,
    this.createdAt = '',
    this.updatedAt = '',
    this.lastError,
  });

  factory Cow.fromJson(Map<String, dynamic> json) => _$CowFromJson(json);

  bool get isPendingSync => syncAction != AppConstants.syncSynced;

  String get displayName => tagNumber;

  factory Cow.fromDb(Map<String, dynamic> map) => Cow(
    localId: map['local_id'] as String,
    serverId: map['server_id'] as String?,
    syncAction: (map['sync_action'] as String?) ?? AppConstants.syncSynced,
    organizationId: map['organization_id'] as String?,
    tagNumber: map['tag_number'] as String,
    breed: map['breed'] as String,
    dateOfBirth: map['date_of_birth'] as String,
    source: map['source'] as String,
    status: (map['status'] as String?) ?? AppConstants.statusActive,
    createdAt: map['created_at'] as String,
    updatedAt: map['updated_at'] as String,
    lastError: map['last_error'] as String?,
  );

  factory Cow.fromApi(
    Map<String, dynamic> map, {
    required String localId,
    required String syncAction,
    String? lastError,
  }) => Cow(
    localId: localId,
    serverId: _stringFromDynamic(map['id']),
    syncAction: syncAction,
    organizationId: _stringFromDynamic(
      map['organizationId'] ?? map['organization_id'],
    ),
    tagNumber: _stringFromDynamic(map['tagNumber'] ?? map['tag_number']) ?? '',
    breed: _stringFromDynamic(map['breed']) ?? '',
    dateOfBirth:
        _stringFromDynamic(map['dateOfBirth'] ?? map['date_of_birth']) ?? '',
    source: _stringFromDynamic(map['source']) ?? AppConstants.sourceBought,
    status: _stringFromDynamic(map['status']) ?? AppConstants.statusActive,
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
    'tag_number': tagNumber,
    'breed': breed,
    'date_of_birth': dateOfBirth,
    'source': source,
    'status': status,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'last_error': lastError,
  };

  Map<String, dynamic> toCreatePayload() => {
    'tag_number': tagNumber,
    'breed': breed,
    'date_of_birth': dateOfBirth,
    'source': source,
  };

  Map<String, dynamic> toUpdatePayload() => {
    'tag_number': tagNumber,
    'breed': breed,
    'status': status,
  };

  Map<String, dynamic> toJson() => _$CowToJson(this);

  Cow copyWith({
    String? localId,
    String? serverId,
    String? syncAction,
    String? organizationId,
    String? tagNumber,
    String? breed,
    String? dateOfBirth,
    String? source,
    String? status,
    String? createdAt,
    String? updatedAt,
    String? lastError,
  }) => Cow(
    localId: localId ?? this.localId,
    serverId: serverId ?? this.serverId,
    syncAction: syncAction ?? this.syncAction,
    organizationId: organizationId ?? this.organizationId,
    tagNumber: tagNumber ?? this.tagNumber,
    breed: breed ?? this.breed,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    source: source ?? this.source,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastError: lastError,
  );
}
