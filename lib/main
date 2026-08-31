import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Config/firebase_options.dart';
import '../Config/theme.dart';
import '../Screens/navigation_shell.dart';
import '../Screens/login_screen.dart';
import '../Screens/role_selection_screen.dart';
import '../Providers/theme_provider.dart';
import '../Providers/service_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      theme: SmartStageTheme.lightTheme,
      darkTheme: SmartStageTheme.darkTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: SmartStageColors.electricGreen,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final user = snapshot.data!;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: SmartStageColors.electricGreen,
                  ),
                ),
              );
            }

            if (userSnapshot.hasData && userSnapshot.data!.exists) {
              final data = userSnapshot.data!.data() as Map<String, dynamic>?;

              if (data != null && data.containsKey('roles')) {
                final roles = data['roles'] as List<dynamic>?;

                if (roles != null && roles.isNotEmpty) {
                  return const NavigationShell();
                }
              }
            }

            return const RoleSelectionScreen();
          },
        );
      },
    );
  }
}