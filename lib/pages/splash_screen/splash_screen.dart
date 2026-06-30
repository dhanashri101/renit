import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rentit24/pages/on_boarding_screen.dart';

/// SplashScreen – matches the recorded video sequence exactly.
///
/// Timeline (total controller duration = 3 800 ms):
///
///  Phase 1  [0.00 → 0.13]  Blue screen – icons hidden (brief pause).
///  Phase 2  [0.13 → 0.40]  Icons fade in AND scatter outward from centre
///                           to their final scattered positions.
///  Phase 3  [0.40 → 0.72]  Icons idle at their scattered positions with a
///                           gentle floating bob + slow continuous spin.
///  Phase 4  [0.72 → 0.85]  Icons fly inward back to centre while scaling
///                           down and fading out (vortex collapse).
///                           Simultaneously the logo fades in.
///  Phase 5  [0.82 → 1.00]  Logo bounces with elasticOut spring; text fades in.
///
/// Navigation fires 600 ms after the controller completes.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // ── Phase 2: scatter outward ─────────────────────────────────────────────
  late final Animation<double> _scatterProgress; // 0→1: centre → final pos
  late final Animation<double> _iconsFadeIn;     // 0→1: icons appear

  // ── Phase 3: idle float (driven by a continuous sine over controller time)
  // No extra animation needed – computed directly from _controller.value in build.

  // ── Phase 4: vortex collapse ─────────────────────────────────────────────
  late final Animation<double> _collapseProgress; // 0→1: final pos → centre
  late final Animation<double> _iconsCollapse;    // 1→0: scale + opacity

  // ── Phase 5: logo + text ─────────────────────────────────────────────────
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _textOpacity;

  // ── Assets ───────────────────────────────────────────────────────────────
  static const List<String> _iconAssets = [
    'assets/images/categories/appliances.png',
    'assets/images/categories/baby-kids.png',
    'assets/images/categories/beauty-grooming.png',
    'assets/images/categories/event-professionals.png',
    'assets/images/categories/events-parties.png',
    'assets/images/categories/fashion-dress.png',
    'assets/images/categories/fashion-services.png',
    'assets/images/categories/festivals-celebrations.png',
    'assets/images/categories/gaming-consoles.png',
    'assets/images/categories/gardening-outdoor.png',
    'assets/images/categories/household-items.png',
    'assets/images/categories/medical-equipment.png',
    'assets/images/categories/miscellaneous.png',
    'assets/images/categories/pets-animals.png',
    'assets/images/categories/professional-services.png',
    'assets/images/categories/real-estate.png',
    'assets/images/categories/sesonal-needs.png',
    'assets/images/categories/musical-instruments.png',
  ];

  // Final scattered positions across the full screen (matching video layout).
  // These are the positions icons settle into after scattering.
  static const List<Alignment> _scatteredPositions = [
    Alignment(-0.75, -0.82), // appliances        – top-left
    Alignment(-0.20, -0.82), // baby-kids         – top-centre-left
    Alignment( 0.72, -0.82), // beauty            – top-right
    Alignment(-0.72, -0.50), // event-prof        – mid-upper left
    Alignment( 0.55, -0.50), // events-parties    – mid-upper right
    Alignment(-0.65, -0.18), // fashion-dress     – mid left
    Alignment(-0.10, -0.18), // fashion-services  – mid centre-left
    Alignment( 0.55, -0.18), // festivals         – mid right
    Alignment(-0.72,  0.12), // gaming            – mid-lower left
    Alignment( 0.10,  0.12), // gardening         – mid centre
    Alignment( 0.65,  0.12), // household         – mid-lower right
    Alignment(-0.55,  0.42), // medical           – lower left
    Alignment( 0.05,  0.42), // misc              – lower centre
    Alignment( 0.65,  0.42), // pets              – lower right
    Alignment(-0.72,  0.72), // professional      – bottom left
    Alignment( 0.10,  0.72), // real-estate       – bottom centre
    Alignment(-0.20,  0.90), // seasonal          – bottom-lower left
    Alignment( 0.65,  0.72), // musical           – bottom right
  ];

  // Per-icon rotation at the scattered (idle) position (radians).
  static const List<double> _idleRotations = [
    -0.10,  0.05, -0.15,  0.20, -0.05,
     0.25, -0.20,  0.10,  0.15, -0.25,
     0.05,  0.20, -0.10,  0.15, -0.30,
     0.10,  0.20, -0.05,
  ];

  // Idle float offsets (Alignment delta, gives each icon a unique bob).
  static const List<Offset> _floatAmplitudes = [
    Offset(0.02,  0.025), Offset(-0.015, 0.020), Offset(0.025, -0.020),
    Offset(-0.020, 0.030), Offset(0.030, -0.015), Offset(-0.025, 0.020),
    Offset(0.020,  0.030), Offset(-0.030, 0.015), Offset(0.015,  0.025),
    Offset(-0.020, -0.030), Offset(0.025, 0.020), Offset(-0.015, 0.025),
    Offset(0.030, -0.020), Offset(-0.025, 0.015), Offset(0.020, -0.025),
    Offset(-0.030, 0.020), Offset(0.015,  0.030), Offset(-0.020, -0.025),
  ];

  // Phase offsets so icons don't all float in sync.
  static const List<double> _floatPhases = [
    0.0, 0.7, 1.4, 2.1, 2.8, 3.5, 4.2, 4.9, 5.6,
    0.3, 1.0, 1.7, 2.4, 3.1, 3.8, 4.5, 5.2, 5.9,
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );

    // Phase 2 – scatter: icons fan outward from Alignment.center → _scatteredPositions
    _scatterProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.13, 0.40, curve: Curves.easeOutCubic),
      ),
    );

    // Icons fade in as they scatter
    _iconsFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.13, 0.28, curve: Curves.easeIn),
      ),
    );

    // Phase 4 – collapse: icons fly from scattered positions → Alignment.center
    _collapseProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.72, 0.88, curve: Curves.easeInCubic),
      ),
    );

    // Icons scale down and fade out during collapse
    _iconsCollapse = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.72, 0.90, curve: Curves.easeIn),
      ),
    );

    // Phase 5 – logo fade in (starts while icons are still collapsing)
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.78, 0.90, curve: Curves.easeIn),
      ),
    );

    // Logo elastic bounce
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.82, 1.00, curve: Curves.elasticOut),
      ),
    );

    // Text fades in after logo
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.88, 1.00, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      });
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
          final t = _controller.value; // 0.0 → 1.0

          // Determine visibility windows
          final iconsVisible = t >= 0.13 && _iconsCollapse.value > 0.0;

          return Stack(
            alignment: Alignment.center,
            children: [
              if (iconsVisible) ..._buildIcons(t),

Center(
  child: _buildLogoSection(),
)            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildIcons(double t) {
    final scatter   = _scatterProgress.value;
    final collapse  = _collapseProgress.value;
    final fadeIn    = _iconsFadeIn.value;
    final iconAlpha = (_iconsCollapse.value * fadeIn).clamp(0.0, 1.0);

    // Idle float: active during Phase 3 (scatter done, collapse not started)
    // We use a 0→1 weight so the bob smoothly fades in/out.
    final idleWeight = ((t - 0.40) / 0.32).clamp(0.0, 1.0) *
                       (1.0 - ((t - 0.72) / 0.10).clamp(0.0, 1.0));

    // Wall-clock seconds drives the sine wave (independent of controller speed)
    final sineT = t * 3.8; // ≈ real seconds at 3800ms

    return List.generate(_iconAssets.length, (i) {
      final scattered = _scatteredPositions[i];

      // ── Position ───────────────────────────────────────────────────────
      // Scatter: centre → scattered (Phase 2)
      // Idle float: small sine displacement (Phase 3)
      // Collapse: scattered → centre (Phase 4)
      Alignment pos = Alignment.lerp(Alignment.center, scattered, scatter)!;

      // Apply idle float
      if (idleWeight > 0.0) {
        final amp = _floatAmplitudes[i];
        final phase = _floatPhases[i];
        final dx = amp.dx * sin(sineT * 1.8 + phase);
        final dy = amp.dy * cos(sineT * 1.4 + phase);
        pos = Alignment(
          pos.x + dx * idleWeight,
          pos.y + dy * idleWeight,
        );
      }

      // Collapse overrides: lerp from scattered back to centre
      if (collapse > 0.0) {
        pos = Alignment.lerp(scattered, Alignment.center, collapse)!;
      }

      // ── Rotation ───────────────────────────────────────────────────────
      // During scatter: ramp up to idle angle
      // During idle:    slow continuous drift
      // During collapse: spin inward
      double rotation = _idleRotations[i] * scatter;
      if (idleWeight > 0.0) {
        rotation += sineT * 0.15 * (i.isEven ? 1 : -1) * idleWeight;
      }
      if (collapse > 0.0) {
        // Add a spin during collapse (2 full turns)
        rotation += collapse * 2 * pi * (i.isEven ? 1 : -1);
      }

      return Align(
        alignment: pos,
        child: Opacity(
          opacity: iconAlpha,
          child: Transform.scale(
            scale: _iconsCollapse.value.clamp(0.0, 1.0),
            child: Transform.rotate(
              angle: rotation,
              child: _IconCard(path: _iconAssets[i]),
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
        Opacity(
          opacity: _logoOpacity.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: _logoScale.value,
            child: Image.asset(
              'assets/images/rentitlogo.png',
              width: 120,
            ),
          ),
        ),
        // SizedBox and Text only occupy layout space once the text is visible,
        // so the logo stays at true vertical centre while text is transparent.
        if (_textOpacity.value > 0.0) ...[
          const SizedBox(height: 16),
          Opacity(
            opacity: _textOpacity.value.clamp(0.0, 1.0),
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
        ],
      ],
    );
  }
}

// ── Reusable icon card ───────────────────────────────────────────────────────

class _IconCard extends StatelessWidget {
  const _IconCard({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Image.asset(
        path,
        width: 30,
        height: 30,
        fit: BoxFit.contain,
      ),
    );
  }
}