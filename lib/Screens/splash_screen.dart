import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Setup the intro animation duration loop
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Start animating immediately on mount
    _animationController.forward();

    // Hold the brand on screen, then route smoothly to Login
    _navigateToLoginPipeline();
  }

  void _navigateToLoginPipeline() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    // Use a custom PageRouteBuilder for a premium slide/fade transition
    // instead of a jarring default system pop cut
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF0056b3);
    final accentGreen = const Color(0xFF10B981);

    return Scaffold(
      backgroundColor: primaryColor, // Matches the top of the login header
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Uses the same custom vector painter for structural consistency
                    CustomPaint(
                      size: const Size(120, 140),
                      painter: SmartStageLogoPainter(
                        brandColor: Colors.white,
                        accentColor: accentGreen,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "SmartStage",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Escrow Transport Infrastructure",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Re-using the vector painter context to ensure the custom "S" matches perfectly
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
    path.moveTo(size.width * 0.8, size.height * 0.15);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.05, size.width * 0.2, size.height * 0.35);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.6, size.width * 0.5, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.6, size.width * 0.8, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.98, size.width * 0.2, size.height * 0.9);

    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = accentColor..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.6), 8, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}