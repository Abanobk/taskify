import "package:equatable/equatable.dart";



abstract class InterviewsEvent extends Equatable{
 const InterviewsEvent();

 @override
 List<Object?> get props => [];
}
class CreateInterviews extends InterviewsEvent {
 final int? candidateId;
 final String? candidateName;
 final int? interviewerId;
 final String? interviewerName;
 final String? round;
 final String? scheduledAt;
 final String? mode;
 final String? location;
 final String? status;

 const CreateInterviews({
  this.candidateId,
  this.candidateName,
  this.interviewerId,
  this.interviewerName,
  this.round,
  this.scheduledAt,
  this.mode,
  this.location,
  this.status,
 });

 @override
 List<Object?> get props => [

  candidateId,
  candidateName,
  interviewerId,
  interviewerName,
  round,
  scheduledAt,
  mode,
  location,
  status,
 ];
}


class InterviewsList extends InterviewsEvent {

 const InterviewsList();

 @override
 List<Object?> get props => [];
}

class UpdateInterviews extends InterviewsEvent {
 final int? id;
 final int? candidateId;
 final String? candidateName;
 final int? interviewerId;
 final String? interviewerName;
 final String? round;
 final String? scheduledAt;
 final String? mode;
 final String? location;
 final String? status;

 const UpdateInterviews({
  this.id,
  this.candidateId,
  this.candidateName,
  this.interviewerId,
  this.interviewerName,
  this.round,
  this.scheduledAt,
  this.mode,
  this.location,
  this.status,
 });

 @override
 List<Object?> get props => [
  id,
  candidateId,
  candidateName,
  interviewerId,
  interviewerName,
  round,
  scheduledAt,
  mode,
  location,
  status,
 ];
}


class DeleteInterviews extends InterviewsEvent {
 final int Interviews;

 const DeleteInterviews(this.Interviews );

 @override
 List<Object?> get props => [Interviews];
}
class SearchInterviews extends InterviewsEvent {
 final String searchQuery;

 const SearchInterviews(this.searchQuery);

 @override
 List<Object?> get props => [searchQuery];
}
class LoadMoreInterviews extends InterviewsEvent {
 final String searchQuery;

 const LoadMoreInterviews(this.searchQuery);

 @override
 List<Object?> get props => [];
}
