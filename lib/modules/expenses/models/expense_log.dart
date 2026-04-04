class ExpenseLog {
  final String localId;
  final String? serverId;
  final int isSynced;
  final String cowLocalId;
  final String category;
  final double amount;
  final String description;
  final String expenseDate;
  final String? notes;
  final String createdAt;

  const ExpenseLog({
    required this.localId,
    this.serverId,
    this.isSynced = 0,
    required this.cowLocalId,
    required this.category,
    required this.amount,
    required this.description,
    required this.expenseDate,
    this.notes,
    required this.createdAt,
  });

  factory ExpenseLog.fromMap(Map<String, dynamic> map) => ExpenseLog(
        localId: map['local_id'],
        serverId: map['server_id'],
        isSynced: map['is_synced'] ?? 0,
        cowLocalId: map['cow_local_id'],
        category: map['category'],
        amount: (map['amount'] as num).toDouble(),
        description: map['description'],
        expenseDate: map['expense_date'],
        notes: map['notes'],
        createdAt: map['created_at'],
      );

  Map<String, dynamic> toMap() => {
        'local_id': localId,
        'server_id': serverId,
        'is_synced': isSynced,
        'cow_local_id': cowLocalId,
        'category': category,
        'amount': amount,
        'description': description,
        'expense_date': expenseDate,
        'notes': notes,
        'created_at': createdAt,
      };
}
