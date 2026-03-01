import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/project_discussion/project_milestone/project_milestone_event.dart';
import 'package:taskify/bloc/project_discussion/project_milestone/project_milestone_state.dart';

import 'package:taskify/utils/widgets/toast_widget.dart';

import '../../../api_helper/api.dart';
import '../../../data/model/project/milestone.dart';
import '../../../data/repositories/Project/project_repo.dart';

// import '../project_id/projectid_event.dart';

class ProjectMilestoneBloc extends Bloc<ProjectMilestoneEvent, ProjectMilestoneState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _hasReachedMax = false;
  ProjectMilestoneBloc() : super(ProjectMilestoneInitial()) {
    on<MileStoneList>(_getMileStoneLists);
    on<ProjectMilestoneLoadMore>(_onLoadMoreProjectMilestone);
    on<DeleteProjectMilestone>(_deleteProjectMilestone);
    on<SearchProjectMilestone>(_onSearchProjectMilestone);
    on<ProjectMilestoneCreated>(_createMilestoneProject);
    on<UpdateMilestoneProject>(_updateProjectMilestone);
  }

  Future<void> _getMileStoneLists(
      MileStoneList event, Emitter<ProjectMilestoneState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(ProjectMilestoneLoading());
      List<Milestone> milestone = [];
      print("j.kfdkdj ${event.id}");
      Map<String, dynamic> result = await ProjectRepo().getProjectsMilestone(
        id: event.id,
        limit: _limit,
        offset: _offset,
        search: '',
        dateBetweenFrom: event.dateBetweenFrom,
        dateBetweenTo: event.dateBetweenTo,
        startDateFrom: event.startDateFrom,
        startDateTo: event.startDateTo,
        endDateFrom: event.endDateFrom,
        endDateTo: event.endDateTo,
        status:event.status
      );
      milestone = List<Milestone>.from(
          result['data'].map((projectData) => Milestone.fromJson(projectData)));
      if (event.id != null) {
        _offset = 0;
      } else {
        _offset += _limit;
      }
      _hasReachedMax = milestone.length >= result['total'];

      if (result['error'] == false) {
        emit(ProjectMilestonePaginated(
          ProjectMilestone: milestone,
          hasReachedMax: _hasReachedMax,
        ));
      }
      if (result['error'] == true) {
        emit((ProjectMilestoneError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((ProjectMilestoneError("Error: $e")));
    }
  }

  void _deleteProjectMilestone(
      DeleteProjectMilestone event, Emitter<ProjectMilestoneState> emit) async {
    // if (emit is NotesSuccess) {
    final project = event.projectMilestoneId;

    try {
      Map<String, dynamic> result = await ProjectRepo().getDeleteProject(
        id: project.toString(),
        token: true,
      );
      if (result['data']['error'] == false) {
        emit(ProjectMilestoneDeleteSuccess());
      }
      if (result['data']['error'] == true) {
        emit((ProjectMilestoneDeleteError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } catch (e) {
      emit(ProjectMilestoneError(e.toString()));
    }
    // }
  }

  Future<void> _createMilestoneProject(ProjectMilestoneCreated event,
      Emitter<ProjectMilestoneState> emit) async {
    try {
      List<Milestone> project = [];

      emit(ProjectMilestoneCreateLoading());
      var result = await ProjectRepo().createProjectMilestone(
        id :event.projId,
        title: event.title,
        status: event.status,
        startDate: event.startDate,
        endDate: event.endDate,
        desc: event.desc,
        cost: event.cost,
      );
      if (result['error'] == false) {
        emit(ProjectMilestoneCreateSuccess(project));
      }
      if (result['error'] == true) {
        emit(ProjectMilestoneCreateError(result['message']));
        flutterToastCustom(msg: result['message']);
        // add(ProjectDashBoardList());
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((ProjectMilestoneError("Error: $e")));
    }
  }

  // void _selectProject(SelectedProject event, Emitter<ProjectState> emit) {
  //   if (state is ProjectSuccess) {
  //     final currentState = state as ProjectSuccess;
  //     emit(ProjectSuccess(currentState.project, event.selectedIndex,
  //         event.selectedTitle, false));
  //   }

  void _updateProjectMilestone(
      UpdateMilestoneProject event, Emitter<ProjectMilestoneState> emit) async {
    // if (state is ProjectMilestonePaginated) {
    //   List<Milestone> milestone = [];
    //   final id = event.id;
    //   final title = event.title;
    //   final status = event.status;
    //   final startDate = event.startDate;
    //   final endDate = event.endDate;
    //   final desc = event.desc;
    //   final cost = event.cost;
    //   final progress = event.progress;
    //
    //   emit(ProjectMilestoneEditLoading());
    //   // Try to update the task via the repository
    //   try {
    //     Map<String, dynamic> updatedProject =
    //         await ProjectRepo().updateProjectMilestone(
    //       id: id,
    //       title: title,
    //       status: status,
    //       startDate: startDate,
    //       endDate: endDate,
    //       desc: desc,
    //       cost: cost,
    //           progress:progress
    //     );
    //     // project = List<ProjectModel>.from(updatedProject['data']
    //     //     .map((projectData) => ProjectModel.fromJson(projectData)));
    //     if (updatedProject['error'] == false) {
    //       emit(ProjectMilestoneEditSuccess(milestone));
    //       // add(ProjectDashBoardList());
    //       // add(ProjectList());
    //     }
    //     if (updatedProject['error'] == true) {
    //       flutterToastCustom(msg: updatedProject['message']);
    //       // add(ProjectDashBoardList());
    //       emit(ProjectMilestoneEditError(updatedProject['message']));
    //     }
    //   } catch (e) {
    //     print('Error while updating Task: $e');
    //   }
    // }
  }

  Future<void> _onSearchProjectMilestone(
      SearchProjectMilestone event, Emitter<ProjectMilestoneState> emit) async {
    try {
      List<Milestone> milestone = [];
      _offset = 0;
      emit(ProjectMilestoneLoading());
      var result = await ProjectRepo().getProjectsMilestone(
        id:event.id,
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
          dateBetweenFrom: event.dateBetweenFrom,
          dateBetweenTo: event.dateBetweenTo,
          startDateFrom: event.startDateFrom,
          startDateTo: event.startDateTo,
          endDateFrom: event.endDateFrom,
          endDateTo: event.endDateTo);

      if (result['error'] == false) {
        milestone = List<Milestone>.from(result['data']
            .map((projectData) => Milestone.fromJson(projectData)));
        bool hasReachedMax = milestone.length < _limit;
        emit(ProjectMilestonePaginated(
          ProjectMilestone: milestone,
          hasReachedMax: hasReachedMax,
        ));
      } else if (result['error'] == true) {
        emit(ProjectMilestoneError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(ProjectMilestoneError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreProjectMilestone(ProjectMilestoneLoadMore event,
      Emitter<ProjectMilestoneState> emit) async {
    if (state is ProjectMilestonePaginated && !_hasReachedMax) {
      try {
        final currentState = state as ProjectMilestonePaginated;
        final updatedProject =
            List<Milestone>.from(currentState.ProjectMilestone);

        // Fetch additional Projects from the repository
        Map<String, dynamic> result = await ProjectRepo().getProjectsMilestone(
            limit: _limit,
            offset: _offset,
            search: event.searchQuery,
            dateBetweenFrom: event.dateBetweenFrom,
            dateBetweenTo: event.dateBetweenTo,
            startDateFrom: event.startDateFrom,
            startDateTo: event.startDateTo,
            endDateFrom: event.endDateFrom,
            endDateTo: event.endDateTo);
        final additional = List<Milestone>.from(
          result['data']
              .map((projectData) => Milestone.fromJson(projectData)),
        );

        if (additional.isEmpty) {
          _hasReachedMax = true;
        } else {
          _offset += _limit; // Increment the offset consistently
          updatedProject.addAll(additional);
        }

        if (result['error'] == false) {
          emit(ProjectMilestonePaginated(
            ProjectMilestone: updatedProject,
            hasReachedMax: _hasReachedMax,
          ));
        } else {
          emit(ProjectMilestoneError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        emit(ProjectMilestoneError("Error: $e"));
      }
    }
  }
}
