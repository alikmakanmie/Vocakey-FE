import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveHelper {
  static void init(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(393, 852), // Design size dari Figma
      minTextAdapt: true,
    );
  }
  
  static double width(double size) => size.w;
  static double height(double size) => size.h;
  static double fontSize(double size) => size.sp;
  static double radius(double size) => size.r;
  
  // Common spacing
  static double get smallSpacing => 8.h;
  static double get mediumSpacing => 16.h;
  static double get largeSpacing => 24.h;
  static double get xLargeSpacing => 32.h;
  
  // Icon sizes
  static double get smallIcon => 20.w;
  static double get mediumIcon => 24.w;
  static double get largeIcon => 32.w;
  static double get xLargeIcon => 48.w;
  
  // Button sizes
  static double get buttonHeight => 56.h;
  static double get smallButtonHeight => 40.h;
}
