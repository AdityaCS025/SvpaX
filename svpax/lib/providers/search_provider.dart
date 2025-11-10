import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchResult {
  final String title;
  final String link;
  final String snippet;

  SearchResult({
    required this.title,
    required this.link,
    required this.snippet,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      snippet: json['snippet'] ?? '',
    );
  }
}

class SearchProvider with ChangeNotifier {
  SearchProvider();

  final String _baseUrl = 'http://localhost:5001';
  List<SearchResult> _results = [];
  bool _isLoading = false;
  String? _error;

  List<SearchResult> get results => List.unmodifiable(_results);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _results = [];
      _error = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$_baseUrl/search?q=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'] is List) {
          _results = (data['items'] as List)
              .map((item) => SearchResult.fromJson(item))
              .toList();
        } else {
          _results = [];
        }
      } else {
        throw Exception('Failed to search: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
