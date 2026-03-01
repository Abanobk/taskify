import 'dart:async';
import 'package:bloc/bloc.dart';

import '../../api_helper/api.dart';
import '../../data/model/candidate/candidate_model.dart';
import '../../data/repositories/candidate/candidate_repo.dart';
import '../../utils/widgets/toast_widget.dart';
import 'candidates_event.dart';
import 'candidates_state.dart';

class CandidatesBloc extends Bloc<CandidatesEvent, CandidatesState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasReachedMax = false;
  String drawingCandidate = "";

  CandidatesBloc() : super(CandidatesInitial()) {
    on<CreateCandidates>(_onCandidatesCreate);
    on<CandidatesList>(_getListOfCandidates);
    on<UpdateCandidates>(_onUpdateCandidate);
    on<DeleteCandidates>(_onDeleteCandidate);
    on<SearchCandidates>(_onSearchCandidates);
    on<LoadMoreCandidates>(_onLoadMoreCandidates);
  }

  Future<void> _onCandidatesCreate(
      CreateCandidates event, Emitter<CandidatesState> emit) async {
    try {
      emit(CandidatesLoading());

      Map<String, dynamic> result = await CandidatesRepo().createCandidate(
        name: event.name,
        email: event.email,
        phone: event.phone,
        position: event.position,
        source: event.source,
        statusId: event.statusId,
        media: event.attachment!,
      );

      if (result['error'] == false) {
        emit(const CandidatesCreateSuccess());
      }
      if (result['error'] == true) {
        emit((CandidatesCreateError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(CandidatesError("Error: $e"));
    }
  }

  Future<void> _getListOfCandidates(
      CandidatesList event, Emitter<CandidatesState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(CandidatesLoading());
      List<CandidateModel> Candidates = [];
      Map<String, dynamic> result = await CandidatesRepo()
          .CandidateList(id:event.id,limit: _limit, offset: _offset, search: '');
      Candidates = List<CandidateModel>.from(result['data']
          .map((projectData) => CandidateModel.fromJson(projectData)));
      _offset += _limit;
      _hasReachedMax = Candidates.length < _limit;

      if (result['error'] == false) {
        emit(CandidatesPaginated(
            Candidates: Candidates, hasReachedMax: _hasReachedMax));
      }
      if (result['error'] == true) {
        emit((CandidatesError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(CandidatesError("Error: $e"));
    }
  }

  void _onUpdateCandidate(
      UpdateCandidates event, Emitter<CandidatesState> emit) async {

    if (state is CandidatesPaginated) {
      final Candidate = event.Candidates;
      final name = Candidate.name ?? "";
      final id = Candidate.id ?? 0;
      final email = Candidate.email ?? "";
      final phone = Candidate.phone ?? "";
      final position = Candidate.position ?? "";
      final source = Candidate.source ?? "";
      // final CandidateStatus? status = Candidate.status;
      final attachment = event.attachment;
      print("==== Update Candidate Params ====");
      print("ID: $id");
      print("Name: $name");
      print("Email: $email");
      print("Phone: $phone");
      print("Position: $position");
      print("Source: $source");
      // print("Status ID: ${status?.id}");
      print("Attachments:");
      attachment?.forEach((file) => print(" - ${file.path}"));


      // Update the Candidate in the list
      try {
        emit(CandidatesEditSuccessLoading());
        Map<String, dynamic> result = await CandidatesRepo().updateCandidate(
          id: id,
          name: name,
          email: email,
          phone: phone,
          position: position,
          source: source,
          statusId: event.statusId,
            media:attachment!
        ); // Cast to CandidatesModel

        // Replace the Candidate in the list with the updated one
        if (result['error'] == false) {
          emit(const CandidatesEditSuccess());
        }
        if (result['error'] == true) {
          emit((CandidatesEditError(result['message'])));
          flutterToastCustom(msg: result['message']);
        }
      } catch (e) {
        emit((CandidatesEditError("$e")));

        print('Error while updating Candidate: $e');
        // Optionally, handle the error state
      }
    }
  }

  void _onDeleteCandidate(
      DeleteCandidates event, Emitter<CandidatesState> emit) async {
    // if (emit is CandidatesSuccess) {
    final Candidate = event.Candidates;
    try {
      Map<String, dynamic> result = await CandidatesRepo().deleteCandidate(
        id: Candidate,
        token: true,
      );
      if (result['error'] == false) {
        emit(const CandidatesDeleteSuccess());
      }
      if (result['error'] == true) {
        emit(CandidatesDeleteError(result['message']));
      }
    } catch (e) {
      emit(CandidatesDeleteError(e.toString()));
    }
    // }
  }

  Future<void> _onSearchCandidates(
      SearchCandidates event, Emitter<CandidatesState> emit) async {
    try {
      emit(CandidatesLoading());
      List<CandidateModel> Candidates = [];
      Map<String, dynamic> result = await CandidatesRepo()
          .CandidateList(limit: _limit, offset: 0, search: event.searchQuery);
      Candidates = List<CandidateModel>.from(result['data']
          .map((projectData) => CandidateModel.fromJson(projectData)));
      bool hasReachedMax = Candidates.length < _limit;
      if (result['error'] == false) {
        emit(CandidatesPaginated(
            Candidates: Candidates, hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((CandidatesError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(CandidatesError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreCandidates(
      LoadMoreCandidates event, Emitter<CandidatesState> emit) async {
    if (state is CandidatesPaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Prevent multiple calls
      try {
        final currentState = state as CandidatesPaginated;
        final updatedCandidates =
            List<CandidateModel>.from(currentState.Candidates);

        List<CandidateModel> additionalCandidates = [];
        Map<String, dynamic> result = await CandidatesRepo().CandidateList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
        );

        additionalCandidates = List<CandidateModel>.from(result['data']
            .map((projectData) => CandidateModel.fromJson(projectData)));

        // Update the offset after each call, increment it by the limit
        _offset += _limit;

        // Check if total number of Candidates has been reached
        if (updatedCandidates.length + additionalCandidates.length >=
            result['total']) {
          _hasReachedMax = true;
        } else {
          _hasReachedMax = false;
        }

        // Add the newly fetched Candidates to the updated list
        updatedCandidates.addAll(additionalCandidates);

        if (result['error'] == false) {
          emit(CandidatesPaginated(
              Candidates: updatedCandidates, hasReachedMax: _hasReachedMax));
        }

        if (result['error'] == true) {
          emit(CandidatesError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        emit(CandidatesError("Error: $e"));
      } finally {
        _isLoading =
            false; // Reset the loading flag after the API call finishes
      }
    }
  }
}
