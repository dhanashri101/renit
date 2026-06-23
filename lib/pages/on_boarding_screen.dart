import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:rentit24/core/theme.dart';
import 'package:rentit24/pages/homescreen.dart';
import 'package:rentit24/wrapper/navbar.dart';
import 'package:rentit24/pages/welcomescreen.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer; 

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Rent Anything, Rent Anytime",
      "subtitle":
          "Rent everything from stylish furniture\nto bicycles—your one-stop solution\nfor all your rental needs!",
      "bgImage": "assets/images/slide1-bg.png",
      "mainImage": "assets/images/slide1-illustration.png",
    },
    {
      "title": "Need a cool dress?",
      "subtitle":
          "Hire a professional fashion stylist to\nevent organiser to help you find\neverything you need.",
      "bgImage": "assets/images/slide2-bg.png",
      "mainImage": "assets/images/slide2-illustration.png",
    },
    {
      "title": "Wanna be a guitarist?",
      "subtitle":
          "Discover everything from guitars\nto speakers—your musical journey\nstarts here!",
      "bgImage": "assets/images/slide3-bg.png",
      "mainImage": "assets/images/slide3-illustration.png",
    },
  ];


  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < onboardingData.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (value) {
              setState(() {
                _currentPage = value;
              });
            },
            itemCount: onboardingData.length,
            itemBuilder: (context, index) {
              return FullScreenSlide(data: onboardingData[index]);
            },
          ),

          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        _timer?.cancel();

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NavigationWrapper(),
                          ),
                        );
                      },
                      child: Text(
                        "SKIP",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          onboardingData.length,
                          (index) => buildDot(index, context),
                        ),
                      ),
                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: () {
                          if (_currentPage == onboardingData.length - 1) {
                            _timer?.cancel();

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainLoginScreen(),
                              ),
                            );
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                          backgroundColor: AppTheme.primaryBlue,
                          elevation: 2,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
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

  Widget buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 6,
      width: _currentPage == index ? 24 : 12,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppTheme.primaryBlue
            : AppTheme.primaryBlue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class FullScreenSlide extends StatelessWidget {
  final Map<String, String> data;

  const FullScreenSlide({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(data["bgImage"]!),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Image.asset(data["mainImage"]!, fit: BoxFit.contain, height: 340),
            const SizedBox(height: 40),
            Text(
              data["title"]!,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                data["subtitle"]!,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
