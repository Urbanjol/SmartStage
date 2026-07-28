import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Config/firebase_options.dart';
import '../Screens/navigation_shell.dart';
import '../Screens/login_screen.dart';
import '../Providers/theme_provider.dart';
import '../Providers/service_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final sharedPrefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesInstanceProvider.overrideWithValue(sharedPrefs),
      ],
      child: const SmartStageApp(),
    ),
  );
}

class SmartStageApp extends ConsumerWidget {
  const SmartStageApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'SmartStage',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF0056b3),
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        dividerColor: Colors.grey.shade100,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0A192F),
        scaffoldBackgroundColor: const Color(0xFF0A192F),
        cardColor: const Color(0xFF172A45),
        dividerColor: Colors.white10.withOpacity(0.05),
      ),
      home: const AuthGate(), // ← This checks auth state
    );
  }
}

// AuthGate decides which screen to show
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is logged in
        if (snapshot.hasData) {
          return const NavigationShell();
        }

        // User is NOT logged in
        return const LoginScreen();
      },
    );
  }
}