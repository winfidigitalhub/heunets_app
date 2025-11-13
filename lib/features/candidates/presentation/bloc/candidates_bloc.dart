import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/candidates_repository.dart';
import 'candidates_event.dart';
import 'candidates_state.dart';

class CandidatesBloc extends Bloc<CandidatesEvent, CandidatesState> {
  final CandidatesRepository candidatesRepository;

  CandidatesBloc({required this.candidatesRepository}) : super(CandidatesInitial()) {
    on<LoadCandidatesEvent>(_onLoadCandidates);
  }

  Future<void> _onLoadCandidates(
    LoadCandidatesEvent event,
    Emitter<CandidatesState> emit,
  ) async {
    emit(CandidatesLoading());
    try {
      final candidates = await candidatesRepository.getCandidatesByEmployer(event.employerId);
      emit(CandidatesLoaded(candidates: candidates));
    } catch (e) {
      emit(CandidatesError(e.toString()));
    }
  }
}
