import 'package:cloud_functions/cloud_functions.dart';

class TrafficService {
  static Future<Map<String, dynamic>> getTraffic(List<String> route) async {
    try {
      final callable =
      FirebaseFunctions.instance.httpsCallable('getTrafficForRoute');
      final result = await callable.call({
        'route': route,
      });

      return Map<String, dynamic>.from(result.data as Map);
    } catch (e) {
      return {
        'condition': 'Unknown',
        'estimated_delay_minutes': 0,
        'summary': 'Traffic unavailable',
      };
    }
  }
}