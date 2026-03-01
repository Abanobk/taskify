import 'package:equatable/equatable.dart';

import '../../data/model/user_model.dart';





abstract class UseridState extends Equatable{
  @override
  List<Object?> get props => [];
}

class UseridInitial extends UseridState {}

class UseridLoading extends UseridState {}
class UserIdError extends UseridState {
  final String errorMessage;
  UserIdError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class UseridWithId extends UseridState {
  final List<User> user;

  UseridWithId(
      this.user,

      );
  @override
  List<Object> get props => [user];
}
