import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/data/model/notification/notification_model.dart';
import '../../../api_helper/api.dart';
import '../../../data/repositories/notification/notification_repo.dart';
import '../../../utils/widgets/toast_widget.dart';

import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationsEvent, NotificationsState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
   int? totalUnreadCount =0;
  bool _isLoading = false; // Add a loading flag to prevent multiple calls

  bool _hasReachedMax = false;
  NotificationBloc() : super(NotificationInitial()) {

    on<NotificationList>(_onAllNotification);
    on<UnreadNotificationCount>(_onUnreadNotificationCount);
    on<SearchNotification>(_onSearchNotes);
    on<DeleteNotification>(onDeleteNotifications);
    on<LoadMoreNotification>(_onLoadMoreNotification);
    on<MarkAsReadNotification>(_onMarkAsReadNotification);
  }

  Future<void> _onSearchNotes(
      SearchNotification event, Emitter<NotificationsState> emit) async {
    try {
      emit(NotificationLoading());

      List<NotificationModel> notes=[];


      Map<String,dynamic> result = await NotificationRepo()
          .getNoti(limit: _limit, offset: 0, search: event.searchQuery,token: true,notificationType: 'system');
      notes = List<NotificationModel>.from(result['data']
          .map((projectData) => NotificationModel.fromJson(projectData)));

      bool hasReachedMax = notes.length < _limit;
      if (result['error'] == false) {
        emit(NotificationPaginated(noti:notes,hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((NotificationError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      emit(NotificationError("Error: $e"));
    }
  }

  Future<void> _onAllNotification(NotificationList event, Emitter<NotificationsState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(NotificationLoading());
      List<NotificationModel> notification =[];
      Map<String,dynamic> result = await NotificationRepo().getNoti(limit: _limit, offset: _offset, search: '',token: true,notificationType: 'system');
      notification = List<NotificationModel>.from(result['data']
          .map((projectData) => NotificationModel.fromJson(projectData)));

      _offset += _limit;
      _hasReachedMax = notification.length < _limit;
      if (result['error'] == false) {
        emit(NotificationPaginated(noti: notification, hasReachedMax: _hasReachedMax));
      }
      if (result['error'] == true) {
        emit((NotificationError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }

      // emit(NotificationLoading());
      // List<Notifications> notification = await NotificationRepo().getNotification(token: true);

      // emit(AllNotificationSuccess(notification));
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((NotificationError("Error: $e")));
    }
  }
  Future<void> _onUnreadNotificationCount(UnreadNotificationCount event, Emitter<NotificationsState> emit) async {
    try {
      emit(NotificationLoading());
      Map<String,dynamic> result = await NotificationRepo().getUnreadNotiCount(token: true,notificationType: 'system');
       List<NotificationModel>.from(result['data'].map((projectData) => NotificationModel.fromJson(projectData)));
       totalUnreadCount =result['total'];
      if (result['error'] == false) {
        emit(UnreadNotification(total: totalUnreadCount!));
      }
      if (result['error'] == true) {
        emit((NotificationError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((NotificationError("Error: $e")));
    }
  }
  Future<void> _onMarkAsReadNotification(MarkAsReadNotification event, Emitter<NotificationsState> emit) async {
    try {
      emit(NotificationLoading());
      Map<String,dynamic> result = await  NotificationRepo().markAsReadNoti(id: event.id);

      if (result['error'] == false) {
        emit(MarkAsReadNotificationSuccess());
        add( NotificationList());
        flutterToastCustom(msg: result['message']);

      }
      if (result['error'] == true) {
        emit((MarkAsReadNotificationError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((MarkAsReadNotificationError("Error: $e")));
    }
  }


  void onDeleteNotifications(DeleteNotification event, Emitter<NotificationsState> emit) async {
    // if (emit is NotesSuccess) {
    final noti = event.id;
    try {
      Map<String,dynamic> result =   await NotificationRepo().getDeleteNoti(
        id: noti.toString(),
        token: true,
      );
      if (result['error'] == false) {
        emit(NotificationDeleteSuccess());
        add( NotificationList());
        flutterToastCustom(msg: result['message']);

      }
      if (result['error'] == true) {
        emit((NotificationError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
    // }
  }


  Future<void> _onLoadMoreNotification(
      LoadMoreNotification event, Emitter<NotificationsState> emit) async {
    if (state is NotificationPaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Prevent concurrent API calls

      try {
        final currentState = state as NotificationPaginated;
        final updatedNotification = List<NotificationModel>.from(currentState.noti);

        // Fetch additional Notifications from the repository
        List<NotificationModel> additionalNotes = [];
        Map<String, dynamic> result = await NotificationRepo().getNoti(
          limit: _limit,
          offset: _offset,
          notificationType: 'system',
          search: event.searchQuery,
          token: true,
        );

        additionalNotes = List<NotificationModel>.from(result['data']
            .map((projectData) => NotificationModel.fromJson(projectData)));

        // Update the offset for the next load
        if (additionalNotes.isNotEmpty) {
          _offset += _limit; // Increment the offset by the limit
        }

        // Check if the total number of items has been reached
        if (updatedNotification.length + additionalNotes.length >= result['total']) {
          _hasReachedMax = true;
        } else {
          _hasReachedMax = false;
        }

        // Add the newly fetched Notifications to the existing list
        updatedNotification.addAll(additionalNotes);

        if (result['error'] == false) {
          emit(NotificationPaginated(
              noti: updatedNotification, hasReachedMax: _hasReachedMax));
        }

        if (result['error'] == true) {
          emit((NotificationError(result['message'])));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        emit(NotificationError("Error: $e"));
      } finally {
        _isLoading = false; // Reset the loading flag after the API call finishes
      }
    }
  }

}
