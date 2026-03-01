
import 'package:equatable/equatable.dart';

abstract class TaskidEvent extends Equatable {
  @override
  List<Object?> get props => [];
}


class TaskIdListId extends TaskidEvent {
  final int? id;

  TaskIdListId(this.id);

  @override
  List<Object?> get props => [id];
}



