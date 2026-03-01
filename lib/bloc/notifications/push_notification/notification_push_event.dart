import 'package:equatable/equatable.dart';


abstract class NotificationsPushEvent extends Equatable {
  @override
  List<Object?> get props => [];
}


class NotificationPushList extends NotificationsPushEvent {


  NotificationPushList( );

  @override
  List<Object?> get props => [];
}
class MarkAsReadPushNotification extends NotificationsPushEvent {
  final int id;

  MarkAsReadPushNotification(this.id );

  @override
  List<Object?> get props => [id];
}

class DeletePushNotification extends NotificationsPushEvent {
  final int id;

  DeletePushNotification(this.id );

  @override
  List<Object?> get props => [id];
}
class UnreadPushNotificationCount extends NotificationsPushEvent {

  UnreadPushNotificationCount( );

  @override
  List<Object?> get props => [];
}
class SearchPushNotification extends NotificationsPushEvent {
  final String searchQuery;

  SearchPushNotification(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}
class LoadMorePushNotification extends NotificationsPushEvent {
  final String? searchQuery;
  LoadMorePushNotification({this.searchQuery});

  @override
  List<Object?> get props => [];
}