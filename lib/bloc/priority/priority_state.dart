import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/priority_model.dart';


abstract class PriorityState extends Equatable{
  @override
  List<Object?> get props => [];
}

class PriorityInitial extends PriorityState {}
class  PriorityEditSuccessLoading extends  PriorityState {}
class  PriorityCreateSuccessLoading extends  PriorityState {}
class PriorityLoading extends PriorityState {}
class PrioritySuccess extends PriorityState {
  PrioritySuccess(this.priority,this.selectedIndex, this.selectedTitle,this.isLoadingMore);
  final List<Priorities> priority;
  final int? selectedIndex;
  final String selectedTitle;
  final bool isLoadingMore;
  @override
  List<Object> get props => [priority,selectedIndex!,selectedTitle,isLoadingMore];
}

class PriorityError extends PriorityState {
  final String errorMessage;
  PriorityError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class PriorityEditLoading extends PriorityState {}
class PriorityCreateLoading extends PriorityState {}
class PriorityCreateSuccess extends PriorityState {}
class PriorityDeleteSuccess extends PriorityState {}

class PriorityEditSuccess extends PriorityState {

  PriorityEditSuccess();
  @override
  List<Object> get props =>
      [];
}

class PriorityCreateError extends PriorityState {
  final String errorMessage;
  PriorityCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class PriorityEditError extends PriorityState {
  final String errorMessage;
  PriorityEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class PriorityDeleteError extends PriorityState {
  final String errorMessage;
  PriorityDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
