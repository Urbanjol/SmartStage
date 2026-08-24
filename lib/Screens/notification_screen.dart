import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Config/theme.dart';
import '../Providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificationProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? SmartStageColors.darkBackground
          : SmartStageColors.lightBackground,
      appBar: AppBar(
        title: const Text('NOTIFICATIONS'),
        backgroundColor: isDark
            ? SmartStageColors.deepNavy
            : SmartStageColors.deepNavy,
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
              },
              child: const Text(
                'READ ALL',
                style: TextStyle(
                  color: SmartStageColors.electricGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: SmartStageColors.electricGreen,
        ),
      )
          : state.notifications.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: isDark
                  ? SmartStageColors.greyDark
                  : SmartStageColors.greyLight,
            ),
            const SizedBox(height: 16),
            Text(
              'No Notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
        itemCount: state.notifications.length,
        itemBuilder: (context, index) {
          final notification = state.notifications[index];
          return _NotificationCard(
            notification: notification,
            onTap: () {
              ref
                  .read(notificationProvider.notifier)
                  .markAsRead(notification.id);
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// NOTIFICATION CARD
// ============================================================
class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color typeColor;
    IconData typeIcon;

    switch (notification.type) {
      case 'ESCROW_CREATED':
        typeColor = SmartStageColors.gold;
        typeIcon = Icons.lock_outline;
        break;
      case 'ESCROW_RELEASED':
        typeColor = SmartStageColors.electricGreen;
        typeIcon = Icons.payments_outlined;
        break;
      case 'ESCROW_REFUNDED':
        typeColor = SmartStageColors.red;
        typeIcon = Icons.undo;
        break;
      case 'CHAT_MESSAGE':
        typeColor = SmartStageColors.electricGreen;
        typeIcon = Icons.chat_bubble_outline;
        break;
      case 'CHAT_CREATED':
        typeColor = SmartStageColors.electricGreen;
        typeIcon = Icons.chat_bubble;
        break;
      default:
        typeColor = SmartStageColors.gold;
        typeIcon = Icons.notifications;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.read
              ? (isDark
              ? SmartStageColors.navyCard.withOpacity(0.5)
              : SmartStageColors.white.withOpacity(0.5))
              : (isDark
              ? SmartStageColors.navyCard
              : SmartStageColors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.read
                ? (isDark ? Colors.white10 : SmartStageColors.greyLight)
                : typeColor.withOpacity(0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: notification.read
                    ? null
                    : [
                  BoxShadow(
                    color: typeColor.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                typeIcon,
                color: typeColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? SmartStageColors.white
                          : SmartStageColors.deepNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? SmartStageColors.greyMid
                          : SmartStageColors.greyDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${notification.createdAt.hour}:${notification.createdAt.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? SmartStageColors.greyDark
                          : SmartStageColors.greyMid,
                    ),
                  ),
                ],
              ),
            ),

            // Unread dot
            if (!notification.read)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: typeColor,
                  boxShadow: [
                    BoxShadow(
                      color: typeColor.withOpacity(0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}