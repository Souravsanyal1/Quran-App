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
    apiKey: 'AIzaSyB9v7oXVPpJgWG1CwLnO9cR3TM-HEw4UwI',
    appId: '1:622185595584:android:13f0b967b1658a04c52325',
    messagingSenderId: '622185595584',
    projectId: 'quran-205d8',
    databaseURL: 'https://quran-205d8-default-rtdb.firebaseio.com',
    storageBucket: 'quran-205d8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAbe88IT92heAwimvA0_nMtbtnD2vkZhSU',
    appId: '1:622185595584:ios:85cee353fbe93dfdc52325',
    messagingSenderId: '622185595584',
    projectId: 'quran-205d8',
    databaseURL: 'https://quran-205d8-default-rtdb.firebaseio.com',
    storageBucket: 'quran-205d8.firebasestorage.app',
    iosBundleId: 'com.quranapp.quranApp',
  );
}
