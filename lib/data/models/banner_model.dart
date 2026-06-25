class BannerModel {
  final String id;
  final String imageUrl;
  final String linkUrl;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.linkUrl,
    this.isActive = true,
  });

  factory BannerModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return BannerModel(
      id: docId,
      imageUrl: json['imageUrl'] ?? '',
      linkUrl: json['linkUrl'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'isActive': isActive,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
