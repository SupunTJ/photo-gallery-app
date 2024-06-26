import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:photo_gallery_app/screens/login_screen.dart';

class GalleryProvider with ChangeNotifier {
  List<String> _imageUrls = [];
  List<String> _selectedUrls = [];
  bool _selectionMode = false;
  bool _isAuthenticated = false;

  List<String> get imageUrls => _imageUrls;
  List<String> get selectedUrls => _selectedUrls;
  bool get selectionMode => _selectionMode;
  bool get isAuthenticated => _isAuthenticated;

  GalleryProvider() {
    checkAuthentication();
    _fetchImageUrls();
  }

  void checkAuthentication() {
    User? user = FirebaseAuth.instance.currentUser;
    _isAuthenticated = user != null;
    notifyListeners();
  }

  Future<void> _fetchImageUrls() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('images').get();
      List<String> urls =
          snapshot.docs.map((doc) => doc['url'] as String).toList();
      _imageUrls = urls;
      notifyListeners();
    } catch (e) {
      print("Error fetching image URLs: $e");
    }
  }

  Future<void> pickImages(BuildContext context) async {
    if (!_isAuthenticated) {
      _showLoginAlert(context);
      return;
    }

    try {
      final List<XFile>? selectedImages = await ImagePicker().pickMultiImage();
      if (selectedImages != null && selectedImages.isNotEmpty) {
        for (XFile image in selectedImages) {
          final String url = await _uploadImageToFirebase(image);
          await _saveImageUrlToFirestore(url);
          _imageUrls.add(url);
        }
        notifyListeners();
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }

  Future<String> _uploadImageToFirebase(XFile image) async {
    try {
      final String fileName = path.basename(image.path);
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('uploads/$fileName');
      final UploadTask uploadTask = storageRef.putFile(File(image.path));
      final TaskSnapshot snapshot = await uploadTask;
      final String url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      print("Error uploading image: $e");
      throw e;
    }
  }

  Future<void> _saveImageUrlToFirestore(String url) async {
    await FirebaseFirestore.instance.collection('images').add({'url': url});
  }

  Future<void> deleteImage(BuildContext context, String url) async {
    if (!_isAuthenticated) {
      _showLoginAlert(context);
      return;
    }

    try {
      await FirebaseStorage.instance.refFromURL(url).delete();

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('images')
          .where('url', isEqualTo: url)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      _imageUrls.remove(url);
      notifyListeners();
    } catch (e) {
      print("Error deleting image: $e");
    }
  }

  Future<void> deleteSelectedImages(BuildContext context) async {
    if (!_isAuthenticated) {
      _showLoginAlert(context);
      return;
    }

    for (String url in _selectedUrls) {
      await deleteImage(context, url);
    }

    _selectionMode = false;
    _selectedUrls.clear();
    notifyListeners();
  }

  void toggleSelectionMode(BuildContext context) {
    if (!_isAuthenticated) {
      _showLoginAlert(context);
      return;
    }

    _selectionMode = !_selectionMode;
    _selectedUrls.clear();
    notifyListeners();
  }

  void selectImage(String url) {
    if (_selectedUrls.contains(url)) {
      _selectedUrls.remove(url);
    } else {
      _selectedUrls.add(url);
    }
    notifyListeners();
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      _isAuthenticated = false;
      notifyListeners();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  void _showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Required'),
          content:
              const Text('You need to be logged in to perform this action.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
