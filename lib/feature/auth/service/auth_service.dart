import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/storage/token_storage.dart';

class AuthService {

  // Register
  Future<String> register(String username, String email,
      String password, String confirmPassword) async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await TokenStorage.saveUserInfo(data);
      return 'success';
    } else {
      return data['message'] ?? 'Something went wrong!';
    }
  }

  // Login
  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await TokenStorage.saveUserInfo(data);
      return 'success';
    } else {
      return data['message'] ?? 'Something went wrong!';
    }
  }
}