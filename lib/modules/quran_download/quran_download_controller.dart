import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../data/models/surah_model.dart';
import '../../data/repositories/quran_repository.dart';
import '../../data/providers/quran_api_provider.dart';
import '../../modules/settings/settings_controller.dart';

class QuranDownloadController extends GetxController {
  final QuranRepository _repository = Get.find<QuranRepository>();

  final RxBool isLoading = true.obs;
  final RxList<SurahModel> surahs = <SurahModel>[].obs;
  
  // Track download status: 0 = not downloaded, 1 = downloading, 2 = downloaded
  final RxMap<int, int> downloadStates = <int, int>{}.obs;
  final RxMap<int, double> downloadProgress = <int, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSurahList();
  }

  Future<void> _loadSurahList() async {
    isLoading.value = true;
    try {
      final list = await _repository.getSurahList();
      surahs.assignAll(list);
      await _checkCachedStatuses();
    } catch (e) {
      Get.log('Error loading download surah list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkCachedStatuses() async {
    final qariId = Get.find<SettingsController>().selectedQari.value;
    for (var surah in surahs) {
      final isCached = _repository.isSurahCached(surah.number);
      if (isCached) {
        final isAudioDownloaded = await _repository.isSurahAudioDownloaded(surah.number, qariId);
        downloadStates[surah.number] = isAudioDownloaded ? 2 : 0;
      } else {
        downloadStates[surah.number] = 0;
      }
    }
  }

  Future<void> downloadSurah(int surahNumber) async {
    if (kIsWeb) {
      Get.snackbar('Not Supported', 'Downloading is not supported on web.', 
        snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (downloadStates[surahNumber] == 2 || downloadStates[surahNumber] == 1) return;

    downloadStates[surahNumber] = 1; // Downloading
    downloadProgress[surahNumber] = 0.05;

    try {
      // 1. Download metadata text
      downloadProgress[surahNumber] = 0.10;
      final ayahs = await _repository.getSurahAyahs(surahNumber);
      
      if (ayahs.isEmpty) {
        throw Exception("Failed to fetch Ayahs for Surah $surahNumber");
      }

      // 2. Download audio files for each Ayah in the Surah
      final qariId = Get.find<SettingsController>().selectedQari.value;
      final totalAyahs = ayahs.length;
      int downloadedCount = 0;

      final dio = Dio(BaseOptions(
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      ));
      
      for (var ayah in ayahs) {
        final localPath = await _repository.getLocalAudioPath(ayah.number, qariId);
        final file = File(localPath);
        
        // Ensure parent directory exists
        await file.parent.create(recursive: true);

        if (!await file.exists() || await file.length() == 0) {
          final QuranApiProvider api = Get.find<QuranApiProvider>();
          final audioUrl = api.getAyahAudioUrl(ayah.number, qariId: qariId);
          try {
            if (await file.exists()) {
              await file.delete();
            }
            await dio.download(audioUrl, localPath);
          } catch (e) {
            if (await file.exists()) {
              await file.delete();
            }
            rethrow;
          }
        }
        
        downloadedCount++;
        // Progress goes from 0.10 to 1.0 based on downloaded count
        downloadProgress[surahNumber] = 0.10 + (0.90 * (downloadedCount / totalAyahs));
      }

      downloadStates[surahNumber] = 2; // Completed
    } catch (e) {
      downloadStates[surahNumber] = 0; // Failed
      Get.log('Download error: $e');
      Get.snackbar('Error', 'Failed to download Surah $surahNumber: $e', 
        snackPosition: SnackPosition.BOTTOM);
    } finally {
      downloadProgress.remove(surahNumber);
    }
  }

  Future<void> deleteDownloadedSurah(int surahNumber) async {
    if (kIsWeb) return;
    // Delete local files
    try {
      final qariId = Get.find<SettingsController>().selectedQari.value;
      final ayahs = await _repository.getSurahAyahs(surahNumber);
      for (var ayah in ayahs) {
        final localPath = await _repository.getLocalAudioPath(ayah.number, qariId);
        final file = File(localPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      downloadStates[surahNumber] = 0;
      Get.snackbar('Success', 'Deleted Surah $surahNumber audio files from device.',
        snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete Surah $surahNumber: $e',
        snackPosition: SnackPosition.BOTTOM);
    }
  }
}
