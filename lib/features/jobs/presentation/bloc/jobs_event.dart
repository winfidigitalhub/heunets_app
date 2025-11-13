import 'package:equatable/equatable.dart';

abstract class JobsEvent extends Equatable {
  const JobsEvent();

  @override
  List<Object> get props => [];
}

class CreateJobEvent extends JobsEvent {
  final String companyName;
  final String? jobImagePath;
  final String jobName;
  final String jobTitle;
  final String jobDescription;
  final String category;
  final String location;
  final double amount;
  final List<String> prerequisites;
  final List<String> skillsNeeded;
  final DateTime applicationDeadline;

  const CreateJobEvent({
    required this.companyName,
    required this.jobImagePath,
    required this.jobName,
    required this.jobTitle,
    required this.jobDescription,
    required this.category,
    required this.location,
    required this.amount,
    required this.prerequisites,
    required this.skillsNeeded,
    required this.applicationDeadline,
  });

  @override
  List<Object> get props => [
        companyName,
        jobName,
        jobTitle,
        jobDescription,
        category,
        location,
        amount,
        prerequisites,
        skillsNeeded,
        applicationDeadline,
      ];
}

class LoadJobsEvent extends JobsEvent {
  const LoadJobsEvent();
}

class FilterJobsByCategoryEvent extends JobsEvent {
  final String category;

  const FilterJobsByCategoryEvent(this.category);

  @override
  List<Object> get props => [category];
}

class LoadJobsByEmployerEvent extends JobsEvent {
  final String employerId;

  const LoadJobsByEmployerEvent(this.employerId);

  @override
  List<Object> get props => [employerId];
}

