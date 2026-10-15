import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  static const Color noturnoBg = Color(0xFF001621);
  static const Color vulcanicoPrimary = Color(0xFFFF4103);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
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
      backgroundColor: noturnoBg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.8,
            colors: [Color(0xFF0A2E3D), noturnoBg],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: vulcanicoPrimary.withAlpha(25),
                          boxShadow: [
                            BoxShadow(
                              color: vulcanicoPrimary.withAlpha(80),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                          border: Border.all(
                            color: vulcanicoPrimary.withAlpha(150),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.delivery_dining,
                          size: 100,
                          color: vulcanicoPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "TokTok",
                        style: TextStyle(
                          fontSize: 46,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 3,
                          shadows: [
                            Shadow(color: vulcanicoPrimary, blurRadius: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: vulcanicoPrimary.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: vulcanicoPrimary.withAlpha(100),
                          ),
                        ),
                        child: const Text(
                          "NEXT GEN DELIVERY",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: vulcanicoPrimary,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 36.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.bolt, color: vulcanicoPrimary, size: 18),
                    SizedBox(width: 6),
                    Text(
                      "POWERED BY KATANA",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
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
}
