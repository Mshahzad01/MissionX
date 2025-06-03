import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_pages.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Scaffold(
      body:  Container(

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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Welcome Animation
                Lottie.asset(
                  'assets/animations/welcome_animation.json',
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                // Welcome Text
                Text(
                  'Welcome to MissionX',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your journey to productivity starts here',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 48),
                // Google Sign In Button
                ElevatedButton.icon(
                  onPressed: () {
                    final authController = Get.find<AuthController>();
                    authController.signInWithGoogle();
                  },
                  icon: Image.asset(
                    'assets/images/google_logo.png',
                    height: 24,
                  ),
                  label: const Text('Continue with Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 16),
                // Email Sign In Button
                ElevatedButton(
                  onPressed: () => Get.toNamed(Routes.LOGIN),
                  child: const Text('Sign in with Email'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 24),
                // Terms and Privacy Text
                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 