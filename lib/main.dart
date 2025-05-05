import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'preferences.dart';
import 'splash.dart';
import 'home.dart';
import 'location_screen.dart';
import 'ranking.dart';
import 'login.dart';
import 'register.dart';

// import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AppPreferences.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeRank',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF5731EA),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'SF Pro Display',
      ),
      home: const InitialScreen(),
      routes: {
        '/home':        (c) => const RestaurantListingPage(),
        '/map':         (c) => const LocationScreen(),
        '/leaderboard': (c) => const LeaderboardPage(),
        '/login':       (c) => const LoginPage(),
        '/register':    (c) => const RegisterPage(),
      },
    );
  }
}
