import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_sign_in/google_sign_in.dart'; // TODO: Fix Google Sign-In API for version 7.2.0
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Create user in Firebase Auth
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user == null) return null;

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }

      // Send email verification
      await user.sendEmailVerification();

      // Create user document in Firestore
      final UserModel userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        photoUrl: null,
        partnerId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user == null) return null;

      // Get user data from Firestore
      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();

      if (docSnapshot.exists) {
        return UserModel.fromMap(docSnapshot.data()!, user.uid);
      } else {
        // Create user document if it doesn't exist
        final userModel = UserModel.fromFirebaseUser(user);
        await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
        return userModel;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with Google
  // TODO: Implement Google Sign-In for mobile using google_sign_in 7.2.0 API
  Future<UserModel?> signInWithGoogle() async {
    throw UnimplementedError('Google Sign-In is not yet implemented for mobile platforms. Use email/password authentication instead.');
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // TODO: Add Google Sign-In sign out when implemented
      await _auth.signOut();
    } catch (e) {
      throw 'Error signing out. Please try again.';
    }
  }

  // Check if current user's email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Send email verification to current user
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in.';
      }

      if (user.emailVerified) {
        throw 'Email is already verified.';
      }

      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        throw 'Too many verification emails sent. Please wait a few minutes before trying again.';
      }
      throw 'Error sending verification email. Please try again.';
    } catch (e) {
      rethrow;
    }
  }

  // Reload current user to check for email verification status
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      throw 'Error reloading user data.';
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();

      if (docSnapshot.exists) {
        return UserModel.fromMap(docSnapshot.data()!, uid);
      }
      return null;
    } catch (e) {
      throw 'Error fetching user data.';
    }
  }

  // Update user data in Firestore
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = DateTime.now();
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw 'Error updating user data.';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak. Please use at least 8 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      default:
        return 'Authentication failed: ${e.message ?? "Unknown error"}';
    }
  }
}
