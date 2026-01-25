import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../utils/responsive_helper.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.darkNavy.withOpacity(0.5),
        selectedFontSize: ResponsiveHelper.fontSize(12),
        unselectedFontSize: ResponsiveHelper.fontSize(12),
        elevation: 0,
        backgroundColor: Colors.transparent,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppStrings.navHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: AppStrings.navSong,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.graphic_eq),
            label: AppStrings.navTranspose,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppStrings.navProfile,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppStrings.navSettings,
          ),
        ],
      ),
    );
  }
}
