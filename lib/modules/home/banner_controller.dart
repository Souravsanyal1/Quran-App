import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/banner_model.dart';

class BannerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _storage = GetStorage();
  
  final RxList<BannerModel> banners = <BannerModel>[].obs;
  final RxList<BannerModel> staticTopBanners = <BannerModel>[].obs;
  final RxList<Map<String, dynamic>> campaignAds = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt currentBannerIndex = 0.obs;
  final RxInt currentAdIndex = 0.obs;
  Timer? _adTimer;

  @override
  void onInit() {
    super.onInit();
    _initBannerStream();
    _initStaticBannerStream();
    _initCampaignAdsStream();
  }

  @override
  void onClose() {
    _adTimer?.cancel();
    super.onClose();
  }

  void _initCampaignAdsStream() {
    // Simplified listener to avoid index requirements
    _firestore.collection('custom_ads')
        .snapshots().listen((snapshot) {
      final List<Map<String, dynamic>> ads = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .where((ad) => ad['status'] == 'active')
          .toList();
          
      // Manual sorting by createdAt if needed
      ads.sort((a, b) {
        final tA = (a['createdAt'] as Timestamp?) ?? Timestamp.now();
        final tB = (b['createdAt'] as Timestamp?) ?? Timestamp.now();
        return tB.compareTo(tA);
      });

      campaignAds.assignAll(ads);
      _startAdTimer();
    });
  }

  void _startAdTimer() {
    _adTimer?.cancel();
    if (campaignAds.length > 1) {
      _adTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        currentAdIndex.value = (currentAdIndex.value + 1) % campaignAds.length;
      });
    }
  }

  void _initBannerStream() {
    // 1. Instant Cache Load
    final cachedData = _storage.read('banners');
    if (cachedData != null) {
      banners.assignAll((cachedData as List).map((e) => BannerModel.fromFirestore(Map<String, dynamic>.from(e), e['id'] ?? '')).toList());
      isLoading.value = false;
    }

    // 2. Ultra-Reliable Firestore Listener (No complex queries to avoid indexing issues)
    _firestore.collection('banners').snapshots().listen((snapshot) {
      debugPrint('[BannerController] Banners update received. Total docs: ${snapshot.docs.length}');
      
      final List<BannerModel> fetchedBanners = snapshot.docs.map((doc) {
        final data = doc.data();
        // Ensure linkUrl exists even if it was saved as targetUrl
        final String image = data['imageUrl'] ?? '';
        final String link = data['linkUrl'] ?? data['targetUrl'] ?? '';
        
        return BannerModel(
          id: doc.id,
          imageUrl: image,
          linkUrl: link,
          isActive: true,
        );
      }).where((b) => b.imageUrl.isNotEmpty).toList();

      banners.assignAll(fetchedBanners);
      isLoading.value = false;

      // Update local storage
      final cacheList = fetchedBanners.map((e) => {
        'id': e.id,
        'imageUrl': e.imageUrl,
        'linkUrl': e.linkUrl,
      }).toList();
      _storage.write('banners', cacheList);
    }, onError: (e) => debugPrint('[BannerController] Error: $e'));
  }

  void _initStaticBannerStream() {
    _firestore.collection('static_top_banners').snapshots().listen((snapshot) {
      staticTopBanners.assignAll(snapshot.docs.map((doc) {
        final data = doc.data();
        return BannerModel(
          id: doc.id,
          imageUrl: data['imageUrl'] ?? '',
          linkUrl: data['linkUrl'] ?? data['targetUrl'] ?? '',
          isActive: true,
        );
      }).where((b) => b.imageUrl.isNotEmpty).toList());
    });
  }

  Future<void> openLink(String url) async {
    if (url.isEmpty) return;
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  // Admin Methods (Standardized)
  Future<void> addBanner(String imageUrl, String linkUrl, String title) async {
    await _firestore.collection('banners').add({
      'title': title,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addStaticTopBanner(String imageUrl, String linkUrl, String title) async {
    await _firestore.collection('static_top_banners').add({
      'title': title,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addCustomAd(String title, String imageUrl, String targetUrl) async {
    try {
      await _firestore.collection('custom_ads').add({
        'title': title,
        'imageUrl': imageUrl,
        'targetUrl': targetUrl,
        'status': 'active',
        'type': 'banner',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding custom ad: $e');
    }
  }

  Future<void> deleteBanner(String id) async => _firestore.collection('banners').doc(id).delete();
  Future<void> deleteStaticBanner(String id) async => _firestore.collection('static_top_banners').doc(id).delete();
}
