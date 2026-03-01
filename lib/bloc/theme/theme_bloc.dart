import 'package:bloc/bloc.dart';
import 'package:taskify/bloc/theme/theme_event.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskify/config/strings.dart';
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  bool isDarkTheme = false;

  ThemeBloc() : super(LightThemeState()) {
    _initializeTheme();
    // Load theme from Hive in the constructor (after super)
    // isDarkTheme = _loadThemeFromHive();
    on<InitialThemeEvent>((event, emit) {
      isDarkTheme = event.isDarkTheme;
      emit(isDarkTheme ? DarkThemeState() : LightThemeState());
    });
    on<ToggleThemeEvent>(_onToggleButtonPressed);
  }

  // Load theme from Hive asynchronously and return it
  static Future<bool> loadTheme() async {
    var box = await Hive.openBox(themeBox);
    return box.get('isDarkTheme', defaultValue: false);
  }

  Future<void> _initializeTheme() async {
    isDarkTheme = await loadTheme();  // Load from Hive asynchronously
    add(InitialThemeEvent(isDarkTheme));  // Dispatch initial event
  }

  void _onToggleButtonPressed(ToggleThemeEvent event, Emitter<ThemeState> emit) async {
    if (state is LightThemeState) {
      emit(DarkThemeState());
      Hive.box(themeBox).put('isDarkTheme', true);
    } else {
      emit(LightThemeState());
      Hive.box(themeBox).put('isDarkTheme', false);
    }
  }

  ThemeState get currentThemeState => state;
}

