import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:library_management_frontend/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:5000';
  final _storage = FlutterSecureStorage();

  // Store token after login
  Future<void> storeToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  // Retrieve the stored token
  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<User> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      throw 'Username and password cannot be empty';
    }
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      //return User.fromJson(json.decode(response.body));
      // On successful login, store the token
      final Map<String, dynamic> data = json.decode(response.body);
      await storeToken(data['accessToken']); // Save token
      return User.fromJson(data);
    } else {
      throw Exception('Failed to login');
    }
  }

  // Save user data (for example, user object)
  Future<void> saveUserData(User user) async {
    await _storage.write(key: 'username', value: user.username);
    await _storage.write(key: 'role', value: user.role);
    await _storage.write(key: 'id', value: user.id);
  }

  // Retrieve user data
  Future<User> getUserData() async {
    String? username = await _storage.read(key: 'username');
    String? role = await _storage.read(key: 'role');
    String? id = await _storage.read(key: 'id');
    return User(username: username ?? '', role: role ?? '', id: id ?? '');
  }


  // Logout function
  Future<void> logout() async {
    // Clear the stored token
    //await _storage.delete(key: 'access_token');
    await _storage.deleteAll();
  }

  // user is logged in Status
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }

  Future<Map<String, dynamic>> register(String username, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password, 'role': role}),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body); 
    } else {
      throw Exception('Registration failed');
    }
  }
}
