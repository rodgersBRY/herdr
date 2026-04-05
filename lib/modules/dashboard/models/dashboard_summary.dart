import '../../../core/utils/app_formatters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dashboard_summary.g.dart';

double _doubleFromJson(dynamic value) => AppFormatters.asDouble(value);

@JsonSerializable()
class CowMilkStat {
  final String cowId;
  final String tagNumber;
  final String breed;
  @JsonKey(fromJson: _doubleFromJson)
  final double totalLitres;

  const CowMilkStat({
    required this.cowId,
    required this.tagNumber,
    required this.breed,
    required this.totalLitres,
  });

  factory CowMilkStat.fromApi(Map<String, dynamic> map) =>
      _$CowMilkStatFromJson(map);
  factory CowMilkStat.fromJson(Map<String, dynamic> json) =>
      _$CowMilkStatFromJson(json);

  Map<String, dynamic> toJson() => _$CowMilkStatToJson(this);
}

@JsonSerializable()
class CowExpenseStat {
  final String cowId;
  final String tagNumber;
  final String breed;
  @JsonKey(fromJson: _doubleFromJson)
  final double totalExpenses;

  const CowExpenseStat({
    required this.cowId,
    required this.tagNumber,
    required this.breed,
    required this.totalExpenses,
  });

  factory CowExpenseStat.fromApi(Map<String, dynamic> map) =>
      _$CowExpenseStatFromJson(map);
  factory CowExpenseStat.fromJson(Map<String, dynamic> json) =>
      _$CowExpenseStatFromJson(json);

  Map<String, dynamic> toJson() => _$CowExpenseStatToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DashboardSummary {
  final int totalActiveCows;
  final int pregnantCows;
  final int cowsInMilk;
  @JsonKey(fromJson: _doubleFromJson)
  final double todayTotalMilk;
  @JsonKey(fromJson: _doubleFromJson)
  final double monthlyMilkTotal;
  @JsonKey(fromJson: _doubleFromJson)
  final double monthlyExpenses;
  @JsonKey(fromJson: _doubleFromJson)
  final double monthlyMilkIncome;
  @JsonKey(fromJson: _doubleFromJson)
  final double profit;
  final List<CowMilkStat> milkPerCow;
  final List<CowExpenseStat> expensePerCow;

  const DashboardSummary({
    required this.totalActiveCows,
    required this.pregnantCows,
    required this.cowsInMilk,
    required this.todayTotalMilk,
    required this.monthlyMilkTotal,
    required this.monthlyExpenses,
    required this.monthlyMilkIncome,
    required this.profit,
    required this.milkPerCow,
    required this.expensePerCow,
  });

  const DashboardSummary.empty()
      : totalActiveCows = 0,
        pregnantCows = 0,
        cowsInMilk = 0,
        todayTotalMilk = 0,
        monthlyMilkTotal = 0,
        monthlyExpenses = 0,
        monthlyMilkIncome = 0,
        profit = 0,
        milkPerCow = const [],
        expensePerCow = const [];

  factory DashboardSummary.fromApi(Map<String, dynamic> map) =>
      _$DashboardSummaryFromJson(map);

  Map<String, dynamic> toJson() => _$DashboardSummaryToJson(this);
}
