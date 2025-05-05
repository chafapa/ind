import 'package:flutter/material.dart';
import 'preferences.dart';          
import 'home.dart';             
import 'register.dart';     





// ← This is the missing piece:
class InitialScreen extends StatefulWidget {
  const InitialScreen({Key? key}) : super(key: key);

  @override
  State<InitialScreen> createState() => InitialScreenState();
}

class InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
     await AppPreferences.resetFirstTimeFlag();


    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    if (AppPreferences.isFirstTime()) {
      await AppPreferences.setFirstTimeDone();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegisterPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RestaurantListingPage()),
      );
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A0BD6),
      body: Align(
        alignment: const Alignment(0, -0.2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: 0.6,
                child: Image.asset(
                  'assets/images/weRM.png',
                  width: 220,
                  height: 220,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'WeRank',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                height: 1.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

