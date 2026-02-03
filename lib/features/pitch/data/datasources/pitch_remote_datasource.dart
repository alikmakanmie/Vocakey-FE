import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/analysis_model.dart';

abstract class PitchRemoteDatasource {
  Future<AnalysisModel> analyzeAudio(String audioPath);  // ✅ Kembali ke AnalysisModel
}

class PitchRemoteDatasourceImpl implements PitchRemoteDatasource {
  final ApiClient apiClient;

  PitchRemoteDatasourceImpl(this.apiClient);

  @override
  Future<AnalysisModel> analyzeAudio(String audioPath) async {
    try {
      print('📤 Uploading audio: $audioPath');
      
      final response = await apiClient.uploadAudio(
        ApiConstants.analyzeEndpoint,
        audioPath,
      );

      print('=== BACKEND RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('========================');

      if (response.statusCode == 200) {
        // ✅ Langsung parse ke AnalysisModel
        // Backend akan return recommendations: [] jika tidak ada match
        final analysisResult = AnalysisModel.fromJson(response.data);
        print('✅ Analysis successful with ${analysisResult.recommendations.length} recommendations');

        return analysisResult;
      } else {
        throw ServerException('Failed to analyze: Status ${response.statusCode}');
      }
      
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');

      // Better error handling
      if (e.response?.statusCode == 422 || e.response?.statusCode == 400) {
        final errorData = e.response?.data;

        if (errorData != null && errorData is Map) {
          final errorCode = errorData['error_code'];
          final errorMessage = errorData['error'] ?? 'Unknown error';

          if (errorCode == 'AUDIO_QUALITY') {
            throw ServerException('Suara tidak terdeteksi dengan jelas. Coba humming lebih keras dan jelas.');
          } else if (errorCode == 'NO_PITCH') {
            throw ServerException('Suara/humming Anda tidak terdeteksi. Pastikan Anda bersenandung dengan nada yang jelas dan konsisten.');
          }

          // Generic 422/400 error - likely pitch detection failed
          throw ServerException('Suara tidak terdeteksi. Coba humming dengan nada yang lebih jelas dan konsisten.');
        }
      }

      throw ServerException('Network error: ${e.message}');
      
    } catch (e) {
      print('❌ Error in analyzeAudio: $e');
      throw ServerException(e.toString());
    }
  }
}
