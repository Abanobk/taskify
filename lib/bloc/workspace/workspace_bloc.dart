import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:taskify/bloc/workspace/workspace_event.dart';
import 'package:taskify/bloc/workspace/workspace_state.dart';
import 'package:taskify/data/localStorage/hive.dart';
import 'package:taskify/data/model/workspace/workspace_model.dart';
import '../../data/repositories/workspace/workspace_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';

class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  int? defaultWorkspaceID;
  bool _isLoading = false;
  bool _hasReachedMax = false;
  int? workspcaId;
  String? workspcaTitle;
  bool? workspcaIsSelected;
  int? totalWorkspace;

  WorkspaceBloc() : super(WorkspaceInitial()) {
    on<WorkspaceList>(_getWorkSpaceList);
    on<WorkspaceRemove>(_getRemoveFromWorkSpace);
    on<RemoveUSerFromWorkspace>(_onRemoveUSerFromWorkspace);
    on<SelectedWokspce>(_getSelectedWorkSpace);
    on<LoadMoreWorkspace>(_onLoadMoreWorkspace);
    on<AddWorkspace>(_onAddWorkspace);
    on<UpdateWorkspace>(_onWorkspaceupdate);
    on<SearchWorkspace>(_onSearchWorkspace);
    on<CreateRemoveWorkspace>(_onSetWorkSpace);
    // on<WorkspaceList>(GetWorkSpaceList);
  }
  @override
  void onTransition(Transition<WorkspaceEvent, WorkspaceState> transition) {
    super.onTransition(transition);
    print("Transition: ${transition.event} => ${transition.nextState}");
  }
  Future<void> _onAddWorkspace(
      AddWorkspace event, Emitter<WorkspaceState> emit) async {
    if (state is WorkspacePaginated) {


      final work = event.workspace;
      final title = work.title;
      final primaryWorkspcae = work.primaryWorkspace;
      final userID = work.userIds;
      final clientID = work.clientIds;

      // final updatedMeeting = List<WorkspaceModel>.from(currentState.workspace)
      //   ..add(work);

      try {
        emit(WorkspaceCreateSuccessLoading());
        Map<String, dynamic> result = await WorkspaceRepo().createWorkspace(
          work: WorkspaceModel(
            title: title,
            primaryWorkspace: primaryWorkspcae,
            userIds: userID,
            clientIds: clientID,
          ),
        );

        if (result['error'] == false) {
          emit(WorkspaceCreateSuccess());
        }
        if (result['error'] == true) {
          emit((WorkspaceCreateError(result['message'])));
          flutterToastCustom(msg: result['message']);
        }
      } catch (e) {
        print('Error while creating Meeting: $e');
        // Optionally, handle the error state
      }
    }
  }

  Future<void> _onSearchWorkspace(
      SearchWorkspace event, Emitter<WorkspaceState> emit) async {
    try {
      _isLoading = true; // Set loading state to true

      emit(WorkspaceLoading());
      List<WorkspaceModel> workspace = [];
      Map<String, dynamic> result = await WorkspaceRepo()
          .workspaceList(limit: _limit, offset: 0, search: event.searchQuery);
      bool hasReachedMax = workspace.length < _limit;
      workspace = List<WorkspaceModel>.from(result['data']
          .map((projectData) => WorkspaceModel.fromJson(projectData)));
      if (result['error'] == false) {
        emit(WorkspacePaginated(
            workspace: workspace,
            hasReachedMax: hasReachedMax,
            isLoading: _isLoading));
      }
      if (result['error'] == true) {
        emit((WorkspaceError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      emit(WorkspaceError("Error: $e"));
    } finally {
      _isLoading = false; // Reset loading state
    }
  }

  void _onWorkspaceupdate(
      UpdateWorkspace event, Emitter<WorkspaceState> emit) async {
    if (state is WorkspacePaginated) {
      // final currentState = state as WorkspacePaginated;
      final work = event.workspace;
      final id = work.id;
      final title = work.title;
      final userId = work.userIds;
      final clientId = work.clientIds;
      final primary = work.primaryWorkspace;
      emit(WorkspaceEditSuccessLoading());
      try {
        Map<String, dynamic> result = await WorkspaceRepo().updateWorkspace(
          primaryWorkSpace: primary!,
          id: id!,
          title: title!,
          userId: userId!,
          clientId: clientId!,
        );
        if (result['error'] == false) {

          emit(WorkspaceEditSuccess());
          // add(const WorkspaceList());
        }
        if (result['error'] == true) {
          emit((WorkspaceEditError(result['message'])));
          flutterToastCustom(msg: result['message']);
        }
      } catch (e) {
        print('Error while updating Task: $e');
        // Optionally, handle the error state, e.g. emit an error state
      }
    }
  }
  Future<void> _getWorkSpaceList(
      WorkspaceList event,
      Emitter<WorkspaceState> emit
      ) async {
    // Guard against duplicate calls
    if (_isLoading) {
      return;
    }

    try {
      _isLoading = false;  // Set loading flag immediately

      // Reset initial values
      _offset = 0;
      _hasReachedMax = false;

      emit(WorkspaceLoading());


      Map<String, dynamic> result = await WorkspaceRepo().workspaceList(
          offset: _offset,
          limit: _limit
      );
print("lkgfdvj l $result");
print("lkgfdvj l $result['message");
if(result['error'] != true && result['data'] != null) {
  List<WorkspaceModel> workspace = List<WorkspaceModel>.from(
      result['data'].map((projectData) => WorkspaceModel.fromJson(projectData))
  );
  print("lkgsaed dfdvj l ");
  // Calculate if we've reached max
  _hasReachedMax = workspace.length >= result['total'];
  totalWorkspace = workspace.length;
  // Set offset to the length of data we've received
  _offset = workspace.length;
  _isLoading = workspace.length <= result['total'];


  emit(WorkspacePaginated(
    workspace: workspace,
    hasReachedMax: _hasReachedMax,
    isLoading: _isLoading, // Set to false after completion
  ));
  print("nfvcm   $state");
}
     if(result['error']==true){ emit(WorkspaceError(" ${result['message']}"));}

    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(WorkspaceError(" $e"));
    } finally {
      _isLoading = false;  // Reset loading flag in finally block
    }
  }

  Future<void> _onSetWorkSpace(
      CreateRemoveWorkspace event, Emitter<WorkspaceState> emit) async {
    try {
      int id = event.id;
      await WorkspaceRepo()
          .getWorkspacePrimary(id: id, defaultPrimary: event.defaultPrimary);
      workspcaId = event.id;
      emit(CreatePrimaryWorkspaceSuccess(id));
add(WorkspaceList());
    } on ApiException catch (e) {
      emit(WorkspaceError("Error: $e"));
    }
  }

  Future<void> _getRemoveFromWorkSpace(
      WorkspaceRemove event, Emitter<WorkspaceState> emit) async {
    final workspcaId = event.id;
    try {
      await WorkspaceRepo().workspaceRemove(
        id: workspcaId,
      );
      emit(WorkspaceDeleteSuccess());

      // add(WorkspaceList());
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> _onRemoveUSerFromWorkspace(
      RemoveUSerFromWorkspace event, Emitter<WorkspaceState> emit) async {
    final workspcaId = event.id;
    try {
      await WorkspaceRepo().workspaceRemove(
        id: workspcaId,
      );
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> _getSelectedWorkSpace(
      SelectedWokspce event, Emitter<WorkspaceState> emit) async {
    try {
      workspcaId = event.id;
      workspcaTitle = event.title;
      workspcaIsSelected = event.isSelected;
      await HiveStorage.setWorkspaceId(workspcaId!);
      await HiveStorage.setWorkspaceTitle(workspcaTitle!);

    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  bool _isFetching = false; // Add a flag to prevent concurrent executions

  Future<void> _onLoadMoreWorkspace(
      LoadMoreWorkspace event, Emitter<WorkspaceState> emit) async {
    // Prevent concurrent executions
    if (_isFetching) return;

    // Ensure this function doesn't execute multiple times
    _isFetching = true;

    if (state is WorkspacePaginated && !_hasReachedMax) {
      try {
        final currentState = state as WorkspacePaginated;
        final updatedTodos = List<WorkspaceModel>.from(currentState.workspace);


        // Fetch data from the API
        Map<String, dynamic> result = await WorkspaceRepo().workspaceList(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
        );

        // Handle API error
        if (result['error'] == true) {
          emit(WorkspaceError(result['message']));
          flutterToastCustom(msg: result['message']);
          _isFetching = false;
          return;
        }

        // Parse the response into a list of WorkspaceModel
        List<WorkspaceModel> todo = List<WorkspaceModel>.from(
            result['data'].map((todoData) => WorkspaceModel.fromJson(todoData)));

        // If no new data is returned, set `_hasReachedMax` to true
        if (todo.isEmpty) {

          _hasReachedMax = true;
          emit(WorkspacePaginated(
            workspace: [...updatedTodos],
            hasReachedMax: _hasReachedMax,
            isLoading: false,
          ));
          _isFetching = false; // Reset flag
          return;
        }

        // Update `_offset` and merge the new data
        _offset += todo.length; // This happens only once per successful fetch
        updatedTodos.addAll(todo);

        // Calculate `_hasReachedMax` based on `result['total']`
        int totalAvailable = result['total'];
        _hasReachedMax = updatedTodos.length >= totalAvailable;


        // Emit the updated state
        _isLoading = !_hasReachedMax; // Only loading if there are more items to fetch
        emit(WorkspacePaginated(
          workspace: [...updatedTodos],
          hasReachedMax: _hasReachedMax,
          isLoading: _isLoading,
        ));
      } catch (e) {
        print("Error occurred: $e");
        emit(WorkspaceError("Error: $e"));
      } finally {
        // Ensure the fetching flag is reset
        _isFetching = false;
      }
    } else {
      _isFetching = false; // Reset flag if state conditions fail
    }
  }




}
