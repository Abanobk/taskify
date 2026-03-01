import 'package:equatable/equatable.dart';
import '../../data/model/finance/unitd_model.dart';

abstract class UnitsState extends Equatable {
  const UnitsState();

  @override
  List<Object?> get props => [];
}

class UnitsInitial extends UnitsState {}

class UnitsLoading extends UnitsState {}

class UnitsSuccess extends UnitsState {
  const UnitsSuccess([this.Units=const []]);

  final List<UnitModel> Units;

  @override
  List<Object> get props => [Units];
}

class UnitsError extends UnitsState {
  final String errorMessage;
  const UnitsError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class DrawingItemUpdated extends UnitsState {
  final String drawing;
  const DrawingItemUpdated(this.drawing);

  @override
  List<Object> get props => [drawing];
}
class UnitsPaginated extends UnitsState {
  final List<UnitModel> Units;
  final bool hasReachedMax;

  const UnitsPaginated({
    required this.Units,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [Units, hasReachedMax];
}
class UnitsCreateError extends UnitsState {
  final String errorMessage;

  const UnitsCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class UnitsEditError extends UnitsState {
  final String errorMessage;

  const UnitsEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class UnitsEditSuccessLoading extends UnitsState {}
class UnitsCreateSuccessLoading extends UnitsState {}
class UnitsEditSuccess extends UnitsState {
  const UnitsEditSuccess();
  @override
  List<Object> get props => [];
}
class UnitsCreateSuccess extends UnitsState {
  const UnitsCreateSuccess();
  @override
  List<Object> get props => [];
}
class UnitsDeleteError extends UnitsState {
  final String errorMessage;

  const UnitsDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class UnitsDeleteSuccess extends UnitsState {
  const UnitsDeleteSuccess();
  @override
  List<Object> get props => [];
}