import 'dart:async';
import 'package:bloc/bloc.dart';

import '../../api_helper/api.dart';
import '../../data/model/candidate_status/candidate_status_model.dart';
import '../../data/repositories/candidate_status/candidate_status_repo.dart';
import '../../utils/widgets/toast_widget.dart';
import 'candidates_status_event.dart';
import 'candidates_status_state.dart';

class CandidatesStatusBloc extends Bloc<CandidatesStatusEvent, CandidatesStatusState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasReachedMax = false;
  String drawingCandidate = "";

  CandidatesStatusBloc() : super(CandidatesStatusInitial()) {
    on<CreateCandidatesStatus>(_onCandidatesStatusCreate);
    on<CandidatesStatusList>(_getListOfCandidatesStatus);
    on<UpdateCandidatesStatus>(_onUpdateCandidate);
    on<DeleteCandidatesStatus>(_onDeleteCandidate);
    on<SearchCandidatesStatus>(_onSearchCandidatesStatus);
    on<LoadMoreCandidatesStatus>(_onLoadMoreCandidatesStatus);
  }


  Future<void> _onCandidatesStatusCreate(CreateCandidatesStatus event, Emitter<CandidatesStatusState> emit) async {
    try {
      emit(CandidatesStatusLoading());

      Map<String,dynamic> result = await CandidatesStatusRepo().createCandidateStatus(
        name: event.name,color:event.color,
      );

      if (result['error'] == false) {
        emit(const CandidatesStatusCreateSuccess());
      }
      if (result['error'] == true) {
        emit((CandidatesStatusCreateError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }


    } on ApiException catch (e) {
      emit(CandidatesStatusError("Error: $e"));
    }
  }


  Future<void> _getListOfCandidatesStatus(CandidatesStatusList event, Emitter<CandidatesStatusState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(CandidatesStatusLoading());
      List<CandidateStatusModel> CandidatesStatus =[];
      Map<String,dynamic> result
      = await CandidatesStatusRepo().CandidateStatusList(limit: _limit, offset: _offset, search: '');
      CandidatesStatus = List<CandidateStatusModel>.from(result['data'].map((projectData) => CandidateStatusModel.fromJson(projectData)));
      _offset += _limit;
      _hasReachedMax = CandidatesStatus.length < _limit;

      if (result['error'] == false) {
        emit(CandidatesStatusPaginated(CandidatesStatus: CandidatesStatus, hasReachedMax: _hasReachedMax));

      }
      if (result['error'] == true) {
        emit((CandidatesStatusError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      emit(CandidatesStatusError("Error: $e"));
    }
  }

  void _onUpdateCandidate(UpdateCandidatesStatus event, Emitter<CandidatesStatusState> emit) async {
    if (state is CandidatesStatusPaginated) {

      final name = event.name;
      final id = event.id;
      final color = event.color;

      // Update the Candidate in the list
      try {


        emit(CandidatesStatusEditSuccessLoading());
        Map<String,dynamic> result = await CandidatesStatusRepo().updateCandidateStatus(
          id: id,
          name: name, color: color,
        ) ;

        // Replace the Candidate in the list with the updated one
        if (result['error'] == false) {
          emit(const CandidatesStatusEditSuccess());
          add(const CandidatesStatusList());


        }
        if (result['error'] == true) {
          emit((CandidatesStatusEditError(result['message'])));
          add(const CandidatesStatusList());
          flutterToastCustom(msg: result['message']);

        }
      } catch (e) {
        emit((CandidatesStatusEditError("$e")));

        print('Error while updating Candidate: $e');
        // Optionally, handle the error state
      }
    }
  }

  void _onDeleteCandidate(DeleteCandidatesStatus event, Emitter<CandidatesStatusState> emit) async {
    // if (emit is CandidatesStatusSuccess) {
    final Candidate = event.CandidatesStatus;
    print("ghj $Candidate");
    try {
      Map<String,dynamic> result
    =  await CandidatesStatusRepo().deleteCandidateStatus(
        id: Candidate,
        token: true,
      );
      print("ftcvgbhjnsdasd ${result}");
      if(result['error']== false) {
        emit( CandidatesStatusDeleteSuccess(result['message']));
      }
      if(result['error'] == true){
        emit(CandidatesStatusDeleteError(result['message']));
      }
    } catch (e) {
      emit(CandidatesStatusDeleteError(e.toString()));
    }
    // }
  }

  Future<void> _onSearchCandidatesStatus(
      SearchCandidatesStatus event, Emitter<CandidatesStatusState> emit) async {
    try {
      emit(CandidatesStatusLoading());
      List<CandidateStatusModel> CandidatesStatus =[];
      Map<String,dynamic> result = await CandidatesStatusRepo()
          .CandidateStatusList(limit: _limit, offset: 0, search: event.searchQuery);
      CandidatesStatus = List<CandidateStatusModel>.from(result['data']
          .map((projectData) => CandidateStatusModel.fromJson(projectData)));
      bool hasReachedMax = CandidatesStatus.length < _limit;
      if (result['error'] == false) {
        emit(CandidatesStatusPaginated(CandidatesStatus:CandidatesStatus,hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((CandidatesStatusError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }

    } on ApiException catch (e) {
      emit(CandidatesStatusError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreCandidatesStatus(
      LoadMoreCandidatesStatus event, Emitter<CandidatesStatusState> emit) async {
    if (state is CandidatesStatusPaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Prevent multiple calls
      try {
        final currentState = state as CandidatesStatusPaginated;
        final updatedCandidatesStatus = List<CandidateStatusModel>.from(currentState.CandidatesStatus);

        List<CandidateStatusModel> additionalCandidatesStatus = [];
        Map<String, dynamic> result = await CandidatesStatusRepo().CandidateStatusList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
        );

        additionalCandidatesStatus = List<CandidateStatusModel>.from(
            result['data'].map((projectData) => CandidateStatusModel.fromJson(projectData)));

        // Update the offset after each call, increment it by the limit
        _offset += _limit;

        // Check if total number of CandidatesStatus has been reached
        if (updatedCandidatesStatus.length + additionalCandidatesStatus.length >= result['total']) {
          _hasReachedMax = true;
        } else {
          _hasReachedMax = false;
        }

        // Add the newly fetched CandidatesStatus to the updated list
        updatedCandidatesStatus.addAll(additionalCandidatesStatus);

        if (result['error'] == false) {
          emit(CandidatesStatusPaginated(CandidatesStatus: updatedCandidatesStatus, hasReachedMax: _hasReachedMax));
        }

        if (result['error'] == true) {
          emit(CandidatesStatusError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        emit(CandidatesStatusError("Error: $e"));
      } finally {
        _isLoading = false; // Reset the loading flag after the API call finishes
      }
    }
  }

}
