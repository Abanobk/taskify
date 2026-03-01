
import 'package:equatable/equatable.dart';

abstract class ProjectidEvent extends Equatable {
  @override
  List<Object?> get props => [];
}


class ProjectIdListId extends ProjectidEvent {
  final int? id;

  ProjectIdListId(this.id);

  @override
  List<Object?> get props => [id];
}



