// lib/providers/auth_provider.dart
import 'dart:convert'; // ADDED: Required for jsonEncode
import 'package:flutter/material.dart';
import 'package:rentit24/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  // final AuthRepository _authRepo = AuthRepository();
//   bool _isLoading = false;

//   bool get isLoading => _isLoading;

//   void _setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }

//   // --- SIGN UP ---
//   Future<bool> registerUser(String name, String email, String password) async {
//     _setLoading(true);
    
//     // 1. Create the actual data payload using the user's input
//     final Map<String, dynamic> rawData = {
//       "name": name,
//       "email": email,
//       "password": password
//     };

//     // 2. Convert it to a JSON string
//     String payload = jsonEncode(rawData); 
    
//     // Note: If your server strictly requires this to be encrypted (e.g., AES/RSA), 
//     // you will need to apply your encryption logic to 'payload' here before sending it.

//     final result = await _authRepo.sendAuthRequest(
//       endpoint: '/auth/getOTP', // Assuming this triggers the signup OTP
//       encryptedPayload: payload,
//       reqType: "REGISTER_INIT", 
//     );
    
//     // 3. Print the result so we can debug if it fails!
//     if (!result['success']) {
//       print("Registration Failed! Server said: ${result['message']}");
      
//     }

//     _setLoading(false);
//     return result['success'];
//   }

//   // --- OTP VERIFICATION ---
//   Future<bool> verifyOtp(String otpCode) async {
//     _setLoading(true);
    
//     // You will likely need to update this similarly to registerUser later!
//     // Example: String payload = jsonEncode({"otp": otpCode});
//     String payload = "encrypted_otp_data"; 
    
//     final result = await _authRepo.sendAuthRequest(
//       endpoint: '/auth/login', 
//       encryptedPayload: payload,
//       reqType: "VERIFY_OTP", 
//     );
    
//     _setLoading(false);
//     return result['success'];
//   }

//   // --- FORGOT PASSWORD ---
//   Future<bool> requestPasswordReset(String contactDetail) async {
//     _setLoading(true);
    
//     // You will likely need to update this similarly to registerUser later!
//     // Example: String payload = jsonEncode({"contact": contactDetail});
//     String payload = "encrypted_contact_data"; 
    
//     // final result = await _authRepo.sendAuthRequest(
//     //   endpoint: '/auth/getOTP',
//     //   encryptedPayload: payload,
//     //   reqType: "FORGOT_PASSWORD",
//     // );
    
//     _setLoading(false);
//     return result['success'];
//   }
}