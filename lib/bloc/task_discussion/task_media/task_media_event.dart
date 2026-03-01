part of 'task_media_bloc.dart';

abstract class TaskMediaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskMediaList extends TaskMediaEvent {
  final int? id;


  TaskMediaList({this.id,});

  @override
  List<Object?> get props => [id];
}
class DeleteTaskMedia extends TaskMediaEvent {
  final int? id;


  DeleteTaskMedia({this.id,});

  @override
  List<Object?> get props => [id];
}
class TaskSilentMediaRefresh extends TaskMediaEvent {
  final int? id;
  TaskSilentMediaRefresh({this.id});

  @override
  List<Object?> get props => [id];
}
class TaskStartDownload extends TaskMediaEvent {
  final String fileUrl;
  final String fileName;

  TaskStartDownload({required this.fileUrl, required this.fileName});

  @override
  List<Object?> get props => [fileUrl, fileName];
}
class TaskSearchMedia extends TaskMediaEvent {
  final String searchQuery;
  final int? id;

  TaskSearchMedia(this.searchQuery,this.id);

  @override
  List<Object?> get props => [searchQuery];
}
class UploadTaskMedia extends TaskMediaEvent {
  final int id;
  final List<File> media; // List of files to be uploaded

  UploadTaskMedia({required this.id, required this.media});

  @override
  List<Object?> get props => [id,media];
}