import 'dart:io';
import 'package:dio/dio.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:taskify/data/repositories/candidate/candidate_repo.dart';
import '../../../api_helper/api.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../data/model/candidate/attachment_candidate.dart';
import 'candidate_attachment_state.dart';

part 'candidate_attachment_event.dart';



class CandidateAttachmentBloc
    extends Bloc<CandidateAttachmentEvent, CandidateAttachmentState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _hasReachedMax = false;

  CandidateAttachmentBloc() : super(CandidateAttachmentInitial()) {
    on<AttachmentList>(_getAttachmentLists);
    on<SilentAttachmentRefresh>(_silentRefresh);
    on<StartDownloadAttachment>(_onStartDownloadAttachment);
    on<DeleteCandidateAttachment>(_onDeleteCandidateAttachment);
    on<UploadAttachment>(_onUploadAttachment);
    on<AttachmentLoadMore>(_onLoadMoreAttachment);
  }

  // Upload attachments with extension validation
  Future<void> _onUploadAttachment(
      UploadAttachment event, Emitter<CandidateAttachmentState> emit) async {
    try {
      final allowedExtensions = ['pdf', 'doc', 'png', 'jpg', 'jpeg'];
      for (final file in event.media) {
        final extension = file.path.split('.').last.toLowerCase();
        if (!allowedExtensions.contains(extension)) {
          emit(CandidateAttachmentError('Unsupported file type: $extension'));
          flutterToastCustom(msg: 'Unsupported file type: $extension');
          return;
        }
      }

      Map<String, dynamic> result =
      await CandidatesRepo().CandidateAttachmentUpload(
        id: event.id,
        media: event.media,
      );

      if (result['error'] == false) {
        emit(CandidateAttachmentUploadSuccess());
        flutterToastCustom(msg: 'All files uploaded successfully');
        add(AttachmentList(id: event.id)); // Refresh list after upload
      } else {
        emit(CandidateAttachmentError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } catch (e) {
      emit(CandidateAttachmentError(e.toString()));
      flutterToastCustom(msg: 'Upload failed: $e');
    }
  }

  // Fetch attachment list
  Future<void> _getAttachmentLists(
      AttachmentList event, Emitter<CandidateAttachmentState> emit) async {
    try {
      _offset = 0; // Reset offset for initial load
      _hasReachedMax = false;

      // Only show loading if not downloading or download completed
      if (state is! DownloadInProgressCandidate && state is! DownloadSuccessCandidate) {
        emit(CandidateAttachmentLoading());
      }

      final result = await CandidatesRepo().CandidateAttachmentList(
        id: event.id,
        limit: _limit,
        offset: _offset,
        search: '',
      );

      final media = List<CandidateAttachment>.from(
        result['data'].map((data) => CandidateAttachment.fromJson(data)),
      );

      _offset += _limit;
      _hasReachedMax = media.length >= result['total'];

      if (result['error'] == false) {
        emit(CandidateAttachmentPaginated(
          CandidateAttachments: media,
          hasReachedMax: _hasReachedMax,
          downloadProgress: {},
        ));
      } else {
        emit(CandidateAttachmentError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(CandidateAttachmentError("Error: $e"));
      flutterToastCustom(msg: "Error: $e");
    }
  }

  // Silent refresh method
  Future<void> _silentRefresh(
      SilentAttachmentRefresh event, Emitter<CandidateAttachmentState> emit) async {
    try {
      _offset = 0;
      _hasReachedMax = false;

      final result = await CandidatesRepo().CandidateAttachmentList(
        id: event.id,
        limit: _limit,
        offset: _offset,
        search: '',
      );

      final media = List<CandidateAttachment>.from(
        result['data'].map((data) => CandidateAttachment.fromJson(data)),
      );

      _offset += _limit;
      _hasReachedMax = media.length >= result['total'];

      if (result['error'] == false) {
        emit(CandidateAttachmentPaginated(
          CandidateAttachments: media,
          hasReachedMax: _hasReachedMax,
          downloadProgress: {},
        ));
      } else {
        emit(CandidateAttachmentError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(CandidateAttachmentError("Error: $e"));
      flutterToastCustom(msg: "Error: $e");
    }
  }

  // Load more attachments
  Future<void> _onLoadMoreAttachment(
      AttachmentLoadMore event, Emitter<CandidateAttachmentState> emit) async {
    if (state is! CandidateAttachmentPaginated || _hasReachedMax) {
      return;
    }

    try {
      final currentState = state as CandidateAttachmentPaginated;
      final updatedAttachments =
      List<CandidateAttachment>.from(currentState.CandidateAttachments);
      final currentProgress = Map<String, double>.from(currentState.downloadProgress);

      final result = await CandidatesRepo().CandidateAttachmentList(
        id: event.id,
        limit: _limit,
        offset: _offset,
        search: event.searchQuery ?? '',
      );

      final additional = List<CandidateAttachment>.from(
        result['data'].map((data) => CandidateAttachment.fromJson(data)),
      );

      if (additional.isEmpty) {
        _hasReachedMax = true;
      } else {
        _offset += _limit;
        updatedAttachments.addAll(additional);
        _hasReachedMax = updatedAttachments.length >= result['total'];
      }

      if (result['error'] == false) {
        emit(CandidateAttachmentPaginated(
          CandidateAttachments: updatedAttachments,
          hasReachedMax: _hasReachedMax,
          downloadProgress: currentProgress,
        ));
      } else {
        emit(CandidateAttachmentError(result['message']));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(CandidateAttachmentError("Error: $e"));
      flutterToastCustom(msg: "Error: $e");
    }
  }

  // Delete attachment
  Future<void> _onDeleteCandidateAttachment(
      DeleteCandidateAttachment event, Emitter<CandidateAttachmentState> emit) async {
    try {
      final result = await CandidatesRepo().deleteCandidateAttachment(
        id: event.id!,
        token: true,
      );

      if (result['error'] == false) {
        emit(CandidateAttachmentDeleteSuccess());
        add(AttachmentList(id: event.id!)); // Refresh list after deletion
      } else {
        emit(CandidateAttachmentError(result['message ']));

        }
        } catch (e) {
          emit(CandidateAttachmentError(e.toString()));
        }
      }
  Future<void> _onStartDownloadAttachment(
      StartDownloadAttachment event, Emitter<CandidateAttachmentState> emit) async {
    // Initialize defaults for attachments, hasReachedMax, and progress
    List<CandidateAttachment> currentAttachments = event.media;
    bool hasReachedMax = false;
    Map<String, double> currentProgress = {};

    // Get current state to preserve attachments and hasReachedMax if available
    if (state is CandidateAttachmentPaginated) {
      final currentState = state as CandidateAttachmentPaginated;
      currentAttachments = currentState.CandidateAttachments;
      hasReachedMax = currentState.hasReachedMax;
      currentProgress = Map<String, double>.from(currentState.downloadProgress);
    } else if (state is DownloadInProgressCandidate) {
      final currentState = state as DownloadInProgressCandidate;
      currentAttachments = currentState.CandidateAttachments;
      hasReachedMax = currentState.hasReachedMax;
      currentProgress = Map<String, double>.from(currentState.downloadProgress);
    } else if (state is DownloadSuccessCandidate) {
      final currentState = state as DownloadSuccessCandidate;
      currentAttachments = currentState.CandidateAttachments;
      hasReachedMax = currentState.hasReachedMax;
    } else if (state is DownloadFailureCandidate) {
      final currentState = state as DownloadFailureCandidate;
      currentAttachments = currentState.CandidateAttachments;
      hasReachedMax = currentState.hasReachedMax;
    }

    // Validate file extension
    final allowedExtensions = ['pdf', 'doc', 'png', 'jpg', 'jpeg'];
    final extension = event.fileUrl.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      emit(DownloadFailureCandidate(
        'Unsupported file type: $extension',
        currentAttachments,
        hasReachedMax: hasReachedMax,
      ));
      flutterToastCustom(msg: 'Unsupported file type: $extension');
      return;
    }

    // Update progress map and emit initial progress state
    currentProgress[event.fileName] = 0.0;
    emit(DownloadInProgressCandidate(
      0.0,
      event.fileName,
      CandidateAttachments: currentAttachments,
      hasReachedMax: hasReachedMax,
      downloadProgress: currentProgress,
    ));

    try {
      String? filePath;

      if (Platform.isAndroid) {
        // Method 1: Try to save directly to Downloads folder
        try {
          final downloadsDir = Directory('/storage/emulated/0/Download');
          if (await downloadsDir.exists()) {
            filePath = "${downloadsDir.path}/${event.fileName}";

            // Test write permission
            final testFile = File(filePath);
            await testFile.writeAsString('test');
            await testFile.delete();

            // Download directly to Downloads folder
            await _downloadFile(
              event.fileUrl,
              filePath,
              emit,
              event.fileName,
              currentAttachments,
              hasReachedMax,
              currentProgress,
            );
            currentProgress.remove(event.fileName);
            emit(DownloadSuccessCandidate(
              filePath,
              event.fileName,
              currentAttachments,
              hasReachedMax: hasReachedMax,
            ));
            return;
          }
        } catch (e) {
          if (kDebugMode) {
            print("Cannot write to Downloads folder: $e");
          }
        }

        // Method 2: Use file picker to let user choose location
        try {
          // Download to temporary location
          final tempDir = await getTemporaryDirectory();
          final tempFile = File("${tempDir.path}/${event.fileName}");

          await _downloadFile(
            event.fileUrl,
            tempFile.path,
            emit,
            event.fileName,
            currentAttachments,
            hasReachedMax,
            currentProgress,
          );

          // Let user choose save location
          final result = await FilePicker.platform.saveFile(
            dialogTitle: 'Save ${event.fileName}',
            fileName: event.fileName,
            bytes: await tempFile.readAsBytes(),
          );

          if (result != null) {
            await tempFile.delete(); // Clean up temp file
            currentProgress.remove(event.fileName);
            emit(DownloadSuccessCandidate(
              result,
              event.fileName,
              currentAttachments,
              hasReachedMax: hasReachedMax,
            ));
          } else {
            await tempFile.delete(); // Clean up temp file
            currentProgress.remove(event.fileName);
            emit(DownloadFailureCandidate(
              'Save cancelled by user',
              currentAttachments,
              hasReachedMax: hasReachedMax,
            ));
          }
          return;
        } catch (e) {
          if (kDebugMode) {
            print("File picker failed: $e");
          }
        }

        // Method 3: Fallback - save to app documents directory
        final documentsDir = await getApplicationDocumentsDirectory();
        filePath = "${documentsDir.path}/${event.fileName}";
        await _downloadFile(
          event.fileUrl,
          filePath,
          emit,
          event.fileName,
          currentAttachments,
          hasReachedMax,
          currentProgress,
        );
        currentProgress.remove(event.fileName);
        emit(DownloadSuccessCandidate(
          filePath,
          event.fileName,
          currentAttachments,
          hasReachedMax: hasReachedMax,
        ));
      } else {
        // iOS: Save to documents directory
        final documentsDir = await getApplicationDocumentsDirectory();
        filePath = "${documentsDir.path}/${event.fileName}";
        await _downloadFile(
          event.fileUrl,
          filePath,
          emit,
          event.fileName,
          currentAttachments,
          hasReachedMax,
          currentProgress,
        );
        currentProgress.remove(event.fileName);
        emit(DownloadSuccessCandidate(
          filePath,
          event.fileName,
          currentAttachments,
          hasReachedMax: hasReachedMax,
        ));
      }
    } catch (e) {
      currentProgress.remove(event.fileName);
      emit(DownloadFailureCandidate(
        e.toString(),
        currentAttachments,
        hasReachedMax: hasReachedMax,
      ));
      flutterToastCustom(msg: 'Download failed: $e');
    }
  }

// Helper method to download file
  Future<void> _downloadFile(
      String url,
      String filePath,
      Emitter<CandidateAttachmentState> emit,
      String fileName,
      List<CandidateAttachment> currentAttachments,
      bool hasReachedMax,
      Map<String, double> currentProgress,
      ) async {
    final dio = Dio();
    await dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          currentProgress[fileName] = received / total;
          emit(DownloadInProgressCandidate(
            received / total,
            fileName,
            CandidateAttachments: currentAttachments,
            hasReachedMax: hasReachedMax,
            downloadProgress: currentProgress,
          ));
        }
      },
    );
  }




}


