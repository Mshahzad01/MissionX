import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/models/user_model.dart';
import '../../routes/app_routes.dart';
import '../../data/remote/firebase_service.dart';
import '../routes/app_pages.dart';

class AuthController extends GetxController {
  final FirebaseService firebaseService;
  final _isLoading = false.obs;
  final _error = Rxn<String>();

  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  User? get currentUser => firebaseService.currentUser;
  bool get isSignedIn => firebaseService.isSignedIn;

  AuthController({required this.firebaseService});

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final referralCodeController = TextEditingController();

  final isPasswordVisible = false.obs;
  final googleUser = Rx<UserModel?>(null);
  final termsAccepted = false.obs;
  final userModel = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen(_handleAuthStateChange);
  }

  Future<void> initializeUserData(User firebaseUser) async {
    try {
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      
      if (doc.exists) {
        userModel.value = UserModel.fromJson(doc.data()!);
      } else {
        // Handle case where user exists in Firebase Auth but not in Firestore
        await signOut();
      }
    } catch (e) {
      print('Error initializing user data: $e');
      await signOut();
    }
  }

  Future<void> _handleAuthStateChange(User? firebaseUser) async {
    try {
      if (firebaseUser != null) {
        // User is logged in
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        
        if (doc.exists) {
          userModel.value = UserModel.fromJson(doc.data()!);
          // Only navigate if on splash screen
          if (Get.currentRoute == AppRoutes.splash) {
            Get.offAllNamed(AppRoutes.home);
          }
        } else {
          // If user exists in Auth but not in Firestore, create user doc
          final newUser = UserModel(
            uid: firebaseUser.uid,
            email: firebaseUser.email!,
            name: firebaseUser.displayName ?? 'Player',
          );
          
          await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .set(newUser.toJson());
              
          userModel.value = newUser;
          if (Get.currentRoute == AppRoutes.splash) {
            Get.offAllNamed(AppRoutes.home);
          }
        }
      } else {
        userModel.value = null;
        // Only navigate to welcome if on splash screen
        if (Get.currentRoute == AppRoutes.splash) {
          Get.offAllNamed(AppRoutes.welcome);
        }
      }
    } catch (e) {
      print('Error in auth state change: $e');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    usernameController.dispose();
    referralCodeController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = null;
      await firebaseService.signUpWithEmailPassword(
        email: email,
        password: password,
        displayName: name,
      );
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to sign up: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _isLoading.value = true;
      _error.value = null;
      await firebaseService.signInWithEmailPassword(email, password);
      Get.offAllNamed(Routes.HOME);
      return true;
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to sign in: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading.value = true;
      _error.value = null;
      await firebaseService.signInWithGoogle();
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to sign in with Google: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading.value = true;
      _error.value = null;
      await firebaseService.signOut();
      Get.offAllNamed(Routes.WELCOME);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to sign out: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  bool _validateSignInInputs() {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your password',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  bool _validateSignUpInputs() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your name',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (emailController.text.trim().isEmpty ||
        !GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        'Error',
        'Please enter a valid email',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (passwordController.text.length < 6) {
      Get.snackbar(
        'Error',
        'Password must be at least 6 characters',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  String _getFirebaseErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Wrong password';
        case 'email-already-in-use':
          return 'Email is already registered';
        case 'invalid-email':
          return 'Invalid email address';
        case 'weak-password':
          return 'Password is too weak';
        default:
          return error.message ?? 'An error occurred';
      }
    }
    return 'An error occurred';
  }

  void showPrivacyPolicy() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    '''Privacy Policy and Terms of Use for TapOrder

Effective Date: 29 January 2025

TapOrder is a mobile gaming application designed exclusively for fun, entertainment, and providing users with an engaging and enjoyable experience. This app is specifically created for users in Pakistan and is accessible to individuals aged 8 years and above, ensuring that it caters to a wide audience while maintaining a safe and family-friendly environment.

By using TapOrder, you agree to the limited collection of non-sensitive personal information, such as your email address, gameplay statistics, and in-app activity, solely for the purpose of improving your experience and providing personalized features. We are committed to safeguarding your privacy and ensuring that your data is never shared with third parties without your explicit consent.

For further inquiries, feedback, or support, users can reach out to our customer service team at cipherstackdigital@gmail.com''',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showTermsOfUse() {
    // Similar dialog as above but with Terms of Use text
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading.value = true;
      _error.value = null;
      await firebaseService.sendPasswordResetEmail(email);
      Get.back(); // Close dialog
      Get.snackbar(
        'Success',
        'Password reset email sent to $email',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to send reset email: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> forgotPassword(String email) => resetPassword(email);
} 