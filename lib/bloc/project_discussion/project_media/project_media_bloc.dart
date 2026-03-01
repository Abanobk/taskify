import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'package:path_provider/path_provider.dart';
import 'package:taskify/bloc/project_discussion/project_media/project_media_state.dart';
import '../../../api_helper/api.dart';
import '../../../data/model/project/media.dart';
import '../../../data/repositories/Project/project_repo.dart';
import '../../../utils/widgets/toast_widget.dart';

part 'project_media_event.dart';

class ProjectMediaBloc extends Bloc<ProjectMediaEvent, ProjectMediaState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _hasReachedMax = false;

  ProjectMediaBloc() : super(ProjectMediaInitial()) {
    on<MediaList>(_getMediaLists);
    on<SilentMediaRefresh>(_silentRefresh);
    on<StartDownload>(_onStartDownload);
    on<DeleteProjectMedia>(_onDeleteProjectMedia);
    on<SearchMedia>(_onSearchMedia);
    on<UploadMedia>(_onUploadMedia);
  }

  Future<void> _onUploadMedia(UploadMedia event, Emitter<ProjectMediaState> emit) async {
    try {
      print("fgf ${event.media}");
      Map<String, dynamic> result = await ProjectRepo().uploadProjectMedia(
        id: event.id,
        media: event.media,
      );

      if (result['data']['error'] == false) {
        emit(ProjectMediaUploadSuccess());
      }
      if (result['data']['error'] == true) {
        emit((ProjectMediaError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } catch (e) {
      emit(ProjectMediaError(e.toString()));
    }
  }

  Future<void> _onSearchMedia(SearchMedia event, Emitter<ProjectMediaState> emit) async {
    try {
      List<MediaModel> media = [];

      Map<String, dynamic> result = await ProjectRepo().getProjectMedia(
          limit: _limit, offset: 0, search: event.searchQuery, id: event.id);
      media = List<MediaModel>.from(result['data']
          .map((projectData) => MediaModel.fromJson(projectData)));

      bool hasReachedMax = media.length >= result['total'];
      if (result['error'] == false) {
        emit(ProjectMediaPaginated(
          ProjectMedia: media,
          hasReachedMax: hasReachedMax,
        ));
      }
      if (result['error'] == true) {
        emit((ProjectMediaError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      flutterToastCustom(msg: "$e");
      emit(ProjectMediaError("Error: $e"));
    }
  }

  void _onDeleteProjectMedia(DeleteProjectMedia event, Emitter<ProjectMediaState> emit) async {
    final project = event.id;

    try {
      Map<String, dynamic> result = await ProjectRepo().getDeleteProjectMedia(
        id: project.toString(),
        token: true,
      );
      if (result['data']['error'] == false) {
        emit(ProjectMediaDeleteSuccess());
      }
      if (result['data']['error'] == true) {
        emit((ProjectMediaError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } catch (e) {
      emit(ProjectMediaError(e.toString()));
    }
  }

  Future<void> _getMediaLists(MediaList event, Emitter<ProjectMediaState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;

      // Only show loading if not downloading or download completed
      if (state is! DownloadInProgress && state is! DownloadSuccess) {
        emit(ProjectMediaLoading());
      }

      List<MediaModel> media = [];
      Map<String, dynamic> result = await ProjectRepo().getProjectMedia(
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
        emit(ProjectMediaPaginated(
          ProjectMedia: media,
          hasReachedMax: _hasReachedMax,
        ));
      }
      if (result['error'] == true) {
        emit((ProjectMediaError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((ProjectMediaError("Error: $e")));
    }
  }

  // Silent refresh method to avoid showing loading state
  Future<void> _silentRefresh(SilentMediaRefresh event, Emitter<ProjectMediaState> emit) async {
    try {
      _offset = 0;
      _hasReachedMax = false;

      // Don't emit loading state - keep current state visible
      List<MediaModel> media = [];
      Map<String, dynamic> result = await ProjectRepo().getProjectMedia(
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
        emit(ProjectMediaPaginated(
          ProjectMedia: media,
          hasReachedMax: _hasReachedMax,
        ));
      }
      if (result['error'] == true) {
        emit((ProjectMediaError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((ProjectMediaError("Error: $e")));
    }
  }

  Future<void> _onStartDownload(StartDownload event, Emitter<ProjectMediaState> emit) async {
    emit(DownloadInProgress(0.0, event.fileName));

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
            emit(DownloadSuccess(filePath, event.fileName));
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

          await _downloadFile(event.fileUrl, tempFile.path, emit, event.fileName);

          // Let user choose where to save
          final result = await FilePicker.platform.saveFile(
            dialogTitle: 'Save ${event.fileName}',
            fileName: event.fileName,
            bytes: await tempFile.readAsBytes(),
          );

          if (result != null) {
            await tempFile.delete(); // Clean up temp file
            emit(DownloadSuccess(result, event.fileName));
          } else {
            await tempFile.delete(); // Clean up temp file
            emit(DownloadFailure("Save cancelled by user"));
          }
          return;
        } catch (e) {
          print("File picker failed: $e");
        }

        // Method 3: Fallback - save to app documents and provide sharing option
        final documentsDir = await getApplicationDocumentsDirectory();
        filePath = "${documentsDir.path}/${event.fileName}";

        await _downloadFile(event.fileUrl, filePath, emit, event.fileName);
        emit(DownloadSuccess(filePath, event.fileName));

      } else {
        // iOS
        final documentsDir = await getApplicationDocumentsDirectory();
        filePath = "${documentsDir.path}/${event.fileName}";

        await _downloadFile(event.fileUrl, filePath, emit, event.fileName);
        emit(DownloadSuccess(filePath, event.fileName));
      }
    } catch (e) {
      emit(DownloadFailure(e.toString()));
    }
  }

  // Helper method to download file
  Future<void> _downloadFile(String url, String filePath, Emitter<ProjectMediaState> emit, String fileName) async {
    Dio dio = Dio();
    await dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          emit(DownloadInProgress(received / total, fileName));
        }
      },
    );
  }

  // // Alternative: Use MediaStore for Android 10+ (saves to Downloads but accessible)
  // Future<void> _downloadUsingMediaStore(StartDownload event, Emitter<ProjectMediaState> emit) async {
  //   if (Platform.isAndroid) {
  //     try {
  //       emit(DownloadInProgress(0.0, event.fileName));
  //
  //       // Download to temporary location first
  //       final tempDir = await getTemporaryDirectory();
  //       final tempFile = File("${tempDir.path}/${event.fileName}");
  //
  //       await _downloadFile(event.fileUrl, tempFile.path, emit, event.fileName);
  //
  //       // Copy to MediaStore Downloads using platform channel
  //       const platform = MethodChannel('com.taskify.management/media');
  //       final result = await platform.invokeMethod('saveToDownloads', {
  //         'fileName': event.fileName,
  //         'filePath': tempFile.path,
  //         'mimeType': _getMimeType(event.fileName),
  //       });
  //
  //       await tempFile.delete(); // Clean up
  //
  //       if (result['success']) {
  //         emit(DownloadSuccess(
  //           result['uri'],
  //           event.fileName,
  //         ));
  //       } else {
  //         emit(DownloadFailure(result['error']));
  //       }
  //     } catch (e) {
  //       emit(DownloadFailure(e.toString()));
  //     }
  //   }
  // }
  //
  // // Map file extensions to MIME types
  // String _getMimeType(String fileName) {
  //   final extension = fileName.split('.').last.toLowerCase();
  //   switch (extension) {
  //     case 'pdf':
  //       return 'application/pdf';
  //     case 'jpg':
  //     case 'jpeg':
  //       return 'image/jpeg';
  //     case 'png':
  //       return 'image/png';
  //     case 'txt':
  //       return 'text/plain';
  //     case 'doc':
  //       return 'application/msword';
  //     case 'docx':
  //       return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
  //     case 'xls':
  //       return 'application/vnd.ms-excel';
  //     case 'xlsx':
  //       return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
  //     case 'zip':
  //       return 'application/zip';
  //     case 'rar':
  //       return 'application/x-rar-compressed';
  //     default:
  //       return 'application/octet-stream';
  //   }
  // }
}