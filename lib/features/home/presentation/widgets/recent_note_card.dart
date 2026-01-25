import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/responsive_helper.dart';

class RecentNoteCard extends StatelessWidget {
  final String? note;

  const RecentNoteCard({
    Key? key,
    this.note,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveHelper.largeSpacing),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(ResponsiveHelper.radius(20)),
      ),
      child: Column(
        children: [
          Text(
            AppStrings.previousNote,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: ResponsiveHelper.fontSize(14),
            ),
          ),
          SizedBox(height: ResponsiveHelper.smallSpacing),
          Text(
            note ?? 'G',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: ResponsiveHelper.fontSize(48),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
