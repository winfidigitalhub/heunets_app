import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/candidate_model.dart';

class CandidatesServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Candidate>> fetchCandidatesByEmployer(String employerId) async {
    try {
      // First, get all jobs posted by the employer
      QuerySnapshot jobsSnapshot = await _firestore
          .collection('jobs')
          .where('userId', isEqualTo: employerId)
          .get();

      if (jobsSnapshot.docs.isEmpty) {
        return [];
      }

      // Collect all unique applicant IDs and map them to job IDs
      Map<String, List<String>> applicantToJobsMap = {};
      
      for (var jobDoc in jobsSnapshot.docs) {
        final Map<String, dynamic> jobData = jobDoc.data() as Map<String, dynamic>;
        final String jobId = jobDoc.id;
        final List<dynamic> applicants = (jobData['applicants'] as List<dynamic>?) ?? [];
        
        for (var applicantId in applicants) {
          if (applicantId is String) {
            if (!applicantToJobsMap.containsKey(applicantId)) {
              applicantToJobsMap[applicantId] = [];
            }
            applicantToJobsMap[applicantId]!.add(jobId);
          }
        }
      }

      if (applicantToJobsMap.isEmpty) {
        return [];
      }

      // Fetch user data for each applicant
      List<Candidate> candidates = [];
      
      for (var entry in applicantToJobsMap.entries) {
        String applicantId = entry.key;
        List<String> appliedJobIds = entry.value;

        try {
          DocumentSnapshot userDoc = await _firestore
              .collection('users')
              .doc(applicantId)
              .get();

          if (userDoc.exists) {
            final Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
            
            final Candidate candidate = Candidate(
              userId: applicantId,
              username: (userData['username'] as String?) ?? 'Unknown User',
              email: (userData['email'] as String?) ?? '',
              profileImageUrl: (userData['profileImageUrl'] as String?) ?? (userData['profilePicture'] as String?),
              appliedJobIds: appliedJobIds,
              createdAt: (userData['createdAt'] as Timestamp?)?.toDate(),
            );
            
            candidates.add(candidate);
          }
        } catch (e) {
          // Skip this candidate if there's an error fetching their data
          continue;
        }
      }

      return candidates;
    } catch (e) {
      rethrow;
    }
  }
}

