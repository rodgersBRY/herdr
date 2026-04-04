class MilkLog {
  final String localId;
  final String? serverId;
  final int isSynced;
  final String cowLocalId;
  final String logDate;
  final double morningLitres;
  final double eveningLitres;
  final String? notes;
  final String createdAt;

  // Optional join fields
  final String? cowTag;
  final String? cowName;

  const MilkLog({
    required this.localId,
    this.serverId,
    this.isSynced = 0,
    required this.cowLocalId,
    required this.logDate,
    this.morningLitres = 0,
    this.eveningLitres = 0,
    this.notes,
    required this.createdAt,
    this.cowTag,
    this.cowName,
  });

  double get totalLitres => morningLitres + eveningLitres;

  factory MilkLog.fromMap(Map<String, dynamic> map) => MilkLog(
        localId: map['local_id'],
        serverId: map['server_id'],
        isSynced: map['is_synced'] ?? 0,
        cowLocalId: map['cow_local_id'],
        logDate: map['log_date'],
        morningLitres: (map['morning_litres'] as num?)?.toDouble() ?? 0,
        eveningLitres: (map['evening_litres'] as num?)?.toDouble() ?? 0,
        notes: map['notes'],
        createdAt: map['created_at'],
        cowTag: map['cow_tag'],
        cowName: map['cow_name'],
      );

  Map<String, dynamic> toMap() => {
        'local_id': localId,
        'server_id': serverId,
        'is_synced': isSynced,
        'cow_local_id': cowLocalId,
        'log_date': logDate,
        'morning_litres': morningLitres,
        'evening_litres': eveningLitres,
        'notes': notes,
        'created_at': createdAt,
      };

  MilkLog copyWith({
    String? localId,
    String? serverId,
    int? isSynced,
    String? cowLocalId,
    String? logDate,
    double? morningLitres,
    double? eveningLitres,
    String? notes,
    String? createdAt,
    String? cowTag,
    String? cowName,
  }) =>
      MilkLog(
        localId: localId ?? this.localId,
        serverId: serverId ?? this.serverId,
        isSynced: isSynced ?? this.isSynced,
        cowLocalId: cowLocalId ?? this.cowLocalId,
        logDate: logDate ?? this.logDate,
        morningLitres: morningLitres ?? this.morningLitres,
        eveningLitres: eveningLitres ?? this.eveningLitres,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        cowTag: cowTag ?? this.cowTag,
        cowName: cowName ?? this.cowName,
      );
}
