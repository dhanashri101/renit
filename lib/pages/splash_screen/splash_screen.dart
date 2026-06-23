import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rentit24/pages/on_boarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // ── Phase 1 (0.00 → 0.40): Each card pops in with a bounce, staggered ──
  // ── Phase 2 (0.40 → 0.45): Brief pause — all cards visible ─────────────
  // ── Phase 3 (0.45 → 0.80): Cards spiral into center & disappear ─────────
  // ── Phase 4 (0.65 → 1.00): Logo bounces in, text fades in ───────────────

  late Animation<double> _spiralProgress;
  late Animation<double> _cardFadeOut;
  late Animation<double> _cardShrink;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;

  final List<String> _imagePaths = [
    'assets/images/categories/agriculture-farming.png',
    'assets/images/categories/appliances.png',
    'assets/images/categories/baby-kids.png',
    'assets/images/categories/beauty-grooming.png',
    'assets/images/categories/books-stationery.png',
    'assets/images/categories/community-ngo.png',
    'assets/images/categories/construction-heavy-machinery.png',
    'assets/images/categories/coworking-business.png',
    'assets/images/categories/delivery-logistics.png',
    'assets/images/categories/digital-tech-services.png',
    'assets/images/categories/education.png',
    'assets/images/categories/electronics.png',
    'assets/images/categories/event-professionals.png',
    'assets/images/categories/events-parties.png',
    'assets/images/categories/fashion-dress.png',
    'assets/images/categories/fashion-services.png',
    'assets/images/categories/festivals-celebrations.png',
    'assets/images/categories/food-catering.png',
    'assets/images/categories/furniture.png',
    'assets/images/categories/gaming-consoles.png',
    'assets/images/categories/gardening-outdoor.png',
    'assets/images/categories/health-wellness.png',
    'assets/images/categories/household-items.png',
    'assets/images/categories/medical-equipment.png',
    'assets/images/categories/miscellaneous.png',
    'assets/images/categories/musical-instruments.png',
    'assets/images/categories/office-work-equipment.png',
    'assets/images/categories/pets-animals.png',
    'assets/images/categories/professional-services.png',
    'assets/images/categories/real-estate.png',
    'assets/images/categories/security-services.png',
    'assets/images/categories/sesonal-needs.png',
    'assets/images/categories/sports-fitness.png',
    'assets/images/categories/tools-machinery.png',
    'assets/images/categories/transportation-services.png',
    'assets/images/categories/travel-hospitality.png',
    'assets/images/categories/travel-outdoors.png',
    'assets/images/categories/vehicles.png',
    'assets/images/categories/wedding-photography.png',
  ];

  late List<Offset> _cardPositions; // normalised -1..1 from center
  late List<double> _cardRotations;
  late List<double> _spiralDirs;
  late List<double> _popDelays; // staggered pop-in delay per card (0..1 within phase 1)

  @override
  void initState() {
    super.initState();

    final random = Random(42);
    final count = _imagePaths.length;

    _cardPositions = List.generate(count, (_) {
      final x = (random.nextDouble() - 0.5) * 1.8;
      final y = (random.nextDouble() - 0.5) * 1.8;
      return Offset(x, y);
    });

    _cardRotations = List.generate(count, (_) {
      return (random.nextDouble() - 0.5) * 0.7;
    });

    _spiralDirs = List.generate(count, (i) => i.isEven ? 1.0 : -1.0);

    // Each card gets a stagger delay spread evenly across [0..0.7] of phase 1
    _popDelays = List.generate(count, (i) => i / count * 0.7);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    // Phase 3: spiral progress 0→1
    _spiralProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.80, curve: Curves.easeInCubic),
    );

    // Cards fade out during spiral
    _cardFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.52, 0.80, curve: Curves.easeIn),
      ),
    );

    // Cards shrink during spiral
    _cardShrink = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.58, 0.80, curve: Curves.easeIn),
      ),
    );

    // Logo pops in while cards are spiralling
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.75, curve: Curves.easeIn),
      ),
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.92, curve: Curves.elasticOut),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.78, 0.92, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Returns 0→1 pop-in scale for a card given its stagger delay.
  /// Phase 1 runs from controller time 0.0 → 0.40.
  /// Each card's pop starts at its delay and lasts 0.25 of the total phase.
  double _popScale(int index) {
    const phaseStart = 0.00;
    const phaseEnd = 0.40;
    final phaseLen = phaseEnd - phaseStart;

    final cardStart = phaseStart + _popDelays[index] * phaseLen;
    final cardEnd = cardStart + 0.20; // each card's pop takes 20% of total

    final t = _controller.value;
    if (t <= cardStart) return 0.0;
    if (t >= cardEnd) return 1.0;

    // Normalise to 0..1 within this card's window
    final localT = (t - cardStart) / (cardEnd - cardStart);

    // Elastic-out style: overshoot then settle
    // Simple approximation: sine ease with slight overshoot
    final bounced = sin(localT * pi * 0.5) * 1.15;
    return bounced.clamp(0.0, 1.15); // allow slight overshoot above 1
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2355D6),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final halfW = w / 2;
          final halfH = h / 2;
          const cardSize = 54.0;
          const halfCard = cardSize / 2;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final spiral = _spiralProgress.value; // 0→1 during spiral phase

              return Stack(
                children: [
                  // ── Cards ─────────────────────────────────────────────────
                  ...List.generate(_imagePaths.length, (i) {
                    // --- Pop-in scale (phase 1) ---
                    final popS = _popScale(i);

                    // --- Spiral position (phase 3) ---
                    final startX = _cardPositions[i].dx * halfW;
                    final startY = _cardPositions[i].dy * halfH;
                    final dist = sqrt(startX * startX + startY * startY);
                    final startAngle = atan2(startY, startX);
                    final radius = dist * (1.0 - spiral);
                    final angle = startAngle + _spiralDirs[i] * spiral * 1.3;
                    final currentX = cos(angle) * radius;
                    final currentY = sin(angle) * radius;

                    // Card rotation: initial tilt, straightens as it spirals
                    final cardRotation = _cardRotations[i] * (1.0 - spiral);

                    // Combined scale: pop-in × shrink-out
                    final scale = (popS * _cardShrink.value).clamp(0.0, 1.15);

                    return Positioned(
                      left: halfW + currentX - halfCard,
                      top: halfH + currentY - halfCard,
                      child: Opacity(
                        opacity: (popS * _cardFadeOut.value).clamp(0.0, 1.0),
                        child: Transform.rotate(
                          angle: cardRotation,
                          child: Transform.scale(
                            scale: scale,
                            child: Container(
                              width: cardSize,
                              height: cardSize,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  _imagePaths[i],
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  // ── Logo + text ────────────────────────────────────────────
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: _logoOpacity.value.clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: _logoScale.value.clamp(0.0, 1.2),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/rentitlogo.png',
                                width: 90,
                              ),
                              const SizedBox(height: 10),
                              Opacity(
                                opacity: _textOpacity.value.clamp(0.0, 1.0),
                                child: const Text(
                                  'Rentit 24',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}