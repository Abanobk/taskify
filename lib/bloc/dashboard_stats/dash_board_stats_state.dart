import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/dashboard_stats/dashboard_stats_model.dart';



abstract class DashBoardStatsState extends Equatable{
  @override
  List<Object?> get props => [];
}
class DashBoardStatsInitial extends DashBoardStatsState {}
class DashBoardStatsLoading extends DashBoardStatsState {}
class DashBoardStatsSuccess extends DashBoardStatsState {
final int totaltask;
final int totaltodos;
final int totalmeeting;
final int totalclient;
final int totaluser;
final int totalproject;
final List<StatusWiseProjects> statusWiseProject;
final List<StatusWiseTasks> statusWiseTask;


   DashBoardStatsSuccess({
    required this.totaltask,required this.totaltodos,required this.totaluser,required this.totalclient,
    required this.totalmeeting,required this.totalproject,required this.statusWiseProject,required this.statusWiseTask
 });
}
class DashBoardStatsError extends DashBoardStatsState {
  final String errorMessage;
  DashBoardStatsError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
