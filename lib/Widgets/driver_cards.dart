import 'package:flutter/material.dart';

class BalanceChangeCard extends StatelessWidget {
  final double balance;
  final double change;
  final bool isVisible;
  final VoidCallback onToggle;

  const BalanceChangeCard({
    Key? key,
    required this.balance,
    required this.change,
    required this.isVisible,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Row(
              children: [
                Text(
                  isVisible
                      ? 'UGX ${balance.toStringAsFixed(0)}'
                      : '••••••',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  size: 18,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            '${change.toStringAsFixed(1)}% today',
            style: TextStyle(
              color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class LiveStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String change;
  final bool isPositive;

  const LiveStatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              change,
              style: TextStyle(
                fontSize: 11,
                color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//activeroutes card
class ActiveRouteTrafficCard extends StatelessWidget {
  final String condition;
  final int delayMinutes;
  final String summary;

  const ActiveRouteTrafficCard({
    Key? key,
    required this.condition,
    required this.delayMinutes,
    required this.summary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (condition) {
      case 'Light':
        color = const Color(0xFF10B981);
        break;
      case 'Moderate':
        color = const Color(0xFFFFB800);
        break;
      case 'Heavy':
        color = const Color(0xFFEF4444);
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.traffic, color: Color(0xFF1E293B)),
              const SizedBox(width: 8),
              const Text(
                'YOUR ROUTE TRAFFIC',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                condition,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                '+$delayMinutes min',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
//end
//new card for combined cards
class DemandFuelRow extends StatelessWidget {
  final String busyHours;
  final String hotStages;
  final List<dynamic> prices;

  const DemandFuelRow({
    Key? key,
    required this.busyHours,
    required this.hotStages,
    required this.prices,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DemandPulseCard(
            busyHours: busyHours,
            hotStages: hotStages,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FuelPricesCard(prices: prices),
        ),
      ],
    );
  }
}

class RequestActionCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const RequestActionCard({
    Key? key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//end of it
//traffic cards
class TrafficCard extends StatelessWidget {
  final List<dynamic> traffic;

  const TrafficCard({Key? key, required this.traffic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (traffic.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TRAFFIC', style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 8),
          ...traffic.map((item) {
            final map = item as Map<String, dynamic>;
            final road = map['road'] ?? 'Unknown';
            final condition = map['condition'] ?? 'Unknown';

            Color color;
            if (condition == 'Heavy') {
              color = const Color(0xFFEF4444);
            } else if (condition == 'Moderate') {
              color = const Color(0xFFFFB800);
            } else {
              color = const Color(0xFF10B981);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(road, style: const TextStyle(fontSize: 13))),
                  Text(
                    condition,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
//end

class ActiveRouteCard extends StatelessWidget {
  final String routeText;
  final VoidCallback onEndRoute;

  const ActiveRouteCard({
    Key? key,
    required this.routeText,
    required this.onEndRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ACTIVE ROUTE', style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            routeText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onEndRoute,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('END ROUTE'),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DemandPulseCard extends StatelessWidget {
  final String busyHours;
  final String hotStages;

  const DemandPulseCard({
    Key? key,
    required this.busyHours,
    required this.hotStages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DEMAND PULSE', style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 8),
          Text('Busy Hours: $busyHours', style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 4),
          Text('Hot Destinations: $hotStages', style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
//new fuel prices card
class FuelPricesCard extends StatelessWidget {
  final List<dynamic> prices;

  const FuelPricesCard({Key? key, required this.prices}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FUEL PRICES', style: TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 8),
          if (prices.isEmpty)
            const Text('No fuel data yet')
          else
            ...prices.take(3).map((price) {
              final map = price as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  '⛽ ${map['company']}  P ${map['petrol']}  D ${map['diesel']}',
                  style: const TextStyle(fontSize: 10),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
//end of fuel prices card
class FuelPricesCard2 extends StatelessWidget {
  final List<dynamic> prices;

  const FuelPricesCard2({Key? key, required this.prices}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FUEL PRICES', style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 8),
          if (prices.isEmpty)
            const Text('No fuel data yet')
          else
            ...prices.map((price) {
              final map = price as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '⛽ ${map['company']}    Petrol ${map['petrol']}  Diesel ${map['diesel']}',
                  style: const TextStyle(fontSize: 13),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}

class FuelNewsCard extends StatelessWidget {
  final List<String> news;

  const FuelNewsCard({Key? key, required this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (news.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FUEL NEWS', style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 8),
          ...news.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('📰 $item', style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
        ],
      ),
    );
  }
}