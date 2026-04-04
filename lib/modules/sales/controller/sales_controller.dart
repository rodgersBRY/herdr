import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../repository/sales_repository.dart';
import '../models/milk_sale.dart';

class SalesController extends GetxController {
  final SalesRepository _repo = SalesRepository();

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
      sales.value = await _repo.getAll();
    } finally {
      isLoading.value = false;
    }
  }

  double get totalAmount => sales.fold(0, (sum, s) => sum + s.totalAmount);
}

class AddSaleController extends GetxController {
  final SalesRepository _repo = SalesRepository();
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  final RxBool isSaving = false.obs;

  Future<void> save() async {
    if (!formKey.currentState!.saveAndValidate()) return;
    final values = formKey.currentState!.value;
    isSaving.value = true;
    try {
      final now = DateTime.now().toIso8601String();
      final sale = MilkSale(
        localId: '',
        saleDate: DateFormat('yyyy-MM-dd').format(values['sale_date'] as DateTime),
        litres: double.parse(values['litres'] as String),
        pricePerLitre: double.parse(values['price_per_litre'] as String),
        buyerName: values['buyer_name'] as String?,
        notes: values['notes'] as String?,
        createdAt: now,
      );
      await _repo.insert(sale);
      Get.back(result: true);
      Get.snackbar('Saved', 'Sale recorded',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF2E7D32),
          colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }
}
