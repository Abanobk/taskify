

import 'package:equatable/equatable.dart';

abstract class SingleAllowanceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SingleAllowanceList extends SingleAllowanceEvent {


  SingleAllowanceList();
  @override
  List<Object> get props => [];
}
class SingleAllowanceLoadMore extends SingleAllowanceEvent {}
class SelectSingleAllowance extends SingleAllowanceEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectSingleAllowance(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}

