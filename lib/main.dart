import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:photo_gallery_app/providers/gallery_provider.dart';
import 'package:photo_gallery_app/screens/home_screen.dart';
import 'package:photo_gallery_app/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:photo_gallery_app/providers/login_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GalleryProvider>(
          create: (_) => GalleryProvider(),
        ),
        ChangeNotifierProvider<LoginProvider>(
          create: (_) => LoginProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Photo Gallery App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Consumer<LoginProvider>(
          builder: (context, loginProvider, _) {
            if (loginProvider.isAuthenticated) {
              return HomeScreen(title: 'Image Grid Gallery');
            } else {
              return LoginScreen();
            }
          },
        ),
      ),
    );
  }
}
