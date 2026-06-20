import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rentit24/login_screens/create_account.dart';
import 'package:rentit24/login_screens/email_loginscreen.dart';
import 'package:rentit24/login_screens/login_screen.dart';

class MainLoginScreen extends StatelessWidget {
  const MainLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'SKIP FOR NOW',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // const SizedBox(height: 32),
              Container(
                height: 200,
                width: double.infinity,

                child: Center(child: Image.asset("assets/images/rocket.png")),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to Rent It 24',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 32),
              _buildSocialButton(
                context: context,
                text: 'Continue with Phone Number',
                icon: Icons.phone_android,
                iconColor: theme.primaryColor,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PhoneLoginScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildSocialButton(
                context: context,
                text: 'Continue with Facebook',
                icon: Icons.facebook,
                iconColor: const Color(0xFF1877F2),
                onPressed: () {},
              ),
              const SizedBox(height: 16),
              _buildSocialButton(
                context: context,
                text: 'Continue with Google',
                icon: Icons.g_mobiledata,
                iconColor: Colors.red,
                iconSize: 32,
                onPressed: () {},
              ),
              const SizedBox(height: 16),
              _buildSocialButton(
                context: context,
                text: 'Continue with Apple',
                icon: Icons.apple,
                iconColor: isDark ? Colors.white : Colors.black,
                onPressed: () {},
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: isDark ? Colors.white24 : const Color(0xFFD1D5DB),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: isDark ? Colors.white24 : const Color(0xFFD1D5DB),
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Sign in with password button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const emailLoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Sign in with password',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Footer text
              RichText(
                text: TextSpan(
                  text: 'Ready to join us? ',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: 'Create an account!',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateAccountScreen(),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method updated to adapt to Dark Mode using Theme.of(context)
  Widget _buildSocialButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onPressed,
    double iconSize = 22,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          // In Light Mode, it uses white. In Dark Mode, it utilizes your AppTheme.darkSurface
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: isDark
              ? Colors.white
              : const Color(0xFF1A1A2E), // Text color
          elevation: isDark ? 0 : 0.5, // Slight shadow in light mode if desired
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: isDark
                ? BorderSide.none
                : BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: iconSize),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
