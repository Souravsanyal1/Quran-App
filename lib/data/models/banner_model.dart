import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String id;
  final String imageUrl;
  final String linkUrl;
  final bool isActive;
  final DateTime? expiresAt;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.linkUrl,
    this.isActive = true,
    this.expiresAt,
  });

  factory BannerModel.fromFirestore(Map<String, dynamic> json, String docId) {
    DateTime? expiry;
    if (json['expiresAt'] != null) {
      if (json['expiresAt'] is Timestamp) {
        expiry = (json['expiresAt'] as Timestamp).toDate();
      } else if (json['expiresAt'] is String) {
        expiry = DateTime.tryParse(json['expiresAt']);
      }
    }

    return BannerModel(
      id: docId,
      imageUrl: json['imageUrl'] ?? '',
      linkUrl: json['linkUrl'] ?? '',
      isActive: json['isActive'] ?? true,
      expiresAt: expiry,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'isActive': isActive,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
