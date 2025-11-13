import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> setupFirebaseForTests() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_core',
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    channel,
    (MethodCall methodCall) async {
      if (methodCall.method == 'Firebase#initializeCore') {
        return [
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': 'AIzaSy-test-api-key',
              'appId': '1:123456789:ios:abcdef123456',
              'messagingSenderId': '123456789',
              'projectId': 'test-project-id',
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
      return null;
    },
  );

  const MethodChannel firestoreChannel = MethodChannel(
    'plugins.flutter.io/cloud_firestore',
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    firestoreChannel,
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
      if (methodCall.method.contains('Query') ||
          methodCall.method.contains('DocumentReference')) {
        return <String, dynamic>{};
      }
      return <String, dynamic>{};
    },
  );

  const MethodChannel authChannel = MethodChannel(
    'plugins.flutter.io/firebase_auth',
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    authChannel,
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
      return <String, dynamic>{};
    },
  );

  const MethodChannel storageChannel = MethodChannel(
    'plugins.flutter.io/firebase_storage',
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    storageChannel,
    (MethodCall methodCall) async {
      return <String, dynamic>{};
    },
  );

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSy-test-api-key',
        appId: '1:123456789:ios:abcdef123456',
        messagingSenderId: '123456789',
        projectId: 'test-project-id',
        storageBucket: 'test-project-id.appspot.com',
      ),
    );
  } catch (e) {
    // Firebase initialization may fail in test environment
    // Method channels are set up to handle calls
  }
}

