import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../bloc/song_bloc.dart';
import '../bloc/song_event.dart';

class SongFilterChips extends StatefulWidget {
  const SongFilterChips({Key? key}) : super(key: key);

  @override
  State<SongFilterChips> createState() => _SongFilterChipsState();
}

class _SongFilterChipsState extends State<SongFilterChips> {
  String? _selectedCategory;

  final List<String> _categories = [
    'Sesuai Nadaku',
    'Pop',
    'Jazz',
    'Rock',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveHelper.height(40),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: EdgeInsets.only(right: ResponsiveHelper.smallSpacing),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : null;
                });
                context.read<SongBloc>().add(
                  LoadSongsEvent(category: _selectedCategory),
                );
              },
              backgroundColor: AppColors.textWhite.withOpacity(0.3),
              selectedColor: AppColors.textWhite,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primaryBlue : AppColors.textWhite,
                fontSize: ResponsiveHelper.fontSize(12),
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.radius(20),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
