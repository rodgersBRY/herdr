import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';

import '../../../config/app_theme.dart';
import '../../../core/ui/app_loading_dots.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../routes/app_routes.dart';
import '../controller/sales_controller.dart';

class SalesView extends StatelessWidget {
  const SalesView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesController>(
      init: SalesController(),
      builder:
          (ctrl) => Scaffold(
            appBar: AppBar(
              title: const Text('Milk Sales'),
              actions: [
                IconButton(
                  onPressed: ctrl.loadSales,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              heroTag: 'sales_add_fab',
              onPressed: () async {
                await Get.toNamed(AppRoutes.addSale);
                await ctrl.loadSales();
              },
              child: const Icon(Icons.add),
            ),
            body: Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(
                  child: AppLoadingDots(
                    color: AppTheme.primary,
                    dotSize: 10,
                    gap: 6,
                  ),
                );
              }

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B3417), Color(0xFFAB6B2E)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sales total',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppFormatters.money(ctrl.totalAmount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        ctrl.sales.isEmpty
                            ? const Center(
                              child: Text('No milk sales recorded yet.'),
                            )
                            : RefreshIndicator(
                              onRefresh: ctrl.loadSales,
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                itemCount: ctrl.sales.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(height: 10),
                                itemBuilder: (_, index) {
                                  final sale = ctrl.sales[index];
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Row(
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor: Color(0xFFFDEAD9),
                                          child: Icon(
                                            Icons.sell,
                                            color: Color(0xFFAB6B2E),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${sale.litresSold.toStringAsFixed(1)} L @ ${AppFormatters.money(sale.pricePerLitre)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${AppFormatters.prettyDate(sale.saleDate)}${sale.buyer != null && sale.buyer!.isNotEmpty ? ' • ${sale.buyer}' : ''}',
                                                style: const TextStyle(
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          AppFormatters.money(sale.totalAmount),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                  ),
                ],
              );
            }),
          ),
    );
  }
}

class AddSaleView extends StatelessWidget {
  const AddSaleView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AddSaleController());

    return Scaffold(
      appBar: AppBar(title: const Text('Record Sale')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FormBuilder(
          key: ctrl.formKey,
          child: Column(
            children: [
              FormBuilderDateTimePicker(
                name: 'saleDate',
                inputType: InputType.date,
                decoration: const InputDecoration(labelText: 'Sale date'),
                initialValue: DateTime.now(),
                lastDate: DateTime.now(),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'litresSold',
                decoration: const InputDecoration(
                  labelText: 'Litres sold',
                  suffixText: 'L',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                  FormBuilderValidators.min(0.1),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'pricePerLitre',
                decoration: const InputDecoration(
                  labelText: 'Price per litre',
                  prefixText: 'KES ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                  FormBuilderValidators.min(0.1),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'buyer',
                decoration: const InputDecoration(labelText: 'Buyer'),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'notes',
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 28),
              Obx(
                () => ElevatedButton(
                  onPressed: ctrl.isSaving.value ? null : ctrl.save,
                  child:
                      ctrl.isSaving.value
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Center(
                              child: AppLoadingDots(dotSize: 4.5, gap: 2.5),
                            ),
                          )
                          : const Text('Save Sale'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
