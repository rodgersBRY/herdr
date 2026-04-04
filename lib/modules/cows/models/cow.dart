class Cow {
  final String localId;
  final String? serverId;
  final int isSynced;
  final String tag;
  final String? name;
  final String? breed;
  final String gender;
  final String? birthDate;
  final double? weight;
  final String status;
  final String? notes;
  final String createdAt;

  const Cow({
    required this.localId,
    this.serverId,
    this.isSynced = 0,
    required this.tag,
    this.name,
    this.breed,
    required this.gender,
    this.birthDate,
    this.weight,
    this.status = 'active',
    this.notes,
    required this.createdAt,
  });

  factory Cow.fromMap(Map<String, dynamic> map) => Cow(
        localId: map['local_id'],
        serverId: map['server_id'],
        isSynced: map['is_synced'] ?? 0,
        tag: map['tag'],
        name: map['name'],
        breed: map['breed'],
        gender: map['gender'],
        birthDate: map['birth_date'],
        weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
        status: map['status'] ?? 'active',
        notes: map['notes'],
        createdAt: map['created_at'],
      );

  Map<String, dynamic> toMap() => {
        'local_id': localId,
        'server_id': serverId,
        'is_synced': isSynced,
        'tag': tag,
        'name': name,
        'breed': breed,
        'gender': gender,
        'birth_date': birthDate,
        'weight': weight,
        'status': status,
        'notes': notes,
        'created_at': createdAt,
      };

  Cow copyWith({
    String? localId,
    String? serverId,
    int? isSynced,
    String? tag,
    String? name,
    String? breed,
    String? gender,
    String? birthDate,
    double? weight,
    String? status,
    String? notes,
    String? createdAt,
  }) =>
      Cow(
        localId: localId ?? this.localId,
        serverId: serverId ?? this.serverId,
        isSynced: isSynced ?? this.isSynced,
        tag: tag ?? this.tag,
        name: name ?? this.name,
        breed: breed ?? this.breed,
        gender: gender ?? this.gender,
        birthDate: birthDate ?? this.birthDate,
        weight: weight ?? this.weight,
        status: status ?? this.status,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );

  String get displayName => name != null && name!.isNotEmpty ? '$tag — $name' : tag;
}
