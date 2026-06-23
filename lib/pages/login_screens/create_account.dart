import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rentit24/core/theme.dart';
import 'package:rentit24/pages/login_screens/congratulationscreen.dart';
import 'package:rentit24/pages/login_screens/login_screen.dart';
import 'package:rentit24/shared/widgets/Social_icon_button.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(_onFocusChange);
    _emailFocus.addListener(_onFocusChange);
    _passwordFocus.addListener(_onFocusChange);
    _confirmFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {}); 
  }

  void _validateForm() {
    setState(() {
      _isFormValid =
          _nameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : const Color(0xFF090726);
    final textSecondary = colorScheme.onSurface.withOpacity(0.7);

    final defaultBgColor = colorScheme.surface;
    final defaultBorderColor = isDark
        ? Colors.grey.shade800
        : Colors.grey.shade300;

    final focusedBorderColor = colorScheme.primary;
    final focusedBgColor = colorScheme.primary.withOpacity(0.1);

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
          color: focusedBorderColor, 
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
      appBar: AppBar(
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

              
              Text(
                'Create your Account',
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (_) => _validateForm(),
                decoration: buildInputDecoration(
                  hintText: 'Full name',
                  prefixIcon: Icons.person_outline,
                  isFocused: _nameFocus.hasFocus,
                ),
              ),
              const SizedBox(height: 16),

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

              TextField(
                controller: _confirmPasswordController,
                focusNode: _confirmFocus,
                obscureText: _obscureConfirmPassword,
                obscuringCharacter: '●',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w500,
                  letterSpacing:
                      _obscureConfirmPassword &&
                          _confirmPasswordController.text.isNotEmpty
                      ? 2
                      : 0,
                ),
                onChanged: (_) => _validateForm(),
                decoration: buildInputDecoration(
                  hintText: 'Re-type Password',
                  prefixIcon: Icons.lock_outline,
                  isFocused: _confirmFocus.hasFocus,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

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

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isFormValid
                      ? () {
                          print("Logging in with: ${_emailController.text}");

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CongratulationsScreen(),
                            ),
                          );
                        }
                      : null,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: focusedBorderColor,
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
                    "Sign up", 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 32),

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

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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

                  SocialIconButton(
                    icon: Icons.g_mobiledata,
                    color: Colors.red,
                    onTap: () {
                      print("Google Login");
                    },
                  ),

                  const SizedBox(width: 16),

                  SocialIconButton(
                    icon: Icons.facebook,
                    color: const Color(0xFF1877F2),
                    onTap: () {
                      print("Facebook Login");
                    },
                  ),

                  const SizedBox(width: 16),

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

              Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      TextSpan(
                        text: 'Sign in',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pop(context);
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
