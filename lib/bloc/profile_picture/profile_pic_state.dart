
import 'dart:io';
import 'package:equatable/equatable.dart';


abstract class ProfilePicState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ImagePickerInitial extends ProfilePicState {}
class ImagePickerLoading extends ProfilePicState {}

class ImagePickerSuccess extends ProfilePicState {
  final File image;

  ImagePickerSuccess(this.image);

  @override
  List<Object?> get props => [image];
}

class ImagePickerFailure extends ProfilePicState {
  final String error;

  ImagePickerFailure(this.error);

  @override
  List<Object?> get props => [error];
}