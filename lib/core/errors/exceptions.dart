class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class PermissionException implements Exception {
  final String message;
  PermissionException(this.message);
}

class RecordingException implements Exception {
  final String message;
  RecordingException(this.message);
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}
