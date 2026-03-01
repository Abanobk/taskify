import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/activity_log/activity_log_bloc.dart';
import '../../bloc/activity_log/activity_log_event.dart';
import '../../bloc/clients/client_bloc.dart';
import '../../bloc/clients/client_event.dart';
import '../../bloc/meeting/meeting_bloc.dart';
import '../../bloc/meeting/meeting_event.dart';
import '../../bloc/notes/notes_bloc.dart';
import '../../bloc/notes/notes_event.dart';

import '../../bloc/notifications/system_notification/notification_bloc.dart';
import '../../bloc/notifications/system_notification/notification_event.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/permissions/permissions_state.dart';
import '../../bloc/setting/settings_bloc.dart';
import '../../bloc/setting/settings_event.dart';
import '../../bloc/todos/todos_bloc.dart';
import '../../bloc/todos/todos_event.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../data/localStorage/hive.dart';
import '../../routes/routes.dart';
import '../dash_board/dashboard.dart';


class SideBar extends StatefulWidget {
  final SlidableBarController? controller;
  final Widget? underWidget;
  final String? hasGuard;
  final BuildContext context;

  const SideBar({super.key, this.underWidget, this.hasGuard,this.controller,required this.context});
  @override
  State<SideBar> createState() => _SideBarState();

}

class _SideBarState extends State<SideBar> {
  String? userRole;
  bool _isSidebarVisible = false; // Track the visibility state
  @override
  void initState() {
    _getUserRole();
    super.initState();
  }
  Future<void> _getUserRole() async {
    final role = await HiveStorage.getRole();
    setState(() {
      userRole = role;
    });
  }
  @override
  Widget build(BuildContext context) {

    return SlidableBar(
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      duration: Duration(milliseconds: 50),
      clicker: Container(
        width: 50.w,
        height: 70.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.backGroundColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(70),
              bottomLeft: Radius.circular(70)
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 0.w),
          child: Tooltip(
            message: _isSidebarVisible ? "Hide Sidebar" : "Show Sidebar",
            child: IconButton(
              splashColor: Colors.transparent, // Disable the splash color
              highlightColor: Colors.transparent,
              icon: Icon(
                _isSidebarVisible ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                color: AppColors.greyColor, // Set the icon color
              ),
              onPressed: () {
                setState(() {
                  _isSidebarVisible = !_isSidebarVisible; // Toggle visibility state
                });
                if (_isSidebarVisible) {
                  widget.controller!.show(); // Show the sidebar
                } else {
                  widget.controller!.hide(); // Hide the sidebar
                }
              },
            ),
          ),
        ),
      ),
      frontColor: Colors.red,
      size: 60,
      slidableController: widget.controller,
      side: Side.right,
      clickerSize: 50.w,
      barChildren: [
        SizedBox(
            height: MediaQuery.of(context).size.height -
                60
                    .h, // Reduced by 30.h from top and bottomAdd padding to create space from top and bottom
            child: SingleChildScrollView(
              child:      BlocConsumer<PermissionsBloc, PermissionsState>(
                listener: (context, state) {
                  if (state is PermissionsSuccess) {}
                },
                builder: (context, state) {
                  return Column(
                    children: [
                      context.read<PermissionsBloc>().isManageProject == true
                          ? InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) =>
                              const DashBoard(initialIndex: 1),
                            ),
                          );
                        },
                        child: Tooltip(
                          message: "Projects",
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: const HeroIcon(
                              HeroIcons.wallet,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                      )
                          : const SizedBox.shrink(),
                      context.read<PermissionsBloc>().isManageTask == true
                          ? InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) =>
                              const DashBoard(initialIndex: 2),
                            ),
                          );
                        },
                        child: Tooltip(
                          message: "Tasks",
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: const HeroIcon(
                              size: 26,
                              HeroIcons.documentCheck,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                      )
                          : const SizedBox.shrink(),
                      context
                          .read<PermissionsBloc>()
                          .isManageSystemNotification ==
                          true
                          ? InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          router.push("/status");
                          context
                              .read<NotificationBloc>()
                              .add(NotificationList());
                          router.pop();
                        },
                        child: Tooltip(
                          message: "Status",
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: const HeroIcon(
                              HeroIcons.square2Stack,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                      )
                          : const SizedBox.shrink(),
                      context
                          .read<PermissionsBloc>()
                          .isManageSystemNotification ==
                          true
                          ? InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          router.push("/priorities");
                          context
                              .read<NotificationBloc>()
                              .add(NotificationList());
                          router.pop();
                        },
                        child: Tooltip(
                          message: "Priorities",
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: const HeroIcon(
                              HeroIcons.arrowUp,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                      )
                          : const SizedBox.shrink(),
                      context
                          .read<PermissionsBloc>()
                          .isManageSystemNotification ==
                          true
                          ? InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          router.push("/tags");
                          context
                              .read<NotificationBloc>()
                              .add(NotificationList());
                          router.pop();
                        },
                        child: Tooltip(
                          message: "Tags",
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: const HeroIcon(
                              HeroIcons.tag,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                      )
                          : const SizedBox.shrink(),
                      context.read<PermissionsBloc>().isManageWorkspace ==
                          true
                          ? InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          router.push('/workspaces',
                              extra: {"fromNoti": false});
                          router.pop();
                        },
                        child: Tooltip(
                          message: "Workspaces",
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: const HeroIcon(
                              HeroIcons.squares2x2,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                      )
                          : const SizedBox.shrink(),
                      context
                          .read<PermissionsBloc>()
                          .isManageSystemNotification ==
                          true
                          ? InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          router.push("/notification");
                          context
                              .read<NotificationBloc>()
                              .add(NotificationList());
                          router.pop();
                        },
                        child: Tooltip(
                          message: "Notifications",
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: const HeroIcon(
                              HeroIcons.bellAlert,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                      )
                          : const SizedBox.shrink(),
                      InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          context.read<TodosBloc>().add(const TodosList());
                          router.push("/todos");
                          router.pop();
                        },
                        child: Tooltip(
                          message: "To-Do List",
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: const HeroIcon(
                              HeroIcons.barsArrowUp,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                      ),
                      context.read<PermissionsBloc>().isManageClient == true
                          ? InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          router.push("/client");
                          BlocProvider.of<ClientBloc>(context)
                              .add(ClientList());
                          router.pop();
                        },
                        child: Tooltip(
                          message: "Clients",
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: const HeroIcon(
                              HeroIcons.userGroup,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                      )
                          : const SizedBox.shrink(),
                      context.read<PermissionsBloc>().isManageUser == true
                          ? InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          router.push('/user');
                          BlocProvider.of<UserBloc>(context)
                              .add(UserList());
                          router.pop();
                        },
                        child: Tooltip(
                          message: "Users",
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: const HeroIcon(
                              HeroIcons.users,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                      )
                          : const SizedBox.shrink(),
                      InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          context.read<NotesBloc>().add(const NotesList());
                          router.push('/notes');
                          router.pop();
                        },
                        child: Tooltip(
                          message: "Notes",
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: const HeroIcon(
                              HeroIcons.newspaper,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                      ),
                      userRole == "Client" || userRole == "client"
                          ? const SizedBox.shrink()
                          : InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          router.push('/leaverequest',
                              extra: {"fromNoti": false});
                          router.pop();
                        },
                        child: Tooltip(
                          message: "Leave Request",
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: const HeroIcon(
                              HeroIcons.arrowRightEndOnRectangle,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                      ),
                      context.read<PermissionsBloc>().isManageMeeting == true
                          ? InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          context
                              .read<MeetingBloc>()
                              .add(const MeetingLists());
                          router.push('/meetings',
                              extra: {"fromNoti": false});
                          router.pop();
                        },
                        child: Tooltip(
                          message: "Meetings",
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: const HeroIcon(
                              HeroIcons.camera,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                      )
                          : const SizedBox.shrink(),
                      context.read<PermissionsBloc>().isManageMeeting == true
                          ? InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          context
                              .read<MeetingBloc>()
                              .add(const MeetingLists());
                          router.push('/googlecalendar',
                              extra: {"fromNoti": false});
                          router.pop();
                        },
                        child: Tooltip(
                          message: "Google Calendar",
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: const HeroIcon(
                              HeroIcons.calendar,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                      )
                          : const SizedBox.shrink(),
                      context.read<PermissionsBloc>().isManageActivityLog ==
                          true
                          ? InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          router.push("/activitylog");
                          BlocProvider.of<ActivityLogBloc>(context)
                              .add(AllActivityLogList());
                          Navigator.pop(context);
                        },
                        child: Tooltip(
                          message: "Activity Log",
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: const HeroIcon(
                              HeroIcons.chartBar,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                      )
                          : const SizedBox.shrink(),
                      (context.read<PermissionsBloc>().isManageContract == true)
                          ? InkWell(
                        splashColor: Colors.transparent,
                  onTap: () async {
                  Navigator.pop(context); // Close Drawer first
                  router.push('/contract'); // Then navigate
                  },

                  child: Tooltip(
                          message: "Contracts",
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: const HeroIcon(
                              HeroIcons.clipboard,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                      )
                          : const SizedBox.shrink(),

                      context.read<PermissionsBloc>().isManagePayslip ==
                          true
                          ? InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {

                          router.push('/payslip');
                          router.pop(context);
                        },
                        child: Tooltip(
                          message: "Payslips",
                          child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: const HeroIcon(
                            HeroIcons.banknotes,
                            style: HeroIconStyle.outline,
                            color: AppColors.greyColor,
                          ),
                        ),
                      ))
                          : const SizedBox.shrink(),
                      userRole == "admin"
                          ? InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          router.push("/settings");
                          BlocProvider.of<SettingsBloc>(context)
                              .add(SettingsList('general_settings'));
                          Navigator.pop(context);
                        },
                        child: Tooltip(
                          message: "Settings",
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: const HeroIcon(
                              HeroIcons.cog6Tooth,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                      )
                          : const SizedBox.shrink(),
                      SizedBox(height: 70.h,)
                    ],
                  );
                },
              ),))
      ],
      child: widget.underWidget!,
    );
  }
}