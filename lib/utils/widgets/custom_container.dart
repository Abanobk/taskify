import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';

import 'my_theme.dart';
Widget buildCustomContainer({
  required BuildContext context,
  required Widget child,
  double? width,
}) {
  return Container(
    decoration: BoxDecoration(
      boxShadow: [
        Theme.of(context).brightness == Brightness.light
            ? MyThemes.lightThemeShadow
            : MyThemes.darkThemeShadow,
      ],
      color: Theme.of(context).colorScheme.containerDark,
      borderRadius: BorderRadius.circular(12),
    ),
    width: width ?? double.infinity,
    child: child,
  );
}