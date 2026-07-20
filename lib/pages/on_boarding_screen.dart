import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rentit24/pages/welcomescreen.dart';
import 'package:rentit24/wrapper/navbar.dart';
import 'package:rentit24/services/banner_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  Timer? _timer;

  final BannerService _bannerService = BannerService();

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Rent Anything, Rent Anytime",
      "subtitle":
          "Rent everything from stylish furniture\n"
          "to bicycles—your one-stop solution\n"
          "for all your rental needs!",
      "bgImage": "assets/images/slide1-bg.png",
      "mainImage": "assets/images/slide1-illustration.png",
    },
    {
      "title": "Need a cool dress?",
      "subtitle":
          "Hire a professional fashion stylist to\n"
          "event organiser to help you find\n"
          "everything you need.",
      "bgImage": "assets/images/slide2-bg.png",
      "mainImage": "assets/images/slide2-illustration.png",
    },
    {
      "title": "Wanna be a guitarist?",
      "subtitle":
          "Discover everything from guitars\n"
          "to speakers—your musical journey\n"
          "starts here!",
      "bgImage": "assets/images/slide3-bg.png",
      "mainImage": "assets/images/slide3-illustration.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    // _loadBanners();
    _startAutoScroll();
  }

  Future<void> _loadBanners() async {
    try {
      final banners = await _bannerService.getSplashBanners();
      if (!mounted || banners.isEmpty) return;
      setState(() {
        onboardingData
          ..clear()
          ..addAll(
            banners.map(
              (banner) => <String, String>{
                'title': banner.title,
                'subtitle': banner.subtitle,
                'bgImage': banner.backgroundImageUrl,
                'mainImage': banner.imageUrl,
              },
            ),
          );
        _currentPage = 0;
      });
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
      _startAutoScroll();
    } catch (error, stackTrace) {
      debugPrint('Onboarding banner error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _startAutoScroll() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !_pageController.hasClients) return;

      if (_currentPage < onboardingData.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      } else {
        timer.cancel();
      }
    });
  }

  void _goToHome() {
    _timer?.cancel();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const NavigationWrapper(),
      ),
    );
  }

  void _goToLogin() {
    _timer?.cancel();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainLoginScreen(),
      ),
    );
  }

  void _handleNext() {
    if (_currentPage == onboardingData.length - 1) {
      _goToLogin();
      return;
    }

    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return FullScreenSlide(
                data: onboardingData[index],
              );
            },
          ),

          // Skip button and bottom controls
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _goToHome,
                      style: TextButton.styleFrom(
                        foregroundColor:
                            colorScheme.onSurface.withOpacity(0.65),
                      ),
                      child: Text(
                        "SKIP",
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.65),
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              colorScheme.onSurface.withOpacity(0.65),
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          onboardingData.length,
                          (index) => _buildDot(index, colorScheme),
                        ),
                      ),
                      const SizedBox(height: 28),

                      SizedBox(
                        width: 56,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _handleNext,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            elevation: 3,
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shadowColor:
                                colorScheme.primary.withOpacity(0.35),
                            shape: const CircleBorder(),
                          ),
                          child: Icon(
                            _currentPage == onboardingData.length - 1
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, ColorScheme colorScheme) {
    final bool isSelected = _currentPage == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 7,
      width: isSelected ? 26 : 10,
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary
            : colorScheme.primary.withOpacity(0.25),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class _AdaptiveImage extends StatelessWidget {
  const _AdaptiveImage({
    required this.source,
    required this.fit,
    required this.fallback,
    this.color,
    this.colorBlendMode,
  });

  final String source;
  final BoxFit fit;
  final Widget fallback;
  final Color? color;
  final BlendMode? colorBlendMode;

  @override
  Widget build(BuildContext context) {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        color: color,
        colorBlendMode: colorBlendMode,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    if (source.isEmpty) return fallback;
    return Image.asset(
      source,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      color: color,
      colorBlendMode: colorBlendMode,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}

class FullScreenSlide extends StatelessWidget {
  final Map<String, String> data;

  const FullScreenSlide({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.scaffoldBackgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Theme-aware background image
          _AdaptiveImage(
            source: data['bgImage'] ?? '',
            fit: BoxFit.cover,
            color: isDark ? Colors.black.withOpacity(0.30) : null,
            colorBlendMode: isDark ? BlendMode.darken : null,
            fallback: ColoredBox(color: theme.scaffoldBackgroundColor),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  Flexible(
                    flex: 6,
                    child: _AdaptiveImage(
                      source: data['mainImage'] ?? '',
                      fit: BoxFit.contain,
                      fallback: Icon(
                        Icons.image_not_supported_outlined,
                        size: 80,
                        color: colorScheme.onSurface.withOpacity(0.35),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    data["title"]!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    data["subtitle"]!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.65),
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}