import 'package:equatable/equatable.dart';
import '../../data/model/task/task_model.dart';




abstract class TaskidState extends Equatable{
  @override
  List<Object?> get props => [];
}

class TaskidInitial extends TaskidState {}

class TaskidLoading extends TaskidState {}
class TaskidWithId extends TaskidState {
  final List<Tasks> task;

  TaskidWithId(
      this.task,

      );
  @override
  List<Object> get props => [task];
}
