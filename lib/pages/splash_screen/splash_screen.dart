import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rentit24/pages/on_boarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Category icons animations
  late final Animation<double> _scatterProgress;
  late final Animation<double> _iconsFadeIn;
  late final Animation<double> _collapseProgress;
  late final Animation<double> _iconsFadeOut;

  // Logo animations
  late final Animation<double> _logoScale;
  late final Animation<double> _logoRotation;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<double> _textSlideUp;

  static const List<String> _iconAssets = [
    'assets/images/categories/appliances.png',
    'assets/images/categories/gaming-consoles.png',
    'assets/images/categories/beauty-grooming.png',
    'assets/images/categories/musical-instruments.png',
    'assets/images/categories/pets-animals.png',
    'assets/images/categories/baby-kids.png',
    'assets/images/categories/events-parties.png',
    'assets/images/categories/household-items.png',
    'assets/images/categories/event-professionals.png',
    'assets/images/categories/professional-services.png',
    'assets/images/categories/real-estate.png',
    'assets/images/categories/fashion-dress.png',
    'assets/images/categories/miscellaneous.png',
    'assets/images/categories/festivals-celebrations.png',
    'assets/images/categories/fashion-services.png',
    'assets/images/categories/gardening-outdoor.png',
    'assets/images/categories/sesonal-needs.png',
    'assets/images/categories/medical-equipment.png',
  ];

  static const List<Alignment> _scatteredPositions = [
    Alignment(0.62, 0.28),
    Alignment(-0.12, -0.84),
    Alignment(0.72, -0.76),
    Alignment(-0.68, -0.55),
    Alignment(-0.08, -0.58),
    Alignment(0.62, -0.48),
    Alignment(-0.72, -0.25),
    Alignment(0.62, 0.88),
    Alignment(-0.75, 0.32),
    Alignment(-0.18, 0.12),
    Alignment(0.72, -0.02),
    Alignment(-0.35, 0.88),
    Alignment(0.72, 0.58),
    Alignment(-0.02, 0.62),
    Alignment(0.78, -0.25),
    Alignment(-0.75, -0.82),
    Alignment(-0.02, -0.25),
    Alignment(-0.68, 0.65),
  ];

  static const List<double> _targetRotations = [
    -0.35,
    0.35,
    0.26,
    -0.26,
    0.26,
    0.43,
    0.35,
    0.35,
    -0.35,
    0.26,
    -0.43,
    -0.43,
    0.43,
    0.35,
    -0.26,
    0.26,
    -0.35,
    -0.26,
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    // Icons move from center to scattered positions.
    _scatterProgress = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.52,
          curve: ElasticOutCurve(0.55),
        ),
      ),
    );

    // Icons appear.
    _iconsFadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.14,
          curve: Curves.easeIn,
        ),
      ),
    );

    // Icons return to the center.
    _collapseProgress = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.52,
          0.70,
          curve: Curves.easeInQuint,
        ),
      ),
    );

    // Icons disappear after collapsing.
    _iconsFadeOut = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.66,
          0.72,
          curve: Curves.easeOut,
        ),
      ),
    );

    // Logo starts small and grows.
    _logoScale = Tween<double>(
      begin: 0.25,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.67,
          0.88,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    // Logo starts below and moves upward to the center.
   
    // Logo performs two complete clockwise rotations.
    _logoRotation = Tween<double>(
      begin: 0.0,
      end: 4 * pi,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.66,
          0.88,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // Logo fades in.
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.66,
          0.73,
          curve: Curves.easeIn,
        ),
      ),
    );

    // Text fades in after the logo reaches the center.
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.82,
          0.94,
          curve: Curves.easeIn,
        ),
      ),
    );

    // Text also moves slightly upward.
    _textSlideUp = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.82,
          0.94,
          curve: Curves.easeOut,
        ),
      ),
    );

    _controller.forward().then((_) {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (
            context,
            animation,
            secondaryAnimation,
          ) {
            return const OnboardingScreen();
          },
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );

            return AnimatedBuilder(
              animation: curvedAnimation,
              builder: (context, _) {
                return ClipPath(
                  clipper: CircularRevealClipper(
                    curvedAnimation.value,
                  ),
                  child: child,
                );
              },
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2355D6),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final iconsVisible = _iconsFadeOut.value > 0.0;

          return Stack(
            alignment: Alignment.center,
            children: [
              if (iconsVisible) ..._buildIcons(),

              Center(
                child: _buildLogoSection(),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildIcons() {
    final scatter = _scatterProgress.value;
    final collapse = _collapseProgress.value;
    final fadeIn = _iconsFadeIn.value;
    final fadeOut = _iconsFadeOut.value;

    return List.generate(_iconAssets.length, (index) {
      final finalPosition = _scatteredPositions[index];

      Alignment currentPosition;

      if (collapse == 0.0) {
        currentPosition = Alignment.lerp(
          Alignment.center,
          finalPosition,
          scatter,
        )!;
      } else {
        currentPosition = Alignment.lerp(
          finalPosition,
          Alignment.center,
          collapse,
        )!;
      }

      double currentRotation = _targetRotations[index] * scatter;

      if (scatter < 1.0 && _controller.value < 0.3) {
        currentRotation +=
            (1 - scatter) * pi * (index.isEven ? 1 : -1);
      }

      if (collapse > 0.0) {
        currentRotation +=
            collapse * 2 * pi * (index.isEven ? -1 : 1);
      }

      return Align(
        alignment: currentPosition,
        child: Opacity(
          opacity: (fadeIn * fadeOut).clamp(0.0, 1.0),
          child: Transform.rotate(
            angle: currentRotation,
            child: _IconCard(
              path: _iconAssets[index],
            ),
          ),
        ),
      );
    });
  }

 Widget _buildLogoSection() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: 120,
        height: 120,
        child: Opacity(
          opacity: _logoOpacity.value,
          child: Transform.scale(
            scale: _logoScale.value,
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: _logoRotation.value,
              alignment: Alignment.center,
              child: Image.asset(
                'assets/images/rentitlogo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Opacity(
        opacity: _textOpacity.value,
        child: Transform.translate(
          offset: Offset(0, _textSlideUp.value),
          child: const Text(
            'Rentit 24',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    ],
  );
}
}

class _IconCard extends StatelessWidget {
  const _IconCard({
    required this.path,
  });

  final String path;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Image.asset(
          path,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class CircularRevealClipper extends CustomClipper<Path> {
  const CircularRevealClipper(this.fraction);

  final double fraction;

  @override
  Path getClip(Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final maxRadius = sqrt(
      pow(size.width / 2, 2) +
          pow(size.height / 2, 2),
    );

    return Path()
      ..addOval(
        Rect.fromCircle(
          center: center,
          radius: maxRadius * fraction,
        ),
      );
  }

  @override
  bool shouldReclip(
    covariant CircularRevealClipper oldClipper,
  ) {
    return oldClipper.fraction != fraction;
  }
}