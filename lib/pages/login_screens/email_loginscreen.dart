import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rentit24/core/theme.dart';
import 'package:rentit24/pages/login_screens/create_account.dart';
import 'package:rentit24/pages/login_screens/forgot_password_screen.dart';
import 'package:rentit24/pages/login_screens/login_screen.dart';
import 'package:rentit24/shared/widgets/Social_icon_button.dart';
// import 'package:rentit24/core/theme.dart';

class emailLoginScreen extends StatefulWidget {
  const emailLoginScreen({Key? key}) : super(key: key);

  @override
  State<emailLoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<emailLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_onFocusChange);
    _passwordFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  void _validateForm() {
    setState(() {
      _isFormValid =
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF090726);
    final textSecondary = const Color(0xFF2F314D);

    // Theme colors mapped to your design
    final defaultBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final defaultBorderColor = isDark
        ? Colors.grey.shade800
        : Colors.grey.shade300;
    final focusedBgColor = const Color(0x19235BD6);
    final focusedBorderColor = const Color(0xFF235BD6);

    InputDecoration buildInputDecoration({
      required String hintText,
      required IconData prefixIcon,
      required bool isFocused,
      Widget? suffixIcon,
    }) {
      return InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
          fontFamily: 'Outfit',
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: isFocused ? focusedBorderColor : Colors.grey.shade400,
          size: 20,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isFocused ? focusedBgColor : defaultBgColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: defaultBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: defaultBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
                systemOverlayStyle: SystemUiOverlayStyle.dark,

        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Title
              Text(
                'Login to your Account',
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 32),

              // Email Field
              TextField(
                controller: _emailController,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (_) => _validateForm(),
                decoration: buildInputDecoration(
                  hintText: 'E-mail',
                  prefixIcon: Icons.mail_outline,
                  isFocused: _emailFocus.hasFocus,
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                obscureText: _obscurePassword,
                obscuringCharacter: '●',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w500,
                  letterSpacing:
                      _obscurePassword && _passwordController.text.isNotEmpty
                      ? 2
                      : 0,
                ),
                onChanged: (_) => _validateForm(),
                decoration: buildInputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  isFocused: _passwordFocus.hasFocus,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Remember Me Checkbox
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: focusedBorderColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Remember me',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isFormValid
                      ? () {
                          // TODO: Handle Login
                          print("Logging in with: ${_emailController.text}");
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: focusedBorderColor, // Primary blue
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: isDark
                        ? Colors.grey.shade800
                        : Colors.white,
                    disabledForegroundColor: Colors.grey.shade400,
                    elevation: _isFormValid ? 4 : 0,
                    shadowColor: focusedBorderColor.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: _isFormValid
                          ? BorderSide.none
                          : BorderSide(
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                            ),
                    ),
                  ),
                  child: const Text(
                    "Sign in",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Forgot Password
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: focusedBorderColor,
                      fontSize: 14,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor: focusedBorderColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.grey.shade300, thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'or continue with',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.grey.shade300, thickness: 1),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Social Icons Row (Interactive)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Phone
                  SocialIconButton(
                    icon: Icons.phone_android,
                    color: AppTheme.primaryBlue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PhoneLoginScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 16),

                  // Google
                  SocialIconButton(
                    icon: Icons.g_mobiledata,
                    color: Colors.red,
                    onTap: () {
                      print("Google Login");
                    },
                  ),

                  const SizedBox(width: 16),

                  // Facebook
                  SocialIconButton(
                    icon: Icons.facebook,
                    color: const Color(0xFF1877F2),
                    onTap: () {
                      print("Facebook Login");
                    },
                  ),

                  const SizedBox(width: 16),

                  // Apple
                  SocialIconButton(
                    icon: Icons.apple,
                    color: Colors.black,
                    onTap: () {
                      print("Apple Login");
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Footer Text
              Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Ready to join us? ',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      TextSpan(
                        text: 'Create an account!',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CreateAccountScreen(),
                              ),
                            );
                          },
                        style: TextStyle(
                          color: focusedBorderColor,
                          fontSize: 14,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: focusedBorderColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
