import 'package:rentit24/config/api_config.dart';

class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerPhoto,
    this.reviewedAt,
  });

  final int id;
  final double rating;
  final String comment;
  final int reviewerId;
  final String reviewerName;
  final String reviewerPhoto;
  final DateTime? reviewedAt;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;
    double toDouble(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

    return ReviewModel(
      id: toInt(json['id']),
      rating: toDouble(json['rating']),
      comment: (json['comment'] ?? '').toString().trim(),
      reviewerId: toInt(json['reviewer_id'] ?? json['reviewerId']),
      reviewerName: (json['reviewer_name'] ?? json['reviewerName'] ?? '').toString().trim(),
      reviewerPhoto: ApiConfig.resolveMediaUrl(
        (json['reviewer_photo'] ?? json['reviewerPhoto'])?.toString(),
      ),
      reviewedAt: DateTime.tryParse((json['reviewed_at'] ?? json['reviewedAt'] ?? '').toString()),
    );
  }
}
