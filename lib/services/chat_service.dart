import 'package:rentit24/model/chat_model.dart';
import 'package:rentit24/services/api_services.dart';
import 'package:rentit24/services/session_service.dart';

class ChatService {
  ChatService({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<int> startChat(int listingId, {int? renterId}) async {
    final userId = renterId ?? await SessionService.getUserId();
    final data = await _api.post(
      '/chat/start',
      queryParameters: {'listingId': listingId, 'renterId': userId},
    );
    if (data is Map) {
      final value = data['chatId'];
      return value is num ? value.toInt() : int.tryParse('$value') ?? 0;
    }
    return 0;
  }

  Future<List<ChatThreadModel>> getChats({
    int? userId,
    String tab = 'all',
    int limit = 20,
    int offset = 0,
  }) async {
    final resolvedUserId = userId ?? await SessionService.getUserId();
    final data = await _api.get(
      '/chat/list',
      queryParameters: {
        'userId': resolvedUserId,
        'tab': tab,
        'limit': limit,
        'offset': offset,
      },
    );
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => ChatThreadModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<ChatMessageModel>> getMessages(
    int chatId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final data = await _api.get(
      '/chat/$chatId/messages',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => ChatMessageModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<int> sendMessage(
    int chatId,
    String message, {
    int? senderId,
  }) async {
    final userId = senderId ?? await SessionService.getUserId();
    final data = await _api.post(
      '/chat/$chatId/send',
      data: {'senderId': userId, 'message': message.trim()},
    );
    if (data is Map) {
      final value = data['messageId'];
      return value is num ? value.toInt() : int.tryParse('$value') ?? 0;
    }
    return 0;
  }

  Future<void> markRead(int chatId, {int? userId}) async {
    final resolvedUserId = userId ?? await SessionService.getUserId();
    await _api.post(
      '/chat/$chatId/read',
      queryParameters: {'userId': resolvedUserId},
    );
  }
}
