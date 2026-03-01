import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../bloc/project/project_bloc.dart';
import '../../../bloc/project/project_event.dart';
import '../../../bloc/task/task_bloc.dart';
import '../../../bloc/task/task_event.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../routes/routes.dart';
import '../../../utils/widgets/back_arrow.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../notes/widgets/notes_shimmer_widget.dart';

class LoadingWidget extends StatelessWidget {
  final String title;
  const LoadingWidget({super.key,required this.title});

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return Scaffold(
      backgroundColor:
      Theme.of(context).colorScheme.backGroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: 20.w, right: 20.w, top: 0.h),
                    child: Column(
                      children: [
                        Container(
                            decoration: BoxDecoration(boxShadow: [
                              isLightTheme
                                  ? MyThemes.lightThemeShadow
                                  : MyThemes.darkThemeShadow,
                            ]),
                            // color: Colors.red,
                            // width: 300.w,
                            child: InkWell(
                              onTap: () {
                                router.pop();

                                BlocProvider.of<ProjectBloc>(
                                    context)
                                    .add(ProjectDashBoardList());
                                BlocProvider.of<TaskBloc>(context)
                                    .add(AllTaskListOnTask());
                              },
                              child: BackArrow(
                                title: title,
                              ),
                            )),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 30.h),
              shimmerAvatarDetails(
                isLightTheme,
                context,
              ),
              const SizedBox(
                height: 20,
              ),
              shimmerDetails(isLightTheme, context, 150.h),
              const SizedBox(
                height: 20,
              ),
              shimmerDetails(isLightTheme, context, 150.h),
              const SizedBox(
                height: 20,
              ),
              shimmerDetails(isLightTheme, context, 50.h),
              const SizedBox(
                height: 20,
              ),
              shimmerDetails(isLightTheme, context, 120.h),
              const SizedBox(
                height: 20,
              ),
              shimmerDetails(isLightTheme, context, 120.h),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
