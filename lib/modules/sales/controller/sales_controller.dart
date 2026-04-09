import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/network/network_status_service.dart';
import '../models/milk_sale.dart';
import '../repository/sales_repository.dart';

class SalesController extends GetxController {
  final SalesRepository _repository = SalesRepository();

  final RxBool isLoading = false.obs;
  final RxList<MilkSale> sales = <MilkSale>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSales();
  }

  Future<void> loadSales() async {
    isLoading.value = true;
    try {
      sales.assignAll(await _repository.getAll());
    } finally {
      isLoading.value = false;
    }
  }

  double get totalAmount =>
      sales.fold(0, (sum, sale) => sum + sale.totalAmount);
}

class AddSaleController extends GetxController {
  final SalesRepository _repository = SalesRepository();
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  final RxBool isSaving = false.obs;

  Future<void> save() async {
    if (!formKey.currentState!.saveAndValidate()) {
      return;
    }

    final values = formKey.currentState!.value;
    isSaving.value = true;

    try {
      final litres = double.parse(values['litresSold'] as String);
      final price = double.parse(values['pricePerLitre'] as String);
      final now = DateTime.now().toIso8601String();

      final sale = MilkSale(
        saleDate: DateFormat(
          'yyyy-MM-dd',
        ).format(values['saleDate'] as DateTime),
        litresSold: litres,
        pricePerLitre: price,
        totalAmount: litres * price,
        buyer: values['buyer'] as String?,
        notes: values['notes'] as String?,
        createdAt: now,
        updatedAt: now,
      );

      await _repository.insert(sale);
      final online = Get.find<NetworkStatusService>().isOnline.value;

      Get.back(result: true);
      Get.snackbar(
        'Sale recorded',
        online
            ? 'The milk sale was synced.'
            : 'The milk sale was saved offline and queued.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
