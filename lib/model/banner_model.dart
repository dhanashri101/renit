import 'package:rentit24/config/api_config.dart';

class BannerModel {
  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.description = '',
    this.backgroundImageUrl = '',
    this.actionUrl = '',
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final String backgroundImageUrl;
  final String actionUrl;

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString().trim() ?? '',
      subtitle: json['subtitle']?.toString().trim() ?? '',
      description: json['description']?.toString().trim() ?? '',
      imageUrl: ApiConfig.resolveMediaUrl(json['image']?.toString()),
      backgroundImageUrl: ApiConfig.resolveMediaUrl(json['bg_image_url']?.toString()),
      actionUrl: json['bUrl']?.toString().trim() ?? '',
    );
  }
}
