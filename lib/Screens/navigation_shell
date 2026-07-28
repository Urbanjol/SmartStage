import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Screens/nav_provider.dart';
import '../Screens/home_map_screen2.dart';
//import '../Screens/home_screen.dart';
import '../Screens/private_booking.dart';
import '../Screens/profile_screen.dart';

// Import  upcoming screens here
// import 'home_map_screen.dart';
// import 'private_booking_screen.dart';
// import 'profile_screen.dart';

class NavigationShell extends ConsumerWidget {
  const NavigationShell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the active tab index from Riverpod
    final currentIndex = ref.watch(navigationIndexProvider);

    // The persistent screens list
    final List<Widget> screens = [
      //const home_screen(),
      const HomeMapScreen(),
      const PrivateHireScreen(),
      //const PrivateBookingScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      // IndexedStack keeps all tabs alive in memory so maps don't reload
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          // Update Riverpod state smoothly on tap
          ref.read(navigationIndexProvider.notifier).state = index;
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0056b3), // Classic Taxi Blue stripe
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Home Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus_outlined),
            activeIcon: Icon(Icons.directions_bus),
            label: 'Private Hire',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// MOCK SCREENS PLACEHOLDERS (So your project runs immediately for testing)
// =========================================================================

//class HomeMapScreen extends StatelessWidget {
  //const HomeMapScreen({Key? key}) : super(key: key);
  //@override
  //Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Home Map Screen (Tab 0)")));
//}

//class PrivateBookingScreen extends StatelessWidget {
  //const PrivateBookingScreen({Key? key}) : super(key: key);
  //@override
  //Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Private Event Logistics Form (Tab 1)")));
//}

//class ProfileScreen extends StatelessWidget {
  //const ProfileScreen({Key? key}) : super(key: key);
  //@override
  //Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("User Profile & Wallet (Tab 2)")));
//}