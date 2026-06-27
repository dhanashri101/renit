import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:rentit24/pages/login_screens/create_account.dart';
import 'package:rentit24/pages/login_screens/email_loginscreen.dart';
import 'package:rentit24/pages/login_screens/login_screen.dart';
import 'package:rentit24/wrapper/navbar.dart';
import 'package:rentit24/pages/login_screens/congratulationscreen.dart';

class MainLoginScreen extends StatefulWidget {
  const MainLoginScreen({super.key});

  @override
  State<MainLoginScreen> createState() => _MainLoginScreenState();
}

class _MainLoginScreenState extends State<MainLoginScreen> {
  bool _isLoading = false;

  // v7 singleton instance
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  GoogleSignInAccount? _googleUser;

@override
void initState() {
  super.initState();
  _initializeGoogleSignIn();
}

Future<void> _initializeGoogleSignIn() async {
  try {
    await _googleSignIn.initialize(
      serverClientId:
          '672213207103-93tuhrddf4dtkhh6k94fns48f9b165fo.apps.googleusercontent.com',
    );

    _googleSignIn.authenticationEvents.listen((event) {
      if (!mounted) return;

      setState(() {
        _googleUser = switch (event) {
          GoogleSignInAuthenticationEventSignIn() => event.user,
          _ => null,
        };
      });
    });

    await _googleSignIn.attemptLightweightAuthentication();
  } catch (e) {
    debugPrint("Google Sign-In initialization failed: $e");
  }
}
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      if (_googleSignIn.supportsAuthenticate()) {
        final GoogleSignInAccount account = await _googleSignIn.authenticate();

        final String? idToken = account.authentication.idToken;

        if (idToken != null) {
          print("Google Token Received: $idToken");
          _showSuccess("Google login successful! (Backend integration pending)");
        } else {
          _showError("Google Sign-In failed: could not retrieve ID token.");
        }
      } else {
        _showError("Google Sign-In is not supported on this platform.");
      }
    } on GoogleSignInException catch (e) {
      _showError("Google Sign-In failed: ${e.code.name} — ${e.description}");
    } catch (error) {
      _showError("Google Sign-In failed: $error");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithFacebook() async {
    setState(() => _isLoading = true);
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final String tokenString = accessToken.tokenString;
        print("Facebook Token Received: $tokenString");
        _showSuccess("Facebook login successful! (Backend integration pending)");
      } else if (result.status == LoginStatus.cancelled) {
        _showError("Facebook Sign-In cancelled.");
      } else {
        _showError("Facebook Sign-In failed: ${result.message}");
      }
    } catch (error) {
      _showError("Facebook Error: $error");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final String? identityToken = credential.identityToken;
      if (identityToken != null) {
        print("Apple Token Received: $identityToken");
        _showSuccess("Apple login successful! (Backend integration pending)");
      }
    } catch (error) {
      _showError("Apple Sign-In failed: $error");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NavigationWrapper(),
                          ),
                        );
                      },
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
                    onPressed: _signInWithFacebook,
                  ),
                  const SizedBox(height: 16),

                  _buildSocialButton(
                    context: context,
                    text: 'Continue with Google',
                    icon: Icons.g_mobiledata,
                    iconColor: Colors.red,
                    iconSize: 32,
                    onPressed: _signInWithGoogle,
                  ),
                  const SizedBox(height: 16),

                  _buildSocialButton(
                    context: context,
                    text: 'Continue with Apple',
                    icon: Icons.apple,
                    iconColor: isDark ? Colors.white : Colors.black,
                    onPressed: _signInWithApple,
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

            // Loading Overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

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
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: isDark ? Colors.white : const Color(0xFF1A1A2E),
          elevation: isDark ? 0 : 0.5,
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
