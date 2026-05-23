import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configuration Firebase générée à partir de la console Firebase
/// (projet `diapaler-africa`).
///
/// Pour la démo Livrable 0, seule la plateforme Web est configurée
/// (`flutter run -d chrome`). Les valeurs ci-dessous sont publiques :
/// la sécurité réelle vient des règles Auth + Realtime Database,
/// et de la liste de domaines autorisés côté Firebase.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return web;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBihgsIao5ccFMCUFYnRDyTRvFDCrfyv4A',
    authDomain: 'diapaler-africa.firebaseapp.com',
    databaseURL:
        'https://diapaler-africa-default-rtdb.europe-west1.firebasedatabase.app',
    projectId: 'diapaler-africa',
    storageBucket: 'diapaler-africa.firebasestorage.app',
    messagingSenderId: '742284091826',
    appId: '1:742284091826:android:dd155e4f84c64c837cc4ab',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBBFVDwfhUKGMrvsqE2EdZG6dODj4BrKMk',
    authDomain: 'diapaler-africa.firebaseapp.com',
    databaseURL:
        'https://diapaler-africa-default-rtdb.europe-west1.firebasedatabase.app',
    projectId: 'diapaler-africa',
    storageBucket: 'diapaler-africa.firebasestorage.app',
    messagingSenderId: '742284091826',
    appId: '1:742284091826:web:528ae3003273cc8b7cc4ab',
  );
}
