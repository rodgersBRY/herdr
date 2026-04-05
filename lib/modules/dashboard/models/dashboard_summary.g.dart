// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CowMilkStat _$CowMilkStatFromJson(Map<String, dynamic> json) => CowMilkStat(
  cowId: json['cowId'] as String,
  tagNumber: json['tagNumber'] as String,
  breed: json['breed'] as String,
  totalLitres: _doubleFromJson(json['totalLitres']),
);

Map<String, dynamic> _$CowMilkStatToJson(CowMilkStat instance) =>
    <String, dynamic>{
      'cowId': instance.cowId,
      'tagNumber': instance.tagNumber,
      'breed': instance.breed,
      'totalLitres': instance.totalLitres,
    };

CowExpenseStat _$CowExpenseStatFromJson(Map<String, dynamic> json) =>
    CowExpenseStat(
      cowId: json['cowId'] as String,
      tagNumber: json['tagNumber'] as String,
      breed: json['breed'] as String,
      totalExpenses: _doubleFromJson(json['totalExpenses']),
    );

Map<String, dynamic> _$CowExpenseStatToJson(CowExpenseStat instance) =>
    <String, dynamic>{
      'cowId': instance.cowId,
      'tagNumber': instance.tagNumber,
      'breed': instance.breed,
      'totalExpenses': instance.totalExpenses,
    };

DashboardSummary _$DashboardSummaryFromJson(Map<String, dynamic> json) =>
    DashboardSummary(
      totalActiveCows: (json['totalActiveCows'] as num).toInt(),
      pregnantCows: (json['pregnantCows'] as num).toInt(),
      cowsInMilk: (json['cowsInMilk'] as num).toInt(),
      todayTotalMilk: _doubleFromJson(json['todayTotalMilk']),
      monthlyMilkTotal: _doubleFromJson(json['monthlyMilkTotal']),
      monthlyExpenses: _doubleFromJson(json['monthlyExpenses']),
      monthlyMilkIncome: _doubleFromJson(json['monthlyMilkIncome']),
      profit: _doubleFromJson(json['profit']),
      milkPerCow:
          (json['milkPerCow'] as List<dynamic>)
              .map((e) => CowMilkStat.fromJson(e as Map<String, dynamic>))
              .toList(),
      expensePerCow:
          (json['expensePerCow'] as List<dynamic>)
              .map((e) => CowExpenseStat.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$DashboardSummaryToJson(DashboardSummary instance) =>
    <String, dynamic>{
      'totalActiveCows': instance.totalActiveCows,
      'pregnantCows': instance.pregnantCows,
      'cowsInMilk': instance.cowsInMilk,
      'todayTotalMilk': instance.todayTotalMilk,
      'monthlyMilkTotal': instance.monthlyMilkTotal,
      'monthlyExpenses': instance.monthlyExpenses,
      'monthlyMilkIncome': instance.monthlyMilkIncome,
      'profit': instance.profit,
      'milkPerCow': instance.milkPerCow.map((e) => e.toJson()).toList(),
      'expensePerCow': instance.expensePerCow.map((e) => e.toJson()).toList(),
    };
