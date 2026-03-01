import 'package:equatable/equatable.dart';


abstract class NotificationsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}


class NotificationList extends NotificationsEvent {

NotificationList();
  @override
  List<Object?> get props => [];
}


class DeleteNotification extends NotificationsEvent {
  final int id;

  DeleteNotification(this.id );

  @override
  List<Object?> get props => [id];
}
class MarkAsReadNotification extends NotificationsEvent {
  final int id;

  MarkAsReadNotification(this.id );

  @override
  List<Object?> get props => [id];
}
class UnreadNotificationCount extends NotificationsEvent {

  UnreadNotificationCount( );

  @override
  List<Object?> get props => [];
}
class SearchNotification extends NotificationsEvent {
  final String searchQuery;

  SearchNotification(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}
class LoadMoreNotification extends NotificationsEvent {
  final String? searchQuery;
  LoadMoreNotification({this.searchQuery});

  @override
  List<Object?> get props => [];
}