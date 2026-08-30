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
            .collection('matatus')
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
      // Silently fail, user stays as passenger
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
            color: SmartStageColors.electricGreen,
          ),
        ),
      );
    }

    final bool isDriver =
        _userRoles.contains('driver') || _userRoles.contains('conductor');

    final List<Widget> screens = [
      const HomeMapScreen(),
      const ParcelScreen(),
      const PrivateHireScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
          unselectedItemColor: Theme.of(context).brightness == Brightness.dark
              ? SmartStageColors.greyDark
              : SmartStageColors.greyMid,
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
          items: [
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
            if (isDriver)
              const BottomNavigationBarItem(
                icon: Icon(Icons.airport_shuttle_outlined),
                activeIcon: Icon(Icons.airport_shuttle),
                label: 'Drive',
              ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
      floatingActionButton: isDriver
          ? Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: SmartStageColors.greenGlow,
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            if (_matatuId != null && _matatuPlate != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DriverHomeScreen(
                    userId: FirebaseAuth.instance.currentUser!.uid,
                    matatuId: _matatuId!,
                    matatuPlate: _matatuPlate!,
                    route: _route ?? [],
                    routeNames: _routeNames ?? [],
                  ),
                ),
              );
            }
          },
          icon: const Icon(Icons.directions_bus),
          label: const Text('Drive'),
          backgroundColor: SmartStageColors.electricGreen,
          foregroundColor: SmartStageColors.white,
          elevation: 0,
        ),
      )
          : null,
    );
  }
}