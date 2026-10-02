import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppText {
  static TextStyle header = GoogleFonts.orbitron(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF1E293B),
  );

  static TextStyle body = GoogleFonts.inter(
    fontSize: 14,
    color: const Color(0xFF1E293B),
  );

  static TextStyle number = GoogleFonts.robotoMono(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF1E293B),
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 11,
    color: const Color(0xFF64748B),
  );

  static TextStyle title = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF1E293B),
  );

  static TextStyle subtitle = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF64748B),
  );
}