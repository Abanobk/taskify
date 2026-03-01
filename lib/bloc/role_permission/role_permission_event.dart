// role_permission_event.dart

import 'package:equatable/equatable.dart';

abstract class RolePermissionEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class RolePermissionList extends RolePermissionEvent {
  final int roleId;

  RolePermissionList({required this.roleId});

  @override
  List<Object> get props => [roleId];
}
