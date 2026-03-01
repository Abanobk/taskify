import 'package:equatable/equatable.dart';

import '../../../data/model/project/media.dart';

abstract class TaskMediaState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskMediaInitial extends TaskMediaState {}
class TaskMediaLoading extends TaskMediaState {}

class TaskMediaSuccess extends TaskMediaState {}
class TaskMediaPaginated extends TaskMediaState {
  final List<MediaModel> TaskMediaList;
  final bool hasReachedMax;


  TaskMediaPaginated({
    required this.TaskMediaList,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [TaskMediaList, hasReachedMax];
}
class TaskMediaError extends TaskMediaState {
  final String errorMessage;
  TaskMediaError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class TaskDownloadInProgress extends TaskMediaState {
  final double progress;
  final String fileName;
  TaskDownloadInProgress(this.progress,this.fileName);

  @override
  List<Object?> get props => [progress];
}

class TaskDownloadSuccess extends TaskMediaState {
  final String filePath;
  final String fileName;
  TaskDownloadSuccess(this.filePath,this.fileName);

  @override
  List<Object?> get props => [filePath];
}

class TaskDownloadFailure extends TaskMediaState {
  final String error;
  TaskDownloadFailure(this.error);

  @override
  List<Object?> get props => [error];
}
class TaskMediaDeleteSuccess extends TaskMediaState {
  TaskMediaDeleteSuccess();
  @override
  List<Object> get props =>
      [];
}
class TaskMediaUploadSuccess extends TaskMediaState {
  TaskMediaUploadSuccess();
  @override
  List<Object> get props =>
      [];
}