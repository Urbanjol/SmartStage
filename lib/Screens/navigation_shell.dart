import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Config/theme.dart';
import '../Screens/nav_provider.dart';
import '../Screens/home_map_screen2.dart';
import '../Screens/privateHireScreen.dart';
import '../Screens/profile_screen.dart';
import '../Screens/driver_home_screen.dart';
import '../Screens/parcel_screen.dart';
import '../Screens/driver_parcel_request.dart';
import '../Screens/driver_request_screen.dart';

class NavigationShell extends ConsumerStatefulWidget {
  const NavigationShell({Key? key}) : super(key: key);

  @override
  ConsumerState<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends ConsumerState<NavigationShell> {
  List<String> _userRoles = ['passenger'];
  bool _isLoading = true;
  String? _matatuId;
  String? _matatuPlate;
  List<String>? _route;
  List<String>? _routeNames;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _userRoles = List<String>.from(data['roles'] ?? ['passenger']);
          _matatuId = data['assigned_vehicle'];
        });
      }

      if (_matatuId != null) {
        final matatuDoc = await FirebaseFirestore.instance
            .collection('taxis')
            .doc(_matatuId)
            .get();

        if (matatuDoc.exists) {
          final matatuData = matatuDoc.data()!;
          setState(() {
            _matatuPlate = matatuData['plate'] ?? 'Unknown';
            _route = List<String>.from(matatuData['route'] ?? []);
            _routeNames = _route!.map((id) {
              return id
                  .split('_')
                  .map((word) => word[0].toUpperCase() + word.substring(1))
                  .join(' ');
            }).toList();
          });
        }
      }
    } catch (e) {
      // Silently fail
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationIndexProvider);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: SmartStageColors.primaryBlue,
          ),
        ),
      );
    }

    final bool isDriver =
        _userRoles.contains('driver') || _userRoles.contains('conductor');

    final List<Widget> screens;

    if (isDriver) {
      screens = [
        DriverHomeScreen(
          userId: FirebaseAuth.instance.currentUser!.uid,
          matatuId: _matatuId ?? '',
          matatuPlate: _matatuPlate ?? 'Unknown',
          route: _route ?? [],
          routeNames: _routeNames ?? [],
        ),
        const DriverParcelRequestsScreen(),
        const DriverRequestsScreen(),
        const ProfileScreen(),
      ];
    } else {
      screens = [
        const HomeMapScreen(),
        const ParcelScreen(),
        const PrivateHireScreen(),
        const ProfileScreen(),
      ];
    }

    final List<BottomNavigationBarItem> navItems;

    if (isDriver) {
      navItems = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Parcels',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.inbox_outlined),
          activeIcon: Icon(Icons.inbox),
          label: 'Requests',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else {
      navItems = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Parcels',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.directions_bus_outlined),
          activeIcon: Icon(Icons.directions_bus),
          label: 'Private Hire',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            ref.read(navigationIndexProvider.notifier).state = index;
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: SmartStageColors.primaryBlue,
          unselectedItemColor: SmartStageColors.greyMid,
          showUnselectedLabels: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          items: navItems,
        ),
      ),
    );
  }
}