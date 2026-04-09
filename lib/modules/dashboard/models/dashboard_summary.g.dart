// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CowMilkStat _$CowMilkStatFromJson(Map<String, dynamic> json) => CowMilkStat(
  cowId: json['cow_id'] as String,
  tagNumber: json['tag_number'] as String,
  breed: json['breed'] as String,
  totalLitres: _doubleFromJson(json['total_litres']),
);

Map<String, dynamic> _$CowMilkStatToJson(CowMilkStat instance) =>
    <String, dynamic>{
      'cow_id': instance.cowId,
      'tag_number': instance.tagNumber,
      'breed': instance.breed,
      'total_litres': instance.totalLitres,
    };

CowExpenseStat _$CowExpenseStatFromJson(Map<String, dynamic> json) =>
    CowExpenseStat(
      cowId: json['cow_id'] as String,
      tagNumber: json['tag_number'] as String,
      breed: json['breed'] as String,
      totalExpenses: _doubleFromJson(json['total_expenses']),
    );

Map<String, dynamic> _$CowExpenseStatToJson(CowExpenseStat instance) =>
    <String, dynamic>{
      'cow_id': instance.cowId,
      'tag_number': instance.tagNumber,
      'breed': instance.breed,
      'total_expenses': instance.totalExpenses,
    };

DashboardSummary _$DashboardSummaryFromJson(Map<String, dynamic> json) =>
    DashboardSummary(
      totalActiveCows: (json['total_active_cows'] as num).toInt(),
      pregnantCows: (json['pregnant_cows'] as num).toInt(),
      cowsInMilk: (json['cows_in_milk'] as num).toInt(),
      todayTotalMilk: _doubleFromJson(json['today_total_milk']),
      monthlyMilkTotal: _doubleFromJson(json['monthly_milk_total']),
      monthlyExpenses: _doubleFromJson(json['monthly_expenses']),
      monthlyMilkIncome: _doubleFromJson(json['monthly_milk_income']),
      profit: _doubleFromJson(json['profit']),
      milkPerCow:
          (json['milk_per_cow'] as List<dynamic>)
              .map((e) => CowMilkStat.fromJson(e as Map<String, dynamic>))
              .toList(),
      expensePerCow:
          (json['expense_per_cow'] as List<dynamic>)
              .map((e) => CowExpenseStat.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$DashboardSummaryToJson(DashboardSummary instance) =>
    <String, dynamic>{
      'total_active_cows': instance.totalActiveCows,
      'pregnant_cows': instance.pregnantCows,
      'cows_in_milk': instance.cowsInMilk,
      'today_total_milk': instance.todayTotalMilk,
      'monthly_milk_total': instance.monthlyMilkTotal,
      'monthly_expenses': instance.monthlyExpenses,
      'monthly_milk_income': instance.monthlyMilkIncome,
      'profit': instance.profit,
      'milk_per_cow': instance.milkPerCow.map((e) => e.toJson()).toList(),
      'expense_per_cow': instance.expensePerCow.map((e) => e.toJson()).toList(),
    };
