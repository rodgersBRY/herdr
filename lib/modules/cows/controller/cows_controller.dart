import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/cow.dart';
import '../repository/cow_repository.dart';

class CowsController extends GetxController {
  final CowRepository _repo = CowRepository();

  final RxBool isLoading = false.obs;
  final RxList<Cow> cows = <Cow>[].obs;
  final RxList<Cow> filtered = <Cow>[].obs;
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    searchCtrl.addListener(_onSearch);
    loadCows();
  }

  @override
  void onClose() {
    searchCtrl.removeListener(_onSearch);
    searchCtrl.dispose();
    super.onClose();
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

  void _onSearch() {
    final query = searchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) {
      filtered.assignAll(cows);
      return;
    }

    filtered.assignAll(
      cows.where((cow) {
        return cow.tagNumber.toLowerCase().contains(query) ||
            cow.breed.toLowerCase().contains(query) ||
            cow.status.toLowerCase().contains(query) ||
            cow.source.toLowerCase().contains(query);
      }),
    );
  }
}
