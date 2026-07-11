// lib/services/auth_services.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'https://rentit24.com'; 
  final Dio _dio = Dio();

  Future<bool> loginWithEmail(String email, String password) async {
    try {
final response = await _dio.post(
  '$baseUrl/auth/login',
  data: {
    "email": email,
    "password": password,
  },
);

print("Status Code: ${response.statusCode}");
print("Response Data: ${response.data}");

      if (response.statusCode == 200 && response.data['token'] != null) {
        final String token = response.data['token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Login Error: ${e.response?.data}');
      return false;
    } catch (e) {
      print('Unexpected Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}