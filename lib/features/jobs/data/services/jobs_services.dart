import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../model/job_model.dart';

class JobsServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> createJob({
    required String companyName,
    required File? jobImage,
    required String jobName,
    required String jobTitle,
    required String jobDescription,
    required String category,
    required String location,
    required double amount,
    required List<String> prerequisites,
    required List<String> skillsNeeded,
    required DateTime applicationDeadline,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently logged in');
      }

      String? jobImageUrl;
      
      // Upload job image if provided
      if (jobImage != null) {
        String fileName = 'job_images/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        UploadTask uploadTask = _storage.ref().child(fileName).putFile(jobImage);
        TaskSnapshot snapshot = await uploadTask;
        jobImageUrl = await snapshot.ref.getDownloadURL();
      }

      // Create job document
      DocumentReference jobRef = _firestore.collection('jobs').doc();
      String jobId = jobRef.id;

      Job job = Job(
        id: jobId,
        companyName: companyName,
        jobImageUrl: jobImageUrl ?? '',
        userId: user.uid,
        jobName: jobName,
        jobTitle: jobTitle,
        jobDescription: jobDescription,
        category: category,
        location: location,
        amount: amount,
        prerequisites: prerequisites,
        skillsNeeded: skillsNeeded,
        applicationDeadline: applicationDeadline,
        createdAt: DateTime.now(),
      );

      await jobRef.set(job.toJson());
      return jobId;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Job>> fetchJobs() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('jobs')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Job.fromJson(data);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Job?> getJobById(String jobId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('jobs').doc(jobId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Job.fromJson(data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Job>> fetchJobsByEmployer(String employerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('jobs')
          .where('userId', isEqualTo: employerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Job.fromJson(data);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addApplicantToJob(String jobId, String applicantId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'applicants': FieldValue.arrayUnion([applicantId]),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeApplicantFromJob(String jobId, String applicantId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'applicants': FieldValue.arrayRemove([applicantId]),
      });
    } catch (e) {
      rethrow;
    }
  }
}

