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
                        // Perform sign-in action here if needed
                        // For example:
                        // User? user = await loginProvider.signInWithGoogle();
                        // if (user != null) {
                        //   loginProvider.navigateToHomePage(context);
                        // }
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HomeScreen(title: 'Flutter Demo Home Page'),
                          ),
                        );
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
                                HomeScreen(title: 'Flutter Demo Home Page'),
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
