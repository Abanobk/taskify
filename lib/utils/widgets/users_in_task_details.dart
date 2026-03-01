import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/utils/widgets/row_dashboard.dart';
import '../../bloc/theme/theme_state.dart';
import '../../config/constants.dart';
import '../../screens/widgets/user_client_box.dart';
import 'custom_text.dart';
import '../../bloc/theme/theme_bloc.dart';
import 'my_theme.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class TaskListDetails extends StatefulWidget {
  final List<dynamic> userList;
  final List<dynamic> clientList;
  final String? title;
  final String? startDate;
  final String? endDate;
  final double? width;
  final int? id;
  const TaskListDetails(
      {super.key,
      required this.clientList,
      required this.userList,
      this.startDate,
      this.endDate,
      this.id,
      this.title,
      this.width});

  @override
  State<TaskListDetails> createState() => _TaskListDetailsState();
}

class _TaskListDetailsState extends State<TaskListDetails> {
  String? startDate;
  String? endDate;
  @override
  Widget build(BuildContext context) {
    if (widget.startDate != null) {

      startDate = formatDateFromApi(widget.startDate??"", context);
      endDate = formatDateFromApi(widget.endDate??"", context);
    }
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Container(
          // height: 610.h,
          width: 400.w,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .containerDark, // Background color of the container
            borderRadius: BorderRadius.circular(17.4), // Rounded corners
            boxShadow: [
              isLightTheme
                  ? MyThemes.lightThemeShadow
                  : MyThemes.darkThemeShadow,
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: "#${widget.id.toString()}",
                  size: 14.sp,
                  color: Theme.of(context).colorScheme.textClrChange,
                  fontWeight: FontWeight.w700,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                widget.title == null
                    ? SizedBox.shrink()
                    : CustomText(
                        text: widget.title!,
                        size: 16.sp,
                        color: Theme.of(context).colorScheme.textClrChange),
                widget.userList.isEmpty && widget.userList.isEmpty
                    ? SizedBox.shrink()
                    : Padding(
                        padding: EdgeInsets.only(top: 10.h),
                        child: SizedBox(
                          height: 60.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: InkWell(
                                    onTap: () {
                                      userClientDialog(
                                        from: 'user',
                                        context: context,
                                        title: AppLocalizations.of(context)!
                                            .allusers,
                                        list:
                                            widget.userList.isEmpty
                                                ? []
                                                :  widget.userList,
                                      );
                                    },
                                    child: RowDashboard(
                                        list: widget.userList, title: "user")),
                              ),
                              widget.clientList.isEmpty
                                  ? const SizedBox.shrink()
                                  : SizedBox(
                                      width: 40.w,
                                    ),
                              widget.clientList.isEmpty
                                  ? const SizedBox.shrink()
                                  : Expanded(
                                      child: InkWell(
                                          onTap: () {
                                            userClientDialog(
                                              from: 'client',
                                              title:
                                                  AppLocalizations.of(context)!
                                                      .allclients,
                                              list:
                                                  widget.clientList.isEmpty
                                                      ? []
                                                      : widget.clientList,
                                              context: context,
                                            );
                                          },
                                          child: RowDashboard(
                                              list: widget.clientList,
                                              title: "client")),
                                    )
                            ],
                          ),
                        )),
                widget.startDate != null
                    ? Padding(
                        padding: EdgeInsets.only(top: 5.h),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 15.w,
                              // color: Colors.yellow,
                              child: const HeroIcon(
                                HeroIcons.calendar,
                                style: HeroIconStyle.outline,
                                color: AppColors.blueColor,
                              ),
                            ),
                            SizedBox(
                              width: 5.w,
                            ),
                            CustomText(
                              text: startDate ?? "",
                              size: 12.26,
                              fontWeight: FontWeight.w300,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                            )
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          )),
    );
  }
}
