import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../jobs/data/model/job_model.dart';
import '../../../jobs/data/services/jobs_services.dart';

class AppliedJobsServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final JobsServices _jobsServices = JobsServices();

  Future<void> addJobToAppliedJobs(Job job) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("No user is currently logged in");
      }
      String userId = currentUser.uid;

      Map<String, dynamic> jobMap = job.toJson();

      DocumentReference appliedJobsRef = _firestore.collection('applied_jobs').doc(userId);
      DocumentSnapshot appliedJobsSnapshot = await appliedJobsRef.get();

      if (appliedJobsSnapshot.exists) {
        await appliedJobsRef.update({
          'jobs': FieldValue.arrayUnion([jobMap])
        });
      } else {
        await appliedJobsRef.set({
          'jobs': [jobMap]
        });
      }

      // Also add applicant to job's applicants list
      await _jobsServices.addApplicantToJob(job.id, userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Job>> fetchAppliedJobs() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("No user is currently logged in");
    }
    String userId = currentUser.uid;

    DocumentReference appliedJobsRef = _firestore.collection('applied_jobs').doc(userId);
    DocumentSnapshot appliedJobsSnapshot = await appliedJobsRef.get();

    if (!appliedJobsSnapshot.exists) {
      return [];
    }

    Map<String, dynamic> appliedJobsData = appliedJobsSnapshot.data() as Map<String, dynamic>;
    if (!appliedJobsData.containsKey('jobs')) {
      return [];
    }

    final List<dynamic> jobsData = appliedJobsData['jobs'] as List<dynamic>;
    return jobsData.map((data) => Job.fromJson(data as Map<String, dynamic>)).toList();
  }

  Future<void> removeJobFromAppliedJobs(Job job) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("No user is currently logged in");
      }
      String userId = currentUser.uid;

      Map<String, dynamic> jobMap = job.toJson();

      DocumentReference appliedJobsRef = _firestore.collection('applied_jobs').doc(userId);
      await appliedJobsRef.update({
        'jobs': FieldValue.arrayRemove([jobMap])
      });

      // Also remove applicant from job's applicants list
      await _jobsServices.removeApplicantFromJob(job.id, userId);
    } catch (e) {
      rethrow;
    }
  }
}
