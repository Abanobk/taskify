
import 'package:equatable/equatable.dart';

abstract class LeadidEvent extends Equatable {
  @override
  List<Object?> get props => [];
}


class LeadIdListId extends LeadidEvent {
  final int? id;

  LeadIdListId(this.id);

  @override
  List<Object?> get props => [id];
}



