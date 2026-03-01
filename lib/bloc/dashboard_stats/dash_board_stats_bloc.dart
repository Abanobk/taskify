import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../../data/model/dashboard_stats/dashboard_stats_model.dart';
import '../../data/repositories/dashboard_stats/dashboard_stats_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';
import 'dash_board_stats_event.dart';
import 'dash_board_stats_state.dart';

class DashBoardStatsBloc extends Bloc<DashBoardStatsEvent, DashBoardStatsState> {
  int? totalProject;
  int? totalTask;
  int? totaluser;
  int? totalClient;
  int? totalMeeting;
  int? totalTodos;
  int? completedTodos;
  int? pendingTodos;
  List<StatusWiseProjects> projectStats=[];
  List<StatusWiseTasks> taskStats=[];

  DashBoardStatsBloc() : super(DashBoardStatsInitial()) {
    on<StatsList>(_onAllStat);
  }


  Future<void> _onAllStat(StatsList event, Emitter<DashBoardStatsState> emit) async {
    try {

      emit(DashBoardStatsLoading());
      print("AllStat");
      Map<String,dynamic> result = await DashboardStatsRepo().getDashboardStats();
      totalProject =  result['data']['total_projects'];
      totalTask = result['data']['total_tasks'];
       totaluser = result['data']['total_users'];
      totalClient = result['data']['total_clients'];
      totalMeeting = result['data']['total_meetings'];
      totalTodos= result['data']['total_todos'];
      completedTodos= result['data']['completed_todos'];
      pendingTodos= result['data']['pending_todos'];
print("hekh ${result['data']['status_wise_projects'].runtimeType}");
      // projectStats =result['data']['status_wise_projects'];
      final data = result['data']; // Extract the 'data' map
      final projectList = data['status_wise_projects']; // Extract the List

      if (projectList is List) {
        projectStats = projectList
            .map((projectData) => StatusWiseProjects.fromJson(projectData))
            .toList();
      } else {
        throw Exception("Expected a List but got ${projectList.runtimeType}");
      }
      final taskList = data['status_wise_tasks']; // Extract the List

      if (taskList is List) {
        taskStats = taskList
            .map((projectData) => StatusWiseTasks.fromJson(projectData))
            .toList();
      } else {
        throw Exception("Expected a List but got ${projectList.runtimeType}");
      }
      // taskStats =result['data']['status_wise_tasks'];
      if (result['error'] == false) {
        emit(DashBoardStatsSuccess(totalmeeting:totalMeeting!,totalclient: totalClient!,totalproject: totalProject!,totaltask: totalTask!,totaltodos: totalTodos!,totaluser: totaluser!,statusWiseProject: projectStats,statusWiseTask: taskStats));      }
      if (result['error'] == true) {
        emit((DashBoardStatsError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((DashBoardStatsError("Error: $e")));
    }
  }


}


