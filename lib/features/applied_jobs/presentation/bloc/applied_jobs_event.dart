import 'package:equatable/equatable.dart';
import '../../../jobs/data/model/job_model.dart';

abstract class AppliedJobsEvent extends Equatable {
  const AppliedJobsEvent();

  @override
  List<Object> get props => [];
}

class LoadAppliedJobsEvent extends AppliedJobsEvent {
  const LoadAppliedJobsEvent();
}

class RemoveJobFromAppliedJobsEvent extends AppliedJobsEvent {
  final Job job;

  const RemoveJobFromAppliedJobsEvent(this.job);

  @override
  List<Object> get props => [job];
}

