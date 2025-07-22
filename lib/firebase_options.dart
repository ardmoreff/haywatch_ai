// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDzIlyCtI4aM_newqgFJylxwleSz2i34mI',
    appId: '1:231536197711:web:a9c466c18f9c509cd0ea3a',
    messagingSenderId: '231536197711',
    projectId: 'haywatch-ai',
    authDomain: 'haywatch-ai.firebaseapp.com',
    storageBucket: 'haywatch-ai.appspot.com',
    measurementId: 'G-JQRGYT1W4Z',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBM_XHqwdH9Qc3vu_YqIW0ggA7PEcXCDUE',
    appId: '1:231536197711:android:4195dd4ac2521f66d0ea3a',
    messagingSenderId: '231536197711',
    projectId: 'haywatch-ai',
    storageBucket: 'haywatch-ai.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD9tcYxKiFjX3mpcD3liDe0I33Ki7fJYJc',
    appId: '1:231536197711:ios:e1b21252d49bce6fd0ea3a',
    messagingSenderId: '231536197711',
    projectId: 'haywatch-ai',
    storageBucket: 'haywatch-ai.appspot.com',
    iosBundleId: 'com.ardmoreff.haywatch',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD9tcYxKiFjX3mpcD3liDe0I33Ki7fJYJc',
    appId: '1:231536197711:ios:992177a4d15af60fd0ea3a',
    messagingSenderId: '231536197711',
    projectId: 'haywatch-ai',
    storageBucket: 'haywatch-ai.appspot.com',
    iosBundleId: 'com.ardmoreff.haywatch',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDzIlyCtI4aM_newqgFJylxwleSz2i34mI',
    appId: '1:231536197711:web:95d29a82d9fef859d0ea3a',
    messagingSenderId: '231536197711',
    projectId: 'haywatch-ai',
    authDomain: 'haywatch-ai.firebaseapp.com',
    storageBucket: 'haywatch-ai.appspot.com',
    measurementId: 'G-KJJTYM0BBF',
  );
}
