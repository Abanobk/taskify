import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import '../../../bloc/leave_req_dashboard/leave_req_dashboard_bloc.dart';
import '../../../bloc/leave_req_dashboard/leave_req_dashboard_event.dart';
import '../../../bloc/leave_req_dashboard/leave_req_dashboard_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/user/user_bloc.dart';
import '../../../bloc/user/user_event.dart';
import '../../../bloc/user/user_state.dart';
import '../../../config/constants.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../routes/routes.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../notes/widgets/notes_shimmer_widget.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../home_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/number_picker.dart';

class LeaveRequest extends StatefulWidget {
  final Function(List<String>, List<int>) onSelected;
  const LeaveRequest({super.key, required this.onSelected});

  @override
  State<LeaveRequest> createState() => _LeaveRequestState();
}

class _LeaveRequestState extends State<LeaveRequest> {
  final TextEditingController _userSearchController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  String searchWord = "";
  List<int> userSelectedId = [];
  List<String> userSelectedname = [];
  final ValueNotifier<int> _currentValue =
      ValueNotifier<int>(7); // Using ValueNotifier

  String? fromDate;

  String? toDate;
  _todayTask() {
    DateTime now = DateTime.now();
    fromDate = DateFormat('yyyy-MM-dd').format(now);

    DateTime oneWeekFromNow = now.add(const Duration(days: 7));
    toDate = DateFormat('yyyy-MM-dd').format(oneWeekFromNow);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dayController.text = _currentValue.value.toString(); // Sync initial text
    dayController.addListener(() {
      int? newValue = int.tryParse(dayController.text);
      if (newValue != null && newValue >= 1 && newValue <= 366) {
        _currentValue.value = newValue; // Notify listeners
      }
    });
    _todayTask();
    BlocProvider.of<UserBloc>(context).add(UserList());
    BlocProvider.of<LeaveReqDashboardBloc>(context)
        .add(WeekLeaveReqListDashboard([], 7, []));
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            titleTask(
              context,
              AppLocalizations.of(context)!.leaverequests,
            ),
          ],
        ),
        _leaveRequestFilter(dayController),
        _leaveRequestBloc(isLightTheme)
      ],
    );
  }

  Widget _leaveRequestFilter(dayController) {
    return Padding(
      padding: EdgeInsets.only(left: 18.w, right: 18.w, top: 20.h),
      child: SizedBox(
        height: 50.h,
        width: double.infinity,  // Ensures it has a width
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicWidth(  // ✅ Constrains Row inside SingleChildScrollView
            child: Row(
              children: [
                _selectMembers(),
                SizedBox(width: 10.w),

                _selectDays(dayController),
              ],
            ),
          ),
        ),
      ),
      // child: SizedBox(
      //   height: 50.h,
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       _selectMembers(),
      //       SizedBox(
      //         width: 18.w,
      //       ),
      //       _selectDays(dayController)
      //     ],
      //   ),
      // ),
    );
  }

  Widget _selectMembers() {
    return Expanded(
      flex: 2,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return const SpinKitFadingCircle(
                    color: AppColors.primary,
                    size: 40.0,
                  );
                }

                if (state is UserSuccess || state is UserPaginated) {
                  final users = state is UserSuccess
                      ? state.user
                      : (state as UserPaginated).user;
                  final hasReachedMax =
                  state is UserPaginated ? state.hasReachedMax : false;

                  ScrollController scrollController = ScrollController();
                  scrollController.addListener(() {
                    if (scrollController.position.atEdge &&
                        scrollController.position.pixels != 0) {
                      context
                          .read<UserBloc>()
                          .add(UserLoadMore(_userSearchController.text));
                    }
                  });

                  return BlocBuilder<LeaveReqDashboardBloc, LeaveReqDashboardState>(
                    builder: (context, leaveReqState) {
                      List<String> userSelectedname = [];
                      List<int> userSelectedId = [];

                      if (leaveReqState is LeaveRequestDashboardSuccess) {
                        userSelectedname = leaveReqState.userSelectedname;
                        userSelectedId = leaveReqState.userSelectedId;
                        if (kDebugMode) {
                          print('SelectMembers Dialog: userSelectedname=$userSelectedname');
                        }
                      }

                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                        backgroundColor:
                        Theme.of(context).colorScheme.alertBoxBackGroundColor,
                        contentPadding: EdgeInsets.zero,
                        title: Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Column(
                              children: [
                                CustomText(
                                  text: AppLocalizations.of(context)!.selectuser,
                                  fontWeight: FontWeight.w800,
                                  size: 20,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .whitepurpleChange,
                                ),
                                const Divider(),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 0.w),
                                  child: SizedBox(
                                    height: 35.h,
                                    width: double.infinity,
                                    child: TextField(
                                      cursorColor: AppColors.greyForgetColor,
                                      cursorWidth: 1,
                                      controller: _userSearchController,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: (35.h - 20.sp) / 2,
                                          horizontal: 10.w,
                                        ),
                                        hintText:
                                        AppLocalizations.of(context)!.search,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: AppColors.greyForgetColor,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            color: AppColors.purple,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        context
                                            .read<UserBloc>()
                                            .add(SearchUsers(value));
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5.h),
                              ],
                            ),
                          ),
                        ),
                        content: Container(
                          constraints: BoxConstraints(maxHeight: 900.h),
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            controller: scrollController,
                            shrinkWrap: true,
                            itemCount:
                            hasReachedMax ? users.length : users.length + 1,
                            itemBuilder: (context, index) {
                              if (index < users.length) {
                                final isSelected =
                                userSelectedId.contains(users[index].id!);
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.h),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      final updatedUserSelectedId =
                                      List<int>.from(userSelectedId);
                                      final updatedUserSelectedname =
                                      List<String>.from(userSelectedname);
                                      if (isSelected) {
                                        updatedUserSelectedId
                                            .remove(users[index].id!);
                                        updatedUserSelectedname
                                            .remove(users[index].firstName!);
                                      } else {
                                        updatedUserSelectedId.add(users[index].id!);
                                        updatedUserSelectedname
                                            .add(users[index].firstName!);
                                      }
                                      context.read<LeaveReqDashboardBloc>().add(
                                        UpdateSelectedUsersLeaveRequest(
                                          List<String>.from(
                                              updatedUserSelectedname),
                                          List<int>.from(updatedUserSelectedId),
                                        ),
                                      );
                                      context.read<UserBloc>().add(
                                          ToggleUserSelection(
                                              index, users[index].firstName!));
                                    },
                                    child: Padding(
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 20.w),
                                      child:
                                      Center(
                                        child:
                                        Container(
                                          decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors
                                                  .purpleShade
                                                  : Colors
                                                  .transparent,
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  10),
                                              border: Border.all(
                                                  color: isSelected
                                                      ? AppColors
                                                      .purple
                                                      : Colors
                                                      .transparent)),
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                              10.w,vertical: 5.h),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              CustomText(
                                                text:users[index].firstName!,
                                                fontWeight:
                                                FontWeight.w500,
                                                size:
                                                18,
                                                color: isSelected
                                                    ? AppColors.purple
                                                    : Theme.of(context).colorScheme.textClrChange,
                                              ),
                                              isSelected
                                                  ? const HeroIcon(
                                                HeroIcons.checkCircle,
                                                style: HeroIconStyle.solid,
                                                color: AppColors.purple,
                                              )
                                                  : const SizedBox.shrink(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return Padding(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                                  child: Center(
                                    child: hasReachedMax
                                        ? const SizedBox.shrink()
                                        : const SpinKitFadingCircle(
                                      color: AppColors.primary,
                                      size: 40.0,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        actions: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: CreateCancelButtom(
                              title: AppLocalizations.of(context)!.ok,
                              onpressCancel: () {
                                _userSearchController.clear();
                                context
                                    .read<LeaveReqDashboardBloc>()
                                    .add(UpdateSelectedUsersLeaveRequest([], []));
                                context.read<LeaveReqDashboardBloc>().add(
                                  WeekLeaveReqListDashboard(
                                    [],
                                    _currentValue.value,
                                    [],
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              onpressCreate: () {
                                _userSearchController.clear();
                                context.read<LeaveReqDashboardBloc>().add(
                                  WeekLeaveReqListDashboard(
                                    userSelectedId,
                                    _currentValue.value,
                                    userSelectedname,
                                  ),
                                );
                                Future.delayed(Duration(milliseconds: 100), () {
                                  Navigator.pop(context);
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          );
        },
        child: BlocBuilder<LeaveReqDashboardBloc, LeaveReqDashboardState>(
          builder: (context, state) {
            List<String> userSelectedname = [];
            if (state is LeaveRequestDashboardSuccess) {
              userSelectedname = state.userSelectedname;
              if (kDebugMode) {
                print('SelectMembers UI: userSelectedname=$userSelectedname');
              }
            }
            return Container(
              alignment: Alignment.center,
              height: 40.h,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyColor, width: 0.5),
                color: Theme.of(context).colorScheme.containerDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CustomText(
                          text: userSelectedname.isNotEmpty
                              ? userSelectedname.join(", ")
                              : AppLocalizations.of(context)!.selectmembers,
                          color: Theme.of(context).colorScheme.textClrChange,
                          size: 14.sp,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  void _showNumberPickerDialog(dayController) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    showDialog(
      context: context,
      builder: (context) => CustomNumberPickerDialog(
        dayController: dayController,
        currentValue: _currentValue,
        isLightTheme: currentTheme is LightThemeState,
        onSubmit: (value) {
          _currentValue.value = value;
          BlocProvider.of<LeaveReqDashboardBloc>(context).add(
              WeekLeaveReqListDashboard(
                  (context.read<LeaveReqDashboardBloc>().state
                              as LeaveRequestDashboardSuccess?)
                          ?.userSelectedId ??
                      [],
                  _currentValue.value,
                  (context.read<LeaveReqDashboardBloc>().state
                              as LeaveRequestDashboardSuccess?)
                          ?.userSelectedname ??
                      []));
        },
      ),
    );
  }

  Widget _selectDays(dayController) {
    return Expanded(
      flex: 2,
      child: InkWell(
        onTap: () async {},
        child: ValueListenableBuilder<int>(
          valueListenable: _currentValue,
          builder: (context, value, child) {
            return Container(
              alignment: Alignment.center,
              height: 40.h,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyColor, width: 0.5),
                color: Theme.of(context).colorScheme.containerDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: InkWell(
                    onTap: () {
                      _showNumberPickerDialog(dayController);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: CustomText(
                            text: value == 7
                                ? AppLocalizations.of(context)!.sevendays
                                : "$value ${AppLocalizations.of(context)!.days}",
                            color: Theme.of(context).colorScheme.textClrChange,
                            size: 14.sp,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        value == 7
                            ? SizedBox.shrink()
                            : InkWell(
                                onTap: () {
                                  _currentValue.value = 7;
                                  dayController.text = "7";
                                  BlocProvider.of<LeaveReqDashboardBloc>(
                                          context)
                                      .add(WeekLeaveReqListDashboard(
                                          (context.read<LeaveReqDashboardBloc>().state
                                                      as LeaveRequestDashboardSuccess?)
                                                  ?.userSelectedId ??
                                              [],
                                          7,
                                          (context.read<LeaveReqDashboardBloc>().state
                                                      as LeaveRequestDashboardSuccess?)
                                                  ?.userSelectedname ??
                                              []));
                                },
                                child: Padding(
                                  padding:  EdgeInsets.only(left: 8.w),
                                  child:Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.greyColor,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(5.h),
                                    child: HeroIcon(
                                      HeroIcons.xMark,
                                      style: HeroIconStyle.outline,
                                      color: AppColors.pureWhiteColor,
                                      size: 15.sp,
                                    ),
                                  ),
                                ),
                              )),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _leaveRequestList(hasReachedMax, leaveState, isLightTheme) {
    return SizedBox(
      height: 250.h,
      width: double.infinity,
      child: ListView.builder(
          padding: EdgeInsets.only(top: 10.h, right: 18.w),
          // physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: hasReachedMax ? leaveState.length : leaveState.length + 1,
          itemBuilder: (context, index) {
            if (index < leaveState.length) {
              var leave = leaveState[index];
              var dateFrom = leave.fromDate;

              var from = formatDateFromApi(dateFrom!, context);
              var dateTo = leave.toDate;
              var to = formatDateFromApi(dateTo!, context);
              return InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  router.push('/userdetail', extra: {
                    "id": leave.id,
                  });
                },
                child: Padding(
                    padding:
                        EdgeInsets.only(top: 10.h, bottom: 10.h, left: 18.w),
                    child: Container(
                      width: 300.w,
                      decoration: BoxDecoration(
                          boxShadow: [
                            isLightTheme
                                ? MyThemes.lightThemeShadow
                                : MyThemes.darkThemeShadow,
                          ],
                          color: Theme.of(context).colorScheme.containerDark,
                          borderRadius: BorderRadius.circular(12)),
                      // height: 122.h,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 18.w, vertical: 12.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Profile Image
                                CircleAvatar(
                                  radius: 40.r,
                                  backgroundImage:
                                      NetworkImage(leave.photo ?? ""),
                                ),
                                SizedBox(width: 12.w),

                                // Leave Details
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      CustomText(
                                        text: "${leave.member} ",
                                        size: 22.sp,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textClrChange,
                                      ),
                                      SizedBox(height: 4.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          // SizedBox(height: 4.h),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.w,
                                                vertical: 2.h),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            child: Text(
                                              leave.type,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ])

                                    // Leave Type (Full/Partial)

                                    )
                              ],
                            ),

                            SizedBox(height: 10.w),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                "${leave.duration!.replaceAll(RegExp(r' days?|Days?'), '')}",
                                            style: TextStyle(
                                              fontSize:
                                                  20.sp, // Bigger size for "26"
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .textClrChange,
                                            ),
                                          ),
                                          leave.duration == "1 day"
                                              ? WidgetSpan(
                                                  child: Transform.translate(
                                                    offset: Offset(0,
                                                        -10), // Moves "th" slightly up
                                                    child: CustomText(
                                                      text: "day",

                                                      size: 10
                                                          .sp, // Smaller size for "th"
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .textClrChange,
                                                    ),
                                                  ),
                                                )
                                              : WidgetSpan(
                                                  child: Transform.translate(
                                                    offset: Offset(0,
                                                        -10), // Moves "th" slightly up
                                                    child: CustomText(
                                                      text: "days",

                                                      size: 18
                                                          .sp, // Smaller size for "th"
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .textClrChange,
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    CustomText(
                                      text: AppLocalizations.of(context)!
                                          .totalLeave,

                                      size: 18.sp, // Smaller size for "th"
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textClrChange,
                                    ),
                                  ],
                                ),
                                leave.daysLeft!.toString() == "0"
                                    ? SizedBox(
                                        child: CustomText(
                                        text:
                                            " ${AppLocalizations.of(context)!.today}",
                                        size: 16.sp,
                                        color: AppColors.projDetailsSubText,
                                        fontWeight: FontWeight.w600,
                                      ))
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .daysLeft,
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 10.sp,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(8.w),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .textClrChange,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              "${leave.daysLeft.toString()}",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .lightWhite,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                            Divider(),
                            // Leave Duration
                            SizedBox(width: 15.w),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(
                                  text: from,
                                  size: 12.sp,
                                  color: AppColors.greyColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                Icon(
                                  Icons.compare_arrows,
                                  color: AppColors.greyColor,
                                ),
                                CustomText(
                                  text: to,
                                  size: 12.sp,
                                  color: AppColors.greyColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
              );
            } else {
              // Show a loading indicator when more notes are being loaded
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: Center(
                  child: hasReachedMax
                      ? const Text('')
                      : const SpinKitFadingCircle(
                          color: AppColors.primary,
                          size: 40.0,
                        ),
                ),
              );
            }
          }),
    );
  }

  Widget _leaveRequestBloc(isLightTheme) {
    return BlocBuilder<LeaveReqDashboardBloc, LeaveReqDashboardState>(
      builder: (context, state) {
        if (state is LeaveRequestDashboardLoading) {
          return Container(
              // color: Colors.red,
              height: 225.h,
              child: const HomeUpcomingShimmer());
        } else if (state is LeaveRequestDashboardSuccess) {
          return NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                // Check if the user has scrolled to the end and load more notes if needed
                if (!state.hasReachedMax &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  context.read<LeaveReqDashboardBloc>().add(
                      WeekLeaveReqListDashboardLoadMore(
                          userSelectedId, _currentValue.value));
                }
                return false;
              },
              child: state.leave.isNotEmpty
                  ? _leaveRequestList(
                      state.hasReachedMax, state.leave, isLightTheme)
                  : Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 18.w, vertical: 12.h),
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              boxShadow: [
                                isLightTheme
                                    ? MyThemes.lightThemeShadow
                                    : MyThemes.darkThemeShadow,
                              ],
                              color:
                                  Theme.of(context).colorScheme.containerDark,
                              borderRadius: BorderRadius.circular(12)),
                          child: NoData(
                            isImage: false,
                          )),
                    ));
        } else if (state is LeaveRequestDasdhboardError) {}
        // Handle other states
        return const SizedBox.shrink();
      },
    );
  }
}
