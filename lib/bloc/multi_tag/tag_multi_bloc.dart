import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/multi_tag/tag_multi_event.dart';
import 'package:taskify/bloc/multi_tag/tag_multi_state.dart';

import '../../data/model/tags/tag_model.dart';
import '../../data/repositories/tags/tag_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';


class TagMultiBloc extends Bloc<TagMultiEvent, TagMultiState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 16;
  bool _hasReachedMax = false;
  TagMultiBloc() : super(TagMultiInitial()) {
    on<TagMultiList>(_getTagMultiList);
    on<SelectedTagMulti>(_selectTagMulti);
    on<TagMultiLoadMore>(_onLoadMore);
    on<ToggleTagMultiSelection>(_onToggleTagMultiSelection);
    on<SearchTagMultis>(_onSearchTagMulti);
  }
  Future<void> _getTagMultiList(TagMultiList event, Emitter<TagMultiState> emit) async {
    try {
      List<TagsModel> tagMultis =[];
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      // emit(TagMultiLoading());
      Map<String,dynamic> result = await TagRepo().getTags(token: true,limit: _limit, offset: _offset,);
      tagMultis = List<TagsModel>.from(result['data']
          .map((projectData) => TagsModel.fromJson(projectData)));
      _offset += _limit;
      _hasReachedMax = tagMultis.length >= result['total'];
      emit(TagMultiPaginated(tagMulti: tagMultis, hasReachedMax: _hasReachedMax));

    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((TagMultiError("Error: $e")));
    }
  }
  Future<void> _onSearchTagMulti(
      SearchTagMultis event, Emitter<TagMultiState> emit) async {
    try {
      List<TagsModel> tagMulti=[];

      Map<String,dynamic> result  = await TagRepo().getTags(limit: _limit, offset: 0, search: event.searchQuery,token: true);
      tagMulti = List<TagsModel>.from(result['data']
          .map((projectData) => TagsModel.fromJson(projectData)));

      bool hasReachedMax = tagMulti.length >= result['total'];
      if (result['error'] == false) {
        emit(TagMultiPaginated(tagMulti:tagMulti,hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((TagMultiError(result['message'])));
        flutterToastCustom(msg: result['message']);

      }
    } on ApiException catch (e) {
      flutterToastCustom(msg:"$e");

      emit(TagMultiError("Error: $e"));

    }
  }
  Future<void> _onLoadMore(
      TagMultiLoadMore event, Emitter<TagMultiState> emit) async {
    if (state is TagMultiPaginated && !_hasReachedMax) {
      try {
        final currentState = state as TagMultiPaginated;
        final updatedNotification = List<TagsModel>.from(currentState.tagMulti);

        // Fetch additional Notifications from the repository
        List<TagsModel> additionalNotes = [];
        Map<String,dynamic> result = await TagRepo().getTags(token: true,limit: _limit, offset: _offset,);
        additionalNotes = List<TagsModel>.from(result['data']
            .map((projectData) => TagsModel.fromJson(projectData)));
        // Update the offset for the next load
        _offset= updatedNotification.length;

        // Check if the D number of items has been reached
        if (currentState.tagMulti.length >= result['total']) {
          _hasReachedMax = true;
        } else {
          _hasReachedMax = false;
        }
        // Add the newly fetched Notifications to the existing list
        updatedNotification.addAll(additionalNotes);
        if (result['error'] == false) {
          emit(TagMultiPaginated(tagMulti: updatedNotification, hasReachedMax: _hasReachedMax, ));
        }
        if (result['error'] == true) {
          emit((TagMultiError(result['message'])));
          flutterToastCustom(msg: result['message']);

        }
        // Emit the new state with the updated Notification list and hasReachedMax flag

      } on ApiException catch (e) {
        // Handle any errors that occur during the API call
        emit(TagMultiError("Error: $e"));
      }
    }

  }

  void _selectTagMulti(SelectedTagMulti event, Emitter<TagMultiState> emit) {
    if (state is TagMultiSuccess) {
      final currentState = state as TagMultiSuccess;

      final selectedIndices = List<int>.from(currentState.selectedIndices);
      final selectedTagMultinames =
      List<String>.from(currentState.selectedTagMultinames);

      if (selectedIndices.contains(event.selectedIndex)) {
        selectedIndices.remove(event.selectedIndex);
        selectedTagMultinames.remove(event.selectedTitle);
      } else {
        selectedIndices.add(event.selectedIndex);
        selectedTagMultinames.add(event.selectedTitle);
      }
      emit(TagMultiSuccess(
        tagMulti: currentState.tagMulti,
        selectedIndices: selectedIndices,
        selectedTagMultinames: selectedTagMultinames,
        isLoadingMore: currentState.isLoadingMore,
      ));
    }
  }

  void _onToggleTagMultiSelection(ToggleTagMultiSelection event, Emitter<TagMultiState> emit) {
    if (state is TagMultiSuccess) {
      final currentState = state as TagMultiSuccess;

      // Create local copies to avoid mutation issues
      final updatedSelectedTagMultiIds = List<int>.from(currentState.selectedIndices);
      final updatedSelectedTagMultinames = List<String>.from(currentState.selectedTagMultinames);

      // Check if the TagMulti is already selected based on TagMultiId
      final isSelected = updatedSelectedTagMultiIds.contains(event.tagMultiId);

      if (isSelected) {
        // Find the index of the TagMultiId in the selectedIndices list
        final removeIndex = updatedSelectedTagMultiIds.indexOf(event.tagMultiId);

        // Remove TagMultiId and corresponding TagMultiname
        updatedSelectedTagMultiIds.removeAt(removeIndex);
        updatedSelectedTagMultinames.removeAt(removeIndex);
      } else {
        // Add TagMultiId and corresponding TagMultiname
        updatedSelectedTagMultiIds.add(event.tagMultiId);
        updatedSelectedTagMultinames.add(event.tagMultiName);
      }

      // Emit the updated state
      emit(TagMultiSuccess(
        tagMulti: currentState.tagMulti,
        selectedIndices: updatedSelectedTagMultiIds,
        selectedTagMultinames: updatedSelectedTagMultinames,
        isLoadingMore: currentState.isLoadingMore,
      ));
    }
  }

}
