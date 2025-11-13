import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/applied_jobs_repository.dart';
import 'applied_jobs_event.dart';
import 'applied_jobs_state.dart';

class AppliedJobsBloc extends Bloc<AppliedJobsEvent, AppliedJobsState> {
  final AppliedJobsRepository appliedJobsRepository;

  AppliedJobsBloc({required this.appliedJobsRepository}) : super(AppliedJobsInitial()) {
    on<LoadAppliedJobsEvent>(_onLoadAppliedJobs);
    on<RemoveJobFromAppliedJobsEvent>(_onRemoveJobFromAppliedJobs);
  }

  Future<void> _onLoadAppliedJobs(
    LoadAppliedJobsEvent event,
    Emitter<AppliedJobsState> emit,
  ) async {
    emit(AppliedJobsLoading());
    try {
      final jobs = await appliedJobsRepository.getAppliedJobs();
      if (jobs.isEmpty) {
        emit(AppliedJobsEmpty());
      } else {
        emit(AppliedJobsLoaded(jobs: jobs));
      }
    } catch (e) {
      emit(AppliedJobsError(e.toString()));
    }
  }

  Future<void> _onRemoveJobFromAppliedJobs(
    RemoveJobFromAppliedJobsEvent event,
    Emitter<AppliedJobsState> emit,
  ) async {
    if (state is AppliedJobsLoaded) {
      try {
        await appliedJobsRepository.removeJobFromAppliedJobs(event.job);
        // Reload applied jobs after removal
        add(const LoadAppliedJobsEvent());
      } catch (e) {
        emit(AppliedJobsError(e.toString()));
      }
    }
  }
}

