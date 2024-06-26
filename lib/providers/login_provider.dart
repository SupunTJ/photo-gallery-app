import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:photo_gallery_app/screens/home_screen.dart';

class LoginProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;
  User? _currentUser;

  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return null; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      _currentUser = userCredential.user;
      _isLoading = false;
      notifyListeners();

      if (_currentUser != null) {
        // Navigate to home screen only if user is authenticated
        navigateToHomePage(context);
      }

      return _currentUser;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print(e.toString());
      return null;
    }
  }

  void navigateToHomePage(BuildContext context) {
    if (_currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(title: 'Image Grid Gallery'),
        ),
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut(); // Sign out from Google
      await _auth.signOut(); // Sign out from Firebase Auth
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print("Error signing out: $e");
    }
  }
}
