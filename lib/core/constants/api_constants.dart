class ApiConstants {
  static const String baseUrl = 'https://sharewave-backend-production.up.railway.app';
  
  static const String register = '$baseUrl/api/auth/register';
  static const String login = '$baseUrl/api/auth/login';
  static const String upload = '$baseUrl/api/transfer/upload';
  static const String receivedFiles = '$baseUrl/api/transfer/received-files';
  static const String download = '$baseUrl/api/transfer/download';
}