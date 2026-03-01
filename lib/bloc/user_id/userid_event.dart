

import 'package:equatable/equatable.dart';


abstract class UseridEvent extends Equatable {
  @override
  List<Object?> get props => [];
}


class UserIdListId extends UseridEvent {
  final int? id;

  UserIdListId(this.id);

  @override
  List<Object?> get props => [id];
}



