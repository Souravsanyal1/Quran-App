import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/banner_model.dart';

class BannerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _storage = GetStorage();
  
  final RxList<BannerModel> banners = <BannerModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt currentBannerIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  Future<void> fetchBanners() async {
    try {
      isLoading.value = true;
      
      // Load from cache first if exists
      final cachedData = _storage.read('banners');
      if (cachedData != null) {
        banners.assignAll((cachedData as List).map((e) => BannerModel.fromFirestore(Map<String, dynamic>.from(e), e['id'])).toList());
      }

      // Fetch from Firestore
      final snapshot = await _firestore
          .collection('banners')
          .where('isActive', isEqualTo: true)
          .get();

      final List<BannerModel> fetchedBanners = snapshot.docs
          .map((doc) => BannerModel.fromFirestore(doc.data(), doc.id))
          .toList();

      banners.assignAll(fetchedBanners);
      
      // Update cache
      final cacheList = fetchedBanners.map((e) {
        var map = e.toFirestore();
        map['id'] = e.id;
        return map;
      }).toList();
      _storage.write('banners', cacheList);

    } catch (e) {
      Get.log('Error fetching banners: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openLink(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar('Error', 'Could not launch $url');
    }
  }

  // Admin Methods
  Future<void> addBanner(String imageUrl, String linkUrl) async {
    try {
      await _firestore.collection('banners').add({
        'imageUrl': imageUrl,
        'linkUrl': linkUrl,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      fetchBanners();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add banner');
    }
  }

  Future<void> deleteBanner(String id) async {
    try {
      await _firestore.collection('banners').doc(id).delete();
      fetchBanners();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete banner');
    }
  }
}
