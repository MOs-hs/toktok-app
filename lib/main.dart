import 'package:delivery_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'admin_dashboard.dart';
import 'agent_dashboard.dart';
import 'customer_dashboard.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'marketplace_dashboard.dart';
import 'signup_screen.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization skipped or failed: ${e.toString()}");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color noturnoBg = Color(0xFF001621);
  static const Color noturnoCard = Color(0xFF0A2230);
  static const Color vulcanicoPrimary = Color(0xFFFF4103);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TokTok',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: noturnoBg,
        primaryColor: vulcanicoPrimary,
        cardColor: noturnoCard,
        colorScheme: const ColorScheme.dark(
          primary: vulcanicoPrimary,
          secondary: vulcanicoPrimary,
          surface: noturnoCard,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: noturnoCard,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: vulcanicoPrimary,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/customer': (context) => const CustomerDashboard(),
        '/agent': (context) => const AgentDashboard(),
        '/admin': (context) => const AdminDashboard(),
        '/marketplace': (context) => const MarketplaceDashboard(),
        '/signup': (context) => const SignupScreen(),
      },
    );
  }
}
