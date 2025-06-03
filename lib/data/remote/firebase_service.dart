import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => currentUser != null;

  Future<FirebaseService> init() async {
    // Initialize Firebase services if needed
    return this;
  }

  // Authentication Methods
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update display name
    await credential.user?.updateDisplayName(displayName);
    
    // Create user document in Firestore
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'displayName': displayName,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // User Profile Methods
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    if (!isSignedIn) return;

    await currentUser!.updateDisplayName(displayName);
    await currentUser!.updatePhotoURL(photoURL);

    await _firestore.collection('users').doc(currentUser!.uid).set({
      'displayName': displayName,
      'photoURL': photoURL,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
} 