import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CalendarProvider with ChangeNotifier {
  final String _baseUrl = 'http://localhost:5001';
  List<CalendarEvent> _events = [];
  bool _isLoading = false;
  String? _error;
  bool _isGoogleCalendarConnected = false;

  List<CalendarEvent> get events => List.unmodifiable(_events);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isGoogleCalendarConnected => _isGoogleCalendarConnected;

  Future<dynamic> getGoogleAuthUrl() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/calendar/auth'));
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to get Google Calendar auth URL');
    }
  }

  Future<void> checkGoogleCalendarConnection() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/calendar/status'));
      final data = json.decode(response.body);
      _isGoogleCalendarConnected = data['connected'] ?? false;
      notifyListeners();
    } catch (e) {
      _isGoogleCalendarConnected = false;
      notifyListeners();
    }
  }

  Future<void> fetchEvents({DateTime? start, DateTime? end}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      var uri = Uri.parse('$_baseUrl/calendar/events').replace(
        queryParameters: {
          if (start != null) 'start': start.toIso8601String(),
          if (end != null) 'end': end.toIso8601String(),
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _events = data.map((event) => CalendarEvent.fromJson(event)).toList();
      } else {
        throw Exception('Failed to load calendar events');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchEventsByDate(DateTime date) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final formattedDate = date.toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse('$_baseUrl/calendar/events/$formattedDate'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _events = [
          ...(data['reminders'] as List).map(
            (r) => CalendarEvent.fromReminder(r),
          ),
          ...(data['todos'] as List).map((t) => CalendarEvent.fromTodo(t)),
        ];
      } else {
        throw Exception('Failed to load events for date');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class CalendarEvent {
  final String id;
  final String title;
  final String? description;
  final DateTime start;
  final DateTime? end;
  final String type; // 'reminder' or 'todo'
  final String priority;
  final bool completed;

  CalendarEvent({
    required this.id,
    required this.title,
    this.description,
    required this.start,
    this.end,
    required this.type,
    this.priority = 'medium',
    this.completed = false,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      start: DateTime.parse(json['start']),
      end: json['end'] != null ? DateTime.parse(json['end']) : null,
      type: json['type'],
      priority: json['priority'] ?? 'medium',
      completed: json['completed'] ?? false,
    );
  }

  factory CalendarEvent.fromReminder(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      start: DateTime.parse(json['dateTime']),
      type: 'reminder',
      priority: json['priority'] ?? 'medium',
      completed: json['completed'] ?? false,
    );
  }

  factory CalendarEvent.fromTodo(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      start: DateTime.parse(json['dueDate']),
      type: 'todo',
      priority: json['priority'] ?? 'medium',
      completed: json['completed'] ?? false,
    );
  }
}
