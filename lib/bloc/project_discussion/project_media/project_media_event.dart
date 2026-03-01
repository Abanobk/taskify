part of 'project_media_bloc.dart';

abstract class ProjectMediaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class MediaList extends ProjectMediaEvent {
  final int? id;


  MediaList({this.id,});

  @override
  List<Object?> get props => [id];
}
class SilentMediaRefresh extends ProjectMediaEvent {
  final int? id;
   SilentMediaRefresh({this.id});

  @override
  List<Object?> get props => [id];
}
class DeleteProjectMedia extends ProjectMediaEvent {
  final int? id;


  DeleteProjectMedia({this.id,});

  @override
  List<Object?> get props => [id];
}
class StartDownload extends ProjectMediaEvent {
  final String fileUrl;
  final String fileName;

  StartDownload({required this.fileUrl, required this.fileName});

  @override
  List<Object?> get props => [fileUrl, fileName];
}
class UploadMedia extends ProjectMediaEvent {
  final int id;
  final List<File> media; // List of files to be uploaded

   UploadMedia({required this.id, required this.media}); // ✅ Mark required

  @override
  List<Object?> get props => [id, media];
}
class SearchMedia extends ProjectMediaEvent {
  final String searchQuery;
  final int? id;

  SearchMedia(this.searchQuery,this.id);

  @override
  List<Object?> get props => [searchQuery];
}