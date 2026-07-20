import 'dart:convert';

import 'package:rentit24/model/user_profile_model.dart';
import 'package:rentit24/services/api_exception.dart';
import 'package:rentit24/services/api_services.dart';
import 'package:rentit24/services/session_service.dart';

class UserProfileService {
  UserProfileService({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<UserProfileModel> getProfile({int? userId}) async {
    final id = userId ?? await SessionService.getUserId();
    final data = await _api.post(
      '/user/userProfile',
      data: {
        'req': jsonEncode({'userId': id}),
        'reqType': 'json',
      },
    );
    if (data is! Map) {
      throw const ApiException(
        type: ApiErrorType.contract,
        message: 'User profile response is invalid.',
      );
    }
    return UserProfileModel.fromJson(Map<String, dynamic>.from(data));
  }
}
