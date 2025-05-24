import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthRepository {
  final _auth = FirebaseAuth.instance;
  
  // Stream that updates on auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  // Register with email and password
  Future<UserCredential> register(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to register: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  // Sign in with GitHub (web only)
  Future<UserCredential> signInWithGitHub() async {
    try {
      if (kIsWeb) {
        GithubAuthProvider githubProvider = GithubAuthProvider();
        return await _auth.signInWithPopup(githubProvider);
      } else {
        throw UnimplementedError('GitHub sign-in is only implemented for web. For mobile, implement a custom OAuth flow.');
      }
    } catch (e) {
      throw Exception('Failed to sign in with GitHub: \\${e.toString()}');
    }
  }
}
