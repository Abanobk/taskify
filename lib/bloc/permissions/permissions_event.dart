
import 'package:equatable/equatable.dart';

abstract class PermissionsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetPermissions extends PermissionsEvent {

  GetPermissions();
@override
List<Object?> get props => [];
}
