import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/roles/role_event.dart';
import 'package:taskify/bloc/roles/role_state.dart';
import '../../data/model/Role/role_model.dart';
import '../../data/model/settings/permission_role.dart';
import '../../data/repositories/Role/role_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';

class RoleBloc extends Bloc<RoleEvent, RoleState> {
  int _offset = 0; // Start offset
  final int _limit = 15; // Limit per request
  bool _hasReachedMax = false;
  int? allDataAccess;
  bool isAllDataAccess = false;
  List<int> PreSlectedIds = [];
  List<int> AfterSlectedIds = [];

  List<int>? selectallGlobal = [];
  bool _isFetching = false; // Prevent duplicate requests

  RoleBloc() : super(RoleInitial()) {
    on<RoleList>(_getRoleList);
    on<RoleLoadMore>(_onLoadMoreRoles);
    on<SelectedRole>(_onSelectRole);
    on<UpdateRole>(_onUpdateRole);
    on<SearchRole>(_onSearchRole);
    on<AllDataAccess>(_onAllDataAccess);
    on<RolePermissionList>(_getRolePermissionList);
    on<RolePermissionInitialList>(_getRolePermissionInitiallyList);
    on<UpdatePermissionsEvent>(_onUpdatePermissionsEvent);
    on<DeleteRole>(_onDeleteRole);
    on<CreateRole>(_onCreateRole);
    on<SelectAllGlobal>(_onGlobalSelectAll);
    on<SelectAllCategory>(_onCategorySelectAll);
    on<ToggleCategorySelectAll>(_onToggleCategorySelectAll);
  }

  // role_bloc.dart

  void _onAllDataAccess(AllDataAccess event, Emitter<RoleState> emit) async {
    print("zbh kjkh ${event.allAccessDataId}");
    allDataAccess = event.allAccessDataId;
    isAllDataAccess = event.isAllDataSelected;
    print("fdggd ${allDataAccess}");
    emit(RoleOfPermissionSuccess(roleList: event.roleList));
  }

  void _onToggleCategorySelectAll(
      ToggleCategorySelectAll event, Emitter<RoleState> emit) async {
    if (state is RoleOfPermissionInitialList) {
      final currentState = state as RoleOfPermissionInitialList;
      final updatedPermissions =
          List<PermissionsAssigned>.from(currentState.roleList);
      currentState.roleList.forEach((action) {
        action.permissionsAssigned!.forEach((a) {
          updatedPermissions[event.index] =
              updatedPermissions[event.index].copyWith(
            isAssigned: event.value ? 1 : 0,
          );
        });
      });
      emit(selectAllSuccess(updatedPermissions: updatedPermissions));
    }
  }

  void _onGlobalSelectAll(
      SelectAllGlobal event, Emitter<RoleState> emit) async {
    selectallGlobal = event.ids;
  }

  void _onCategorySelectAll(
      SelectAllCategory event, Emitter<RoleState> emit) async {
    selectallGlobal = event.ids;
  }

  void _onDeleteRole(DeleteRole event, Emitter<RoleState> emit) async {
    // if (emit is NotesSuccess) {
    final project = event.roleId;

    try {
      Map<String, dynamic> result = await RoleRepo().getDeleteRole(
        id: project.toString(),
        token: true,
      );
      if (result['data']['error'] == false) {
        emit(RoleDeleteSuccess());
      }
      if (result['data']['error'] == true) {
        emit((RoleDeleteError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } catch (e) {
      emit(RoleError(e.toString()));
    }
    // }
  }

  void _onCreateRole(CreateRole event, Emitter<RoleState> emit) async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      _offset = 0;
          await RoleRepo().createRole(ids: event.ids, name: event.name);

      emit(RoleOfPermissionCreatedSuccess());
      print("fHesgfn $state");
    } on ApiException catch (e) {
      if (kDebugMode) print(e);
      emit(RoleError("Error: $e"));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onUpdatePermissionsEvent(
      UpdatePermissionsEvent event, Emitter<RoleState> emit) async {
    emit(PermissionsUpdatedState(event.selectedPermissionIds));
  }

  Future<void> _onSearchRole(SearchRole event, Emitter<RoleState> emit) async {
    try {
      List<RoleModel> role = [];
      // emit(UserLoading());
      _offset = 0;
      _hasReachedMax = false;
      Map<String, dynamic> result =
          await RoleRepo().getRoles(offset: _offset, limit: _limit);
      role = List<RoleModel>.from(
          result['data'].map((Data) => RoleModel.fromJson(Data)));
      _offset += _limit;
      bool hasReachedMax = role.length >= result['total'];
      if (result['error'] == false) {
        emit(RoleSuccess(role, -1, '', hasReachedMax));
      }
      if (result['error'] == true) {
        emit(RoleError(result['message']));
      }
    } on ApiException catch (e) {
      emit(RoleError("Error: $e"));
    }
  }

  // **Initial Load**
  Future<void> _getRoleList(RoleList event, Emitter<RoleState> emit) async {
    if (_isFetching) return; // Avoid duplicate requests
    _isFetching = true;

    try {
      _offset = 0; // Reset offset when fetching the first page
      List<RoleModel> roleList = [];

      // Fetch initial roles
      Map<String, dynamic> result =
          await RoleRepo().getRoles(offset: _offset, limit: _limit);

      roleList = List<RoleModel>.from(
          result['data'].map((roleData) => RoleModel.fromJson(roleData)));

      // Check if there are more roles to load
      _hasReachedMax = roleList.length < _limit;
      emit(RoleSuccess(roleList, -1, '', _hasReachedMax));
    } on ApiException catch (e) {
      if (kDebugMode) print(e);
      emit(RoleError("Error: $e"));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _getRolePermissionList(
      RolePermissionList event, Emitter<RoleState> emit) async {
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

      print(
          "Parsed permissions count: ${roleList[1].permissionsAssigned![2].isAssigned}");

      // Check if there are more roles to load
      _hasReachedMax = roleList.length < _limit;
      print("Has more data to fetch? $_hasReachedMax");

      emit(RoleOfPermissionSuccess(roleList: roleList));
    } on ApiException catch (e) {
      if (kDebugMode) print(e);
      emit(RoleError("Error: $e"));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _getRolePermissionInitiallyList(
      RolePermissionInitialList event, Emitter<RoleState> emit) async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      _offset = 0;
      List<PermissionsInRole> roleList = [];

      // Fetch role permissions from API
      Map<String, dynamic> result =
          await RoleRepo().getAllPermissions(token: true);

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

      emit(RoleOfPermissionInitialList(roleList: roleList));
    } on ApiException catch (e) {
      if (kDebugMode) print(e);
      emit(RoleError("Error: $e"));
    } finally {
      _isFetching = false;
    }
  }

  // **Load More Roles**
  Future<void> _onLoadMoreRoles(
      RoleLoadMore event, Emitter<RoleState> emit) async {
    if (_isFetching || _hasReachedMax || state is! RoleSuccess) return;
    _isFetching = true;

    final currentState = state as RoleSuccess;
    List<RoleModel> updatedRoles = List.from(currentState.role);

    try {
      _offset += _limit; // Move offset forward

      Map<String, dynamic> result =
          await RoleRepo().getRoles(offset: _offset, limit: _limit);

      List<RoleModel> newRoles = List<RoleModel>.from(
          result['data'].map((roleData) => RoleModel.fromJson(roleData)));

      updatedRoles.addAll(newRoles);

      // If we get fewer items than the limit, we have reached the end
      _hasReachedMax = newRoles.length < _limit;
      emit(RoleSuccess(updatedRoles, currentState.selectedIndex,
          currentState.selectedTitle, _hasReachedMax));
    } on ApiException catch (e) {
      if (kDebugMode) print(e);
      emit(RoleError("Error: $e"));
    } finally {
      _isFetching = false;
    }
  }

  // **Select a Role**
  void _onSelectRole(SelectedRole event, Emitter<RoleState> emit) {
    if (state is RoleSuccess) {
      final currentState = state as RoleSuccess;
      emit(RoleSuccess(currentState.role, event.selectedIndex,
          event.selectedTitle, currentState.isLoadingMore));
    }
  }


  Future<void> _onUpdateRole(UpdateRole event, Emitter<RoleState> emit) async {
    //
    try {
      emit(RoleLoading());
      print("idfDK ${event.name}");
      print("idfDK ${event.ids}");
      print("idfDK ${event.id}");
      Map<String, dynamic> result = await RoleRepo().updateRole(
        id: event.id,
        ids: event.ids,
        name: event.name,
      );

      if (result['error'] == false) {
        emit(UpdateRoleSuccess());
        if (result['error'] == true) {
          emit((RoleError(result['message'])));

          flutterToastCustom(msg: result['message']);
        }
      }
    } catch (e) {
      print('Error while creating note: $e');
      // Optionally, handle the error state
    }
  }
}
