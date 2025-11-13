import '../../data/model/candidate_model.dart';

abstract class CandidatesRepository {
  Future<List<Candidate>> getCandidatesByEmployer(String employerId);
}

