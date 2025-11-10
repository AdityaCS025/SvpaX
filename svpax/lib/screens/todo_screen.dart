import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);

    // Fetch todos when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (todoProvider.todos.isEmpty && !todoProvider.isLoading) {
        todoProvider.fetchTodos();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => todoProvider.fetchTodos(),
          ),
        ],
      ),
      body: todoProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : todoProvider.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${todoProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () => todoProvider.fetchTodos(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : todoProvider.todos.isEmpty
          ? const Center(child: Text('No todos yet. Add one to get started!'))
          : ListView.builder(
              itemCount: todoProvider.todos.length,
              itemBuilder: (context, index) {
                final todo = todoProvider.todos[index];
                return CheckboxListTile(
                  value: todo.completed,
                  title: Text(todo.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (todo.description?.isNotEmpty ?? false)
                        Text(todo.description!),
                      if (todo.dueDate != null)
                        Text(
                          'Due: ${todo.dueDate.toString()}',
                          style: TextStyle(
                            color: todo.dueDate!.isBefore(DateTime.now())
                                ? Colors.red
                                : null,
                          ),
                        ),
                    ],
                  ),
                  onChanged: (bool? value) =>
                      todoProvider.toggleTodo(todo.id, value ?? false),
                  secondary: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => todoProvider.deleteTodo(todo.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final titleController = TextEditingController();
          final descriptionController = TextEditingController();
          DateTime? selectedDueDate;
          String selectedPriority = 'medium';

          showDialog(
            context: context,
            builder: (context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: const Text('Add Task'),
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
                        title: const Text('Due Date'),
                        subtitle: Text(
                          selectedDueDate?.toString().split(' ')[0] ??
                              'No due date',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (selectedDueDate != null)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() => selectedDueDate = null);
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      selectedDueDate ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (date != null) {
                                  setState(() => selectedDueDate = date);
                                }
                              },
                            ),
                          ],
                        ),
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
                        todoProvider.addTodo(
                          titleController.text.trim(),
                          description: descriptionController.text.trim(),
                          dueDate: selectedDueDate,
                          priority: selectedPriority,
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
