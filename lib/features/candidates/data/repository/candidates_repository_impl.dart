import '../../domain/repository/candidates_repository.dart';
import '../model/candidate_model.dart';
import '../services/candidates_services.dart';

class CandidatesRepositoryImpl implements CandidatesRepository {
  final CandidatesServices _candidatesServices;

  CandidatesRepositoryImpl({CandidatesServices? candidatesServices})
      : _candidatesServices = candidatesServices ?? CandidatesServices();

  @override
  Future<List<Candidate>> getCandidatesByEmployer(String employerId) async {
    return await _candidatesServices.fetchCandidatesByEmployer(employerId);
  }
}

