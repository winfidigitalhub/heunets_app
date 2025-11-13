import '../../../jobs/data/model/job_model.dart';

abstract class SavedJobsRepository {
  Future<List<Job>> getSavedJobs();
  Future<void> removeJobFromSavedJobs(Job job);
}

