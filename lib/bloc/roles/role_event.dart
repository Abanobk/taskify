
import 'package:equatable/equatable.dart';

import '../../data/model/settings/permission_role.dart';

abstract class RoleEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RoleList extends RoleEvent {
  RoleList();
  @override
  List<Object> get props => [];
}
class AllDataAccess extends RoleEvent {
  // final int offset;
  final int allAccessDataId;
  final bool isAllDataSelected;
  final List<PermissionsInRole> roleList;

  // RoleList({required this.offset,required this.limit});
  AllDataAccess({required this.allAccessDataId,required this.isAllDataSelected,required this.roleList});
  @override
  // List<Object> get props => [offset,limit];
  List<Object> get props => [allAccessDataId,isAllDataSelected];
}
class RolePermissionList extends RoleEvent {
  // final int offset;
  final int roleId;
  final bool isCreate;
  // final int limit;

  // RoleList({required this.offset,required this.limit});
  RolePermissionList({required this.roleId,this.isCreate=false});
  @override
  // List<Object> get props => [offset,limit];
  List<Object> get props => [roleId,isCreate];
}
class RolePermissionInitialList extends RoleEvent {

  // RoleList({required this.offset,required this.limit});
  RolePermissionInitialList();
  @override
  // List<Object> get props => [offset,limit];
  List<Object> get props => [];
}
class RolePreIds extends RoleEvent {
  // final int offset;
  final List<int> id;
  // final int limit;

  // RoleList({required this.offset,required this.limit});
  RolePreIds({required this.id});
  @override
  // List<Object> get props => [offset,limit];
  List<Object> get props => [];
}
class RoleAfterIds extends RoleEvent {
  // final int offset;
  final List<int> id;
  // final int limit;

  // RoleList({required this.offset,required this.limit});
  RoleAfterIds({required this.id});
  @override
  // List<Object> get props => [offset,limit];
  List<Object> get props => [];
}
class RoleLoadMore extends RoleEvent {}
class SelectedRole extends RoleEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectedRole(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}
class UpdateRole extends RoleEvent {
  final int id;
  final List<int> ids;
  final String name;

  UpdateRole({required this.id, required this.ids,required this.name});
  @override
  List<Object> get props => [id,ids,name];
}
class CreateRole extends RoleEvent {

  final List<int> ids;
  final String name;

  CreateRole({ required this.ids,required this.name});
  @override
  List<Object> get props => [ids,name];
}
class ToggleCategorySelectAll extends RoleEvent {
  final int index;
  final bool value;

   ToggleCategorySelectAll({required this.index, required this.value});

  @override
  List<Object> get props => [index, value];
}

class SelectAllGlobal extends RoleEvent {

  final List<int> ids;

  SelectAllGlobal({ required this.ids});
  @override
  List<Object> get props => [ids];
}
class SelectAllCategory extends RoleEvent {

  final List<int> ids;

  SelectAllCategory({ required this.ids});
  @override
  List<Object> get props => [ids];
}
class SearchRole extends RoleEvent {
  final String searchQuery;


  SearchRole(this.searchQuery);
  @override
  List<Object> get props => [searchQuery];
}


class TogglePermissionEvent extends RoleEvent {
  final int index;
  final bool value;
  TogglePermissionEvent(this.index, this.value);
}
class UpdatePermissionsEvent extends RoleEvent {
  final List<int?> selectedPermissionIds;

  UpdatePermissionsEvent(this.selectedPermissionIds);
}
class UpdateExpandedStateEvent extends RoleEvent {
  final bool isExpanded;
  UpdateExpandedStateEvent(this.isExpanded);
}
class ToggleSelectAllEvent extends RoleEvent {
  final bool selectAll; // Whether to select or deselect all roles
  ToggleSelectAllEvent({required this.selectAll});
}
class  DeleteRole extends RoleEvent {
  final int roleId;

  DeleteRole(this.roleId );

  @override
  List<Object?> get props => [roleId];
}