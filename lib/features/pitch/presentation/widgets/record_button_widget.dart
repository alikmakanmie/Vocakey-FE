import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_helper.dart';

class RecordButtonWidget extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onPressed;
  final int? recordingDuration;
  
  const RecordButtonWidget({
    Key? key,
    required this.isRecording,
    required this.onPressed,
    this.recordingDuration,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: ResponsiveHelper.width(150),
        height: ResponsiveHelper.width(150),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.textWhite,
          border: Border.all(
            color: AppColors.textWhite,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: isRecording
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mic,
                      size: ResponsiveHelper.largeIcon,
                      color: AppColors.primaryBlue,
                    ),
                    if (recordingDuration != null) ...[
                      SizedBox(height: ResponsiveHelper.smallSpacing),
                      Text(
                        '${recordingDuration! ~/ 60}:${(recordingDuration! % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.fontSize(14),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ],
                )
              : Icon(
                  Icons.mic_none,
                  size: ResponsiveHelper.xLargeIcon,
                  color: AppColors.primaryBlue,
                ),
        ),
      ),
    );
  }
}
