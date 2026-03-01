import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';


import '../../api_helper/api.dart';
import '../../data/model/Project/all_project.dart';
import '../../data/repositories/Project/project_repo.dart';

import 'projectid_event.dart';
import 'projectid_state.dart';


class ProjectidBloc extends Bloc<ProjectidEvent, ProjectidState> {
  ProjectidBloc() : super(ProjectidInitial()) {
    on<ProjectIdListId>(_getprojectListId);
  }
  Future<void> _getprojectListId(
      ProjectIdListId event, Emitter<ProjectidState> emit) async {
    try {



      List<ProjectModel> projects = [];

      List<ProjectModel> existingprojects = [];

      if(state is  ProjectidWithId){
        var oldData = state as  ProjectidWithId;
        emit(ProjectidLoading());
        existingprojects = oldData.project;
      }else{
        emit(ProjectidLoading());
      }

      Map<String, dynamic> result = await ProjectRepo().getProjects(
        id: event.id,


      );
      projects = List<ProjectModel>.from(result['data'].map((projectData) => ProjectModel.fromJson(projectData)));

      if(state is ProjectidWithId){
        bool flag = false;
        for(var i = 0; i< existingprojects.length; i++){
          if(event.id == existingprojects[i].id){
            existingprojects[i] = projects[0];

            flag = true;
          }
        }
        for(var i = 0; i< existingprojects.length; i++){
        }
        if(!flag){
          existingprojects.addAll(projects);
        }
        emit(ProjectidWithId(
          existingprojects,
        ));
        return;
      }
      emit(ProjectidWithId(
        projects,
      ));
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      // emit((projectError("Error: $e")));
    }
  }
}
