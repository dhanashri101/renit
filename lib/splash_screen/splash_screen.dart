import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rentit24/homescreen.dart'; // Adjust import as needed

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScaleAnimation;

  // Using emojis to mimic the colorful, 3D assets in your screenshot
  final List<String> _floatingItems = [
    '🎮', '✂️', '🐕', '🎸', '🛒', '☂️', '☕', '🏠', 
    '👷', '🌀', '🚁', '🔊', '💐', '👗', '🔌'
  ];

  // Store relative positions and rotations for each card
  late List<Map<String, double>> _cardConfigs;

  @override
  void initState() {
    super.initState();

    // 1. Pre-calculate random positions and tilts so they don't jump on rebuild
    final random = Random(42); // Fixed seed keeps the layout looking the exact same every time
    _cardConfigs = List.generate(_floatingItems.length, (index) {
      return {
        'x': random.nextDouble(), // Relative horizontal position (0.0 to 1.0)
        'y': random.nextDouble(), // Relative vertical position (0.0 to 1.0)
        'angle': (random.nextDouble() - 0.5) * 0.8, // Random tilt between -0.4 and 0.4 radians
      };
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Phase 2: Main logo pops up with a slight bounce
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.9, curve: Curves.elasticOut),
      ),
    );

    // Start animation and simulate navigation
    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
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

  // 2. Build the scattered cards spreading across the full screen
  List<Widget> _buildScatteredCards(Size screenSize) {
    return List.generate(_floatingItems.length, (index) {
      final config = _cardConfigs[index];
      
      // Map the 0.0 - 1.0 relative values to actual screen pixels
      // Subtracting 60 ensures the cards stay mostly within the screen edges
      final leftPos = config['x']! * (screenSize.width - 60);
      final topPos = config['y']! * (screenSize.height - 60);

      return Positioned(
        left: leftPos,
        top: topPos,
        child: Transform.rotate(
          angle: config['angle']!,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18), // Smooth rounded corners
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _floatingItems[index],
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
        ),
      );
    });
  }

  // Optional: Keeping your logo widget if you still want it to pop up in the center
  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Opacity(
            opacity: _logoScaleAnimation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF1E50CE), // Match background to obscure cards behind it
              border: Border.all(color: Colors.white, width: 4),
              shape: BoxShape.circle,
            ),
            child: const Text(
              'R',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Rentit 24',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
              shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Grab the screen dimensions to scatter the cards properly
    final size = MediaQuery.of(context).size; 

    return Scaffold(
      backgroundColor: const Color(0xFF2355D6), // Vibrant blue from your screenshot
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ..._buildScatteredCards(size),
            // _buildLogo(), // Uncomment this if you want your logo to animate in over the scattered cards
          ],
        ),
      ),
    );
  }
}