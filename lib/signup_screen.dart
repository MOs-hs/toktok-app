import 'package:flutter/material.dart';

import 'models.dart';
import 'otp_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const Color noturnoBg = Color(0xFF001621);
  static const Color noturnoCard = Color(0xFF0A2230);
  static const Color vulcanicoPrimary = Color(0xFFFF4103);

  String selectedRole = 'Customer';
  String? selectedMarketType;
  final roles = ['Customer', 'Driver', 'Marketplace Owner'];

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController =
      TextEditingController(); // Email
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whishPhoneController = TextEditingController();

  void _proceedToOtp() {
    final name = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final whishPhone = _whishPhoneController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    if (!phone.startsWith('+')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter phone number with country code (e.g. +961...)",
          ),
        ),
      );
      return;
    }

    final mappedRole = selectedRole == 'Driver'
        ? 'agent'
        : (selectedRole == 'Marketplace Owner' ? 'marketplace' : 'customer');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          fullName: name,
          phone: phone,
          email: email,
          password: password,
          role: mappedRole,
          shopCategory: selectedMarketType,
          whishPhone: mappedRole == 'agent' ? whishPhone : null,
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
      prefixIcon: Icon(icon, color: vulcanicoPrimary),
      filled: true,
      fillColor: noturnoCard,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E3A4B)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: vulcanicoPrimary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: noturnoBg,
      appBar: AppBar(
        title: const Text(
          "Create Account",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: noturnoCard,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: vulcanicoPrimary.withAlpha(30),
                border: Border.all(color: vulcanicoPrimary.withAlpha(120)),
              ),
              child: const Icon(
                Icons.person_add,
                size: 70,
                color: vulcanicoPrimary,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _fullNameController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco("Full Name", Icons.person),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco("Phone Number (+961...)", Icons.phone),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco("Email Address", Icons.email),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco("Password", Icons.lock),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedRole,
              dropdownColor: noturnoCard,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco("I am a...", Icons.badge),
              items: roles
                  .map(
                    (role) => DropdownMenuItem(
                      value: role,
                      child: Text(
                        role,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => selectedRole = value!),
            ),
            if (selectedRole == 'Driver') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _whishPhoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco(
                  "Whish Account Phone Number",
                  Icons.account_balance_wallet,
                ),
              ),
            ],
            if (selectedRole == 'Marketplace Owner') ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedMarketType,
                dropdownColor: noturnoCard,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco("Shop Category", Icons.store),
                items: AppData.categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.title,
                        child: Text(
                          c.title,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => selectedMarketType = value),
              ),
            ],
            const SizedBox(height: 30),
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
                ),
                onPressed: _proceedToOtp,
                child: const Text(
                  "PROCEED",
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
    );
  }
}
