import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  static const String _baseUrl = 'http://localhost:5001';

  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null && _token != null;

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        _error = data['error'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      _error = 'Connection failed. Please check if the server is running.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register(String name, String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('Attempting registration for: $email');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(Duration(seconds: 10));

      debugPrint('Registration response status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        _error = data['error'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      _error = 'Connection failed. Please check if the server is running.';
      _isLoading = false;
      notifyListeners();
      return false;
      _error = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  void logout() {
    _currentUser = null;
    _token = null;
    _error = null;
    notifyListeners();
  }

  // Get profile
  Future<void> getProfile() async {
    if (_token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentUser = User.fromJson(data['user']);
        notifyListeners();
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        logout();
      }
    } catch (e) {
      debugPrint('Error getting profile: $e');
    }
  }
}
