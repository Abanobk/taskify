import "package:equatable/equatable.dart";

import "../../data/model/finance/unitd_model.dart";


abstract class UnitsEvent extends Equatable{
 const UnitsEvent();

 @override
 List<Object?> get props => [];
}
 class CreateUnits extends UnitsEvent{
 final String title;
  final String desc;
  final int unitId;
  final bool token;
 const CreateUnits({required this.desc,required this.token,required this.title,
  required this.unitId});

 @override
 List<Object> get props => [title,desc,token];
}
class DrawingItem extends UnitsEvent{
 final String drawing;

 const DrawingItem({required this.drawing});

 @override
 List<Object> get props => [drawing];
}

class UnitsList extends UnitsEvent {

 const UnitsList();

 @override
 List<Object?> get props => [];
}
class AddUnits extends UnitsEvent {
 final UnitModel Units;

 const AddUnits(this.Units);

 @override
 List<Object?> get props => [Units];
}

class UpdateUnits extends UnitsEvent {
 final UnitModel Units;

 const UpdateUnits(this.Units);

 @override
 List<Object?> get props => [Units];
}

class DeleteUnits extends UnitsEvent {
 final int Units;

 const DeleteUnits(this.Units );

 @override
 List<Object?> get props => [Units];
}
class SearchUnits extends UnitsEvent {
 final String searchQuery;

 const SearchUnits(this.searchQuery);

 @override
 List<Object?> get props => [searchQuery];
}
class LoadMoreUnits extends UnitsEvent {
 final String searchQuery;

 const LoadMoreUnits(this.searchQuery);

 @override
 List<Object?> get props => [];
}
