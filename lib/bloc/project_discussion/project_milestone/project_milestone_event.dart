
import 'package:equatable/equatable.dart';

abstract class ProjectMilestoneEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class MileStoneList extends ProjectMilestoneEvent {
  final int? id;

  final String? fromDate;
  final String? dateBetweenFrom;
  final String? dateBetweenTo;
  final String? startDateFrom;
  final String? startDateTo;
  final String? endDateFrom;
  final String? endDateTo;
  final String? searchQuery;
  final String? status;


  MileStoneList({this.id,this.searchQuery,this.dateBetweenFrom,
    this.dateBetweenTo,this.endDateTo,this.endDateFrom,this.startDateTo
    ,this.startDateFrom,this.fromDate,this.status});

  @override
  List<Object?> get props => [id,searchQuery,dateBetweenTo,dateBetweenTo,dateBetweenTo,
    dateBetweenFrom,startDateTo,startDateFrom,endDateTo,endDateFrom];
}
class SearchProjectMilestone extends ProjectMilestoneEvent {
  final int? id;
  final String? fromDate;
  final String? dateBetweenFrom;
  final String? dateBetweenTo;
  final String? startDateFrom;
  final String? startDateTo;
  final String? endDateFrom;
  final String? endDateTo;
  final String? searchQuery;



  SearchProjectMilestone(this.id,this.searchQuery,this.dateBetweenFrom,
      this.dateBetweenTo,this.endDateTo,this.endDateFrom,this.startDateTo
      ,this.startDateFrom,this.fromDate);

  @override
  List<Object?> get props => [id,searchQuery,dateBetweenTo,dateBetweenTo,dateBetweenTo,
    dateBetweenFrom,startDateTo,startDateFrom,endDateTo,endDateFrom

  ];
}
class ProjectMilestoneLoadMore extends ProjectMilestoneEvent {
  final int? id;
  final String? searchQuery;
  final String? fromDate;
  final String? dateBetweenFrom;
  final String? dateBetweenTo;
  final String? startDateFrom;
  final String? startDateTo;
  final String? endDateFrom;
  final String? endDateTo;


  ProjectMilestoneLoadMore(this.id,this.searchQuery,this.fromDate,this.dateBetweenFrom,this.dateBetweenTo,this.startDateFrom,
      this.startDateTo,this.endDateFrom,this.endDateTo);

  @override
  List<Object?> get props => [searchQuery,fromDate,dateBetweenTo,dateBetweenFrom,
    startDateTo,startDateFrom,endDateTo,endDateFrom  ];
}
class UpdateMilestoneProject extends ProjectMilestoneEvent {
  final int id;
  final int projectId;
  final String title;
  final String status;

  final String startDate;
  final String endDate;
  final String desc;
  final String  cost;
  final int?  progress;

  UpdateMilestoneProject(
      {
        required  this.id,
        required  this.projectId,
        required this.title,
        required this.status,

        required this.startDate,
        required this.endDate,
        required this.desc,
 this.progress,
        required this.cost,
        });
  @override
  List<Object> get props => [
    id,
    title,
    status,

    startDate,
    endDate,
    desc,
   cost
  ];
}
class ProjectMilestoneCreated extends ProjectMilestoneEvent {
  final int projId;
  final String title;
  final String status;

  final String startDate;
  final String endDate;
  final String desc;
  final String  cost;

  ProjectMilestoneCreated(
      {
        required this.title,
        required this.status,
        required this.projId,

        required this.startDate,
        required this.endDate,
        required this.desc,

        required this.cost,});
  @override
  List<Object> get props => [
    title,
    status,
projId,
    startDate,
    endDate,
    desc,
    cost
  ];
}

class DeleteProjectMilestone extends ProjectMilestoneEvent {
  final int projectMilestoneId;

  DeleteProjectMilestone(this.projectMilestoneId );

  @override
  List<Object?> get props => [projectMilestoneId];
}