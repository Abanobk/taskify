import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/priority/priority_bloc.dart';
import 'package:taskify/bloc/priority/priority_event.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/status/widgets/color_fiield.dart';
import 'package:taskify/screens/widgets/custom_cancel_create_button.dart';
import 'package:taskify/screens/widgets/custom_textfields/custom_textfield.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import 'package:taskify/screens/widgets/search_field.dart';
import 'package:taskify/screens/widgets/side_bar.dart';
import 'package:taskify/screens/widgets/speech_to_text.dart';
import '../bloc/permissions/permissions_bloc.dart';
import '../bloc/permissions/permissions_event.dart';
import '../bloc/priority/priority_state.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_state.dart';
import '../config/constants.dart';
import '../config/internet_connectivity.dart';
import '../data/model/priority_model.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../utils/widgets/back_arrow.dart';
import '../utils/widgets/custom_dimissible.dart';
import '../utils/widgets/custom_text.dart';
import '../utils/widgets/my_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../utils/widgets/search_pop_up.dart';
import '../utils/widgets/shake_widget.dart';
import '../utils/widgets/toast_widget.dart';
import 'notes/widgets/notes_shimmer_widget.dart';

class PrioritiesScreen extends StatefulWidget {
  const PrioritiesScreen({super.key});

  @override
  State<PrioritiesScreen> createState() => _PrioritiesScreenState();
}

class _PrioritiesScreenState extends State<PrioritiesScreen> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  String searchWord = "";
  bool? isLoading = true;
  bool isLoadingMore = false;
  String? selectedColorName;
  final Connectivity _connectivity = Connectivity();
  TextEditingController searchController = TextEditingController();
  late SpeechToTextHelper speechHelper;
  TextEditingController titleController = TextEditingController();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final GlobalKey<FormState> _createEditPriorityKey = GlobalKey<FormState>();
  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);

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
          // context.read<ActivityLogBloc>().add(SearchActivityLog(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    super.initState();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    // also clean up if SpeechToTextHelper uses any resources
    super.dispose();
  }

  void _initializeApp() {
    searchController.addListener(() {
      setState(() {});
    });
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          context.read<PriorityBloc>().add(SearchPriority(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();

    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
  }

  void _onEditPriority(id, title, color) async {
    if (titleController.text.isNotEmpty && color != null) {
      context.read<PriorityBloc>().add(UpdatePriority(
            id: id,
            title:
                titleController.text.isNotEmpty ? titleController.text : title,
            color: color,
          ));
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
    // Navigator.pop(context);
  }

  void _onCreatePriority() {
    if (titleController.text.isNotEmpty) {
      context.read<PriorityBloc>().add(CreatePriority(
            title: titleController.text.toString(),
            color: selectedColorName?.toLowerCase() ?? "",
          ));
      final statusBloc = BlocProvider.of<PriorityBloc>(context);
      statusBloc.stream.listen((state) {
        if (state is PriorityCreateSuccess) {
          if (mounted) {
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.createdsuccessfully,
                color: AppColors.primary);
          }
        }
        if (state is PriorityCreateError) {
          flutterToastCustom(msg: state.errorMessage);
        }
      });
      statusBloc.add(PriorityLists());
    } else {
      flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleasefilltherequiredfield);
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    BlocProvider.of<PriorityBloc>(context).add(PriorityLists());
    setState(() {
      isLoading = false;
    });
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
                width: double.infinity,
                child: Column(
                  children: [
                    _appBar(isLightTheme),
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
                                      .read<PriorityBloc>()
                                      .add(SearchPriority(""));
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
                                speechHelper.startListening(
                                    context, searchController, SearchPopUp());
                              }
                            },
                          ),
                        ],
                      ),
                      onChanged: (value) {
                        searchWord = value;
                        context.read<PriorityBloc>().add(SearchPriority(value));
                      },
                    ),
                    SizedBox(height: 20.h),
                    _body(isLightTheme)
                  ],
                ),
              ),
            ));
  }

  Widget _appBar(isLightTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: BackArrow(
        iSBackArrow: true,
        iscreatePermission: true,
        title: AppLocalizations.of(context)!.priorities,
        isAdd: true,
        onPress: () {
          _createEditPriority(isLightTheme: isLightTheme, isCreate: true);
        },
      ),
    );
  }

  Widget _body(isLightTheme) {
    return Expanded(
        child: RefreshIndicator(
            color: AppColors.primary, // Spinner color
            backgroundColor: Theme.of(context).colorScheme.backGroundColor,
            onRefresh: _onRefresh,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: BlocConsumer<PriorityBloc, PriorityState>(
                    listener: (context, state) {
                  if (state is PrioritySuccess) {
                    isLoadingMore = false;
                    setState(() {});
                  }
                }, builder: (context, state) {
                  print("sefzgzghz $state");
                  if (state is PriorityLoading) {
                    return const NotesShimmer();
                  }
                  if (state is PriorityEditSuccess) {
                    flutterToastCustom(
                        msg: AppLocalizations.of(context)!.updatedsuccessfully,
                        color: AppColors.primary);
                    Navigator.pop(context);
                    BlocProvider.of<PriorityBloc>(context).add(PriorityLists());
                  }
                  if (state is PriorityDeleteSuccess) {
                    flutterToastCustom(
                        msg: AppLocalizations.of(context)!.deletedsuccessfully,
                        color: AppColors.primary);

                    BlocProvider.of<PriorityBloc>(context).add(PriorityLists());
                  }
                  if (state is PriorityCreateSuccess) {
                    flutterToastCustom(
                        msg: AppLocalizations.of(context)!.createdsuccessfully,
                        color: AppColors.primary);
                    Navigator.pop(context);
                    BlocProvider.of<PriorityBloc>(context).add(PriorityLists());
                  }
                  if (state is PrioritySuccess) {
                    return NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        if (!state.isLoadingMore &&
                            scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent &&
                            isLoadingMore == false) {
                          isLoadingMore = true;
                          setState(() {});
                          context
                              .read<PriorityBloc>()
                              .add(PriorityLoadMore(searchWord));
                        }
                        return false;
                      },
                      child: state.priority.isNotEmpty
                          ? _priorityLists(
                              isLightTheme,
                              state.isLoadingMore,
                              state.priority,
                            )
                          : NoData(
                              isImage: true,
                            ),
                    );
                  }
                  if (state is PriorityError) {
                    flutterToastCustom(
                        msg: state.errorMessage, color: AppColors.primary);
                  }
                  if (state is PriorityEditError) {
                    BlocProvider.of<PriorityBloc>(context).add(PriorityLists());
                    flutterToastCustom(
                        msg: state.errorMessage, color: AppColors.primary);
                  }
                  if (state is PriorityCreateError) {
                    BlocProvider.of<PriorityBloc>(context).add(PriorityLists());
                    flutterToastCustom(
                        msg: state.errorMessage, color: AppColors.primary);
                  }
                  return SizedBox.shrink();
                }))));
  }

  Widget _priorityLists(isLightTheme, hasReachedMax, priorityList) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: hasReachedMax
          ? priorityList.length // No extra item if all data is loaded
          : priorityList.length + 1,
      itemBuilder: (context, index) {
        if (index < priorityList.length) {
          final status = priorityList[index];
          String? dateCreated;
          DateTime createdDate = parseDateStringFromApi(status.createdAt!);
          dateCreated = dateFormatConfirmed(createdDate, context);
          return priorityList.isEmpty
              ? NoData(
                  isImage: true,
                )
              : _priorityListContainer(status, isLightTheme, priorityList,
                  index, dateCreated, status.color);
        } else {
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
      },
    );
  }

  Widget _priorityListContainer(Priorities priority, bool isLightTheme,
      List<Priorities> priorityModel, int index, dateCreated, color) {
    return index == 0
        ? ShakeWidget(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 0.w),
                child: DismissibleCard(
                  title: priority.id!.toString(),
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
                          print("Handling deletion directly in confirmDismiss");
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              priorityModel.removeAt(index);
                            });
                            context
                                .read<PriorityBloc>()
                                .add(DeletePriority(priority.id!));
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
                      _createEditPriority(
                          isLightTheme: isLightTheme,
                          isCreate: false,
                          id: priority.id,
                          title: priority.title,
                          color: priority.color);
                      // Perform the edit action if needed
                      return false; // Prevent dismiss
                    }
                    // flutterToastCustom(
                    //     msg: AppLocalizations.of(context)!.isDemooperation);
                    return false; // Default case
                  },
                  dismissWidget: _priorityCard(
                    isLightTheme,
                    priority,
                    color,
                  ),
                  onDismissed: (DismissDirection direction) {
                    // This will not be called if `confirmDismiss` returned `false`
                    if (direction == DismissDirection.endToStart) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          priorityModel.removeAt(index);

                          // _onDeleteTodos(status);
                        });
                        context
                            .read<PriorityBloc>()
                            .add(DeletePriority(priority.id!));

                        // _onDeleteTodos(status);
                      });
                    }
                  },
                )),
          )
        : Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 0.w),
            child: DismissibleCard(
              title: priority.id!.toString(),
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
                      print("Handling deletion directly in confirmDismiss");
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          priorityModel.removeAt(index);
                        });
                        context
                            .read<PriorityBloc>()
                            .add(DeletePriority(priority.id!));
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
                  _createEditPriority(
                      isLightTheme: isLightTheme,
                      isCreate: false,
                      id: priority.id,
                      title: priority.title,
                      color: priority.color);
                  // Perform the edit action if needed
                  return false; // Prevent dismiss
                }
                // flutterToastCustom(
                //     msg: AppLocalizations.of(context)!.isDemooperation);
                return false; // Default case
              },
              dismissWidget: _priorityCard(
                isLightTheme,
                priority,
                color,
              ),
              onDismissed: (DismissDirection direction) {
                // This will not be called if `confirmDismiss` returned `false`
                if (direction == DismissDirection.endToStart) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      priorityModel.removeAt(index);

                      // _onDeleteTodos(status);
                    });
                    context
                        .read<PriorityBloc>()
                        .add(DeletePriority(priority.id!));

                    // _onDeleteTodos(status);
                  });
                }
              },
            ));
  }

  Widget _priorityCard(
    isLightTheme,
    status,
    color,
  ) {
    Color? colorOfStatus;
    switch (color) {
      case "primary":
        colorOfStatus = AppColors.primary;
        break;
      case "secondary":
        colorOfStatus = Color(0xFF8592a3);
        break;
      case "success":
        colorOfStatus = Colors.green;
        break;
      case "danger":
        colorOfStatus = Colors.red;
        break;
      case "warning":
        colorOfStatus = Color(0xFFfaab01);
        break;
      case "info":
        colorOfStatus = Color(0xFF36c3ec);
        break;
      case "dark":
        colorOfStatus = Colors.black;
        break;
      default:
        colorOfStatus = Colors.grey; // Fallback color
    }
    String dateCreated = formatDateFromApi(status.createdAt!, context);
    String dateUpdated = formatDateFromApi(status.updatedAt!, context);

    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
          ],
          color: Theme.of(context).colorScheme.containerDark,
          borderRadius: BorderRadius.circular(12)),
      // height: 100.h,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.h),
            child: SizedBox(
              width: double.infinity,
              // color: Colors.red,
              // height: 70.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "#${status.id.toString()}",
                    size: 14.sp,
                    color: Theme.of(context).colorScheme.textClrChange,
                    fontWeight: FontWeight.w700,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  CustomText(
                    text: status.title!,
                    size: 16.sp,
                    color: Theme.of(context).colorScheme.textClrChange,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(
                    height: 18.h,
                  ),
                  Row(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: 25.h,
                        // width: 110.w, //
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color:
                                colorOfStatus), // Set the height of the dropdown
                        child: Center(
                          child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: CustomText(
                                text: status.title!,
                                color: AppColors.whiteColor,
                                size: 14.sp,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.backGroundColor,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 5.h),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CustomText(
                          text:
                              "📅 ${AppLocalizations.of(context)!.createdat} : ",
                          size: 13.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w600,
                        ),
                        CustomText(
                          text: dateCreated,
                          size: 12.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Row(
                      children: [
                        CustomText(
                          text:
                              "📅 ${AppLocalizations.of(context)!.updatedAt} : ",
                          size: 13.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w600,
                        ),
                        CustomText(
                          text: dateUpdated,
                          size: 12.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _createEditPriority(
      {isLightTheme, isCreate, int? id, title, color}) {
    if (isCreate) {
      titleController.text = '';
    } else {
      titleController.text = title;
      selectedColorName = color;
    }
    return showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(// This ensures the modal content updates
              builder: (context, setState) {
            void _handleAccessSelected(String colorName) {
              setState(() {
                selectedColorName = colorName;
                // Debugging
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: const [],
                  borderRadius: BorderRadius.circular(25),
                  color: Theme.of(context).colorScheme.backGroundColor,
                ),
                height: 380.h,
                child: Center(
                  child: Form(
                    key: _createEditPriorityKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          child: BackArrow(
                            title: isCreate == false
                                ? AppLocalizations.of(context)!.editpriorities
                                : AppLocalizations.of(context)!
                                    .createpriorities,
                            iSBackArrow: false,
                            iscreatePermission: true,
                            onPress: () {
                              print("dgfkgv ");
                              _createEditPriority(
                                  isLightTheme: isLightTheme, isCreate: true);
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        CustomTextFields(
                          title: AppLocalizations.of(context)!.title,
                          hinttext:
                              AppLocalizations.of(context)!.pleaseentertitle,
                          controller: titleController,
                          onSaved: (value) {},
                          onFieldSubmitted: (value) {},
                          isLightTheme: isLightTheme,
                          isRequired: true,
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        ColorField(
                          isRequired: true,
                          isCreate: isCreate ?? false,
                          name: selectedColorName ?? "",
                          onSelected: _handleAccessSelected,
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        SizedBox(
                          height: 25.h,
                        ),
                        BlocBuilder<PriorityBloc, PriorityState>(
                            builder: (context, state) {
                          if (state is PriorityEditSuccessLoading) {
                            return CreateCancelButtom(
                              isLoading: true,
                              isCreate: isCreate,
                              onpressCreate: isCreate == true
                                  ? () async {}
                                  : () {
                                      _onEditPriority(id, title, color);
                                      // context.read<TodosBloc>().add(const TodosList());
                                      // Navigator.pop(context);
                                    },
                              onpressCancel: () {
                                Navigator.pop(context);
                              },
                            );
                          }
                          if (state is PriorityCreateSuccessLoading) {
                            return CreateCancelButtom(
                              isLoading: true,
                              isCreate: isCreate,
                              onpressCreate: isCreate == true
                                  ? () async {
                                      _onCreatePriority();
                                    }
                                  : () {
                                      _onEditPriority(id, title, color);
                                      // context.read<TodosBloc>().add(const TodosList());
                                      // Navigator.pop(context);
                                    },
                              onpressCancel: () {
                                Navigator.pop(context);
                              },
                            );
                          }
                          return CreateCancelButtom(
                            isCreate: isCreate,
                            onpressCreate: isCreate == true
                                ? () async {
                                    _onCreatePriority();
                                  }
                                : () {
                                    _onEditPriority(id, title, color);
                                    // context.read<TodosBloc>().add(const TodosList());
                                    // Navigator.pop(context);
                                  },
                            onpressCancel: () {
                              Navigator.pop(context);
                            },
                          );
                        })
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }
}
