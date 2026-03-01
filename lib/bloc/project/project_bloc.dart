import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/project/project_event.dart';
import 'package:taskify/bloc/project/project_state.dart';
import 'package:taskify/data/model/Project/all_project.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import '../../data/repositories/Project/project_repo.dart';
import '../../api_helper/api.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _hasReachedMax = false;
  ProjectBloc() : super(ProjectInitial()) {
    on<ProjectDashBoardList>(_getProjectLists);
    on<ProjectDashBoardFavList>(_getProjectFavLists);
    on<SelectedProject>(_onSelectProject);
    on<ProjectLoadMore>(_onLoadMoreProject);
    on<DeleteProject>(_onDeleteProject);
    on<SearchProject>(_onSearchProject);
    on<ProjectCreated>(_onCreateProject);
    on<UpdateProject>(_onUpdateProject);
    on<ProjectMindMap>(_onProjectMindMap);
  }

  Future<void> _onProjectMindMap(
      ProjectMindMap event, Emitter<ProjectState> emit) async {
    try {
      //
      emit(ProjectMapLoading());

      Map<String, dynamic> result = await ProjectRepo().getProjectMindMap(
          id: event.id,
    );
print("fghbj ${result['original']['error']}");

      if (result['original']['error'] == false) {
        emit(ProjectMindMapSuccess(
result
        ));
      }
      if (result['error'] == true) {
        emit((ProjectError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((ProjectError("Error: $e")));
    }
  }

  Future<void> _getProjectLists(
      ProjectDashBoardList event, Emitter<ProjectState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(ProjectLoading());
      List<ProjectModel> notification = [];
      Map<String, dynamic> result = await ProjectRepo().getProjects(
          id: event.id,
          isFav:event.isFav,
          limit: _limit,
          offset: _offset,
          search: '',
          userId: event.userId,
          clientId: event.clientId,
          tagId: event.tagId,
          statusId: event.statusId,
          priorityId: event.priorityId,
          fromDate: event.fromDate,
          toDate: event.toDate);
      notification = List<ProjectModel>.from(result['data']
          .map((projectData) => ProjectModel.fromJson(projectData)));
      if(event.id != null ){
        _offset = 0 ;
      }else{
        _offset += _limit;
        _hasReachedMax = notification.length >= result['total'];
      }

      if (result['error'] == false) {
        emit(ProjectPaginated(
          project: notification,
          hasReachedMax: _hasReachedMax,
        ));
      }
      if (result['error'] == true) {
        emit((ProjectError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((ProjectError("Error: $e")));
    }
  }
  Future<void> _getProjectFavLists(
      ProjectDashBoardFavList event, Emitter<ProjectState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(ProjectLoading());
      List<ProjectModel> fav = [];
      Map<String, dynamic> result = await ProjectRepo().getProjectsFav(
          isFav: event.isFav,
          limit: _limit,
          offset: _offset,
          search: '',
         );
      fav = List<ProjectModel>.from(result['data']
          .map((projectData) => ProjectModel.fromJson(projectData)));
        _offset += _limit;
        _hasReachedMax = fav.length >= result['total'];


      if (result['error'] == false) {
        emit(ProjectFavPaginated(
          project: fav,
          hasReachedMax: _hasReachedMax,
        ));
      }
      if (result['error'] == true) {
        emit((ProjectError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((ProjectError("Error: $e")));
    }
  }

  void _onDeleteProject(DeleteProject event, Emitter<ProjectState> emit) async {
    // if (emit is NotesSuccess) {
    final project = event.projectId;

    try {
      Map<String, dynamic> result = await ProjectRepo().getDeleteProject(
        id: project.toString(),
        token: true,
      );
      if (result['data']['error'] == false) {

        emit(ProjectDeleteSuccess());
      }
      if (result['data']['error'] == true) {
        emit((ProjectDeleteError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }

    } catch (e) {
      emit(ProjectError(e.toString()));
    }
    // }
  }

  Future<void> _onCreateProject(
      ProjectCreated event, Emitter<ProjectState> emit) async {
    try {
      List<ProjectModel> project = [];

      emit(ProjectCreateLoading());
      var result = await ProjectRepo().createProject(
          title: event.title,
          statusId: event.statusId,
          priorityId: event.priorityId,
          startDate: event.startDate,
          endDate: event.endDate,
          desc: event.desc,
          note: event.note,
          userId: event.userId,
          taskAccess: event.taskAccess,
          canClientDiscuss:event.clientCanDiscuss!,
          enable:event.enable!,
          budget: event.budget,
          clientId: event.clientId,
          tagId: event.tagId,
          customFieldValues :event.customFieldValues
      );
      if (result['error'] == false) {
        emit(ProjectCreateSuccess(project));
        add(ProjectDashBoardList());
      }
      if (result['error'] == true) {
        emit(ProjectCreateError(result['message']));
        flutterToastCustom(msg: result['message']);
        add(ProjectDashBoardList());
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((ProjectError("Error: $e")));
    }
  }

  void _onSelectProject(SelectedProject event, Emitter<ProjectState> emit) {
    if (state is ProjectSuccess) {
      final currentState = state as ProjectSuccess;
      emit(ProjectSuccess(currentState.project, event.selectedIndex,
          event.selectedTitle, false));
    }
  }

  void _onUpdateProject(UpdateProject event, Emitter<ProjectState> emit) async {
    if (state is ProjectPaginated) {
      List<ProjectModel> project = [];
      final id = event.id;
      final title = event.title;
      final statusId = event.statusId;
      final priorityId = event.priorityId;
      final startDate = event.startDate;
      final endDate = event.endDate;
      final desc = event.desc;
      final note = event.note;
      final taskAccess = event.taskAccess;
      final budget = event.budget;
      final userId = event.userId;
      final clientId = event.clientId;
      final tagId = event.tagId;
      final canClientDiscuss = event.clientCanDiscuss;
      final isEnabled = event.enable;
      final customFieldValues = event.customFieldValues; // Access from the event

      // Get custom field values
      // final fieldValues = getFieldValues(); // From your submitToAPI function

      emit(ProjectEditLoading());
      try {
        Map<String, dynamic> updatedProject = await ProjectRepo().updateProject(
          id: id,
          title: title,
          statusId: statusId,
          priorityId: priorityId,
          startDate: startDate,
          endDate: endDate,
          desc: desc,
          note: note,
          userId: userId,
          taskAccess: taskAccess,
          budget: budget,
          clientId: clientId,
          canClientDiscuss: canClientDiscuss!,
          enable: isEnabled!,
          tagId: tagId,
          customFieldValues: customFieldValues, // Pass as a named parameter
        );

        if (updatedProject['error'] == false) {
          emit(ProjectEditSuccess(project));
          add(ProjectDashBoardList());
        }
        if (updatedProject['error'] == true) {
          flutterToastCustom(msg: updatedProject['message']);
          add(ProjectDashBoardList());
          emit(ProjectEditError(updatedProject['message']));
        }
      } catch (e) {
        print('Error while updating Task: $e');
      }
    }
  }


  Future<void> _onSearchProject(
      SearchProject event, Emitter<ProjectState> emit) async {
    try {
      List<ProjectModel> projects = [];
      _offset = 0;
      emit(ProjectLoading());
      var result = await ProjectRepo().getProjects(
          limit: _limit, offset: _offset, search: event.searchQuery,clientId: event.clientId);

      if (result['error'] == false) {
        projects = List<ProjectModel>.from(result['data']
            .map((projectData) => ProjectModel.fromJson(projectData)));
        bool hasReachedMax = projects.length < _limit;
        emit(ProjectPaginated(
          project: projects,
          hasReachedMax: hasReachedMax,
        ));
      } else if (result['error'] == true) {
        emit(ProjectError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(ProjectError("Error: $e"));
    }
  }

  Future<void> _onLoadMoreProject(
      ProjectLoadMore event, Emitter<ProjectState> emit) async {
    if (state is ProjectPaginated && !_hasReachedMax) {
      try {
        final currentState = state as ProjectPaginated;
        final updatedProject = List<ProjectModel>.from(currentState.project);

        // Fetch additional Projects from the repository
        Map<String, dynamic> result = await ProjectRepo().getProjects(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
          clientId: event.clientId,
          userId: event.userId
        );
        final additional = List<ProjectModel>.from(
          result['data']
              .map((projectData) => ProjectModel.fromJson(projectData)),
        );

        if (additional.isEmpty) {
          _hasReachedMax = true;
        } else {
          _offset += _limit; // Increment the offset consistently
          updatedProject.addAll(additional);
        }

        if (result['error'] == false) {
          emit(ProjectPaginated(
            project: updatedProject,
            hasReachedMax: _hasReachedMax,
          ));
        } else {
          emit(ProjectError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        emit(ProjectError("Error: $e"));
      }
    }
  }
}
