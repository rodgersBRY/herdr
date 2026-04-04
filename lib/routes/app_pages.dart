import 'package:get/get.dart';
import '../widgets/app_scaffold.dart';
import '../modules/cows/view/add_cow_view.dart';
import '../modules/cow_profile/view/cow_profile_view.dart';
import '../modules/health/view/add_health_record_view.dart';
import '../modules/breeding/view/add_breeding_record_view.dart';
import '../modules/expenses/view/add_expense_view.dart';
import '../modules/sales/view/sales_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.main, page: () => const AppScaffold()),
    GetPage(name: AppRoutes.addCow, page: () => const AddCowView()),
    GetPage(name: AppRoutes.cowProfile, page: () => const CowProfileView()),
    GetPage(
      name: AppRoutes.addHealthRecord,
      page: () => const AddHealthRecordView(),
    ),
    GetPage(
      name: AppRoutes.addBreedingRecord,
      page: () => const AddBreedingRecordView(),
    ),
    GetPage(name: AppRoutes.addExpense, page: () => const AddExpenseView()),
    GetPage(name: AppRoutes.addSale, page: () => const AddSaleView()),
  ];
}
