import 'dart:io';
import '../../domain/repository/jobs_repository.dart';
import '../model/job_model.dart';
import '../services/jobs_services.dart';

class JobsRepositoryImpl implements JobsRepository {
  final JobsServices _jobsServices;

  JobsRepositoryImpl({JobsServices? jobsServices})
      : _jobsServices = jobsServices ?? JobsServices();

  @override
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
  }) async {
    File? jobImageFile;
    if (jobImagePath != null && jobImagePath.isNotEmpty) {
      jobImageFile = File(jobImagePath);
    }

    return await _jobsServices.createJob(
      companyName: companyName,
      jobImage: jobImageFile,
      jobName: jobName,
      jobTitle: jobTitle,
      jobDescription: jobDescription,
      category: category,
      location: location,
      amount: amount,
      prerequisites: prerequisites,
      skillsNeeded: skillsNeeded,
      applicationDeadline: applicationDeadline,
    );
  }

  @override
  Future<List<Job>> getJobs() async {
    return await _jobsServices.fetchJobs();
  }

  @override
  Future<Job?> getJobById(String jobId) async {
    return await _jobsServices.getJobById(jobId);
  }

  @override
  Future<List<Job>> getJobsByEmployer(String employerId) async {
    return await _jobsServices.fetchJobsByEmployer(employerId);
  }
}

