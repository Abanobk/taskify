import 'package:equatable/equatable.dart';


abstract class WorkAnniversaryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AllWorkAnniversaryList extends WorkAnniversaryEvent {
  AllWorkAnniversaryList();

  @override
  List<Object> get props => [];
}
class WeekWorkAnniversaryList extends WorkAnniversaryEvent {
  final int upcomingDays;
  final List<int>? userId;
  final List<int>? clientId;
  final List<String>? clientNames;
  final List<String>? userNames;
  WeekWorkAnniversaryList(this.userId,this.clientId,this.upcomingDays,this.clientNames,this.userNames);

  @override
  List<Object> get props => [upcomingDays,userId!];
}
class LoadMoreWorkAnniversary extends WorkAnniversaryEvent {
  final int upcomingDays;
  final List<int>? userId;
  LoadMoreWorkAnniversary(this.upcomingDays,this.userId);

  @override
  List<Object?> get props => [upcomingDays,userId];
}

class UpdateSelectedUsersWorkAnni extends WorkAnniversaryEvent {
  final List<String> userSelectedname;
  final List<int> userSelectedId;

  UpdateSelectedUsersWorkAnni(this.userSelectedname, this.userSelectedId);

  @override
  List<Object> get props => [userSelectedname, userSelectedId];
}

class UpdateSelectedClientsWorkAnni extends WorkAnniversaryEvent {
  final List<String> clientSelectedname;
  final List<int> clientSelectedId;

  UpdateSelectedClientsWorkAnni(this.clientSelectedname, this.clientSelectedId);

  @override
  List<Object> get props => [clientSelectedname, clientSelectedId];
}

class UpdateDaysValue extends WorkAnniversaryEvent {
  final int days;

  UpdateDaysValue(this.days);
}