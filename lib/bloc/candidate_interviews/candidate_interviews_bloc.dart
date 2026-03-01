import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:taskify/data/model/interview/interview_model.dart';
import 'package:taskify/data/repositories/interviews/interviews_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';
import 'candidate_interviews_event.dart';
import 'candidate_interviews_state.dart';

class CandidateInterviewssBloc extends Bloc<CandidateInterviewsEvent, CandidateInterviewsState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasReachedMax = false;
  String drawingCandidate = "";

  CandidateInterviewssBloc() : super(CandidateInterviewInitial()) {
    on<CreateCandidateInterviews>(_onCandidateInterviewssCreate);
    on<CandidateInterviewsList>(_getListOfCandidateInterviewss);
    on<UpdateCandidateInterview>(_onUpdateCandidate);
    on<DeleteCandidateInterview>(_onDeleteCandidate);
    on<SearchCandidateInterview>(_onSearchCandidateInterviewss);
    on<LoadMoreCandidateInterview>(_onLoadMoreCandidateInterviewss);
  }


  Future<void> _onCandidateInterviewssCreate(CreateCandidateInterviews event, Emitter<CandidateInterviewsState> emit) async {
    try {
      emit(CandidateInterviewssLoading());

      Map<String,dynamic> result = await InterviewsRepo().createInterviews(
          candidateName: event.CandidateInterviewserName,candidateId:event.candidateId ,interviewerName: event.candidateName,interviewerId: event.CandidateInterviewserId,
          status: event.status,scheduledAt:event.scheduledAt ,mode: event.mode,location:event.location ,round: event.round
      );
print("ftghjk ${result['error']}");
      if (result['error'] == false) {
        emit(const CandidateInterviewssCreateSuccess());
        // add(const CandidateInterviewsList());
      }
      if (result['error'] == true) {
        emit((CandidateInterviewssCreateError(result['message'])));
        // add(const CandidateInterviewsList());
        flutterToastCustom(msg: result['message']);

      }
      print("edAWsdsWEwrES$state");


    } on ApiException catch (e) {
      emit(CandidateInterviewssError("Error: $e"));
    }
  }


  Future<void> _getListOfCandidateInterviewss(CandidateInterviewsList event, Emitter<CandidateInterviewsState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(CandidateInterviewssLoading());
      List<InterviewModel> CandidateInterviewss =[];
      Map<String,dynamic> result
      = await InterviewsRepo().InterviewsList(id:event.id,limit: _limit, offset: _offset, search: '');
      CandidateInterviewss = List<InterviewModel>.from(result['data'].map((projectData) => InterviewModel.fromJson(projectData)));
      _offset += _limit;
      _hasReachedMax = CandidateInterviewss.length < _limit;

      if (result['error'] == false) {
        emit(CandidateInterviewssPaginated(CandidateInterviewss: CandidateInterviewss, hasReachedMax: _hasReachedMax));

      }
      if (result['error'] == true) {
        emit((CandidateInterviewssError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      emit(CandidateInterviewssError("Error: $e"));
    }
  }

  void _onUpdateCandidate(UpdateCandidateInterview event, Emitter<CandidateInterviewsState> emit) async {
    if (state is CandidateInterviewssPaginated) {

      try {
        print('Updating CandidateInterviews with values in BLOC:');
        print('id: ${event.id}');
        print('candidateId: ${event.candidateId}');
        print('candidateName: ${event.candidateName}');
        print('interviewerId: ${event.interviewerId}');
        print('CandidateInterviewserId: ${event.CandidateInterviewserId}');
        print('CandidateInterviewserName: ${event.CandidateInterviewserName}');
        print('round: ${event.round}');
        print('scheduledAt: ${event.scheduledAt}');
        print('mode: ${event.mode}');
        print('location: ${event.location}');
        print('status: ${event.status}');
        emit(CandidateInterviewssEditSuccessLoading());
        Map<String,dynamic> result = await InterviewsRepo().updateInterviews(
          id: event.id!,

            candidateName: event.CandidateInterviewserName,candidateId:event.candidateId ,interviewerName: event.candidateName,interviewerId: event.interviewerId,
            status: event.status,scheduledAt:event.scheduledAt ,mode: event.mode,location:event.location ,round: event.round
        ) ;

        // Replace the Candidate in the list with the updated one
        if (result['error'] == false) {
          emit(const CandidateInterviewssEditSuccess());
           // add(const CandidateInterviewsList());


        }
        if (result['error'] == true) {
          emit((CandidateInterviewssEditError(result['message'])));
          // add(const CandidateInterviewsList());
          // flutterToastCustom(msg: result['message']);

        }
      } catch (e) {
        emit((CandidateInterviewssEditError("$e")));

        print('Error while updating CandidateInterviews: $e');
        // Optionally, handle the error state
      }
    }
  }

  void _onDeleteCandidate(DeleteCandidateInterview event, Emitter<CandidateInterviewsState> emit) async {
    // if (emit is CandidateInterviewssSuccess) {
    final Candidate = event.CandidateInterviewss;
    try {
      Map<String,dynamic> result
    =  await InterviewsRepo().deleteInterviews(
        id: Candidate,
        token: true,
      );
      if(result['error']== false) {
        emit(const CandidateInterviewssDeleteSuccess());
        // add(const CandidateInterviewsList());
      }
      if(result['error'] == true){
        emit(CandidateInterviewssDeleteError(result['message']));
        // add(const CandidateInterviewsList());
      }
    } catch (e) {
      emit(CandidateInterviewssDeleteError(e.toString()));
      // add(const CandidateInterviewsList());
    }
    // }
  }

  Future<void> _onSearchCandidateInterviewss(
      SearchCandidateInterview event, Emitter<CandidateInterviewsState> emit) async {
    try {
      emit(CandidateInterviewssLoading());
      List<InterviewModel> CandidateInterviewss =[];
      Map<String,dynamic> result = await InterviewsRepo()
          .InterviewsList(limit: _limit, offset: 0, search: event.searchQuery);
      CandidateInterviewss = List<InterviewModel>.from(result['data']
          .map((projectData) => InterviewModel.fromJson(projectData)));
      bool hasReachedMax = CandidateInterviewss.length < _limit;
      if (result['error'] == false) {
        emit(CandidateInterviewssPaginated(CandidateInterviewss:CandidateInterviewss,hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((CandidateInterviewssError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }

    } on ApiException catch (e) {
      emit(CandidateInterviewssError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreCandidateInterviewss(
      LoadMoreCandidateInterview event, Emitter<CandidateInterviewsState> emit) async {
    if (state is CandidateInterviewssPaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Prevent multiple calls
      try {
        final currentState = state as CandidateInterviewssPaginated;
        final updatedCandidateInterviewss = List<InterviewModel>.from(currentState.CandidateInterviewss);

        List<InterviewModel> additionalCandidateInterviewss = [];
        Map<String, dynamic> result = await InterviewsRepo().InterviewsList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
        );

        additionalCandidateInterviewss = List<InterviewModel>.from(
            result['data'].map((projectData) => InterviewModel.fromJson(projectData)));

        // Update the offset after each call, increment it by the limit
        _offset += _limit;

        // Check if total number of CandidateInterviewss has been reached
        if (updatedCandidateInterviewss.length + additionalCandidateInterviewss.length >= result['total']) {
          _hasReachedMax = true;
        } else {
          _hasReachedMax = false;
        }

        // Add the newly fetched CandidateInterviewss to the updated list
        updatedCandidateInterviewss.addAll(additionalCandidateInterviewss);

        if (result['error'] == false) {
          emit(CandidateInterviewssPaginated(CandidateInterviewss: updatedCandidateInterviewss, hasReachedMax: _hasReachedMax));
        }

        if (result['error'] == true) {
          emit(CandidateInterviewssError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        emit(CandidateInterviewssError("Error: $e"));
      } finally {
        _isLoading = false; // Reset the loading flag after the API call finishes
      }
    }
  }

}
