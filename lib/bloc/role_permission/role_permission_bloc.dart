// role_permission_bloc.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api_helper/api.dart';
import '../../data/model/settings/permission_role.dart';
import '../../data/repositories/Role/Role_repo.dart';
import 'role_permission_event.dart';
import 'role_permission_state.dart';


class RolePermissionBloc extends Bloc<RolePermissionEvent, RolePermissionState> {
  bool _isFetching = false;
  int _offset = 0;
  int _limit = 10;
  bool _hasReachedMax = false;

  RolePermissionBloc() : super(RolePermissionInitial()) {
    on<RolePermissionList>(_getRolePermissionList);
  }

  Future<void> _getRolePermissionList(
      RolePermissionList event,
      Emitter<RolePermissionState> emit,
      ) async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      _offset = 0;
      List<PermissionsInRole> roleList = [];

      // Fetch role permissions from API
      Map<String, dynamic> result = await RoleRepo().getSpecificRolePermissions(
        offset: _offset,
        limit: _limit,
        roleId: event.roleId,
      );

      print("API Response: $result"); // Debugging API response

      if (result.isEmpty || result['permissions'] == null) {
        emit(RoleError("No data found"));
        return;
      }

      print("Parsing permissions...");

      // Parsing permissions list correctly
      roleList = (result['permissions'] as List)
          .map((perm) => PermissionsInRole.fromJson(perm))
          .toList();

      print("Parsed permissions count: ${roleList.length}");

      // Check if there are more roles to load
      _hasReachedMax = roleList.length < _limit;
      print("Has more data to fetch? $_hasReachedMax");

      emit(RoleOfPermissionSuccess(role: roleList));
    } on ApiException catch (e) {
      if (kDebugMode) print(e);
      emit(RoleError("Error: $e"));
    } finally {
      _isFetching = false;
    }
  }
}

