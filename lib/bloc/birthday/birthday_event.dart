import 'package:equatable/equatable.dart';

abstract class BirthdayEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AllBirthdayList extends BirthdayEvent {
  final int upcomingDays;
  final List<int>? userId;
  AllBirthdayList(this.upcomingDays,this.userId);

  @override
  List<Object> get props => [upcomingDays,userId!];

}
class WeekBirthdayList extends BirthdayEvent {
  final int upcomingDays;
  final List<int>? userId;
  final List<int>? clientId;
  final List<String>? clientNames;
  final List<String>? userNames;

  WeekBirthdayList(this.upcomingDays,this.userId,this.clientId,this.clientNames,this.userNames);

  @override
  List<Object> get props => [upcomingDays,userId!];
}
class LoadMoreBirthday extends BirthdayEvent {
  final int upcomingDays;
  final List<int>? userId;
  final List<int>? clientId;
  LoadMoreBirthday(this.upcomingDays,this.userId,this.clientId);

  @override
  List<Object?> get props => [upcomingDays, userId!];
}

class UpdateSelectedUsers extends BirthdayEvent {
  final List<String> userSelectedname;
  final List<int> userSelectedId;

   UpdateSelectedUsers(this.userSelectedname, this.userSelectedId);

  @override
  List<Object> get props => [userSelectedname, userSelectedId];
}

class UpdateSelectedClients extends BirthdayEvent {
  final List<String> clientSelectedname;
  final List<int> clientSelectedId;

   UpdateSelectedClients(this.clientSelectedname, this.clientSelectedId);

  @override
  List<Object> get props => [clientSelectedname, clientSelectedId];
}