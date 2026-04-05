// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseLog _$ExpenseLogFromJson(Map<String, dynamic> json) => ExpenseLog(
  serverId: json['id'] as String?,
  category: json['category'] as String? ?? '',
  amount: json['amount'] == null ? 0 : _doubleFromJson(json['amount']),
  expenseDate: json['expenseDate'] as String? ?? '',
  notes: json['notes'] as String?,
  createdAt: json['createdAt'] as String? ?? '',
);

Map<String, dynamic> _$ExpenseLogToJson(ExpenseLog instance) =>
    <String, dynamic>{
      if (instance.serverId case final value?) 'id': value,
      'category': instance.category,
      'amount': instance.amount,
      'expenseDate': instance.expenseDate,
      if (instance.notes case final value?) 'notes': value,
      'createdAt': instance.createdAt,
    };
