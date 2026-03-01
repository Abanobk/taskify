import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/permissions/permissions_event.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/widgets/no_permission_screen.dart';
import 'package:taskify/utils/widgets/row_dashboard.dart';
import 'package:taskify/utils/widgets/shake_widget.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/clients/client_bloc.dart';
import '../../bloc/clients/client_event.dart';
import '../../bloc/meeting/meeting_bloc.dart';
import '../../bloc/meeting/meeting_event.dart';
import '../../bloc/meeting/meeting_state.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../config/constants.dart';
import '../../data/localStorage/hive.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_dimissible.dart';
import '../../utils/widgets/custom_text.dart';
import 'package:heroicons/heroicons.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/circularprogress_indicator.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/toast_widget.dart';
import '../../utils/widgets/search_pop_up.dart';
import '../notes/widgets/notes_shimmer_widget.dart';
import '../widgets/no_data.dart';

import '../widgets/search_field.dart';
import '../widgets/side_bar.dart';
import '../widgets/speech_to_text.dart';
import '../widgets/user_client_box.dart';
import '../../src/generated/i18n/app_localizations.dart';

class MeetingScreen extends StatefulWidget {
  final bool? fromNoti;
  const MeetingScreen({super.key, this.fromNoti});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  TextEditingController searchController = TextEditingController();

  String searchWord = "";

  bool shouldDisableEdit = true;


  bool isListening =
      false; // Flag to track if speech recognition is in progress
  bool dialogShown = false;

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late SpeechToTextHelper speechHelper;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  bool isLoadingMore = false;
  final SlidableBarController sideBarController =
  SlidableBarController(initialStatus: false);


  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
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
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          context.read<MeetingBloc>().add(SearchMeetings(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    super.initState();
    BlocProvider.of<MeetingBloc>(context).add(MeetingLists());
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
  }


  bool? isLoading = true;
  void onDeleteMeeting(int meeting) {
    context.read<MeetingBloc>().add(DeleteMeetings(meeting));
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    BlocProvider.of<MeetingBloc>(context).add(MeetingLists());

    setState(() {
      isLoading = false;
    });
  }

  String convertTo12HourFormat(String timeString) {
    // Parse the string to a DateTime object
    DateTime dateTime = DateFormat("HH:mm:ss").parse(timeString);

    // Format the DateTime object to 12-hour format
    String formattedTime = DateFormat("h a").format(dateTime);

    return formattedTime;
  }

  Future<void> _launchUrl(url) async {
    var token = await HiveStorage.getToken();
    if (!await launchUrl(Uri.parse("$url?token=$token"),
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }



  @override
  Widget build(BuildContext context) {
    context.read<PermissionsBloc>().isManageMeeting;
    context.read<PermissionsBloc>().iscreateMeeting;
    context.read<PermissionsBloc>().iseditMeeting;
    context.read<PermissionsBloc>().isdeleteMeeting;

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
    underWidget:Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: BackArrow(
                    iscreatePermission:
                        context.read<PermissionsBloc>().iscreateMeeting,
                    isFromNotification: widget.fromNoti,
                    fromNoti: "meeting",
                    iSBackArrow: true,
                    title: AppLocalizations.of(context)!.allmeetings,
                    isAdd: context.read<PermissionsBloc>().iscreateMeeting,
                    onPress: () {
                      router.push(
                        "/createmeeting",
                        extra: {
                          'isCreate': true,
                        },
                      );
                      BlocProvider.of<ClientBloc>(context).add(ClientList());
                      // createEditNotes(isLightTheme: isLightTheme, isCreate: true);
                    },
                  ),
                ),
                SizedBox(height: 20.h),
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
                              color:
                                  Theme.of(context).colorScheme.textFieldColor,
                            ),
                            onPressed: () {
                              // Clear the search field
                              setState(() {
                                searchController.clear();
                              });
                              // Optionally trigger the search event with an empty string
                              context
                                  .read<MeetingBloc>()
                                  .add(SearchMeetings(""));
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
                    searchWord = value;
                    context.read<MeetingBloc>().add(SearchMeetings(value));
                  },
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: RefreshIndicator(
                      color: AppColors.primary, // Spinner color
                      backgroundColor:
                          Theme.of(context).colorScheme.backGroundColor,
                      onRefresh: _onRefresh,
                      child: _meetingBloc(isLightTheme)),
                ),
              ],
            ),
          ));
  }

  Widget _meetingBloc(isLightTheme) {
    return BlocBuilder<MeetingBloc, MeetingState>(
      builder: (context, state) {
        print("thjmk $state");
        if(state is MeetingDeleteSuccess){
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
          context.read<MeetingBloc>().add(const MeetingLists());
        } if(state is MeetingCreateSuccess){
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.createdsuccessfully,
              color: AppColors.primary);
          Navigator.pop(context);
          context.read<MeetingBloc>().add(const MeetingLists());
        }if(state is MeetingEditSuccess){
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.updatedsuccessfully,
              color: AppColors.primary);
          Navigator.pop(context);
          context.read<MeetingBloc>().add(const MeetingLists());
        }
        if (state is MeetingDeleteError) {
          flutterToastCustom(msg: state.errorMessage);
          context.read<MeetingBloc>().add(const MeetingLists());

        } if (state is MeetingCreateError) {
          flutterToastCustom(msg: state.errorMessage);
          context.read<MeetingBloc>().add(const MeetingLists());

        }
        if (state is MeetingLoading) {
          return NotesShimmer(
            height: 190.h,
            count: 4,
          );
        } else if (state is MeetingPaginated) {
          // Show Meeting list with pagination
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {

              // Check if the user has scrolled to the end and load more Meeting if needed
              if (!state.hasReachedMax &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                context.read<MeetingBloc>().add(LoadMoreMeetings(searchWord));
              }
              return false;
            },
            child:  context
                .read<PermissionsBloc>()
                .isManageMeeting ==
                true ?state.meeting.isNotEmpty
                ? _meetingList(isLightTheme, state.hasReachedMax, state.meeting)
                : NoData(
                    isImage: true,
                  ):NoPermission(),
          );
        } else if (state is MeetingError) {
          // Show error message
          return Center(
            child: Text(
              state.errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        return const Text("");
      },
    );
  }

  Widget _meetingList(isLightTheme, hasReachedMax, meetingList) {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 0.h),
      // shrinkWrap: true,
      itemCount: hasReachedMax
          ? meetingList.length // No extra item if all data is loaded
          : meetingList.length + 1, // Add 1 for the loading indicator
      itemBuilder: (context, index) {
        if (index < meetingList.length) {
          final meeting = meetingList[index];
          final starttime = formatDateFromApi(meeting.startTime!, context);
          final endTime = formatDateFromApi(meeting.endTime!, context);

          final startDate = formatDateFromApi(meeting.startDate!, context);
          final endDate = formatDateFromApi(meeting.endDate!, context);
          return index == 0
              ? ShakeWidget(
                  child: _meetingCard(meeting, index, isLightTheme, starttime,
                      startDate, endTime, endDate, meetingList),
                )
              : _meetingCard(meeting, index, isLightTheme, starttime, startDate,
                  endTime, endDate, meetingList);
        } else {
          // Show a loading indicator when more Meeting are being loaded
          return CircularProgressIndicatorCustom(
            hasReachedMax: hasReachedMax,
          );
        }
      },
    );
  }

  Widget _meetingCard(meeting, index, isLightTheme, starttime, startDate,
      endTime, endDate, meetingList) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
        child: DismissibleCard(
          title: meeting.id.toString(),
          confirmDismiss: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart  ) {
              // Right to left swipe (Delete action)
              try {
                final result = await showDialog<bool>(
                  context: context,
                  barrierDismissible:
                  false, // Prevent dismissing by tapping outside
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      backgroundColor:
                      Theme.of(context).colorScheme.alertBoxBackGroundColor,
                      title: Text(
                        AppLocalizations.of(context)!.confirmDelete,
                      ),
                      content: Text(
                        AppLocalizations.of(context)!.areyousure,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            print(
                                "User confirmed deletion - about to pop with true");
                            Navigator.of(context).pop(true); // Confirm deletion
                          },
                          child: Text(
                            AppLocalizations.of(context)!.ok,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            print(
                                "User cancelled deletion - about to pop with false");
                            Navigator.of(context).pop(false); // Cancel deletion
                          },
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                          ),
                        ),
                      ],
                    );
                  },
                );

                print("Dialog result received: $result");
                print("About to return from confirmDismiss: ${result ?? false}");

                // If user confirmed deletion, handle it here instead of in onDismissed
                if (result == true) {
                  print("Handling deletion directly in confirmDismiss");
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      meetingList.removeAt(index);

                    });
                    onDeleteMeeting(meeting.id!);
                  });
                  // Return false to prevent the dismissible from animating
                  return false;
                }

                return false; // Always return false since we handle deletion manually
              } catch (e) {
                print("Error in dialog: $e");
                return false;
              }// Return the result of the dialog
            }
            else if (direction == DismissDirection.startToEnd) {
              router.push(
                '/createmeeting',
                extra: {
                  'isCreate': false,
                  "index": index,
                  "meeting": meeting,
                  "meetingModel": meeting
                },
              );


              return false; // Prevent dismiss
            }

            return false;
          },
          dismissWidget: InkWell(
            highlightColor: Colors.transparent, // No highlight on tap
            splashColor: Colors.transparent,
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                  boxShadow: [
                    isLightTheme
                        ? MyThemes.lightThemeShadow
                        : MyThemes.darkThemeShadow,
                  ],
                  color: Theme.of(context).colorScheme.containerDark,
                  borderRadius: BorderRadius.circular(12)),
              // height: 175.h,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.only(top: 0.h, left: 20.h, right: 20.h),
                      child: SizedBox(
                        height: 40.h,
                        // width: 270.w,
                        //  color: Colors.red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: meeting.ongoing == 1 ? 150.w : 270.w,
                              child: CustomText(
                                text: meeting.title!,
                                size: 16.sp,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            meeting.ongoing == 1
                                ? InkWell(
                                    highlightColor: Colors
                                        .transparent, // No highlight on tap
                                    splashColor: Colors.transparent,
                                    onTap: () {

                                      _launchUrl(
                                        Uri.parse(meeting.joinUrl!),
                                      );
                                    },
                                    child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: AppColors.purple,
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        height: 20.h,
                                        width: 100.w,
                                        margin: EdgeInsets.symmetric(
                                            vertical: 10.h),
                                        child: CustomText(
                                          text: AppLocalizations.of(context)!
                                              .join,
                                          size: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.pureWhiteColor,
                                        )),
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                    // Divider(color: colors.darkColor),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: SizedBox(
                        width: 300.w,
                        // color: Colors.red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(
                                    top: 5.h,
                                    bottom: 15.h,
                                    left: 0.h,
                                    right: 0.h),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    HeroIcon(
                                      HeroIcons.clock,
                                      style: HeroIconStyle.outline,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textClrChange,
                                      size: 12.sp,
                                    ),
                                    CustomText(
                                      text: " $startDate ",
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textClrChange,
                                      size: 10.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ],
                                )),
                            Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: HeroIcon(
                                HeroIcons.arrowUturnRight,
                                style: HeroIconStyle.solid,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                                size: 15.sp,
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                    top: 5.h,
                                    bottom: 15.h,
                                    left: 0.h,
                                    right: 0.h),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    HeroIcon(
                                      HeroIcons.clock,
                                      style: HeroIconStyle.outline,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textClrChange,
                                      size: 12.sp,
                                    ),
                                    CustomText(
                                      text: " $endDate ",
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textClrChange,
                                      size: 10,
                                      fontWeight: FontWeight.w500,
                                    ),

                                  ],
                                )),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: SizedBox(
                        height: 60.h,
                        // width: 280.w,

                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                  onTap: () {

                                    userClientDialog(
                                      from:'user',
                                      context:context,
                                      title: AppLocalizations.of(context)!
                                          .allusers,
                                      list: meeting!
                                          .users.isEmpty
                                          ? []
                                          :meeting.users,
                                    );
                                  },
                                  child: RowDashboard(
                                      list: meeting.users!, title: "user")),
                            ),
                            Expanded(
                              child: InkWell(
                                  onTap: () {
                                    userClientDialog(
                                      title: AppLocalizations.of(context)!
                                          .allclients,
                                      list:meeting
                                          .clients!.isEmpty
                                          ? []
                                          :  meeting.clients,
                                      from: 'client',
                                      context: context,
                                    );
                                  },
                                  child: RowDashboard(
                                      list: meeting.clients!,
                                      title: "client")),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: HeroIcon(
                              HeroIcons.camera,
                              style: HeroIconStyle.outline,
                              color: AppColors.primary,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Expanded(
                            flex: 12,
                            child: CustomText(
                              text: meeting.status,
                              color: AppColors.greyColor,
                              size: 12.sp,
                              maxLines: 2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // CustomText(
                          //   text:
                          //   "  $endTime",
                          //   color: Theme.of(context)
                          //       .colorScheme
                          //       .textClrChange,
                          //   size: 10,
                          //   fontWeight: FontWeight.w500,
                          // ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          direction: context.read<PermissionsBloc>().isdeleteMeeting == true &&
                  context.read<PermissionsBloc>().iseditMeeting == true
              ? DismissDirection.horizontal // Allow both directions
              : context.read<PermissionsBloc>().isdeleteMeeting == true
                  ? DismissDirection.endToStart // Allow delete
                  : context.read<PermissionsBloc>().iseditMeeting == true
                      ? DismissDirection.startToEnd // Allow edit
                      : DismissDirection.none,
          onDismissed: (DismissDirection direction) {
            if (direction == DismissDirection.endToStart &&
                context.read<PermissionsBloc>().isdeleteProject == true) {
              WidgetsBinding.instance.addPostFrameCallback((_) {   setState(() {
                meetingList.removeAt(index);
              });
              onDeleteMeeting(meeting.id!);

              });
            } else if (direction == DismissDirection.startToEnd &&
                context.read<PermissionsBloc>().iseditProject == true) {
              // Perform edit action

            }
          },
        ));
  }
}
