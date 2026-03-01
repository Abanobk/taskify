
import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../data/model/user_model.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserList extends UserEvent {
  final int? id;
  UserList({this.id});
  @override
  List<Object> get props => [id!];
}
class UserListId extends UserEvent {
  final int? id;
  UserListId({this.id});
  @override
  List<Object> get props => [id!];
}
class UserLoadMore extends UserEvent {
  final String search;
  UserLoadMore(this.search);

  @override
  List<Object?> get props => [];
}

class SelectedUser extends UserEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectedUser(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}
class SelectedSingleUser extends UserEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectedSingleUser({required this.selectedIndex, required this.selectedTitle});
}

class ToggleUserSelection extends UserEvent {
  final int userId;
  final String userName;

  ToggleUserSelection(this.userId, this.userName);
}
class UsersCreated extends UserEvent {
  final User userList;
  final File? image;
  final String? profileImage;


  UsersCreated(this.userList,this.image,this.profileImage);
  @override
  List<Object> get props => [userList];
}
class AllUsersList extends UserEvent {

  AllUsersList();

  @override
  List<Object> get props => [];
}
class UpdateUsers extends UserEvent {
  final User user;

  UpdateUsers(this.user);
  @override
  List<Object> get props => [user];
}

class DeleteUsers extends UserEvent {
  final int userId;

  DeleteUsers(this.userId);

  @override
  List<Object?> get props => [userId];
}
class SearchUsers extends UserEvent {
  final String searchQuery;

  SearchUsers(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}

