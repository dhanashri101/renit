import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:rentit24/core/theme.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  final String phoneNumber;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isOtpFilled = false;
  Timer? _timer;
  int _remainingSeconds = 47;
  late final TapGestureRecognizer _resendRecognizer;

  @override
  void initState() {
    super.initState();
    // This screen must only be opened after a successful OTP request.
    _startTimer();
    _resendRecognizer = TapGestureRecognizer()..onTap = _onResendTap;
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 47;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  void _showContractBlocker(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$action is not sent because the backend has not documented the OTP req encoding, reqType values, and success/token response contract.',
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _onResendTap() {
    if (_remainingSeconds == 0) {
      _showContractBlocker('OTP resend');
    }
  }

  String get formattedTime {
    final int minutes = _remainingSeconds ~/ 60;
    final int seconds = _remainingSeconds % 60;
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final PinTheme defaultPinTheme = PinTheme(
      width: 40,
      height: 48,
      textStyle: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF090726),
        fontSize: 18,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w400,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
      ),
    );
    final PinTheme focusedPinTheme = defaultPinTheme.copyDecorationWith(
      color: const Color(0x19235BD6),
      border: Border.all(color: AppTheme.primaryBlue),
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              Text(
                'OTP Verification',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w700,
                  height: 1.21,
                ),
              ),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: 'Please enter the six-digit code sent to ',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF2F314D),
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF2F314D),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
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
                submittedPinTheme: focusedPinTheme,
                separatorBuilder: (int index) => const SizedBox(width: 20),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (String value) {
                  setState(() => _isOtpFilled = value.length == 6);
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isOtpFilled
                      ? () => _showContractBlocker('OTP verification')
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(height: 24),
              Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: 'Didn’t receive the OTP? ',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF2F314D),
                        fontSize: 14,
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
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
