import 'package:flutter/material.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/widgets/edit_delete_pop.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/leave_request/leave_request_bloc.dart';
import '../../bloc/leave_request/leave_request_event.dart';
import '../../bloc/leave_request/leave_request_state.dart';
import '../../src/generated/i18n/app_localizations.dart';

import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../config/constants.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_text.dart';
import 'package:heroicons/heroicons.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/toast_widget.dart';
import '../../utils/widgets/search_pop_up.dart';
import '../notes/widgets/notes_shimmer_widget.dart';
import '../widgets/no_data.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import '../widgets/search_field.dart';
import '../widgets/side_bar.dart';
import '../widgets/speech_to_text.dart';

class LeaveRequestScreen extends StatefulWidget {
  final bool? fromNoti;
  const LeaveRequestScreen({super.key, this.fromNoti});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  TextEditingController searchController = TextEditingController();


  String searchword = "";

  bool dialogShown = false;

  bool? isLoading = true;
  bool isLoadingMore = false;
  String? formattedFrom;
  bool shouldDisableEdit = true;

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late SpeechToTextHelper speechHelper;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  String? formattedTo;
  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    BlocProvider.of<LeaveRequestBloc>(context)
        .add(LeaveRequestList(searchword));
    // await LeaveRequestRepo().LeaveRequestList(token: true, );
    setState(() {
      isLoading = false;
    });
  }



  @override
  void initState() {
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {

      if (results.isNotEmpty) {
        setState(() {
          _connectionStatus = results;
        });

      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
        });
      }
    });
    searchController.addListener(() {
      setState(() {});
    });
    context.read<LeaveRequestBloc>().add(LeaveRequestList(searchword));
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          context.read<LeaveRequestBloc>().add(SearchLeaveRequest(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    super.initState();
  }



  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  void onDeleteLeaveReq(leaveReq) {
    context.read<LeaveRequestBloc>().add(DeleteLeaveRequest(leaveReq));
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;

    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : Scaffold(
            backgroundColor: Theme.of(context).colorScheme.backGroundColor,
            body: SideBar(
              context: context,
              controller: sideBarController,
              underWidget: SizedBox(
                // height: 400,
                width: double.infinity,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: BackArrow(
                        iscreatePermission: true,
                        isFromNotification: widget.fromNoti,
                        fromNoti: "leaverequest",
                        title: AppLocalizations.of(context)!.leavereqs,
                        isAdd: true,
                        onPress: () {
                          router.push(
                            '/createleaverequest',
                            extra: {
                              'isCreate':
                                  true, // or true, depending on your needs
                              'req': [], // your list of LeaveRequests
                            },
                          );
                          BlocProvider.of<UserBloc>(context).add(UserList());
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    CustomSearchField(
                      isLightTheme: isLightTheme,
                      controller: searchController,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (searchController.text.isNotEmpty)
                            SizedBox(
                              width: 20.w,
                              // color: AppColors.red,
                              child: IconButton(
                                highlightColor: Colors.transparent,

                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.clear,
                                  size: 20.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textFieldColor,
                                ),
                                onPressed: () {
                                  // Clear the search field
                           setState(() {
                             searchController.clear();
                           });
                                  // Optionally trigger the search event with an empty string
                                  context
                                      .read<LeaveRequestBloc>()
                                      .add(SearchLeaveRequest(""));
                                },
                              ),
                            ),
                          IconButton(
                            icon: Icon(
                              !speechHelper.isListening
                                  ? Icons.mic_off
                                  : Icons.mic,
                              size: 20.sp,
                              color:
                                  Theme.of(context).colorScheme.textFieldColor,
                            ),
                            onPressed: () {
                              if (speechHelper.isListening) {
                                speechHelper.stopListening();
                              } else {
                                speechHelper.startListening(context, searchController, SearchPopUp());
                              }
                            },
                          ),
                        ],
                      ),
                      onChanged: (value) {
                        searchword = value;
                        context
                            .read<LeaveRequestBloc>()
                            .add(SearchLeaveRequest(value));
                      },
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Expanded(
                      child: RefreshIndicator(
                          color: AppColors.primary, // Spinner color
                          backgroundColor:
                              Theme.of(context).colorScheme.backGroundColor,
                          onRefresh: _onRefresh,
                          child: leaveRequestList(isLightTheme)),
                    ),
                    // LeaveReqList(isLightTheme)
                  ],
                ),
              ),
            ));
  }

  Widget leaveRequestList(bool isLightTheme) {
    return BlocConsumer<LeaveRequestBloc, LeaveRequestState>(
      listener: (context, state) {
        if (state is LeaveRequestPaginated) {}
      },
      buildWhen: (previous, current) {

        return previous != current;
      },
      builder: (context, state) {

        if (state is LeaveRequestLoading) {
          return GridShimmer();
        } else if (state is LeaveRequestPaginated) {
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              // Check if we're at the bottom and not already loading
              if (!state.hasReachedMax && state.isLoading &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {

                context.read<LeaveRequestBloc>().add(
                    LoadMoreLeaveRequest(searchword)
                );
                return true;
              }
              return false;
            },
            child: state.leave.isEmpty
                ? NoData(isImage: true)
                : Stack(
              children: [

                  GridView.builder(
                    padding: EdgeInsets.only(
                        left: 8.w,
                        right: 8.w,
                        bottom: 50.h
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 1.0,
                      mainAxisSpacing: 1.0,
                      childAspectRatio: 0.9,
                    ),
                    shrinkWrap: true,
                    itemCount:  state.leave.length
                       ,
                    itemBuilder: (context, index) {

                      if (index < state.leave.length) {
                        final leave = state.leave[index];
                        final from = datechange(leave.fromDate!);
                        final to = datechange(leave.toDate!);
                        return _leaveReqCard(
                            isLightTheme,
                            leave,
                            state.leave,
                            index,
                            from,
                            to
                        );
                      }else{
                        return SizedBox();
                      }
                    },
                  ),

              ],
            ),
          );
        } else if (state is LeaveRequestError) {
          flutterToastCustom(msg: state.errorMessage);

        }else if (state is LeaveRequestDeleteError) {
          flutterToastCustom(msg: state.errorMessage);

        }else if (state is LeaveRequestDeleteSuccess) {
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
          BlocProvider.of<LeaveRequestBloc>(context)
              .add(LeaveRequestList(searchword));
          Navigator.pop(context);
        }
        return const SizedBox.shrink();
      },
    );
  }


  Widget _leaveReqCard(isLightTheme, leave, leaveReqState, index, from, to) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: InkWell(
          splashColor: Colors.transparent,
          onTap: () {},
          child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.containerDark,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  isLightTheme
                      ? MyThemes.lightThemeShadow
                      : MyThemes.darkThemeShadow,
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(leave.userPhoto!),
                            ),
                            SizedBox(
                              width: 10.h,
                            ),
                            Column(
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 59.w,
                                  // color: Colors.red,
                                  child: CustomText(
                                    text: leave.userName!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    size: 14.sp,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                                Container(
                                  height: 20.h,
                                  width: 60.w,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: leave.status == "approved"
                                          ? Colors.green
                                          : leave.status == "pending"
                                          ? Colors.yellow
                                          : Colors.red,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  alignment: Alignment.center, // Centers content both horizontally & vertically
                                  child: CustomText(
                                    textAlign: TextAlign.center,
                                    text: leave.status.toString(),
                                    size: 10.sp,
                                    color: Theme.of(context).colorScheme.textClrChange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )

                              ],
                            )
                          ],
                        ),
                        Container(
                          width: 10.w,
                          // color: Colors.yellow,
                          margin: const EdgeInsets.only(right: 6),
                          padding: EdgeInsets.zero,
                          child: CustomPopupMenuButton(isEditAllowed:
                              true, isDeleteAllowed: true, onSelected: (value) {
                            setState(() {
                              if (value == 'Edit') {

                                router.push(
                                  '/createleaverequest',
                                  extra: {
                                    'isCreate': false,
                                    'req': leaveReqState
                                        .map((leaveRequest) =>
                                        leaveRequest.toJson())
                                        .toList(), // Convert list to List<Map<String, dynamic>>
                                    'index':
                                    index, // Pass the index of the item to edit (optional, depends on your logic)
                                  },
                                );

                                BlocProvider.of<UserBloc>(context)
                                    .add(UserList());
                              } else if (value == "Delete") {
                              // if(isDemo){
                              //
                              //   flutterToastCustom(
                              //       msg: AppLocalizations.of(context)!.isDemooperation);
                              // }else{
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10.r), // Set the desired radius here
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .alertBoxBackGroundColor,
                                      title: Text(
                                        AppLocalizations.of(context)!
                                            .confirmDelete,
                                      ),
                                      content: Text(
                                        AppLocalizations.of(context)!
                                            .areyousure,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            context
                                                .read<LeaveRequestBloc>()
                                                .add(DeleteLeaveRequest(
                                                leaveReqState[index]));
                                            Navigator.of(context).pop(
                                                true); // Confirm deletion
                                          },
                                          child: const Text('Delete'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(
                                                false); // Cancel deletion
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              // }
                              }
                            });
                          },),

                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    SizedBox(
                      // color: Colors.red,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomText(
                            text: leave.type == "Partial"
                                ? leave.fromTime!
                                : from,
                            size: 10.sp,
                            color: Theme.of(context).colorScheme.textClrChange,
                            fontWeight: FontWeight.w600,
                          ),
                          HeroIcon(
                            HeroIcons.arrowUturnRight,
                            style: HeroIconStyle.outline,
                            color: Theme.of(context).colorScheme.textClrChange,
                            size: 10,
                          ),
                          CustomText(
                            text: leave.partialLeave == "on"
                                ? leave.toTime!
                                // ? leave.duration!
                                : to,
                            size: 10.sp,
                            color: Theme.of(context).colorScheme.textClrChange,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    CustomText(
                      text:
                          "${leave.duration} ${AppLocalizations.of(context)!.days}",
                      size: 12,
                      color: Theme.of(context).colorScheme.colorChange,
                      fontWeight: FontWeight.w400,
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    CustomText(
                      text: leave.reason!,
                      size: 12.sp,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      color: Theme.of(context).colorScheme.colorChange,
                      fontWeight: FontWeight.w400,
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Row(
                      children: [
                        HeroIcon(
                          HeroIcons.calendar,
                          style: HeroIconStyle.solid,
                          color: AppColors.blueColor,
                          size: 20.sp,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Container(
                          height: 20.h,
                          // width: 70.w,
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          decoration: BoxDecoration(
                              color: AppColors.primary,
                              // color:  leave.partialLeave ==
                              //     "on" ? Color(0xff4EB5FF):colors.purple,
                              borderRadius: BorderRadius.circular(5)),
                          child: Center(
                            child: CustomText(
                              textAlign: TextAlign.center,
                              text: leave.partialLeave == "on"
                                  ? AppLocalizations.of(context)!.partialleave
                                  : AppLocalizations.of(context)!.fullday,
                              size: 12.sp,
                              color: AppColors.pureWhiteColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ))),
    );
  }
}
