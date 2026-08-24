import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Config/theme.dart';
import '../Providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String otherUserName;

  const ChatScreen({
    Key? key,
    required this.chatId,
    required this.otherUserName,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(chatProvider.notifier).loadMessages(widget.chatId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    await ref.read(chatProvider.notifier).sendMessage(
      chatId: widget.chatId,
      content: content,
    );

    ref.read(chatProvider.notifier).loadMessages(widget.chatId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

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
                shape: BoxShape.circle,
                color: SmartStageColors.electricGreen,
                boxShadow: [
                  BoxShadow(
                    color: SmartStageColors.greenGlow,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: SmartStageColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 11,
                    color: SmartStageColors.electricGreen,
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
          // Messages
          Expanded(
            child: state.isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: SmartStageColors.electricGreen,
              ),
            )
                : state.currentMessages.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: isDark
                        ? SmartStageColors.greyDark
                        : SmartStageColors.greyLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Messages Yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? SmartStageColors.greyMid
                          : SmartStageColors.greyDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start the conversation',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? SmartStageColors.greyMid
                          : SmartStageColors.greyDark,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.currentMessages.length,
              itemBuilder: (context, index) {
                final message = state.currentMessages[index];
                final isMe = message.senderId == currentUserId;

                return _MessageBubble(
                  message: message.content,
                  isMe: isMe,
                  time: message.createdAt,
                );
              },
            ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? SmartStageColors.navyCard : SmartStageColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
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
                  onTap: _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: SmartStageColors.electricGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: SmartStageColors.greenGlow,
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send,
                      color: SmartStageColors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MESSAGE BUBBLE
// ============================================================
class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final DateTime time;

  const _MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe
              ? SmartStageColors.electricGreen
              : isDark
              ? SmartStageColors.navyCard
              : SmartStageColors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 5),
            bottomRight: Radius.circular(isMe ? 5 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isMe
                    ? SmartStageColors.deepNavy
                    : isDark
                    ? SmartStageColors.white
                    : SmartStageColors.deepNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                color: isMe
                    ? SmartStageColors.deepNavy.withOpacity(0.6)
                    : isDark
                    ? SmartStageColors.greyMid
                    : SmartStageColors.greyDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}