import '../../domain/repository/saved_jobs_repository.dart';
import '../../../jobs/data/model/job_model.dart';
import '../services/saved_jobs_services.dart';

class SavedJobsRepositoryImpl implements SavedJobsRepository {
  final SavedJobsServices _savedJobsServices;

  SavedJobsRepositoryImpl({SavedJobsServices? savedJobsServices})
      : _savedJobsServices = savedJobsServices ?? SavedJobsServices();

  @override
  Future<List<Job>> getSavedJobs() async {
    return await _savedJobsServices.fetchSavedJobs();
  }

  @override
  Future<void> removeJobFromSavedJobs(Job job) async {
    await _savedJobsServices.removeJobFromSavedJobs(job);
  }
}

