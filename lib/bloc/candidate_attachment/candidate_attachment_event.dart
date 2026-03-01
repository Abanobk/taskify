part of 'candidate_attachment_bloc.dart';

abstract class CandidateAttachmentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AttachmentList extends CandidateAttachmentEvent {
  final int? id;


  AttachmentList({this.id,});

  @override
  List<Object?> get props => [id];
}
class SilentAttachmentRefresh extends CandidateAttachmentEvent {
  final int? id;
  SilentAttachmentRefresh({this.id});

  @override
  List<Object?> get props => [id];
}
class DeleteCandidateAttachment extends CandidateAttachmentEvent {
  final int? id;


  DeleteCandidateAttachment({this.id,});

  @override
  List<Object?> get props => [id];
}
class StartDownloadAttachment extends CandidateAttachmentEvent {
  final int id;
  final String fileUrl;
  final String fileName;
  final List<CandidateAttachment> media;

  StartDownloadAttachment({required this.fileUrl, required this.fileName,required this.id,required this.media});

  @override
  List<Object?> get props => [fileUrl, fileName];
}
class UploadAttachment extends CandidateAttachmentEvent {
  final int id;
  final List<File> media; // List of files to be uploaded

   UploadAttachment({required this.id, required this.media}); // ✅ Mark required

  @override
  List<Object?> get props => [id, media];
}
class AttachmentLoadMore extends CandidateAttachmentEvent {
  final String? searchQuery;
  final int id;


  AttachmentLoadMore(this.searchQuery,this.id);

  @override
  List<Object?> get props => [searchQuery];
}