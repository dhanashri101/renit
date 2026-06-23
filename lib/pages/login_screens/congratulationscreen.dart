import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

class CongratulationsScreen extends StatelessWidget {
  const CongratulationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final textColor = colorScheme.onSurface;
    final textSecondary = colorScheme.onSurface.withOpacity(0.7);

    final primaryBlue = colorScheme.primary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 289,
                  height: 289,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(),
                  child: Image.asset(
                    'assets/images/congratulation.png',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 48),

              
                Text(
                  'Congratulations!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 28,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  "Let's explore how we can meet your needs!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40), 

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: primaryBlue.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Get Started",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}