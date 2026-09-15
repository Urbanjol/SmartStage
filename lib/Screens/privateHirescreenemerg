import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Config/theme.dart';
import '../Providers/PrivateHireProvider.dart';
import '../models/Booking_model.dart';
import 'driver_request_screen.dart';

class PrivateHireScreen extends ConsumerStatefulWidget {
  const PrivateHireScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PrivateHireScreen> createState() => _PrivateHireScreenState();
}

class _PrivateHireScreenState extends ConsumerState<PrivateHireScreen> {
  EventType _selectedEvent = EventType.wedding;
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _passengersController = TextEditingController();

  int _bookingRequestCount = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(privateHireProvider.notifier).loadMyBookings();
      ref.read(privateHireProvider.notifier).loadNearbyDrivers();
      _loadBookingRequestCount();
    });
  }

  Future<void> _loadBookingRequestCount() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('status', isEqualTo: 'searching')
          .get();

      if (mounted) {
        setState(() {
          _bookingRequestCount = snapshot.docs.length;
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _descriptionController.dispose();
    _passengersController.dispose();
    super.dispose();
  }

  void _showCreateBookingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateBookingSheet(
        selectedEvent: _selectedEvent,
        pickupController: _pickupController,
        destinationController: _destinationController,
        descriptionController: _descriptionController,
        passengersController: _passengersController,
        onCreate: () async {
          final bookingId = await ref
              .read(privateHireProvider.notifier)
              .createBooking(
            pickUpAddress: _pickupController.text.trim(),
            destinationAddress: _destinationController.text.trim(),
            pickUph3: 'kampala_h3',
            destinationH3: 'destination_h3',
            eventType: _selectedEvent,
            eventDate: DateTime.now().add(const Duration(days: 7)),
            passengerCount:
            int.tryParse(_passengersController.text.trim()) ?? 1,
            eventDescription: _descriptionController.text.trim(),
          );

          if (bookingId != null && mounted) {
            _showSuccessDialog();
          }
        },
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? SmartStageColors.navyCard
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'REQUEST SENT!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: SmartStageColors.electricGreen,
          ),
        ),
        content: const Text(
          'Your booking request has been sent to nearby drivers.',
          style: TextStyle(
            color: SmartStageColors.greyDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                color: SmartStageColors.electricGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(privateHireProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A192F) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('PRIVATE HIRE'),
        backgroundColor: isDark ? const Color(0xFF0A192F) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.inbox_outlined),
                tooltip: 'Driver Requests',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DriverRequestsScreen(),
                    ),
                  ).then((_) => _loadBookingRequestCount());
                },
              ),
              if (_bookingRequestCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      '$_bookingRequestCount',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
      //),
        child: Column(
          children: [
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: EventType.values.map((event) {
                  final isSelected = _selectedEvent == event;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedEvent = event;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : isDark
                              ? SmartStageColors.navyCard
                              : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : isDark
                                ? Colors.white10
                                : SmartStageColors.greyLight,
                          ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.4),
                              blurRadius: 12,
                            ),
                          ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            event.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : isDark
                                  ? SmartStageColors.greyMid
                                  : SmartStageColors.greyDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlowButton(
                text: 'CREATE BOOKING REQUEST',
                color: SmartStageColors.primaryBlue,
                glowColor: SmartStageColors.primaryBlue.withOpacity(0.4),
                icon: Icons.add_circle_outline,
                onPressed: _showCreateBookingSheet,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: state.isLoadingBookings
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2563EB),
                ),
              )
                  : state.myBookings.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_note,
                      size: 64,
                      color: isDark
                          ? SmartStageColors.greyDark
                          : SmartStageColors.greyLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Bookings Yet',
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
                      'Create a request for your event',
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
                itemCount: state.myBookings.length,
                itemBuilder: (context, index) {
                  final booking = state.myBookings[index];
                  return _BookingCard(booking: booking);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;

  const _BookingCard({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? SmartStageColors.navyCard : Colors.white,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  booking.eventLabel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Text(
                booking.statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? SmartStageColors.greyMid
                      : SmartStageColors.greyDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Color(0xFF2563EB),
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
          Row(
            children: [
              const Icon(
                Icons.flag_outlined,
                size: 16,
                color: Color(0xFFFFB800),
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
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.people_outline,
                size: 14,
                color: SmartStageColors.greyMid,
              ),
              const SizedBox(width: 4),
              Text(
                '${booking.passengerCount} Passengers',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? SmartStageColors.greyMid
                      : SmartStageColors.greyDark,
                ),
              ),
              const Spacer(),
              if (booking.fareAmount > 0)
                Text(
                  'UGX ${booking.fareAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFFB800),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateBookingSheet extends StatelessWidget {
  final EventType selectedEvent;
  final TextEditingController pickupController;
  final TextEditingController destinationController;
  final TextEditingController descriptionController;
  final TextEditingController passengersController;
  final VoidCallback onCreate;

  const _CreateBookingSheet({
    Key? key,
    required this.selectedEvent,
    required this.pickupController,
    required this.destinationController,
    required this.descriptionController,
    required this.passengersController,
    required this.onCreate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? SmartStageColors.navyCard : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? SmartStageColors.greyDark
                        : SmartStageColors.greyLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'CREATE BOOKING',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? SmartStageColors.white
                      : SmartStageColors.deepNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Event: ${selectedEvent.name.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: pickupController,
                decoration: const InputDecoration(
                  labelText: 'Pickup Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: destinationController,
                decoration: const InputDecoration(
                  labelText: 'Destination Address',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passengersController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of Passengers',
                  prefixIcon: Icon(Icons.people_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Event Description (optional)',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: 24),
              GlowButton(
                text: 'SUBMIT REQUEST',
                color: const Color(0xFFFFB800),
                glowColor: const Color(0xFFFFB800).withOpacity(0.4),
                icon: Icons.send_outlined,
                onPressed: () {
                  Navigator.pop(context);
                  onCreate();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}