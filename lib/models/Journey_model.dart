class JourneyLeg {
  final int walkMin;
  final String stage;
  final String stageId;
  final String matatuPlate;
  final String matatuId;
  final String departure;
  final String arrival;
  final String destination;
  final int fare;
  final String space;

  JourneyLeg({
    required this.walkMin,
    required this.stage,
    required this.stageId,
    required this.matatuPlate,
    required this.matatuId,
    required this.departure,
    required this.arrival,
    required this.destination,
    required this.fare,
    required this.space,
  });

  factory JourneyLeg.fromJson(Map<String, dynamic> json) {
    return JourneyLeg(
      walkMin: json['walk_min'] ?? 0,
      stage: json['stage'] ?? '',
      stageId: json['stage_id'] ?? '',
      matatuPlate: json['matatu_plate'] ?? '',
      matatuId: json['matatu_id'] ?? '',
      departure: json['departure'] ?? '',
      arrival: json['arrival'] ?? '',
      destination: json['destination'] ?? '',
      fare: json['fare'] ?? 0,
      space: json['space'] ?? 'Unknown',
    );
  }
}

class Journey {
  final int totalTimeMin;
  final int totalFare;
  final List<JourneyLeg> legs;

  Journey({
    required this.totalTimeMin,
    required this.totalFare,
    required this.legs,
  });

  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
      totalTimeMin: json['total_time_min'] ?? 0,
      totalFare: json['total_fare'] ?? 0,
      legs: (json['legs'] as List<dynamic>? ?? [])
          .map((leg) => JourneyLeg.fromJson(leg as Map<String, dynamic>))
          .toList(),
    );
  }
}