import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class FirebaseTestMocks {
  static bool _isSetup = false;

  static Future<void> setupFirebaseMocks() async {
    if (_isSetup) {
      return;
    }

    TestWidgetsFlutterBinding.ensureInitialized();

    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    // Set up Firebase Core method channel handler FIRST, before any Firebase code runs
    // This handler must respond to Firebase#initializeCore BEFORE Firebase.initializeApp() is called
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/firebase_core'),
      (MethodCall methodCall) async {
        // Handle Firebase#initializeCore - this is called when Firebase.app() is accessed
        if (methodCall.method == 'Firebase#initializeCore') {
          return [
            {
              'name': '[DEFAULT]',
              'options': {
                'apiKey': 'test-api-key',
                'appId': 'test-app-id',
                'messagingSenderId': '123456789',
                'projectId': 'test-project',
              },
              'pluginConstants': <String, dynamic>{},
            }
          ];
        }
        // Handle Firebase#initializeApp - this is called when Firebase.initializeApp() is called
        if (methodCall.method == 'Firebase#initializeApp') {
          final appName = methodCall.arguments['appName'] ?? '[DEFAULT]';
          final options = methodCall.arguments['options'] as Map<Object?, Object?>;
          return {
            'name': appName,
            'options': options,
            'pluginConstants': <String, dynamic>{},
          };
        }
        // Handle FirebaseApp#delete
        if (methodCall.method == 'FirebaseApp#delete') {
          return null;
        }
        // Return null for unknown methods
        return null;
      },
    );

    // Mock Cloud Firestore
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/cloud_firestore'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'DocumentReference#get') {
          return <String, dynamic>{
            'data': <String, dynamic>{},
            'metadata': <String, dynamic>{
              'hasPendingWrites': false,
              'isFromCache': false,
            },
          };
        }
        if (methodCall.method == 'Query#snapshots' ||
            methodCall.method.contains('Query') ||
            methodCall.method.contains('DocumentReference')) {
          return <String, dynamic>{};
        }
        if (methodCall.method == 'Firestore#enableNetwork' ||
            methodCall.method == 'Firestore#disableNetwork') {
          return null;
        }
        return <String, dynamic>{};
      },
    );

    // Mock Firebase Auth
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/firebase_auth'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'Auth#registerIdTokenListener':
          case 'Auth#registerAuthStateListener':
            return <String, dynamic>{};
          case 'Auth#currentUser':
            return null;
          case 'User#reload':
          case 'User#getIdToken':
            return <String, dynamic>{};
          default:
            return <String, dynamic>{};
        }
      },
    );

    // Mock Firebase Storage
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/firebase_storage'),
      (MethodCall methodCall) async {
        return <String, dynamic>{};
      },
    );

    // Mock Image Picker
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/image_picker'),
      (MethodCall methodCall) async {
        return null;
      },
    );

    // Initialize Firebase AFTER setting up all method channels
    // This must complete successfully before any widgets using Firebase are built
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'test-api-key',
          appId: 'test-app-id',
          messagingSenderId: '123456789',
          projectId: 'test-project',
          storageBucket: 'test-project.appspot.com',
        ),
      );
      _isSetup = true;
    } catch (e) {
      // If initialization fails, try to continue anyway
      // The method channels should handle subsequent calls
      _isSetup = true;
    }
  }

  static void reset() {
    _isSetup = false;
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/firebase_core'),
      null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/cloud_firestore'),
      null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/firebase_auth'),
      null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/firebase_storage'),
      null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/image_picker'),
      null,
    );
  }
}

