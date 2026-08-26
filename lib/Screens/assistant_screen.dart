import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../Config/theme.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({Key? key}) : super(key: key);

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  final List<String> _quickSuggestions = [
    "Taxi to Mukono",
    "Sente mmeka?",
    "Which taxi has space?",
    "Book me a seat",
  ];

  @override
  void initState() {
    super.initState();
    _addMessage(
      "Hello! I am SmartStage Assistant. How can I help you today?",
      false,
    );
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: isUser));
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _addMessage(text, true);
    _controller.clear();

    setState(() {
      _isTyping = true;
    });

    try {
      final callable =
      FirebaseFunctions.instance.httpsCallable('smartAssistant');
      final result = await callable.call({
        'question': text,
      });

      final data = result.data as Map<String, dynamic>;
      final answer = data['answer'] as String? ?? "Sorry, I could not answer.";

      _addMessage(answer, false);
    } catch (e) {
      _addMessage("Sorry, the assistant is unavailable right now.", false);
    }

    setState(() {
      _isTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? SmartStageColors.darkBackground
          : SmartStageColors.lightBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B2FF7), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7B2FF7).withOpacity(0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFFFFB800),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SmartStage Assistant',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7B2FF7),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: isDark
            ? SmartStageColors.deepNavy
            : SmartStageColors.deepNavy,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return const _TypingIndicator();
                }

                final message = _messages[index];
                return _MessageBubble(message: message);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? SmartStageColors.navyCard
                  : SmartStageColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _quickSuggestions.map((suggestion) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => _sendMessage(suggestion),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? SmartStageColors.navyLight
                                  : SmartStageColors.greyLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF7B2FF7).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              suggestion,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7B2FF7),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Ask me anything...',
                          filled: true,
                          fillColor: isDark
                              ? SmartStageColors.navyLight
                              : SmartStageColors.greyLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _sendMessage(_controller.text),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7B2FF7), Color(0xFF1E3A8A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7B2FF7).withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Color(0xFFFFB800),
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
      message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          gradient: message.isUser
              ? const LinearGradient(
            colors: [Color(0xFFFFB800), Color(0xFFFFD54F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [
              const Color(0xFF7B2FF7).withOpacity(0.2),
              const Color(0xFF1E3A8A).withOpacity(0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(message.isUser ? 20 : 5),
            bottomRight: Radius.circular(message.isUser ? 5 : 20),
          ),
          border: Border.all(
            color: message.isUser
                ? SmartStageColors.gold.withOpacity(0.5)
                : const Color(0xFF7B2FF7).withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: (message.isUser
                  ? SmartStageColors.gold
                  : const Color(0xFF7B2FF7))
                  .withOpacity(0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: message.isUser
                ? SmartStageColors.deepNavy
                : (Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : SmartStageColors.deepNavy),
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF7B2FF7).withOpacity(0.2),
              const Color(0xFF1E3A8A).withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF7B2FF7).withOpacity(0.3),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Typing',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF7B2FF7),
              ),
            ),
            SizedBox(width: 8),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF7B2FF7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}