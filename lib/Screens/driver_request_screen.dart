import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Config/theme.dart';
import '../Providers/PrivateHireProvider.dart';
//import '../Providers/private_hire_provider.dart';
import '../Providers/chat_provider.dart';
import '../models/Booking_model.dart';
import 'chart_screen.dart';

class DriverRequestsScreen extends ConsumerStatefulWidget {
  const DriverRequestsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DriverRequestsScreen> createState() =>
      _DriverRequestsScreenState();
}

class _DriverRequestsScreenState extends ConsumerState<DriverRequestsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(privateHireProvider.notifier).loadNearbyBookings();
      ref.read(privateHireProvider.notifier).loadMyBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(privateHireProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? SmartStageColors.darkBackground
          : SmartStageColors.lightBackground,
      appBar: AppBar(
        title: const Text('BOOKING REQUESTS'),
        backgroundColor: isDark
            ? SmartStageColors.deepNavy
            : SmartStageColors.deepNavy,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(privateHireProvider.notifier).loadNearbyBookings();
            },
          ),
        ],
      ),
      body: state.isLoadingBookings
          ? const Center(
        child: CircularProgressIndicator(
          color: SmartStageColors.electricGreen,
        ),
      )
          : state.nearbyBookings.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: isDark
                  ? SmartStageColors.greyDark
                  : SmartStageColors.greyLight,
            ),
            const SizedBox(height: 16),
            Text(
              'No Requests Nearby',
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
              'Pull to refresh or check back later',
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
          : RefreshIndicator(
        color: SmartStageColors.electricGreen,
        onRefresh: () async {
          ref.read(privateHireProvider.notifier).loadNearbyBookings();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.nearbyBookings.length,
          itemBuilder: (context, index) {
            final booking = state.nearbyBookings[index];
            return _DriverRequestCard(
              booking: booking,
              onInterested: () async {
                await ref
                    .read(privateHireProvider.notifier)
                    .driverInterested(booking.bookingId);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You showed interest'),
                      backgroundColor:
                      SmartStageColors.electricGreen,
                    ),
                  );
                }
              },
              onChat: () async {
                final chatId = await ref
                    .read(chatProvider.notifier)
                    .createChat(
                  bookingId: booking.bookingId,
                  passengerId: booking.passengerUid,
                  driverId:
                  FirebaseAuth.instance.currentUser?.uid ?? '',
                );

                if (chatId != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: chatId,
                        otherUserName: 'Passenger',
                      ),
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// DRIVER REQUEST CARD
// ============================================================
class _DriverRequestCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onInterested;
  final VoidCallback onChat;

  const _DriverRequestCard({
    Key? key,
    required this.booking,
    required this.onInterested,
    required this.onChat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? SmartStageColors.navyCard : SmartStageColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : SmartStageColors.greyLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: SmartStageColors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  booking.eventLabel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: SmartStageColors.gold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 14,
                    color: SmartStageColors.greyMid,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${booking.passengerCount} pax',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? SmartStageColors.greyMid
                          : SmartStageColors.greyDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pickup
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: SmartStageColors.electricGreen,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  booking.pickUpAddress,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? SmartStageColors.white
                        : SmartStageColors.deepNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Destination
          Row(
            children: [
              const Icon(
                Icons.flag_outlined,
                size: 16,
                color: SmartStageColors.gold,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  booking.destinationAddress,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? SmartStageColors.white
                        : SmartStageColors.deepNavy,
                  ),
                ),
              ),
            ],
          ),

          // Event date
          if (booking.eventDate != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 16,
                  color: SmartStageColors.greyMid,
                ),
                const SizedBox(width: 6),
                Text(
                  '${booking.eventDate!.day}/${booking.eventDate!.month}/${booking.eventDate!.year}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? SmartStageColors.greyMid
                        : SmartStageColors.greyDark,
                  ),
                ),
              ],
            ),
          ],

          // Description
          if (booking.eventDescription.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              booking.eventDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: isDark
                    ? SmartStageColors.greyMid
                    : SmartStageColors.greyDark,
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onChat,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? SmartStageColors.navyLight
                          : SmartStageColors.greyLight,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 18,
                          color: SmartStageColors.deepNavy,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'CHAT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: SmartStageColors.deepNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onInterested,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: SmartStageColors.electricGreen,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: SmartStageColors.greenGlow,
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: SmartStageColors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'INTERESTED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: SmartStageColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}