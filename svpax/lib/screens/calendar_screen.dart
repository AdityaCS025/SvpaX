import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/calendar_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CalendarProvider>(context, listen: false);
      provider.checkGoogleCalendarConnection();
      _fetchEvents();
    });
  }

  void _fetchEvents() {
    Provider.of<CalendarProvider>(
      context,
      listen: false,
    ).fetchEventsByDate(_selectedDay);
  }

  Future<void> _connectGoogleCalendar() async {
    try {
      final calendarProvider = Provider.of<CalendarProvider>(
        context,
        listen: false,
      );
      final response = await calendarProvider.getGoogleAuthUrl();
      if (response != null && response["url"] != null) {
        final url = Uri.parse(response["url"]);
        if (await canLaunchUrl(url)) {
          // Use platformDefault mode for web OAuth flow
          await launchUrl(
            url,
            mode: LaunchMode.platformDefault,
            webOnlyWindowName: '_self', // Force same window for OAuth
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Could not launch URL")),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    }
  }

  Widget _buildEventIcon(CalendarEvent event) {
    late IconData iconData;
    late Color iconColor;

    switch (event.type) {
      case "reminder":
        iconData = Icons.alarm;
        iconColor = Colors.red;
        break;
      case "todo":
        iconData = Icons.check_box_outlined;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.calendar_today;
        iconColor = Colors.green;
    }

    return Icon(
      event.completed ? Icons.check_circle : iconData,
      color: event.completed ? Colors.grey : iconColor,
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      case "low":
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar"),
        actions: [
          Consumer<CalendarProvider>(
            builder: (context, provider, _) => IconButton(
              icon: Icon(
                provider.isGoogleCalendarConnected
                    ? Icons.cloud_done
                    : Icons.cloud_off,
              ),
              onPressed: provider.isGoogleCalendarConnected
                  ? null
                  : _connectGoogleCalendar,
              tooltip: provider.isGoogleCalendarConnected
                  ? "Connected to Google Calendar"
                  : "Connect Google Calendar",
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchEvents,
            tooltip: "Refresh Events",
          ),
        ],
      ),
      body: Consumer<CalendarProvider>(
        builder: (context, calendarProvider, child) {
          if (calendarProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (calendarProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Error: ${calendarProvider.error}",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _fetchEvents,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _fetchEvents();
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                  _fetchEvents();
                },
                eventLoader: (day) {
                  return calendarProvider.events
                      .where((event) => isSameDay(event.start, day))
                      .toList();
                },
                calendarStyle: const CalendarStyle(
                  weekendTextStyle: TextStyle(color: Colors.red),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: calendarProvider.events
                      .where((event) => isSameDay(event.start, _selectedDay))
                      .length,
                  itemBuilder: (context, index) {
                    final events = calendarProvider.events
                        .where((event) => isSameDay(event.start, _selectedDay))
                        .toList();
                    final event = events[index];

                    final time =
                        "${event.start.hour.toString().padLeft(2, "0")}:${event.start.minute.toString().padLeft(2, "0")}";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: _buildEventIcon(event),
                        title: Text(
                          event.title,
                          style: TextStyle(
                            decoration: event.completed
                                ? TextDecoration.lineThrough
                                : null,
                            color: event.completed ? Colors.grey : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (event.description != null &&
                                event.description!.isNotEmpty)
                              Text(
                                event.description!,
                                style: TextStyle(
                                  color: event.completed
                                      ? Colors.grey
                                      : Colors.grey[600],
                                ),
                              ),
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: 12,
                                color: event.completed
                                    ? Colors.grey
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: event.completed
                                ? Colors.grey[200]
                                : _getPriorityColor(
                                    event.priority,
                                  ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            event.priority.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: event.completed
                                  ? Colors.grey
                                  : _getPriorityColor(event.priority),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
