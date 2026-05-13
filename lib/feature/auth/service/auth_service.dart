import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/storage/token_storage.dart';

class AuthService {

  // Register
  Future<String> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await TokenStorage.saveToken(data['token']);
      return 'success';
    } else {
      return data.toString();
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
      await TokenStorage.saveToken(data['token']);
      return 'success';
    } else {
      return data.toString();
    }
  }
}