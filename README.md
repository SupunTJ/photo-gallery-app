# Photo Gallery App

A Flutter application that allows users to upload and display images in a visually appealing grid gallery. This app leverages Firebase for storage, database, and authentication functionalities.

App Demo:

```bash
https://youtu.be/l8hGBumfRk0
```

## Features

- Upload multiple images from your device's gallery
- Store uploaded images in Firebase Storage
- Save image URLs in Firebase Firestore
- Display all uploaded images in a responsive grid gallery
- User authentication with Firebase Auth and Google Sign-In

## Getting Started

To get started with this project, you'll need to have Flutter installed on your machine. If you haven't already, you can follow the [official Flutter installation guide](https://flutter.dev/docs/get-started/install) for your operating system.

### Prerequisites

- Flutter SDK
- Firebase account

### Setup

1. Clone the repository:

```bash
git clone https://github.com/SupunTJ/photo-gallery-app.git
```

2. Navigate to the project directory:

```bash
cd photo-gallery-app
```

3. Install the required dependencies:

```bash
flutter pub get
```

4. Set up Firebase:
   - Create a new Firebase project in the [Firebase Console](https://console.firebase.google.com/).
   - Enable the Firestore Database, Storage, and Authentication services.
   - Download the `google-services.json` file and place it in the `android/app` directory for Android, and the `ios/Runner` directory for iOS.

5. Run the app:

```bash
flutter run
```

## Dependencies

This project uses the following dependencies:

- [cupertino_icons](https://pub.dev/packages/cupertino_icons)
- [image_picker](https://pub.dev/packages/image_picker)
- [path_provider](https://pub.dev/packages/path_provider)
- [firebase_core](https://pub.dev/packages/firebase_core)
- [firebase_storage](https://pub.dev/packages/firebase_storage)
- [cloud_firestore](https://pub.dev/packages/cloud_firestore)
- [firebase_auth](https://pub.dev/packages/firebase_auth)
- [google_sign_in](https://pub.dev/packages/google_sign_in)
- [provider](https://pub.dev/packages/provider)

## Acknowledgments

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
