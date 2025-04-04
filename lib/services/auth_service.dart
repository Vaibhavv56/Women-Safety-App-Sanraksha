import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to track authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user getter
  User? get currentUser => _auth.currentUser;

  // Create user with email and password (using phone as email with domain)
  Future<UserCredential> createUserWithPhoneAndPassword(
      String phone, String password, String name, String? gender) async {
    // Create email from phone (since Firebase requires email for standard auth)
    String email = '${phone.replaceAll('+', '')}@sanrakshan25.com';
    
    // Create user in Firebase Auth
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Update display name
    if (userCredential.user != null) {
      await userCredential.user!.updateDisplayName(name);
      
      // Add user to Firestore with additional details
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'phone': phone,
        'gender': gender,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    
    return userCredential;
  }

  // Sign in with phone and password
  Future<UserCredential> signInWithPhoneAndPassword(String phone, String password) async {
    // Create email from phone (using same format as in createUserWithPhoneAndPassword)
    String email = '${phone.replaceAll('+', '')}@sanrakshan25.com';
    
    // Sign in with email and password
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update user profile
  Future<void> updateUserProfile(String? displayName, String? photoURL) async {
    if (_auth.currentUser != null) {
      await _auth.currentUser!.updateDisplayName(displayName);
      await _auth.currentUser!.updatePhotoURL(photoURL);
      
      // Also update Firestore
      if (displayName != null) {
        await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
          'name': displayName,
        });
      }
    }
  }

  // Update user details in Firestore
  Future<void> updateUserDetails({
    String? name,
    String? phone,
    String? gender,
  }) async {
    if (_auth.currentUser != null) {
      Map<String, dynamic> updates = {};
      
      if (name != null) {
        updates['name'] = name;
        await _auth.currentUser!.updateDisplayName(name);
      }
      
      if (phone != null) updates['phone'] = phone;
      if (gender != null) updates['gender'] = gender;
      
      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(_auth.currentUser!.uid).update(updates);
      }
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    if (_auth.currentUser != null) {
      String uid = _auth.currentUser!.uid;
      
      // Delete from Firestore first
      await _firestore.collection('users').doc(uid).delete();
      
      // Then delete from Auth
      await _auth.currentUser!.delete();
    }
  }

  // Check if user is signed in
  bool isUserSignedIn() {
    return _auth.currentUser != null;
  }

  // Get user ID
  String? getUserId() {
    return _auth.currentUser?.uid;
  }
}