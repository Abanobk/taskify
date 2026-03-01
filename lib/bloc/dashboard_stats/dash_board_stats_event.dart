import 'package:equatable/equatable.dart';


abstract class DashBoardStatsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StatsList extends DashBoardStatsEvent {

  StatsList();

  @override
  List<Object> get props => [];
}
