import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static const String _keyLastAnalysis = 'last_analysis';
  static const String _keyAnalysisHistory = 'analysis_history';
  
  // Save latest analysis result
  static Future<void> saveLastAnalysis({
    required String note,
    required String vocalRange,
    required double accuracy,
    required String? vocalType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    final data = {
      'note': note,
      'vocal_range': vocalRange,
      'accuracy': accuracy,
      'vocal_type': vocalType,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await prefs.setString(_keyLastAnalysis, jsonEncode(data));
  }
  
  // Get latest analysis result
  static Future<Map<String, dynamic>?> getLastAnalysis() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_keyLastAnalysis);
    
    if (dataString == null) return null;
    
    try {
      return jsonDecode(dataString) as Map<String, dynamic>;
    } catch (e) {
      print('Error decoding last analysis: $e');
      return null;
    }
  }
  
  // Save to history (multiple results)
  static Future<void> addToHistory({
    required String note,
    required String vocalRange,
    required double accuracy,
    required String? vocalType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing history
    final historyString = prefs.getString(_keyAnalysisHistory);
    List<Map<String, dynamic>> history = [];
    
    if (historyString != null) {
      try {
        history = List<Map<String, dynamic>>.from(jsonDecode(historyString));
      } catch (e) {
        print('Error decoding history: $e');
      }
    }
    
    // Add new entry
    history.insert(0, {
      'note': note,
      'vocal_range': vocalRange,
      'accuracy': accuracy,
      'vocal_type': vocalType,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Keep only last 10 entries
    if (history.length > 10) {
      history = history.sublist(0, 10);
    }
    
    // Save back to storage
    await prefs.setString(_keyAnalysisHistory, jsonEncode(history));
  }
  
  // Get history
  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString(_keyAnalysisHistory);
    
    if (historyString == null) return [];
    
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(historyString));
    } catch (e) {
      print('Error decoding history: $e');
      return [];
    }
  }
  
  // Clear all data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastAnalysis);
    await prefs.remove(_keyAnalysisHistory);
  }
}
