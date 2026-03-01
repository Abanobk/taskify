import 'package:equatable/equatable.dart';

import '../../data/model/user_model.dart';

abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}
class UserWithId extends UserState {
  final List<User> user;

  UserWithId(
     this.user,

  );
  @override
  List<Object> get props => [user];
}

class UserLoading extends UserState {}

class UserSuccess extends UserState {
  final List<User> user;
  final List<int> selectedIndices;
  final List<String> selectedUsernames;
  final bool isLoadingMore;

  UserSuccess({
    required this.user,
    this.selectedIndices = const [],
    this.selectedUsernames = const [],
    this.isLoadingMore = false,
  });
}
class UserSingleSuccess extends UserState {
  final List<User> user;
  final int? selectedIndex;
  final String selectedTitle;
  final bool isLoadingMore;

  UserSingleSuccess(this.user,this.selectedIndex, this.selectedTitle,this.isLoadingMore);

  @override
  List<Object> get props => [user,selectedIndex!,selectedTitle,isLoadingMore];

}
class UserPaginated extends UserState {
  final List<User> user;
  final bool hasReachedMax;
  final bool? isLoading;

  UserPaginated({
    required this.user,
    required this.hasReachedMax,
     this.isLoading,
  });

  // Implementing the copyWith method
  UserPaginated copyWith({
    List<User>? user,
    bool? hasReachedMax,
    bool? isLoading,
  }) {
    return UserPaginated(
      user: user ?? this.user,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [user, hasReachedMax, isLoading];
}


class UserSuccessCreateLoading extends UserState {}
class UserSuccessEditLoading extends UserState {}

class UserSuccessCreate extends UserState {
  final User users;

  UserSuccessCreate({
    required this.users,
  });

  @override
  List<Object> get props => [users];
}

class UserError extends UserState {
  final String errorMessage;
  UserError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class  UserCreateError extends  UserState {
  final String errorMessage;

  UserCreateError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class  UserEditError extends  UserState {
  final String errorMessage;

  UserEditError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class  UserEditSuccess extends  UserState {
  UserEditSuccess();
  @override
  List<Object> get props => [];
}
class  UserCreateSuccess extends  UserState {
  UserCreateSuccess();
  @override
  List<Object> get props => [];
}
class  UserDeleteError extends  UserState {
  final String errorMessage;

  UserDeleteError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class  UserDeleteSuccess extends  UserState {
  UserDeleteSuccess();
  @override
  List<Object> get props => [];
}