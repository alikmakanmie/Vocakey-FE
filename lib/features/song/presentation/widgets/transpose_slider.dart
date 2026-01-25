import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/responsive_helper.dart';

class TransposeSlider extends StatefulWidget {
  final int initialValue;
  final ValueChanged<double> onChanged;

  const TransposeSlider({
    Key? key,
    this.initialValue = 0,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<TransposeSlider> createState() => _TransposeSliderState();
}

class _TransposeSliderState extends State<TransposeSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.mediumSpacing),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(ResponsiveHelper.radius(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Minus Button
              IconButton(
                onPressed: () {
                  if (_currentValue > -12) {
                    setState(() {
                      _currentValue--;
                    });
                    widget.onChanged(_currentValue);
                  }
                },
                icon: Container(
                  width: ResponsiveHelper.width(40),
                  height: ResponsiveHelper.width(40),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryPurple,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.remove,
                    color: AppColors.textWhite,
                    size: ResponsiveHelper.mediumIcon,
                  ),
                ),
              ),

              // Value Display
              Column(
                children: [
                  Text(
                    '${_currentValue > 0 ? '+' : ''}${_currentValue.toInt()} ${AppStrings.semitone}',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: ResponsiveHelper.fontSize(20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Plus Button
              IconButton(
                onPressed: () {
                  if (_currentValue < 12) {
                    setState(() {
                      _currentValue++;
                    });
                    widget.onChanged(_currentValue);
                  }
                },
                icon: Container(
                  width: ResponsiveHelper.width(40),
                  height: ResponsiveHelper.width(40),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryPurple,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    color: AppColors.textWhite,
                    size: ResponsiveHelper.mediumIcon,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveHelper.mediumSpacing),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primaryBlue,
              inactiveTrackColor: AppColors.textDark.withOpacity(0.2),
              thumbColor: AppColors.primaryBlue,
              overlayColor: AppColors.primaryBlue.withOpacity(0.2),
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: ResponsiveHelper.width(12),
              ),
              overlayShape: RoundSliderOverlayShape(
                overlayRadius: ResponsiveHelper.width(20),
              ),
            ),
            child: Slider(
              value: _currentValue,
              min: -12,
              max: 12,
              divisions: 24,
              onChanged: (value) {
                setState(() {
                  _currentValue = value;
                });
                widget.onChanged(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
