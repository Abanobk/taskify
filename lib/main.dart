// main.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:taskify/screens/authentication/login_screen.dart';
import 'package:taskify/screens/home_screen/home_screen.dart';
import 'package:taskify/screens/my_app.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'app/app.dart';
import 'bloc/theme/theme_bloc.dart';
import 'bloc/theme/theme_event.dart';
import 'config/strings.dart';

late final GoRouter router;

void main() async {
  try {
    log("🚀 Starting app...");

    // Initialize Flutter binding
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize app (Firebase, Hive, etc.)
    await initializeApp();

    // Get theme preference after initialization
    final themeBoxIs = Hive.box(themeBox);
    bool isDarkTheme = themeBoxIs.get(isDarkThemeKey, defaultValue: false);

    // Initialize Flutter Downloader
    await FlutterDownloader.initialize(debug: true);

    // Setup router
    router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
      ],
    );

    print("✅ App initialization successful, starting UI...");

    runApp(
      BlocProvider(
        create: (_) => ThemeBloc()..add(InitialThemeEvent(isDarkTheme)),
        child: ShowCaseWidget(
          autoPlay: true,
          autoPlayDelay: const Duration(seconds: 8),
          builder: (context) => ThemeSwitcher(
            clipper: const ThemeSwitcherCircleClipper(),
            builder: (context) => MyApp(isDarkTheme: isDarkTheme),
          ),
        ),
      ),
    );

  } catch (e, stackTrace) {
    print("❌ Fatal error in main: $e");
    print("Stack trace: $stackTrace");

    // Show error screen
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.red[50],
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red[600],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'App Failed to Start',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Please restart the app or contact support if the problem persists.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Error Details:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        e.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Close the app
                        // SystemNavigator.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Close App'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}