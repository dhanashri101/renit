import 'package:rentit24/model/notification_model.dart';
import 'package:rentit24/services/api_services.dart';
import 'package:rentit24/services/session_service.dart';

class NotificationService {
  NotificationService({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<List<NotificationModel>> getMine({
    int? userId,
    int limit = 30,
    int offset = 0,
  }) async {
    final resolvedUserId = userId ?? await SessionService.getUserId();
    final data = await _api.get(
      '/notification/list',
      queryParameters: {
        'userId': resolvedUserId,
        'limit': limit,
        'offset': offset,
      },
    );
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => NotificationModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> markRead(int id) => _api.post('/notification/read/$id');

  Future<void> markAllRead({int? userId}) async {
    final resolvedUserId = userId ?? await SessionService.getUserId();
    await _api.post(
      '/notification/readAll',
      queryParameters: {'userId': resolvedUserId},
    );
  }
}
