import 'package:intl/intl.dart';

class AppFormatters {
  static final DateFormat _apiDate = DateFormat('yyyy-MM-dd');
  static final DateFormat _prettyDate = DateFormat('dd MMM yyyy');
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_KE',
    symbol: 'KES ',
    decimalDigits: 0,
  );

  static String todayApi() => _apiDate.format(DateTime.now());

  static String monthApi([DateTime? date]) =>
      DateFormat('yyyy-MM').format(date ?? DateTime.now());

  static String prettyDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Not set';
    }

    try {
      return _prettyDate.format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }

  static String monthLabel([DateTime? date]) =>
      DateFormat('MMMM yyyy').format(date ?? DateTime.now());

  static String money(num value) => _currency.format(value);

  static double asDouble(dynamic value) {
    if (value == null) {
      return 0;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString()) ?? 0;
  }
}
