import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoWebApiKeyForTokTokDeliveryApp0',
    appId: '1:100000000000:web:toktokdeliveryapp0000',
    messagingSenderId: '100000000000',
    projectId: 'toktok-delivery-app',
    authDomain: 'toktok-delivery-app.firebaseapp.com',
    storageBucket: 'toktok-delivery-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoAndroidApiKeyForTokTok000',
    appId: '1:100000000000:android:toktokdeliveryapp0',
    messagingSenderId: '100000000000',
    projectId: 'toktok-delivery-app',
    storageBucket: 'toktok-delivery-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoIosApiKeyForTokTokApp0000',
    appId: '1:100000000000:ios:toktokdeliveryapp00000',
    messagingSenderId: '100000000000',
    projectId: 'toktok-delivery-app',
    storageBucket: 'toktok-delivery-app.appspot.com',
    iosBundleId: 'com.example.deliveryApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDemoMacosApiKeyForTokTokApp0000',
    appId: '1:100000000000:ios:toktokdeliveryapp00000',
    messagingSenderId: '100000000000',
    projectId: 'toktok-delivery-app',
    storageBucket: 'toktok-delivery-app.appspot.com',
    iosBundleId: 'com.example.deliveryApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDemoWindowsApiKeyForTokTokApp0',
    appId: '1:100000000000:web:toktokdeliveryapp0000',
    messagingSenderId: '100000000000',
    projectId: 'toktok-delivery-app',
    authDomain: 'toktok-delivery-app.firebaseapp.com',
    storageBucket: 'toktok-delivery-app.appspot.com',
  );
}
