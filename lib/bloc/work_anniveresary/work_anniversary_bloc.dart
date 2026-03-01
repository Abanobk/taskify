// import 'dart:async';
//
// import 'package:bloc/bloc.dart';
// import 'package:flutter/foundation.dart';
// import 'package:taskify/bloc/work_anniveresary/work_anniversary_event.dart';
// import 'package:taskify/bloc/work_anniveresary/work_anniversary_state.dart';
// import '../../data/model/work_anniversary/work_anni_model.dart';
// import '../../data/repositories/work_anniniversary/work_anniniversary_repo.dart';
// import '../../api_helper/api.dart';
// import '../../utils/widgets/toast_widget.dart';
//
//
// class WorkAnniversaryBloc extends Bloc<WorkAnniversaryEvent, WorkAnniversaryState> {
//   int _offset = 0; // Start with the initial offset
//   final int _limit = 10;
//   bool _hasReachedMax = false;
//   WorkAnniversaryBloc() : super(WorkAnniversaryInitial()) {
//     on<AllWorkAnniversaryList>(_getAllWorkAnniversary);
//     on<WeekWorkAnniversaryList>(_onWeekWorkAnniversary);
//     on<LoadMoreWorkAnniversary>(_onLoadMoreWorkAnniversary);
//     on<UpdateSelectedUsers>(_onUpdateSelectedUsers);
//     on<UpdateSelectedClients>(_onUpdateSelectedClients);
//   }
//
//   void _onUpdateSelectedUsers(UpdateSelectedUsers event, Emitter<WorkAnniversaryState> emit) {
//     if (state is WorkAnniversaryPaginated) {
//       final currentState = state as WorkAnniversaryPaginated;
//       emit(currentState.copyWith(
//         selectedUserIds: event.userIds,
//         selectedUserNames: event.userNames,
//       ));
//     }
//   }
//
//   void _onUpdateSelectedClients(UpdateSelectedClients event, Emitter<WorkAnniversaryState> emit) {
//     if (state is WorkAnniversaryPaginated) {
//       final currentState = state as WorkAnniversaryPaginated;
//       emit(currentState.copyWith(
//         selectedClientIds: event.clientIds,
//         selectedClientNames: event.clientNames,
//       ));
//     }
//   }
//
//   Future<void> _getAllWorkAnniversary(AllWorkAnniversaryList event, Emitter<WorkAnniversaryState> emit) async {
//     try {
//       _offset = 0; // Reset offset for the initial load
//       _hasReachedMax = false;
//       emit(WorkAnniversaryLoading());
//       List<WorkAnniversaryModel> workAnniversary =[];
//       await WorkAnniversaryRepo().getWorkAnniversary(limit: _limit, offset: _offset,token: true);
//       _offset += _limit;
//       _hasReachedMax = workAnniversary.length < _limit;
//       emit(WorkAnniversaryPaginated(workAnniversaries: workAnniversary, hasReachedMax: _hasReachedMax));
//       // emit(WorkAnniversaryLoading());
//       // List<WorkAnniversarys> workAnniversary = await WorkAnniversaryRepo().getWorkAnniversary(token: true);
//
//       // emit(AllWorkAnniversarySuccess(workAnniversary));
//     } on ApiException catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//       emit((WorkAnniversaryError("Error: $e")));
//     }
//   }
//
//   Future<void> _onWeekWorkAnniversary(WeekWorkAnniversaryList event, Emitter<WorkAnniversaryState> emit) async {
//     try {
//       _offset = 0; // Reset offset for the initial load
//       _hasReachedMax = false;
//       emit(TodaysWorkAnniversaryLoading());
//       List<WorkAnniversaryModel> workAnniversary = [];
//
//       Map<String,dynamic> result = await WorkAnniversaryRepo().getWorkAnniversary(
//         limit: _limit,
//         offset: _offset,
//         token: true,
//         upComingDays: event.upcomingDays,
//         userId: event.userId,
//         clientId: event.clientId
//       );
//
//       if(result['data'] != null) {
//         workAnniversary = List<WorkAnniversaryModel>.from(result['data']
//             .map((projectData) => WorkAnniversaryModel.fromJson(projectData)));
//       }
//
//       _offset += _limit;
//       _hasReachedMax = workAnniversary.length < _limit;
//
//       if (result['error'] == false) {
//         emit(WorkAnniversaryPaginated(
//           workAnniversaries: workAnniversary,
//           hasReachedMax: _hasReachedMax,
//           selectedUserIds: event.userId ?? [],
//           selectedClientIds: event.clientId ?? []
//         ));
//       } else {
//         emit(WorkAnniversaryError(result['message']));
//         flutterToastCustom(msg: result['message']);
//       }
//     } on ApiException catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//       emit(WorkAnniversaryError("Error: $e"));
//     }
//   }
//
//
//
//
//   Future<void> _onLoadMoreWorkAnniversary(
//       LoadMoreWorkAnniversary event, Emitter<WorkAnniversaryState> emit) async {
//
//     if (state is WorkAnniversaryPaginated && !_hasReachedMax) {
//       try {
//         List<WorkAnniversaryModel> additionalNotes = [];
//         final currentState = state as WorkAnniversaryPaginated;
//         final updatedNotes = List<WorkAnniversaryModel>.from(currentState.workAnniversaries);
//          Map<String,dynamic> result = await WorkAnniversaryRepo().getWorkAnniversary(limit: _limit, offset: _offset, token: true,upComingDays: event.upcomingDays,userId:event.userId);
//         if (result['error'] == false) {
//           additionalNotes = List<WorkAnniversaryModel>.from(result['data']
//               .map((projectData) => WorkAnniversaryModel.fromJson(projectData)));
//           _offset = updatedNotes.length + additionalNotes.length;
//
//           if (updatedNotes.length + additionalNotes.length >= result['total']) {
//             _hasReachedMax = true;
//           } else {
//             _hasReachedMax = false;
//           }
//           updatedNotes.addAll(additionalNotes);
//           if (result['error'] == false) {
//           emit(WorkAnniversaryPaginated(workAnniversaries: updatedNotes, hasReachedMax: _hasReachedMax));
//         }
//         if (result['error'] == true) {
//           emit((WorkAnniversaryError(result['message'])));
//           flutterToastCustom(msg: result['message']);
//
//         }
//         }} on ApiException catch (e) {
//         // Handle any errors that occur during the API call
//         emit(WorkAnniversaryError("Error: $e"));
//       }
//     }
//   }
//
// }
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/work_anniveresary/work_anniversary_event.dart';
import 'package:taskify/bloc/work_anniveresary/work_anniversary_state.dart';
import '../../data/model/work_anniversary/work_anni_model.dart';
import '../../data/repositories/work_anniniversary/work_anniniversary_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';

class WorkAnniversaryBloc
    extends Bloc<WorkAnniversaryEvent, WorkAnniversaryState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _hasReachedMax = false;
  WorkAnniversaryBloc() : super(WorkAnniversaryInitial()) {
    // on<AllWorkAnniversaryList>(_allWorkAnniversary);
    on<WeekWorkAnniversaryList>(_weekWorkAnniversary);
    on<LoadMoreWorkAnniversary>(_onLoadMoreWorkAnniversary);
    on<UpdateSelectedClientsWorkAnni>(_onUpdateSelectedClients);
    on<UpdateSelectedUsersWorkAnni>(_onUpdateSelectedUsers);

  }
  Future<void> _onUpdateSelectedUsers(UpdateSelectedUsersWorkAnni event, Emitter<WorkAnniversaryState> emit) async {
    if (kDebugMode) {
      print(
          'UpdateSelectedUsers: userSelectedname=${event.userSelectedname}, userSelectedId=${event.userSelectedId}');
    }
    if (state is WorkAnniversaryPaginated) {
      final currentState = state as WorkAnniversaryPaginated;
      emit(currentState.copyWith(
        userSelectedname: event.userSelectedname,
        userSelectedId: event.userSelectedId,
      ));
    } else {
      emit(WorkAnniversaryPaginated(
        workAnniversary: [],
        hasReachedMax: false,
        userSelectedname: event.userSelectedname,
        userSelectedId: event.userSelectedId,
        clientSelectedname: [],
        clientSelectedId: [],
      ));
    }
  }

  Future<void> _onUpdateSelectedClients(UpdateSelectedClientsWorkAnni event,
      Emitter<WorkAnniversaryState> emit) async {
    if (kDebugMode) {
      print(
          'UpdateSelectedClients: clientSelectedname=${event.clientSelectedname}, clientSelectedId=${event.clientSelectedId}');
    }
    if (state is WorkAnniversaryPaginated) {
      final currentState = state as WorkAnniversaryPaginated;
      emit(currentState.copyWith(
        clientSelectedname: event.clientSelectedname,
        clientSelectedId: event.clientSelectedId,
      ));
    } else {
      emit(WorkAnniversaryPaginated(
        workAnniversary: [],
        hasReachedMax: false,
        userSelectedname: [],
        userSelectedId: [],
        clientSelectedname: event.clientSelectedname,
        clientSelectedId: event.clientSelectedId,
      ));
    }
  }

  Future<void> _weekWorkAnniversary(
      WeekWorkAnniversaryList event, Emitter<WorkAnniversaryState> emit) async {
    try {
      emit(TodaysWorkAnniversaryLoading());
      _offset = 0;
      _hasReachedMax = false;

      // 🌐 API call
      final result = await WorkAnniversaryRepo().getWorkAnniversary(
        limit: _limit,
        offset: _offset,
        token: true,
        upComingDays: event.upcomingDays,
        userId: event.userId,
        clientId: event.clientId,
      );

      final workAnniversary = List<WorkAnniversaryModel>.from(
        result['data']?.map(
                (projectData) => WorkAnniversaryModel.fromJson(projectData)) ??
            [],
      );

      _offset += _limit;
      _hasReachedMax = workAnniversary.length < _limit;

      if (result['error'] == false) {
        // ✅ Preserve names from state if available
        final userSelectedname = state is WorkAnniversaryPaginated
            ? (state as WorkAnniversaryPaginated).userSelectedname
            : event.userNames;

        final clientSelectedname = state is WorkAnniversaryPaginated
            ? (state as WorkAnniversaryPaginated).clientSelectedname
            : event.clientNames;

        emit(WorkAnniversaryPaginated(
          workAnniversary: workAnniversary,
          hasReachedMax: _hasReachedMax,
          userSelectedname: userSelectedname ?? [],
          userSelectedId: event.userId ?? [],
          clientSelectedId: event.clientId ?? [],
          clientSelectedname: clientSelectedname ?? [],
        ));
      } else {
        emit(WorkAnniversaryError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print('WeekWorkAnniversary error: $e');
      }
      emit(WorkAnniversaryError("Error: $e"));
      flutterToastCustom(msg: "$e");
    }
  }

  Future<void> _onLoadMoreWorkAnniversary(
      LoadMoreWorkAnniversary event, Emitter<WorkAnniversaryState> emit) async {
    if (state is WorkAnniversaryPaginated && !_hasReachedMax) {
      try {
        List<WorkAnniversaryModel> additionalNotes = [];
        final currentState = state as WorkAnniversaryPaginated;
        final updatedNotes =
            List<WorkAnniversaryModel>.from(currentState.workAnniversary);
        Map<String, dynamic> result = await WorkAnniversaryRepo()
            .getWorkAnniversary(
                limit: _limit,
                offset: _offset,
                token: true,
                upComingDays: event.upcomingDays,
                userId: event.userId);
        if (result['error'] == false) {
          additionalNotes = List<WorkAnniversaryModel>.from(result['data'].map(
              (projectData) => WorkAnniversaryModel.fromJson(projectData)));
          _offset = updatedNotes.length + additionalNotes.length;

          if (updatedNotes.length + additionalNotes.length >= result['total']) {
            _hasReachedMax = true;
          } else {
            _hasReachedMax = false;
          }
          updatedNotes.addAll(additionalNotes);
          if (result['error'] == false) {
            emit(WorkAnniversaryPaginated(
              workAnniversary: updatedNotes,
              hasReachedMax: _hasReachedMax,
              userSelectedname: currentState.userSelectedname,
              userSelectedId: currentState.userSelectedId,
              clientSelectedname: currentState.clientSelectedname,
              clientSelectedId: currentState.clientSelectedId,
            ));
          }
          if (result['error'] == true) {
            emit((WorkAnniversaryError(result['message'])));
            flutterToastCustom(msg: result['message']);
          }
        }
      } on ApiException catch (e) {
        // Handle any errors that occur during the API call
        emit(WorkAnniversaryError("Error: $e"));
      }
    }
  }
}
