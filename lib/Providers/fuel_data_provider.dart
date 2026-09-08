import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FuelData {
  final List<FuelPrice> prices;
  final List<String> news;

  FuelData({required this.prices, required this.news});

  factory FuelData.fromMap(Map<String, dynamic> map) {
    final pricesRaw = map['prices'] as List<dynamic>? ?? [];
    final newsRaw = map['news'] as List<dynamic>? ?? [];

    return FuelData(
      prices: pricesRaw
          .map((p) => FuelPrice.fromMap(Map<String, dynamic>.from(p as Map)))
          .toList(),
      news: newsRaw.map((n) => n.toString()).toList(),
    );
  }
}

class FuelPrice {
  final String company;
  final double petrol;
  final double diesel;
  final double kerosene;

  FuelPrice({
    required this.company,
    required this.petrol,
    required this.diesel,
    required this.kerosene,
  });

  factory FuelPrice.fromMap(Map<String, dynamic> map) {
    return FuelPrice(
      company: map['company'] ?? 'Unknown',
      petrol: (map['petrol'] as num?)?.toDouble() ?? 0,
      diesel: (map['diesel'] as num?)?.toDouble() ?? 0,
      kerosene: (map['kerosene'] as num?)?.toDouble() ?? 0,
    );
  }
}

final fuelDataProvider = StreamProvider<FuelData>((ref) {
  return FirebaseFirestore.instance
      .collection('fuel_data')
      .doc('latest')
      .snapshots()
      .map((doc) {
    if (doc.exists) {
      return FuelData.fromMap(doc.data() as Map<String, dynamic>);
    }
    return FuelData(prices: [], news: []);
  });
});