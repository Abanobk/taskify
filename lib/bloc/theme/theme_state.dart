import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeState extends Equatable {
  final ThemeData themeData;

  const ThemeState(this.themeData);

  @override
  List<Object> get props => [themeData];
}

class LightThemeState extends ThemeState {
   LightThemeState() : super(ThemeData.light());
}

class DarkThemeState extends ThemeState {
   DarkThemeState() : super(ThemeData.dark());
}
