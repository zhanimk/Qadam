import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qadam/theme/app_theme.dart';

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({Key? key}) : super(key: key);

  @override
  _AICoachScreenState createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      "sender": "ai",
      "text": "Hello! I'm your personal AI coach. How can I help you achieve your goals today?"
    },
  ];

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    setState(() {
      _messages.add({
        "sender": "user",
        "text": _controller.text,
      });
      // TODO: Replace with actual AI response
      _messages.add({
        "sender": "ai",
        "text": "That's a great goal! Let's break it down. What's the first step you can take?",
      });
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080812),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("AI Coach", style: AppTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final bool isUserMessage = message['sender'] == 'user';
                return _buildMessageBubble(message['text']!, isUserMessage);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUserMessage) {
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isUserMessage ? AppTheme.primary : AppTheme.surface.withAlpha(50),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(color: isUserMessage ? Colors.white : AppTheme.onSurface),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppTheme.surface.withAlpha(50),
            border: Border(top: BorderSide(color: Colors.white.withAlpha(26))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: AppTheme.onSurface),
                  decoration: InputDecoration(
                    hintText: "Ask your coach anything...",
                    hintStyle: TextStyle(color: AppTheme.mutedForeground),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.send, color: AppTheme.accent),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
