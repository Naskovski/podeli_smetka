import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:podeli_smetka/screens/login_screen.dart';
import 'package:podeli_smetka/screens/profile_screen.dart';
import 'package:podeli_smetka/screens/scan_screen.dart';
import 'package:podeli_smetka/widgets/main_navigation.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.purple[50],
  ));

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
        '/scan': (context) => const ScanScreen(),
      },
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Future.microtask(() {
            Navigator.pushReplacementNamed(context, '/app');
          });
          return const SizedBox();
        }
        return const LoginScreen();
      },
    );
  }
}
