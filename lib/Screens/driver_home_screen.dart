import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class DriverHomeScreen extends StatefulWidget {
  final String userId;
  final String matatuId;
  final String matatuPlate;
  final List<String> route;
  final List<String> routeNames;

  const DriverHomeScreen({
    Key? key,
    required this.userId,
    required this.matatuId,
    required this.matatuPlate,
    required this.route,
    required this.routeNames,
  }) : super(key: key);

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  String _status = 'IDLE';
  String _seatState = 'space_available';
  bool _isUpdating = false;

  Future<void> _updateStatus(String status) async {
    setState(() => _isUpdating = true);

    try {
      final callable =
      FirebaseFunctions.instance.httpsCallable('updateMatatuLocation');
      await callable.call({
        'matatu_id': widget.matatuId,
        'driver_id': widget.userId,
        'status': status,
        'seats_available': _seatState == 'full' ? 0 : 5,
      });

      setState(() => _status = status);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    setState(() => _isUpdating = false);
  }

  Future<void> _updateSeatState(String state) async {
    setState(() => _isUpdating = true);

    try {
      final callable =
      FirebaseFunctions.instance.httpsCallable('updateSeatStatus');
      await callable.call({
        'matatu_id': widget.matatuId,
        'seat_state': state,
      });

      setState(() => _seatState = state);
      if (state == 'full') {
        _updateStatus('EN_ROUTE');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    setState(() => _isUpdating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Driver Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _status == 'LOADING' || _status == 'EN_ROUTE'
                          ? Colors.green.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _status,
                      style: TextStyle(
                        color: _status == 'LOADING' || _status == 'EN_ROUTE'
                            ? Colors.green
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.matatuPlate,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.routeNames.join(' → '),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 32),

              // Start Route Button
              if (_status == 'IDLE' || _status == 'OFFLOADING')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUpdating
                        ? null
                        : () => _updateStatus('LOADING'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isUpdating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'START ROUTE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              if (_status == 'LOADING') ...[
                const SizedBox(height: 24),
                const Text(
                  'SEAT STATUS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                // Seat status buttons
                Row(
                  children: [
                    Expanded(
                      child: _seatButton(
                        'Space Available',
                        'space_available',
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _seatButton(
                        'Filling Up',
                        'filling_up',
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _seatButton(
                        'Full',
                        'full',
                        Colors.red,
                      ),
                    ),
                  ],
                ),
              ],

              if (_status == 'EN_ROUTE')
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isUpdating
                          ? null
                          : () => _updateStatus('OFFLOADING'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0056b3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'ARRIVED AT DESTINATION',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

              const Spacer(),

              // Route display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ROUTE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.routeNames.asMap().entries.map((entry) {
                      final i = entry.key;
                      final name = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              i == 0
                                  ? Icons.trip_origin
                                  : i == widget.routeNames.length - 1
                                  ? Icons.flag
                                  : Icons.circle,
                              size: 12,
                              color: const Color(0xFF0056b3),
                            ),
                            const SizedBox(width: 8),
                            Text(name,
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _seatButton(String label, String state, Color color) {
    final isSelected = _seatState == state;
    return GestureDetector(
      onTap: _isUpdating ? null : () => _updateSeatState(state),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}