import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color noturnoBg = Color(0xFF001621);
  static const Color vulcanicoPrimary = Color(0xFFFF4103);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: noturnoBg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A2E3D),
              noturnoBg,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: vulcanicoPrimary.withAlpha(30),
                      boxShadow: [
                        BoxShadow(
                          color: vulcanicoPrimary.withAlpha(90),
                          blurRadius: 35,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(
                        color: vulcanicoPrimary.withAlpha(180),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.delivery_dining,
                      size: 90,
                      color: vulcanicoPrimary,
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "TokTok",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: vulcanicoPrimary,
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Fast • Reliable • At Your Doorstep",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 50),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: vulcanicoPrimary,
                        elevation: 8,
                        shadowColor: vulcanicoPrimary.withAlpha(150),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "GET STARTED",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
