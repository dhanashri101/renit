import 'package:flutter/material.dart';
import 'package:rentit24/core/theme.dart';

class RentItScreen extends StatefulWidget {
  const RentItScreen({super.key});

  @override
  State<RentItScreen> createState() => _RentItScreenState();
}

class _RentItScreenState extends State<RentItScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark
            ? AppTheme.darkBackground
            : AppTheme.lightBackground,
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(
            color: Color(0xFFE0E0E0), // Border color
            width: 1,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Rent It', style: TextStyle(color: Colors.black)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),

              // Subtitle
              Text(
                'Earn money\nby renting something you have!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  color: isDark
                      ? Colors.white.withOpacity(0.8)
                      : const Color(0xFF2D3748),
                ),
              ),

              const Spacer(flex: 2),

              // First Section: Rent a Product
              Expanded(
                flex:
                    7, // Allocates a dynamic chunk of the screen for the image
                child: Image.asset(
                  'assets/images/rentaproduct.png',
                  fit: BoxFit
                      .contain, // Ensures the image never overflows its boundaries
                ),
              ),
              const SizedBox(height: 16),
              PremiumGlowButton(
                text: 'Rent a Product',
                onPressed: () {
                  // Handle rent product
                },
              ),

              const Spacer(flex: 2),

              // Divider "or"
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: isDark ? Colors.white24 : Colors.black12,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'or',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black38,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: isDark ? Colors.white24 : Colors.black12,
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // Second Section: Give a Professional Service
              Expanded(
                flex: 7,
                child: Image.asset(
                  'assets/images/give_service.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              PremiumGlowButton(
                text: 'Give a Professional Service',
                onPressed: () {
                  // Handle professional service
                },
              ),

              const Spacer(
                flex: 3,
              ), // Pushes everything up slightly so it doesn't hug the very bottom
            ],
          ),
        ),
      ),
    );
  }
}

// --- PREMIUM CUSTOM BUTTON ---

class PremiumGlowButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const PremiumGlowButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<PremiumGlowButton> createState() => _PremiumGlowButtonState();
}

class _PremiumGlowButtonState extends State<PremiumGlowButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.95);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
    widget.onPressed();
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          width: 280, // Stays consistent horizontally
          height: 52, // Standard touch target height
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
