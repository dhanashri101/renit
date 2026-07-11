import 'package:flutter/material.dart';
import 'package:rentit24/core/theme.dart';
import 'package:rentit24/pages/form/product_listing_form.dart';
import 'package:rentit24/pages/form/service_upload_form.dart';

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
            color: Color(0xFFE0E0E0), 
            width: 1,
          ),
        ),

        title: Text('Rent It', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF2D3748))),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),

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

              Expanded(
                flex:
                    7,
                child: Image.asset(
                  'assets/images/rentaproduct.png',
                  fit: BoxFit
                      .contain,
                ),
              ),
              const SizedBox(height: 16),
              PremiumGlowButton(
                text: 'Rent a Product',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductListingFlow()),
                  );
                },
              ),

              const Spacer(flex: 2),

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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ServiceUploadFlow()),
                  );
                },
              ),

              const Spacer(
                flex: 3,
              ), 
            ],
          ),
        ),
      ),
    );
  }
}


class PremiumGlowButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const PremiumGlowButton({super.key, required this.text, required this.onTap});

  @override
  State<PremiumGlowButton> createState() => _PremiumGlowButtonState();
}

class _PremiumGlowButtonState extends State<PremiumGlowButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.95);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
    widget.onTap();
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
          width: 280,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue ,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue .withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
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