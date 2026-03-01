import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/utils/widgets/shake_widget.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/activity_log/activity_log_bloc.dart';
import '../../bloc/activity_log/activity_log_event.dart';
import '../../bloc/activity_log/activity_log_state.dart';
import '../../bloc/permissions/permissions_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../bloc/user_profile/user_profile_bloc.dart';
import '../../config/constants.dart';
import '../../src/generated/i18n/app_localizations.dart';import '../../utils/widgets/custom_dimissible.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/circularprogress_indicator.dart';
import '../../utils/widgets/search_pop_up.dart';
import '../notes/widgets/notes_shimmer_widget.dart';
import '../widgets/no_data.dart';
import '../widgets/search_field.dart';
import '../widgets/side_bar.dart';
import '../widgets/speech_to_text.dart';
import 'activity_card.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  TextEditingController searchController = TextEditingController();
  bool shouldDisableEdit = true;
  late SpeechToTextHelper speechHelper;

  bool isListening =
      false; // Flag to track if speech recognition is in progress
  bool dialogShown = false;
  final SlidableBarController sidebarController =
      SlidableBarController(initialStatus: false);

  String searchWord = "";
  String? profilePic;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;

  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);
  Future<void> requestForPermission() async {
    await Permission.microphone.request();
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  void _initializeApp() {
    searchController.addListener(() {
      setState(() {});
    });
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          context.read<ActivityLogBloc>().add(SearchActivityLog(result, 0, ""));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    if (context.read<UserProfileBloc>().profilePic != null) {
      profilePic = context.read<UserProfileBloc>().profilePic;
    }

    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
  }

  Future<void> _onRefresh() async {
    BlocProvider.of<ActivityLogBloc>(context).add(AllActivityLogList());
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
  }

  @override
  void initState() {
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results != "ConnectivityResult.none") {
        setState(() {
          _connectionStatus = results;
        });
        _initializeApp();
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results != "ConnectivityResult.none") {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
          _initializeApp();
        });
      }
    });
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          context.read<ActivityLogBloc>().add(SearchActivityLog(result, 0, ""));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    super.initState();
  }

  void onDeleteActivityLog(int activity) {
    context.read<ActivityLogBloc>().add(DeleteActivityLog(activity));
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
              underWidget: Column(
                children: [
                  _appbar(),
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
                                    .read<ActivityLogBloc>()
                                    .add(SearchActivityLog("", 0, ""));
                              },
                            ),
                          ),
                        IconButton(
                          icon: Icon(
                            !speechHelper.isListening
                                ? Icons.mic_off
                                : Icons.mic,
                            size: 20.sp,
                            color: Theme.of(context).colorScheme.textFieldColor,
                          ),
                          onPressed: () {
                            if (speechHelper.isListening) {
                              speechHelper.stopListening();
                            } else {
                              speechHelper.startListening(
                                  context, searchController, SearchPopUp());
                            }
                          },
                        ),
                      ],
                    ),
                    onChanged: (value) {
                      searchWord = value;
                      context
                          .read<ActivityLogBloc>()
                          .add(SearchActivityLog(value, 0, ""));
                    },
                  ),
                  SizedBox(height: 20.h),
                  _body(isLightTheme)
                ],
              ),
            ));
  }

  Widget _appbar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: BackArrow(
        iSBackArrow: true,
        title: AppLocalizations.of(context)!.activityLog,
      ),
    );
  }

  Widget _body(isLightTheme) {
    return Expanded(
      child: Container(
          color: Theme.of(context).colorScheme.backGroundColor,
          child: RefreshIndicator(
            color: AppColors.primary, // Spinner color
            backgroundColor: Theme.of(context).colorScheme.backGroundColor,
            onRefresh: _onRefresh,
            child: BlocConsumer<ActivityLogBloc, ActivityLogState>(
              listener: (context, state) {
                if (state is ActivityLogDeleteSuccess) {
                  flutterToastCustom(
                      msg: AppLocalizations.of(context)!.deletedsuccessfully,
                      color: AppColors.primary);
                  BlocProvider.of<ActivityLogBloc>(context)
                      .add(AllActivityLogList());
                } else if (state is ActivityLogError) {
                  BlocProvider.of<ActivityLogBloc>(context)
                      .add(AllActivityLogList());

                  flutterToastCustom(msg: state.errorMessage);
                } else if (state is ActivityLogDeleteError) {
                  BlocProvider.of<ActivityLogBloc>(context)
                      .add(AllActivityLogList());

                  flutterToastCustom(msg: state.errorMessage);
                }
              },
              builder: (context, state) {
                if (state is ActivityLogLoading) {
                  return NotesShimmer(
                    height: 190.h,
                    count: 4,
                  );
                } else if (state is ActivityLogPaginated) {
                  return NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (!state.hasReachedMax &&
                          scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                        context
                            .read<ActivityLogBloc>()
                            .add(LoadMoreActivityLog(searchWord));
                      }
                      return false;
                    },
                    child: state.activityLog.isNotEmpty
                        ? _activityLogList(isLightTheme, state.hasReachedMax,
                            state.activityLog)

                        // height: 500,

                        : NoData(
                            isImage: true,
                          ),
                  );
                }
                // Handle other states
                return const Text("");
              },
            ),
          )),
    );
  }

  Widget _activityLogList(isLightTheme, hasReachedMax, activityLog) {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 0.h),
      // shrinkWrap: true,
      itemCount: hasReachedMax
          ? activityLog.length // No extra item if all data is loaded
          : activityLog.length + 1, // Add 1 for the loading indicator
      itemBuilder: (context, index) {
        if (index < activityLog.length) {
          final activity = activityLog[index];
          String? dateCreated;
          dateCreated = formatDateFromApi(activity.createdAt!, context);
          return index == 0
              ? ShakeWidget(
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.h, horizontal: 18.w),
                      child: DismissibleCard(
                        title: activityLog[index].id.toString(),
                        confirmDismiss: (DismissDirection direction) async {
                          if (direction == DismissDirection.endToStart) {
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
                                    activityLog.removeAt(index);

                                  });
                                  onDeleteActivityLog(activity.id!);
                                });
                                // Return false to prevent the dismissible from animating
                                return false;
                              }

                              return false; // Always return false since we handle deletion manually
                            } catch (e) {
                              print("Error in dialog: $e");
                              return false;
                            }
                          }
                          return false;
                        },
                        dismissWidget: activityChild(
                            isLightTheme,
                            activityLog[index],
                            dateCreated,
                            context,
                            profilePic),
                        direction: context
                                    .read<PermissionsBloc>()
                                    .isdeleteActivityLog ==
                                true
                            ? DismissDirection.endToStart
                            : DismissDirection.none,
                        onDismissed: (DismissDirection direction) {
                          if (direction == DismissDirection.endToStart) {

                            // Use post-frame callback to ensure the dismissible animation completes
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                activityLog.removeAt(index);
                              });
                              onDeleteActivityLog(activity.id!);
                            });
                          }

                        },
                      )),
                )
              : Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                  child: DismissibleCard(
                    title: activityLog[index].id.toString(),
                    confirmDismiss: (DismissDirection direction) async {
                      if (direction == DismissDirection.endToStart) {
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
                                activityLog.removeAt(index);

                              });
                              onDeleteActivityLog(activity.id!);
                            });
                            // Return false to prevent the dismissible from animating
                            return false;
                          }

                          return false; // Always return false since we handle deletion manually
                        } catch (e) {
                          print("Error in dialog: $e");
                          return false;
                        }
                      }
                      return false;
                    },
                    dismissWidget: activityChild(isLightTheme,
                        activityLog[index], dateCreated, context, profilePic),
                    direction:
                        context.read<PermissionsBloc>().isdeleteActivityLog ==
                                true
                            ? DismissDirection.endToStart
                            : DismissDirection.none,
                    onDismissed: (DismissDirection direction) {
                      if (direction == DismissDirection.endToStart) {

                        // Use post-frame callback to ensure the dismissible animation completes
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            activityLog.removeAt(index);
                          });
                          onDeleteActivityLog(activity.id!);
                        });
                      }

                    },
                  ));
        } else {
          // Show a loading indicator when more Meeting are being loaded
          return CircularProgressIndicatorCustom(
            hasReachedMax: hasReachedMax,
          );
        }
      },
    );
  }
}
