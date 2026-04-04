class BreedingRecord {
  final String localId;
  final String? serverId;
  final int isSynced;
  final String cowLocalId;
  final String recordType;
  final String? serviceDate;
  final String? sireName;
  final String? sireBreed;
  final String? pregnancyCheckDate;
  final String? pregnancyResult;
  final String? expectedCalvingDate;
  final String? actualCalvingDate;
  final String? calfGender;
  final String? calfTag;
  final String? notes;
  final String createdAt;

  const BreedingRecord({
    required this.localId,
    this.serverId,
    this.isSynced = 0,
    required this.cowLocalId,
    required this.recordType,
    this.serviceDate,
    this.sireName,
    this.sireBreed,
    this.pregnancyCheckDate,
    this.pregnancyResult,
    this.expectedCalvingDate,
    this.actualCalvingDate,
    this.calfGender,
    this.calfTag,
    this.notes,
    required this.createdAt,
  });

  factory BreedingRecord.fromMap(Map<String, dynamic> map) => BreedingRecord(
        localId: map['local_id'],
        serverId: map['server_id'],
        isSynced: map['is_synced'] ?? 0,
        cowLocalId: map['cow_local_id'],
        recordType: map['record_type'],
        serviceDate: map['service_date'],
        sireName: map['sire_name'],
        sireBreed: map['sire_breed'],
        pregnancyCheckDate: map['pregnancy_check_date'],
        pregnancyResult: map['pregnancy_result'],
        expectedCalvingDate: map['expected_calving_date'],
        actualCalvingDate: map['actual_calving_date'],
        calfGender: map['calf_gender'],
        calfTag: map['calf_tag'],
        notes: map['notes'],
        createdAt: map['created_at'],
      );

  Map<String, dynamic> toMap() => {
        'local_id': localId,
        'server_id': serverId,
        'is_synced': isSynced,
        'cow_local_id': cowLocalId,
        'record_type': recordType,
        'service_date': serviceDate,
        'sire_name': sireName,
        'sire_breed': sireBreed,
        'pregnancy_check_date': pregnancyCheckDate,
        'pregnancy_result': pregnancyResult,
        'expected_calving_date': expectedCalvingDate,
        'actual_calving_date': actualCalvingDate,
        'calf_gender': calfGender,
        'calf_tag': calfTag,
        'notes': notes,
        'created_at': createdAt,
      };
}
