import 'package:equatable/equatable.dart';

abstract class PermissionsState extends Equatable{
  @override
  List<Object?> get props => [];
}

class PermissionsInitial extends PermissionsState {}
class PermissionsLoading extends PermissionsState {}
class PermissionsSuccess extends PermissionsState {


  PermissionsSuccess();
}


class PermissionsError extends PermissionsState {
  final String errorMessage;
  PermissionsError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}