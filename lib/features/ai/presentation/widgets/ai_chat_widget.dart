import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Removed unused import

/// AI Chat Widget
class AIChatWidget extends ConsumerStatefulWidget {
  const AIChatWidget({super.key});

  @override
  ConsumerState<AIChatWidget> createState() => _AIChatWidgetState();
}

class _AIChatWidgetState extends ConsumerState<AIChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  // Removed unused field
  // Removed unused field
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // Start chat session
    // Note: Session management is handled by the provider
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chat messages
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return _buildMessageBubble(message);
            },
          ),
        ),

        // Message input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['role'] == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? Colors.deepPurple : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['content'] as String,
              style: TextStyle(color: isUser ? Colors.white : Colors.black87),
            ),
            if (message['metadata'] != null &&
                message['metadata']['suggestions'] != null)
              _buildSuggestions(
                message['metadata']['suggestions'] as List<String>,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions(List<String> suggestions) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: suggestions.map((suggestion) {
          return GestureDetector(
            onTap: () {
              _messageController.text = suggestion;
              _sendMessage();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Text(
                suggestion,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Send message by updating session
    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': message,
        'role': 'user',
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
    _messageController.clear();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Note: ScrollController removed, scroll handling simplified
    });
  }
}
