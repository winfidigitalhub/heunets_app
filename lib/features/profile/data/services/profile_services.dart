import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/shared/services/user_service.dart';

class ProfileServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> updateProfile(
    String username,
    String email,
    File? profileImage, {
    String? employeeBio,
    String? companyName,
    String? employerBio,
  }) async {
    User? user = _auth.currentUser;

    if (user != null) {
      String? imageUrl;

      if (profileImage != null) {
        String fileName = 'profile_pictures/${user.uid}.jpg';
        UploadTask uploadTask = _storage.ref().child(fileName).putFile(profileImage);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      await user.updateDisplayName(username);
      if (imageUrl != null) {
        await user.updatePhotoURL(imageUrl);
      }

      Map<String, dynamic> updateData = {
        'username': username,
        if (imageUrl != null) 'profileImageUrl': imageUrl,
        if (employeeBio != null) 'employeeBio': employeeBio,
        if (companyName != null) 'companyName': companyName,
        if (employerBio != null) 'employerBio': employerBio,
      };

      await _firestore.collection('users').doc(user.uid).update(updateData);
      
      // Clear user service cache to ensure fresh data is loaded
      UserService.clearCache();
    }
  }

  Future<void> updateUserRole(String role) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'userRole': role,
      });
      
      // Clear user service cache to ensure fresh data is loaded
      UserService.clearCache();
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.data() as Map<String, dynamic>;
    }
    return {};
  }
}
