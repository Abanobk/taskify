import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../data/model/meetings/meeting_model.dart';
import '../../data/repositories/meeting/meeting_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';
import 'meeting_event.dart';
import 'meeting_state.dart';

class MeetingBloc extends Bloc<MeetingsEvent, MeetingState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasReachedMax = false;

  MeetingBloc() : super(MeetingInitial()) {
    on<MeetingLists>(_onListOfMeeting);
    on<AddMeetings>(_onAddMeeting);
    on<MeetingUpdateds>(_onUpdateMeeting);
    on<DeleteMeetings>(_onDeleteMeeting);
    on<SearchMeetings>(_onSearchMeeting);
    on<LoadMoreMeetings>(_onLoadMoreMeeting);
  }

  Future<void> _onListOfMeeting(
      MeetingLists event, Emitter<MeetingState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(MeetingLoading());
      List<MeetingModel> meeting = [];
      Map<String, dynamic> result = await MeetingRepo()
          .meetingList(limit: _limit, offset: _offset, search: '');
      meeting = List<MeetingModel>.from(result['data']
          .map((projectData) => MeetingModel.fromJson(projectData)));

      _offset += _limit;
      _hasReachedMax = meeting.length >= result['total'];
      if (result['error'] == false) {
        emit(MeetingPaginated(meeting: meeting, hasReachedMax: _hasReachedMax));
      }
      if (result['error'] == true) {
        emit((MeetingError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(MeetingError("Error: $e"));
    }
  }



  Future<void> _onAddMeeting(
      AddMeetings event, Emitter<MeetingState> emit) async {

    emit(MeetingCreateSuccessLoading());
    var meeting = event.meeting;
    try {
      Map<String, dynamic> result = await MeetingRepo().createMeeting(
        title: meeting.title!,
        startDate: meeting.startDate!,
        token: true,
        endDate: meeting.endDate!,
        startTime: meeting.startTime!,
        endTime: meeting.endTime!,
        userId: meeting.userIds!,
        clientIds: meeting.clientIds!,
      );

      if (result['error'] == false) {
        emit(const MeetingCreateSuccess());;
      }
      if (result['error'] == true) {
        emit((MeetingCreateError(result['message'])));

        flutterToastCustom(msg: result['message']);
      }

    } catch (e) {
      print('Error while creating Meeting: $e');
    }
  }

  void _onUpdateMeeting(
      MeetingUpdateds event, Emitter<MeetingState> emit) async {
    if (state is MeetingPaginated) {

  emit(MeetingEditSuccessLoading());
      final meetings = event.meeting;
      final id = meetings.id;
      final title = meetings.title;
      final startDate = meetings.startDate;
      final endDate = meetings.endDate;
      final startTime = meetings.startTime;
      final endTime = meetings.endTime;
      final userIds = meetings.userIds;
      final clientIds = meetings.clientIds;

      try {
        // Assuming updateMeeting returns a single MeetingModel
        Map<String, dynamic> result = await MeetingRepo().updateMeeting(
          id: id!,
          title: title!,
          startDate: startDate!,
          token: true,
          endDate: endDate!,
          startTime: startTime!,
          endTime: endTime!,
          userId: userIds!,
          clientIds: clientIds!,
        ); // Cast to MeetingModel
        if (result['error'] == false) {
          emit(const MeetingEditSuccess());
          // add(const MeetingLists());

        }
        if (result['error'] == true) {
          emit((MeetingEditError(result['message'])));

          flutterToastCustom(msg: result['message']);


        }

        // emit(MeetingSuccess(MeetingWithUpdatedMeeting));
      } catch (e) {
        print('Error while updating Meeting: $e');
        // Optionally, handle the error state
      }
    }
  }

  void _onDeleteMeeting(
      DeleteMeetings event, Emitter<MeetingState> emit) async {
    // if (emit is MeetingSuccess) {
    final meetings = event.meeting;
    try {
      Map<String, dynamic> result = await MeetingRepo().deleteMeeting(
        id: meetings,
        token: true,
      );
      if (result['error'] == false) {
        emit(const MeetingDeleteSuccess());

      }
      if (result['error'] == true) {
        emit((MeetingDeleteError(result['message'])));

        flutterToastCustom(msg: result['message']);
      }
    } catch (e) {
      emit(MeetingDeleteError(e.toString()));
    }
    // }
  }

  Future<void> _onSearchMeeting(
      SearchMeetings event, Emitter<MeetingState> emit) async {
    try {
      List<MeetingModel> meeting = [];
      _offset = 0;
      emit(MeetingLoading());

      Map<String, dynamic> result = await MeetingRepo().meetingList(limit: _limit, offset: _offset, search: event.searchQuery);


      if (result['error'] == false) {
        meeting = List<MeetingModel>.from(result['data'].map((projectData) => MeetingModel.fromJson(projectData)));
        bool hasReachedMax = meeting.length >=  result['total'];

        emit(MeetingPaginated(meeting: meeting, hasReachedMax: hasReachedMax));
      } else if (result['error'] == true) {
        emit(MeetingError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(MeetingError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreMeeting(
      LoadMoreMeetings event, Emitter<MeetingState> emit) async {
    if (state is MeetingPaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Prevent concurrent API calls
      try {
        final currentState = state as MeetingPaginated;
        final updatedMeeting = List<MeetingModel>.from(currentState.meeting);

        // Fetch additional meetings
        Map<String, dynamic> result = await MeetingRepo().meetingList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
        );

        final additionalMeeting = List<MeetingModel>.from(result['data']
            .map((projectData) => MeetingModel.fromJson(projectData)));

        if (additionalMeeting.isEmpty) {
          _hasReachedMax = true;
        } else {
          _offset += _limit; // Increment the offset consistently
          updatedMeeting.addAll(additionalMeeting);
        }

        // Determine if all data is loaded
        // _hasReachedMax = updatedMeeting.length + additionalMeeting.length >= result['total'];

        // Add the new data to the existing list
        // updatedMeeting.addAll(additionalMeeting);

        if (result['error'] == false) {
          emit(MeetingPaginated(
            meeting: updatedMeeting,
            hasReachedMax: _hasReachedMax,
          ));
        } else {
          emit(MeetingError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        emit(MeetingError("Error: $e"));
      } finally {
        _isLoading = false; // Reset the loading flag
      }
    }
  }
}
