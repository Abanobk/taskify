import 'package:flutter/material.dart';

import '../config/colors.dart';

class AppTheme {
  final Color primaryColor;
  final Color accentColor;
  final TextStyle textStyle;

  AppTheme({required this.primaryColor, required this.accentColor, required this.textStyle});
}

final AppTheme lightTheme = AppTheme(
  primaryColor:   AppColors.primary,
  accentColor: Colors.green,
  textStyle: const TextStyle(fontSize: 16, color: Colors.teal),
);

final AppTheme darkTheme = AppTheme(
  primaryColor:   AppColors.primary,
  accentColor: Colors.yellow,
  textStyle: const TextStyle(fontSize: 16, color: Colors.red),
);
