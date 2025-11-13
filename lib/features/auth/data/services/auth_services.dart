import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<User?> registerUser({
    required String username,
    required String email,
    required String password,
    required String role,
    required String employeeBio,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _storeUserData(
        userID: userCredential.user!.uid,
        username: username,
        email: email,
        role: role,
        employeeBio: employeeBio,
      );

      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> _storeUserData({
    required String userID,
    required String username,
    required String email,
    required String role,
    required String employeeBio,
  }) async {
    try {
      Map<String, dynamic> userData = {
        'userID': userID,
        'username': username,
        'email': email,
        'profilePicture': '',
        'shippingAddress': '',
        'location': '',
        'privilege': 'customer',
        'userRole': role,
      };

      // Save bio based on role
      if (role == 'employee' && employeeBio.isNotEmpty) {
        userData['employeeBio'] = employeeBio;
      } else if (role == 'employer' && employeeBio.isNotEmpty) {
        // For employers, save bio as employerBio (they'll update it in onboarding)
        userData['employerBio'] = employeeBio;
      }

      await _firestore.collection('users').doc(userID).set(userData);
    } catch (e) {
      print('Error storing user data: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

