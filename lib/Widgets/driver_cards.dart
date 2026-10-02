import 'package:flutter/material.dart';
import '../Config/app_config.dart';

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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Row(
              children: [
                Text(
                  isVisible ? 'UGX ${balance.toStringAsFixed(0)}' : '••••••',
                  style: AppText.number.copyWith(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  size: 16,
                  color: const Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            '${change.toStringAsFixed(1)}% today',
            style: AppText.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isPositive
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
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
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.caption),
            const SizedBox(height: 6),
            Text(value, style: AppText.number.copyWith(fontSize: 18)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 10,
                  color: isPositive
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
                const SizedBox(width: 2),
                Text(
                  change,
                  style: AppText.body.copyWith(
                    fontSize: 11,
                    color: isPositive
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ACTIVE ROUTE', style: AppText.caption),
          const SizedBox(height: 8),
          Text(routeText, style: AppText.title),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onEndRoute,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'END ROUTE',
                style: AppText.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.traffic, color: Color(0xFF1E293B), size: 18),
              const SizedBox(width: 8),
              Text('YOUR ROUTE TRAFFIC', style: AppText.caption),
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
                style: AppText.number.copyWith(fontSize: 18, color: color),
              ),
              const Spacer(),
              Text(
                '+$delayMinutes min',
                style: AppText.number.copyWith(fontSize: 14, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(summary, style: AppText.body.copyWith(color: const Color(0xFF64748B))),
        ],
      ),
    );
  }
}

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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(title, style: AppText.body.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: AppText.number.copyWith(fontSize: 22, color: color),
              ),
            ],
          ),
        ),
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                text,
                style: AppText.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DEMAND PULSE', style: AppText.caption),
          const SizedBox(height: 8),
          Text('Busy: $busyHours', style: AppText.body.copyWith(fontSize: 12)),
          const SizedBox(height: 4),
          Text('Hot: $hotStages', style: AppText.body.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}

class FuelPricesCard extends StatelessWidget {
  final List<dynamic> prices;

  const FuelPricesCard({Key? key, required this.prices}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FUEL PRICES', style: AppText.caption),
          const SizedBox(height: 8),
          if (prices.isEmpty)
            Text('No data', style: AppText.body)
          else
            ...prices.take(3).map((price) {
              final map = price as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  '⛽ ${map['company']}  P ${map['petrol']}',
                  style: AppText.body.copyWith(fontSize: 11),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}

class TrafficCard extends StatelessWidget {
  final List<dynamic> traffic;

  const TrafficCard({Key? key, required this.traffic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (traffic.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TRAFFIC', style: AppText.caption),
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
                  Expanded(
                    child: Text(road, style: AppText.body.copyWith(fontSize: 13)),
                  ),
                  Text(
                    condition,
                    style: AppText.body.copyWith(
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FUEL NEWS', style: AppText.caption),
          const SizedBox(height: 8),
          ...news.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('📰 $item', style: AppText.body.copyWith(fontSize: 13)),
            );
          }).toList(),
        ],
      ),
    );
  }
}