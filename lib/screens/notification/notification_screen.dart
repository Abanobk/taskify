import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/model/create_task_model.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import 'package:taskify/utils/widgets/custom_dimissible.dart';
import 'package:taskify/utils/widgets/shake_widget.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../bloc/notifications/push_notification/notification_push_bloc.dart';
import '../../bloc/notifications/push_notification/notification_push_event.dart';
import '../../bloc/notifications/push_notification/notification_push_state.dart';
import '../../bloc/notifications/system_notification/notification_bloc.dart';
import '../../bloc/notifications/system_notification/notification_event.dart';
import '../../bloc/notifications/system_notification/notification_state.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../config/app_images.dart';
import '../../config/constants.dart';
import '../../data/localStorage/hive.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_text.dart';
import 'package:heroicons/heroicons.dart';
import 'dart:async';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/row_dashboard.dart';
import '../../utils/widgets/search_pop_up.dart';
import '../notes/widgets/notes_shimmer_widget.dart';
import '../widgets/html_widget.dart';
import '../widgets/search_field.dart';
import '../widgets/side_bar.dart';
import '../widgets/user_client_box.dart';
import '../../src/generated/i18n/app_localizations.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey globalKeyOne = GlobalKey();
  final GlobalKey globalKeyTwo = GlobalKey();
  final GlobalKey globalKeyThree = GlobalKey();

  String _searchQuery = '';
  String _searchPushQuery = '';

  TextEditingController searchController = TextEditingController();
  TextEditingController searchPushController = TextEditingController();

  bool? isLoading = true;
  bool _speechEnabled = false;
  final bool _speechPushEnabled = false;
  bool? isFirst = false;
  bool isListening =
      false; // Flag to track if speech recognition is in progress
  bool dialogShown = false;
  bool isLoadingMore = false;
  String _lastWords = "";
  String _lastPushWords = "";
  final SpeechToText _speechToText = SpeechToText();
  final SpeechToText _speechToTextPush = SpeechToText();

  String? getLanguage;
  late TabController _tabController;

  bool shouldDisableEdit = true;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String notiType = "";
  static final bool _onDevice = false;

  double level = 0.0;
  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);
  Future<String> getLang() async {
    final hiveStorage = HiveStorage();
    final language = await hiveStorage.getLanguage();

    return language ?? defaultLanguage;
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
  }

  void _initPushSpeech() async {
    _speechEnabled = await _speechToTextPush.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
    _tabController.dispose();
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
    _tabController = TabController(length: 2, vsync: this);

    // Listen for tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) { // Avoid multiple calls during transition
        setState(() {
          // Clear search queries and controllers
          _searchQuery = '';
          _searchPushQuery = '';
          searchController.clear();
          searchPushController.clear();
        });
        // Reset the notification lists to their initial state
        context.read<NotificationBloc>().add(NotificationList());
        context.read<NotificationPushBloc>().add(NotificationPushList());
      }
    });
    BlocProvider.of<NotificationBloc>(context).add(NotificationList());
    BlocProvider.of<NotificationPushBloc>(context).add(NotificationPushList());

    listenForPermissions();
    if (!_speechEnabled) {
      _initSpeech();
    }
    if (!_speechPushEnabled) {
      _initPushSpeech();
    }
    super.initState();
    _getIsFirst();
    // getLang();
  }

  _getIsFirst() async {
    isFirst = await HiveStorage.isFirstTime();
  }

  void _onDelete(notiId) {
    context.read<NotificationBloc>().add(DeleteNotification(notiId));
    final meetingBloc = BlocProvider.of<NotificationBloc>(context);
    meetingBloc.stream.listen((state) {
      if (state is NotificationDeleteSuccess) {
        if (mounted) {
          Navigator.pop(context);
          // BlocProvider.of<NotificationBloc>(context).add(const NotificationList());
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is NotificationError) {
        flutterToastCustom(msg: state.errorMessage);
      }
    });

     BlocProvider.of<NotificationBloc>(context).add( NotificationList());

  }

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      // Reset the last words on each new result to avoid appending repeatedly
      _lastWords = result.recognizedWords;
      searchController.text = _lastWords;
      if (_lastWords.isNotEmpty && dialogShown) {
        Navigator.pop(context); // Close the dialog once the speech is detected
        dialogShown = false; // Reset the dialog flag
      }
    });

    // Trigger search with the current recognized words
    context.read<NotificationBloc>().add(SearchNotification(_lastWords));
  }

  void _onSpeechPushResult(SpeechRecognitionResult result) {
    setState(() {
      // Reset the last words on each new result to avoid appending repeatedly
      _lastPushWords = result.recognizedWords;
      searchPushController.text = _lastPushWords;
      if (_lastPushWords.isNotEmpty && dialogShown) {
        Navigator.pop(context); // Close the dialog once the speech is detected
        dialogShown = false; // Reset the dialog flag
      }
    });

    // Trigger search with the current recognized words
    context
        .read<NotificationPushBloc>()
        .add(SearchPushNotification(_lastPushWords));
  }

  final options = SpeechListenOptions(
      onDevice: _onDevice,
      listenMode: ListenMode.confirmation,
      cancelOnError: true,
      partialResults: true,
      autoPunctuation: true,
      enableHapticFeedback: true);
  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // _logEvent('sound level $level: $minSoundLevel - $maxSoundLevel ');
    setState(() {
      this.level = level;
    });
  }

  void listenForPermissions() async {
    final status = await Permission.microphone.status;
    switch (status) {
      case PermissionStatus.denied:
        requestForPermission();
        break;
      case PermissionStatus.granted:
        break;
      case PermissionStatus.limited:
        break;
      case PermissionStatus.permanentlyDenied:
        break;
      case PermissionStatus.restricted:
        break;
      case PermissionStatus.provisional: // Handle the provisional case
        break;
    }
  }

  Future<void> requestForPermission() async {
    await Permission.microphone.request();
  }

  void _onDialogDismissed() {
    setState(() {
      dialogShown = false; // Reset flag when the dialog is dismissed
    });
  }

  void _startListening() async {
    if (!_speechToText.isListening && !dialogShown) {
      setState(() {
        dialogShown = true; // Set the flag to prevent showing multiple dialogs
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SearchPopUp(); // Call the SearchPopUp widget here
        },
      ).then((_) {
        // This will be called when the dialog is dismissed.
        _onDialogDismissed();
      });
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30),
        localeId: "en_En",
        pauseFor: Duration(seconds: 3),
        onSoundLevelChange: soundLevelListener,
        listenOptions: options,
      );
      setState(() {});
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      isListening = false;
      if (_lastWords.isEmpty) {
        // If no words were recognized, allow reopening the dialog
        dialogShown = false;
      }
    });
  }

  void _startPushListening() async {
    if (!_speechToText.isListening && !dialogShown) {
      setState(() {
        dialogShown = true; // Set the flag to prevent showing multiple dialogs
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SearchPopUp(); // Call the SearchPopUp widget here
        },
      ).then((_) {
        // This will be called when the dialog is dismissed.
        _onDialogDismissed();
      });
      await _speechToText.listen(
        onResult: _onSpeechPushResult,
        listenFor: const Duration(seconds: 30),
        localeId: "en_En",
        pauseFor: Duration(seconds: 3),
        onSoundLevelChange: soundLevelListener,
        listenOptions: options,
      );
      setState(() {});
    }
  }

  void _stopPushListening() async {
    await _speechToText.stop();
    setState(() {
      isListening = false;
      if (_lastWords.isEmpty) {
        // If no words were recognized, allow reopening the dialog
        dialogShown = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context.read<PermissionsBloc>().isManageSystemNotification;
    context.read<PermissionsBloc>().isdeleteSystemNotification;

    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;

    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Theme.of(context).colorScheme.backGroundColor,
            body: SideBar(
              context: context,
              controller: sideBarController,
              underWidget: Column(
                children: [
                  // SizedBox(height: 30.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: BackArrow(
                      iSBackArrow: true,
                      title: AppLocalizations.of(context)!.allnotifications,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  _body(isLightTheme)
                ],
              ),
            ));
  }

  Widget _body(isLightTheme) {
    return Expanded(
      child: _notificationListBloc(isLightTheme),
    );
  }

  Widget _notificationListBloc(isLightTheme) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: TabBar(
                  controller: _tabController, // Attach TabController
                  unselectedLabelColor: Theme.of(context)
                      .colorScheme
                      .textClrChange, // Set unselected label color
                  // selectedLabelColor: Colors.blue, // Set selected label color
                  dividerColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.zero,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  tabs: [
                    Tab(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        width: double.infinity,
                        child: Center(
                          child: CustomText(
                            text: AppLocalizations.of(context)!.system,
                            color: _tabController.index == 0
                                ? AppColors.pureWhiteColor // Selected tab color
                                : Theme.of(context)
                                    .colorScheme
                                    .textClrChange, // Default color for unselected
                            fontWeight: FontWeight.w700,
                            size: 15.sp,
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        width: double.infinity,
                        child: Center(
                          child: CustomText(
                            text: AppLocalizations.of(context)!.pushin,
                            color: _tabController.index == 1
                                ? AppColors.pureWhiteColor // Selected tab color
                                : Theme.of(context)
                                    .colorScheme
                                    .textClrChange, // Default color for unselected
                            fontWeight: FontWeight.w700,
                            size: 15.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController, // Attach TabController
                children: [
                  systemNoti(isLightTheme),
                  pushNoti(isLightTheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget systemNoti(isLightTheme) {
    return BlocConsumer<NotificationBloc, NotificationsState>(
        listener: (context, state) {
      if (state is NotificationPaginated) {
        isLoadingMore = false;
        setState(() {});
      }
    }, builder: (context, state) {
      if (state is NotificationLoading) {
        return Padding(
          padding:  EdgeInsets.symmetric(horizontal: 18.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.w),
                child: SizedBox(  // Ensure proper height constraint
                  height: 40.h,
                  child: Shimmer.fromColors(
                    baseColor: isLightTheme ? Colors.grey[100]! : Colors.grey[600]!,
                    highlightColor: isLightTheme ? Colors.grey[300]! : Colors.grey[800]!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface, // Fixed typo: backGroundColor -> background
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: NotesShimmer(
                  isNoti: true,
                  count: 3,
                ),
              ),
            ],
          ),
        );

      }
      if (state is NotificationInitial) {
        return Expanded(
          child: Column(
            children: [
              SizedBox(
                height: 20.h,
              ),
              Shimmer.fromColors(
                  baseColor: isLightTheme == true
                      ? Colors.grey[100]!
                      : Colors.grey[600]!,
                  highlightColor: isLightTheme == false
                      ? Colors.grey[800]!
                      : Colors.grey[300]!,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.backGroundColor,
                        borderRadius: BorderRadius.circular(12)),
                    height: 40.h,
                  )),
              Expanded(
                child: NotesShimmer(
                  isNoti: true,
                  count: 3,
                ),
              )
            ],
          ),
        );
      }
      if (state is NotificationPaginated) {
        var notiState = state.noti;

        return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo is ScrollStartNotification) {
                FocusScope.of(context).unfocus(); // Dismiss keyboard
              }
              if (!state.hasReachedMax &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                context
                    .read<NotificationBloc>()
                    .add(LoadMoreNotification(searchQuery: _lastWords));
              }
              return false;
            },
            child: RefreshIndicator(
              onRefresh: () async {
                // Trigger the refresh logic, e.g., reload the notifications
                BlocProvider.of<NotificationBloc>(context)
                    .add(NotificationList());
              },
              child: state.noti.isNotEmpty
                  ? Column(
                      children: [
                        SizedBox(height: 20.h),
                        Padding(
                          padding:  EdgeInsets.symmetric(horizontal: 20.0),
                          child: CustomSearchField(
                            isNoti: true,
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
                                        searchController.clear();
                                        // Optionally trigger the search event with an empty string
                                        context.read<NotificationBloc>().add(
                                            SearchNotification(_searchQuery));
                                      },
                                    ),
                                  ),
                                IconButton(
                                  icon: Icon(
                                    _speechToText.isNotListening
                                        ? Icons.mic_off
                                        : Icons.mic,
                                    size: 20.sp,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textFieldColor,
                                  ),
                                  onPressed: () {
                                    if (_speechToText.isNotListening) {
                                      _startListening();
                                    } else {
                                      _stopListening();
                                    }
                                  },
                                ),
                              ],
                            ),
                            onChanged: (value) {
                              _searchQuery = value;
                              context
                                  .read<NotificationBloc>()
                                  .add(SearchNotification(value));
                            },
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Expanded(
                          child: ListView.builder(
                              padding: EdgeInsets.only(top: 8.w),
                              // physics: NeverScrollableScrollPhysics(),
                              // shrinkWrap: true,
                              itemCount: state.hasReachedMax
                                  ? state.noti.length
                                  : notiState.length + 1,
                              itemBuilder: (context, index) {
                                if (index < notiState.length) {
                                  var noti = notiState[index];

                                  String? dateCreated = formatDateFromApi(
                                      noti.createdAt!, context);

                                  return index == 0
                                      ? ShakeWidget(
                                          child: _getNotiList(
                                              notiState,
                                              index,
                                              noti,
                                              isLightTheme,
                                              dateCreated,
                                              "system"))
                                      : _getNotiList(notiState, index, noti,
                                          isLightTheme, dateCreated, "system");
                                } else {
                                  // Show a loading indicator when more notes are being loaded
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 0),
                                    child: Center(
                                      child: state.hasReachedMax
                                          ? const Text('')
                                          : const SpinKitFadingCircle(
                                              color: AppColors.primary,
                                              size: 40.0,
                                            ),
                                    ),
                                  );
                                }
                              }),
                        ),
                      ],
                    )
                  : Center(
                    child: NoData(
                        isImage: true,
                      ),
                  ),
            ));
      }
      return Container();
    });
  }

  Widget pushNoti(isLightTheme) {
    return BlocConsumer<NotificationPushBloc, NotificationPushState>(
        listener: (context, state) {
      if (state is NotificationPushPaginated) {
        isLoadingMore = false;
        setState(() {});
      }
    }, builder: (context, state) {
print("dfghjk $state");
      if (state is NotificationPushLoading) {
        return Padding(
          padding:  EdgeInsets.symmetric(horizontal: 18.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.w),
                child: SizedBox(  // Ensure proper height constraint
                  height: 40.h,
                  child: Shimmer.fromColors(
                    baseColor: isLightTheme ? Colors.grey[100]! : Colors.grey[600]!,
                    highlightColor: isLightTheme ? Colors.grey[300]! : Colors.grey[800]!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface, // Fixed typo: backGroundColor -> background
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: NotesShimmer(
                  isNoti: true,
                  count: 3,
                ),
              ),
            ],
          ),
        );
      }
      if (state is NotificationPushInitial) {
        return Expanded(
          child: Column(
            children: [
              SizedBox(
                height: 20.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.w),
                child: Shimmer.fromColors(
                    baseColor: isLightTheme == true
                        ? Colors.grey[100]!
                        : Colors.grey[600]!,
                    highlightColor: isLightTheme == false
                        ? Colors.grey[800]!
                        : Colors.grey[300]!,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.backGroundColor,
                          borderRadius: BorderRadius.circular(12)),
                      height: 40.h,
                    )),
              ),
              Expanded(
                child: NotesShimmer(
                  isNoti: true,
                  count: 3,
                ),
              )
            ],
          ),
        );
      }
      if (state is NotificationPushPaginated) {
        var notiState = state.noti;

        return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo is ScrollStartNotification) {
                FocusScope.of(context).unfocus(); // Dismiss keyboard
              }
              if (!state.hasReachedMax &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                context
                    .read<NotificationPushBloc>()
                    .add(LoadMorePushNotification(searchQuery: _lastWords));
              }
              return false;
            },
            child: RefreshIndicator(
              onRefresh: () async {

                BlocProvider.of<NotificationPushBloc>(context)
                    .add(NotificationPushList());
              },
              child: state.noti.isNotEmpty
                  ? Column(
                      children: [
                        SizedBox(height: 20.h),
                        Padding(
                            padding:  EdgeInsets.symmetric(horizontal: 20.0),
                            child:CustomSearchField(
                          isNoti: true,
                          isLightTheme: isLightTheme,
                          controller: searchPushController,
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (searchPushController.text.isNotEmpty)
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
                                      searchPushController.clear();
                                      // Optionally trigger the search event with an empty string
                                      context.read<NotificationPushBloc>().add(
                                          SearchPushNotification(
                                              _searchPushQuery));
                                    },
                                  ),
                                ),
                              IconButton(
                                icon: Icon(
                                  _speechToTextPush.isNotListening
                                      ? Icons.mic_off
                                      : Icons.mic,
                                  size: 20.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textFieldColor,
                                ),
                                onPressed: () {
                                  if (_speechToTextPush.isNotListening) {
                                    _startPushListening();
                                  } else {
                                    _stopPushListening();
                                  }
                                },
                              ),
                            ],
                          ),
                          onChanged: (value) {
                            _searchPushQuery = value;

                            context
                                .read<NotificationPushBloc>()
                                .add(SearchPushNotification(value));
                          },
                        )),
                        SizedBox(height: 10.h),
                        Expanded(
                          child: ListView.builder(
                              padding: EdgeInsets.only(top: 8.w),
                              // physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: state.hasReachedMax
                                  ? state.noti.length
                                  : notiState.length + 1,
                              itemBuilder: (context, index) {
                                if (index < notiState.length) {
                                  var noti = notiState[index];

                                  String? dateCreated = formatDateFromApi(
                                      noti.createdAt!, context);

                                  return index == 0
                                      ? ShakeWidget(
                                          child: _getNotiList(
                                              notiState,
                                              index,
                                              noti,
                                              isLightTheme,
                                              dateCreated,
                                              "push"))
                                      : _getNotiList(notiState, index, noti,
                                          isLightTheme, dateCreated, "push");
                                } else {
                                  // Show a loading indicator when more notes are being loaded
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 0),
                                    child: Center(
                                      child: state.hasReachedMax
                                          ? const Text('')
                                          : const SpinKitFadingCircle(
                                              color: AppColors.primary,
                                              size: 40.0,
                                            ),
                                    ),
                                  );
                                }
                              }),
                        ),
                      ],
                    )
                  : Center(
                    child: NoData(
                        isImage: true,
                      ),
                  ),
            ));
      }
      return Container();
    });
  }

  Widget _getNotiList(stateNoti, index, noti, isLightTheme, dateCreated, from) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: DismissibleCard(
          direction: DismissDirection.endToStart,
          title: stateNoti[index].id.toString(),
          confirmDismiss: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart ) {
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
                      stateNoti.removeAt(index);

                    });
                    _onDelete(noti.id);
                  });
                  // Return false to prevent the dismissible from animating
                  return false;
                }

                return false; // Always return false since we handle deletion manually
              } catch (e) {
                print("Error in dialog: $e");
                return false;
              } // Return the result of the dialog
            }
            return false; // Default case
          },
          dismissWidget: InkWell(
            onTap: () {

              if (noti.status == "Unread") {
                if (from == "system") {
                  context
                      .read<NotificationBloc>()
                      .add(MarkAsReadNotification(noti.id!));
                }
                if (from == "push") {
                  context
                      .read<NotificationPushBloc>()
                      .add(MarkAsReadPushNotification(noti.id!));
                }
              }

              router.push(
                '/notificationdetail',
                extra: {
                  "id": noti.id,
                  "title": noti.title,
                  "users": noti.users,
                  "clients": noti.clients,
                  'status': noti.status,
                  "createdAt": noti.createdAt,
                  "updatedAt": noti.updatedAt,
                  "message": noti.message, // or true, depending on your needs
                  'req': <CreateTaskModel>[], // your list of LeaveRequests
                },
              );
            },
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: 18.w),
              child: Container(
                decoration: BoxDecoration(
                    boxShadow: [
                      isLightTheme
                          ? MyThemes.lightThemeShadow
                          : MyThemes.darkThemeShadow,
                    ],
                    color: Theme.of(context).colorScheme.containerDark,
                    borderRadius: BorderRadius.circular(12)),
                // height: 120.h,
                child: Padding(
                  padding: EdgeInsets.only(top: 20.h, left: 20.h, right: 20.h),
                  child: Column(
                    children: [
                      SizedBox(
                        // height: 30.h,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  // color:Colors.red,
                                  width: 250.w,
                                  child: CustomText(
                                    text: noti.title!,
                                    size: 16,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                noti.status == "Unread"
                                    ? Expanded(
                                        flex: 1,
                                        child: InkWell(
                                          highlightColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          onTap: () {

                                            if (noti.status == "Unread") {
                                              if (from == "system") {
                                                context
                                                    .read<NotificationBloc>()
                                                    .add(MarkAsReadNotification(
                                                        noti.id!));
                                                context
                                                    .read<NotificationBloc>()
                                                    .add(NotificationList());
                                              }
                                              if (from == "push") {

                                                context
                                                    .read<NotificationPushBloc>()
                                                    .add(
                                                        MarkAsReadPushNotification(
                                                            noti.id!));
                                                context
                                                    .read<NotificationPushBloc>()
                                                    .add(NotificationPushList());
                                              }
                                            }
                                          },
                                          child: Container(
                                            width: 30,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        height: 30.h,
                                        width: 20.w,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    AppImages.meetingTickImage),
                                                fit: BoxFit.cover)),
                                      )
                              ],
                            ),
                            htmlWidget(noti.message!,context,width:double.infinity.w,height: 36.h),
                            SizedBox(
                              height: 5.h,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                userClientDialog(
                                  from: 'user',
                                  title: AppLocalizations.of(context)!.allusers,
                                  list: noti.users.isEmpty
                                      ? []
                                      : noti.users,
                                  context: context,
                                );
                              },
                              child: SizedBox(
                                // color: Colors.brown,
                                child: RowDashboard(
                                    isnotificationusers: true,
                                    list: noti.users!,
                                    title: "user",
                                    isusertitle: false,
                                    fromNotification: true),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                userClientDialog(
                                  from: 'client',
                                  context: context,
                                  title: AppLocalizations.of(context)!.allclients,
                                  list: noti.clients.isEmpty
                                      ? []
                                      : noti.clients,
                                );
                              },
                              child: SizedBox(
                                // color: Colors.brown,
                                child: RowDashboard(
                                    isnotificationclient: true,
                                    list: noti.clients!,
                                    title: "client",
                                    isusertitle: false,
                                    fromNotification: true),
                              ),
                            ),
                          )
                        ],
                      ),
                      Divider(
                          color: Theme.of(context).colorScheme.dividerClrChange),
                      Row(
                        children: [
                          const HeroIcon(
                            HeroIcons.calendar,
                            style: HeroIconStyle.solid,
                            color: AppColors.blueColor,
                          ),
                          SizedBox(
                            width: 20.w,
                          ),
                          CustomText(
                            text: dateCreated,
                            color: AppColors.greyColor,
                            size: 12,
                            fontWeight: FontWeight.w500,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10.h,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          onDismissed: (DismissDirection direction) {
            // This will not be called if `confirmDismiss` returned `false`
            if (direction == DismissDirection.endToStart) {
              WidgetsBinding.instance.addPostFrameCallback((_) {  setState(() {

                stateNoti.removeAt(index);
              });
              _onDelete(noti.id);

              });
            }
          },
        ));
  }
}
