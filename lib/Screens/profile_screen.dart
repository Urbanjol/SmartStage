import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Config/theme.dart';
import 'notification_screen.dart';
//import 'notifications_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _userName = 'SmartStage User';
  String _phoneNumber = '';
  List<String> _roles = ['passenger'];
  int _totalTrips = 0;
  double _rating = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _phoneNumber = user.phoneNumber ?? '';
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _userName = data['name'] ?? 'SmartStage User';
          _roles = List<String>.from(data['roles'] ?? ['passenger']);
          _totalTrips = (data['total_trips'] as num?)?.toInt() ?? 0;
          _rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
        });
      }
    } catch (e) {
      // Silently fail
    }

    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }
  //new logout dialog box function
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? SmartStageColors.navyCard
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'LOGOUT',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: SmartStageColors.deepNavy,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: SmartStageColors.greyDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                color: SmartStageColors.greyMid,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text(
              'LOGOUT',
              style: TextStyle(
                color: SmartStageColors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  //end of function

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDriver = _roles.contains('driver') || _roles.contains('conductor');

    return Scaffold(
      backgroundColor: isDark
          ? SmartStageColors.darkBackground
          : SmartStageColors.lightBackground,
      appBar: AppBar(
        title: const Text('PROFILE'),
        backgroundColor: isDark
            ? SmartStageColors.deepNavy
            : SmartStageColors.deepNavy,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: SmartStageColors.electricGreen,
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    SmartStageColors.deepNavy,
                    SmartStageColors.navyLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: SmartStageColors.blueGlow,
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: SmartStageColors.electricGreen,
                      border: Border.all(
                        color: SmartStageColors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: SmartStageColors.greenGlow,
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: SmartStageColors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: SmartStageColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _phoneNumber,
                    style: const TextStyle(
                      fontSize: 13,
                      color: SmartStageColors.greyMid,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDriver
                          ? SmartStageColors.electricGreen
                          : SmartStageColors.gold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isDriver ? 'DRIVER' : 'PASSENGER',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: SmartStageColors.deepNavy,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats Row
            Row(
              children: [
                _buildStatCard(
                  context,
                  label: 'TRIPS',
                  value: _totalTrips.toString(),
                  icon: Icons.directions_bus,
                  color: SmartStageColors.electricGreen,
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  context,
                  label: 'RATING',
                  value: _rating > 0 ? _rating.toStringAsFixed(1) : 'New',
                  icon: Icons.star,
                  color: SmartStageColors.gold,
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  context,
                  label: 'STATUS',
                  value: isDriver ? 'Active' : 'Ready',
                  icon: Icons.check_circle,
                  color: SmartStageColors.blueGlow,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Menu Items
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? SmartStageColors.navyCard
                    : SmartStageColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white10
                      : SmartStageColors.greyLight,
                ),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    context,
                    icon: Icons.history,
                    title: 'Trip History',
                    onTap: () {
                      // Navigate to trip history
                    },
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    context,
                    icon: Icons.payment_outlined,
                    title: 'Payment Methods',
                    onTap: () {
                      // Navigate to payment methods
                    },
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      // Navigate to settings
                    },
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      // Navigate to help
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Logout Button
            GestureDetector(
              onTap: _showLogoutDialog, //logout
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: SmartStageColors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: SmartStageColors.red.withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout,
                      color: SmartStageColors.red,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'LOGOUT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: SmartStageColors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, {
        required String label,
        required String value,
        required IconData icon,
        required Color color,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? SmartStageColors.navyCard : SmartStageColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : SmartStageColors.greyLight,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? SmartStageColors.white
                    : SmartStageColors.deepNavy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? SmartStageColors.greyMid
                    : SmartStageColors.greyDark,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: SmartStageColors.electricGreen,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? SmartStageColors.white
                      : SmartStageColors.deepNavy,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark
                  ? SmartStageColors.greyDark
                  : SmartStageColors.greyMid,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark ? Colors.white10 : SmartStageColors.greyLight,
    );
  }
}