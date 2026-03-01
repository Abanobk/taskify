import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:heroicons/heroicons.dart';
import 'package:shimmer/shimmer.dart';

import '../../../bloc/workspace/workspace_bloc.dart';
import '../../../bloc/workspace/workspace_state.dart';
import '../../../config/colors.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../widgets/workspace_dialog.dart';

class CurrentWorkspace extends StatelessWidget {
  final bool isLightTheme;
  final String? workSpaceTitle;

  const CurrentWorkspace({
    super.key,
    required this.isLightTheme,
    this.workSpaceTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: BlocConsumer<WorkspaceBloc, WorkspaceState>(
        listener: (context, state) {
          if (state is WorkspacePaginated) {}
        },
        builder: (context, state) {
          if (state is WorkspacePaginated) {
            return InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return WorkSpaceDialog(
                      work: state.workspace,
                      isDashboard: true,
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    isLightTheme
                        ? MyThemes.lightThemeShadow
                        : MyThemes.darkThemeShadow,
                  ],
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                width: double.infinity,
                height: 50.h,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: workSpaceTitle ?? "",
                          color: AppColors.pureWhiteColor,
                          size: 15.sp,
                          fontWeight: FontWeight.w800,
                        ),
                        const HeroIcon(
                          HeroIcons.chevronRight,
                          style: HeroIconStyle.outline,
                          color: AppColors.pureWhiteColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          if (state is WorkspaceLoading) {
            return Shimmer.fromColors(
              baseColor: isLightTheme == true
                  ? Colors.grey[100]!
                  : Colors.grey[600]!,
              highlightColor: isLightTheme == false
                  ? Colors.grey[800]!
                  : Colors.grey[300]!,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    isLightTheme
                        ? MyThemes.lightThemeShadow
                        : MyThemes.darkThemeShadow,
                  ],
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                width: double.infinity,
                height: 50.h,
              ),
            );
          }
          if (state is WorkspaceError) {
            flutterToastCustom(
              msg: state.errorMessage,
              color: Colors.red,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
} 