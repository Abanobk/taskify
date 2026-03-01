import "dart:io";

import "package:equatable/equatable.dart";
import "package:taskify/data/model/contract/contract_model.dart";

abstract class ContractEvent extends Equatable {
  const ContractEvent();

  @override
  List<Object?> get props => [];
}

class CreateContract extends ContractEvent {
  final ContractModel model;

  const CreateContract({required this.model});

  @override
  List<Object> get props => [model];
}

class SignContract extends ContractEvent {
  final String contractImage;
  final int id;
  const SignContract({required this.contractImage, required this.id});

  @override
  List<Object> get props => [contractImage, id];
}

class ContractList extends ContractEvent {
  const ContractList();

  @override
  List<Object?> get props => [];
}
// class ContractList extends ContractEvent {
//
//  final int? projectId;
//  final int? clientId;
//  final int? typeId;
//  final int? statusId;
//  final String? fromDate;
//  final String? toDate;
//  ContractList({this.projectId,this.clientId,this.typeId,this.statusId,this.fromDate,this.toDate});
//
//  @override
//  List<Object?> get props => [projectId,clientId,typeId,statusId,statusId,fromDate,toDate];
// }

class UpdateContract extends ContractEvent {
  final ContractModel model;
  final File? contractPdf;

  const UpdateContract(this.model,this.contractPdf);

  @override
  List<Object?> get props => [model];
}

class DeleteContract extends ContractEvent {
  final int Contract;

  const DeleteContract(this.Contract);

  @override
  List<Object?> get props => [Contract];
}class DeleteContractSign extends ContractEvent {
  final int Contract;

  const DeleteContractSign(this.Contract);

  @override
  List<Object?> get props => [Contract];
}

class SearchContract extends ContractEvent {
  final String searchQuery;

  const SearchContract(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}

class LoadMoreContract extends ContractEvent {
  final String searchQuery;

  const LoadMoreContract(this.searchQuery);

  @override
  List<Object?> get props => [];
}
