import 'dart:convert';

import 'package:rentit24/model/listing_model.dart';
import 'package:rentit24/services/api_services.dart';
import 'package:rentit24/services/session_service.dart';

class DashboardService {
  DashboardService({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<List<ListingModel>> getTopProfessionals({int limit = 10}) async {
    final data = await _api.get(
      '/dashboard/topProfessionals',
      queryParameters: {'limit': limit},
    );
    return _listings(data);
  }

  Future<List<ListingModel>> getFreshRecommendations({int limit = 10}) async {
    final data = await _api.get(
      '/dashboard/freshRecommendations',
      queryParameters: {'limit': limit},
    );
    return _listings(data);
  }

  Future<List<ListingModel>> getRecentlyUploaded({
    int limit = 10,
    int offset = 0,
  }) async {
    final data = await _api.get(
      '/dashboard/recentlyUploaded',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return _listings(data);
  }

  Future<Map<String, dynamic>> bootstrap({String appVersion = '1.0.0'}) async {
    final data = await _api.post(
      '/dashboard/splashScreen',
      data: {
        'req': jsonEncode({
          'deviceId': '',
          'email': '',
          'mobile': '',
          'appVersion': appVersion,
        }),
        'reqType': 'json',
      },
    );
    return data is Map ? Map<String, dynamic>.from(data) : const {};
  }

  Future<List<ListingModel>> getLegacyWishlist() async {
    final userId = await SessionService.getUserId();
    final data = await _api.post(
      '/dashboard/getWishList',
      data: {'req': jsonEncode({'userId': userId}), 'reqType': 'json'},
    );
    return _listings(data);
  }

  List<ListingModel> _listings(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => ListingModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
