import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/roles_multi/role_multi_event.dart';
import 'package:taskify/bloc/roles_multi/role_multi_state.dart';

import '../../api_helper/api.dart';
import '../../data/model/Role/role_model.dart';
import '../../data/repositories/Role/Role_repo.dart';
import '../../utils/widgets/toast_widget.dart';


class RoleMultiBloc extends Bloc<RoleMultiEvent, RoleMultiState> {

  int _offset = 0; // Start with the initial offset
  final int _limit = 15;
  bool _isLoading = false;
  bool _hasReachedMax = false;
  RoleMultiBloc() : super(RoleMultiInitial()) {
    on<RoleMultiList>(_getRoleList);
    on<SelectedRoleMulti>(_onSelectRole);
    on<RoleMultiLoadMore>(_onLoadMoreRole);
    on<ToggleRoleMultiSelection>(_onToggleRoleSelection);
    on<SearchRoleMulti>(_onSearchStatus);

    // on<RoleMultiLoadMore>(_onSearchStatus);


  }

  Future<void> _onSearchStatus(
      SearchRoleMulti event, Emitter<RoleMultiState> emit) async {
    try {
      List<RoleModel> role = [];
      // emit(UserLoading());
      _offset = 0;
      _hasReachedMax = false;
      Map<String, dynamic> result = await RoleRepo().getRoles(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
          );
      role = List<RoleModel>.from(
          result['data'].map((projectData) => RoleModel.fromJson(projectData)));
      _offset += _limit;
      bool hasReachedMax =role.length >= result['total'];
      if (result['error'] == false) {
        emit(RoleMultiSuccess(RoleMulti: role, hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((RoleMultiError(result['message'])));
      }
    } on ApiException catch (e) {
      emit(RoleMultiError("Error: $e"));
    }
  }
  Future<void> _getRoleList(RoleMultiList event, Emitter<RoleMultiState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      List<RoleModel> Role =[];
      Map<String,dynamic> result = await RoleRepo().getRoles(limit: _limit, offset: _offset);
      Role = List<RoleModel>.from(result['data']
          .map((projectData) => RoleModel.fromJson(projectData)));
      _offset += _limit;
      _hasReachedMax = Role.length >= result['total'];
      if (result['error'] == false) {
        emit(RoleMultiSuccess(RoleMulti: Role,hasReachedMax: _hasReachedMax));
      }
      if (result['error'] == true) {
        emit((RoleMultiError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }

    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((RoleMultiError("Error: $e")));
    }
  }
  Future<void> _onLoadMoreRole(
      RoleMultiLoadMore event, Emitter<RoleMultiState> emit) async {
    if (state is RoleMultiSuccess && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Prevent concurrent API calls
      try {
        final currentState = state as RoleMultiSuccess;
        final updatedRole = List<RoleModel>.from(currentState.RoleMulti);

        // Fetch additional meetings
        Map<String, dynamic> result = await RoleRepo().getRoles(
          limit: _limit,
          offset: _offset,
          search: event.search,
        );

        final additionalRole = List<RoleModel>.from(result['data']
            .map((projectData) => RoleModel.fromJson(projectData)));

        if (additionalRole.isEmpty) {
          _hasReachedMax = true;
        } else {
          _offset += _limit; // Increment the offset consistently
          updatedRole.addAll(additionalRole);
        }

        // Determine if all data is loaded
        // _hasReachedMax = updatedMeeting.length + additionalMeeting.length >= result['total'];

        // Add the new data to the existing list
        // updatedMeeting.addAll(additionalMeeting);

        if (result['error'] == false) {
          emit(RoleMultiSuccess(
            RoleMulti: updatedRole,
            hasReachedMax: _hasReachedMax,
          ));
        } else {
          emit(RoleMultiError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } on ApiException catch (e) {
        emit(RoleMultiError("Error: $e"));
      } finally {
        _isLoading = false; // Reset the loading flag
      }
    }
  }


  void _onSelectRole(SelectedRoleMulti event, Emitter<RoleMultiState> emit) {
    if (state is RoleMultiSuccess) {
      final currentState = state as RoleMultiSuccess;

      final selectedIndices = List<int>.from(currentState.selectedIndices);
      final selectedRolenames =
      List<String>.from(currentState.selectedRoleMultinames);

      if (selectedIndices.contains(event.selectedIndex)) {
        selectedIndices.remove(event.selectedIndex);
        selectedRolenames.remove(event.selectedTitle);
      } else {
        selectedIndices.add(event.selectedIndex);
        selectedRolenames.add(event.selectedTitle);
      }
      print("Updated selectedRolenames: $selectedRolenames");
      emit(RoleMultiSuccess(
        RoleMulti: currentState.RoleMulti,
        selectedIndices: selectedIndices,
        selectedRoleMultinames: selectedRolenames,
        hasReachedMax: currentState.hasReachedMax,
      ));
    }
  }

  void _onToggleRoleSelection(ToggleRoleMultiSelection event, Emitter<RoleMultiState> emit) {
    if (state is RoleMultiSuccess) {
      final currentState = state as RoleMultiSuccess;

      // Create local copies to avoid mutation issues
      final updatedSelectedRoleIds = List<int>.from(currentState.selectedIndices);
      final updatedSelectedRolenames = List<String>.from(currentState.selectedRoleMultinames);

      // Check if the Role is already selected based on RoleId
      final isSelected = updatedSelectedRoleIds.contains(event.RoleMultiId);

      if (isSelected) {
        // Find the index of the RoleId in the selectedIndices list
        final removeIndex = updatedSelectedRoleIds.indexOf(event.RoleMultiId);

        // Remove RoleId and corresponding Rolename
        updatedSelectedRoleIds.removeAt(removeIndex);
        updatedSelectedRolenames.removeAt(removeIndex);
      } else {
        // Add RoleId and corresponding Rolename
        updatedSelectedRoleIds.add(event.RoleMultiId);
        updatedSelectedRolenames.add(event.RoleMultiName);
      }
      print("Before emitting state - selectedRolenames: $updatedSelectedRolenames");
      print("Before emitting state - isEmpty: ${updatedSelectedRolenames.isEmpty}");
      // Emit the updated state
      emit(RoleMultiSuccess(
        RoleMulti: currentState.RoleMulti,
        selectedIndices: List.from(updatedSelectedRoleIds),  // Ensuring a new instance
        selectedRoleMultinames: List.from(updatedSelectedRolenames),
        hasReachedMax: currentState.hasReachedMax,
      ));
      print("Bloc emitted new state: ${updatedSelectedRolenames}");

    }
  }

}
