import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:photo_gallery_app/full_screen_image.dart';
import 'package:photo_gallery_app/login_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _imageUrls = [];
  List<String> _selectedUrls = [];
  bool _selectionMode = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _fetchImageUrls();
  }

  void _checkAuthentication() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _isAuthenticated = user != null;
    });
  }

  Future<void> _fetchImageUrls() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('images').get();
      List<String> urls =
          snapshot.docs.map((doc) => doc['url'] as String).toList();
      setState(() {
        _imageUrls = urls;
      });
    } catch (e) {
      print("Error fetching image URLs: $e");
    }
  }

  Future<void> pickImages() async {
    if (!_isAuthenticated) {
      _showLoginAlert();
      return;
    }

    try {
      final List<XFile>? selectedImages = await ImagePicker().pickMultiImage();
      if (selectedImages != null && selectedImages.isNotEmpty) {
        for (XFile image in selectedImages) {
          final String url = await _uploadImageToFirebase(image);
          await _saveImageUrlToFirestore(url);
          setState(() {
            _imageUrls.add(url);
          });
        }
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

  Future<void> _deleteImage(String url) async {
    if (!_isAuthenticated) {
      _showLoginAlert();
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

      setState(() {
        _imageUrls.remove(url);
      });
    } catch (e) {
      print("Error deleting image: $e");
    }
  }

  Future<void> _deleteSelectedImages() async {
    if (!_isAuthenticated) {
      _showLoginAlert();
      return;
    }

    for (String url in _selectedUrls) {
      await _deleteImage(url);
    }
    setState(() {
      _selectionMode = false;
      _selectedUrls.clear();
    });
  }

  void _toggleSelectionMode() {
    if (!_isAuthenticated) {
      _showLoginAlert();
      return;
    }

    setState(() {
      _selectionMode = !_selectionMode;
      _selectedUrls.clear();
    });
  }

  void _onThumbnailTap(String url) {
    if (_selectionMode) {
      setState(() {
        if (_selectedUrls.contains(url)) {
          _selectedUrls.remove(url);
        } else {
          _selectedUrls.add(url);
        }
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImage(imageUrl: url),
        ),
      );
    }
  }

  void _onThumbnailLongPress(String url) {
    if (!_isAuthenticated) {
      _showLoginAlert();
      return;
    }

    setState(() {
      _selectionMode = true;
      if (!_selectedUrls.contains(url)) {
        _selectedUrls.add(url);
      }
    });
  }

  void _showLoginAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Required'),
          content:
              const Text('You need to be logged in to perform this action.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      setState(() {
        _isAuthenticated = false;
      });
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  void _goToLoginScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _goToLoginScreen,
        ),
        actions: [
          if (_isAuthenticated)
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: _signOut,
            ),
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed:
                  _selectedUrls.isNotEmpty ? _deleteSelectedImages : null,
            ),
          if (_imageUrls.isNotEmpty && _isAuthenticated)
            IconButton(
              icon: Icon(_selectionMode ? Icons.cancel : Icons.select_all),
              onPressed: _toggleSelectionMode,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _imageUrls.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No images selected.'),
                    if (!_isAuthenticated)
                      ElevatedButton(
                        onPressed: _goToLoginScreen,
                        child: const Text('Login'),
                      ),
                  ],
                ),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: _imageUrls.length,
                itemBuilder: (context, index) {
                  String imageUrl = _imageUrls[index];
                  bool isSelected = _selectedUrls.contains(imageUrl);
                  return GestureDetector(
                    onTap: () => _onThumbnailTap(imageUrl),
                    onLongPress: () => _onThumbnailLongPress(imageUrl),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            color: isSelected ? Colors.black45 : null,
                            colorBlendMode:
                                isSelected ? BlendMode.darken : null,
                          ),
                        ),
                        if (_selectionMode && isSelected)
                          const Center(
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: _isAuthenticated
          ? FloatingActionButton(
              onPressed: pickImages,
              tooltip: 'Pick Images',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
