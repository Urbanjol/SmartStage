import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 0 = Passenger, 1 = Driver/Conductor Crew
  int _selectedRoleIndex = 0;

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF0056b3); // Brand Blue
    final accentGreen = const Color(0xFF10B981);  // SmartStage Green Highlight

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. THE HERO PREMIUM "S" BRANDING AREA
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, primaryColor.withOpacity(0.85)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Dynamic Elegant Custom Paint "S" Logo Symbol
                    CustomPaint(
                      size: const Size(100, 120),
                      painter: SmartStageLogoPainter(brandColor: Colors.white, accentColor: accentGreen),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "SmartStage",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      "Escrow Transport Infrastructure",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 2. THE DYNAMIC ROLE SELECTION TAB SYSTEM
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // PASSENGER TAB
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRoleIndex = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _selectedRoleIndex == 0 ? primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            "Passenger",
                            style: TextStyle(
                              color: _selectedRoleIndex == 0 ? Colors.white : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // DRIVER / CONDUCTOR TAB
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRoleIndex = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _selectedRoleIndex == 1 ? accentGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            "Driver / Conductor",
                            style: TextStyle(
                              color: _selectedRoleIndex == 1 ? Colors.white : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 3. SECURE AUTHENTICATION INPUT FORM PIPELINE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dynamic hint message depending on the role selected
                  Text(
                    _selectedRoleIndex == 0
                        ? "Commuter Terminal Access"
                        : "Transit Crew Operator Terminal",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _selectedRoleIndex == 0 ? primaryColor : accentGreen,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Phone input card frame
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.phone_android, color: Colors.black45),
                        hintText: "Phone Number (e.g. 07...)",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password input card frame
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.lock_outline, color: Colors.black45),
                        hintText: "Security PIN / Password",
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.black38),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 4. MAIN ACTION INTERACTION BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Route strategy or validation processing blocks go here...
                        print("Role ID Authenticating: $_selectedRoleIndex");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedRoleIndex == 0 ? primaryColor : accentGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Secure Access",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 5. VECTOR CANVAS PAINT GENERATOR FOR THE BIG BRAND "S"
class SmartStageLogoPainter extends CustomPainter {
  final Color brandColor;
  final Color accentColor;

  SmartStageLogoPainter({required this.brandColor, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = brandColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Mathematically plotting an interlocking, premium ribbon curve "S"
    path.moveTo(size.width * 0.8, size.height * 0.15);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.05, size.width * 0.2, size.height * 0.35);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.6, size.width * 0.5, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.6, size.width * 0.8, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.98, size.width * 0.2, size.height * 0.9);

    canvas.drawPath(path, paint);

    // Drop a signature accent verification dot at the nexus loop core
    final dotPaint = Paint()..color = accentColor..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.6), 8, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}