import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  static const Color noturnoBg = Color(0xFF001621);
  static const Color noturnoCard = Color(0xFF0A2230);
  static const Color vulcanicoPrimary = Color(0xFFFF4103);

  Future<void> _handleLogin() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter both username/email and password"),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Quick demo shortcuts
    if (username == 'admin') {
      setState(() => _isLoading = false);
      _navigateToDashboardForRole('admin');
      return;
    } else if (username == 'driver' || username == 'agent') {
      setState(() => _isLoading = false);
      _navigateToDashboardForRole('agent');
      return;
    } else if (username == 'shop' || username == 'marketplace') {
      setState(() => _isLoading = false);
      _navigateToDashboardForRole('marketplace');
      return;
    }

    // Attempt Firebase Authentication
    if (Firebase.apps.isNotEmpty) {
      final credential = await _firebaseService.login(username, password);
      if (credential != null && credential.user != null) {
        String? role = await _firebaseService.getUserRole(credential.user!.uid);
        if (!mounted) return;
        setState(() => _isLoading = false);
        _navigateToDashboardForRole(role ?? 'customer');
        return;
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Fallback role routing based on email/username keyword or customer default
    if (username.contains('admin')) {
      _navigateToDashboardForRole('admin');
    } else if (username.contains('agent') || username.contains('driver')) {
      _navigateToDashboardForRole('agent');
    } else if (username.contains('market') || username.contains('shop')) {
      _navigateToDashboardForRole('marketplace');
    } else {
      _navigateToDashboardForRole('customer');
    }
  }

  void _navigateToDashboardForRole(String role) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Logged in as ${role.toUpperCase()}")),
    );
    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin');
    } else if (role == 'agent' || role == 'driver') {
      Navigator.pushReplacementNamed(context, '/agent');
    } else if (role == 'marketplace' || role == 'shop') {
      Navigator.pushReplacementNamed(context, '/marketplace');
    } else {
      Navigator.pushReplacementNamed(context, '/customer');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: noturnoBg,
      appBar: AppBar(
        title: const Text(
          "Login to TokTok",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: noturnoCard,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: vulcanicoPrimary.withAlpha(30),
                    border: Border.all(color: vulcanicoPrimary.withAlpha(120)),
                  ),
                  child: const Icon(
                    Icons.delivery_dining,
                    size: 70,
                    color: vulcanicoPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Username / Email",
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(
                      Icons.person,
                      color: vulcanicoPrimary,
                    ),
                    filled: true,
                    fillColor: noturnoCard,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1E3A4B)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: vulcanicoPrimary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.lock, color: vulcanicoPrimary),
                    filled: true,
                    fillColor: noturnoCard,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1E3A4B)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: vulcanicoPrimary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vulcanicoPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                      shadowColor: vulcanicoPrimary.withAlpha(120),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: const Text(
                      "LOGIN",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: vulcanicoPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 40, color: Color(0xFF1E3A4B)),
                const Text(
                  "Quick Access (Demo Only)",
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: [
                    ActionChip(
                      backgroundColor: noturnoCard,
                      side: const BorderSide(color: Color(0xFF1E3A4B)),
                      label: const Text(
                        "Admin",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () => _navigateToDashboardForRole('admin'),
                    ),
                    ActionChip(
                      backgroundColor: noturnoCard,
                      side: const BorderSide(color: Color(0xFF1E3A4B)),
                      label: const Text(
                        "Driver",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () => _navigateToDashboardForRole('agent'),
                    ),
                    ActionChip(
                      backgroundColor: noturnoCard,
                      side: const BorderSide(color: Color(0xFF1E3A4B)),
                      label: const Text(
                        "Market",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () =>
                          _navigateToDashboardForRole('marketplace'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: vulcanicoPrimary),
            ),
        ],
      ),
    );
  }
}
