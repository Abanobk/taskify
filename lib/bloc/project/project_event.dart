
import 'package:equatable/equatable.dart';

abstract class ProjectEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProjectList extends ProjectEvent {

  final int? userId;
  final int? clientId;
  final int? priorityId;
  final int? statusId;
  final int? tagId;
   ProjectList({this.tagId,this.clientId,this.userId,this.statusId,this.priorityId});

  @override
  List<Object?> get props => [tagId,clientId,userId,statusId,priorityId];
}

class ProjectDashBoardFavList extends ProjectEvent {
  final int? isFav;
  ProjectDashBoardFavList({this.isFav});

  @override
  List<Object?> get props => [isFav];
}
class ProjectMindMap extends ProjectEvent {
  final int? id;
  ProjectMindMap({this.id});

  @override
  List<Object?> get props => [id];
}

class ProjectDashBoardList extends ProjectEvent {
  final List<int>? userId;
  final int? id;
  final int? isFav;
  final List<int>? clientId;
  final List<int>? priorityId;
  final List<int>? statusId;
  final List<int>? tagId;
  final String? fromDate;
  final String? toDate;
  ProjectDashBoardList({this.tagId,this.id,this.isFav,this.clientId,this.userId,this.statusId,this.priorityId,this.fromDate,this.toDate});

  @override
  List<Object?> get props => [tagId,id,clientId,isFav,userId,statusId,priorityId,fromDate,toDate];
}
// class MileStoneList extends ProjectEvent {
//   final int? id;
//   final String? fromDate;
//   final String? dateBetweenFrom;
//   final String? dateBetweenTo;
//   final String? startDateFrom;
//   final String? startDateTo;
//   final String? endDateFrom;
//   final String? endDateTo;
//
//
//
//   MileStoneList({this.id,this.fromDate,this.dateBetweenFrom,this.dateBetweenTo,this.endDateFrom,this.endDateTo,this.startDateFrom,this.startDateTo});
//
//   @override
//   List<Object?> get props => [id,fromDate,dateBetweenFrom,dateBetweenTo,startDateFrom,startDateTo,endDateFrom,endDateTo];
// }
class SearchProject extends ProjectEvent {
  final List<int>? clientId;
  final List<int>? userId;
  final String? searchQuery;



  SearchProject(this.searchQuery,this.clientId,this.userId);

  @override
  List<Object?> get props => [searchQuery,userId,clientId];
}
class ProjectId extends ProjectEvent {
  final int? id;



  ProjectId(this.id);

  @override
  List<Object?> get props => [id];
}
class ProjectLoadMore extends ProjectEvent {
  final String? searchQuery;
  final List<int>? clientId;
  final List<int>? userId;


  ProjectLoadMore(this.searchQuery,this.clientId,this.userId);

  @override
  List<Object?> get props => [searchQuery,clientId,userId];
}
class SelectedProject extends ProjectEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectedProject(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}
class UpdateProject extends ProjectEvent {
  final int id;
  final String title;
  final int statusId;
  final int priorityId;
  final String startDate;
  final String endDate;
  final String desc;
  final String note;
  final String  budget;
  final String taskAccess;
  final List<int> userId;
  final List<int> clientId;
  final List<int> tagId;
  final int? clientCanDiscuss;
  final int? enable;
  final Map<String, dynamic> customFieldValues; // Declare the property

  UpdateProject(
      {
        required  this.id,
        required this.title,
        required this.statusId,
        required this.priorityId,
        required this.startDate,
        required this.endDate,
        required this.desc,
        required this.taskAccess,
        required this.clientCanDiscuss,
        required this.note,
        required this.budget,
        required this.enable,
        required this.userId,
        required this.clientId,
        required this.customFieldValues, // Add this,
        required this.tagId,});
  @override
  List<Object> get props => [
    id,
    title,
    statusId,
    priorityId,
    startDate,
    endDate,
    desc,
    note,
    taskAccess,
    budget,clientId,userId,
    tagId,
    customFieldValues

  ];
}
class ProjectCreated extends ProjectEvent {
  final String title;
  final int statusId;
  final int priorityId;
  final String startDate;
  final String endDate;
  final String desc;
  final int? clientCanDiscuss;
  final int? enable;
  final String note;
  final String  budget;
  final String taskAccess;
  final List<int> userId;
  final List<int> clientId;
  final List<int> tagId;
  final Map<String, dynamic> customFieldValues; // Declare the property

  ProjectCreated(
      {
        required this.title,
        required this.enable,
        required this.clientCanDiscuss,
        required this.statusId,
        required this.priorityId,
        required this.startDate,
        required this.endDate,
        required this.desc,
        required this.taskAccess,
        required this.note,
        required this.budget,
        required this.userId,
        required this.clientId,
        required this.tagId,
      required this.customFieldValues});
  @override
  List<Object> get props => [
    title,
    statusId,
    priorityId,
    startDate,
    endDate,
    desc,
    note,
    taskAccess,
    budget,clientId,userId,
    tagId,
    customFieldValues
  ];
}

class DeleteProject extends ProjectEvent {
  final int projectId;

  DeleteProject(this.projectId );

  @override
  List<Object?> get props => [projectId];
}