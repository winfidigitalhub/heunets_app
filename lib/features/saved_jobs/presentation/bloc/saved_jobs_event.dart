import 'package:equatable/equatable.dart';
import '../../../jobs/data/model/job_model.dart';

abstract class SavedJobsEvent extends Equatable {
  const SavedJobsEvent();

  @override
  List<Object> get props => [];
}

class LoadSavedJobsEvent extends SavedJobsEvent {
  const LoadSavedJobsEvent();
}

class RemoveJobFromSavedJobsEvent extends SavedJobsEvent {
  final Job job;

  const RemoveJobFromSavedJobsEvent(this.job);

  @override
  List<Object> get props => [job];
}

