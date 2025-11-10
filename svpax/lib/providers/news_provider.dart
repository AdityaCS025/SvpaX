import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsProvider with ChangeNotifier {
  final String _baseUrl = 'http://localhost:5001';
  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  String? _error;

  List<NewsArticle> get articles => List.unmodifiable(_articles);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getNewsHeadlines({
    String category = 'general',
    String country = 'us',
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/news/headlines?category=$category&country=$country',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _articles = (data['articles'] as List)
            .map((article) => NewsArticle.fromJson(article))
            .toList();
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchNews(
    String query, {
    String? from,
    String sortBy = 'publishedAt',
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      var uri = Uri.parse('$_baseUrl/news/search').replace(
        queryParameters: {
          'q': query,
          if (from != null) 'from': from,
          'sortBy': sortBy,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _articles = (data['articles'] as List)
            .map((article) => NewsArticle.fromJson(article))
            .toList();
      } else {
        throw Exception('Failed to search news');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class NewsArticle {
  final String title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? source;
  final String? author;
  final String? content;

  NewsArticle({
    required this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.source,
    this.author,
    this.content,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['description'],
      url: json['url'],
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'],
      source: json['source']?['name'],
      author: json['author'],
      content: json['content'],
    );
  }
}
