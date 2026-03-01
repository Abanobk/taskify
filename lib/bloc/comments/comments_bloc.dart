import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:taskify/data/model/discussion/discussion_model.dart';
import '../../data/repositories/comments/comment_repo.dart';
import 'comments_event.dart';
import 'comments_state.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final DiscussionRepo discussionRepo;
  List<CommentModel> _currentComments = [];
  int _offset = 0;
  String parentId = "";
  String content = "";
  String parentName = "";
  bool isUpdate = false;
  int _limit = 20;
  String? _lastSearch;
  int? _currentId;
  bool _hasMore = true;
  bool _isLoading = false;
  String updateContent = "";
  bool isProject = true;
  final StreamController<void> _focusController =
      StreamController<void>.broadcast();

  CommentsBloc({required this.discussionRepo}) : super(CommentInitial()) {
    on<LoadComments>(_onLoadComments);
    on<AddComment>(_onAddComment);
    on<RefreshComments>(_onRefreshComments);
    on<DeleteComment>(_onDeleteComment);
    on<DeleteCommentAttachment>(_onDeleteCommentAttachment);
    on<UpdateComment>(_onUpdateComment);
    on<FocusCommentTextField>(_onFocusCommentTextField);
    on<EditComment>(_onEditComment);
  }
  Future<void> _onEditComment(
      EditComment event, Emitter<CommentsState> emit) async {
    isUpdate = true;
    content = event.content;
    parentName = event.parentName;

    emit(CommentEditState(
      comments: List<CommentModel>.from(_currentComments),
      content: content,
      parentName: parentName,
    ));
  }

  Future<void> _onFocusCommentTextField(
      FocusCommentTextField event, Emitter<CommentsState> emit) async {
    log("FocusCommentTextField triggered at ${DateTime.now()}");
    _focusController.add(null); // Notify FloatingActionBar to focus
    log("Focus event emitted to focusStream");
  }

  Future<void> _onUpdateComment(
      UpdateComment event, Emitter<CommentsState> emit) async {
    if (_isLoading) {
      print('Skipping UpdateComment: already loading');
      return;
    }
    _isLoading = true;

    // Keep current state visible during update
    emit(CommentLoaded(_currentComments));
    print("xdfgyhuj ${event.commentId}");
    try {
      await discussionRepo.updateDiscussion(
        DiscussionId: int.parse(event.commentId),
        content: event.content,
        isProject: event.isProject,
      );

      // Silently reload comments without changing UI
      final response = await discussionRepo.DiscussionList(
        isProject: event.isProject,
        id: _currentId ?? 1,
        limit: _limit,
        offset: 0,
        search: _lastSearch,
      );
      final commentJsonList = response['data'] as List<dynamic>?;
      if (commentJsonList == null || commentJsonList.isEmpty) {
        _currentComments = [];
        _hasMore = false;
        emit(CommentLoaded([]));
        return;
      }
      final comments = commentJsonList
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _currentComments = comments;
      _offset = comments.length;
      _hasMore = comments.length >= _limit;
      emit(CommentLoaded(_currentComments));
    } catch (e) {
      emit(CommentError('Failed to update comment: ${e.toString()}'));
    } finally {
      _isLoading = false;
    }
    _focusController.add(null);
  }

  Future<void> _onDeleteComment(
      DeleteComment event, Emitter<CommentsState> emit) async {
    if (_isLoading) {
      print('Skipping DeleteComment: already loading');
      return;
    }
    _isLoading = true;

    // Optimistically update the comments list
    List<CommentModel> updatedComments = List.from(_currentComments);
    bool isChildComment = false;
    print("$isChildComment");
    // Update the comments list by removing the comment (top-level or child)
    updatedComments = updatedComments
        .map((comment) {
          if (comment.id == event.commentId.toString()) {
            return null; // Remove top-level comment
          }
          if (comment.children != null && comment.children!.isNotEmpty) {
            // Check if the commentId matches a child comment
            final updatedChildren = comment.children!
                .where((child) => child.id != event.commentId.toString())
                .toList();
            if (updatedChildren.length < comment.children!.length) {
              isChildComment = true; // Mark as child comment deletion
              return comment.copyWith(children: updatedChildren);
            }
          }
          return comment;
        })
        .where((comment) => comment != null)
        .cast<CommentModel>()
        .toList();

    // Emit the optimistic update
    emit(CommentLoaded(updatedComments));

    try {
      final result = await discussionRepo.deleteComment(
        CommentId: event.commentId.toString(),
        token: true,
        isProject: event.isProject,
      );

      if (result['error'] == false) {
        _currentComments = updatedComments;
        _offset = _currentComments.length;
        emit(CommentDeleteSuccess());
        emit(CommentLoaded(List<CommentModel>.from(_currentComments)));

        // Optionally, fetch the latest comments from the server to ensure consistency
        final response = await discussionRepo.DiscussionList(
          id: _currentId ?? 1,
          limit: _limit,
          offset: 0,
          search: _lastSearch,
          isProject: event.isProject,
        );

        final commentJsonList = response['data'] as List<dynamic>?;
        if (commentJsonList == null || commentJsonList.isEmpty) {
          _currentComments = [];
          _hasMore = false;
          emit(CommentLoaded([]));
        } else {
          _currentComments = commentJsonList
              .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
              .toList();
          _offset = _currentComments.length;
          _hasMore = _currentComments.length >= _limit;
          emit(CommentLoaded(List<CommentModel>.from(_currentComments)));
        }
      } else {
        // Revert on failure
        emit(CommentLoaded(List<CommentModel>.from(_currentComments)));
        emit(CommentDeleteError(result['message'] as String));
      }
    } catch (e) {
      // Revert on error
      emit(CommentLoaded(List<CommentModel>.from(_currentComments)));
      emit(CommentDeleteError('Failed to delete comment: ${e.toString()}'));
    } finally {
      _isLoading = false;
    }
  }

  // Future<void> _onDeleteComment(DeleteComment event, Emitter<CommentsState> emit) async {
  //   if (_isLoading) {
  //     print('Skipping DeleteComment: already loading');
  //     return;
  //   }
  //   _isLoading = true;
  //
  //   // Optimistically remove comment from UI
  //   final updatedComments = _currentComments.where((comment) =>
  //   comment.id != event.commentId.toString()).toList();
  //   emit(CommentLoaded(updatedComments));
  //
  //   try {
  //     final result = await discussionRepo.deleteComment(
  //       CommentId: event.commentId.toString(),
  //       token: true,
  //         isProject: event.isProject
  //     );
  //     if (result['error'] == false) {
  //       _currentComments = updatedComments;
  //       _offset = updatedComments.length;
  //       emit(CommentDeleteSuccess());
  //       emit(CommentLoaded(_currentComments));
  //     } else {
  //       // Revert on failure
  //       emit(CommentLoaded(_currentComments));
  //       emit(CommentDeleteError(result['message'] as String));
  //     }
  //   } catch (e) {
  //     // Revert on error
  //     emit(CommentLoaded(_currentComments));
  //     emit(CommentDeleteError('Failed to delete comment: ${e.toString()}'));
  //   } finally {
  //     _isLoading = false;
  //   }
  // }
  Future<void> _onDeleteCommentAttachment(
      DeleteCommentAttachment event, Emitter<CommentsState> emit) async {
    if (_isLoading) {
      print('Skipping DeleteCommentAttachment: already loading');
      return;
    }
    _isLoading = true;

    // Optimistically update the comment's attachments in the UI
    final updatedComments = _currentComments.map((comment) {
      if (comment.id == event.commentId.toString()) {
        final updatedAttachments = comment.attachments
                ?.where((attachment) => attachment.id != event.commentId)
                .toList() ??
            [];
        return comment.copyWith(attachments: updatedAttachments);
      }
      return comment;
    }).toList();

    emit(CommentLoaded(updatedComments));

    try {
      final result = await discussionRepo.deleteCommentAttachment(
          id: event.commentId.toString(), // Use attachment ID
          token: true,
          isProject: event.isProject);

      if (result['error'] == false) {
        // Fetch the updated comment list from the server
        final response = await discussionRepo.DiscussionList(
            id: _currentId ?? 1,
            limit: _limit,
            offset: 0,
            search: _lastSearch,
            isProject: event.isProject);

        final commentJsonList = response['data'] as List<dynamic>?;
        if (commentJsonList == null || commentJsonList.isEmpty) {
          _currentComments = [];
          _hasMore = false;
          emit(CommentLoaded([]));
          emit(CommentDeleteSuccess());
          return;
        }

        // Update _currentComments with the fresh list
        _currentComments = commentJsonList
            .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _offset = _currentComments.length;
        _hasMore = _currentComments.length >= _limit;

        emit(CommentDeleteSuccess());
        emit(CommentLoaded(List<CommentModel>.from(_currentComments)));
      } else {
        // Revert on failure
        emit(CommentLoaded(_currentComments));
        emit(CommentDeleteError(result['message'] as String));
      }
    } catch (e) {
      // Revert on error
      emit(CommentLoaded(_currentComments));
      emit(CommentDeleteError('Failed to delete attachment: ${e.toString()}'));
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _onLoadComments(
    LoadComments event,
    Emitter<CommentsState> emit,
  ) async {
    print("ISPROJECT ${event.isProject}");
    if (_isLoading) {
      print('Skipping LoadComments: already loading');
      return;
    }

    // Reset if ID/search changes or refresh (offset = 0)
    if (event.id != _currentId ||
        event.search != _lastSearch ||
        event.offset == 0) {
      print('Refreshing comments...');
      _currentId = event.id;
      _lastSearch = event.search;
      _offset = 0;
      _hasMore = true;
      _currentComments.clear();
    }

    if (!_hasMore) {
      print('No more comments to load');
      return;
    }

    _isLoading = true;

    // ✅ Emit only if we already have some comments (pagination case)
    if (_currentComments.isNotEmpty) {
      emit(CommentLoaded(List<CommentModel>.from(_currentComments)));
    }

    try {
      final response = await discussionRepo.DiscussionList(
          id: event.id,
          limit: event.limit,
          offset: _offset,
          search: event.search,
          isProject: event.isProject);

      final commentJsonList = response['data'] as List<dynamic>?;

      if (commentJsonList == null || commentJsonList.isEmpty) {
        _hasMore = false;
        emit(CommentLoaded(List<CommentModel>.from(_currentComments)));
        return;
      }

      final newComments = commentJsonList
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList();

      print('Fetched ${newComments.length} comments');

      _currentComments.addAll(newComments);
      _offset = _currentComments.length;
      _hasMore = newComments.length >= event.limit;

      emit(CommentLoaded(List<CommentModel>.from(_currentComments)));
    } catch (e) {
      print('Error: $e');
      emit(CommentError('Failed to load comments: $e'));
    } finally {
      _isLoading = false;
    }
  }

  // Future<void> _onLoadComments(LoadComments event, Emitter<CommentsState> emit,) async {
  //   if (_isLoading) {
  //     print('Skipping LoadComments: already loading');
  //     return;
  //   }
  //
  //   // Reset if ID/search changes or refresh (offset = 0)
  //   if (event.id != _currentId || event.search != _lastSearch || event.offset == 0) {
  //     print('Refreshing comments...');
  //     _currentId = event.id;
  //     _lastSearch = event.search;
  //     _offset = 0;
  //     _hasMore = true;
  //     _currentComments.clear();
  //   }
  //
  //   if (!_hasMore) {
  //     print('No more comments to load');
  //     return;
  //   }
  //
  //   _isLoading = true;
  //
  //   // Emit current list without shimmer (always show existing comments)
  //   emit(CommentLoaded(List<CommentModel>.from(_currentComments)));
  //
  //   try {
  //     final response = await discussionRepo.DiscussionList(
  //       id: event.id,
  //       limit: event.limit,
  //       offset: _offset,
  //       search: event.search,
  //     );
  //
  //     final commentJsonList = response['data'] as List<dynamic>?;
  //
  //     if (commentJsonList == null || commentJsonList.isEmpty) {
  //       _hasMore = false;
  //       emit(CommentLoaded(List<CommentModel>.from(_currentComments)));
  //       return;
  //     }
  //
  //     final newComments = commentJsonList
  //         .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
  //         .toList();
  //
  //     print('Fetched ${newComments.length} comments');
  //
  //     _currentComments.addAll(newComments);
  //     _offset = _currentComments.length;
  //     _hasMore = newComments.length >= event.limit;
  //
  //     emit(CommentLoaded(List<CommentModel>.from(_currentComments)));
  //   } catch (e) {
  //     print('Error: $e');
  //     emit(CommentError('Failed to load comments: $e'));
  //   } finally {
  //     _isLoading = false;
  //   }
  // }

  // Future<void> _onLoadComments(LoadComments event, Emitter<CommentsState> emit) async {
  //   if (_isLoading) {
  //     print('Skipping LoadComments: already loading');
  //     return;
  //   }
  //
  //   // Reset state for new ID, search, or when explicitly requesting offset 0
  //   if (event.id != _currentId || event.search != _lastSearch || event.offset == 0) {
  //     if (event.id != _currentId || event.search != _lastSearch) {
  //       _currentComments.clear();
  //     }
  //     _offset = 0;
  //     _hasMore = true;
  //     _currentId = event.id;
  //     _lastSearch = event.search;
  //   }
  //
  //   if (!_hasMore) {
  //     print('No more comments to load');
  //     return;
  //   }
  //
  //   _isLoading = true;
  //   if (_offset == 0 && _currentComments.isEmpty) {
  //     print('Emitting CommentLoading for initial load');
  //     emit(CommentLoading(currentComments: []));
  //   } else if (_offset > 0) {
  //     print('Emitting CommentLoadMoreLoading with ${_currentComments.length} comments');
  //     emit(CommentLoadMoreLoading(_currentComments));
  //   }
  //   // If _currentComments is not empty and offset is 0, don't emit loading state
  //
  //   try {
  //     print('Calling DiscussionList with id: ${event.id}, offset: $_offset, limit: ${event.limit}');
  //     final response = await discussionRepo.DiscussionList(
  //       id: event.id,
  //       limit: event.limit,
  //       offset: _offset,
  //       search: event.search,
  //     );
  //
  //     final commentJsonList = response['data'] as List<dynamic>?;
  //     if (commentJsonList == null || commentJsonList.isEmpty) {
  //       print('No comments found');
  //       if (_offset == 0) {
  //         _currentComments = [];
  //       }
  //       _hasMore = false;
  //       emit(CommentLoaded(_currentComments));
  //       return;
  //     }
  //
  //     final newComments = commentJsonList
  //         .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
  //         .toList();
  //
  //     print('Parsed ${newComments.length} new comments:');
  //     for (var comment in newComments) {
  //       print('ID: ${comment.id}, Content: ${comment.content}, By: ${comment.commenter?.firstName}');
  //     }
  //
  //     if (_offset == 0) {
  //       _currentComments = newComments;
  //     } else {
  //       _currentComments.addAll(newComments);
  //     }
  //     _offset += newComments.length;
  //     _hasMore = newComments.length >= event.limit;
  //     print('Updated _currentComments: ${_currentComments.length} comments');
  //     emit(CommentLoaded(_currentComments));
  //   } catch (e) {
  //     print('Error loading comments: ${e.toString()}');
  //     emit(CommentError('Failed to load comments: ${e.toString()}'));
  //   } finally {
  //     _isLoading = false;
  //   }
  // }

  Future<void> _onAddComment(
      AddComment event, Emitter<CommentsState> emit) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      log("Starting createDiscussion call at ${DateTime.now()}");
      final response = await discussionRepo.createDiscussion(
          modelType: event.modelType,
          modelId: event.modelId,
          content: event.content,
          parentId: event.parentId,
          media: event.media,
          isProject: event.isProject);
      log("createDiscussion Response at ${response['success']}: $response");
      // await Future.delayed(Duration(milliseconds: 200));
      // emit(CommentInitial());

      if (response['success'] == true) {
        // Retry logic to handle API delay
        int retryCount = 0;
        const maxRetries = 5; // Maximum 5 retries
        const retryDelay =
            Duration(seconds: 2); // Wait 2 seconds between retries
        bool latestCommentFound = false;

        while (retryCount < maxRetries && !latestCommentFound) {
          print(
              "Starting DiscussionList call (Attempt $retryCount) at ${DateTime.now()}");
          final freshResponse = await discussionRepo.DiscussionList(
              id: event.modelId,
              limit: _limit,
              offset: 0,
              search: _lastSearch,
              isProject: event.isProject);
          print(
              "DiscussionList Response (Attempt $retryCount) at ${DateTime.now()}: $freshResponse");

          final commentJsonList = freshResponse['data'] as List<dynamic>?;
          if (commentJsonList == null) {
            print("Warning: commentJsonList is null at ${DateTime.now()}");
            break;
          }

          _currentComments = commentJsonList
              .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
              .toList();
          print(
              "Mapped _currentComments - IDs at ${DateTime.now()}: ${_currentComments.map((comment) => comment.id).join(', ')}");

          // Check if the latest comment (based on content or newest ID) is present
          final latestCommentId = _currentComments.isNotEmpty
              ? _currentComments
                  .map((c) => int.tryParse(c.id!) ?? 0)
                  .reduce((a, b) => a > b ? a : b)
                  .toString()
              : null;
          if (latestCommentId != null &&
              _currentComments.any((c) => c.id == latestCommentId)) {
            latestCommentFound = true;
          }

          if (!latestCommentFound) {
            retryCount++;
            if (retryCount < maxRetries) {
              await Future.delayed(retryDelay);
            }
          }
        }

        _offset = _currentComments.length;
        _hasMore = _currentComments.length >= _limit;

        log('Latest Comment ${_currentComments.last}');

        // Emit new state with fresh list and log IDs
        emit(CommentLoaded(List<CommentModel>.from(_currentComments)));

        print(
            "Emitted Final CommentLoaded - IDs at ${DateTime.now()}: ${_currentComments.map((comment) => comment.id).join(', ')}");
      }
      // else {
      //   // Remove optimistic comment on failure
      //   _currentComments.removeWhere((comment) => comment.isTemporary);
      //   emit(CommentLoaded(List<CommentModel>.from(_currentComments)));
      //   emit(CommentError('Failed to add comment: ${response['message']}'));
      //   print("Emitted CommentError at ${DateTime.now()} - Remaining IDs: ${_currentComments.map((comment) => comment.id).join(', ')}");
      // }
    } catch (e) {
      // Remove optimistic comment on error
      _currentComments.removeWhere((comment) => comment.isTemporary);
      emit(CommentLoaded(List<CommentModel>.from(_currentComments)));
      emit(CommentError('Failed to add comment: ${e.toString()}'));
      print(
          "Emitted CommentError at ${DateTime.now()} - Exception: $e, Remaining IDs: ${_currentComments.map((comment) => comment.id).join(', ')}");
    } finally {
      _isLoading = false;
      print("Finished _onAddComment at ${DateTime.now()}");
    }
  }

  Future<void> _onRefreshComments(
      RefreshComments event, Emitter<CommentsState> emit) async {
    if (_isLoading) {
      print('Skipping RefreshComments: already loading');
      return;
    }
    print('Refreshing comments for id: ${event.id}, search: ${event.search}');

    emit(CommentLoading(currentComments: _currentComments));
    _offset = 0;
    _hasMore = true;
    _currentId = event.id;
    _lastSearch = event.search;

    add(LoadComments(
        id: event.id, limit: _limit, offset: 0, isProject: event.isProject));
  }
  // Future<void> _onRefreshComments(RefreshComments event, Emitter<CommentsState> emit) async {
  //   if (_isLoading) {
  //     print('Skipping RefreshComments: already loading');
  //     return;
  //   }
  //   print('Refreshing comments for id: ${event.id}');
  //
  //   // Keep current state visible during refresh
  //   emit(CommentLoaded(_currentComments));
  //
  //   _offset = 0;
  //   _hasMore = true;
  //   _currentId = event.id;
  //   _lastSearch = event.search;
  //
  //   add(LoadComments(id: event.id, limit: _limit, offset: 0, isProject: event.isProject));
  // }

  void loadMoreComments(isProject) {
    if (_currentId != null && !_isLoading && _hasMore) {
      print('Loading more comments at offset: $_offset');
      add(LoadComments(
          id: _currentId!,
          limit: _limit,
          offset: _offset,
          isProject: isProject));
    }
  }

  @override
  Future<void> close() {
    _focusController.close();
    return super.close();
  }
}
