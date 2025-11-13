import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../jobs/data/model/job_model.dart';

class SavedJobsServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveJob(Job job) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("No user is currently logged in");
      }
      String userId = currentUser.uid;

      Map<String, dynamic> jobMap = job.toJson();

      DocumentReference savedJobsRef = _firestore.collection('saved_jobs').doc(userId);
      DocumentSnapshot savedJobsSnapshot = await savedJobsRef.get();

      if (savedJobsSnapshot.exists) {
        await savedJobsRef.update({
          'jobs': FieldValue.arrayUnion([jobMap])
        });
      } else {
        await savedJobsRef.set({
          'jobs': [jobMap]
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Job>> fetchSavedJobs() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("No user is currently logged in");
    }
    String userId = currentUser.uid;

    DocumentReference savedJobsRef = _firestore.collection('saved_jobs').doc(userId);
    DocumentSnapshot savedJobsSnapshot = await savedJobsRef.get();

    if (!savedJobsSnapshot.exists) {
      return [];
    }

    Map<String, dynamic> savedJobsData = savedJobsSnapshot.data() as Map<String, dynamic>;
    if (!savedJobsData.containsKey('jobs')) {
      return [];
    }

    final List<dynamic> jobsData = (savedJobsData['jobs'] as List<dynamic>?) ?? [];
    return jobsData.map((data) => Job.fromJson(data as Map<String, dynamic>)).toList();
  }

  Future<void> removeJobFromSavedJobs(Job job) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("No user is currently logged in");
      }
      String userId = currentUser.uid;

      Map<String, dynamic> jobMap = job.toJson();

      DocumentReference savedJobsRef = _firestore.collection('saved_jobs').doc(userId);
      await savedJobsRef.update({
        'jobs': FieldValue.arrayRemove([jobMap])
      });
    } catch (e) {
      rethrow;
    }
  }
}
