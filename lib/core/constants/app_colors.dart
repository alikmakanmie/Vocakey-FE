import 'package:flutter/material.dart';

class AppColors {
  // Gradient colors dari desain
  static const Color primaryBlue = Color(0xFF6BA5E7);
  static const Color secondaryPurple = Color(0xFF9B88D9);
  static const Color darkNavy = Color(0xFF3D4B63);
  static const Color lightBlue = Color(0xFFB8D8F5);
  
  // Text colors
  static const Color textWhite = Colors.white;
  static const Color textDark = Color(0xFF2C3E50);
  
  // Button colors
  static const Color buttonLight = Color(0xFFE8F4FD);
  static const Color buttonDark = Color(0xFF3D4B63);
  
  // Background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryBlue, secondaryPurple],
  );
  
  // Card colors
  static const Color cardLight = Color(0xFFCCE5F8);
  static const Color cardDark = Color(0xFF3D4B63);
}
