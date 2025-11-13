import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/jobs_repository.dart';
import '../../data/model/job_model.dart';
import 'jobs_event.dart';
import 'jobs_state.dart';

class JobsBloc extends Bloc<JobsEvent, JobsState> {
  final JobsRepository jobsRepository;

  JobsBloc({required this.jobsRepository}) : super(JobsInitial()) {
    on<CreateJobEvent>(_onCreateJob);
    on<LoadJobsEvent>(_onLoadJobs);
    on<FilterJobsByCategoryEvent>(_onFilterJobsByCategory);
  }

  List<Job> _allJobs = [];

  Future<void> _onCreateJob(
    CreateJobEvent event,
    Emitter<JobsState> emit,
  ) async {
    emit(JobsLoading());
    try {
      final jobId = await jobsRepository.createJob(
        companyName: event.companyName,
        jobImagePath: event.jobImagePath,
        jobName: event.jobName,
        jobTitle: event.jobTitle,
        jobDescription: event.jobDescription,
        category: event.category,
        location: event.location,
        amount: event.amount,
        prerequisites: event.prerequisites,
        skillsNeeded: event.skillsNeeded,
        applicationDeadline: event.applicationDeadline,
      );
      emit(JobCreated(jobId: jobId));
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }

  Future<void> _onLoadJobs(
    LoadJobsEvent event,
    Emitter<JobsState> emit,
  ) async {
    emit(JobsLoading());
    try {
      _allJobs = await jobsRepository.getJobs();
      emit(JobsLoaded(
        jobs: _allJobs,
        selectedCategory: 'All',
      ));
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }

  void _onFilterJobsByCategory(
    FilterJobsByCategoryEvent event,
    Emitter<JobsState> emit,
  ) {
    if (state is JobsLoaded) {
      emit((state as JobsLoaded).copyWith(
        selectedCategory: event.category,
      ));
    }
  }
}

