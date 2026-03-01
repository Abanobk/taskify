import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/status_model.dart';


abstract class StatusState extends Equatable{
  @override
  List<Object?> get props => [];
}

class StatusInitial extends StatusState {}
class StatusLoading extends StatusState {}
class StatusEditLoading extends StatusState {}
class StatusCreateLoading extends StatusState {}
class StatusCreateSuccess extends StatusState {}
class StatusDeleteSuccess extends StatusState {}
class StatusSuccess extends StatusState {
  StatusSuccess(this.status,this.selectedIndex, this.selectedTitle,this.isLoadingMore);
  final List<Statuses> status;
  final int? selectedIndex;
  final String selectedTitle;
  final bool isLoadingMore;
  @override
  List<Object> get props => [status,selectedIndex!,selectedTitle,isLoadingMore];
}
class StatusEditSuccess extends StatusState {
  final List<Statuses> editStatus;
  StatusEditSuccess(this.editStatus);
  @override
  List<Object> get props =>
      [editStatus];
}

class StatusCreateError extends StatusState {
  final String errorMessage;
  StatusCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class StatusEditError extends StatusState {
  final String errorMessage;
  StatusEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class StatusDeleteError extends StatusState {
  final String errorMessage;
  StatusDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class StatusError extends StatusState {
  final String errorMessage;
  StatusError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}