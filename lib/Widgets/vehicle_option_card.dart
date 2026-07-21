import 'package:flutter/material.dart';

class VehicleOptionCard extends StatelessWidget {
  final String vehicleType;
  final String capacity;
  final String estimatedFare;
  final IconData iconData;
  final bool isSelected;
  final VoidCallback onTap;

  const VehicleOptionCard({
    Key? key,
    required this.vehicleType,
    required this.capacity,
    required this.estimatedFare,
    required this.iconData,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Gather theme metadata from the context tree
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    // 2. Derive dynamic, highly legible visual properties
    final Color cardBackground = isSelected
        ? (isDarkMode ? colorScheme.primary.withOpacity(0.15) : const Color(0xFFEEF6FF))
        : theme.cardColor;

    final Color borderStrokeColor = isSelected
        ? (isDarkMode ? Colors.orange : const Color(0xFF0056b3))
        : (isDarkMode ? Colors.white.withOpacity(0.08) : Colors.grey.shade200);

    final Color titleTextColor = isDarkMode ? Colors.white : Colors.black87;
    final Color subtitleTextColor = isDarkMode ? Colors.white70 : Colors.grey.shade600;

    final Color iconBackground = isSelected
        ? (isDarkMode ? Colors.orange.withOpacity(0.2) : const Color(0xFF0056b3).withOpacity(0.1))
        : (isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100);

    final Color iconColor = isSelected
        ? (isDarkMode ? Colors.orange : const Color(0xFF0056b3))
        : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderStrokeColor,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            // Vehicle Icon Bubble wrapper
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),

            // Text Meta Descriptions Block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicleType,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: titleTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Capacity: $capacity",
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleTextColor,
                    ),
                  ),
                ],
              ),
            ),

            // Dynamic Currency Pricing Text Frame
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  estimatedFare,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected && isDarkMode ? Colors.orange : titleTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Est. Total",
                  style: TextStyle(
                    fontSize: 11,
                    color: subtitleTextColor,
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