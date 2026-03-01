import "package:equatable/equatable.dart";
import "package:taskify/data/model/finance/tax_model.dart";

abstract class TaxesEvent extends Equatable{
 const TaxesEvent();

 @override
 List<Object?> get props => [];
}
 class CreateTaxes extends TaxesEvent{
 final String title;
  final String amount;
  final String per;
  final String type;

  CreateTaxes({required this.title,required this.type,
  required this.amount,required this.per});

 @override
 List<Object> get props => [title,amount,per];
}


class TaxesList extends TaxesEvent {

 const TaxesList();

 @override
 List<Object?> get props => [];
}
class AddTaxes extends TaxesEvent {
 final TaxModel Taxes;

 const AddTaxes(this.Taxes);

 @override
 List<Object?> get props => [Taxes];
}

class UpdateTaxes extends TaxesEvent {
 final TaxModel Taxes;

 const UpdateTaxes(this.Taxes);

 @override
 List<Object?> get props => [Taxes];
}

class DeleteTaxes extends TaxesEvent {
 final int Taxes;

 const DeleteTaxes(this.Taxes );

 @override
 List<Object?> get props => [Taxes];
}
class SearchTaxes extends TaxesEvent {
 final String searchQuery;
 final String type;

 const SearchTaxes(this.searchQuery,this.type);

 @override
 List<Object?> get props => [searchQuery];
}
class LoadMoreTaxes extends TaxesEvent {
 final String searchQuery;

 const LoadMoreTaxes(this.searchQuery);

 @override
 List<Object?> get props => [];
}
