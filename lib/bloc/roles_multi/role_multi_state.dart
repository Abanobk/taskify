import 'package:equatable/equatable.dart';

import '../../data/model/Role/role_model.dart';




abstract class RoleMultiState extends Equatable{
  @override
  List<Object?> get props => [];
}

class RoleMultiInitial extends RoleMultiState {}
class RoleMultiLoading extends RoleMultiState {}
class RoleMultiSuccess extends RoleMultiState {
  final List<RoleModel> RoleMulti;
  final List<int> selectedIndices;
  final List<String> selectedRoleMultinames;
  final bool hasReachedMax;

  RoleMultiSuccess({
    required this.RoleMulti,
    this.selectedIndices = const [],
    this.selectedRoleMultinames = const [],
    this.hasReachedMax = false,
  });
}


class RoleMultiError extends RoleMultiState {
  final String errorMessage;
  RoleMultiError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
