
import 'package:equatable/equatable.dart';

import '../../data/model/user_model.dart';


abstract class SingleUserState extends Equatable{
  @override
  List<Object?> get props => [];
}

class SingleUserInitial extends SingleUserState {}
class SingleUserLoading extends SingleUserState {}
class SingleUserSuccess extends SingleUserState {
  SingleUserSuccess(this.user,this.selectedIndex, this.selectedTitle,this.isLoadingMore);
  final List<User> user;
   final int? selectedIndex;
  final String selectedTitle;
  final bool isLoadingMore;
  @override
  List<Object> get props => [user,selectedIndex!,selectedTitle,isLoadingMore];
}

class SingleUserError extends SingleUserState {
  final String errorMessage;
  SingleUserError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
