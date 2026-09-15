import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPoint {
  final double lat;
  final double lng;
  final int count;

  SearchPoint({
    required this.lat,
    required this.lng,
    required this.count,
  });
}

final searchHistoryProvider = StreamProvider<List<SearchPoint>>((ref) {
  final since = DateTime.now().subtract(const Duration(hours: 24));

  return FirebaseFirestore.instance
      .collection('search_history')
      .where('search_time', isGreaterThanOrEqualTo: since)
      .snapshots()
      .map((snapshot) {
    final grouped = <String, Map<String, dynamic>>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final lat = (data['origin_lat'] as num?)?.toDouble();
      final lng = (data['origin_lng'] as num?)?.toDouble();

      if (lat == null || lng == null) continue;

      final key = '${lat.toStringAsFixed(3)},${lng.toStringAsFixed(3)}';

      if (grouped.containsKey(key)) {
        grouped[key]!['count'] = (grouped[key]!['count'] as int) + 1;
      } else {
        grouped[key] = {
          'lat': lat,
          'lng': lng,
          'count': 1,
        };
      }
    }

    return grouped.values.map((data) {
      return SearchPoint(
        lat: data['lat'],
        lng: data['lng'],
        count: data['count'],
      );
    }).toList();
  });
});