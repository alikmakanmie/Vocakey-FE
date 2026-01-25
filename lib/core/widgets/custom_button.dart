import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/responsive_helper.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isLoading;
  final IconData? icon;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveHelper.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary 
              ? AppColors.primaryBlue 
              : AppColors.textWhite,
          foregroundColor: isPrimary 
              ? AppColors.textWhite 
              : AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.radius(12),
            ),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? SizedBox(
                width: ResponsiveHelper.mediumIcon,
                height: ResponsiveHelper.mediumIcon,
                child: CircularProgressIndicator(
                  color: isPrimary 
                      ? AppColors.textWhite 
                      : AppColors.primaryBlue,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: ResponsiveHelper.mediumIcon),
                    SizedBox(width: ResponsiveHelper.smallSpacing),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
