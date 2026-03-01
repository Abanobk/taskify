import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/utils/widgets/shake_widget.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../../bloc/custom_fields/custom_field_bloc.dart';
import '../../../bloc/custom_fields/custom_field_event.dart';
import '../../../bloc/custom_fields/custom_field_state.dart';
import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/permissions/permissions_event.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/user_profile/user_profile_bloc.dart';
import '../../../config/internet_connectivity.dart';
import '../../../data/model/custom_field/custom_field_model.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/circularprogress_indicator.dart';
import '../../../utils/widgets/custom_dimissible.dart';
import '../../../utils/widgets/no_data.dart';
import '../../../utils/widgets/no_internet_screen.dart';
import '../../../utils/widgets/search_pop_up.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import '../../notes/widgets/notes_shimmer_widget.dart';
import '../../widgets/search_field.dart';
import '../../widgets/side_bar.dart';
import '../../widgets/speech_to_text.dart';
import '../widgets/customFieldCard.dart';
import '../../../routes/routes.dart';
class CustomFieldsScreen extends StatefulWidget {
  const CustomFieldsScreen({super.key});

  @override
  State<CustomFieldsScreen> createState() => _CustomFieldsScreenState();
}

class _CustomFieldsScreenState extends State<CustomFieldsScreen> {
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
          context.read<CustomFieldBloc>().add(SearchCustomField(result));
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
    BlocProvider.of<CustomFieldBloc>(context).add(CustomFieldLists());
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
          context.read<CustomFieldBloc>().add(SearchCustomField(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    BlocProvider.of<CustomFieldBloc>(context).add(CustomFieldLists());

    super.initState();
  }

  void onDeleteCustomField(int activity) {
    context.read<CustomFieldBloc>().add(DeleteCustomField(activity));
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
                                    .read<CustomFieldBloc>()
                                    .add(SearchCustomField(
                                      "",
                                    ));
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
                          .read<CustomFieldBloc>()
                          .add(SearchCustomField(value));
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
        onTap: () {
          router.pop();
        },
        iSBackArrow: true,
        isAdd: true,
        onPress: () {
          var emptyField = CustomFieldModel.empty();
          router.push('/createeditcustomfield',
              extra: {'isCreate': true, 'model': emptyField});
        },
        iscreatePermission: true,
        title: AppLocalizations.of(context)!.customfields,
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
            child: BlocConsumer<CustomFieldBloc, CustomFieldState>(
              listener: (context, state) {
                if (state is CustomFieldDeleteSuccess) {
                  flutterToastCustom(
                      msg: AppLocalizations.of(context)!.deletedsuccessfully,
                      color: AppColors.primary);
                  BlocProvider.of<CustomFieldBloc>(context)
                      .add(CustomFieldLists());
                } else if (state is CustomFieldError) {
                  BlocProvider.of<CustomFieldBloc>(context)
                      .add(CustomFieldLists());

                  flutterToastCustom(msg: state.errorMessage);
                } else if (state is CustomFieldEditError) {
                  BlocProvider.of<CustomFieldBloc>(context)
                      .add(CustomFieldLists());

                  flutterToastCustom(msg: state.errorMessage);
                } else if (state is CustomFieldCreateError) {
                  BlocProvider.of<CustomFieldBloc>(context)
                      .add(CustomFieldLists());

                  flutterToastCustom(msg: state.errorMessage);
                } else if (state is CustomFieldDeleteError) {
                  BlocProvider.of<CustomFieldBloc>(context)
                      .add(CustomFieldLists());

                  flutterToastCustom(msg: state.errorMessage);
                } else if (state is CustomFieldEditSuccess) {
                  BlocProvider.of<CustomFieldBloc>(context)
                      .add(CustomFieldLists());
                  Navigator.pop(context);
                  flutterToastCustom(
                      msg: AppLocalizations.of(context)!.createdsuccessfully,
                      color: AppColors.primary);
                }
              },
              builder: (context, state) {
                print("trghj$state");
                if (state is CustomFieldLoading) {
                  return NotesShimmer(
                    height: 190.h,
                    count: 4,
                  );
                } else if (state is CustomFieldSuccess) {
                  return NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (!state.isLoadingMore &&
                          scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                        context
                            .read<CustomFieldBloc>()
                            .add(CustomFieldLoadMore(searchWord));
                      }
                      return false;
                    },
                    child: state.CustomField.isNotEmpty
                        ? _CustomFieldList(isLightTheme, state.isLoadingMore,
                            state.CustomField)

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

  Widget _CustomFieldList(isLightTheme, hasReachedMax, CustomField) {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 0.h),
      // shrinkWrap: true,
      itemCount: hasReachedMax
          ? CustomField.length // No extra item if all data is loaded
          : CustomField.length + 1, // Add 1 for the loading indicator
      itemBuilder: (context, index) {
        if (index < CustomField.length) {
          final activity = CustomField[index];
          // String? dateCreated;
          // dateCreated = formatDateFromApi(activity.createdAt!, context);
          return index == 0
              ? ShakeWidget(
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.h, horizontal: 18.w),
                      child: DismissibleCard(
                        title: activity.id!.toString(),
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
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .alertBoxBackGroundColor,
                                    title: Text(
                                      AppLocalizations.of(context)!
                                          .confirmDelete,
                                    ),
                                    content: Text(
                                      AppLocalizations.of(context)!.areyousure,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          print(
                                              "User confirmed deletion - about to pop with true");
                                          Navigator.of(context)
                                              .pop(true); // Confirm deletion
                                        },
                                        child: Text(
                                          AppLocalizations.of(context)!.ok,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          print(
                                              "User cancelled deletion - about to pop with false");
                                          Navigator.of(context)
                                              .pop(false); // Cancel deletion
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
                              print(
                                  "About to return from confirmDismiss: ${result ?? false}");

                              // If user confirmed deletion, handle it here instead of in onDismissed
                              if (result == true) {
                                print(
                                    "Handling deletion directly in confirmDismiss");
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  setState(() {
                                    CustomField.removeAt(index);
                                  });
                                  onDeleteCustomField(activity.id);
                                });
                                // Return false to prevent the dismissible from animating
                                return false;
                              }

                              return false; // Always return false since we handle deletion manually
                            } catch (e) {
                              print("Error in dialog: $e");
                              return false;
                            } // Return the result of the dialog
                          } else if (direction == DismissDirection.startToEnd) {
                            router.push('/createeditcustomfield',
                                extra: {'isCreate': false, 'model': activity});
                            // Perform the edit action if needed
                            return false; // Prevent dismiss
                          }
                          // flutterToastCustom(
                          //     msg: AppLocalizations.of(context)!.isDemooperation);
                          return false; // Default case
                        },
                        dismissWidget: customFieldChild(isLightTheme,
                            CustomField[index], context, profilePic),
                        onDismissed: (DismissDirection direction) {
                          // This will not be called if `confirmDismiss` returned `false`
                          if (direction == DismissDirection.endToStart) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                CustomField.removeAt(index);
                              });
                              onDeleteCustomField(activity.id);
                            });
                          }
                        },
                      )),
                )
              : Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                  child: DismissibleCard(
                    title: activity.id!.toString(),
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
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .alertBoxBackGroundColor,
                                title: Text(
                                  AppLocalizations.of(context)!
                                      .confirmDelete,
                                ),
                                content: Text(
                                  AppLocalizations.of(context)!.areyousure,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      print(
                                          "User confirmed deletion - about to pop with true");
                                      Navigator.of(context)
                                          .pop(true); // Confirm deletion
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!.ok,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      print(
                                          "User cancelled deletion - about to pop with false");
                                      Navigator.of(context)
                                          .pop(false); // Cancel deletion
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
                          print(
                              "About to return from confirmDismiss: ${result ?? false}");

                          // If user confirmed deletion, handle it here instead of in onDismissed
                          if (result == true) {
                            print(
                                "Handling deletion directly in confirmDismiss");
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) {
                              setState(() {
                                CustomField.removeAt(index);
                              });
                              onDeleteCustomField(activity.id);
                            });
                            // Return false to prevent the dismissible from animating
                            return false;
                          }

                          return false; // Always return false since we handle deletion manually
                        } catch (e) {
                          print("Error in dialog: $e");
                          return false;
                        } // Return the result of the dialog
                      } else if (direction == DismissDirection.startToEnd) {
                        router.push('/createeditcustomfield',
                            extra: {'isCreate': false, 'model': activity});
                        // Perform the edit action if needed
                        return false; // Prevent dismiss
                      }
                      // flutterToastCustom(
                      //     msg: AppLocalizations.of(context)!.isDemooperation);
                      return false; // Default case
                    },
                    dismissWidget: customFieldChild(isLightTheme,
                        CustomField[index], context, profilePic),
                    onDismissed: (DismissDirection direction) {
                      // This will not be called if `confirmDismiss` returned `false`
                      if (direction == DismissDirection.endToStart) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            CustomField.removeAt(index);
                          });
                          onDeleteCustomField(activity.id);
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
