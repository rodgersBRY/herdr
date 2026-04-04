import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import '../controller/sales_controller.dart';
import '../../../config/app_theme.dart';
import '../../../routes/app_routes.dart';

class SalesView extends StatelessWidget {
  const SalesView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesController>(
      init: SalesController(),
      builder: (ctrl) => Scaffold(
        appBar: AppBar(title: const Text('Milk Sales')),
        body: Obx(() {
          if (ctrl.isLoading.value) return const Center(child: CircularProgressIndicator());
          return Column(
            children: [
              Container(
                color: AppTheme.primary.withAlpha(20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Income', style: TextStyle(fontWeight: FontWeight.w600)),
                    Obx(() => Text('KES ${ctrl.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 18))),
                  ],
                ),
              ),
              Expanded(
                child: ctrl.sales.isEmpty
                    ? const Center(child: Text('No sales recorded yet', style: TextStyle(color: AppTheme.textSecondary)))
                    : RefreshIndicator(
                        onRefresh: ctrl.loadSales,
                        child: ListView.separated(
                          itemCount: ctrl.sales.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final s = ctrl.sales[i];
                            return ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFE8F5E9),
                                child: Icon(Icons.sell, color: AppTheme.primary),
                              ),
                              title: Text('${s.litres} L @ KES ${s.pricePerLitre}/L',
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(s.saleDate + (s.buyerName != null ? ' · ${s.buyerName}' : '')),
                              trailing: Text('KES ${s.totalAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Get.toNamed(AppRoutes.addSale);
            ctrl.loadSales();
          },
          backgroundColor: AppTheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
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
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: ctrl.formKey,
          child: Column(
            children: [
              FormBuilderDateTimePicker(
                name: 'sale_date',
                inputType: InputType.date,
                decoration: const InputDecoration(labelText: 'Sale Date *'),
                initialValue: DateTime.now(),
                lastDate: DateTime.now(),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'litres',
                decoration: const InputDecoration(labelText: 'Litres *', suffixText: 'L'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                  FormBuilderValidators.min(0.1),
                ]),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'price_per_litre',
                decoration: const InputDecoration(labelText: 'Price per Litre (KES) *', prefixText: 'KES '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                  FormBuilderValidators.min(0.1),
                ]),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'buyer_name',
                decoration: const InputDecoration(labelText: 'Buyer Name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'notes',
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Obx(() => ElevatedButton(
                    onPressed: ctrl.isSaving.value ? null : ctrl.save,
                    child: ctrl.isSaving.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Sale'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
