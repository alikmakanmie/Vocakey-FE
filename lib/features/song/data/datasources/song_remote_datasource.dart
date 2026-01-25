import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/song_model.dart';

abstract class SongRemoteDatasource {
  Future<List<SongModel>> getPopularSongs({int limit = 20, String category = 'trending'});
}

class SongRemoteDatasourceImpl implements SongRemoteDatasource {
  final Dio dio;

  SongRemoteDatasourceImpl(this.dio);

  @override
  Future<List<SongModel>> getPopularSongs({
    int limit = 20,
    String category = 'trending',
  }) async {
    try {
      print('📋 Fetching songs from API...');
      
      final response = await dio.get(
        ApiConstants.getSongsUrl,
        queryParameters: {
          'limit': limit,
          'category': category,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final songsJson = data['songs'] as List;
        
        final songs = songsJson
            .map((json) => SongModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        print('✅ Fetched ${songs.length} songs from API');
        return songs;
      } else {
        throw ServerException('Failed to load songs');
      }
    } on DioException catch (e) {
      print('❌ Network error: ${e.message}');
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      print('❌ Error: $e');
      throw ServerException(e.toString());
    }
  }
}
