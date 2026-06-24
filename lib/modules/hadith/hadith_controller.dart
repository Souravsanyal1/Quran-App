import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/hadith_model.dart';
import '../../data/repositories/hadith_repository.dart';

class HadithController extends GetxController {
  final HadithRepository _repository = Get.find<HadithRepository>();

  final RxBool isLoadingBooks = true.obs;
  final RxBool isLoadingHadiths = false.obs;
  final RxList<HadithBook> books = <HadithBook>[].obs;
  final RxList<Hadith> hadiths = <Hadith>[].obs;
  final Rxn<HadithBook> selectedBook = Rxn<HadithBook>();

  final scrollController = ScrollController();
  int currentRangeStart = 1;
  final int rangeStep = 50;

  @override
  void onInit() {
    super.onInit();
    loadBooks();
    scrollController.addListener(_scrollListener);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (!isLoadingHadiths.value && selectedBook.value != null) {
        loadMoreHadiths();
      }
    }
  }

  Future<void> loadBooks() async {
    isLoadingBooks.value = true;
    try {
      final result = await _repository.getBooks();
      books.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load Hadith books');
    } finally {
      isLoadingBooks.value = false;
    }
  }

  Future<void> selectBook(HadithBook book) async {
    selectedBook.value = book;
    hadiths.clear();
    currentRangeStart = 1;
    loadHadiths();
  }

  Future<void> loadHadiths() async {
    if (selectedBook.value == null) return;
    isLoadingHadiths.value = true;
    try {
      final result = await _repository.getHadiths(
        selectedBook.value!.id,
        start: currentRangeStart,
        end: currentRangeStart + rangeStep - 1,
      );
      hadiths.addAll(result);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load Hadiths');
    } finally {
      isLoadingHadiths.value = false;
    }
  }

  Future<void> loadMoreHadiths() async {
    if (selectedBook.value == null) return;
    if (hadiths.length >= selectedBook.value!.available) return;

    currentRangeStart += rangeStep;
    loadHadiths();
  }
}
