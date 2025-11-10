import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);

    // Fetch reminders when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (reminderProvider.reminders.isEmpty && !reminderProvider.isLoading) {
        reminderProvider.fetchReminders();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders & Alarms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => reminderProvider.fetchReminders(),
          ),
        ],
      ),
      body: reminderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : reminderProvider.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${reminderProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () => reminderProvider.fetchReminders(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : reminderProvider.reminders.isEmpty
          ? const Center(
              child: Text('No reminders yet. Add one to get started!'),
            )
          : ListView.builder(
              itemCount: reminderProvider.reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminderProvider.reminders[index];
                return ListTile(
                  title: Text(reminder.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reminder.description ?? ''),
                      Text(
                        'Due: ${reminder.dateTime.toString()}',
                        style: TextStyle(
                          color: reminder.dateTime.isBefore(DateTime.now())
                              ? Colors.red
                              : null,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // TODO: Show edit dialog
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          reminderProvider.deleteReminder(reminder.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final titleController = TextEditingController();
          final descriptionController = TextEditingController();
          DateTime selectedDate = DateTime.now();
          TimeOfDay selectedTime = TimeOfDay.now();
          String selectedPriority = 'medium';
          String selectedRepeat = 'none';

          showDialog(
            context: context,
            builder: (context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: const Text('Add Reminder'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Date'),
                        subtitle: Text(selectedDate.toString().split(' ')[0]),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setState(
                              () => selectedDate = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                selectedTime.hour,
                                selectedTime.minute,
                              ),
                            );
                          }
                        },
                      ),
                      ListTile(
                        title: const Text('Time'),
                        subtitle: Text(selectedTime.format(context)),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (time != null) {
                            setState(() {
                              selectedTime = time;
                              selectedDate = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                        ),
                        items: ['low', 'medium', 'high']
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(p.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => selectedPriority = value!);
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedRepeat,
                        decoration: const InputDecoration(labelText: 'Repeat'),
                        items: ['none', 'daily', 'weekly', 'monthly', 'yearly']
                            .map(
                              (r) => DropdownMenuItem(
                                value: r,
                                child: Text(r.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => selectedRepeat = value!);
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.trim().isNotEmpty) {
                        reminderProvider.addReminder(
                          titleController.text.trim(),
                          selectedDate,
                          description: descriptionController.text.trim(),
                          priority: selectedPriority,
                          repeat: selectedRepeat,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
