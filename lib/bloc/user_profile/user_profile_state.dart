import 'package:equatable/equatable.dart';

import '../../data/model/user_profile/user_profile.dart';


abstract class UserProfileState extends Equatable{
  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {}
class UserProfileLoading extends UserProfileState {}
class UserProfileSuccess extends UserProfileState {
  final List<ProfileModel> profile;
  UserProfileSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}
class UserProfileError extends UserProfileState {
  final String error;

  UserProfileError(this.error);

  @override
  List<Object?> get props => [error];
}
class UserDetailUpdateError extends UserProfileState {
  final String error;

  UserDetailUpdateError(this.error);

  @override
  List<Object?> get props => [error];
}
class UserDetailUpdateSuccess extends UserProfileState {


  UserDetailUpdateSuccess();

  @override
  List<Object?> get props => [];
}