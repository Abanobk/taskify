import "dart:io";

import "package:equatable/equatable.dart";

import "../../data/model/candidate/candidate_model.dart";



abstract class CandidatesEvent extends Equatable{
 const CandidatesEvent();

 @override
 List<Object?> get props => [];
}
 class CreateCandidates extends CandidatesEvent{
 final String name;
  final String email;
  final String phone;
  final String position;
  final String source;
  final int statusId;
  final List<File>? attachment;

 const CreateCandidates({required this.name,required this.email,required this.phone,
  required this.position,required this.source,required this.statusId,this.attachment});

 @override
 List<Object> get props => [name,email,phone,position,source,statusId];
}

class CandidatesList extends CandidatesEvent {
 final int? id;

 const CandidatesList({this.id});

 @override
 List<Object?> get props => [id];
}


class UpdateCandidates extends CandidatesEvent {

 final CandidateModel Candidates;
 final List<File>? attachment;
 final int statusId;

 const UpdateCandidates(this.Candidates,this.attachment,this.statusId);

 @override
 List<Object?> get props => [Candidates,attachment];
}

class DeleteCandidates extends CandidatesEvent {
 final int Candidates;

 const DeleteCandidates(this.Candidates );

 @override
 List<Object?> get props => [Candidates];
}
class SearchCandidates extends CandidatesEvent {
 final String searchQuery;

 const SearchCandidates(this.searchQuery);

 @override
 List<Object?> get props => [searchQuery];
}
class LoadMoreCandidates extends CandidatesEvent {
 final String searchQuery;

 const LoadMoreCandidates(this.searchQuery);

 @override
 List<Object?> get props => [];
}

