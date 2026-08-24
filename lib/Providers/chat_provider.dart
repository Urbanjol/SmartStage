import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ============================================================
// CHAT STATE
// ============================================================
class ChatState {
  final bool isLoading;
  final bool isSending;
  final String? errorMessage;
  final List<ChatRoom> chatRooms;
  final List<ChatMessage> currentMessages;
  final String? currentChatId;

  const ChatState({
    this.isLoading = false,
    this.isSending = false,
    this.errorMessage,
    this.chatRooms = const [],
    this.currentMessages = const [],
    this.currentChatId,
  });

  ChatState copyWith({
    bool? isLoading,
    bool? isSending,
    String? errorMessage,
    List<ChatRoom>? chatRooms,
    List<ChatMessage>? currentMessages,
    String? currentChatId,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage ?? this.errorMessage,
      chatRooms: chatRooms ?? this.chatRooms,
      currentMessages: currentMessages ?? this.currentMessages,
      currentChatId: currentChatId ?? this.currentChatId,
    );
  }
}

// ============================================================
// MODELS
// ============================================================
class ChatRoom {
  final String chatId;
  final String bookingId;
  final String passengerId;
  final String driverId;
  final String lastMessage;
  final int passengerUnread;
  final int driverUnread;

  const ChatRoom({
    required this.chatId,
    required this.bookingId,
    required this.passengerId,
    required this.driverId,
    this.lastMessage = '',
    this.passengerUnread = 0,
    this.driverUnread = 0,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoom(
      chatId: id,
      bookingId: map['booking_id'] ?? '',
      passengerId: map['passenger_id'] ?? '',
      driverId: map['driver_id'] ?? '',
      lastMessage: map['last_message'] ?? '',
      passengerUnread: map['passenger_unread'] ?? 0,
      driverUnread: map['driver_unread'] ?? 0,
    );
  }
}

class ChatMessage {
  final String messageId;
  final String chatId;
  final String senderId;
  final String content;
  final String messageType;
  final bool read;
  final DateTime createdAt;

  const ChatMessage({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.content,
    this.messageType = 'text',
    this.read = false,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      messageId: id,
      chatId: map['chat_id'] ?? '',
      senderId: map['sender_id'] ?? '',
      content: map['content'] ?? '',
      messageType: map['message_type'] ?? 'text',
      read: map['read'] ?? false,
      createdAt: map['created_at'] != null
          ? (map['created_at'] as dynamic).toDate()
          : DateTime.now(),
    );
  }
}

// ============================================================
// PROVIDER
// ============================================================
final chatProvider = NotifierProvider<ChatNotifier, ChatState>(() {
  return ChatNotifier();
});

class ChatNotifier extends Notifier<ChatState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  ChatState build() {
    return const ChatState();
  }

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  // ============================================================
  // CREATE CHAT
  // ============================================================
  Future<String?> createChat({
    required String bookingId,
    required String passengerId,
    required String driverId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final callable = _functions.httpsCallable('createChat');
      final result = await callable.call({
        'booking_id': bookingId,
        'passenger_id': passengerId,
        'driver_id': driverId,
      });

      final data = result.data as Map<String, dynamic>;
      final chatId = data['chat_id'] as String?;

      state = state.copyWith(isLoading: false);
      return chatId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create chat: $e',
      );
      return null;
    }
  }

  // ============================================================
  // LOAD USER CHAT ROOMS
  // ============================================================
  Future<void> loadChatRooms() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final snapshot = await _firestore
          .collection('chats')
          .where('passenger_id', isEqualTo: _currentUserId)
          .orderBy('updated_at', descending: true)
          .get();

      final passengerChats = snapshot.docs
          .map((doc) => ChatRoom.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ))
          .toList();

      final driverSnapshot = await _firestore
          .collection('chats')
          .where('driver_id', isEqualTo: _currentUserId)
          .orderBy('updated_at', descending: true)
          .get();

      final driverChats = driverSnapshot.docs
          .map((doc) => ChatRoom.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ))
          .toList();

      final allChats = [...passengerChats, ...driverChats];

      state = state.copyWith(
        isLoading: false,
        chatRooms: allChats,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load chats: $e',
      );
    }
  }

  // ============================================================
  // LOAD MESSAGES
  // ============================================================
  Future<void> loadMessages(String chatId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final snapshot = await _firestore
          .collection('messages')
          .where('chat_id', isEqualTo: chatId)
          .orderBy('created_at')
          .get();

      final messages = snapshot.docs
          .map((doc) => ChatMessage.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ))
          .toList();

      state = state.copyWith(
        isLoading: false,
        currentMessages: messages,
        currentChatId: chatId,
      );

      // Mark as read
      await markMessagesRead(chatId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load messages: $e',
      );
    }
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================
  Future<bool> sendMessage({
    required String chatId,
    required String content,
  }) async {
    state = state.copyWith(isSending: true, errorMessage: null);

    try {
      final callable = _functions.httpsCallable('sendMessage');
      await callable.call({
        'chat_id': chatId,
        'sender_id': _currentUserId,
        'content': content,
      });

      state = state.copyWith(isSending: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: 'Failed to send message: $e',
      );
      return false;
    }
  }

  // ============================================================
  // MARK MESSAGES READ
  // ============================================================
  Future<void> markMessagesRead(String chatId) async {
    try {
      final callable = _functions.httpsCallable('markMessagesRead');
      await callable.call({
        'chat_id': chatId,
        'user_id': _currentUserId,
      });
    } catch (e) {
      // Silently fail
    }
  }
}