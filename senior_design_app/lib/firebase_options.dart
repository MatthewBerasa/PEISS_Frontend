// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCha6YX_e4H0vSKxiiO3MvJBdBM_yVpFN4',
    appId: '1:364548731299:web:99d7b2c7fb3bafcaa1ea16',
    messagingSenderId: '364548731299',
    projectId: 'peiss-f237f',
    authDomain: 'peiss-f237f.firebaseapp.com',
    storageBucket: 'peiss-f237f.firebasestorage.app',
    measurementId: 'G-BPSX7SZDZW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCi6wW-6BkV0yPydezZNbhJT0q3azi_gP4',
    appId: '1:364548731299:android:5b85dedf1ffe56fca1ea16',
    messagingSenderId: '364548731299',
    projectId: 'peiss-f237f',
    storageBucket: 'peiss-f237f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_PevlkSn5IJ3C5j8P3hemTzhiziqpw9Y',
    appId: '1:364548731299:ios:4bacc2bbde893c8aa1ea16',
    messagingSenderId: '364548731299',
    projectId: 'peiss-f237f',
    storageBucket: 'peiss-f237f.firebasestorage.app',
    iosBundleId: 'com.example.seniorDesignApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB_PevlkSn5IJ3C5j8P3hemTzhiziqpw9Y',
    appId: '1:364548731299:ios:4bacc2bbde893c8aa1ea16',
    messagingSenderId: '364548731299',
    projectId: 'peiss-f237f',
    storageBucket: 'peiss-f237f.firebasestorage.app',
    iosBundleId: 'com.example.seniorDesignApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCha6YX_e4H0vSKxiiO3MvJBdBM_yVpFN4',
    appId: '1:364548731299:web:c795fc17da5c2889a1ea16',
    messagingSenderId: '364548731299',
    projectId: 'peiss-f237f',
    authDomain: 'peiss-f237f.firebaseapp.com',
    storageBucket: 'peiss-f237f.firebasestorage.app',
    measurementId: 'G-ZZ63EWNL78',
  );
}
