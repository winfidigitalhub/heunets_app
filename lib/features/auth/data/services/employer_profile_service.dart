import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EmployerProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> saveEmployerProfile({
    required String employerBio,
    required String companyName,
    File? cvFile,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently logged in');
      }

      String? cvUrl;

      // Upload CV/resume if provided
      if (cvFile != null) {
        // Get file extension
        String fileExtension = cvFile.path.split('.').last.toLowerCase();
        String fileName = 'cv_resumes/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
        UploadTask uploadTask = _storage.ref().child(fileName).putFile(cvFile);
        TaskSnapshot snapshot = await uploadTask;
        cvUrl = await snapshot.ref.getDownloadURL();
      }

      // Update user document with employer profile data
      await _firestore.collection('users').doc(user.uid).update({
        'employerBio': employerBio,
        'companyName': companyName,
        if (cvUrl != null) 'cvUrl': cvUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
}

