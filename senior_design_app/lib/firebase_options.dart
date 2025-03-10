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
    apiKey: 'AIzaSyBKMotRUFnEcQUSz3Ma-iWow9ZgGIi6wBA',
    appId: '1:985837680709:web:193f83d831085f94454b2c',
    messagingSenderId: '985837680709',
    projectId: 'seniordesignpeiss',
    authDomain: 'seniordesignpeiss.firebaseapp.com',
    storageBucket: 'seniordesignpeiss.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB1KcpBbtvEpBv71tS8Hi1w89-zLyGsufk',
    appId: '1:985837680709:android:45c104a3231ed839454b2c',
    messagingSenderId: '985837680709',
    projectId: 'seniordesignpeiss',
    storageBucket: 'seniordesignpeiss.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDtprklNw8NN7YkOw2UTpT7ufx4K_Ck27g',
    appId: '1:985837680709:ios:7ca3823829cca3b4454b2c',
    messagingSenderId: '985837680709',
    projectId: 'seniordesignpeiss',
    storageBucket: 'seniordesignpeiss.firebasestorage.app',
    iosBundleId: 'com.peiss.senior-design-app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDtprklNw8NN7YkOw2UTpT7ufx4K_Ck27g',
    appId: '1:985837680709:ios:1deeac225dee283d454b2c',
    messagingSenderId: '985837680709',
    projectId: 'seniordesignpeiss',
    storageBucket: 'seniordesignpeiss.firebasestorage.app',
    iosBundleId: 'com.example.seniorDesignApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBKMotRUFnEcQUSz3Ma-iWow9ZgGIi6wBA',
    appId: '1:985837680709:web:733e61aade31ec4e454b2c',
    messagingSenderId: '985837680709',
    projectId: 'seniordesignpeiss',
    authDomain: 'seniordesignpeiss.firebaseapp.com',
    storageBucket: 'seniordesignpeiss.firebasestorage.app',
  );

}