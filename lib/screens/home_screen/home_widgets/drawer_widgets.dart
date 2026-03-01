import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:heroicons/heroicons.dart';

import '../../../bloc/notifications/system_notification/notification_bloc.dart';
import '../../../bloc/notifications/system_notification/notification_event.dart';
import '../../../bloc/notifications/system_notification/notification_state.dart';
import '../../../bloc/workspace/workspace_bloc.dart';
import '../../../bloc/workspace/workspace_state.dart';
import '../../../bloc/user_profile/user_profile_bloc.dart';
import '../../../bloc/user_profile/user_profile_state.dart';
import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/permissions/permissions_state.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/notes/notes_bloc.dart';
import '../../../bloc/notes/notes_event.dart';
import '../../../bloc/todos/todos_bloc.dart';
import '../../../bloc/todos/todos_event.dart';
import '../../../bloc/clients/client_bloc.dart';
import '../../../bloc/clients/client_event.dart';
import '../../../bloc/user/user_bloc.dart';
import '../../../bloc/user/user_event.dart';
import '../../../bloc/leave_request/leave_request_bloc.dart';
import '../../../bloc/leave_request/leave_request_event.dart';
import '../../../bloc/meeting/meeting_bloc.dart';
import '../../../bloc/meeting/meeting_event.dart';
import '../../../bloc/activity_log/activity_log_bloc.dart';
import '../../../bloc/activity_log/activity_log_event.dart';
import '../../../bloc/setting/settings_bloc.dart';
import '../../../bloc/setting/settings_event.dart';
import '../../../config/colors.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../routes/routes.dart';
import '../../dash_board/dashboard.dart';
import '../widgets/workspace_dialog.dart';

class DrawerWidgets extends StatefulWidget {
  final bool isExpand;
  final Function(bool) toggleDrawer;
  final int? statusPending;
  final String? firstNameUser;
  final String? lastNameUSer;
  final String? email;
  final String? roleInUser;
  final String? photoWidget;
  final String? role;

  DrawerWidgets({
    super.key,
    required this.isExpand,
    required this.toggleDrawer,
    this.statusPending,
    this.firstNameUser,
    this.lastNameUSer,
    this.email,
    this.roleInUser,
    this.photoWidget,
    this.role,
  });

  @override
  State<DrawerWidgets> createState() => _DrawerWidgetsState();
}

class _DrawerWidgetsState extends State<DrawerWidgets> {
  bool isExpanded = false;
  bool isExpandedContract = false;
  bool isExpandedPayslip = false;
  bool isExpandedHrms = false;
  bool isExpandedLeads = false;
  String? firstNameUser;
  String? lastNameUSer;
  String? email;
  String? roleInUser;
  String? photoWidget;
  String? role;

  @override
  void initState() {
    super.initState();
    // Initialize state with initial data from widget if any
    firstNameUser = widget.firstNameUser ?? "First Name";
    lastNameUSer = widget.lastNameUSer ?? "Last Name";
    email = widget.email ?? "Email";
    roleInUser = widget.roleInUser;
    photoWidget = widget.photoWidget;
    role = widget.role;
  }

  @override
  Widget build(BuildContext context) {
    return widget.isExpand ? _drawerIn(context) : _expandedDrawer(context);
  }

  Widget _drawerIn(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20.0),
        bottomRight: Radius.circular(20.0),
      ),
      child: Container(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        height: 680.h,
        child: Drawer(
          elevation: 0,
          width: 62.w,
          backgroundColor: Theme.of(context).colorScheme.bgColorChange,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BlocConsumer<WorkspaceBloc, WorkspaceState>(
                  listener: (context, state) {
                    if (state is WorkspacePaginated) {}
                  },
                  builder: (context, state) {
                    if (state is WorkspacePaginated) {
                      return InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
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
                        child: Padding(
                          padding: EdgeInsets.only(top: 20.h),
                          child: HeroIcon(
                            HeroIcons.square3Stack3d,
                            style: HeroIconStyle.outline,
                            color: AppColors.greyColor,
                            size: 20.sp,
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: EdgeInsets.only(top: 30.h),
                      child: SizedBox(
                        child: HeroIcon(
                          HeroIcons.square3Stack3d,
                          style: HeroIconStyle.outline,
                          color: AppColors.greyColor,
                          size: 20.sp,
                        ),
                      ),
                    );
                  },
                ),
                const Divider(),
                SizedBox(
                  height: 0.h,
                ),
                BlocConsumer<UserProfileBloc, UserProfileState>(
                  listener: (context, state) {
                    if (state is UserProfileSuccess) {
                      for (var data in state.profile) {
                        firstNameUser = data.firstName ?? "First Name";
                        lastNameUSer = data.lastName ?? "LastName";
                        email = data.email ?? "Email";
                        roleInUser = data.roleId.toString();
                        photoWidget = data.profile ?? "Photo";
                        role = data.role ?? "Role";
                      }
                    } else if (state is UserProfileError) {}
                  },
                  builder: (context, state) {
                    if (state is UserProfileSuccess) {
                      firstNameUser =
                          context.read<UserProfileBloc>().firstname ??
                              "First Name";
                      lastNameUSer = context.read<UserProfileBloc>().lastName ??
                          "LastName";
                      email = context.read<UserProfileBloc>().email ?? "Email";
                      roleInUser =
                          context.read<UserProfileBloc>().roleId.toString();
                      photoWidget =
                          context.read<UserProfileBloc>().profilePic ?? "Photo";
                      role = context.read<UserProfileBloc>().role ?? "Role";

                      return widget.photoWidget == null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 68),
                              child: SizedBox(
                                width: 30.w,
                                child: CircleAvatar(
                                  radius: 21.r,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                  child: CircleAvatar(
                                    radius: 20.r,
                                    backgroundColor: Colors.grey[200],
                                  ),
                                ),
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.only(top: 0.h),
                              child: SizedBox(
                                width: 30.w,
                                child: CircleAvatar(
                                  radius: 25.r,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                  child: widget.photoWidget != null
                                      ? CircleAvatar(
                                          radius: 20.r,
                                          backgroundImage:
                                              NetworkImage(widget.photoWidget!),
                                          backgroundColor: Colors.grey[200],
                                        )
                                      : CircleAvatar(
                                          radius: 20.r,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .backGroundColor,
                                          child: CircleAvatar(
                                            radius: 20.r,
                                            backgroundColor: Colors.grey[200],
                                            child: Icon(
                                              Icons.person,
                                              size: 20.sp,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: SizedBox(
                        width: 50.w,
                        child: CircleAvatar(
                          radius: 26.r,
                          backgroundColor:
                              Theme.of(context).colorScheme.backGroundColor,
                          child: CircleAvatar(
                            radius: 25.r,
                            backgroundColor: Colors.grey[200],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 15.h,
                ),
                BlocConsumer<PermissionsBloc, PermissionsState>(
                  listener: (context, state) {
                    if (state is PermissionsSuccess) {}
                  },
                  builder: (context, state) {
                    return Column(
                      children: [
                        context.read<PermissionsBloc>().isManageProject == true
                            ? InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) =>
                                          const DashBoard(initialIndex: 1),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.wallet,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        context.read<PermissionsBloc>().isManageTask == true
                            ? InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) =>
                                          const DashBoard(initialIndex: 2),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    size: 26,
                                    HeroIcons.documentCheck,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
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
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  router.push("/Status");
                                  // widget.toggleDrawer(false);
                                  // GoRouter.of(context).pushNamed('StatusScreen');
                                  // router.push("/status");
                                  context
                                      .read<NotificationBloc>()
                                      .add(NotificationList());
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.square2Stack,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
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
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  router.push("/priorities");
                                  context
                                      .read<NotificationBloc>()
                                      .add(NotificationList());
                                  router.pop();
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.arrowUp,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
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
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  router.push("/tags");
                                  context
                                      .read<NotificationBloc>()
                                      .add(NotificationList());
                                  router.pop();
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.tag,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        context.read<PermissionsBloc>().isManageWorkspace ==
                                true
                            ? InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  router.push('/workspaces',
                                      extra: {"fromNoti": false});
                                  router.pop();
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.squares2x2,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
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
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  router.push("/notification");
                                  context
                                      .read<NotificationBloc>()
                                      .add(NotificationList());
                                  router.pop();
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.bellAlert,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        context.read<PermissionsBloc>().isManageLeads == true
                            ? InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  router.push('/leads');
                                  router.pop();
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.phone,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            context.read<TodosBloc>().add(const TodosList());
                            router.push("/todos");
                            router.pop();
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: const HeroIcon(
                              HeroIcons.barsArrowUp,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                        context.read<PermissionsBloc>().isManageClient == true
                            ? InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  router.push("/client");
                                  BlocProvider.of<ClientBloc>(context)
                                      .add(ClientList());
                                  router.pop();
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.userGroup,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        context.read<PermissionsBloc>().isManageUser == true
                            ? InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  router.push('/user');
                                  BlocProvider.of<UserBloc>(context)
                                      .add(UserList());
                                  router.pop();
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.users,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            context.read<NotesBloc>().add(const NotesList());
                            router.push('/notes');
                            router.pop();
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: const HeroIcon(
                              HeroIcons.newspaper,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                        widget.role == "Client" || widget.role == "client"
                            ? const SizedBox.shrink()
                            : InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  router.push('/leaverequest',
                                      extra: {"fromNoti": false});
                                  router.pop();
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.arrowRightEndOnRectangle,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              ),
                        context.read<PermissionsBloc>().isManageMeeting == true
                            ? InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  context
                                      .read<MeetingBloc>()
                                      .add(const MeetingLists());
                                  router.push('/meetings',
                                      extra: {"fromNoti": false});
                                  router.pop();
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.camera,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        context.read<PermissionsBloc>().isManageMeeting == true
                            ? InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  context
                                      .read<MeetingBloc>()
                                      .add(const MeetingLists());
                                  router.push('/googlecalendar',
                                      extra: {"fromNoti": false});
                                  router.pop();
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.calendar,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        context.read<PermissionsBloc>().isManageActivityLog ==
                                true
                            ? InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  router.push("/activitylog");
                                  BlocProvider.of<ActivityLogBloc>(context)
                                      .add(AllActivityLogList());
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.chartBar,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        context.read<PermissionsBloc>().isManageContract == true
                            ? InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  router.push('/contract');
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.clipboard,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        context.read<PermissionsBloc>().isManagePayslip == true
                            ? InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  router.push('/payslip');
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.banknotes,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        widget.role == "admin"
                            ? InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  router.push("/settings");
                                  BlocProvider.of<SettingsBloc>(context)
                                      .add(SettingsList('general_settings'));
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.cog6Tooth,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    );
                  },
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    BlocProvider.of<AuthBloc>(context).add(LoggedOut(
                      context: context,
                    ));
                    router.pop();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: const HeroIcon(
                      HeroIcons.arrowLeftStartOnRectangle,
                      style: HeroIconStyle.outline,
                      color: AppColors.greyColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    widget.toggleDrawer(!widget.isExpand);
                  },
                  child: widget.isExpand
                      ? Container(
                          height: 30.h,
                          width: 30.w,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: AppColors.primary),
                          child: const HeroIcon(
                            size: 15,
                            HeroIcons.arrowRight,
                            style: HeroIconStyle.solid,
                            color: AppColors.pureWhiteColor,
                          ))
                      : Container(),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _expandedDrawer(BuildContext context) {
    BlocProvider.of<LeaveRequestBloc>(context)
        .add(const GetPendingLeaveRequest());
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20.0),
        bottomRight: Radius.circular(20.0),
      ),
      child: Drawer(
        elevation: 0,
        width: 270.w,
        backgroundColor: Theme.of(context).colorScheme.bgColorChange,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20.h,
                ),
                BlocConsumer<UserProfileBloc, UserProfileState>(
                  listener: (context, state) {
                    if (state is UserProfileSuccess) {
                      for (var data in state.profile) {
                        firstNameUser = data.firstName ?? "First Name";
                        lastNameUSer = data.lastName ?? "LastName";
                        email = data.email ?? "Email";
                        roleInUser = data.roleId.toString();
                        photoWidget = data.profile ?? "Photo";
                        role = data.role ?? "Role";
                      }
                    } else if (state is UserProfileError) {}
                  },
                  builder: (context, state) {
                    if (state is UserProfileSuccess) {
                      firstNameUser =
                          context.read<UserProfileBloc>().firstname ??
                              "First Name";
                      lastNameUSer = context.read<UserProfileBloc>().lastName ??
                          "LastName";
                      email = context.read<UserProfileBloc>().email ?? "Email";
                      roleInUser =
                          context.read<UserProfileBloc>().roleId.toString();
                      photoWidget =
                          context.read<UserProfileBloc>().profilePic ?? "Photo";
                      role = context.read<UserProfileBloc>().role ?? "Role";
                      print(
                          "firstNameUser ${context.read<UserProfileBloc>().profilePic}");
                      return widget.photoWidget == null
                          ? Padding(
                              padding: EdgeInsets.only(top: 30.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    // width: 30.w,
                                    child: CircleAvatar(
                                      radius: 26.r,
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .backGroundColor,
                                      child: CircleAvatar(
                                        radius: 25.r,
                                        backgroundColor: Colors.grey[200],
                                        backgroundImage: NetworkImage(context
                                            .read<UserProfileBloc>()
                                            .profilePic!),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  firstNameUser != null
                                      ? CustomText(
                                          text:
                                              "${firstNameUser} ${lastNameUSer}",
                                          color: Theme.of(context)
                                              .colorScheme
                                              .textClrChange,
                                        )
                                      : SizedBox(),
                                  email != null
                                      ? CustomText(
                                          text: email ?? "",
                                          size: 12,
                                          color: AppColors.greyColor,
                                        )
                                      : SizedBox()
                                ],
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.only(top: 30.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    // width: 30.w,
                                    child: CircleAvatar(
                                      radius: 26.r,
                                      backgroundColor: AppColors.greyColor,
                                      child: widget.photoWidget != null
                                          ? CircleAvatar(
                                              radius: 25.r,
                                              backgroundImage: NetworkImage(
                                                  widget.photoWidget!),
                                              backgroundColor: Colors.grey[200],
                                            )
                                          : CircleAvatar(
                                              radius: 25.r,
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .backGroundColor,
                                              child: CircleAvatar(
                                                radius: 25.r,
                                                backgroundColor:
                                                    Colors.grey[200],
                                                child: Icon(
                                                  Icons.person,
                                                  size: 20.sp,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  firstNameUser != null
                                      ? CustomText(
                                          text:
                                              "${firstNameUser} ${lastNameUSer}",
                                          color: Theme.of(context)
                                              .colorScheme
                                              .textClrChange,
                                        )
                                      : SizedBox(),
                                  email != null
                                      ? CustomText(
                                          text: email ?? "",
                                          size: 12,
                                          color: AppColors.greyColor,
                                        )
                                      : SizedBox()
                                ],
                              ),
                            );
                    }
                    return Padding(
                      padding: EdgeInsets.only(top: 30.h),
                      child: SizedBox(
                        // width: 26.w,
                        child: CircleAvatar(
                          radius: 26.r,
                          backgroundColor: AppColors.greyColor,
                          child: CircleAvatar(
                            radius: 25.r,
                            backgroundColor: Colors.grey[200],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 12.h,
                ),
                BlocConsumer<PermissionsBloc, PermissionsState>(
                  listener: (context, state) {
                    if (state is PermissionsSuccess) {}
                  },
                  builder: (context, state) {
                    if (state is PermissionsInitial) {}
                    if (state is PermissionsSuccess) {
                      return SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            context.read<PermissionsBloc>().isManageProject ==
                                    true
                                ? InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      widget.toggleDrawer(false);
                                      Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (context) =>
                                              const DashBoard(initialIndex: 1),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.h),
                                      child: Row(
                                        children: [
                                          const HeroIcon(
                                            HeroIcons.wallet,
                                            style: HeroIconStyle.outline,
                                            color: AppColors.greyColor,
                                          ),
                                          SizedBox(
                                            width: 20.w,
                                          ),
                                          CustomText(
                                            text: AppLocalizations.of(context)!
                                                .projects,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .textClrChange,
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            context.read<PermissionsBloc>().isManageTask == true
                                ? InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      widget.toggleDrawer(false);
                                      Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (context) =>
                                              const DashBoard(initialIndex: 2),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.h),
                                      child: Row(
                                        children: [
                                          const HeroIcon(
                                            size: 26,
                                            HeroIcons.documentCheck,
                                            style: HeroIconStyle.outline,
                                            color: AppColors.greyColor,
                                          ),
                                          SizedBox(
                                            width: 20.w,
                                          ),
                                          CustomText(
                                            text: AppLocalizations.of(context)!
                                                .tasksFromDrawer,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .textClrChange,
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            context.read<PermissionsBloc>().isManageStatus ==
                                    true
                                ? InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      router.push("/Status");
                                      // widget.toggleDrawer(false);
                                      Navigator.pop(context);
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.h),
                                      child: Row(
                                        children: [
                                          const HeroIcon(
                                            size: 26,
                                            HeroIcons.square2Stack,
                                            style: HeroIconStyle.outline,
                                            color: AppColors.greyColor,
                                          ),
                                          SizedBox(
                                            width: 20.w,
                                          ),
                                          CustomText(
                                            text: AppLocalizations.of(context)!
                                                .statuses,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .textClrChange,
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            context.read<PermissionsBloc>().isManagePriority ==
                                    true
                                ? InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      // widget.toggleDrawer(false);
                                      router.push("/priorities");
                                      Navigator.pop(context);
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.h),
                                      child: Row(
                                        children: [
                                          const HeroIcon(
                                            size: 26,
                                            HeroIcons.arrowUp,
                                            style: HeroIconStyle.outline,
                                            color: AppColors.greyColor,
                                          ),
                                          SizedBox(
                                            width: 20.w,
                                          ),
                                          CustomText(
                                            text: AppLocalizations.of(context)!
                                                .priorities,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .textClrChange,
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            context.read<PermissionsBloc>().isManageTags == true
                                ? InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      // widget.toggleDrawer(false);
                                      router.push("/tags");
                                      Navigator.pop(context);
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.h),
                                      child: Row(
                                        children: [
                                          const HeroIcon(
                                            size: 26,
                                            HeroIcons.tag,
                                            style: HeroIconStyle.outline,
                                            color: AppColors.greyColor,
                                          ),
                                          SizedBox(
                                            width: 20.w,
                                          ),
                                          CustomText(
                                            text: AppLocalizations.of(context)!
                                                .tags,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .textClrChange,
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            context.read<PermissionsBloc>().isManageWorkspace ==
                                    true
                                ? InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      // widget.toggleDrawer(false);
                                      router.push('/workspaces',
                                          extra: {"fromNoti": false});
                                      router.pop();
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.h),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const HeroIcon(
                                                HeroIcons.squares2x2,
                                                style: HeroIconStyle.outline,
                                                color: AppColors.greyColor,
                                              ),
                                              SizedBox(
                                                width: 20.w,
                                              ),
                                              CustomText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .workspaceFromDrawer,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .textClrChange,
                                              ),
                                            ],
                                          ),
                                          Container(
                                            height: 20,
                                            width: 20,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red.shade300,
                                            ),
                                            child: Center(
                                                child: CustomText(
                                              size: 10,
                                              fontWeight: FontWeight.w600,
                                              text:
                                                  "${context.read<WorkspaceBloc>().totalWorkspace ?? 0}",
                                              color: AppColors.pureWhiteColor,
                                            )),
                                          )
                                        ],
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
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      // widget.toggleDrawer(false);
                                      router.push("/notification");
                                      context
                                          .read<NotificationBloc>()
                                          .add(NotificationList());
                                      router.pop();
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.h),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const HeroIcon(
                                                HeroIcons.bellAlert,
                                                style: HeroIconStyle.outline,
                                                color: AppColors.greyColor,
                                              ),
                                              SizedBox(
                                                width: 20.w,
                                              ),
                                              CustomText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .notifications,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .textClrChange,
                                              )
                                            ],
                                          ),
                                          BlocConsumer<NotificationBloc,
                                                  NotificationsState>(
                                              listener: (context, state) {
                                            if (state
                                                is NotificationPaginated) {}
                                          }, builder: (context, state) {
                                            if (state is UnreadNotification) {
                                              return Container(
                                                height: 20,
                                                width: 20,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.yellow.shade800,
                                                ),
                                                child: Center(
                                                    child: CustomText(
                                                  size: 10.sp,
                                                  fontWeight: FontWeight.w600,
                                                  text: "${state.total}",
                                                  color:
                                                      AppColors.pureWhiteColor,
                                                )),
                                              );
                                            }
                                            return SizedBox();
                                          })
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      );
                    }
                    return SizedBox();
                  },
                ),
                context.read<PermissionsBloc>().isManageLeads == true
                    ? InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            isExpandedLeads = !isExpandedLeads;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const HeroIcon(
                                        HeroIcons.phone,
                                        style: HeroIconStyle.outline,
                                        color: AppColors.greyColor,
                                      ),
                                      SizedBox(width: 20.w),
                                      CustomText(
                                        text: AppLocalizations.of(context)!
                                            .leadsmanagement,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textClrChange,
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    isExpandedLeads
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 20.sp,
                                    color: AppColors.greyColor,
                                  ),
                                ],
                              ),
                              isExpandedLeads
                                  ? SizedBox(height: 10.h)
                                  : SizedBox(),
                              if (isExpandedLeads)
                                Padding(
                                  padding: const EdgeInsets.only(left: 40.0),
                                  child: Column(
                                    children: [
                                      InkWell(
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        onTap: () {
                                          // widget.toggleDrawer(false);
                                          router.push('/leadSource');
                                          router.pop();
                                        },
                                        child: _buildFinanceItem(
                                            AppLocalizations.of(context)!
                                                .leadsource,
                                            context),
                                      ),
                                      InkWell(
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        onTap: () {
                                          // widget.toggleDrawer(false);
                                          router.push('/leadstage');
                                          router.pop();
                                        },
                                        child: _buildFinanceItem(
                                            AppLocalizations.of(context)!
                                                .leadstages,
                                            context),
                                      ),
                                      InkWell(
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        onTap: () {
                                          // widget.toggleDrawer(false);
                                          router.push('/leads');
                                          router.pop();
                                        },
                                        child: _buildFinanceItem(
                                            AppLocalizations.of(context)!.leads,
                                            context),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    // widget.toggleDrawer(false);
                    router.push("/todos");
                    BlocProvider.of<TodosBloc>(context).add(TodosList());
                    router.pop();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Row(
                      children: [
                        const HeroIcon(
                          HeroIcons.barsArrowUp,
                          style: HeroIconStyle.outline,
                          color: AppColors.greyColor,
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        CustomText(
                          text: AppLocalizations.of(context)!.todos,
                          color: Theme.of(context).colorScheme.textClrChange,
                        )
                      ],
                    ),
                  ),
                ),
                context.read<PermissionsBloc>().isManageClient == true
                    ? InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          // widget.toggleDrawer(false);
                          router.push("/client");
                          BlocProvider.of<ClientBloc>(context)
                              .add(ClientList());
                          router.pop();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Row(
                            children: [
                              const HeroIcon(
                                HeroIcons.userGroup,
                                style: HeroIconStyle.outline,
                                color: AppColors.greyColor,
                              ),
                              SizedBox(
                                width: 20.w,
                              ),
                              CustomText(
                                text: AppLocalizations.of(context)!
                                    .clientsFordrawer,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                              )
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                context.read<PermissionsBloc>().isManageUser == true
                    ? InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          // widget.toggleDrawer(false);
                          router.push('/user');
                          BlocProvider.of<UserBloc>(context).add(UserList());
                          router.pop();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Row(
                            children: [
                              const HeroIcon(
                                HeroIcons.users,
                                style: HeroIconStyle.outline,
                                color: AppColors.greyColor,
                              ),
                              SizedBox(
                                width: 20.w,
                              ),
                              CustomText(
                                text: AppLocalizations.of(context)!
                                    .usersFordrawer,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                              )
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    // widget.toggleDrawer(false);
                    context.read<NotesBloc>().add(const NotesList());
                    router.push('/notes');
                    router.pop();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Row(
                      children: [
                        const HeroIcon(
                          HeroIcons.newspaper,
                          style: HeroIconStyle.outline,
                          color: AppColors.greyColor,
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        CustomText(
                          text: AppLocalizations.of(context)!.notes,
                          color: Theme.of(context).colorScheme.textClrChange,
                        )
                      ],
                    ),
                  ),
                ),
                widget.role == "Client" || widget.role == "client"
                    ? SizedBox.shrink()
                    : InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          // widget.toggleDrawer(false);
                          router.push('/leaverequest',
                              extra: {"fromNoti": false});
                          router.pop();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const HeroIcon(
                                    HeroIcons.arrowRightEndOnRectangle,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                  SizedBox(
                                    width: 20.w,
                                  ),
                                  CustomText(
                                    text: AppLocalizations.of(context)!
                                        .leaverequestsDrawer,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                  ),
                                ],
                              ),
                              Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.yellow.shade800,
                                ),
                                child: Center(
                                    child: CustomText(
                                  size: 10,
                                  fontWeight: FontWeight.w600,
                                  text: "${widget.statusPending ?? 0}",
                                  color: AppColors.pureWhiteColor,
                                )),
                              )
                            ],
                          ),
                        ),
                      ),
                context.read<PermissionsBloc>().isManageMeeting == true
                    ? InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          // widget.toggleDrawer(false);
                          context.read<MeetingBloc>().add(const MeetingLists());
                          router.push('/meetings', extra: {"fromNoti": false});
                          router.pop();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Row(
                            children: [
                              const HeroIcon(
                                HeroIcons.camera,
                                style: HeroIconStyle.outline,
                                color: AppColors.greyColor,
                              ),
                              SizedBox(
                                width: 20.w,
                              ),
                              CustomText(
                                text: AppLocalizations.of(context)!.meetings,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                              )
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                widget.role == "admin" ||
                        context.read<PermissionsBloc>().isManageInterview ==
                            true ||
                        context.read<PermissionsBloc>().isManageCandidate ==
                            true ||
                        context
                                .read<PermissionsBloc>()
                                .isManageCandidateStatus ==
                            true
                    ? InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            isExpandedHrms = !isExpandedHrms;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const HeroIcon(
                                        HeroIcons.briefcase,
                                        style: HeroIconStyle.outline,
                                        color: AppColors.greyColor,
                                      ),
                                      SizedBox(width: 20.w),
                                      CustomText(
                                        text:
                                            AppLocalizations.of(context)!.hrms,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textClrChange,
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    isExpandedHrms
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 20.sp,
                                    color: AppColors.greyColor,
                                  ),
                                ],
                              ),
                              isExpandedHrms
                                  ? SizedBox(height: 10.h)
                                  : SizedBox(),
                              if (isExpandedHrms)
                                Padding(
                                  padding: const EdgeInsets.only(left: 40.0),
                                  child: Column(
                                    children: [
                                      context
                                                  .read<PermissionsBloc>()
                                                  .isManageCandidate ==
                                              true
                                          ? InkWell(
                                              highlightColor:
                                                  Colors.transparent,
                                              splashColor: Colors.transparent,
                                              onTap: () {
                                                // widget.toggleDrawer(false);
                                                router.push('/candidates');
                                                router.pop();
                                              },
                                              child: _buildFinanceItem(
                                                  AppLocalizations.of(context)!
                                                      .candidates,
                                                  context),
                                            )
                                          : SizedBox.shrink(),
                                      context
                                                  .read<PermissionsBloc>()
                                                  .isManageCandidateStatus ==
                                              true
                                          ? InkWell(
                                              highlightColor:
                                                  Colors.transparent,
                                              splashColor: Colors.transparent,
                                              onTap: () {
                                                // widget.toggleDrawer(false);
                                                router.push('/candidatestatus');
                                                router.pop();
                                              },
                                              child: _buildFinanceItem(
                                                  AppLocalizations.of(context)!
                                                      .candidatestatus,
                                                  context),
                                            )
                                          : SizedBox(),
                                      context
                                                  .read<PermissionsBloc>()
                                                  .isManageInterview ==
                                              true
                                          ? InkWell(
                                              highlightColor:
                                                  Colors.transparent,
                                              splashColor: Colors.transparent,
                                              onTap: () {
                                                // widget.toggleDrawer(false);
                                                router.push('/interviews');
                                                router.pop();
                                              },
                                              child: _buildFinanceItem(
                                                  AppLocalizations.of(context)!
                                                      .interviews,
                                                  context),
                                            )
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    // widget.toggleDrawer(false);
                    router.push('/googlecalendar');
                    router.pop();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Row(
                      children: [
                        const HeroIcon(
                          HeroIcons.calendar,
                          style: HeroIconStyle.outline,
                          color: AppColors.greyColor,
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        CustomText(
                          text: AppLocalizations.of(context)!.calendar,
                          color: Theme.of(context).colorScheme.textClrChange,
                        )
                      ],
                    ),
                  ),
                ),
                context.read<PermissionsBloc>().isManageActivityLog == true
                    ? InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          // widget.toggleDrawer(false);
                          router.push("/activitylog");
                          BlocProvider.of<ActivityLogBloc>(context)
                              .add(AllActivityLogList());
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Row(
                            children: [
                              const HeroIcon(
                                HeroIcons.chartBar,
                                style: HeroIconStyle.outline,
                                color: AppColors.greyColor,
                              ),
                              SizedBox(
                                width: 20.w,
                              ),
                              CustomText(
                                text:
                                    AppLocalizations.of(context)!.activitylogs,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                              )
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                widget.role == "admin"
                    ? InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const HeroIcon(
                                        HeroIcons.banknotes,
                                        style: HeroIconStyle.outline,
                                        color: AppColors.greyColor,
                                      ),
                                      SizedBox(width: 20.w),
                                      CustomText(
                                        text: AppLocalizations.of(context)!
                                            .finance,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textClrChange,
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 20.sp,
                                    color: AppColors.greyColor,
                                  ),
                                ],
                              ),
                              isExpanded ? SizedBox(height: 10.h) : SizedBox(),
                              if (isExpanded)
                                Padding(
                                  padding: const EdgeInsets.only(left: 40.0),
                                  child: Column(
                                    children: [
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          // widget.toggleDrawer(false);
                                          router.push('/expense');
                                          Navigator.pop(context);
                                        },
                                        child: _buildFinanceItem(
                                            AppLocalizations.of(context)!
                                                .expenses,
                                            context),
                                      ),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          // widget.toggleDrawer(false);
                                          router.push('/expensetype');
                                          Navigator.pop(context);
                                        },
                                        child: _buildFinanceItem(
                                            AppLocalizations.of(context)!
                                                .expensetype,
                                            context),
                                      ),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          // widget.toggleDrawer(false);
                                          router.push('/estimateinvoice');
                                          Navigator.pop(context);
                                        },
                                        child: _buildFinanceItem(
                                            AppLocalizations.of(context)!
                                                .estimatesinvoices,
                                            context),
                                      ),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          // widget.toggleDrawer(false);
                                          router.push('/payment');
                                          Navigator.pop(context);
                                        },
                                        child: _buildFinanceItem(
                                            AppLocalizations.of(context)!
                                                .payments,
                                            context),
                                      ),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          // widget.toggleDrawer(false);
                                          router.push('/paymentmethod');
                                          Navigator.pop(context);
                                        },
                                        child: _buildFinanceItem(
                                            AppLocalizations.of(context)!
                                                .paymentmethods,
                                            context),
                                      ),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          // widget.toggleDrawer(false);
                                          router.push('/tax');
                                          Navigator.pop(context);
                                        },
                                        child: _buildFinanceItem(
                                            AppLocalizations.of(context)!.taxes,
                                            context),
                                      ),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          // widget.toggleDrawer(false);
                                          router.push('/unit');
                                          Navigator.pop(context);
                                        },
                                        child: _buildFinanceItem(
                                            AppLocalizations.of(context)!.units,
                                            context),
                                      ),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          // widget.toggleDrawer(false);
                                          router.push('/items');
                                          Navigator.pop(context);
                                        },
                                        child: _buildFinanceItem(
                                            AppLocalizations.of(context)!.items,
                                            context),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                widget.role == "admin" &&
                        context.read<PermissionsBloc>().isManageContract == true
                    ? InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            isExpandedContract = !isExpandedContract;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const HeroIcon(
                                        HeroIcons.clipboard,
                                        style: HeroIconStyle.outline,
                                        color: AppColors.greyColor,
                                      ),
                                      SizedBox(width: 20.w),
                                      CustomText(
                                        text: AppLocalizations.of(context)!
                                            .contracts,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textClrChange,
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    isExpandedContract
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 20.sp,
                                    color: AppColors.greyColor,
                                  ),
                                ],
                              ),
                              isExpandedContract
                                  ? SizedBox(height: 10.h)
                                  : SizedBox(),
                              if (isExpandedContract)
                                Padding(
                                  padding: const EdgeInsets.only(left: 40.0),
                                  child: Column(
                                    children: [
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          // widget.toggleDrawer(false);
                                          router.push('/contract');
                                          Navigator.pop(context);
                                        },
                                        child: _buildFinanceItem(
                                            AppLocalizations.of(context)!
                                                .managecontract,
                                            context),
                                      ),
                                      context
                                                  .read<PermissionsBloc>()
                                                  .isManageContractType ==
                                              true
                                          ? InkWell(
                                              onTap: () {
                                                // widget.toggleDrawer(false);
                                                router.push('/contracttype');
                                                Navigator.pop(context);
                                              },
                                              child: _buildFinanceItem(
                                                  AppLocalizations.of(context)!
                                                      .contractstypes,
                                                  context),
                                            )
                                          : SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                widget.role == "admin" &&
                        context.read<PermissionsBloc>().isManagePayslip == true
                    ? InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            isExpandedPayslip = !isExpandedPayslip;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const HeroIcon(
                                        HeroIcons.banknotes,
                                        style: HeroIconStyle.outline,
                                        color: AppColors.greyColor,
                                      ),
                                      SizedBox(width: 20.w),
                                      CustomText(
                                        text: AppLocalizations.of(context)!
                                            .payslips,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textClrChange,
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    isExpandedPayslip
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 20.sp,
                                    color: AppColors.greyColor,
                                  ),
                                ],
                              ),
                              isExpandedPayslip
                                  ? SizedBox(height: 10.h)
                                  : SizedBox(),
                              if (isExpandedPayslip)
                                Padding(
                                  padding: const EdgeInsets.only(left: 40.0),
                                  child: Column(
                                    children: [
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          // widget.toggleDrawer(false);
                                          router.push('/payslip');
                                          Navigator.pop(context);
                                        },
                                        child: _buildFinanceItem(
                                            AppLocalizations.of(context)!
                                                .managepayslip,
                                            context),
                                      ),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          // widget.toggleDrawer(false);
                                          router.push('/allowance');
                                          Navigator.pop(context);
                                        },
                                        child: _buildFinanceItem(
                                            AppLocalizations.of(context)!
                                                .allowances,
                                            context),
                                      ),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          // widget.toggleDrawer(false);
                                          router.push('/deduction');
                                          Navigator.pop(context);
                                        },
                                        child: _buildFinanceItem(
                                            AppLocalizations.of(context)!
                                                .deductions,
                                            context),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                widget.role == "admin"
                    ? InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          // widget.toggleDrawer(false);
                          router.push("/settings");
                          BlocProvider.of<SettingsBloc>(context)
                              .add(SettingsList("general_settings"));
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Row(
                            children: [
                              const HeroIcon(
                                HeroIcons.cog6Tooth,
                                style: HeroIconStyle.outline,
                                color: AppColors.greyColor,
                              ),
                              SizedBox(
                                width: 20.w,
                              ),
                              CustomText(
                                text: AppLocalizations.of(context)!.settings,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                              )
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),


                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    // widget.toggleDrawer(false);
                    BlocProvider.of<AuthBloc>(context).add(LoggedOut(
                      context: context,
                    ));
                    router.replace('/login');
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Row(
                      children: [
                        const HeroIcon(
                          HeroIcons.arrowLeftStartOnRectangle,
                          style: HeroIconStyle.outline,
                          color: AppColors.greyColor,
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        CustomText(
                          text: AppLocalizations.of(context)!.logout,
                          color: Theme.of(context).colorScheme.textClrChange,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    widget.toggleDrawer(!widget.isExpand);
                  },
                  child: !widget.isExpand
                      ? Container(
                          height: 30.h,
                          width: 30.w,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: AppColors.primary),
                          child: const HeroIcon(
                            size: 15,
                            HeroIcons.arrowLeft,
                            style: HeroIconStyle.solid,
                            color: AppColors.whiteColor,
                          ))
                      : Container(),
                ),
                const SizedBox(
                  height: 100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceItem(String text, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          CircleAvatar(radius: 3, backgroundColor: AppColors.primary),
          SizedBox(width: 10.w),
          CustomText(
            text: text,
            color: Theme.of(context).colorScheme.textClrChange,
          ),
        ],
      ),
    );
  }
}
