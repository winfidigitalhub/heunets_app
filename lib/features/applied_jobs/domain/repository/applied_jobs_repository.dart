import '../../../jobs/data/model/job_model.dart';

abstract class AppliedJobsRepository {
  Future<List<Job>> getAppliedJobs();
  Future<void> removeJobFromAppliedJobs(Job job);
}

