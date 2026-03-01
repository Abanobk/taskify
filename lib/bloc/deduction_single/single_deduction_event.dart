

import 'package:equatable/equatable.dart';

abstract class SingleDeductionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SingleDeductionList extends SingleDeductionEvent {


  SingleDeductionList();
  @override
  List<Object> get props => [];
}
class SingleDeductionLoadMore extends SingleDeductionEvent {}
class SelectSingleDeduction extends SingleDeductionEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectSingleDeduction(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}

