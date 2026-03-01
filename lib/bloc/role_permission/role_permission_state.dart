// role_permission_state.dart

import 'package:equatable/equatable.dart';

import '../../data/model/settings/permission_role.dart';

abstract class RolePermissionState extends Equatable {
  @override
  List<Object> get props => [];
}

class RolePermissionInitial extends RolePermissionState {}

class RoleOfPermissionSuccess extends RolePermissionState {
  final List<PermissionsInRole> role;

  RoleOfPermissionSuccess({required this.role});

  @override
  List<Object> get props => [role];
}

class RoleError extends RolePermissionState {
  final String message;

  RoleError(this.message);

  @override
  List<Object> get props => [message];
}
