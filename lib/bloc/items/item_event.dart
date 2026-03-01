import "package:equatable/equatable.dart";
import "../../data/model/finance/estimate_invoices_model.dart";


abstract class ItemsEvent extends Equatable{
 const ItemsEvent();

 @override
 List<Object?> get props => [];
}
 class CreateItems extends ItemsEvent{
 final String title;
  final String desc;
  final int unitId;
  final int price;
  final bool token;
 const CreateItems({required this.desc,required this.token,required this.title,required this.price,
  required this.unitId});

 @override
 List<Object> get props => [title,desc,token];
}
class DrawingItem extends ItemsEvent{
 final String drawing;

 const DrawingItem({required this.drawing});

 @override
 List<Object> get props => [drawing];
}

class ItemsList extends ItemsEvent {

 const ItemsList();

 @override
 List<Object?> get props => [];
}
class AddItems extends ItemsEvent {
 final InvoicesItems Items;

 const AddItems(this.Items);

 @override
 List<Object?> get props => [Items];
}

class UpdateItems extends ItemsEvent {
 final InvoicesItems Items;

 const UpdateItems(this.Items);

 @override
 List<Object?> get props => [Items];
}

class DeleteItems extends ItemsEvent {
 final int Items;

 const DeleteItems(this.Items );

 @override
 List<Object?> get props => [Items];
}
class SearchItems extends ItemsEvent {
 final String searchQuery;
 final String unitId;

 const SearchItems(this.searchQuery,this.unitId);

 @override
 List<Object?> get props => [searchQuery];
}
class LoadMoreItems extends ItemsEvent {
 final String searchQuery;

 const LoadMoreItems(this.searchQuery);

 @override
 List<Object?> get props => [];
}
