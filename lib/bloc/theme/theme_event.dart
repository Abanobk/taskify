import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class InitialThemeEvent extends ThemeEvent {
  final bool isDarkTheme;

  InitialThemeEvent(this.isDarkTheme);
}
class ToggleThemeEvent extends ThemeEvent {}

