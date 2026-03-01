import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_state.dart';

abstract class ThemeEvent {}

class ToggleTheme extends ThemeEvent {}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(LightThemeState()) {
    on<ToggleTheme>(_onToggleTheme);
  }

  ThemeState get currentThemeState => state;

  void _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) {
    if (state is LightThemeState) {
      emit(DarkThemeState());
    } else {
      emit(LightThemeState());
    }
  }
} 