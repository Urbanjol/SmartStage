import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ============================================================
// NOTIFICATION STATE
// ============================================================
class NotificationState {
  final bool isLoading;
  final String? errorMessage;
  final List<AppNotification> notifications;
  final int unreadCount;

  const NotificationState({
    this.isLoading = false,
    this.errorMessage,
    this.notifications = const [],
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<AppNotification>? notifications,
    int? unreadCount,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

// ============================================================
// MODEL
// ============================================================
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String bookingId;
  final String chatId;
  final bool read;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.type = '',
    this.bookingId = '',
    this.chatId = '',
    this.read = false,
    required this.createdAt,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map, String id) {
    return AppNotification(
      id: id,
      userId: map['user_id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? '',
      bookingId: map['booking_id'] ?? '',
      chatId: map['chat_id'] ?? '',
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
final notificationProvider =
NotifierProvider<NotificationNotifier, NotificationState>(() {
  return NotificationNotifier();
});

class NotificationNotifier extends Notifier<NotificationState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  NotificationState build() {
    return const NotificationState();
  }

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  // ============================================================
  // LOAD NOTIFICATIONS
  // ============================================================
  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: _currentUserId)
          .orderBy('created_at')
          .get();

      final notifications = snapshot.docs
          .map((doc) => AppNotification.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ))
          .toList()
          .reversed
          .toList();

      final unread = notifications.where((n) => !n.read).length;

      state = state.copyWith(
        isLoading: false,
        notifications: notifications,
        unreadCount: unread,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load notifications: $e',
      );
    }
  }

  // ============================================================
  // MARK AS READ
  // ============================================================
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});

      // Update local state
      final updatedList = state.notifications.map((n) {
        if (n.id == notificationId) {
          return AppNotification(
            id: n.id,
            userId: n.userId,
            title: n.title,
            body: n.body,
            type: n.type,
            bookingId: n.bookingId,
            chatId: n.chatId,
            read: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();

      final unread = updatedList.where((n) => !n.read).length;

      state = state.copyWith(
        notifications: updatedList,
        unreadCount: unread,
      );
    } catch (e) {
      // Silently fail
    }
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================
  Future<void> markAllAsRead() async {
    try {
      final batch = _firestore.batch();
      final unread = state.notifications.where((n) => !n.read);

      for (final notification in unread) {
        batch.update(
          _firestore.collection('notifications').doc(notification.id),
          {'read': true},
        );
      }

      await batch.commit();

      final updatedList = state.notifications.map((n) {
        return AppNotification(
          id: n.id,
          userId: n.userId,
          title: n.title,
          body: n.body,
          type: n.type,
          bookingId: n.bookingId,
          chatId: n.chatId,
          read: true,
          createdAt: n.createdAt,
        );
      }).toList();

      state = state.copyWith(
        notifications: updatedList,
        unreadCount: 0,
      );
    } catch (e) {
      // Silently fail
    }
  }

  // ============================================================
  // LISTEN FOR REAL-TIME UPDATES
  // ============================================================
  Stream<List<AppNotification>> notificationsStream() {
    if (_currentUserId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: _currentUserId)
        .orderBy('created_at')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppNotification.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ))
          .toList()
          .reversed
          .toList();
    });
  }
}