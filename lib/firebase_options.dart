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
        return macos;
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
    apiKey: 'AIzaSyCr5Ntt906v3ZechWpgOPCFYT9pYEIxRZs',
    appId: '1:1054775048480:web:a16ecd6e0a9f21e1f07f45',
    messagingSenderId: '1054775048480',
    projectId: 'shopping-server-590dd',
    authDomain: 'shopping-server-590dd.firebaseapp.com',
    databaseURL: 'https://shopping-server-590dd.firebaseio.com',
    storageBucket: 'shopping-server-590dd.appspot.com',
    measurementId: 'G-09PH6QE0JR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCI_9Z0QGX20CtKEmX8T0GeBgZqKaaI6Zs',
    appId: '1:1054775048480:android:ee268e9f018b09a3f07f45',
    messagingSenderId: '1054775048480',
    projectId: 'shopping-server-590dd',
    databaseURL: 'https://shopping-server-590dd.firebaseio.com',
    storageBucket: 'shopping-server-590dd.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBCEDThM_hWW1rkw9lZg8SY0JBIibwsPfk',
    appId: '1:1054775048480:ios:10f66549f5042b14f07f45',
    messagingSenderId: '1054775048480',
    projectId: 'shopping-server-590dd',
    databaseURL: 'https://shopping-server-590dd.firebaseio.com',
    storageBucket: 'shopping-server-590dd.appspot.com',
    androidClientId: '1054775048480-065c08b8q1b658gqo4n3cssajuj75eka.apps.googleusercontent.com',
    iosClientId: '1054775048480-2kq1rdphq4hle23uj6ehb6je7qm3t9g1.apps.googleusercontent.com',
    iosBundleId: 'com.example.artistree',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBCEDThM_hWW1rkw9lZg8SY0JBIibwsPfk',
    appId: '1:1054775048480:ios:b840e0a5dfda5fcaf07f45',
    messagingSenderId: '1054775048480',
    projectId: 'shopping-server-590dd',
    databaseURL: 'https://shopping-server-590dd.firebaseio.com',
    storageBucket: 'shopping-server-590dd.appspot.com',
    androidClientId: '1054775048480-065c08b8q1b658gqo4n3cssajuj75eka.apps.googleusercontent.com',
    iosClientId: '1054775048480-ei67tk4g5eu80r8nobsmjanuhlcjo4dr.apps.googleusercontent.com',
    iosBundleId: 'com.example.artistree.RunnerTests',
  );
}
