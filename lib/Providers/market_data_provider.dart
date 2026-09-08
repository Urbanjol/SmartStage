import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MarketData {
  final List<dynamic> fuel;
  final List<dynamic> traffic;
  final List<String> news;

  MarketData({
    required this.fuel,
    required this.traffic,
    required this.news,
  });

  factory MarketData.fromMap(Map<String, dynamic> map) {
    return MarketData(
      fuel: map['fuel'] as List<dynamic>? ?? [],
      traffic: map['traffic'] as List<dynamic>? ?? [],
      news: (map['news'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    );
  }
}

final marketDataProvider = StreamProvider<MarketData>((ref) {
  return FirebaseFirestore.instance
      .collection('market_data')
      .doc('latest')
      .snapshots()
      .map((doc) {
    if (doc.exists) {
      return MarketData.fromMap(doc.data() as Map<String, dynamic>);
    }
    return MarketData(fuel: [], traffic: [], news: []);
  });
});