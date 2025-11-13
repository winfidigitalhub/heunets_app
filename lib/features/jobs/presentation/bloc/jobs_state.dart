import 'package:equatable/equatable.dart';
import '../../data/model/job_model.dart';

abstract class JobsState extends Equatable {
  const JobsState();

  @override
  List<Object> get props => [];
}

class JobsInitial extends JobsState {}

class JobsLoading extends JobsState {}

class JobsLoaded extends JobsState {
  final List<Job> jobs;
  final String selectedCategory;

  const JobsLoaded({
    required this.jobs,
    this.selectedCategory = 'All',
  });

  @override
  List<Object> get props => [jobs, selectedCategory];

  JobsLoaded copyWith({
    List<Job>? jobs,
    String? selectedCategory,
  }) {
    return JobsLoaded(
      jobs: jobs ?? this.jobs,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class JobCreated extends JobsState {
  final String jobId;

  const JobCreated({required this.jobId});

  @override
  List<Object> get props => [jobId];
}

class JobsError extends JobsState {
  final String message;

  const JobsError(this.message);

  @override
  List<Object> get props => [message];
}

