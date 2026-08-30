import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Config/theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('SETTINGS'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2563EB),
              Color(0xFFB197FC),
              Color(0xFFF8FAFC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSettingCard(
              icon: Icons.notifications_outlined,
              title: 'Push Notifications',
              subtitle: 'Get alerts for taxis, parcels, and bookings',
              color: const Color(0xFF2563EB),
              child: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeColor: const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.location_on_outlined,
              title: 'Location Services',
              subtitle: 'Allow SmartStage to see your location',
              color: const Color(0xFF10B981),
              child: Switch(
                value: _locationEnabled,
                onChanged: (value) {
                  setState(() {
                    _locationEnabled = value;
                  });
                },
                activeColor: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle: 'Coming soon',
              color: const Color(0xFF7B2FF7),
              child: Switch(
                value: _darkMode,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dark mode coming soon'),
                    ),
                  );
                },
                activeColor: const Color(0xFF7B2FF7),
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English • Luganda',
              color: const Color(0xFFFFB800),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
              onTap: () {
                // Language selection later
              },
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.directions_bus_outlined,
              title: 'Vehicle Preferences',
              subtitle: 'Taxi • E-Bus • Bus',
              color: const Color(0xFF1E40AF),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
              onTap: () {
                // Vehicle preferences later
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    Widget? child,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (child != null)
              child
            else if (trailing != null)
              trailing,
          ],
        ),
      ),
    );
  }
}