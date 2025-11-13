import 'package:equatable/equatable.dart';
import '../../../jobs/data/model/job_model.dart';

abstract class AppliedJobsState extends Equatable {
  const AppliedJobsState();

  @override
  List<Object> get props => [];
}

class AppliedJobsInitial extends AppliedJobsState {}

class AppliedJobsLoading extends AppliedJobsState {}

class AppliedJobsLoaded extends AppliedJobsState {
  final List<Job> jobs;

  const AppliedJobsLoaded({
    required this.jobs,
  });

  @override
  List<Object> get props => [jobs];

  AppliedJobsLoaded copyWith({
    List<Job>? jobs,
  }) {
    return AppliedJobsLoaded(
      jobs: jobs ?? this.jobs,
    );
  }
}

class AppliedJobsError extends AppliedJobsState {
  final String message;

  const AppliedJobsError(this.message);

  @override
  List<Object> get props => [message];
}

class AppliedJobsEmpty extends AppliedJobsState {}

