
import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/allowance.dart';



abstract class SingleAllowanceState extends Equatable{
  @override
  List<Object?> get props => [];
}

class SingleAllowanceInitial extends SingleAllowanceState {}
class SingleAllowanceLoading extends SingleAllowanceState {}
class SingleAllowanceSuccess extends SingleAllowanceState {
  SingleAllowanceSuccess(this.Allowance,this.selectedIndex, this.selectedTitle,this.isLoadingMore);
  final List<AllowanceModel> Allowance;
   final int? selectedIndex;
  final String selectedTitle;
  final bool isLoadingMore;
  @override
  List<Object> get props => [Allowance,selectedIndex!,selectedTitle,isLoadingMore];
}

class SingleAllowanceError extends SingleAllowanceState {
  final String errorMessage;
  SingleAllowanceError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
