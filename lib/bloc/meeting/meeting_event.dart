import "package:equatable/equatable.dart";

import "../../data/model/meetings/meeting_model.dart";

abstract class MeetingsEvent extends Equatable {
  const MeetingsEvent();
  @override
  List<Object?> get props => [];
}

class CreateMeetings extends MeetingsEvent {
  final String title;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final List<int> userId;
  final List<int> clientIds;
  final String token;

  const CreateMeetings(
      {
        required  this.title,
        required this.startDate,
        required this.endDate,
        required this.startTime,
        required this.endTime,
        required this.userId,
        required this.clientIds,
        required this.token

      });

  @override
  List<Object> get props => [title,startDate,endDate,startTime,endTime,userId,clientIds,token];
}

class MeetingLists extends MeetingsEvent {
  const MeetingLists();

  @override
  List<Object?> get props => [];
}

class AddMeetings extends MeetingsEvent {
  final MeetingModel meeting;

  const AddMeetings(this.meeting);

  @override
  List<Object?> get props => [meeting];
}

class MeetingUpdateds extends MeetingsEvent {
  final MeetingModel meeting;

  const MeetingUpdateds(this.meeting);

  @override
  List<Object> get props => [meeting];

}

class DeleteMeetings extends MeetingsEvent {
  final int meeting;

  const DeleteMeetings(this.meeting);

  @override
  List<Object?> get props => [meeting];
}

class SearchMeetings extends MeetingsEvent {
  final String searchQuery;

  const SearchMeetings(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}

class LoadMoreMeetings extends MeetingsEvent {
  final String searchQuery;
  const LoadMoreMeetings(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}
