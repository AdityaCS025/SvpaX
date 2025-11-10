import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/speech_provider.dart';

class SpeechAssistantScreen extends StatefulWidget {
  const SpeechAssistantScreen({super.key});

  @override
  State<SpeechAssistantScreen> createState() => _SpeechAssistantScreenState();
}

class _SpeechAssistantScreenState extends State<SpeechAssistantScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Assistant"),
        backgroundColor: const Color(0xFF7C83FD),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<SpeechProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.isSpeechSupported ? Icons.mic : Icons.mic_off,
                ),
                onPressed: provider.isSpeechSupported
                    ? null
                    : () => _showUnsupportedDialog(context),
                tooltip: provider.isSpeechSupported
                    ? "Speech supported"
                    : "Speech not supported",
              );
            },
          ),
          Consumer<SpeechProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.soundEnabled ? Icons.volume_up : Icons.volume_off,
                ),
                onPressed: () {
                  Provider.of<SpeechProvider>(
                    context,
                    listen: false,
                  ).toggleSound();
                },
                tooltip: provider.soundEnabled
                    ? "Sound enabled - click to mute"
                    : "Sound disabled - click to unmute",
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              Provider.of<SpeechProvider>(
                context,
                listen: false,
              ).clearConversation();
            },
            tooltip: "Clear conversation",
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7C83FD), Color(0xFFB5FFD9)],
          ),
        ),
        child: Column(
          children: [
            Expanded(child: _buildConversationList()),
            _buildControlPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationList() {
    return Consumer<SpeechProvider>(
      builder: (context, provider, child) {
        if (provider.conversation.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  "Start a conversation with your AI assistant",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.isSpeechSupported
                      ? "Tap the microphone to speak or type a message"
                      : "Speech not supported - you can type messages",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.conversation.length,
          itemBuilder: (context, index) {
            final message = provider.conversation[index];
            return _buildMessageBubble(message);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(SpeechMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.smart_toy, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Colors.white.withOpacity(0.9)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.black87 : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(
                          color: message.isUser
                              ? Colors.black54
                              : Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      if (!message.isUser) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _speakMessage(message.text),
                          child: Icon(
                            Icons.volume_up,
                            size: 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIndicator(),
          const SizedBox(height: 16),
          _buildVoiceControls(),
          const SizedBox(height: 16),
          _buildTextInput(),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Consumer<SpeechProvider>(
      builder: (context, provider, child) {
        if (provider.error != null) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }

        String status = "Ready";
        Color statusColor = Colors.green;
        IconData statusIcon = Icons.check_circle;

        if (provider.isListening) {
          status = "Listening...";
          statusColor = Colors.blue;
          statusIcon = Icons.mic;
        } else if (provider.isProcessing) {
          status = "Processing...";
          statusColor = Colors.orange;
          statusIcon = Icons.psychology;
        } else if (provider.isSpeaking) {
          status = "Speaking...";
          statusColor = Colors.purple;
          statusIcon = Icons.volume_up;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, color: statusColor, size: 16),
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoiceControls() {
    return Consumer<SpeechProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Voice input button
            AnimatedBuilder(
              animation: provider.isListening
                  ? _pulseAnimation
                  : _waveAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: provider.isListening ? _pulseAnimation.value : 1.0,
                  child: GestureDetector(
                    onTap: provider.isSpeechSupported && !provider.isActive
                        ? () => provider.startListening()
                        : provider.isListening
                        ? () => provider.stopListening()
                        : null,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: provider.isListening
                            ? Colors.red.withOpacity(0.8)
                            : provider.isSpeechSupported
                            ? Colors.white.withOpacity(0.9)
                            : Colors.grey.withOpacity(0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        provider.isListening ? Icons.stop : Icons.mic,
                        size: 36,
                        color: provider.isListening
                            ? Colors.white
                            : provider.isSpeechSupported
                            ? const Color(0xFF7C83FD)
                            : Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Stop speaking button
            GestureDetector(
              onTap: provider.isSpeaking ? () => provider.stopSpeaking() : null,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: provider.isSpeaking
                      ? Colors.orange.withOpacity(0.8)
                      : Colors.white.withOpacity(0.3),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.stop,
                  size: 28,
                  color: provider.isSpeaking ? Colors.white : Colors.white70,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextInput() {
    return Consumer<SpeechProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (text) => _sendTextMessage(text),
                  enabled: !provider.isActive,
                ),
              ),
              IconButton(
                onPressed: provider.isActive
                    ? null
                    : () => _sendTextMessage(_textController.text),
                icon: Icon(
                  Icons.send,
                  color: provider.isActive
                      ? Colors.grey
                      : const Color(0xFF7C83FD),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendTextMessage(String text) {
    if (text.trim().isEmpty) return;

    Provider.of<SpeechProvider>(
      context,
      listen: false,
    ).sendTextMessage(text.trim());
    _textController.clear();
  }

  void _speakMessage(String text) {
    Provider.of<SpeechProvider>(context, listen: false).speakText(text);
  }

  void _showUnsupportedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Speech Not Supported"),
        content: const Text(
          "Speech recognition is not supported in this browser. "
          "Please use Chrome or Edge for the best experience. "
          "You can still use text messaging.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
