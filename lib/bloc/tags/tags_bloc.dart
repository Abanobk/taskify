import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../../data/model/tags/tag_model.dart';
import '../../data/repositories/tags/tag_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';
import 'tags_event.dart';
import 'tags_state.dart';

class TagsBloc extends Bloc<TagsEvent, TagsState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 15;
  bool _isFetching = false;

  bool _hasReachedMax = false;

  TagsBloc() : super(TagsInitial()) {
    on<TagsList>(_getTagsList);
    on<SelectedTags>(_onSelectTags);
    on<TagsLoadMore>(_onLoadMoreTags);
    on<ToggleTagsSelection>(_toggleTagsSelection);
    on<CreateTag>(_onCreateTag);
    on<SearchTags>(_onSearchTags);
    on<UpdateTag>(_onUpdateTag);
    on<DeleteTag>(_onDeleteTag);
  }
  Future<void> _onSearchTags(SearchTags event, Emitter<TagsState> emit) async {
    try {
      List<TagsModel> tagList = [];
      // emit(UserLoading());
      _offset = 0;
      _hasReachedMax = false;
      Map<String, dynamic> result = await TagRepo().getTags(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
          token: true);
      tagList = List<TagsModel>.from(
          result['data'].map((projectData) => TagsModel.fromJson(projectData)));
      _offset += _limit;
      bool hasReachedMax = tagList.length >= result['total'];
      if (result['error'] == false) {
        emit(TagsSuccess(tag: tagList, isLoadingMore: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((TagsError(result['message'])));
      }
    } on ApiException catch (e) {
      emit(TagsError("Error: $e"));
    }
  }

  void _onDeleteTag(DeleteTag event, Emitter<TagsState> emit) async {
    // if (emit is NotesSuccess) {
    final Tag = event.TagId;

    try {
      Map<String, dynamic> result = await TagRepo().deleteTags(
        id: Tag,
        token: true,
      );
      if (result['data']['error'] == false) {
        emit(TagDeleteSuccess());
      }
      if (result['data']['error'] == true) {
        emit((TagDeleteError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } catch (e) {
      emit(TagsError(e.toString()));
    }
    // }
  }

  void _onUpdateTag(UpdateTag event, Emitter<TagsState> emit) async {
    if (state is TagsSuccess) {
      List<TagsModel> Tag = [];
      final id = event.id;
      final title = event.title;
      final color = event.color;

      emit(TagEditLoading());
      // Try to update the task via the repository
      try {
        Map<String, dynamic> updatedProject = await TagRepo().updateTags(
          id: id,
          title: title,
          color: color,
        );
        // project = List<ProjectModel>.from(updatedProject['data']
        //     .map((projectData) => ProjectModel.fromJson(projectData)));
        if (updatedProject['error'] == false) {
          emit(TagEditSuccess(tag: Tag));
          // add(ProjectDashBoardList());
          // add(ProjectList());
        }
        if (updatedProject['error'] == true) {
          flutterToastCustom(msg: updatedProject['message']);
          // add(ProjectDashBoardList());
          emit(TagEditError(updatedProject['message']));
        }
      } catch (e) {
        print('Error while updating Task: $e');
      }
    }
  }

  Future<void> _onCreateTag(CreateTag event, Emitter<TagsState> emit) async {
    try {
      emit(TagCreateLoading());
      var result = await TagRepo().createTags(
        title: event.title,
        color: event.color,
      );
      if (result['error'] == false) {
        emit(TagCreateSuccess());
        // add(ProjectDashBoardList());
      }
      if (result['error'] == true) {
        emit(TagCreateError(result['message']));
        flutterToastCustom(msg: result['message']);
        // add(ProjectDashBoardList());
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((TagsError("Error: $e")));
    }
  }

  Future<void> _getTagsList(TagsList event, Emitter<TagsState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;

      List<TagsModel> tags = [];
      Map<String, dynamic> result =
          await TagRepo().getTags(token: true, limit: _limit, offset: _offset);
      tags = List<TagsModel>.from(
          result['data'].map((projectData) => TagsModel.fromJson(projectData)));

      _offset += _limit;
      print("cfvgbhnj ${result['total']}");
      print("cfvgbhnj ${tags.length}");
      _hasReachedMax = tags.length >= result['total'];
      print("cfvgbhnj ${_hasReachedMax}");
      if (result['error'] == false) {
        emit(TagsSuccess(tag: tags, isLoadingMore: _hasReachedMax));
      }
      if (result['error'] == true) {
        emit((TagsError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((TagsError("Error: $e")));
    }
  }

  Future<void> _onLoadMoreTags(
      TagsLoadMore event, Emitter<TagsState> emit) async {
    if (_isFetching || _hasReachedMax)
      return; // prevent multiple simultaneous fetches

    if (state is TagsSuccess) {
      final currentState = state as TagsSuccess;
      _isFetching = true;

      try {
        List<TagsModel> moreTags = [];
        final result = await TagRepo().getTags(
          token: true,
          limit: _limit,
          offset: _offset,
        );

        if (result['error'] == false) {
          moreTags = List<TagsModel>.from(
              result['data'].map((tagData) => TagsModel.fromJson(tagData)));

          // Update offset and hasReachedMax
          _offset += _limit;
          _hasReachedMax = moreTags.length < _limit;

          emit(TagsSuccess(
            tag: [...currentState.tag, ...moreTags],
            selectedIndices: currentState.selectedIndices,
            selectedTagsnames: currentState.selectedTagsnames,
            isLoadingMore: _hasReachedMax,
          ));
        } else {
          emit(TagsError(result['message']));
          flutterToastCustom(msg: result['message']);
        }
      } catch (e) {
        emit(TagsError("Error: $e"));
      } finally {
        _isFetching = false;
      }
    }
  }

  void _onSelectTags(SelectedTags event, Emitter<TagsState> emit) {
    if (state is TagsSuccess) {
      final currentState = state as TagsSuccess;

      final selectedIndices = List<int>.from(currentState.selectedIndices);
      final selectedTagsnames =
          List<String>.from(currentState.selectedTagsnames);

      if (selectedIndices.contains(event.selectedIndex)) {
        selectedIndices.remove(event.selectedIndex);
        selectedTagsnames.remove(event.selectedTitle);
      } else {
        selectedIndices.add(event.selectedIndex);
        selectedTagsnames.add(event.selectedTitle);
      }

      emit(TagsSuccess(
        tag: currentState.tag,
        selectedIndices: selectedIndices,
        selectedTagsnames: selectedTagsnames,
        isLoadingMore: currentState.isLoadingMore,
      ));
    }
  }

  void _toggleTagsSelection(
      ToggleTagsSelection event, Emitter<TagsState> emit) {
    if (state is TagsSuccess) {
      final currentState = state as TagsSuccess;

      // Create local copies to avoid mutation issues
      final updatedSelectedTagsIds =
          List<int>.from(currentState.selectedIndices);
      final updatedSelectedTagsnames =
          List<String>.from(currentState.selectedTagsnames);

      // Check if the Tags is already selected based on TagsId
      final isSelected = updatedSelectedTagsIds.contains(event.tagsId);

      if (isSelected) {
        // Find the index of the TagsId in the selectedIndices list
        final removeIndex = updatedSelectedTagsIds.indexOf(event.tagsId);

        // Remove TagsId and corresponding Tagsname
        updatedSelectedTagsIds.removeAt(removeIndex);
        updatedSelectedTagsnames.removeAt(removeIndex);
      } else {
        // Add TagsId and corresponding Tagsname
        updatedSelectedTagsIds.add(event.tagsId);
        updatedSelectedTagsnames.add(event.tagsName);
      }

      // Emit the updated state
      emit(TagsSuccess(
        tag: currentState.tag,
        selectedIndices: updatedSelectedTagsIds,
        selectedTagsnames: updatedSelectedTagsnames,
        isLoadingMore: currentState.isLoadingMore,
      ));
    }
  }
}
