import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class TestFirebaseApp {
  static bool _initialized = false;

  static Future<void> initializeApp() async {
    if (_initialized) {
      return;
    }

    TestWidgetsFlutterBinding.ensureInitialized();

    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    // Set up method channel mocks for Firebase Core
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/firebase_core'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'Firebase#initializeCore') {
          return [
            {
              'name': '[DEFAULT]',
              'options': {
                'apiKey': 'AIzaSy-test',
                'appId': '1:123456789:ios:abcdef',
                'messagingSenderId': '123456789',
                'projectId': 'test-project',
              },
              'pluginConstants': <String, dynamic>{},
            }
          ];
        }
        if (methodCall.method == 'Firebase#initializeApp') {
          return {
            'name': methodCall.arguments['appName'] ?? '[DEFAULT]',
            'options': methodCall.arguments['options'],
            'pluginConstants': <String, dynamic>{},
          };
        }
        if (methodCall.method == 'FirebaseApp#delete') {
          return null;
        }
        return null;
      },
    );

    // Set up method channel mocks for Cloud Firestore
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/cloud_firestore'),
      (MethodCall methodCall) async {
        // Handle all Firestore method calls
        if (methodCall.method.contains('Query') || methodCall.method.contains('DocumentReference')) {
          return <String, dynamic>{
            'data': <String, dynamic>{},
            'metadata': <String, dynamic>{
              'hasPendingWrites': false,
              'isFromCache': false,
            },
          };
        }
        if (methodCall.method == 'Firestore#enableNetwork') {
          return null;
        }
        if (methodCall.method == 'Firestore#disableNetwork') {
          return null;
        }
        return <String, dynamic>{};
      },
    );

    // Set up method channel mocks for Firebase Auth
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/firebase_auth'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'Auth#registerIdTokenListener') {
          return <String, dynamic>{};
        }
        if (methodCall.method == 'Auth#registerAuthStateListener') {
          return <String, dynamic>{};
        }
        if (methodCall.method == 'Auth#currentUser') {
          return null;
        }
        if (methodCall.method == 'User#reload') {
          return <String, dynamic>{};
        }
        return <String, dynamic>{};
      },
    );

    // Set up method channel mocks for Firebase Storage
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/firebase_storage'),
      (MethodCall methodCall) async {
        return <String, dynamic>{};
      },
    );

    // Initialize Firebase with test options
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSy-test',
          appId: '1:123456789:ios:abcdef',
          messagingSenderId: '123456789',
          projectId: 'test-project',
          storageBucket: 'test-project.appspot.com',
        ),
      );
      _initialized = true;
    } catch (e) {
      // Even if initialization throws, the method channels are set up
      // The app will handle Firebase errors gracefully
      _initialized = true;
    }
  }

  static void reset() {
    _initialized = false;
  }
}

