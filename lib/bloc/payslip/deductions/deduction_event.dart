import "package:equatable/equatable.dart";

import "../../../data/model/payslip/deduction-model.dart";

abstract class DeductionsEvent extends Equatable{
 const DeductionsEvent();

 @override
 List<Object?> get props => [];
}
 class CreateDeductions extends DeductionsEvent{
 final String title;
  final String amount;
  final String per;
  final String type;

  CreateDeductions({required this.title,required this.type,
  required this.amount,required this.per});

 @override
 List<Object> get props => [title,amount,per];
}


class DeductionsList extends DeductionsEvent {

 const DeductionsList();

 @override
 List<Object?> get props => [];
}
class AddDeductions extends DeductionsEvent {
 final DeductionModel Deductions;

 const AddDeductions(this.Deductions);

 @override
 List<Object?> get props => [Deductions];
}

class UpdateDeductions extends DeductionsEvent {
 final DeductionModel Deductions;

 const UpdateDeductions(this.Deductions);

 @override
 List<Object?> get props => [Deductions];
}

class DeleteDeductions extends DeductionsEvent {
 final int Deductions;

 const DeleteDeductions(this.Deductions );

 @override
 List<Object?> get props => [Deductions];
}
class SearchDeductions extends DeductionsEvent {
 final String searchQuery;
 final String type;

 const SearchDeductions(this.searchQuery,this.type);

 @override
 List<Object?> get props => [searchQuery];
}
class LoadMoreDeductions extends DeductionsEvent {
 final String searchQuery;

 const LoadMoreDeductions(this.searchQuery);

 @override
 List<Object?> get props => [];
}
