import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Config/theme.dart';
import '../Services/Auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String _verificationId = '';
  bool _isCodeSent = false;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _sendOTP() async {
    String phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _errorMessage = 'Please enter your phone number');
      return;
    }

    if (!phone.startsWith('+')) {
      phone = '+256${phone.replaceFirst('0', '')}';
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.sendOTP(
        phone,
        codeSent: (verificationId, resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isCodeSent = true;
            _isLoading = false;
          });
        },
        verificationFailed: (e) {
          setState(() {
            _errorMessage = e.message;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOTP() async {
    String otp = _otpController.text.trim();
    if (otp.isEmpty) {
      setState(() => _errorMessage = 'Please enter the OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.verifyOTP(_verificationId, otp);
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid OTP. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? SmartStageColors.darkBackground
          : SmartStageColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Logo and Title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            SmartStageColors.deepNavy,
                            SmartStageColors.electricGreen,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: SmartStageColors.greenGlow,
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_bus,
                        color: SmartStageColors.white,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'SmartStage',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: SmartStageColors.deepNavy,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your journey starts here',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark
                            ? SmartStageColors.greyMid
                            : SmartStageColors.greyDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              // Phone Number Label
              Text(
                'PHONE NUMBER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? SmartStageColors.greyMid
                      : SmartStageColors.greyDark,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),

              // Phone Number Input
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? SmartStageColors.navyCard
                      : SmartStageColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white10
                        : SmartStageColors.greyLight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: isDark
                            ? SmartStageColors.navyLight
                            : SmartStageColors.greyLight,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '+256',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: SmartStageColors.deepNavy,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        enabled: !_isCodeSent,
                        style: TextStyle(
                          color: isDark
                              ? SmartStageColors.white
                              : SmartStageColors.deepNavy,
                        ),
                        decoration: InputDecoration(
                          hintText: '7XX XXX XXX',
                          hintStyle: TextStyle(
                            color: isDark
                                ? SmartStageColors.greyMid
                                : SmartStageColors.greyDark,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // OTP Input
              if (_isCodeSent) ...[
                Text(
                  'VERIFICATION CODE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? SmartStageColors.greyMid
                        : SmartStageColors.greyDark,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? SmartStageColors.navyCard
                        : SmartStageColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: SmartStageColors.electricGreen.withOpacity(0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: SmartStageColors.greenGlow,
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: TextStyle(
                      color: isDark
                          ? SmartStageColors.white
                          : SmartStageColors.deepNavy,
                      letterSpacing: 4,
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter 6-digit code',
                      hintStyle: TextStyle(
                        color: isDark
                            ? SmartStageColors.greyMid
                            : SmartStageColors.greyDark,
                        letterSpacing: 1,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 18),
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: SmartStageColors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: SmartStageColors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: SmartStageColors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: SmartStageColors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Action Button
              GlowButton(
                text: _isCodeSent ? 'VERIFY & LOGIN' : 'SEND OTP',
                color: _isCodeSent
                    ? SmartStageColors.electricGreen
                    : SmartStageColors.gold,
                glowColor: _isCodeSent
                    ? SmartStageColors.greenGlow
                    : SmartStageColors.goldGlow,
                icon: _isCodeSent
                    ? Icons.verified_outlined
                    : Icons.send_outlined,
                onPressed: _isLoading
                    ? () {}
                    : (_isCodeSent ? _verifyOTP : _sendOTP),
              ),
              const SizedBox(height: 16),

              // Loading indicator
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: SmartStageColors.electricGreen,
                  ),
                ),
              const SizedBox(height: 16),

              // Terms
              Center(
                child: Text(
                  'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? SmartStageColors.greyMid
                        : SmartStageColors.greyDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}