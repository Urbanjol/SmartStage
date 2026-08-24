enum BookingStatus {
  searching,
  driver_interested,
  arriving,
  pending,
  matched,
  boarded,
  completed,
  cancelled
}

enum EventType {
  burial,
  graduation,
  wedding,
  introduction,
  cooperate,
  football,
  church,
  school,
  other
}

class BookingModel {
  final String bookingId;
  final String passengerUid;
  final String? driverUid;
  final String? taxiId;
  final String? stageId;
  final DateTime bookingTime;
  final DateTime? eventDate;
  final double fareAmount;

  // H3 spatial indexing
  final String pickUph3;
  final String destinationH3;

  // Addresses
  final String pickUpAddress;
  final String destinationAddress;

  // Booking details
  final BookingStatus status;
  final EventType event;
  final int passengerCount;
  final String eventDescription;
  final String? chatRoomId;

  // Payment
  final String paymentStatus;

  BookingModel({
    required this.bookingId,
    required this.passengerUid,
    this.driverUid,
    this.taxiId,
    this.stageId,
    required this.bookingTime,
    this.eventDate,
    required this.pickUph3,
    required this.destinationH3,
    required this.pickUpAddress,
    required this.destinationAddress,
    this.status = BookingStatus.searching,
    this.event = EventType.other,
    this.fareAmount = 0,
    this.passengerCount = 1,
    this.eventDescription = '',
    this.chatRoomId,
    this.paymentStatus = 'UNPAID',
  });

  // Helper to map to Firebase
  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'passengerUid': passengerUid,
      'driverUid': driverUid,
      'taxiId': taxiId,
      'stageId': stageId,
      'pickUph3': pickUph3,
      'destinationH3': destinationH3,
      'pickUpAddress': pickUpAddress,
      'destinationAddress': destinationAddress,
      'status': status.name,
      'eventType': event.name,
      'fareAmount': fareAmount,
      'passengerCount': passengerCount,
      'eventDescription': eventDescription,
      'chatRoomId': chatRoomId,
      'paymentStatus': paymentStatus,
      'bookingTime': bookingTime.toIso8601String(),
      'eventDate': eventDate?.toIso8601String(),
    };
  }

  // Helper function getting data from Firebase
  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      bookingId: map['bookingId'] ?? '',
      passengerUid: map['passengerUid'] ?? '',
      driverUid: map['driverUid'],
      taxiId: map['taxiId'],
      stageId: map['stageId'],
      status: BookingStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => BookingStatus.searching,
      ),
      event: EventType.values.firstWhere(
            (e) => e.name == map['eventType'],
        orElse: () => EventType.other,
      ),
      bookingTime: DateTime.tryParse(map['bookingTime'] ?? '') ?? DateTime.now(),
      eventDate: map['eventDate'] != null
          ? DateTime.tryParse(map['eventDate'])
          : null,
      pickUph3: map['pickUph3'] ?? '',
      destinationH3: map['destinationH3'] ?? '',
      pickUpAddress: map['pickUpAddress'] ?? '',
      destinationAddress: map['destinationAddress'] ?? '',
      fareAmount: (map['fareAmount'] as num?)?.toDouble() ?? 0.0,
      passengerCount: (map['passengerCount'] as num?)?.toInt() ?? 1,
      eventDescription: map['eventDescription'] ?? '',
      chatRoomId: map['chatRoomId'],
      paymentStatus: map['paymentStatus'] ?? 'UNPAID',
    );
  }

  // Helper getters
  bool get isActive =>
      status == BookingStatus.searching ||
          status == BookingStatus.driver_interested ||
          status == BookingStatus.pending;

  bool get isConfirmed =>
      status == BookingStatus.matched ||
          status == BookingStatus.arriving ||
          status == BookingStatus.boarded;

  bool get isFinished =>
      status == BookingStatus.completed ||
          status == BookingStatus.cancelled;

  String get eventLabel {
    switch (event) {
      case EventType.burial:
        return 'Burial';
      case EventType.graduation:
        return 'Graduation';
      case EventType.wedding:
        return 'Wedding';
      case EventType.introduction:
        return 'Introduction';
      case EventType.cooperate:
        return 'Corporate';
      case EventType.football:
        return 'Football Match';
      case EventType.church:
        return 'Church Event';
      case EventType.school:
        return 'School Trip';
      case EventType.other:
        return 'Other';
      default:
        return 'Other';
    }
  }

  String get statusLabel {
    switch (status) {
      case BookingStatus.searching:
        return 'Searching';
      case BookingStatus.driver_interested:
        return 'Driver Interested';
      case BookingStatus.arriving:
        return 'Arriving';
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.matched:
        return 'Matched';
      case BookingStatus.boarded:
        return 'Boarded';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
}