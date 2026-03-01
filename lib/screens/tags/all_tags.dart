import 'dart:math';
import '../../../src/generated/i18n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/tags/tags_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/model/tags/tag_model.dart';
import 'package:taskify/screens/notes/widgets/notes_shimmer_widget.dart';
import 'package:taskify/screens/status/widgets/color_fiield.dart';
import 'package:taskify/utils/widgets/custom_dimissible.dart';
import 'package:taskify/utils/widgets/shake_widget.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../bloc/roles_multi/role_multi_bloc.dart';
import '../../bloc/roles_multi/role_multi_event.dart';
import '../../bloc/tags/tags_bloc.dart';
import '../../bloc/tags/tags_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../config/constants.dart';
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
import '../widgets/search_field.dart';
import '../widgets/side_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
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

    BlocProvider.of<TagsBloc>(context).add(TagsList());
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
    context.read<TagsBloc>().add(SearchTags(_lastWords));
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
      context.read<TagsBloc>().add(CreateTag(
        title: titleController.text.toString(),
        color: selectedColorName?.toLowerCase() ?? "",

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
      context.read<TagsBloc>().add(UpdateTag(
          id: id, title: titleController.text, color: color));
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
    Navigator.pop(context);
  }

  void _onDeleteTags(tag) {
    context.read<TagsBloc>().add(DeleteTag(tag));

  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    BlocProvider.of<TagsBloc>(context).add(TagsList());
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
                                  .read<TagsBloc>()
                                  .add(SearchTags(""));
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
                    context.read<TagsBloc>().add(SearchTags(value));

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
          child: BlocConsumer<TagsBloc, TagsState>(
            listener: (context, state) {
              if (state is TagsSuccess) {
                isLoadingMore = false;
                setState(() {});
              }
            },
            builder: (context, state) {
              print("fnjuhdkcm,$state");
              if (state is TagsLoading || state is TagCreateLoading || state is TagEditLoading) {
                return const NotesShimmer();
              } else if (state is TagDeleteSuccess) {
                flutterToastCustom(
                    msg: AppLocalizations.of(context)!.deletedsuccessfully,
                    color: AppColors.primary);
                BlocProvider.of<TagsBloc>(context).add(TagsList());

              }
               else if (state is TagsSuccess) {
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
                          .read<TagsBloc>()
                          .add(TagsLoadMore(search: searchWord));
                    }
                    return false;
                  },
                  child: state.tag.isNotEmpty

                      ? _tagLists(
                    isLightTheme,
                    state.isLoadingMore,
                    state.tag,
                  )
                      : NoData(
                    isImage: true,
                  ),
                );
              } else if (state is TagsError) {
                BlocProvider.of<TagsBloc>(context).add(TagsList());

                return SizedBox();
              } else if (state is TagEditSuccess) {
                BlocProvider.of<TagsBloc>(context).add(TagsList());
                flutterToastCustom(
                    msg: AppLocalizations.of(context)!.updatedsuccessfully,
                    color: AppColors.primary);
              } else if (state is TagEditError) {
                BlocProvider.of<TagsBloc>(context).add(TagsList());

                flutterToastCustom(
                    msg: state.errorMessage, color: AppColors.primary);
              } else if (state is TagsError) {
                BlocProvider.of<TagsBloc>(context).add(TagsList());
                flutterToastCustom(
                    msg: state.errorMessage, color: AppColors.primary);
              }
              else if (state is TagsSuccess) {
                // Show initial list of notes
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 10, // Horizontal spacing
                    mainAxisSpacing: 10, // Vertical spacing
                    childAspectRatio: 1, // Width/Height ratio
                  ),
                  itemCount: state.tag.length +
                      1, // Add 1 for the loading indicator
                  itemBuilder: (context, index) {
                    if (index < state.tag.length) {
                      final tag = state.tag[index];
                      String? dateCreated;
                      DateTime createdDate =
                      parseDateStringFromApi(tag.createdAt!);
                      dateCreated = dateFormatConfirmed(createdDate, context);
                      return state.tag.isEmpty
                          ? NoData(
                        isImage: true,
                      )
                          : _statusListContainer(tag, isLightTheme,
                          state.tag, index, dateCreated, "priority");
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
              }
              else if (state is TagCreateSuccess) {
                Navigator.pop(context);
                flutterToastCustom(
                    msg: AppLocalizations.of(context)!.createdsuccessfully,
                    color: AppColors.primary);
                BlocProvider.of<TagsBloc>(context).add(TagsList());

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
        title: AppLocalizations.of(context)!.tags,
        isAdd: true,

        onPress: () {
          print("kjfvnm");
          _createEditTag(isLightTheme: isLightTheme, isCreate: true);
        },
      ),
    );
  }

  Widget _tagLists(isLightTheme, hasReachedMax, tagList) {
    // statusList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

    // Reverse the list so the last item appears first
    tagList = tagList.reversed.toList();
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: hasReachedMax
          ? tagList.length // No extra item if all data is loaded
          : tagList.length + 1,
      itemBuilder: (context, index) {
        print("ctfgvbhjnkm$index");
        print("ctfgvbhjnkm${tagList.length}");
        if (index < tagList.length) {
          final status = tagList[index];
          String? dateCreated;
          DateTime createdDate = parseDateStringFromApi(status.createdAt!);
          dateCreated = dateFormatConfirmed(createdDate, context);
          return tagList.isEmpty
              ? NoData(
            isImage: true,
          )
              : _statusListContainer(status, isLightTheme, tagList, index,
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

  Future<void> _createEditTag(
      {isLightTheme,
        isCreate,
        status,
        Statuses,
        int? id,
        title,
        color,
        }) {

    if (isCreate) {
      titleController.text = '';
      descController.text = '';

      // selectedColor=color;
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
                    print("Selected Color Updated: $selectedColorName"); // Debugging
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
                    height: 330.h,
                    child: Form(
                      key: _createEditStatusKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18.w),
                            child: BackArrow(
                              isBottomSheet: true,
                              title: isCreate == false
                                  ? AppLocalizations.of(context)!.edittag
                                  : AppLocalizations.of(context)!.createtag,
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
                            height: 25.h,
                          ),
                          BlocBuilder<TagsBloc, TagsState>(
                              builder: (context, state) {
                                if (state is TagEditLoading) {
                                  return CreateCancelButtom(
                                    isLoading: true,
                                    isCreate: isCreate,
                                    onpressCreate: isCreate == true
                                        ? () async {}
                                        : () {
                                      _onEditStatus(id, title, color);

                                    },
                                    onpressCancel: () {
                                      Navigator.pop(context);
                                    },
                                  );
                                }
                                if (state is TagCreateLoading) {
                                  return CreateCancelButtom(
                                    isLoading: true,
                                    isCreate: isCreate,
                                    onpressCreate: isCreate == true
                                        ? () async {

                                    }
                                        : () {
                                      _onEditStatus(id, title, color);
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
                                    _onEditStatus(id, titleController.text, selectedColorName);

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

  Widget _statusListContainer(TagsModel tag, bool isLightTheme,
      List<TagsModel> tagModel, int index, dateCreated, color) {
    return index == 0
        ? ShakeWidget(
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 0.w),
          child: DismissibleCard(
            title: tag.id!.toString(),
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
                        tagModel.removeAt(index);

                      });
                      _onDeleteTags(tag.id);                    });
                    // Return false to prevent the dismissible from animating
                    return false;
                  }

                  return false; // Always return false since we handle deletion manually
                } catch (e) {
                  print("Error in dialog: $e");
                  return false;
                }// Return the result of the dialog
              } else if (direction == DismissDirection.startToEnd) {

                _createEditTag(
                  isLightTheme: isLightTheme,
                  isCreate: false,
                  status: tag,
                  Statuses: tagModel,
                  id: tag.id,
                  title: tag.title,
                  color: tag.color,
                );
                // Perform the edit action if needed
                return false; // Prevent dismiss
              }
              // flutterToastCustom(
              //     msg: AppLocalizations.of(context)!.isDemooperation);
              return false; // Default case
            },
            dismissWidget:
            _tagCard(isLightTheme, tag, color, ),
            onDismissed: (DismissDirection direction) {
              // This will not be called if `confirmDismiss` returned `false`
              if (direction == DismissDirection.endToStart) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    tagModel.removeAt(index);
                  });
                  _onDeleteTags(tag.id);                });
              }
            },
          )),
    )
        : Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 0.w),
        child: DismissibleCard(
          title: tag.id!.toString(),
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
                      tagModel.removeAt(index);

                    });
                    _onDeleteTags(tag.id);                    });
                  // Return false to prevent the dismissible from animating
                  return false;
                }

                return false; // Always return false since we handle deletion manually
              } catch (e) {
                print("Error in dialog: $e");
                return false;
              }// Return the result of the dialog
            } else if (direction == DismissDirection.startToEnd) {

              _createEditTag(
                isLightTheme: isLightTheme,
                isCreate: false,
                status: tag,
                Statuses: tagModel,
                id: tag.id,
                title: tag.title,
                color: tag.color,
              );
              // Perform the edit action if needed
              return false; // Prevent dismiss
            }
            // flutterToastCustom(
            //     msg: AppLocalizations.of(context)!.isDemooperation);
            return false; // Default case
          },
          dismissWidget:
          _tagCard(isLightTheme, tag, color, ),
          onDismissed: (DismissDirection direction) {
            // This will not be called if `confirmDismiss` returned `false`
            if (direction == DismissDirection.endToStart) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  tagModel.removeAt(index);
                });
                _onDeleteTags(tag.id);                });
            }
          },
        ));
  }

  Widget _tagCard(isLightTheme, status, color, ) {
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
      case "warning" :
      case "Warning" :
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
    String  dateCreated = formatDateFromApi(status.createdAt!, context);
    String  dateUpdated = formatDateFromApi(status.updatedAt!, context);
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
                    color:
                    Theme.of(context).colorScheme.textClrChange,
                    fontWeight: FontWeight.w700,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5.h,),
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
                          color: colorOfStatus ,
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
                color:  Theme
                    .of(context)
                    .colorScheme
                    .backGroundColor,
              ),
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 18.w,vertical: 5.h),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CustomText(
                          text:"📅 ${ AppLocalizations.of(context)!.createdat} : ",
                          size: 13.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w600,
                        ),  CustomText(
                          text:dateCreated,
                          size: 12.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h,),
                    Row(
                      children: [
                        CustomText(
                          text:"📅 ${ AppLocalizations.of(context)!.updatedAt} : ",
                          size: 13.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w600,
                        ),  CustomText(
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
