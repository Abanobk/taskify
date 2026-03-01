
import 'package:equatable/equatable.dart';

import '../../data/model/payslip/deduction-model.dart';



abstract class SingleDeductionState extends Equatable{
  @override
  List<Object?> get props => [];
}

class SingleDeductionInitial extends SingleDeductionState {}
class SingleDeductionLoading extends SingleDeductionState {}
class SingleDeductionSuccess extends SingleDeductionState {
  SingleDeductionSuccess(this.Deduction,this.selectedIndex, this.selectedTitle,this.isLoadingMore);
  final List<DeductionModel> Deduction;
   final int? selectedIndex;
  final String selectedTitle;
  final bool isLoadingMore;
  @override
  List<Object> get props => [Deduction,selectedIndex!,selectedTitle,isLoadingMore];
}

class SingleDeductionError extends SingleDeductionState {
  final String errorMessage;
  SingleDeductionError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
