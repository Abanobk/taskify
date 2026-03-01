import 'package:equatable/equatable.dart';

import '../../data/model/finance/estimate_invoices_model.dart';

abstract class ItemsState extends Equatable {
  const ItemsState();

  @override
  List<Object?> get props => [];
}

class ItemsInitial extends ItemsState {}

class ItemsLoading extends ItemsState {}

class ItemsSuccess extends ItemsState {
  const ItemsSuccess([this.Items=const []]);

  final List<InvoicesItems> Items;

  @override
  List<Object> get props => [Items];
}

class ItemsError extends ItemsState {
  final String errorMessage;
  const ItemsError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class DrawingItemUpdated extends ItemsState {
  final String drawing;
  const DrawingItemUpdated(this.drawing);

  @override
  List<Object> get props => [drawing];
}
class ItemsPaginated extends ItemsState {
  final List<InvoicesItems> Items;
  final bool hasReachedMax;

  const ItemsPaginated({
    required this.Items,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [Items, hasReachedMax];
}
class ItemsCreateError extends ItemsState {
  final String errorMessage;

  const ItemsCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ItemsEditError extends ItemsState {
  final String errorMessage;

  const ItemsEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ItemsEditSuccessLoading extends ItemsState {}
class ItemsCreateSuccessLoading extends ItemsState {}
class ItemsEditSuccess extends ItemsState {
  const ItemsEditSuccess();
  @override
  List<Object> get props => [];
}
class ItemsCreateSuccess extends ItemsState {
  const ItemsCreateSuccess();
  @override
  List<Object> get props => [];
}
class ItemsDeleteError extends ItemsState {
  final String errorMessage;

  const ItemsDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class ItemsDeleteSuccess extends ItemsState {
  const ItemsDeleteSuccess();
  @override
  List<Object> get props => [];
}