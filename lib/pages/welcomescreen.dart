import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:rentit24/pages/homescreen.dart';
import 'package:rentit24/wrapper/navbar.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:rentit24/core/theme.dart';
import 'package:rentit24/pages/login_screens/create_account.dart';
import 'package:rentit24/pages/login_screens/email_loginscreen.dart';
import 'package:rentit24/pages/login_screens/login_screen.dart';

class MainLoginScreen extends StatefulWidget {
  const MainLoginScreen({super.key});

  @override
  State<MainLoginScreen> createState() => _MainLoginScreenState();
}

class _MainLoginScreenState extends State<MainLoginScreen> {
  bool _isLoading = false;

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
      debugPrint('Google Sign-In initialization failed: $e');
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      if (_googleSignIn.supportsAuthenticate()) {
        final GoogleSignInAccount account = await _googleSignIn.authenticate();
        final String? idToken = account.authentication.idToken;

        if (idToken != null) {
          _showBackendPending('Google identity was received, but the RentIt24 backend social-session exchange endpoint is not documented.');
        } else {
          _showError('Google Sign-In failed: could not retrieve ID token.');
        }
      } else {
        _showError('Google Sign-In is not supported on this platform.');
      }
    } on GoogleSignInException catch (e) {
      _showError('Google Sign-In failed: ${e.code.name} — ${e.description}');
    } catch (error) {
      _showError('Google Sign-In failed: $error');
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
        if (accessToken.tokenString.isEmpty) {
          _showError('Facebook Sign-In did not return a usable access token.');
          return;
        }
        _showBackendPending(
          'Facebook identity was received, but the RentIt24 backend social-session exchange endpoint is not documented.',
        );
      } else if (result.status == LoginStatus.cancelled) {
        _showError('Facebook Sign-In cancelled.');
      } else {
        _showError('Facebook Sign-In failed: ${result.message}');
      }
    } catch (error) {
      _showError('Facebook Error: $error');
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
        _showBackendPending(
          'Apple identity was received, but the RentIt24 backend social-session exchange endpoint is not documented.',
        );
      } else {
        _showError('Apple Sign-In did not return an identity token.');
      }
    } catch (error) {
      _showError('Apple Sign-In failed: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showBackendPending(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white12 : AppColors.neutral100;
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final horizontalPadding = isTablet ? 36.0 : 22.0;
    final heroHeight = isTablet ? 280.0 : 220.0;
    final titleStyle = AppTypography.h2Style(
      isDark ? AppColors.baseWhite : AppColors.neutral900,
    ).copyWith(
      fontSize: isTablet ? 30 : 28,
      letterSpacing: -0.6,
      height: 1.1,
    );
    final bodyStyle = AppTypography.bodyMedium(
      AppTypography.regular,
      isDark ? AppColors.neutral300 : AppColors.neutral600,
    ).copyWith(fontSize: isTablet ? 15 : 14, height: 1.5);
    final maxWidth = isTablet ? 460.0 : 390.0;
    final buttonHeight = isTablet ? 58.0 : 54.0;
    final buttonRadius = isTablet ? 20.0 : 16.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        const NavigationWrapper(),
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
                                style: AppTypography.bodyExtraSmall(
                                  AppTypography.semibold,
                                  isDark ? AppColors.neutral200 : AppColors.neutral500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: heroHeight,
                            width: double.infinity,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: heroHeight * 0.74,
                                  height: heroHeight * 0.74,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.primaryColor.withOpacity(0.16),
                                        theme.primaryColor.withOpacity(0.02),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  child: Image.asset(
                                    'assets/images/rocket.png',
                                    height: heroHeight * 0.7,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Welcome to Rent It 24',
                            textAlign: TextAlign.center,
                            style: titleStyle,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Discover rentals, connect with trusted hosts, and move faster with a seamless experience.',
                            textAlign: TextAlign.center,
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 28),
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
                            buttonHeight: buttonHeight,
                            radius: buttonRadius,
                          ),
                          const SizedBox(height: 12),
                          _buildSocialButton(
                            context: context,
                            text: 'Continue with Facebook',
                            icon: Icons.facebook,
                            iconColor: const Color(0xFF1877F2),
                            onPressed: _signInWithFacebook,
                            buttonHeight: buttonHeight,
                            radius: buttonRadius,
                          ),
                          const SizedBox(height: 12),
                          _buildSocialButton(
                            context: context,
                            text: 'Continue with Google',
                            icon: Icons.g_mobiledata,
                            iconColor: Colors.red,
                            iconSize: isTablet ? 32 : 28,
                            onPressed: _signInWithGoogle,
                            buttonHeight: buttonHeight,
                            radius: buttonRadius,
                          ),
                          const SizedBox(height: 12),
                          _buildSocialButton(
                            context: context,
                            text: 'Continue with Apple',
                            icon: Icons.apple,
                            iconColor: isDark ? AppColors.baseWhite : AppColors.neutral900,
                            onPressed: _signInWithApple,
                            buttonHeight: buttonHeight,
                            radius: buttonRadius,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: borderColor,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  'or',
                                  style: AppTypography.bodySmall(
                                    AppTypography.medium,
                                    isDark ? AppColors.neutral400 : AppColors.neutral500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: borderColor,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            height: buttonHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(buttonRadius + 8),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.18),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
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
                                foregroundColor: AppColors.baseWhite,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(buttonRadius + 8),
                                ),
                              ),
                              child: Text(
                                'Sign in with password',
                                style: AppTypography.bodyMedium(
                                  AppTypography.semibold,
                                  AppColors.baseWhite,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: 'Ready to join us? ',
                              style: AppTypography.bodySmall(
                                AppTypography.regular,
                                isDark ? AppColors.neutral400 : AppColors.neutral500,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Create an account!',
                                  style: AppTypography.bodySmall(
                                    AppTypography.semibold,
                                    theme.primaryColor,
                                  ).copyWith(decoration: TextDecoration.underline),
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
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.35),
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
    double buttonHeight = 54,
    double radius = 16,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? theme.colorScheme.surface : AppColors.baseWhite,
          foregroundColor: isDark ? AppColors.baseWhite : AppColors.neutral900,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(
              color: isDark ? Colors.white12 : AppColors.neutral100,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: iconSize),
            const SizedBox(width: 12),
            Text(
              text,
              style: AppTypography.bodyMedium(
                AppTypography.semibold,
                isDark ? AppColors.baseWhite : AppColors.neutral900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
