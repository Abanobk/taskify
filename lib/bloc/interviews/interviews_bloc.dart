import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:taskify/data/model/interview/interview_model.dart';
import '../../api_helper/api.dart';
import '../../data/repositories/interviews/interviews_repo.dart';
import '../../utils/widgets/toast_widget.dart';
import 'interviews_event.dart';
import 'interviews_state.dart';

class InterviewsBloc extends Bloc<InterviewsEvent, InterviewsState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasReachedMax = false;
  String drawingCandidate = "";

  InterviewsBloc() : super(InterviewsInitial()) {
    on<CreateInterviews>(_onInterviewsCreate);
    on<InterviewsList>(_getListOfInterviews);
    on<UpdateInterviews>(_onUpdateCandidate);
    on<DeleteInterviews>(_onDeleteCandidate);
    on<SearchInterviews>(_onSearchInterviews);
    on<LoadMoreInterviews>(_onLoadMoreInterviews);
  }

  Future<void> _onInterviewsCreate(
      CreateInterviews event, Emitter<InterviewsState> emit) async {
    try {
      emit(InterviewsLoading());

      Map<String, dynamic> result = await InterviewsRepo().createInterviews(
          candidateName: event.interviewerName,
          candidateId: event.candidateId,
          interviewerName: event.candidateName,
          interviewerId: event.interviewerId,
          status: event.status,
          scheduledAt: event.scheduledAt,
          mode: event.mode,
          location: event.location,
          round: event.round);

      if (result['error'] == false) {
        emit(const InterviewsCreateSuccess());
        // add(const InterviewsList());
      }
      if (result['error'] == true) {
        emit((InterviewsCreateError(result['message'])));
        // add(const InterviewsList());
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(InterviewsError("Error: $e"));
    }
  }

  Future<void> _getListOfInterviews(
      InterviewsList event, Emitter<InterviewsState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(InterviewsLoading());
      List<InterviewModel> Interviews = [];
      Map<String, dynamic> result = await InterviewsRepo()
          .InterviewsList(limit: _limit, offset: _offset, search: '');
      Interviews = List<InterviewModel>.from(result['data']
          .map((projectData) => InterviewModel.fromJson(projectData)));
      _offset += _limit;
      _hasReachedMax = Interviews.length < _limit;

      if (result['error'] == false) {
        emit(InterviewsPaginated(
            Interviews: Interviews, hasReachedMax: _hasReachedMax));
      }
      if (result['error'] == true) {
        emit((InterviewsError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(InterviewsError("Error: $e"));
    }
  }

  void _onUpdateCandidate(
      UpdateInterviews event, Emitter<InterviewsState> emit) async {
    if (state is InterviewsPaginated) {
      try {
        print('Updating interview with values in BLOC:');
        print('id: ${event.id}');
        print('candidateId: ${event.candidateId}');
        print('candidateName: ${event.candidateName}');
        print('interviewerId: ${event.interviewerId}');
        print('interviewerName: ${event.interviewerName}');
        print('round: ${event.round}');
        print('scheduledAt: ${event.scheduledAt}');
        print('mode: ${event.mode}');
        print('location: ${event.location}');
        print('status: ${event.status}');
        emit(InterviewsEditSuccessLoading());
        Map<String, dynamic> result = await InterviewsRepo().updateInterviews(
            id: event.id!,
            candidateName: event.interviewerName,
            candidateId: event.candidateId,
            interviewerName: event.candidateName,
            interviewerId: event.interviewerId,
            status: event.status,
            scheduledAt: event.scheduledAt,
            mode: event.mode,
            location: event.location,
            round: event.round);

        // Replace the Candidate in the list with the updated one
        if (result['error'] == false) {
          emit(const InterviewsEditSuccess());
          // add(const InterviewsList());
        }
        if (result['error'] == true) {
          emit((InterviewsEditError(result['message'])));
          // add(const InterviewsList());
          flutterToastCustom(msg: result['message']);
        }
      } catch (e) {
        emit((InterviewsEditError("$e")));

        print('Error while updating INTERVIEW: $e');
        // Optionally, handle the error state
      }
    }
  }

  void _onDeleteCandidate(
      DeleteInterviews event, Emitter<InterviewsState> emit) async {
    // if (emit is InterviewsSuccess) {
    final Candidate = event.Interviews;
    try {
      Map<String, dynamic> result = await InterviewsRepo().deleteInterviews(
        id: Candidate,
        token: true,
      );
      if (result['error'] == false) {
        emit(const InterviewsDeleteSuccess());
        // add(const InterviewsList());
      }
      if (result['error'] == true) {
        emit(InterviewsDeleteError(result['message']));
        // add(const InterviewsList());
      }
    } catch (e) {
      emit(InterviewsDeleteError(e.toString()));
      // add(const InterviewsList());
    }
    // }
  }

  Future<void> _onSearchInterviews(
      SearchInterviews event, Emitter<InterviewsState> emit) async {
    try {
      emit(InterviewsLoading());
      List<InterviewModel> Interviews = [];
      Map<String, dynamic> result = await InterviewsRepo()
          .InterviewsList(limit: _limit, offset: 0, search: event.searchQuery);
      Interviews = List<InterviewModel>.from(result['data']
          .map((projectData) => InterviewModel.fromJson(projectData)));
      bool hasReachedMax = Interviews.length < _limit;
      if (result['error'] == false) {
        emit(InterviewsPaginated(
            Interviews: Interviews, hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((InterviewsError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(InterviewsError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreInterviews(
      LoadMoreInterviews event, Emitter<InterviewsState> emit) async {
    if (state is InterviewsPaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Prevent multiple calls
      try {
        final currentState = state as InterviewsPaginated;
        final updatedInterviews =
            List<InterviewModel>.from(currentState.Interviews);

        List<InterviewModel> additionalInterviews = [];
        Map<String, dynamic> result = await InterviewsRepo().InterviewsList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
        );

        additionalInterviews = List<InterviewModel>.from(result['data']
            .map((projectData) => InterviewModel.fromJson(projectData)));

        // Update the offset after each call, increment it by the limit
        _offset += _limit;

        // Check if total number of Interviews has been reached
        if (updatedInterviews.length + additionalInterviews.length >=
            result['total']) {
          _hasReachedMax = true;
        } else {
          _hasReachedMax = false;
        }

        // Add the newly fetched Interviews to the updated list
        updatedInterviews.addAll(additionalInterviews);

        if (result['error'] == false) {
          emit(InterviewsPaginated(
              Interviews: updatedInterviews, hasReachedMax: _hasReachedMax));
        }

        if (result['error'] == true) {
          emit(InterviewsError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        emit(InterviewsError("Error: $e"));
      } finally {
        _isLoading =
            false; // Reset the loading flag after the API call finishes
      }
    }
  }
}
