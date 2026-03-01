import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';


import '../../api_helper/api.dart';
import '../../data/model/task/task_model.dart';
import '../../data/repositories/task/task_repo.dart';

import 'taskid_event.dart';
import 'taskid_state.dart';


class TaskidBloc extends Bloc<TaskidEvent, TaskidState> {
  TaskidBloc() : super(TaskidInitial()) {
    on<TaskIdListId>(_getTaskListId);
  }
  Future<void> _getTaskListId(
      TaskIdListId event, Emitter<TaskidState> emit) async {
    try {


      List<Tasks> taskList = [];

      List<Tasks> existingTasks = [];
      emit(TaskidLoading());
      if(state is  TaskidWithId){
        var oldData = state as  TaskidWithId;
        existingTasks = oldData.task;
      }else{
        emit(TaskidLoading());
      }

      Map<String, dynamic> result = await TaskRepo().getTask(
        id: event.id, token: true,


      );
      taskList = List<Tasks>.from(result['data'].map((taskData) => Tasks.fromJson(taskData)));

      if(state is TaskidWithId){
        bool flag = false;
        for(var i = 0; i< existingTasks.length; i++){
          if(event.id == existingTasks[i].id){
            existingTasks[i] = taskList[0];
            flag = true;
          }
        }
        for(var i = 0; i< existingTasks.length; i++){
        }
        if(!flag){
          existingTasks.addAll(taskList);
        }
        emit(TaskidWithId(
          existingTasks,
        ));
        return;
      }
      emit(TaskidWithId(
        taskList,
      ));
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      // emit((TaskError("Error: $e")));
    }
  }
}
