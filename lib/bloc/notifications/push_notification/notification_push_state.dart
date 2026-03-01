import 'package:equatable/equatable.dart';

import '../../../data/model/notification/notification_model.dart';


abstract class NotificationPushState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationPushInitial extends NotificationPushState {}
class MarkAsReadNotificationPushSuccess extends NotificationPushState {}
class MarkAsReadNotificationPushError extends NotificationPushState {
  final String errorMessage;

  MarkAsReadNotificationPushError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class NotificationPushLoading extends NotificationPushState {}
class TodaysTaskLoading extends NotificationPushState {}

class NotificationPushSuccess extends NotificationPushState {
  NotificationPushSuccess(this.noti,);

  final List<NotificationModel> noti;

  @override
  List<Object> get props => [noti];
}
class AllNotificationPushSuccess extends NotificationPushState {
  AllNotificationPushSuccess(this.allNoti,);

  final List<NotificationModel> allNoti;

  @override
  List<Object> get props => [allNoti];
}

class NotificationPushError extends NotificationPushState {
  final String errorMessage;

  NotificationPushError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class NotificationPushPaginated extends NotificationPushState {
  final List<NotificationModel> noti;
  final bool hasReachedMax;

  NotificationPushPaginated({
    required this.noti,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [noti, hasReachedMax];
}
class UnreadNotificationPush extends NotificationPushState {
  final int total;

  UnreadNotificationPush({
    required this.total,

  });

  @override
  List<Object> get props => [total];
}

class PushNotificationDeleteSuccess extends NotificationPushState {
  PushNotificationDeleteSuccess();
  @override
  List<Object> get props => [];
}