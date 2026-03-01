import "package:equatable/equatable.dart";



abstract class ContractTypeEvent extends Equatable{
 const ContractTypeEvent();

 @override
 List<Object?> get props => [];
}
 class CreateContractType extends ContractTypeEvent{
 final String type;

 const CreateContractType({required this.type});

 @override
 List<Object> get props => [type];
}

class ContractTypeList extends ContractTypeEvent {

 const ContractTypeList();

 @override
 List<Object?> get props => [];
}


class UpdateContractType extends ContractTypeEvent {
 final String type;
 final int id;

 const UpdateContractType(this.type,this.id);

 @override
 List<Object?> get props => [id,type];
}

class DeleteContractType extends ContractTypeEvent {
 final int ContractType;

 const DeleteContractType(this.ContractType );

 @override
 List<Object?> get props => [ContractType];
}
class SearchContractType extends ContractTypeEvent {
 final String searchQuery;

 const SearchContractType(this.searchQuery);

 @override
 List<Object?> get props => [searchQuery];
}
class LoadMoreContractType extends ContractTypeEvent {
 final String searchQuery;

 const LoadMoreContractType(this.searchQuery);

 @override
 List<Object?> get props => [];
}
class SelectContractType extends ContractTypeEvent {
 final int id;
 final String type;
 SelectContractType({required this.id, required this.type});
}