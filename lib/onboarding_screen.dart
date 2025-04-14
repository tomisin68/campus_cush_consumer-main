import 'package:flutter/material.dart';
import 'package:campus_cush_consumer/signup.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> slides = [
    OnboardingSlide(
      image: 'assets/hostel1.jpg',
      headline: 'Find Student Hostels Easily',
      subtext:
          'Discover affordable and comfortable hostels near your campus with just a few taps.',
      color: const Color(0xFF1E88E5),
    ),
    OnboardingSlide(
      image: 'assets/hostel2.jpg',
      headline: 'Secure Payment System',
      subtext:
          'Pay for your hostel securely with our verified payment gateway. No hidden charges!',
      color: const Color(0xFF43A047),
    ),
    OnboardingSlide(
      image: 'assets/hostel1.jpg',
      headline: '24/7 Support',
      subtext:
          'Our support team is always available to help with any issues you might encounter.',
      color: const Color(0xFF5E35B1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Image Section (Top Half)
            Expanded(
              flex: 5,
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        slides[index].image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Content Section
            Expanded(
              flex: 4,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Content Section
                    Column(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: Text(
                            slides[_currentPage].headline,
                            key:
                                ValueKey<String>(slides[_currentPage].headline),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: 'Roboto',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: Text(
                            slides[_currentPage].subtext,
                            key: ValueKey<String>(slides[_currentPage].subtext),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontFamily: 'Roboto',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),

                    // Page Indicator
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: slides.length,
                      effect: ExpandingDotsEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: slides[_currentPage].color,
                        dotColor: Colors.grey.shade300,
                        spacing: 8,
                      ),
                    ),

                    // Navigation Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Skip Button
                        TextButton(
                          onPressed: () => _navigateToMain(),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),

                        // Next/Get Started Button
                        ElevatedButton(
                          onPressed: () => _handleNextButton(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: slides[_currentPage].color,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage == slides.length - 1
                                    ? 'Get Started'
                                    : 'Next',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentPage == slides.length - 1
                                    ? Icons.login_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNextButton() {
    if (_currentPage < slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToMain();
    }
  }

  void _navigateToMain() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupPage()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingSlide {
  final String image;
  final String headline;
  final String subtext;
  final Color color;

  OnboardingSlide({
    required this.image,
    required this.headline,
    required this.subtext,
    required this.color,
  });
}
