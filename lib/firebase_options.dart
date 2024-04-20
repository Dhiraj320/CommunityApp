// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBjzDkJqT7nEBVKwhix91ZBY1uYDuhlNxo',
    appId: '1:427153043701:web:f490a94bf9ab8573de55bc',
    messagingSenderId: '427153043701',
    projectId: 'redditclone-f9bd3',
    authDomain: 'redditclone-f9bd3.firebaseapp.com',
    storageBucket: 'redditclone-f9bd3.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBbsRrtZO_7u1vqbyVIycIJq2BLT77HHKM',
    appId: '1:427153043701:android:c2158f8c7763653dde55bc',
    messagingSenderId: '427153043701',
    projectId: 'redditclone-f9bd3',
    storageBucket: 'redditclone-f9bd3.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBzBmHDZ2g6sr1VLvXqMur4aQu569tJtZQ',
    appId: '1:427153043701:ios:0dc4cd26078589dade55bc',
    messagingSenderId: '427153043701',
    projectId: 'redditclone-f9bd3',
    storageBucket: 'redditclone-f9bd3.appspot.com',
    iosBundleId: 'com.example.reditClone',
  );
}