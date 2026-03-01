

import 'package:equatable/equatable.dart';

import '../../data/model/candidate/attachment_candidate.dart';

abstract class CandidateAttachmentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CandidateAttachmentInitial extends CandidateAttachmentState {}
class CandidateAttachmentLoading extends CandidateAttachmentState {}

class CandidateAttachmentSuccess extends CandidateAttachmentState {}
class CandidateAttachmentPaginated extends CandidateAttachmentState {
  final List<CandidateAttachment> CandidateAttachments;
  final bool hasReachedMax;
  final Map<String, double> downloadProgress; // Map of fileName to progress (0.0 to 1.0)

   CandidateAttachmentPaginated({
    required this.CandidateAttachments,
    required this.hasReachedMax,
    this.downloadProgress = const {}, // Empty by default
  });

  CandidateAttachmentPaginated copyWith({
    List<CandidateAttachment>? CandidateAttachments,
    bool? hasReachedMax,
    Map<String, double>? downloadProgress,
  }) {
    return CandidateAttachmentPaginated(
      CandidateAttachments: CandidateAttachments ?? this.CandidateAttachments,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }

  @override
  List<Object> get props => [CandidateAttachments, hasReachedMax, downloadProgress];
}
class CandidateAttachmentError extends CandidateAttachmentState {
  final String errorMessage;
  CandidateAttachmentError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class DownloadInProgressCandidate extends CandidateAttachmentState {
  final double progress;
  final String fileName;
  final List<CandidateAttachment> CandidateAttachments;
  final bool hasReachedMax;
  final Map<String, double> downloadProgress;

   DownloadInProgressCandidate(
      this.progress,
      this.fileName, {
        required this.CandidateAttachments,
        required this.hasReachedMax,
        this.downloadProgress = const {},
      });

  @override
  List<Object> get props => [
    progress,
    fileName,
    CandidateAttachments,
    hasReachedMax,
    downloadProgress,
  ];
}

class DownloadSuccessCandidate extends CandidateAttachmentState {
  final String filePath;
  final String fileName;
  final List<CandidateAttachment> CandidateAttachments;
  final bool hasReachedMax;
   DownloadSuccessCandidate(
      this.filePath,
      this.fileName,
      this.CandidateAttachments, {
        required this.hasReachedMax,
      });
  @override
  List<Object?> get props => [filePath,fileName,CandidateAttachments,hasReachedMax];
}

class DownloadFailureCandidate extends CandidateAttachmentState {
  final String error;
  final List<CandidateAttachment> CandidateAttachments;
  final bool hasReachedMax;

   DownloadFailureCandidate(
      this.error,
      this.CandidateAttachments, {
        required this.hasReachedMax,
      });

  @override
  List<Object> get props => [
    error,
    CandidateAttachments,
    hasReachedMax,
  ];
}
class CandidateAttachmentDeleteSuccess extends CandidateAttachmentState {
  CandidateAttachmentDeleteSuccess();
  @override
  List<Object> get props =>
      [];
}
class CandidateAttachmentUploadSuccess extends CandidateAttachmentState {
  CandidateAttachmentUploadSuccess();
  @override
  List<Object> get props =>
      [];
}
