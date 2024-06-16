import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_gallery_app/providers/login_provider.dart';
import 'package:photo_gallery_app/screens/home_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Consumer<LoginProvider>(
          builder: (context, loginProvider, _) => loginProvider.isLoading
              ? CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        User? user = await loginProvider.signInWithGoogle();
                        if (user != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HomeScreen(title: 'Image Grid Gallery'),
                            ),
                          );
                        }
                      },
                      child: const Text('Sign in with Google'),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HomeScreen(title: 'Image Grid Gallery'),
                          ),
                        );
                      },
                      child: const Text('View Without Signing In'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
