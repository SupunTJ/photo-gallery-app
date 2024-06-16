import 'package:flutter/material.dart';
import 'package:photo_gallery_app/providers/gallery_provider.dart';
import 'package:photo_gallery_app/screens/full_screen_image.dart';
import 'package:photo_gallery_app/screens/login_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  void _goToLoginScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GalleryProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => _goToLoginScreen(context),
        ),
        actions: [
          if (provider.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () => provider.signOut(context),
            ),
          if (provider.selectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: provider.selectedUrls.isNotEmpty
                  ? () => provider.deleteSelectedImages(context)
                  : null,
            ),
          if (provider.imageUrls.isNotEmpty && provider.isAuthenticated)
            IconButton(
              icon: Icon(
                provider.selectionMode ? Icons.cancel : Icons.select_all,
              ),
              onPressed: () => provider.toggleSelectionMode(context),
            ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'assets/background.jpg',
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: provider.imageUrls.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('No images to Display.'),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemCount: provider.imageUrls.length,
                    itemBuilder: (context, index) {
                      String imageUrl = provider.imageUrls[index];
                      bool isSelected =
                          provider.selectedUrls.contains(imageUrl);
                      return GestureDetector(
                        onTap: () {
                          if (provider.selectionMode) {
                            provider.selectImage(imageUrl);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FullScreenImage(imageUrl: imageUrl),
                              ),
                            );
                          }
                        },
                        onLongPress: () {
                          if (!provider.selectionMode) {
                            provider.toggleSelectionMode(context);
                          }
                          provider.selectImage(imageUrl);
                        },
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
                            if (provider.selectionMode && isSelected)
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
        ],
      ),
      floatingActionButton: provider.isAuthenticated
          ? FloatingActionButton(
              onPressed: () => provider.pickImages(context),
              tooltip: 'Pick Images',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
