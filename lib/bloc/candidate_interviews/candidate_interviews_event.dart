import "package:equatable/equatable.dart";



abstract class CandidateInterviewsEvent extends Equatable{
 const CandidateInterviewsEvent();

 @override
 List<Object?> get props => [];
}
class CreateCandidateInterviews extends CandidateInterviewsEvent {
 final int? candidateId;
 final String? candidateName;
 final int? CandidateInterviewserId;
 final String? CandidateInterviewserName;
 final String? round;
 final String? scheduledAt;
 final String? mode;
 final String? location;
 final String? status;

 const CreateCandidateInterviews({
  this.candidateId,
  this.candidateName,
  this.CandidateInterviewserId,
  this.CandidateInterviewserName,
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
  CandidateInterviewserId,
  CandidateInterviewserName,
  round,
  scheduledAt,
  mode,
  location,
  status,
 ];
}


class CandidateInterviewsList extends CandidateInterviewsEvent {
 final int? id;
 const CandidateInterviewsList({this.id});

 @override
 List<Object?> get props => [id];
}

class UpdateCandidateInterview extends CandidateInterviewsEvent {
 final int? id;
 final int? candidateId;
 final String? candidateName;
 final int? CandidateInterviewserId;
 final int? interviewerId;
 final String? interviewerName;
 final String? CandidateInterviewserName;
 final String? round;
 final String? scheduledAt;
 final String? mode;
 final String? location;
 final String? status;

 const UpdateCandidateInterview({
  this.id,
  this.candidateId,
  this.candidateName,
  this.interviewerId,
  this.interviewerName,
  this.CandidateInterviewserId,
  this.CandidateInterviewserName,
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
  CandidateInterviewserId,
  CandidateInterviewserName,
  round,
  interviewerName,
  interviewerId,
  scheduledAt,
  mode,
  location,
  status,
 ];
}


class DeleteCandidateInterview extends CandidateInterviewsEvent {
 final int CandidateInterviewss;

 const DeleteCandidateInterview(this.CandidateInterviewss );

 @override
 List<Object?> get props => [CandidateInterviewss];
}
class SearchCandidateInterview extends CandidateInterviewsEvent {
 final String searchQuery;

 const SearchCandidateInterview(this.searchQuery);

 @override
 List<Object?> get props => [searchQuery];
}
class LoadMoreCandidateInterview extends CandidateInterviewsEvent {
 final String searchQuery;

 const LoadMoreCandidateInterview(this.searchQuery);

 @override
 List<Object?> get props => [];
}
