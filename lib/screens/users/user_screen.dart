import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/permissions/permissions_event.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/widgets/edit_delete_pop.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import 'package:taskify/screens/widgets/no_permission_screen.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';
import '../../data/model/user_model.dart';
import '../../routes/routes.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../utils/widgets/custom_text.dart';
import 'package:heroicons/heroicons.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/toast_widget.dart';
import '../../utils/widgets/search_pop_up.dart';
import '../notes/widgets/notes_shimmer_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import '../widgets/search_field.dart';
import '../widgets/side_bar.dart';
import '../widgets/speech_to_text.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class UserScreen extends StatefulWidget {
//   final String title;
  const UserScreen({
    super.key,
  });

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool? isLoading = true;
  bool _speechEnabled = false;
  String search = "";
  String _lastWords = "";
  bool shouldDisableEdit = true;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  static final bool _onDevice = false;
  bool isListening =
      false; // Flag to track if speech recognition is in progress
  bool dialogShown = false;
  double level = 0.0;
  late SpeechToTextHelper speechHelper;
  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);
  final SpeechToText _speechToText = SpeechToText();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  TextEditingController searchController = TextEditingController();
  ConnectivityResult connectivityCheck = ConnectivityResult.none;

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

  void _onDeleteUser(task) {
    context.read<UserBloc>().add(DeleteUsers(task));
    final setting = context.read<UserBloc>();
    setting.stream.listen((state) {
      if (state is UserDeleteSuccess) {
        if (mounted) {
          BlocProvider.of<UserBloc>(context).add(UserList());
          flutterToastCustom(
            msg: AppLocalizations.of(context)!.deletedsuccessfully,
            color: AppColors.primary,
          );
        }
      }
      if (state is UserDeleteError) {
        flutterToastCustom(msg: state.errorMessage);
      }
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    BlocProvider.of<UserBloc>(context).add(UserList());
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() {
          _connectionStatus = results;
        });
      }
    });
    listenForPermissions();
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          context.read<UserBloc>().add(SearchUsers(result));

        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    BlocProvider.of<UserBloc>(context).add(UserList());

    if (!_speechEnabled) {
      _initSpeech();
    }
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
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
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

    // Trigger search event with the updated result
    context.read<UserBloc>().add(SearchUsers(_lastWords));
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    _connectivitySubscription.cancel();
  }

  // final List<int> tileSizes = [2, 1, 2, 1,2, 1, 2, 1];
  @override
  Widget build(BuildContext context) {
    context.read<PermissionsBloc>().isManageUser;
    context.read<PermissionsBloc>().iseditUser;
    context.read<PermissionsBloc>().isdeleteUser;
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
                        iscreatePermission:
                            context.read<PermissionsBloc>().iscreateUser,
                        iSBackArrow: true,
                        title: AppLocalizations.of(context)!.usersFordrawer,
                        isAdd: context.read<PermissionsBloc>().iscreateUser,
                        onPress: () {
                          router.push(
                            '/createuser',
                            extra: {
                              'isCreate': true,
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.only(bottom: 5.h),
                      child: CustomSearchField(
                        isLightTheme: isLightTheme,
                        controller: searchController,
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 10.w),
                          child: Row(
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
                                      searchController.clear();
                                      context
                                          .read<UserBloc>()
                                          .add(SearchUsers(""));
                                      setState(() {});
                                    },
                                  ),
                                ),
                              SizedBox(
                                width: 30.w,
                                child: IconButton(
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
                              ),
                            ],
                          ),
                        ),
                        onChanged: (value) {
                          search = value;
                          context.read<UserBloc>().add(SearchUsers(value));
                          setState(() {});
                        },
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.primary, // Spinner color
                        backgroundColor:
                            Theme.of(context).colorScheme.backGroundColor,
                        onRefresh: _onRefresh,
                        child: _userFieldList(isLightTheme),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  Widget _userFieldList(isLightTheme) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        print("esdfcjnx $state");
        if (state is UserInitial) {
          return GridShimmer();
        } else if (state is UserLoading) {
          return GridShimmer();
          //UserSuccessCreateLoading
        } else if (state is UserPaginated) {
          return AbsorbPointer(
            absorbing: false,
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                bool load = false;
                int loadInt = 0;

                if (state is UserPaginated) {
                  return NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        if (!state.hasReachedMax &&
                            scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                          load = scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent;
                          BlocProvider.of<UserBloc>(context)
                              .add(UserLoadMore(search));
                        }
                        return false;
                      },
                      child: userCard(isLightTheme, state.hasReachedMax,
                          state.user, loadInt, load, state.isLoading!));
                }
                return SizedBox.shrink();

                // return const Center(child: CircularProgressIndicator());
              },
            ),
          );
        } else if (state is UserError) {
          return Text("ERROR ${state.errorMessage}");
        }
        return Container();
      },
    );
  }

  Widget userCard(
      isLightTheme, hasReachedMax, userList, loadInt, load, isLoading) {
    return context
        .read<PermissionsBloc>()
        .isManageUser ==
        true ?userList.isNotEmpty
        ? Stack(
            children: [
              MasonryGridView.count(
                padding: EdgeInsets.only(
                    top: 0.h, bottom: 50.h, left: 18.w, right: 18.w),
                crossAxisCount: 2,
                mainAxisSpacing: 13,
                crossAxisSpacing: 15,
                itemCount:
                    hasReachedMax ? userList.length : userList.length + 2,
                itemBuilder: (context, index) {
                  if (index < userList.length) {
                    loadInt = index;
                    var user = userList[index];
                    bool? hasPhoneNumber;

                    hasPhoneNumber =
                        user.phone != null && user.phone!.isNotEmpty;
                    // }
                    return Padding(
                      padding: EdgeInsets.only(top: 20.w),
                      child: InkWell(
                        highlightColor:
                            Colors.transparent, // No highlight on tap
                        splashColor: Colors.transparent,
                        onTap: () {
                          router.push('/userdetail', extra: {
                            "isUser": "isUser",
                            "id": user.id,
                            "from": "homescreen"
                          });
                        },
                        child: Container(
                          height: hasPhoneNumber == false ? 205.h : 220.h,
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 8.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      text: "#${user.id!}",
                                      size: 12.sp,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textClrChange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    context
                                                    .read<PermissionsBloc>()
                                                    .isdeleteUser ==
                                                true ||
                                            context
                                                    .read<PermissionsBloc>()
                                                    .iseditUser ==
                                                true
                                        ? SizedBox(
                                            // color: Colors.red,
                                            height: 30.h,
                                            child: Row(
                                              children: [
                                                Container(
                                                    width: 30.w,
                                                    // color: Colors.yellow,
                                                    margin: EdgeInsets.zero,
                                                    padding: EdgeInsets.zero,
                                                    child:
                                                        CustomPopupMenuButton(
                                                      isEditAllowed: context
                                                              .read<
                                                                  PermissionsBloc>()
                                                              .iseditUser ==
                                                          true,
                                                      isDeleteAllowed: context
                                                              .read<
                                                                  PermissionsBloc>()
                                                              .isdeleteUser ==
                                                          true,
                                                      onSelected: (value) {
                                                        User userModel = User(
                                                          id: userList[index]
                                                              .id,
                                                          profile:
                                                              userList[index]
                                                                  .profile,
                                                          firstName:
                                                              userList[index]
                                                                  .firstName,
                                                          lastName:
                                                              userList[index]
                                                                  .lastName,
                                                          role: userList[index]
                                                              .role,
                                                          roleId:
                                                              userList[index]
                                                                  .roleId,
                                                          email: userList[index]
                                                              .email,
                                                          phone: userList[index]
                                                              .phone,
                                                          countryCode:
                                                              userList[index]
                                                                  .countryCode,
                                                          type: userList[index]
                                                              .type,
                                                          dob: userList[index]
                                                              .dob,
                                                          doj: userList[index]
                                                              .doj,
                                                          address:
                                                              userList[index]
                                                                  .address,
                                                          city: userList[index]
                                                              .city,
                                                          state: userList[index]
                                                              .state,
                                                          country:
                                                              userList[index]
                                                                  .country,
                                                          zip: userList[index]
                                                              .zip,
                                                          status:
                                                              userList[index]
                                                                  .status,
                                                          createdAt:
                                                              userList[index]
                                                                  .createdAt,
                                                          updatedAt:
                                                              userList[index]
                                                                  .updatedAt,
                                                          assigned:
                                                              userList[index]
                                                                  .assigned,
                                                          requireEv:
                                                              userList[index]
                                                                  .requireEv,
                                                        );
                                                        if (value == 'Edit') {
                                                          router.push(
                                                            '/createuser',
                                                            extra: {
                                                              'isCreate': false,
                                                              "users": userList,
                                                              "userModel":
                                                                  userModel
                                                            },
                                                          );
                                                        } else if (value ==
                                                            "Delete") {
                                                          // if (isDemo) {
                                                          //   flutterToastCustom(
                                                          //       msg: AppLocalizations.of(
                                                          //               context)!
                                                          //           .isDemooperation);
                                                          // } else {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.r), // Set the desired radius here
                                                                  ),
                                                                  backgroundColor: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .alertBoxBackGroundColor,
                                                                  title: Text(
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .confirmDelete,
                                                                  ),
                                                                  content: Text(
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .areyousure,
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        _onDeleteUser(
                                                                            userList[index].id);
                                                                        context
                                                                            .read<UserBloc>()
                                                                            .add(UserList());
                                                                        Navigator.of(context)
                                                                            .pop(true); // Confirm deletion
                                                                      },
                                                                      child: const Text(
                                                                          'Delete'),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop(false); // Cancel deletion
                                                                      },
                                                                      child: const Text(
                                                                          'Cancel'),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          // }
                                                        }
                                                      },
                                                    )),
                                              ],
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ],
                                ),
                                Row(
                                  children: [
                                    user.profile != null
                                        ? CircleAvatar(
                                            backgroundColor: Colors.transparent,
                                            radius: 20,
                                            backgroundImage:
                                                NetworkImage(user.profile!),
                                          )
                                        : CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.red[200],
                                          ),
                                    SizedBox(
                                      width: 10.h,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 80.w,
                                          // color: Colors.red,
                                          child: CustomText(
                                            text: user.firstName!,
                                            size: 14.sp,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .textClrChange,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 80.w,
                                          // color: Colors.red,
                                          child: CustomText(
                                            text: user.email!,
                                            size: 12.sp,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .colorChange,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                SizedBox(
                                  // width: 130.w,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          children: [
                                            CustomText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .projectwithCounce,
                                              size: 12.sp,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .colorChange,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            SizedBox(
                                              height: 5.h,
                                            ),
                                            Container(
                                              // width: 55.w,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          AppColors.blueColor),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Center(
                                                child: CustomText(
                                                  text: user.assigned != null
                                                      ? user.assigned!.projects
                                                          .toString()
                                                      : "0",
                                                  size: 12.sp,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .textClrChange,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10.w,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          children: [
                                            CustomText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .tasks,
                                              size: 12.sp,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .colorChange,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            SizedBox(
                                              height: 5.h,
                                            ),
                                            Container(
                                              height: 20.h,
                                              // width: 55.w,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          AppColors.blueColor),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Center(
                                                child: CustomText(
                                                  text: user.assigned!.tasks
                                                      .toString(),
                                                  size: 12.sp,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .textClrChange,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 8.h,
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CustomText(
                                      text:
                                          AppLocalizations.of(context)!.status,
                                      size: 12.sp,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .colorChange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    user.status == 1
                                        ? Column(
                                            children: [
                                              Container(
                                                height: 20.h,
                                                width: 60.w,
                                                decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Center(
                                                  child: CustomText(
                                                    text: "Active",
                                                    // Ensure status is treated as a string
                                                    size: 10.sp,
                                                    color: AppColors
                                                        .pureWhiteColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(
                                            height: 20.h,
                                            width: 60.w,
                                            decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: Center(
                                              child: CustomText(
                                                text: "InActive",
                                                // Ensure status is treated as a string
                                                size: 10.sp,
                                                color: AppColors.pureWhiteColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                                hasPhoneNumber == false
                                    ? SizedBox.shrink()
                                    : SizedBox(
                                        height: 8.h,
                                      ),
                                user.phone != null && user.phone != ""
                                    ? Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: HeroIcon(
                                              HeroIcons.phone,
                                              style: HeroIconStyle.solid,
                                              size: 12.sp,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .textFieldColor,
                                            ),
                                          ),
                                          // SizedBox(
                                          //   width: 5.w,
                                          // ),
                                          Expanded(
                                            flex: 4,
                                            child: CustomText(
                                              text: user.phone != null
                                                  ? user.phone!
                                                  : "",
                                              size: 12.sp,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .textClrChange,
                                              fontWeight: FontWeight.w400,
                                              letterspace: 2,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
              if (!hasReachedMax && isLoading)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 50.h,
                    width: double.infinity,
                    child: Center(
                      child: SpinKitFadingCircle(
                        color: Colors.blue,
                        size: 40.0,
                      ),
                    ),
                  ),
                ),
            ],
          )
        : NoData(
            isImage: true,
          ):NoPermission();
  }
}
