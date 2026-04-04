class HealthRecord {
  final String localId;
  final String? serverId;
  final int isSynced;
  final String cowLocalId;
  final String recordType;
  final String description;
  final String? vetName;
  final double? cost;
  final String recordDate;
  final String? nextDueDate;
  final String? notes;
  final String createdAt;

  const HealthRecord({
    required this.localId,
    this.serverId,
    this.isSynced = 0,
    required this.cowLocalId,
    required this.recordType,
    required this.description,
    this.vetName,
    this.cost,
    required this.recordDate,
    this.nextDueDate,
    this.notes,
    required this.createdAt,
  });

  factory HealthRecord.fromMap(Map<String, dynamic> map) => HealthRecord(
        localId: map['local_id'],
        serverId: map['server_id'],
        isSynced: map['is_synced'] ?? 0,
        cowLocalId: map['cow_local_id'],
        recordType: map['record_type'],
        description: map['description'],
        vetName: map['vet_name'],
        cost: (map['cost'] as num?)?.toDouble(),
        recordDate: map['record_date'],
        nextDueDate: map['next_due_date'],
        notes: map['notes'],
        createdAt: map['created_at'],
      );

  Map<String, dynamic> toMap() => {
        'local_id': localId,
        'server_id': serverId,
        'is_synced': isSynced,
        'cow_local_id': cowLocalId,
        'record_type': recordType,
        'description': description,
        'vet_name': vetName,
        'cost': cost,
        'record_date': recordDate,
        'next_due_date': nextDueDate,
        'notes': notes,
        'created_at': createdAt,
      };
}
