import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../home/domain/entities/song.dart';

class SongListItem extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const SongListItem({
    Key? key,
    required this.song,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveHelper.mediumSpacing),
        padding: EdgeInsets.all(ResponsiveHelper.mediumSpacing),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(ResponsiveHelper.radius(15)),
        ),
        child: Row(
          children: [
            // Album Cover
            Container(
              width: ResponsiveHelper.width(80),
              height: ResponsiveHelper.width(80),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.radius(10),
                ),
              ),
              child: Icon(
                Icons.music_note,
                size: ResponsiveHelper.largeIcon,
                color: AppColors.textWhite,
              ),
            ),

            SizedBox(width: ResponsiveHelper.mediumSpacing),

            // Song Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: ResponsiveHelper.fontSize(16),
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ResponsiveHelper.smallSpacing / 2),
                  Text(
                    song.artist,
                    style: TextStyle(
                      color: AppColors.textDark.withOpacity(0.7),
                      fontSize: ResponsiveHelper.fontSize(12),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.smallSpacing / 2),
                  Row(
                    children: [
                      Text(
                        'Nada Asli: ${song.originalNote}',
                        style: TextStyle(
                          color: AppColors.textDark.withOpacity(0.5),
                          fontSize: ResponsiveHelper.fontSize(11),
                        ),
                      ),
                      if (song.isMatchWithUserNote) ...[
                        SizedBox(width: ResponsiveHelper.smallSpacing),
                        Icon(
                          Icons.check_circle,
                          size: ResponsiveHelper.fontSize(14),
                          color: Colors.green,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Cocok Dengan Nada Dasar Mu',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: ResponsiveHelper.fontSize(10),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
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
