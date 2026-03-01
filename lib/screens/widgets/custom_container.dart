import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/colors.dart';

import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../utils/widgets/my_theme.dart';

Widget customContainer(
    {required Widget addWidget, required BuildContext context, double? width,double? height}) {
  final themeBloc = context.read<ThemeBloc>();
  final currentTheme = themeBloc.currentThemeState;

  bool isLightTheme = currentTheme is LightThemeState;
  return Container(
      height: height ,
      width: width ?? 400.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17.4),
        boxShadow: [
          isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
        ],
        color: Theme.of(context).colorScheme.containerDark,
      ),
      child: addWidget);
}
