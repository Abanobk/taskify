import 'package:equatable/equatable.dart';
import 'package:taskify/data/model/Role/role_model.dart';

import '../../data/model/settings/permission_role.dart';



abstract class RoleState extends Equatable{
  @override
  List<Object?> get props => [];
}

class RoleInitial extends RoleState {}
class RoleLoading extends RoleState {}
class RoleDeleteSuccess extends RoleState {}
class selectAllSuccess extends RoleState {
  final List<PermissionsAssigned> updatedPermissions;
  selectAllSuccess({this.updatedPermissions = const []});

  @override
  List<Object> get props => [updatedPermissions];
}
class RoleOfPermissionSuccess extends RoleState {
  final List<PermissionsInRole> roleList;

  RoleOfPermissionSuccess({this.roleList = const []});

  @override
  List<Object> get props => [roleList];
}
class RoleOfPermissionCreatedSuccess extends RoleState {


  RoleOfPermissionCreatedSuccess();

  @override
  List<Object> get props => [];
}
class RoleOfPermissionInitialList extends RoleState {
  final List<PermissionsInRole> roleList;

  RoleOfPermissionInitialList({this.roleList = const []});

  @override
  List<Object> get props => [roleList];
}
class UpdateRoleSuccess extends RoleState {

  UpdateRoleSuccess();
  @override
  List<Object> get props => [];

}
class PreselectedIdsSuccess extends RoleState {
  final List<int> ids;

  PreselectedIdsSuccess(this.ids);

  @override
  List<Object> get props => [ids];
}
class RoleSuccess extends RoleState {
  RoleSuccess(this.role,this.selectedIndex, this.selectedTitle,this.isLoadingMore);
  final List<RoleModel> role;
  final int? selectedIndex;
  final String selectedTitle;
  final bool isLoadingMore;
  @override
  List<Object> get props => [role,selectedIndex!,selectedTitle,isLoadingMore];
}

class RoleError extends RoleState {
  final String errorMessage;
  RoleError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class RoleDeleteError extends RoleState {
  final String errorMessage;
  RoleDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class RoleInitialState extends RoleState {
  final List<PermissionsAssigned> permissions;
  RoleInitialState(this.permissions);
}

class RoleUpdatedState extends RoleState {
  final List<PermissionsAssigned> permissions;
  final bool isSelectAll;
  RoleUpdatedState(this.permissions, this.isSelectAll);
}
class PermissionsUpdatedState extends RoleState {
  final List<int?> selectedPermissionIds;

  PermissionsUpdatedState(this.selectedPermissionIds);
}