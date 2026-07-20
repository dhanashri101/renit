import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:rentit24/core/theme.dart';
import 'package:rentit24/pages/login_screens/email_loginscreen.dart';
import 'package:rentit24/pages/login_screens/otp_verificationscreen.dart';
import 'package:rentit24/services/auth_service.dart';
import 'package:rentit24/shared/widgets/Social_icon_button.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isPhoneFilled = false;
  bool _isSendingOtp = false;
  String selectedCode = '+91';
  String selectedFlag = '🇮🇳';
  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() {
        _isPhoneFilled = _phoneController.text.length >= 10;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    if (_isSendingOtp) return;
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final mobile = '$selectedCode$digits';
    setState(() => _isSendingOtp = true);
    final success = await _authService.requestLoginOtp(mobile);
    if (!mounted) return;
    setState(() => _isSendingOtp = false);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_authService.lastError ?? 'Unable to request OTP.')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(phoneNumber: mobile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: 328,
                child: Text(
                  'Enter your phone    number',
                  style: TextStyle(
                    color: const Color(0xFF090726),
                    fontSize: 28,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                    height: 1.21,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: 328,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "We'll send you a ",
                        style: TextStyle(
                          color: const Color(0xFF2F314D) /* text-secondary */,
                          fontSize: 14,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                      TextSpan(
                        text: 'One Time Password (OTP)',
                        style: TextStyle(
                          color: const Color(0xFF2F314D) /* text-secondary */,
                          fontSize: 14,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                          height: 1.43,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' to this mobile number. Thank you for your patience!',
                        style: TextStyle(
                          color: const Color(0xFF2F314D) /* text-secondary */,
                          fontSize: 14,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Container(
                    width: 90,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: CountryCodePicker(
                      initialSelection: 'IN',
                      padding: EdgeInsets.zero,
                      onChanged: (country) {
                        setState(() {
                          selectedCode = country.dialCode ?? '+91';
                        });
                      },
                      builder: (countryCode) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: Image.asset(
                                countryCode?.flagUri ?? '',
                                package: 'country_code_picker',
                                width: 25,
                                height: 18,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppTheme.primaryBlue ,
                              size: 22,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),

                          prefixText: '$selectedCode ',
                          prefixStyle: const TextStyle(
                            color: Color(0xFFB0B3C1),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),

                          hintText: '(000) 000 0000',
                          hintStyle: const TextStyle(
                            color: Color(0xFFB0B3C1),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isPhoneFilled && !_isSendingOtp ? _requestOtp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    disabledBackgroundColor: isDark
                        ? const Color(0xFF3A3A3C)
                        : Colors.grey.shade100,
                    disabledForegroundColor: isDark
                        ? Colors.white38
                        : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isSendingOtp
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text(
                    'Get OTP',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(height: 150),
              SizedBox(
                width: 328,
                child: Text(
                  "Log in with your phone number to receive a six-digit verification code via SMS. Ensure the number is correct for security. If you don't receive the code, request a new one. Your number is used solely for authentication and remains private.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0x66090726) /* disabled-main */,
                    fontSize: 10,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w400,
                    height: 1.20,
                    letterSpacing: 0.20,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Text(
                      'or continue with',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialIconButton(
                    icon: Icons.mail_outline,
                    color: isDark ? Colors.white : Colors.black87,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const emailLoginScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 16),

                  SocialIconButton(
                    icon: Icons.g_mobiledata,
                    color: Colors.redAccent,
                    size: 32,
                    onTap: () {
                      print("Google login");
                    },
                  ),

                  const SizedBox(width: 16),

                  SocialIconButton(
                    icon: Icons.facebook,
                    color: const Color(0xFF1877F2),
                    onTap: () {
                      print("Facebook login");
                    },
                  ),

                  const SizedBox(width: 16),

                  SocialIconButton(
                    icon: Icons.apple,
                    color: isDark ? Colors.white : Colors.black,
                    onTap: () {
                      print("Apple login");
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: 328,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          color: const Color(0x66090726),
                          fontSize: 12,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w400,
                          height: 1.42,
                        ),
                      ),
                      TextSpan(
                        text: 'Sign in',
                        style: TextStyle(
                          color: const Color(0xFF4A7CE0),
                          fontSize: 12,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFF4A7CE0),
                          height: 1.42,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
