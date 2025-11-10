import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReminderProvider extends ChangeNotifier {
  final String _baseUrl = 'http://localhost:5001';
  List<Reminder> _reminders = [];
  bool _isLoading = false;
  String? _error;

  List<Reminder> get reminders => List.unmodifiable(_reminders);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchReminders() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.get(Uri.parse('$_baseUrl/reminders'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _reminders = data
            .map((reminder) => Reminder.fromJson(reminder))
            .toList();
      } else {
        throw Exception('Failed to load reminders');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReminder(
    String title,
    DateTime dateTime, {
    String? description,
    String repeat = 'none',
    String priority = 'medium',
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$_baseUrl/reminders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'description': description,
          'dateTime': dateTime.toIso8601String(),
          'repeat': repeat,
          'priority': priority,
        }),
      );

      if (response.statusCode == 201) {
        await fetchReminders();
      } else {
        throw Exception('Failed to add reminder');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateReminder(String id, Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.put(
        Uri.parse('$_baseUrl/reminders/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        await fetchReminders();
      } else {
        throw Exception('Failed to update reminder');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.delete(Uri.parse('$_baseUrl/reminders/$id'));

      if (response.statusCode == 200) {
        await fetchReminders();
      } else {
        throw Exception('Failed to delete reminder');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class Reminder {
  final String id;
  final String title;
  final String? description;
  final DateTime dateTime;
  final String repeat;
  final String priority;
  bool completed;

  Reminder({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    this.repeat = 'none',
    this.priority = 'medium',
    this.completed = false,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      dateTime: DateTime.parse(json['dateTime']),
      repeat: json['repeat'] ?? 'none',
      priority: json['priority'] ?? 'medium',
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'repeat': repeat,
      'priority': priority,
      'completed': completed,
    };
  }
}
