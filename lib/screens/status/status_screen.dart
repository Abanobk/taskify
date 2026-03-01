import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/notes/widgets/notes_shimmer_widget.dart';
import 'package:taskify/screens/status/widgets/color_fiield.dart';
import 'package:taskify/utils/widgets/custom_dimissible.dart';
import 'package:taskify/utils/widgets/shake_widget.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../bloc/roles_multi/role_multi_bloc.dart';
import '../../bloc/roles_multi/role_multi_event.dart';
import '../../bloc/status/status_bloc.dart';
import '../../bloc/status/status_event.dart';
import '../../bloc/status/status_state.dart';
import '../../bloc/todos/todos_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../config/constants.dart';
import '../../data/model/status_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../utils/widgets/custom_text.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/search_pop_up.dart';
import '../widgets/custom_cancel_create_button.dart';
import '../widgets/no_data.dart';
import '../widgets/custom_textfields/custom_textfield.dart';
import '../widgets/role_multi_field.dart';
import '../widgets/search_field.dart';
import '../widgets/side_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../../../src/generated/i18n/app_localizations.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  DateTime now = DateTime.now();
  final GlobalKey<FormState> _createEditStatusKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController startsController = TextEditingController();
  final GlobalKey globalKeyOne = GlobalKey();
  final GlobalKey globalKeyTwo = GlobalKey();
  final GlobalKey globalKeyThree = GlobalKey();
  bool isLoadingMore = false;
  String? selectedPriority;
  List<String>? selectedRoleName;
  int? selectedPriorityId;
  List<int>? selectedRoleId;
  bool? isLoading = true;
  bool? isFirst = false;
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = "";
  String searchWord = "";
  bool isListening =
      false; // Flag to track if speech recognition is in progress
  bool dialogShown = false;
  FocusNode? titleFocus, descFocus, startsFocus, endFocus = FocusNode();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  String priorityName = "Priority";
  bool shouldDisableEdit = true;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String? selectedColorName;
  String? colorIs;

  int? selectedColorId;
  static final bool _onDevice = false;

  double level = 0.0;

  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);
  String? selectedCategory;

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

  @override
  void initState() {
    super.initState();
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

    BlocProvider.of<StatusBloc>(context).add(StatusList());
    BlocProvider.of<RoleMultiBloc>(context).add(RoleMultiList());
    listenForPermissions();
    if (!_speechEnabled) {
      _initSpeech();
    }
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
    context.read<StatusBloc>().add(SearchStatus(_lastWords));
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
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _onCreateStatus() {
    if (titleController.text.isNotEmpty) {
      print("gfhjdgkdjgxn $selectedColorName");
      print("gfhjdgkdjgxn $selectedRoleId");
      context.read<StatusBloc>().add(CreateStatus(
            title: titleController.text.toString(),
            color: selectedColorName?.toLowerCase() ?? "",
            roleId: selectedRoleId!,
          ));

      // statusBloc.add(StatusList());
    } else {
      flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleasefilltherequiredfield);
    }
  }

  void _onEditStatus(id, title, color) async {
    if (titleController.text.isNotEmpty && color != null) {
      print("grnhvkjm $color");
      context.read<StatusBloc>().add(UpdateStatus(
          id: id,
          title: titleController.text,
          color: color,
          roleId: selectedRoleId ?? []));
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
    Navigator.pop(context);
  }

  void _onDeleteTodos(todos) {
    context.read<StatusBloc>().add(DeleteStatus(todos));
    final setting = context.read<StatusBloc>();
    setting.stream.listen((state) {
      if (state is StatusDeleteSuccess) {
        if (mounted) {
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
        BlocProvider.of<StatusBloc>(context).add(StatusList());
      } else if (state is StatusError) {
        flutterToastCustom(
          msg: state.errorMessage,
        );
      }
      // BlocProvider.of<TodosBloc>(context).add(TodosList());
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    BlocProvider.of<StatusBloc>(context).add(StatusList());
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
                                  searchController.clear();
                                  // Optionally trigger the search event with an empty string
                                  context
                                      .read<StatusBloc>()
                                      .add(SearchStatus(""));
                                },
                              ),
                            ),
                          IconButton(
                            icon: Icon(
                              _speechToText.isNotListening
                                  ? Icons.mic_off
                                  : Icons.mic,
                              size: 20.sp,
                              color:
                                  Theme.of(context).colorScheme.textFieldColor,
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
                        _lastWords = value;
                        context.read<StatusBloc>().add(SearchStatus(value));
                      },
                    ),
                    SizedBox(height: 20.h),
                    _body(isLightTheme)
                  ],
                ),
              ),
            ));
  }

  Widget _body(isLightTheme) {
    return Expanded(
      child: RefreshIndicator(
        color: AppColors.primary, // Spinner color
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        onRefresh: _onRefresh,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: BlocConsumer<StatusBloc, StatusState>(
            listener: (context, state) {
              if (state is StatusSuccess) {
                isLoadingMore = false;
                setState(() {});
              }
            },
            builder: (context, state) {
              print("fnjuhdkcm,$state");
              if (state is StatusLoading) {
                return const NotesShimmer(
                  paddingNeeded: false,
                );
              } else if (state is StatusEditLoading) {
                return Expanded(
                    child: const NotesShimmer(
                  paddingNeeded: false,
                ));
              } else if (state is StatusSuccess) {
                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (!state.isLoadingMore &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent &&
                        isLoadingMore == false) {
                      print("ekfsndm ");
                      isLoadingMore = true;
                      setState(() {});
                      context
                          .read<StatusBloc>()
                          .add(StatusLoadMore(searchWord));
                    }
                    return false;
                  },
                  child: state.status.isNotEmpty
                      ? _statusLists(
                          isLightTheme,
                          state.isLoadingMore,
                          state.status,
                        )
                      : NoData(
                          isImage: true,
                        ),
                );
              } else if (state is StatusError) {
                return SizedBox();
              } else if (state is StatusEditSuccess) {
                BlocProvider.of<StatusBloc>(context).add(StatusList());
                flutterToastCustom(
                    msg: AppLocalizations.of(context)!.updatedsuccessfully,
                    color: AppColors.primary);
              } else if (state is StatusEditError) {
                BlocProvider.of<StatusBloc>(context).add(StatusList());
                flutterToastCustom(
                    msg: state.errorMessage, color: AppColors.primary);
              } else if (state is StatusSuccess) {
                // Show initial list of notes
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 10, // Horizontal spacing
                    mainAxisSpacing: 10, // Vertical spacing
                    childAspectRatio: 1, // Width/Height ratio
                  ),
                  itemCount: state.status.length +
                      1, // Add 1 for the loading indicator
                  itemBuilder: (context, index) {
                    if (index < state.status.length) {
                      final status = state.status[index];
                      String? dateCreated;
                      DateTime createdDate =
                          parseDateStringFromApi(status.createdAt!);
                      dateCreated = dateFormatConfirmed(createdDate, context);
                      return state.status.isEmpty
                          ? NoData(
                              isImage: true,
                            )
                          : _statusListContainer(status, isLightTheme,
                              state.status, index, dateCreated, "priority");
                    } else {
                      // Show a loading indicator when more notes are being loaded
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: SpinKitFadingCircle(
                            color: AppColors.primary,
                            size: 40.0,
                          ),
                        ),
                      );
                    }
                  },
                );
              } else if (state is StatusCreateSuccess) {
                Navigator.pop(context);
                flutterToastCustom(
                    msg: AppLocalizations.of(context)!.createdsuccessfully,
                    color: AppColors.primary);
                BlocProvider.of<StatusBloc>(context).add(StatusList());

                selectedColorName = "";
              }
              // Handle other states
              return const Text("");
            },
          ),
        ),
      ),
    );
  }

  Widget _appBar(isLightTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: BackArrow(
        iSBackArrow: true,
        iscreatePermission: true,
        title: AppLocalizations.of(context)!.status,
        isAdd: true,
        onPress: () {
          print("kjfvnm");
          _createEditStatus(isLightTheme: isLightTheme, isCreate: true);
        },
      ),
    );
  }

  Widget _statusLists(isLightTheme, hasReachedMax, statusList) {
    // statusList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

    // Reverse the list so the last item appears first
    statusList = statusList.reversed.toList();
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: hasReachedMax
          ? statusList.length // No extra item if all data is loaded
          : statusList.length + 1,
      itemBuilder: (context, index) {
        if (index < statusList.length) {
          final status = statusList[index];
          String? dateCreated;
          DateTime createdDate = parseDateStringFromApi(status.createdAt!);
          dateCreated = dateFormatConfirmed(createdDate, context);
          return statusList.isEmpty
              ? NoData(
                  isImage: true,
                )
              : _statusListContainer(status, isLightTheme, statusList, index,
                  dateCreated, status.color);
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

  Future<void> _createEditStatus(
      {isLightTheme,
      isCreate,
      status,
      Statuses,
      int? id,
      title,
      color,
      Roles? statusName}) {
    if (isCreate) {
      titleController.text = '';
      descController.text = '';
      selectedRoleName = [];
      // selectedColor=color;
    } else {
      titleController.text = title;
      selectedColorName = color;
      selectedRoleName = statusName!.names ?? [];
      selectedRoleId = statusName.ids ?? [];
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
                print(
                    "Selected Color Updated: $selectedColorName"); // Debugging
              });
            }

            void _handleStatusSelected(
                List<String>? category, List<int>? catId) {
              print("fsdfgrfrf $category");
              print("fsdfgrfrf $catId");
              setState(() {
                selectedRoleName = category;
                selectedRoleId = catId;
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  boxShadow: const [],
                  borderRadius: BorderRadius.circular(25),
                  color: Theme.of(context).colorScheme.backGroundColor,
                ),
                height: 410.h,
                child: Form(
                  key: _createEditStatusKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: BackArrow(
                          title: isCreate == false
                              ? AppLocalizations.of(context)!.editstatus
                              : AppLocalizations.of(context)!.createstatus,
                          iSBackArrow: false,
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
                      RoleMultiField(
                        nameId: selectedRoleId,
                        isRequired: false,
                        title:
                            AppLocalizations.of(context)!.rolesCanSettheStatus,
                        isCreate: isCreate ?? false,
                        name: selectedRoleName ?? [],
                        onSelectedRoleMulti: _handleStatusSelected,
                        fromProfile: false,
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                      BlocBuilder<StatusBloc, StatusState>(
                          builder: (context, state) {
                        if (state is TodosEditSuccessLoading) {
                          return CreateCancelButtom(
                            isLoading: true,
                            isCreate: isCreate,
                            onpressCreate: isCreate == true
                                ? () async {}
                                : () {
                                    _onEditStatus(id, title, color);
                                    // context.read<TodosBloc>().add(const TodosList());
                                    // Navigator.pop(context);
                                  },
                            onpressCancel: () {
                              Navigator.pop(context);
                            },
                          );
                        }
                        if (state is TodosCreateSuccessLoading) {
                          return CreateCancelButtom(
                            isLoading: true,
                            isCreate: isCreate,
                            onpressCreate: isCreate == true
                                ? () async {
                                    // _onCreateTodos();
                                  }
                                : () {
                                    _onEditStatus(id, title, color);
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
                                  _onCreateStatus();
                                }
                              : () {
                                  _onEditStatus(id, titleController.text,
                                      selectedColorName);
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
            );
          });
        });
  }

  Widget _statusListContainer(Statuses status, bool isLightTheme,
      List<Statuses> statusModel, int index, dateCreated, color) {
    return index == 0
        ? ShakeWidget(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 0.w),
                child: DismissibleCard(
                  key: ValueKey(status.id),
                  title: status.id!.toString(),
                  confirmDismiss: (DismissDirection direction) async {
                    if (direction == DismissDirection.endToStart) {
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
                              statusModel.removeAt(index);
                            });
                            _onDeleteTodos(status.id);
                          });
                          // Return false to prevent the dismissible from animating
                          return false;
                        }

                        return false; // Always return false since we handle deletion manually
                      } catch (e) {
                        print("Error in dialog: $e");
                        return false;
                      }
                    } else if (direction == DismissDirection.startToEnd) {
                      print("dfjksfksdj h ${status.roles}");
                      _createEditStatus(
                        isLightTheme: isLightTheme,
                        isCreate: false,
                        status: status,
                        Statuses: statusModel,
                        id: status.id,
                        title: status.title,
                        color: status.color,
                        statusName: status.roles,
                      );
                      return false; // Prevent dismiss
                    }
                    return false; // Default case
                  },
                  dismissWidget:
                      _statusCard(isLightTheme, status, color, status.roles),
                  onDismissed: (DismissDirection direction) {
                    if (direction == DismissDirection.endToStart) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          statusModel.removeAt(index);
                        });
                        _onDeleteTodos(status.id);
                      });
                    }
                  },
                )),
          )
        : Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 0.w),
            child: DismissibleCard(
              key: ValueKey(status.id),
              title: status.id!.toString(),
              confirmDismiss: (DismissDirection direction) async {
                if (direction == DismissDirection.endToStart) {
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
                          statusModel.removeAt(index);
                        });
                        _onDeleteTodos(status.id);
                      });
                      // Return false to prevent the dismissible from animating
                      return false;
                    }

                    return false; // Always return false since we handle deletion manually
                  } catch (e) {
                    print("Error in dialog: $e");
                    return false;
                  }
                } else if (direction == DismissDirection.startToEnd) {
                  print("dfjksfksdj h ${status.roles}");
                  _createEditStatus(
                    isLightTheme: isLightTheme,
                    isCreate: false,
                    status: status,
                    Statuses: statusModel,
                    id: status.id,
                    title: status.title,
                    color: status.color,
                    statusName: status.roles,
                  );
                  return false; // Prevent dismiss
                }
                return false; // Default case
              },
              dismissWidget:
              _statusCard(isLightTheme, status, color, status.roles),
              onDismissed: (DismissDirection direction) {
                if (direction == DismissDirection.endToStart) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      statusModel.removeAt(index);
                    });
                    _onDeleteTodos(status.id);
                  });
                }
              },
            ));
  }
// Add this to your class as a member variable
//   Set<int> _dismissedItems = <int>{};
//
//   Widget _statusListContainer(Statuses status, bool isLightTheme,
//       List<Statuses> statusModel, int index, dateCreated, color) {
//
//     // Don't render if item is already dismissed
//     if (_dismissedItems.contains(status.id)) {
//       return const SizedBox.shrink();
//     }
//
//     return index == 0
//         ? ShakeWidget(
//       child: Padding(
//           padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 0.w),
//           child: DismissibleCard(
//             key: ValueKey(status.id),
//             title: status.id!.toString(),
//             confirmDismiss: (DismissDirection direction) async {
//               if (direction == DismissDirection.endToStart) {
//                 final result = await showDialog(
//                   context: context,
//                   builder: (context) {
//                     return AlertDialog(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10.r),
//                       ),
//                       backgroundColor: Theme.of(context)
//                           .colorScheme
//                           .alertBoxBackGroundColor,
//                       title: Text(
//                           AppLocalizations.of(context)!.confirmDelete),
//                       content:
//                       Text(AppLocalizations.of(context)!.areyousure),
//                       actions: [
//                         TextButton(
//                           onPressed: () {
//                             Navigator.of(context).pop(true);
//                           },
//                           child:
//                           Text(AppLocalizations.of(context)!.delete),
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             Navigator.of(context).pop(false);
//                           },
//                           child:
//                           Text(AppLocalizations.of(context)!.cancel),
//                         ),
//                       ],
//                     );
//                   },
//                 );
//                 return result;
//               } else if (direction == DismissDirection.startToEnd) {
//                 _createEditStatus(
//                   isLightTheme: isLightTheme,
//                   isCreate: false,
//                   status: status,
//                   Statuses: statusModel,
//                   id: status.id,
//                   title: status.title,
//                   color: status.color,
//                   statusName: status.roles,);
//                 return false;
//               }
//               return false;
//             },
//             dismissWidget:
//             _statusCard(isLightTheme, status, color, status.roles),
//             onDismissed: (DismissDirection direction) {
//               if (direction == DismissDirection.endToStart) {
//                 final idToDelete = status.id;
//
//                 // Mark as dismissed immediately
//                 _dismissedItems.add(idToDelete!);
//
//                 if (mounted) {
//                   setState(() {
//                     statusModel.removeWhere((e) => e.id == idToDelete);
//                   });
//                   _onDeleteTodos(idToDelete);
//                 }
//               }
//             },
//           )),
//     )
//         : Padding(
//         padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 0.w),
//         child: DismissibleCard(
//           key: ValueKey(status.id),
//           title: status.id!.toString(),
//           confirmDismiss: (DismissDirection direction) async {
//             if (direction == DismissDirection.endToStart) {
//               final result = await showDialog(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.r),
//                     ),
//                     backgroundColor: Theme.of(context)
//                         .colorScheme
//                         .alertBoxBackGroundColor,
//                     title:
//                     Text(AppLocalizations.of(context)!.confirmDelete),
//                     content: Text(AppLocalizations.of(context)!.areyousure),
//                     actions: [
//                       TextButton(
//                         onPressed: () {
//                           Navigator.of(context).pop(true);
//                         },
//                         child: Text(AppLocalizations.of(context)!.delete),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.of(context).pop(false);
//                         },
//                         child: Text(AppLocalizations.of(context)!.cancel),
//                       ),
//                     ],
//                   );
//                 },
//               );
//               return result;
//             } else if (direction == DismissDirection.startToEnd) {
//               _createEditStatus(
//                 isLightTheme: isLightTheme,
//                 isCreate: false,
//                 status: status,
//                 Statuses: statusModel,
//                 id: status.id,
//                 title: status.title,
//                 color: status.color,
//                 statusName: status.roles, );
//               return false;
//             }
//             return false;
//           },
//           dismissWidget:
//           _statusCard(isLightTheme, status, color, status.roles),
//           onDismissed: (DismissDirection direction) {
//             if (direction == DismissDirection.endToStart) {
//               final idToDelete = status.id;
//
//               // Mark as dismissed immediately
//               _dismissedItems.add(idToDelete!);
//
//               if (mounted) {
//                 setState(() {
//                   statusModel.removeWhere((e) => e.id == idToDelete);
//                 });
//                 _onDeleteTodos(idToDelete);
//               }
//             }
//           },
//         ));
//   }

  Widget _statusCard(isLightTheme, status, color, roles) {
    Color? colorOfStatus;
    switch (color) {
      case "primary":
      case "Primary":
        colorOfStatus = AppColors.primary;
        break;
      case "secondary":
      case "Secondary":
        colorOfStatus = Color(0xFF8592a3);
        break;
      case "success":
      case "Success":
        colorOfStatus = Colors.green;
        break;
      case "danger":
      case "Danger":
        colorOfStatus = Colors.red;
        break;
      case "warning":
      case "Warning":
        colorOfStatus = Color(0xFFfaab01);
        break;
      case "info":
      case "Info":
        colorOfStatus = Color(0xFF36c3ec);
        break;
      case "dark":
      case "Dark":
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: colorOfStatus,
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: CustomText(
                              text: status.title!,
                              color: AppColors.whiteColor,
                              size: 14.sp,
                              fontWeight: FontWeight.w600,
                              maxLines: 2, // Allows text to go to another line
                              overflow: TextOverflow.visible,
                              softwrap: true,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          width: 1.5,
                          height: 18,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Flexible(
                        child: CustomText(
                          text: roles.names.isNotEmpty
                              ? roles.names.join(', ')
                              : " no roles",
                          size: 16.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w600,
                          maxLines: 2, // Allows text to wrap
                          overflow: TextOverflow.visible,
                          softwrap: true,
                        ),
                      ),
                    ],
                  )
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
}
