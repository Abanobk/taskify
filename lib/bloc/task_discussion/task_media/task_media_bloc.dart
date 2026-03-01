import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taskify/bloc/task_discussion/task_media/task_media_state.dart';

import '../../../api_helper/api.dart';

import '../../../data/model/project/media.dart';
import '../../../data/repositories/Task/Task_repo.dart';
import '../../../utils/widgets/toast_widget.dart';

part 'task_media_event.dart';

class TaskMediaBloc extends Bloc<TaskMediaEvent, TaskMediaState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _hasReachedMax = false;
  TaskMediaBloc() : super(TaskMediaInitial()) {
    on<TaskMediaList>(_getMediaLists);
    on<TaskStartDownload>(_onStartDownload);
    on<TaskSilentMediaRefresh>(_silentRefresh);
    on<DeleteTaskMedia>(_deleteTaskMedia);
    on<TaskSearchMedia>(_onSearchMedia);
    on<UploadTaskMedia>(_onUploadMedia);
  }
  Future<void> _silentRefresh(TaskSilentMediaRefresh event, Emitter<TaskMediaState> emit) async {
    try {
      _offset = 0;
      _hasReachedMax = false;

      // Don't emit loading state - keep current state visible
      List<MediaModel> media = [];
      Map<String, dynamic> result = await TaskRepo().getTaskMedia(
        id: event.id,
        limit: _limit,
        offset: _offset,
        search: '',
      );

      media = List<MediaModel>.from(
          result['data'].map((projectData) => MediaModel.fromJson(projectData)));

      if (event.id != null) {
        _offset = 0;
      } else {
        _offset += _limit;
      }
      _hasReachedMax = media.length >= result['total'];

      if (result['error'] == false) {
        emit(TaskMediaPaginated(
          TaskMediaList: media,
          hasReachedMax: _hasReachedMax,
        ));
      }
      if (result['error'] == true) {
        emit((TaskMediaError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((TaskMediaError("Error: $e")));
    }
  }
  Future<void> _onUploadMedia(
      UploadTaskMedia event, Emitter<TaskMediaState> emit) async {
    try {
      print("fgf ${event.media}");
      Map<String, dynamic> result = await TaskRepo().uploadTaskMedia(
        id: event.id,
        media: event.media,
      );

      if (result['data']['error'] == false) {
        emit(TaskMediaUploadSuccess());
      }
      if (result['data']['error'] == true) {
        emit((TaskMediaError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } catch (e) {
      emit(TaskMediaError(e.toString()));
    }
  }

  Future<void> _onSearchMedia(
      TaskSearchMedia event, Emitter<TaskMediaState> emit) async {
    try {
      List<MediaModel> media = [];
      print("esklfrdf'lMDFmlDF ${event.searchQuery}");
      Map<String, dynamic> result = await TaskRepo().getTaskMedia(
          limit: _limit, offset: 0, search: event.searchQuery, id: event.id);
      media = List<MediaModel>.from(
          result['data'].map((TaskData) => MediaModel.fromJson(TaskData)));

      bool hasReachedMax = media.length >= result['total'];
      if (result['error'] == false) {
        emit(TaskMediaPaginated(
          TaskMediaList: media,
          hasReachedMax: hasReachedMax,
        ));
      }
      if (result['error'] == true) {
        emit((TaskMediaError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      flutterToastCustom(msg: "$e");

      emit(TaskMediaError("Error: $e"));
    }
  }

  void _deleteTaskMedia(
      DeleteTaskMedia event, Emitter<TaskMediaState> emit) async {
    final Task = event.id;

    try {
      Map<String, dynamic> result = await TaskRepo().getDeleteTaskMedia(
        id: Task.toString(),
        token: true,
      );
      if (result['data']['error'] == false) {
        emit(TaskMediaDeleteSuccess());
      }
      if (result['data']['error'] == true) {
        emit((TaskMediaError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } catch (e) {
      emit(TaskMediaError(e.toString()));
    }
    // }
  }

  Future<void> _getMediaLists(
      TaskMediaList event, Emitter<TaskMediaState> emit) async {
    try {
      print("Fetching task media...");
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;

      if (state is! TaskDownloadSuccess) {
        emit(TaskMediaLoading());
      }

      Map<String, dynamic> result = await TaskRepo().getTaskMedia(
        id: event.id,
        limit: _limit,
        offset: _offset,
        search: '',
      );
      print("FeSGFK ${result['data']}");

      // Check if 'data' exists and is a List
      if (result['data'] == null || result['data'] is! List) {
        emit(TaskMediaError("Invalid response: Missing 'data' field"));
        return;
      }

      List<MediaModel> media = List<MediaModel>.from(
          result['data'].map((taskData) => MediaModel.fromJson(taskData)));

      if (event.id == null) {
        _offset += _limit;
      } else {
        _offset = 0;
      }

      _hasReachedMax = media.length >= result['total'];

      if (result['error'] == false) {
        emit(TaskMediaPaginated(
          TaskMediaList: media,
          hasReachedMax: _hasReachedMax,
        ));
      } else {
        emit(TaskMediaError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print("API Exception: $e");
      }
      emit(TaskMediaError("Error: $e"));
    } catch (e) {
      if (kDebugMode) {
        print("Unexpected error: $e");
      }
      emit(TaskMediaError("Unexpected error occurred"));
    }
  }

  Future<void> _onStartDownload(
      TaskStartDownload event, Emitter<TaskMediaState> emit) async {
    emit(TaskDownloadInProgress(0.0, event.fileName));

    try {
      String? filePath;

      if (Platform.isAndroid) {
        // Method 1: Try to save directly to Downloads folder
        try {
          final downloadsDir = Directory('/storage/emulated/0/Download');
          if (await downloadsDir.exists()) {
            filePath = "${downloadsDir.path}/${event.fileName}";

            // Test if we can write to Downloads folder
            final testFile = File(filePath);
            await testFile.writeAsString('test');
            await testFile.delete();

            // If we reach here, we can write to Downloads
            await _downloadFile(event.fileUrl, filePath, emit, event.fileName);
            emit(TaskDownloadSuccess(filePath, event.fileName));
            return;
          }
        } catch (e) {
          print("Cannot write to Downloads folder: $e");
        }

        // Method 2: Use file picker to let user choose location
        try {
          // First download to temporary location
          final tempDir = await getTemporaryDirectory();
          final tempFile = File("${tempDir.path}/${event.fileName}");

          await _downloadFile(
              event.fileUrl, tempFile.path, emit, event.fileName);

          // Let user choose where to save
          final result = await FilePicker.platform.saveFile(
            dialogTitle: 'Save ${event.fileName}',
            fileName: event.fileName,
            bytes: await tempFile.readAsBytes(),
          );

          if (result != null) {
            await tempFile.delete(); // Clean up temp file
            emit(TaskDownloadSuccess(result, event.fileName));
          } else {
            await tempFile.delete(); // Clean up temp file
            emit(TaskDownloadFailure("Save cancelled by user"));
          }
          return;
        } catch (e) {
          print("File picker failed: $e");
        }

        // Method 3: Fallback - save to app documents and provide sharing option
        final documentsDir = await getApplicationDocumentsDirectory();
        filePath = "${documentsDir.path}/${event.fileName}";

        await _downloadFile(event.fileUrl, filePath, emit, event.fileName);
        emit(TaskDownloadSuccess(filePath, event.fileName));
      } else {
        // iOS
        final documentsDir = await getApplicationDocumentsDirectory();
        filePath = "${documentsDir.path}/${event.fileName}";

        await _downloadFile(event.fileUrl, filePath, emit, event.fileName);
        emit(TaskDownloadSuccess(filePath, event.fileName));
      }
    } catch (e) {
      emit(TaskDownloadFailure(e.toString()));
    }
  }

  // Helper method to download file
  Future<void> _downloadFile(String url, String filePath,
      Emitter<TaskMediaState> emit, String fileName) async {
    Dio dio = Dio();
    await dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          emit(TaskDownloadInProgress(received / total, fileName));
        }
      },
    );
  }
}
