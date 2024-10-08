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
    apiKey: 'AIzaSyBHmPN6zsg4EZIhih__BPWdYdAEc-KYYZQ',
    appId: '1:966571855143:web:f4d8cc7a9cc9fec8e12d02',
    messagingSenderId: '966571855143',
    projectId: 'gestticket-71869',
    authDomain: 'gestticket-71869.firebaseapp.com',
    storageBucket: 'gestticket-71869.appspot.com',
    measurementId: 'G-K00HL15SSQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC9GEsNv3GKJzg2SWgtM2SCBF80GzYCKJw',
    appId: '1:966571855143:android:eba4164b4fc11fc5e12d02',
    messagingSenderId: '966571855143',
    projectId: 'gestticket-71869',
    storageBucket: 'gestticket-71869.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCK-cWZ-XWpQ6Gzcxee4SuHHmIE4xNjibQ',
    appId: '1:966571855143:ios:085fc946943768dfe12d02',
    messagingSenderId: '966571855143',
    projectId: 'gestticket-71869',
    storageBucket: 'gestticket-71869.appspot.com',
    iosBundleId: 'com.example.gestTicket',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCK-cWZ-XWpQ6Gzcxee4SuHHmIE4xNjibQ',
    appId: '1:966571855143:ios:085fc946943768dfe12d02',
    messagingSenderId: '966571855143',
    projectId: 'gestticket-71869',
    storageBucket: 'gestticket-71869.appspot.com',
    iosBundleId: 'com.example.gestTicket',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBHmPN6zsg4EZIhih__BPWdYdAEc-KYYZQ',
    appId: '1:966571855143:web:600a4034fd5d61d3e12d02',
    messagingSenderId: '966571855143',
    projectId: 'gestticket-71869',
    authDomain: 'gestticket-71869.firebaseapp.com',
    storageBucket: 'gestticket-71869.appspot.com',
    measurementId: 'G-FSKC64VRXV',
  );
}
