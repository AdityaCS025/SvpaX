import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatProvider with ChangeNotifier {
  // Frontend is running on port 3000, backend on 5001
  final String _baseUrl = 'http://localhost:5001'; // Backend URL
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, String>> get messages => [..._messages];
  bool get isLoading => _isLoading;
  String? get error => _error;

  void addUserMessage(String message) {
    _messages.add({'role': 'user', 'content': message});
    notifyListeners();
  }

  void addAssistantMessage(String message) {
    _messages.add({'role': 'assistant', 'content': message});
    notifyListeners();
  }

  Future<void> sendMessage(String message) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Add user message immediately
      addUserMessage(message);

      print('Sending message to backend URL: $_baseUrl/chat');
      print('Message content: $message');

      final uri = Uri.parse('$_baseUrl/chat');
      print('Request URI: $uri');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Connection': 'keep-alive',
        },
        body: json.encode({'message': message}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response'] != null) {
          addAssistantMessage(data['response'].toString());
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final error = json.decode(response.body)['error'] ?? 'Unknown error';
        throw Exception('Server error: $error');
      }
    } catch (e) {
      _error = e.toString();
      print('Chat error: $_error');
      addAssistantMessage('Error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }
}
