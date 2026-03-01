import 'package:flutter/material.dart';
import 'colors.dart';

ThemeData lightTheme = ThemeData(
  popupMenuTheme: const PopupMenuThemeData(
    color: AppColors.pureWhiteColor, // Set the background color of the popup menu
  ),

    useMaterial3: false,

  // scaffoldBackgroundColor:colors.primary,
    brightness: Brightness.light,
    primarySwatch: Colors.indigo,
    hintColor: Colors.pink,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xff696CFF), // Set your desired background color
  ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.indigo,
      textTheme: ButtonTextTheme.primary,
    ),
    // scaffoldBackgroundColor: Color(0xfff1f1f1)
);

ThemeData darkTheme = ThemeData(
  useMaterial3: false,
  // scaffoldBackgroundColor: Color(0xff302C52),
  brightness: Brightness.dark,
  popupMenuTheme: const PopupMenuThemeData(
    color: AppColors.darkContainer, // Set the background color of the popup menu
  ),
  primarySwatch: Colors.indigo,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xff696CFF), // Set your desired background color
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.red,
    textTheme: ButtonTextTheme.primary,
  ),
  hintColor: Colors.pink,
);


// ThemeData lightTheme = ThemeData(
//   scaffoldBackgroundColor: ThemeData().colorScheme.lightWhite,
//   canvasColor: colors.darkColor,
//   cardColor: colors.darkColor2,
//   dialogBackgroundColor: colors.darkColor2,
//   primaryColor: colors.darkColor,
//   textSelectionTheme: TextSelectionThemeData(
//       cursorColor: colors.darkIcon,
//       selectionColor: colors.darkIcon,
//       selectionHandleColor: colors.darkIcon),
//   fontFamily: 'Raleway',
//   //brightness: Brightness.dark,
//   iconTheme: ThemeData().iconTheme.copyWith(color: colors.primary),
//   textTheme: TextTheme(
//       titleLarge: TextStyle(
//         color: ThemeData().colorScheme.fontColor,
//         fontWeight: FontWeight.w600,
//       ),
//       titleMedium: TextStyle(
//           color: ThemeData().colorScheme.fontColor,
//           fontWeight: FontWeight.bold))
//       .apply(bodyColor: ThemeData().colorScheme.fontColor),
//   colorScheme: ColorScheme.fromSwatch(primarySwatch: colors.primary_app)
//       .copyWith(secondary: colors.darkIcon, brightness: Brightness.dark),
//   checkboxTheme: CheckboxThemeData(
//     fillColor:
//     MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
//       if (states.contains(MaterialState.disabled)) {
//         return null;
//       }
//       if (states.contains(MaterialState.selected)) {
//         return colors.primary;
//       }
//       return null;
//     }),
//   ),
//   radioTheme: RadioThemeData(
//     fillColor:
//     MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
//       if (states.contains(MaterialState.disabled)) {
//         return null;
//       }
//       if (states.contains(MaterialState.selected)) {
//         return colors.primary;
//       }
//       return null;
//     }),
//   ),
//   switchTheme: SwitchThemeData(
//     thumbColor:
//     MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
//       if (states.contains(MaterialState.disabled)) {
//         return null;
//       }
//       if (states.contains(MaterialState.selected)) {
//         return colors.primary;
//       }
//       return null;
//     }),
//     trackColor:
//     MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
//       if (states.contains(MaterialState.disabled)) {
//         return null;
//       }
//       if (states.contains(MaterialState.selected)) {
//         return colors.primary;
//       }
//       return null;
//     }),
//   ),
// );
//
//
// ThemeData darkTheme= ThemeData(
//   scaffoldBackgroundColor: ThemeData().colorScheme.lightWhite,
//   canvasColor: ThemeData().colorScheme.lightWhite,
//   cardColor: colors.cardColor,
//   dialogBackgroundColor: ThemeData().colorScheme.white,
//   iconTheme: ThemeData().iconTheme.copyWith(color: colors.primary),
//   primarySwatch: colors.primary_app,
//   primaryColor: ThemeData().colorScheme.lightWhite,
//   fontFamily: 'Raleway',
//   colorScheme: ColorScheme.fromSwatch(primarySwatch: colors.primary_app)
//       .copyWith(secondary: colors.secondary, brightness: Brightness.light),
//   textTheme: TextTheme(
//       titleLarge: TextStyle(
//         color: ThemeData().colorScheme.fontColor,
//         fontWeight: FontWeight.w600,
//       ),
//       titleMedium: TextStyle(
//           color: ThemeData().colorScheme.fontColor,
//           fontWeight: FontWeight.bold))
//       .apply(bodyColor: ThemeData().colorScheme.fontColor),
// );