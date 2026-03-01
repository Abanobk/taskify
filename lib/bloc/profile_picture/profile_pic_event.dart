import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ProfilePicEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PickImageFromGallery extends ProfilePicEvent {
 final BuildContext context;
  PickImageFromGallery({required this.context});
  @override
  List<Object?> get props => [context];
}

class PickImageFromCamera extends ProfilePicEvent {
 final  BuildContext context;
  PickImageFromCamera({required this.context});
  @override
  List<Object?> get props => [context];
}
class LoadSavedImage extends ProfilePicEvent {

  @override
  List<Object?> get props => [];
}
class ShowImage extends ProfilePicEvent {

  @override
  List<Object?> get props => [];
}
class ProfileDetailsUpdate extends ProfilePicEvent {

  @override
  List<Object?> get props => [];
}
