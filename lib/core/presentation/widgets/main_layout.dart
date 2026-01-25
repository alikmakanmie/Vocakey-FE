import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../features/home/presentation/pages/home_page.dart';
import '../../../features/song/presentation/pages/song_list_page.dart';
import '../../../features/song/presentation/bloc/song_bloc.dart';
import '../../../injection_container.dart' as di;

class MainLayout extends StatefulWidget {
  final int initialIndex;
  
  const MainLayout({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }
  
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SongBloc>(
          create: (_) => di.sl<SongBloc>(),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            HomePage(),
            SongListPage(),
            TransposePage(),
            ProfilePage(),
            SettingsPage(),
          ],
        ),
        // ✅ FloatingActionButton di tengah
        floatingActionButton: SizedBox(
          width: 64,
          height: 64,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/pitch-recording');
            },
            backgroundColor: AppColors.primaryBlue,
            elevation: 6,
            child: const Icon(
              Icons.mic,
              size: 32,
              color: Colors.white,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        
        // ✅ Bottom Navigation Bar dengan BottomAppBar
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          shape: const CircularNotchedRectangle(),
          notchMargin: 6.0,
          elevation: 10,
          child: Container(
            height: 56, // ✅ Fixed height
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side items
                Row(
                  children: [
                    _buildNavItem(
                      icon: Icons.home,
                      label: 'Beranda',
                      index: 0,
                    ),
                    const SizedBox(width: 8),
                    _buildNavItem(
                      icon: Icons.music_note,
                      label: 'Lagu',
                      index: 1,
                    ),
                  ],
                ),
                
                // ✅ Spacer untuk FAB di tengah
                const SizedBox(width: 64),
                
                // Right side items
                Row(
                  children: [
                    _buildNavItem(
                      icon: Icons.person,
                      label: 'Profil',
                      index: 3,
                    ),
                    const SizedBox(width: 8),
                    _buildNavItem(
                      icon: Icons.settings,
                      label: 'Pengaturan',
                      index: 4,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        constraints: const BoxConstraints(
          minWidth: 64, // ✅ Minimum width
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive 
                  ? AppColors.primaryBlue 
                  : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive 
                    ? AppColors.primaryBlue 
                    : Colors.grey.shade600,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Placeholder Pages =====

class TransposePage extends StatelessWidget {
  const TransposePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: const Center(
        child: Text(
          'Tranpose Page',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: const Center(
        child: Text(
          'Profile Page',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: const Center(
        child: Text(
          'Settings Page',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
