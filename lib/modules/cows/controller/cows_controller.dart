import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repository/cow_repository.dart';
import '../models/cow.dart';

class CowsController extends GetxController {
  final CowRepository _repo = CowRepository();

  final RxBool isLoading = false.obs;
  final RxList<Cow> cows = <Cow>[].obs;
  final RxList<Cow> filtered = <Cow>[].obs;
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    loadCows();

    searchCtrl.addListener(_onSearch);
  }

  @override
  void onClose() {
    searchCtrl.removeListener(_onSearch);

    searchCtrl.dispose();

    super.onClose();
  }

  void _onSearch() {
    final q = searchCtrl.text.trim();

    if (q.isEmpty) {
      filtered.value = cows;
    } else {
      final ql = q.toLowerCase();

      filtered.value = cows
          .where((c) =>
              c.tag.toLowerCase().contains(ql) ||
              (c.name?.toLowerCase().contains(ql) ?? false))
          .toList();
    }
  }

  Future<void> loadCows() async {
    isLoading.value = true;

    try {
      cows.value = await _repo.getAll();
      
      _onSearch();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCow(String localId) async {
    await _repo.delete(localId);
    await loadCows();
  }
}
