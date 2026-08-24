import 'package:flutter/material.dart';

class SmartStageColors {
  // Primary Palette
  static const Color deepNavy = Color(0xFF0A192F);
  static const Color navyCard = Color(0xFF172A45);
  static const Color electricGreen = Color(0xFF10B981);
  static const Color gold = Color(0xFFFFB800);
  static const Color softGold = Color(0xFFFFD54F);
  static const Color orange = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color greyLight = Color(0xFFF1F5F9);
  static const Color greyMid = Color(0xFF94A3B8);
  static const Color greyDark = Color(0xFF475569);
  static const Color black = Color(0xFF000000);
  static const Color navyLight = Color(0xFF1E3A5F);

  // Backgrounds
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color darkBackground = Color(0xFF0A192F);

  // Glow Colors
  static const Color greenGlow = Color(0x6610B981);
  static const Color goldGlow = Color(0x66FFB800);
  static const Color blueGlow = Color(0x660056b3);
  static const Color whiteGlow = Color(0x66FFFFFF);
}

class SmartStageTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: SmartStageColors.deepNavy,
    scaffoldBackgroundColor: SmartStageColors.lightBackground,
    cardColor: SmartStageColors.white,
    dividerColor: SmartStageColors.greyLight,
    colorScheme: const ColorScheme.light(
      primary: SmartStageColors.deepNavy,
      secondary: SmartStageColors.electricGreen,
      tertiary: SmartStageColors.gold,
      surface: SmartStageColors.white,
      background: SmartStageColors.lightBackground,
      error: SmartStageColors.red,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: SmartStageColors.deepNavy,
      foregroundColor: SmartStageColors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: SmartStageColors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SmartStageColors.gold,
        foregroundColor: SmartStageColors.deepNavy,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 0.8,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: SmartStageColors.electricGreen,
      foregroundColor: SmartStageColors.white,
      elevation: 4,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: SmartStageColors.white,
      selectedItemColor: SmartStageColors.electricGreen,
      unselectedItemColor: SmartStageColors.greyMid,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
    ),
    cardTheme: CardThemeData(
      color: SmartStageColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: SmartStageColors.greyLight,
          width: 1,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SmartStageColors.greyLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: SmartStageColors.electricGreen,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(
        color: SmartStageColors.greyMid,
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: SmartStageColors.deepNavy,
    scaffoldBackgroundColor: SmartStageColors.darkBackground,
    cardColor: SmartStageColors.navyCard,
    dividerColor: Colors.white10,
    colorScheme: const ColorScheme.dark(
      primary: SmartStageColors.deepNavy,
      secondary: SmartStageColors.electricGreen,
      tertiary: SmartStageColors.gold,
      surface: SmartStageColors.navyCard,
      background: SmartStageColors.darkBackground,
      error: SmartStageColors.red,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: SmartStageColors.deepNavy,
      foregroundColor: SmartStageColors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: SmartStageColors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SmartStageColors.gold,
        foregroundColor: SmartStageColors.deepNavy,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 0.8,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: SmartStageColors.electricGreen,
      foregroundColor: SmartStageColors.white,
      elevation: 6,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: SmartStageColors.navyCard,
      selectedItemColor: SmartStageColors.electricGreen,
      unselectedItemColor: SmartStageColors.greyDark,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
    ),
    cardTheme: CardThemeData(
      color: SmartStageColors.navyCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.white10,
          width: 1,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SmartStageColors.navyLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: SmartStageColors.electricGreen,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(
        color: SmartStageColors.greyMid,
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),
  );
}

// ============================================================
// GLOWING WIDGETS
// ============================================================

class GlowCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final bool isActive;
  final VoidCallback? onTap;

  const GlowCard({
    Key? key,
    required this.child,
    required this.glowColor,
    this.isActive = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? glowColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: glowColor.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class GlowButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color glowColor;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isFullWidth;

  const GlowButton({
    Key? key,
    required this.text,
    required this.color,
    required this.glowColor,
    required this.onPressed,
    this.icon,
    this.isFullWidth = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: SmartStageColors.deepNavy,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SeatIndicator extends StatelessWidget {
  final String seatState;
  final double size;

  const SeatIndicator({
    Key? key,
    required this.seatState,
    this.size = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    Color glow;

    switch (seatState) {
      case 'space_available':
        color = SmartStageColors.electricGreen;
        glow = SmartStageColors.greenGlow;
        break;
      case 'filling_up':
        color = SmartStageColors.orange;
        glow = SmartStageColors.goldGlow;
        break;
      case 'full':
        color = SmartStageColors.red;
        glow = Colors.transparent;
        break;
      default:
        color = SmartStageColors.greyMid;
        glow = Colors.transparent;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: glow != Colors.transparent
            ? [
          BoxShadow(
            color: glow,
            blurRadius: size,
            spreadRadius: size * 0.2,
          ),
        ]
            : null,
      ),
    );
  }
}