import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';

abstract class HomeLocalDatasource {
  Future<String?> getRecentNote();
  Future<void> saveRecentNote(String note);
}

class HomeLocalDatasourceImpl implements HomeLocalDatasource {
  final SharedPreferences sharedPreferences;
  static const String recentNoteKey = 'RECENT_NOTE';

  HomeLocalDatasourceImpl(this.sharedPreferences);

  @override
  Future<String?> getRecentNote() async {
    try {
      return sharedPreferences.getString(recentNoteKey);
    } catch (e) {
      throw CacheException('Failed to get recent note');
    }
  }

  @override
  Future<void> saveRecentNote(String note) async {
    try {
      await sharedPreferences.setString(recentNoteKey, note);
    } catch (e) {
      throw CacheException('Failed to save recent note');
    }
  }
}
