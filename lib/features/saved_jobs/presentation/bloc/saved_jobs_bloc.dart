import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/saved_jobs_repository.dart';
import 'saved_jobs_event.dart';
import 'saved_jobs_state.dart';

class SavedJobsBloc extends Bloc<SavedJobsEvent, SavedJobsState> {
  final SavedJobsRepository savedJobsRepository;

  SavedJobsBloc({required this.savedJobsRepository}) : super(SavedJobsInitial()) {
    on<LoadSavedJobsEvent>(_onLoadSavedJobs);
    on<RemoveJobFromSavedJobsEvent>(_onRemoveJobFromSavedJobs);
  }

  Future<void> _onLoadSavedJobs(
    LoadSavedJobsEvent event,
    Emitter<SavedJobsState> emit,
  ) async {
    emit(SavedJobsLoading());
    try {
      final jobs = await savedJobsRepository.getSavedJobs();
      if (jobs.isEmpty) {
        emit(SavedJobsEmpty());
      } else {
        emit(SavedJobsLoaded(jobs: jobs));
      }
    } catch (e) {
      emit(SavedJobsError(e.toString()));
    }
  }

  Future<void> _onRemoveJobFromSavedJobs(
    RemoveJobFromSavedJobsEvent event,
    Emitter<SavedJobsState> emit,
  ) async {
    if (state is SavedJobsLoaded) {
      try {
        await savedJobsRepository.removeJobFromSavedJobs(event.job);
        // Reload saved jobs after removal
        add(const LoadSavedJobsEvent());
      } catch (e) {
        emit(SavedJobsError(e.toString()));
      }
    }
  }
}

