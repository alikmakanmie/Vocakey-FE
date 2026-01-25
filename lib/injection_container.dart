import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'features/pitch/data/datasources/pitch_remote_datasource.dart';
import 'features/pitch/data/repositories/pitch_repository_impl.dart';
import 'features/pitch/domain/repositories/pitch_repository.dart';
import 'features/pitch/domain/usecases/analyze_audio.dart';
import 'features/pitch/presentation/bloc/pitch_bloc.dart';
import 'features/home/presentation/bloc/home_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ===== BLoC =====
  sl.registerFactory(
    () => PitchBloc(analyzeAudio: sl()),
  );
  
  sl.registerFactory(
    () => HomeBloc(),
  );
  
  // ===== Use Cases =====
  sl.registerLazySingleton(() => AnalyzeAudio(sl()));
  
  // ===== Repository =====
  // ✅ FIXED: Gunakan positional parameter
  sl.registerLazySingleton<PitchRepository>(
    () => PitchRepositoryImpl(sl()),  // positional, bukan named
  );
  
  // ===== Data Sources =====
  sl.registerLazySingleton<PitchRemoteDatasource>(
    () => PitchRemoteDatasourceImpl(sl()),
  );
  
  // ===== Core =====
  // ✅ FIXED: Pass Dio instance ke ApiClient
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));
  
  // ===== External =====
  // Register Dio PERTAMA sebelum ApiClient
  sl.registerLazySingleton(() => Dio());
  
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
