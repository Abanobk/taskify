import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/notification/notification_model.dart';

abstract class NotificationsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationsState {}

class NotificationLoading extends NotificationsState {}
class TodaysTaskLoading extends NotificationsState {}
class MarkAsReadNotificationSuccess extends NotificationsState {}
class MarkAsReadNotificationError extends NotificationsState {
  final String errorMessage;

  MarkAsReadNotificationError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class NotificationSuccess extends NotificationsState {
  NotificationSuccess(this.noti,);

  final List<NotificationModel> noti;

  @override
  List<Object> get props => [noti];
}
class AllNotificationSuccess extends NotificationsState {
  AllNotificationSuccess(this.allNoti,);

  final List<NotificationModel> allNoti;

  @override
  List<Object> get props => [allNoti];
}

class NotificationError extends NotificationsState {
  final String errorMessage;

  NotificationError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class NotificationPaginated extends NotificationsState {
  final List<NotificationModel> noti;
  final bool hasReachedMax;

  NotificationPaginated({
    required this.noti,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [noti, hasReachedMax];
}
class UnreadNotification extends NotificationsState {
  final int total;

  UnreadNotification({
    required this.total,

  });

  @override
  List<Object> get props => [total];
}
class NotificationDeleteSuccess extends NotificationsState {
   NotificationDeleteSuccess();
  @override
  List<Object> get props => [];
}