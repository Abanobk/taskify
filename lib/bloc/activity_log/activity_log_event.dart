import 'package:equatable/equatable.dart';


abstract class ActivityLogEvent extends Equatable {
  @override
  List<Object?> get props => [];
}


class AllActivityLogList extends ActivityLogEvent {
  final String? type;
  final int? typeId;

  AllActivityLogList({this.type,this.typeId});

  @override
  List<Object> get props => [];
}



class DeleteActivityLog extends ActivityLogEvent {
  final int activityLog;

  DeleteActivityLog(this.activityLog );

  @override
  List<Object?> get props => [activityLog];
}
class SearchActivityLog extends ActivityLogEvent {
  final String searchQuery;
  final String? type;
  final int? typeId;

  SearchActivityLog(this.searchQuery,this.typeId,this.type);

  @override
  List<Object?> get props => [searchQuery,typeId,type];
}
class LoadMoreActivityLog extends ActivityLogEvent {
  final String searchWord;

  LoadMoreActivityLog(this.searchWord);

  @override
  List<Object?> get props => [];
}