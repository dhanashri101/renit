import 'dart:convert';

import 'package:rentit24/services/api_exception.dart';
import 'package:rentit24/services/api_services.dart';
import 'package:rentit24/services/session_service.dart';

class AuthService {
  AuthService({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;
  String? lastError;

  Future<bool> requestLoginOtp(String mobile) async {
    lastError = null;
    try {
      final inner = jsonEncode({'mobile': _normalizeMobile(mobile)});
      final request = jsonEncode({'responseType': 0, 'req': inner});
      await _api.post(
        '/auth/getloginOTP',
        data: {'req': request, 'reqType': 'json'},
      );
      return true;
    } on ApiException catch (error) {
      lastError = error.userMessage;
      return false;
    }
  }

  Future<bool> requestSignupOtp(String mobile) async {
    lastError =
        'Account creation and signup OTP verification are not available from the backend yet.';
    return false;
  }

  /// Email/password authentication is not included in the backend contract.
  Future<bool> loginWithEmail(String email, String password) async {
    lastError =
        'Email login is not available from the backend yet. Please use the phone OTP test flow.';
    return false;
  }

  String _normalizeMobile(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    // The backend contract currently documents a 10-digit mobile value.
    return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
  }

  Future<void> logout() => SessionService.clear();
}
