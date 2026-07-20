import 'package:rentit24/model/review_model.dart';
import 'package:rentit24/services/api_services.dart';
import 'package:rentit24/services/session_service.dart';

class ReviewService {
  ReviewService({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<List<ReviewModel>> getReviews(
    int listingId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await _api.get(
      '/review/$listingId',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => ReviewModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> addReview({
    required int listingId,
    required double rating,
    required String comment,
    int? reviewerId,
  }) async {
    final userId = reviewerId ?? await SessionService.getUserId();
    await _api.post(
      '/review/add',
      data: {
        'listingId': listingId,
        'reviewerId': userId,
        'rating': rating,
        'comment': comment,
      },
    );
  }
}
