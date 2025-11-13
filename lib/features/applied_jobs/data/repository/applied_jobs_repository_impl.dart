import '../../domain/repository/applied_jobs_repository.dart';
import '../../../jobs/data/model/job_model.dart';
import '../services/applied_jobs_services.dart';

class AppliedJobsRepositoryImpl implements AppliedJobsRepository {
  final AppliedJobsServices _appliedJobsServices;

  AppliedJobsRepositoryImpl({AppliedJobsServices? appliedJobsServices})
      : _appliedJobsServices = appliedJobsServices ?? AppliedJobsServices();

  @override
  Future<List<Job>> getAppliedJobs() async {
    return await _appliedJobsServices.fetchAppliedJobs();
  }

  @override
  Future<void> removeJobFromAppliedJobs(Job job) async {
    await _appliedJobsServices.removeJobFromAppliedJobs(job);
  }
}

