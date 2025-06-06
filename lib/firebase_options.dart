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
    apiKey: 'AIzaSyDz7m5FEO9lJrhKQtbu0P4WXJw3Y20EOP0',
    appId: '1:709035031899:web:2efa33b23595b19f356e7e',
    messagingSenderId: '709035031899',
    projectId: 'missionx-72ae1',
    authDomain: 'missionx-72ae1.firebaseapp.com',
    storageBucket: 'missionx-72ae1.firebasestorage.app',
    measurementId: 'G-4RL98R724N',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBX3HydtHlhMtjsQ8avSSdcVyd8h-vav0Q',
    appId: '1:709035031899:android:3b6cfa3ba13ba277356e7e',
    messagingSenderId: '709035031899',
    projectId: 'missionx-72ae1',
    storageBucket: 'missionx-72ae1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCYsEl_Bpzz0_3Nmtb3Xesk78QCoEbzvmo',
    appId: '1:709035031899:ios:53892972bddd416e356e7e',
    messagingSenderId: '709035031899',
    projectId: 'missionx-72ae1',
    storageBucket: 'missionx-72ae1.firebasestorage.app',
    iosBundleId: 'com.example.missionx',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCYsEl_Bpzz0_3Nmtb3Xesk78QCoEbzvmo',
    appId: '1:709035031899:ios:53892972bddd416e356e7e',
    messagingSenderId: '709035031899',
    projectId: 'missionx-72ae1',
    storageBucket: 'missionx-72ae1.firebasestorage.app',
    iosBundleId: 'com.example.missionx',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDz7m5FEO9lJrhKQtbu0P4WXJw3Y20EOP0',
    appId: '1:709035031899:web:5dd497d85e4ba753356e7e',
    messagingSenderId: '709035031899',
    projectId: 'missionx-72ae1',
    authDomain: 'missionx-72ae1.firebaseapp.com',
    storageBucket: 'missionx-72ae1.firebasestorage.app',
    measurementId: 'G-TBFQTY5613',
  );
}
