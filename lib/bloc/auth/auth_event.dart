import 'package:flutter/material.dart';

abstract class AuthEvent {}

class AuthStarted extends AuthEvent {}

class AuthLoggedIn extends AuthEvent {
  final BuildContext context;
  final String? email;
  final String? password;

  AuthLoggedIn({required this.context, this.email,this.password});
}

class AuthSignUp extends AuthEvent {
  final BuildContext context;
  final String? email;
  final String? firstname;
  final String? lastname;
  final String? company;
  final int? role;
  final String? type;
  final String? confirmPass;
  final String? password;

  AuthSignUp({required this.context, this.email,this.password,this.role,this.company,this.lastname,this.firstname,this.confirmPass,this.type});
}
class WorkspaceUpdate extends AuthEvent {

   final String? workspaceTitle;
   WorkspaceUpdate({this.workspaceTitle});
}
class AuthSignIn extends AuthEvent {


  AuthSignIn();
}
class LoggedOut extends AuthEvent {
  final BuildContext context;
  VoidCallback? onLoggedOutCompleted(){
    return null;

  }

  LoggedOut({required this.context});
}

class AppStarted extends AuthEvent {}
class GetWorkspace extends AuthEvent {
  final String currentWorkspace;

  GetWorkspace({required this.currentWorkspace});
}
class GetEmail extends AuthEvent {
  final String email;
  GetEmail({required this.email});
}
class GetPassword extends AuthEvent {
  final String password;
  GetPassword({required this.password});
}
class GetResentPassword extends AuthEvent {
  final String password;

  final String email;
  GetResentPassword({required this.password,required this.email,});
}
class AuthProgress extends AuthEvent {}

class AuthLoggedOut extends AuthEvent {}
