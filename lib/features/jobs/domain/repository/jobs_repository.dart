import '../../data/model/job_model.dart';

abstract class JobsRepository {
  Future<String> createJob({
    required String companyName,
    required String? jobImagePath,
    required String jobName,
    required String jobTitle,
    required String jobDescription,
    required String category,
    required String location,
    required double amount,
    required List<String> prerequisites,
    required List<String> skillsNeeded,
    required DateTime applicationDeadline,
  });

  Future<List<Job>> getJobs();

  Future<Job?> getJobById(String jobId);

  Future<List<Job>> getJobsByEmployer(String employerId);
}

