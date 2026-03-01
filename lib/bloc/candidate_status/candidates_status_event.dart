import "package:equatable/equatable.dart";



abstract class CandidatesStatusEvent extends Equatable{
 const CandidatesStatusEvent();

 @override
 List<Object?> get props => [];
}
 class CreateCandidatesStatus extends CandidatesStatusEvent{
 final String name;
  final String color;

 const CreateCandidatesStatus({required this.name,required this.color});

 @override
 List<Object> get props => [name,color];
}

class CandidatesStatusList extends CandidatesStatusEvent {

 const CandidatesStatusList();

 @override
 List<Object?> get props => [];
}

class UpdateCandidatesStatus extends CandidatesStatusEvent {
 final int id;
 final String name;
 final String color;

 const UpdateCandidatesStatus({required this.id,required this.name,required this.color});

 @override
 List<Object?> get props => [id,name,color];
}

class DeleteCandidatesStatus extends CandidatesStatusEvent {
 final int CandidatesStatus;

 const DeleteCandidatesStatus(this.CandidatesStatus );

 @override
 List<Object?> get props => [CandidatesStatus];
}
class SearchCandidatesStatus extends CandidatesStatusEvent {
 final String searchQuery;

 const SearchCandidatesStatus(this.searchQuery);

 @override
 List<Object?> get props => [searchQuery];
}
class LoadMoreCandidatesStatus extends CandidatesStatusEvent {
 final String searchQuery;

 const LoadMoreCandidatesStatus(this.searchQuery);

 @override
 List<Object?> get props => [];
}
