//This model is were we are going to put the bipartite graph theorem
//we will add an enum for protection
enum BookingStatus {
  searching,
  arriving,
  pending,
  matched,
  boarded,
  cancelled
}
enum EventType {
  burial,
  //ceremony,
  graduation,
  wedding,
  introduction,
  cooperate,
  other
}
class BookingModel{
  final String bookingId;
  final String passengerUid;
  final String? taxiId;
  final String? stageId;
  final DateTime bookingTime;
  //final String destination;
  final double fareAmount;
  //routing h3 parameters
  final String pickUph3;
  final String destinationH3;

  final String pickUpAddress;
  final String destinationAddress;
  final BookingStatus status;
  final EventType event;

  //state machine for the breakthrough
BookingModel({
    required this.bookingId,
    required this.passengerUid,
    this.taxiId,
    this.stageId,
    required this.bookingTime,
    //required this.destination,
    required this.pickUph3,
    required this.destinationH3,
    required this.pickUpAddress,
    required this.destinationAddress,
    this.status = BookingStatus.searching,
    this.event = EventType.other,
    this.fareAmount = 0,
});
//helper to map to firebase
Map<String, dynamic>toMap() {
  return{
    'bookingId':bookingId,
    'passengerUid':passengerUid,
    'taxiId':taxiId,
    'stageId':stageId,
    'pickUph3':pickUph3, //pickUp cell
    'destinationH3':destinationH3, //dest cell
    'pickUpAddress':pickUpAddress, //pickUp address
    'destinationAddress':destinationAddress, //dest address
    //'destination':destination,
    'status':status.name,
    'eventType':EventType.other,
    'fareAmount':fareAmount,
    'bookingTime':bookingTime.toIso8601String(),
  };
}
//Helper function getting data from firebase
factory BookingModel.fromMap(Map<String,dynamic>map){
  return BookingModel(
      bookingId: map['bookingId'] ?? '',
      passengerUid: map['passengerUid'] ?? '',
      taxiId: map['taxiId'] ?? '',
      stageId: map['stageId'] ?? '',
      status: map['status'] ?? '',
      event: EventType.values.byName(map['EventType'] ?? 'burial'),
      bookingTime: map['bookingTime'] ?? '',
      pickUph3: map['pickUph3'] ?? '',
      destinationH3: map['destinationH3'] ?? '',
      pickUpAddress: map['pickUpAddress'] ?? '',
      destinationAddress: map['destinationAddress'] ?? '',
      fareAmount: (map['fareAmount'] as num?)?.toDouble() ?? 0.0,
      //destination: map['destination'] ?? '',
  );
}
}