
abstract class AuthState {}

class AuthInitial extends AuthState {

}

class AuthLoadInProgress extends AuthState {}
class WorkspaceUpdated extends AuthState {
  final String workspace;

  WorkspaceUpdated({required this.workspace});
}

class AuthLoadSuccess extends AuthState {
  final Map<String,dynamic> user;


  AuthLoadSuccess({required this.user});
}
class AuthLoadSuccessLoading extends AuthState {}
class AuthSignUpLoadSuccess extends AuthState {
  final Map<String,dynamic> user;


  AuthSignUpLoadSuccess({required this.user});
}
class AuthSignUpLoadFailure extends AuthState {
  final String message;


  AuthSignUpLoadFailure({ required this.message});
}
class AuthLoadFailure extends AuthState {
  final String message;


  AuthLoadFailure({ required this.message});
}
class ResetPasswordSuccess extends AuthState {


  ResetPasswordSuccess();
}
class ResetPasswordFailure extends AuthState {
  final String message;


  ResetPasswordFailure({ required this.message});
}