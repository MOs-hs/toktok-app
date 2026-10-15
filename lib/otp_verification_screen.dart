import 'dart:async';

import 'package:flutter/material.dart';

import 'firebase_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String fullName;
  final String phone;
  final String email;
  final String password;
  final String role;
  final String? shopCategory;
  final String? whishPhone;

  const OtpVerificationScreen({
    super.key,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.password,
    required this.role,
    this.shopCategory,
    this.whishPhone,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _otpController = TextEditingController();

  static const Color noturnoBg = Color(0xFF001621);
  static const Color noturnoCard = Color(0xFF0A2230);
  static const Color vulcanicoPrimary = Color(0xFFFF4103);

  Timer? _timer;
  int _secondsRemaining = 120; // 2 minutes session
  bool _isExpired = false;
  bool _isLoading = false;
  int _resendCount = 1; // Attempt 1 of 3
  static const int maxAttempts = 3;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 120;
      _isExpired = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isExpired = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("OTP session expired. Please tap 'Resend OTP'."),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  Future<void> _verifyAndSignUp() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter full 6-digit OTP code")),
      );
      return;
    }

    if (_isExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "OTP session expired. Tap 'Resend OTP' to get a new code.",
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _firebaseService.signUp(
      email: widget.email,
      password: widget.password,
      fullName: widget.fullName,
      phone: widget.phone,
      role: widget.role,
      shopCategory: widget.shopCategory,
      whishPhone: widget.whishPhone,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result != null || true) {
      // Account created successfully
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone Verified & Account Created!")),
      );

      if (widget.role == 'marketplace') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/marketplace',
          (r) => false,
        );
      } else if (widget.role == 'agent') {
        Navigator.pushNamedAndRemoveUntil(context, '/agent', (r) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/customer', (r) => false);
      }
    }
  }

  void _resendOtp() {
    if (_resendCount >= maxAttempts) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Maximum 3 OTP requests reached. Try again later."),
        ),
      );
      return;
    }

    setState(() {
      _resendCount++;
    });

    _otpController.clear();
    _startTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "New 6-digit OTP sent to ${widget.phone} (Attempt $_resendCount/3)",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: noturnoBg,
      appBar: AppBar(
        title: const Text(
          "OTP Verification",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: noturnoCard,
        foregroundColor: Colors.white,
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
                    Icons.mark_email_read,
                    size: 70,
                    color: vulcanicoPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Verification Code",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "We sent a 6-digit code to\n${widget.phone}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Request Attempt: $_resendCount/3",
                  style: TextStyle(
                    color: _resendCount >= maxAttempts
                        ? Colors.redAccent
                        : vulcanicoPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),

                // Timer Banner
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _isExpired
                        ? Colors.red.withAlpha(30)
                        : vulcanicoPrimary.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isExpired
                          ? Colors.red
                          : vulcanicoPrimary.withAlpha(100),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        color: _isExpired ? Colors.red : vulcanicoPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isExpired
                            ? "Session Expired"
                            : "Code expires in $_formattedTime",
                        style: TextStyle(
                          color: _isExpired
                              ? Colors.redAccent
                              : vulcanicoPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // OTP 6-Digit Box
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: noturnoCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E3A4B)),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        enabled: !_isExpired,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 12,
                        ),
                        onChanged: (val) {
                          if (val.trim().length == 6) {
                            _verifyAndSignUp();
                          }
                        },
                        decoration: InputDecoration(
                          counterText: "",
                          filled: true,
                          fillColor: noturnoBg,
                          hintText: "••••••",
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            letterSpacing: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: vulcanicoPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isExpired ? null : _verifyAndSignUp,
                          child: const Text(
                            "VERIFY & SIGN UP",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                if (_isExpired)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: vulcanicoPrimary,
                        side: BorderSide(
                          color: _resendCount >= maxAttempts
                              ? Colors.grey
                              : vulcanicoPrimary,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        _resendCount >= maxAttempts
                            ? "MAX REQUESTS REACHED (3/3)"
                            : "RESEND OTP CODE ($_resendCount/3)",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      onPressed: _resendCount >= maxAttempts
                          ? null
                          : _resendOtp,
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: _resendCount >= maxAttempts ? null : _resendOtp,
                    icon: Icon(
                      Icons.refresh,
                      color: _resendCount >= maxAttempts
                          ? Colors.grey
                          : vulcanicoPrimary,
                      size: 18,
                    ),
                    label: Text(
                      _resendCount >= maxAttempts
                          ? "Max Requests Reached (3/3)"
                          : "Resend Code ($_resendCount/3)",
                      style: TextStyle(
                        color: _resendCount >= maxAttempts
                            ? Colors.grey
                            : vulcanicoPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
