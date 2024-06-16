import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Screen Image'),
        // Optional: You can customize the app bar background here
        backgroundColor: Color.fromARGB(133, 83, 137, 218),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'assets/background.jpg', // Replace with your actual asset image path
            fit: BoxFit.cover,
          ),
          Center(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain, // Adjust the fit as needed
            ),
          ),
        ],
      ),
    );
  }
}
