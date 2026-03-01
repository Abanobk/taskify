
import 'package:equatable/equatable.dart';

abstract class ClientidEvent extends Equatable {
  @override
  List<Object?> get props => [];
}


class ClientIdListId extends ClientidEvent {
  final int? id;

  ClientIdListId(this.id);

  @override
  List<Object?> get props => [id];
}



