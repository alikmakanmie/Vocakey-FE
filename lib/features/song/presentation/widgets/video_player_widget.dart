import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/responsive_helper.dart';

class VideoPlayerWidget extends StatelessWidget {
  final String? videoUrl;

  const VideoPlayerWidget({
    Key? key,
    this.videoUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: ResponsiveHelper.height(200),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(ResponsiveHelper.radius(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline,
            size: ResponsiveHelper.xLargeIcon * 2,
            color: AppColors.textDark,
          ),
          SizedBox(height: ResponsiveHelper.smallSpacing),
          Text(
            AppStrings.videoKaraoke,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: ResponsiveHelper.fontSize(14),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: ResponsiveHelper.smallSpacing / 2),
          // Progress Bar Placeholder
          Container(
            width: ResponsiveHelper.width(250),
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textDark.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.3,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
