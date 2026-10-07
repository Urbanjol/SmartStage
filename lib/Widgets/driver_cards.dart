import 'package:flutter/material.dart';
import 'package:smart_stage/Widgets/seat_progress_ring.dart';
import '../Config/app_config.dart';
import 'animated_counter.dart';

// ============================================================
// BALANCE HERO CARD
// ============================================================
class BalanceHeroCard extends StatelessWidget {
  final double balance;
  final double change;
  final bool isVisible;
  final VoidCallback onToggle;

  const BalanceHeroCard({
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
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'BALANCE',
                style: AppText.caption.copyWith(
                  color: Colors.white70,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          isVisible
              ? AnimatedCounter(
            value: balance,
            prefix: 'UGX ',
            style: AppText.number.copyWith(
              fontSize: 30,
              color: Colors.white,
            ),
          )
              : Text(
            '••••••',
            style: AppText.number.copyWith(
              fontSize: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${change.toStringAsFixed(1)}%',
                      style: AppText.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'today',
                style: AppText.caption.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DUAL STAT CARD
// ============================================================
class DualStatCard extends StatelessWidget {
  final String title;
  final String label1;
  final String value1;
  final String change1;
  final bool isPositive1;
  final String label2;
  final String value2;
  final String change2;
  final bool isPositive2;

  const DualStatCard({
    Key? key,
    required this.title,
    required this.label1,
    required this.value1,
    required this.change1,
    required this.isPositive1,
    required this.label2,
    required this.value2,
    required this.change2,
    required this.isPositive2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.caption.copyWith(letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStat(label1, value1, change1, isPositive1),
              ),
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFFF1F5F9),
              ),
              Expanded(
                child: _buildStat(
                  label2,
                  value2,
                  change2,
                  isPositive2,
                  isRight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
      String label,
      String value,
      String change,
      bool isPositive, {
        bool isRight = false,
      }) {
    return Column(
      crossAxisAlignment:
      isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.caption),
        const SizedBox(height: 6),
        Text(value, style: AppText.number.copyWith(fontSize: 22)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment:
          isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Icon(
              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
              size: 10,
              color: isPositive
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFEF4444),
            ),
            const SizedBox(width: 2),
            Text(
              change,
              style: AppText.caption.copyWith(
                color: isPositive
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// ACTIVE ROUTE CARD
// ============================================================
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ACTIVE ROUTE',
              style: AppText.caption.copyWith(letterSpacing: 1.5)),
          const SizedBox(height: 10),
          Text(routeText, style: AppText.title),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onEndRoute,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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


// ============================================================
// QUICK ACTION BUTTON
// ============================================================
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
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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

// ============================================================
// DEMAND PULSE CARD
// ============================================================
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
      height: 140,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DEMAND PULSE',
              style: AppText.caption.copyWith(letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text('Busy: $busyHours', style: AppText.caption),
          const SizedBox(height: 4),
          Text('Hot: $hotStages', style: AppText.caption),
        ],
      ),
    );
  }
}

// ============================================================
// FUEL PRICES CARD
// ============================================================
class FuelPricesCard extends StatelessWidget {
  final List<dynamic> prices;

  const FuelPricesCard({Key? key, required this.prices}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FUEL PRICES',
              style: AppText.caption.copyWith(letterSpacing: 1.5)),
          const SizedBox(height: 8),
          if (prices.isEmpty)
            Text('No data', style: AppText.caption)
          else
            ...prices.take(3).map((price) {
              final map = price as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  '${map['company']}  ${map['petrol']}',
                  style: AppText.caption,
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}

// ============================================================
// DEMAND FUEL ROW
// ============================================================
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

// ============================================================
// REQUEST ACTION CARD
// ============================================================
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
          height: 110,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(title,
                  style: AppText.caption.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('$count',
                  style: AppText.number.copyWith(fontSize: 22, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// TRAFFIC CARD
// ============================================================
// ============================================================
// COMBINED TRAFFIC CARD
// ============================================================
class TrafficCard extends StatelessWidget {
  final String routeCondition;
  final int routeDelay;
  final String routeSummary;
  final List<dynamic> traffic;

  const TrafficCard({
    Key? key,
    required this.routeCondition,
    required this.routeDelay,
    required this.routeSummary,
    required this.traffic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color routeColor;
    switch (routeCondition) {
      case 'Light':
        routeColor = const Color(0xFF2563EB);
        break;
      case 'Moderate':
        routeColor = const Color(0xFFFFB800);
        break;
      case 'Heavy':
        routeColor = const Color(0xFFEF4444);
        break;
      default:
        routeColor = const Color(0xFF64748B);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TRAFFIC', style: AppText.caption.copyWith(letterSpacing: 1.5)),
          const SizedBox(height: 12),

          // Your route traffic
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: routeColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: routeColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.traffic, color: routeColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'YOUR ROUTE',
                      style: AppText.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: routeColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '+$routeDelay min',
                      style: AppText.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: routeColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: routeColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      routeCondition,
                      style: AppText.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: routeColor,
                      ),
                    ),
                  ],
                ),
                if (routeSummary.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(routeSummary, style: AppText.caption),
                ],
              ],
            ),
          ),

          // General traffic overview
          if (traffic.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'ALL ROADS',
              style: AppText.caption.copyWith(letterSpacing: 1.5),
            ),
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
                color = const Color(0xFF2563EB);
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
                      child: Text(road, style: AppText.caption),
                    ),
                    Text(
                      condition,
                      style: AppText.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// FUEL NEWS CARD
// ============================================================
class FuelNewsCard extends StatelessWidget {
  final List<String> news;

  const FuelNewsCard({Key? key, required this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (news.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FUEL NEWS',
              style: AppText.caption.copyWith(letterSpacing: 1.5)),
          const SizedBox(height: 10),
          ...news.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(item, style: AppText.caption),
            );
          }).toList(),
        ],
      ),
    );
  }
}

//seats ring card
class SeatRingCard extends StatelessWidget {
  final int filled;
  final int total;

  const SeatRingCard({
    Key? key,
    required this.filled,
    required this.total,
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
      child: Row(
        children: [
          SeatProgressRing(filled: filled, total: total),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SEATS FILLED', style: AppText.caption),
              const SizedBox(height: 4),
              Text('$filled / $total',
                  style: AppText.number.copyWith(fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }
}
//end

// ============================================================
// SHARED DECORATION
// ============================================================
BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}