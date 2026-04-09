import 'package:get/get.dart';
import '../widgets/app_scaffold.dart';
import '../modules/auth/view/sign_in_view.dart';
import '../modules/auth/view/sign_up_view.dart';
import '../modules/cows/view/add_cow_view.dart';
import '../modules/cows/view/edit_cow_view.dart';
import '../modules/cow_profile/view/cow_profile_view.dart';
import '../modules/health/view/add_health_record_view.dart';
import '../modules/breeding/view/add_breeding_record_view.dart';
import '../modules/expenses/view/add_expense_view.dart';
import '../modules/sales/view/sales_view.dart';
import 'auth_middleware.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.main,
      page: () => const AppScaffold(),
      middlewares: [AuthRequiredMiddleware()],
    ),
    GetPage(
      name: AppRoutes.signIn,
      page: () => const SignInView(),
      middlewares: [GuestOnlyMiddleware()],
    ),
    GetPage(
      name: AppRoutes.signUp,
      page: () => const SignUpView(),
      middlewares: [GuestOnlyMiddleware()],
    ),
    GetPage(
      name: AppRoutes.addCow,
      page: () => const AddCowView(),
      middlewares: [AuthRequiredMiddleware()],
    ),
    GetPage(
      name: AppRoutes.editCow,
      page: () => const EditCowView(),
      middlewares: [AuthRequiredMiddleware()],
    ),
    GetPage(
      name: AppRoutes.cowProfile,
      page: () => const CowProfileView(),
      middlewares: [AuthRequiredMiddleware()],
    ),
    GetPage(
      name: AppRoutes.addHealthRecord,
      page: () => const AddHealthRecordView(),
      middlewares: [AuthRequiredMiddleware()],
    ),
    GetPage(
      name: AppRoutes.addBreedingRecord,
      page: () => const AddBreedingRecordView(),
      middlewares: [AuthRequiredMiddleware()],
    ),
    GetPage(
      name: AppRoutes.addExpense,
      page: () => const AddExpenseView(),
      middlewares: [AuthRequiredMiddleware()],
    ),
    GetPage(
      name: AppRoutes.addSale,
      page: () => const AddSaleView(),
      middlewares: [AuthRequiredMiddleware()],
    ),
  ];
}
