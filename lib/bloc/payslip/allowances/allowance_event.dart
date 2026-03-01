import "package:equatable/equatable.dart";

import "../../../data/model/allowance.dart";

abstract class AllowancesEvent extends Equatable {
  const AllowancesEvent();

  @override
  List<Object?> get props => [];
}

class CreateAllowances extends AllowancesEvent {
  final String title;
  final String amount;

  CreateAllowances({required this.title, required this.amount});

  @override
  List<Object> get props => [
        title,
        amount,
      ];
}

class AllowancesList extends AllowancesEvent {
  const AllowancesList();

  @override
  List<Object?> get props => [];
}

class AddAllowances extends AllowancesEvent {
  final AllowanceModel Allowances;

  const AddAllowances(this.Allowances);

  @override
  List<Object?> get props => [Allowances];
}

class UpdateAllowances extends AllowancesEvent {
  final AllowanceModel Allowances;

  const UpdateAllowances(this.Allowances);

  @override
  List<Object?> get props => [Allowances];
}

class DeleteAllowances extends AllowancesEvent {
  final int Allowances;

  const DeleteAllowances(this.Allowances);

  @override
  List<Object?> get props => [Allowances];
}

class SearchAllowances extends AllowancesEvent {
  final String searchQuery;


  const SearchAllowances(this.searchQuery,);

  @override
  List<Object?> get props => [searchQuery];
}

class LoadMoreAllowances extends AllowancesEvent {
  final String searchQuery;

  const LoadMoreAllowances(this.searchQuery);

  @override
  List<Object?> get props => [];
}
