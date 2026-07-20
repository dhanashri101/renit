import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:rentit24/core/theme.dart';
import 'package:rentit24/pages/login_screens/congratulationscreen.dart';
import 'package:rentit24/services/auth_service.dart';
import 'package:rentit24/services/session_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _pinController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isOtpFilled = false;

  Timer? _timer;
  int _remainingSeconds = 47;
  late TapGestureRecognizer _resendRecognizer;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _resendRecognizer = TapGestureRecognizer()..onTap = _onResendTap;
  }

  void _startTimer() {
    setState(() {
      _remainingSeconds = 47; 
    });

    _timer?.cancel(); 
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _onResendTap() async {
    if (_remainingSeconds != 0) return;
    final success = await _authService.requestLoginOtp(widget.phoneNumber);
    if (!mounted) return;
    if (success) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP requested again.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_authService.lastError ?? 'Unable to resend OTP.')),
      );
    }
  }

  Future<void> _continueInTestMode() async {
    await SessionService.setUserId(SessionService.defaultUserId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP verification is not enabled by the backend. Continuing with test user 11.'),
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CongratulationsScreen()),
    );
  }

  String get formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    _pinController.dispose();
    _resendRecognizer.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;


    final defaultPinTheme = PinTheme(
      width: 40,
      height: 48,
      textStyle: const TextStyle(
        color: Color(0xFF090726),
        fontSize:
            18, 
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w400,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkSurface
            : Colors.white, 
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.grey.shade800
              : Colors.grey.shade300, 
          width: 1,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      color: const Color(0x19235BD6), 
      border: Border.all(
        color: const Color(0xFF235BD6),
        width: 1,
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      color: const Color(0x19235BD6), 
      border: Border.all(
        color: const Color(0xFF235BD6), 
        width: 1,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              SizedBox(
                width: 328,
                child: const Text(
                  'OTP Verification',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF090726),
                    fontSize: 28,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                    height: 1.21,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: 328,
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text:
                            'Please enter the six-digit code we sent to your phone at ',
                        style: TextStyle(
                          color: Color(0xFF2F314D),
                          fontSize: 14,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                      TextSpan(
                        text: '${widget.phoneNumber} ',
                        style: const TextStyle(
                          color: Color(0xFF2F314D),
                          fontSize: 14,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                          height: 1.43,
                        ),
                      ),
                      const TextSpan(
                        text: 'Take your time!',
                        style: TextStyle(
                          color: Color(0xFF2F314D),
                          fontSize: 14,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _remainingSeconds > 0
                      ? AppTheme.primaryBlue 
                      : Colors.red,
                ),
              ),
              const SizedBox(height: 32),

              Pinput(
                length: 6,
                controller: _pinController,
                obscureText: true,
                obscuringCharacter: '●',
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                separatorBuilder: (index) => const SizedBox(width: 20),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {
                    _isOtpFilled = value.length == 6;
                  });
                },
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isOtpFilled ? _continueInTestMode : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue ,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: isDark
                        ? Colors.grey.shade800
                        : Colors.white,
                    disabledForegroundColor: isDark
                        ? Colors.grey.shade500
                        : Colors.grey.shade400,
                    elevation: _isOtpFilled ? 2 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: _isOtpFilled
                          ? BorderSide.none
                          : BorderSide(
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                            ),
                    ),
                  ),
                  child: const Text(
                    "Continue in Test Mode",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: 360,
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Didn’t receive the OTP? ',
                        style: TextStyle(
                          color: Color(0xFF2F314D),
                          fontSize: 14,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                      TextSpan(
                        text: 'RESEND',
                        recognizer: _resendRecognizer,
                        style: TextStyle(
                          color: _remainingSeconds == 0
                              ? const Color(0xFF4A7CE0)
                              : Colors.grey,
                          fontSize: 14,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                          decorationColor: _remainingSeconds == 0
                              ? const Color(0xFF4A7CE0)
                              : Colors.grey,
                          height: 1.43,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
