import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_helper.dart';

class SongCard extends StatelessWidget {
  final String title;
  final String artist;
  final VoidCallback onTap;
  
  const SongCard({
    Key? key,
    required this.title,
    required this.artist,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ResponsiveHelper.width(150),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(ResponsiveHelper.radius(12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Image/Icon Section
            Container(
              height: ResponsiveHelper.height(120),
              decoration: BoxDecoration(
                color: AppColors.cardLight.withOpacity(0.3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ResponsiveHelper.radius(12)),
                  topRight: Radius.circular(ResponsiveHelper.radius(12)),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: ResponsiveHelper.xLargeIcon,
                  color: AppColors.textWhite,
                ),
              ),
            ),
            
            // ✅ Text Info Section
            Padding(
              padding: EdgeInsets.all(ResponsiveHelper.smallSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: ResponsiveHelper.fontSize(14),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ResponsiveHelper.smallSpacing / 2),
                  Text(
                    artist,
                    style: TextStyle(
                      color: AppColors.textWhite.withOpacity(0.7),
                      fontSize: ResponsiveHelper.fontSize(12),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
