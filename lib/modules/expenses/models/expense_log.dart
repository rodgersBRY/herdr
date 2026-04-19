import '../../../core/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'expense_log.g.dart';

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
class ExpenseLog {
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
  final String category;
  @JsonKey(fromJson: _doubleFromJson)
  final double amount;
  final String expenseDate;
  final String? notes;
  final String createdAt;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String updatedAt;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? lastError;

  const ExpenseLog({
    this.localId = '',
    this.serverId,
    this.syncAction = AppConstants.syncSynced,
    this.organizationId,
    this.cowLocalId = '',
    this.category = '',
    this.amount = 0,
    this.expenseDate = '',
    this.notes,
    this.createdAt = '',
    this.updatedAt = '',
    this.lastError,
  });

  factory ExpenseLog.fromJson(Map<String, dynamic> json) =>
      _$ExpenseLogFromJson(json);

  factory ExpenseLog.fromDb(Map<String, dynamic> map) => ExpenseLog(
    localId: map['local_id'] as String,
    serverId: map['server_id'] as String?,
    syncAction: (map['sync_action'] as String?) ?? AppConstants.syncSynced,
    organizationId: map['organization_id'] as String?,
    cowLocalId: map['cow_local_id'] as String,
    category: map['category'] as String,
    amount: (map['amount'] as num).toDouble(),
    expenseDate: map['expense_date'] as String,
    notes: map['notes'] as String?,
    createdAt: map['created_at'] as String,
    updatedAt: map['updated_at'] as String,
    lastError: map['last_error'] as String?,
  );

  factory ExpenseLog.fromApi(
    Map<String, dynamic> map, {
    required String localId,
    required String cowLocalId,
    required String syncAction,
    String? lastError,
  }) => ExpenseLog(
    localId: localId,
    serverId: _stringFromDynamic(map['id']),
    syncAction: syncAction,
    organizationId: _stringFromDynamic(
      map['organizationId'] ?? map['organization_id'],
    ),
    cowLocalId: cowLocalId,
    category: _stringFromDynamic(map['category']) ?? '',
    amount: _doubleFromJson(map['amount']),
    expenseDate:
        _stringFromDynamic(map['expenseDate'] ?? map['expense_date']) ?? '',
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
    'cow_local_id': cowLocalId,
    'category': category,
    'amount': amount,
    'expense_date': expenseDate,
    'notes': notes,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'last_error': lastError,
  };

  Map<String, dynamic> toCreatePayload() => {
    'category': category,
    'amount': amount,
    'expense_date': expenseDate,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };

  Map<String, dynamic> toJson() => _$ExpenseLogToJson(this);

  ExpenseLog copyWith({
    String? localId,
    String? serverId,
    String? syncAction,
    String? organizationId,
    String? cowLocalId,
    String? category,
    double? amount,
    String? expenseDate,
    String? notes,
    String? createdAt,
    String? updatedAt,
    String? lastError,
  }) => ExpenseLog(
    localId: localId ?? this.localId,
    serverId: serverId ?? this.serverId,
    syncAction: syncAction ?? this.syncAction,
    organizationId: organizationId ?? this.organizationId,
    cowLocalId: cowLocalId ?? this.cowLocalId,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    expenseDate: expenseDate ?? this.expenseDate,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastError: lastError,
  );
}
