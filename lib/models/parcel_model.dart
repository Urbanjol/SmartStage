enum ParcelStatus {
  created,
  picked_up,
  in_transit,
  near_destination,
  delivered
}

class ParcelModel {
  final String parcelId;
  final String senderId;
  final String senderName;
  final String receiverName;
  final String receiverPhone;
  final String pickupStage;
  final String destinationStage;
  final String? taxiId;
  final String trackingCode;
  final ParcelStatus status;
  final double fare;
  final DateTime createdAt;

  ParcelModel({
    required this.parcelId,
    required this.senderId,
    required this.senderName,
    required this.receiverName,
    required this.receiverPhone,
    required this.pickupStage,
    required this.destinationStage,
    this.taxiId,
    required this.trackingCode,
    this.status = ParcelStatus.created,
    required this.fare,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'parcel_id': parcelId,
      'sender_id': senderId,
      'sender_name': senderName,
      'receiver_name': receiverName,
      'receiver_phone': receiverPhone,
      'pickup_stage': pickupStage,
      'destination_stage': destinationStage,
      'taxi_id': taxiId,
      'tracking_code': trackingCode,
      'status': status.name,
      'fare': fare,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ParcelModel.fromMap(Map<String, dynamic> map, String id) {
    return ParcelModel(
      parcelId: id,
      senderId: map['sender_id'] ?? '',
      senderName: map['sender_name'] ?? '',
      receiverName: map['receiver_name'] ?? '',
      receiverPhone: map['receiver_phone'] ?? '',
      pickupStage: map['pickup_stage'] ?? '',
      destinationStage: map['destination_stage'] ?? '',
      taxiId: map['taxi_id'],
      trackingCode: map['tracking_code'] ?? '',
      status: ParcelStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => ParcelStatus.created,
      ),
      fare: (map['fare'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  String get statusLabel {
    switch (status) {
      case ParcelStatus.created:
        return 'Created';
      case ParcelStatus.picked_up:
        return 'Picked Up';
      case ParcelStatus.in_transit:
        return 'In Transit';
      case ParcelStatus.near_destination:
        return 'Near Destination';
      case ParcelStatus.delivered:
        return 'Delivered';
      default:
        return 'Unknown';
    }
  }
}