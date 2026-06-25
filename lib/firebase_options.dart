import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAEYZBDOjkWZtvXOiwAcKT3RKbPcsQVDeg',
    appId: '1:622185595584:web:cf5e3867d2974a5dc52325',
    messagingSenderId: '622185595584',
    projectId: 'quran-205d8',
    authDomain: 'quran-205d8.firebaseapp.com',
    databaseURL: 'https://quran-205d8-default-rtdb.firebaseio.com',
    storageBucket: 'quran-205d8.firebasestorage.app',
    measurementId: 'G-MGQLFTTQYN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAEYZBDOjkWZtvXOiwAcKT3RKbPcsQVDeg',
    appId: '1:622185595584:android:72f2e519c96b7dc9c52325', // Standard generated format for Android
    messagingSenderId: '622185595584',
    projectId: 'quran-205d8',
    databaseURL: 'https://quran-205d8-default-rtdb.firebaseio.com',
    storageBucket: 'quran-205d8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAEYZBDOjkWZtvXOiwAcKT3RKbPcsQVDeg',
    appId: '1:622185595584:ios:bb18a599c96b7dc9c52325', // Standard generated format for iOS
    messagingSenderId: '622185595584',
    projectId: 'quran-205d8',
    databaseURL: 'https://quran-205d8-default-rtdb.firebaseio.com',
    storageBucket: 'quran-205d8.firebasestorage.app',
    iosBundleId: 'com.example.quranApp',
  );
}
