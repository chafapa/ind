import 'package:flutter/material.dart';
import 'register.dart';
import 'dart:math' as math;

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,  // ← distribute
            children: [
              // 1) Header + texts in their own little column
              Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('WE',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 32)),
                      Text('RANK',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 32)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Discover, Rate, and Get Rewarded',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Join the community that rewards you for your reviews',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey[700], fontSize: 16)),
                ],
              ),

              // 2) The “floating cards” scroll area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 20),
                  physics: const BouncingScrollPhysics(),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 40,
                        child:
                            Transform.rotate(angle: -0.05, child: LeaderboardCard()),
                      ),
                      Positioned(
                        top: 260,
                        right: MediaQuery.of(context).size.width * 0.1,
                        child: Transform.rotate(angle: 0.08, child: ReviewCard()),
                      ),
                      Positioned(
                        top: 450,
                        left: MediaQuery.of(context).size.width * 0.05,
                        child:
                            Transform.rotate(angle: -0.03, child: NotificationCard()),
                      ),
                      Positioned(
                        top: 650,
                        child:
                            Transform.rotate(angle: 0.04, child: RewardsCard()),
                      ),
                    ],
                  ),
                ),
              ),

              // 3) Get Started glued to the bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Get Started',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
