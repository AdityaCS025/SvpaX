import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'test_screen.dart';
import 'speech_assistant_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final TextEditingController controller = TextEditingController();

    void _navigateToTest() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TestScreen()),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF7C83FD), Color(0xFFFFC7C7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _navigateToTest(),
                  child: const Text('Test API'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Hello, how can I assist you today?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C83FD),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                final msg = chatProvider.messages.reversed.toList()[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFFFFC7C7)
                          : const Color(0xFF7C83FD),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(24),
                        topRight: const Radius.circular(24),
                        bottomLeft: Radius.circular(isUser ? 24 : 8),
                        bottomRight: Radius.circular(isUser ? 8 : 24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg['content'] ?? '',
                      style: TextStyle(
                        color: isUser ? Color(0xFF232946) : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.mic, color: Color(0xFF7C83FD)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SpeechAssistantScreen(),
                      ),
                    );
                  },
                  tooltip: 'Voice Assistant',
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your query...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (controller.text.trim().isNotEmpty) {
                      final message = controller.text.trim();
                      controller.clear();
                      await chatProvider.sendMessage(message);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Color(0xFF7C83FD)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SpeechAssistantScreen(),
                      ),
                    );
                  },
                  tooltip: 'Voice Assistant',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
