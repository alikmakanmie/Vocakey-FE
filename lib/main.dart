import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'core/presentation/widgets/main_layout.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/home/presentation/bloc/home_event.dart';
import 'features/pitch/presentation/pages/pitch_recording_page.dart';
import 'features/pitch/presentation/pages/pitch_result_page.dart';
import 'features/pitch/presentation/bloc/pitch_bloc.dart';
import 'features/pitch/domain/entities/analysis_result.dart';
import 'features/song/presentation/pages/song_list_page.dart';
import 'features/song/presentation/pages/song_detail_page.dart'; // ✅ Import SongDetailPage
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await di.init();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const VocaKeyApp());
}

class VocaKeyApp extends StatelessWidget {
  const VocaKeyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'VocaKey',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(
                  builder: (_) => const SplashPage(),
                );
              case '/home':
                return MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => di.sl<HomeBloc>()..add(LoadLastAnalysisEvent()),
                    child: const MainLayout(initialIndex: 0),
                  ),
                );
              case '/pitch-recording':
                return MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => di.sl<PitchBloc>(),
                    child: const PitchRecordingPage(),
                  ),
                );
              case '/pitch-result':
                final result = settings.arguments as AnalysisResult;
                return MaterialPageRoute(
                  builder: (_) => PitchResultPage(result: result),
                );
              case '/songs':
                return MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => di.sl<HomeBloc>(),
                    child: const MainLayout(initialIndex: 1),
                  ),
                );
              case '/song-detail':
                // ✅ UPDATE: Terima SongDetailArguments
                final args = settings.arguments as SongDetailArguments;
                return MaterialPageRoute(
                  builder: (_) => SongDetailPage(arguments: args),
                );
              default:
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(
                    body: Center(
                      child: Text('Page not found'),
                    ),
                  ),
                );
            }
          },
        );
      },
    );
  }
}
