import 'package:equatable/equatable.dart';
import '../../../jobs/data/model/job_model.dart';

abstract class SavedJobsState extends Equatable {
  const SavedJobsState();

  @override
  List<Object> get props => [];
}

class SavedJobsInitial extends SavedJobsState {}

class SavedJobsLoading extends SavedJobsState {}

class SavedJobsLoaded extends SavedJobsState {
  final List<Job> jobs;

  const SavedJobsLoaded({required this.jobs});

  @override
  List<Object> get props => [jobs];

  SavedJobsLoaded copyWith({
    List<Job>? jobs,
  }) {
    return SavedJobsLoaded(
      jobs: jobs ?? this.jobs,
    );
  }
}

class SavedJobsError extends SavedJobsState {
  final String message;

  const SavedJobsError(this.message);

  @override
  List<Object> get props => [message];
}

class SavedJobsEmpty extends SavedJobsState {}

