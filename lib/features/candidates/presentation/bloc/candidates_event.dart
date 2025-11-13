import 'package:equatable/equatable.dart';

abstract class CandidatesEvent extends Equatable {
  const CandidatesEvent();

  @override
  List<Object> get props => [];
}

class LoadCandidatesEvent extends CandidatesEvent {
  final String employerId;

  const LoadCandidatesEvent(this.employerId);

  @override
  List<Object> get props => [employerId];
}

