import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TodoProvider extends ChangeNotifier {
  final String _baseUrl = 'http://localhost:5001';
  List<TodoItem> _todos = [];
  bool _isLoading = false;
  String? _error;

  List<TodoItem> get todos => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTodos() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.get(Uri.parse('$_baseUrl/todos'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _todos = data.map((todo) => TodoItem.fromJson(todo)).toList();
      } else {
        throw Exception('Failed to load todos');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo(
    String title, {
    String? description,
    DateTime? dueDate,
    String priority = 'medium',
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$_baseUrl/todos'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'description': description,
          'dueDate': dueDate?.toIso8601String(),
          'priority': priority,
        }),
      );

      if (response.statusCode == 201) {
        await fetchTodos();
      } else {
        throw Exception('Failed to add todo');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTodo(String id, bool completed) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.put(
        Uri.parse('$_baseUrl/todos/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'completed': completed}),
      );

      if (response.statusCode == 200) {
        await fetchTodos();
      } else {
        throw Exception('Failed to update todo');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.delete(Uri.parse('$_baseUrl/todos/$id'));

      if (response.statusCode == 200) {
        await fetchTodos();
      } else {
        throw Exception('Failed to delete todo');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class TodoItem {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String priority;
  bool completed;

  TodoItem({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 'medium',
    this.completed = false,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      priority: json['priority'] ?? 'medium',
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'completed': completed,
    };
  }
}
