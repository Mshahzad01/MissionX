import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Navigate to welcome screen after animation
    Future.delayed(const Duration(seconds: 5), () {
      final authController = Get.find<AuthController>();
      if (authController.isSignedIn) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/welcome');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // backgroundColor: Theme.of(context).colorScheme.primary,
      body: 
       Container(

        decoration: BoxDecoration(

          gradient: LinearGradient(

            begin: Alignment.topCenter,

            end: Alignment.bottomCenter,

            colors: [

              Theme.of(context).colorScheme.primary,

              Theme.of(context).colorScheme.secondary,

            ],

          ),

        ),
        child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo Animation
              Lottie.asset(
                'assets/animations/task_animation.json',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              // App Name
              Text(
                'MissionX',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 10),
              // Tagline
              Text(
                'Your Personal Task Manager',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),),
    );
  }
} 