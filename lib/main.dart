import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:podeli_smetka/screens/login_screen.dart';
import 'package:podeli_smetka/screens/home_screen.dart';
import 'package:podeli_smetka/screens/profile_screen.dart';
import 'package:podeli_smetka/widgets/main_navigation.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Firebase is initialized before the app runs
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Podeli Smetka',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthenticationWrapper(),
        '/login': (context) => const LoginScreen(),
        '/app': (context) => const MainNavigation(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

/// This widget checks if the user is logged in and navigates accordingly.
class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the user is logged in, navigate to the /app route
        if (snapshot.hasData) {
          // Navigate to /app
          Future.microtask(() {
            Navigator.pushReplacementNamed(context, '/app');
          });
          return const SizedBox(); // Empty widget until navigation occurs
        }
        // Otherwise, show the LoginScreen
        return const LoginScreen();
      },
    );
  }
}
