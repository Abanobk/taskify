import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:taskify/bloc/setting/settings_bloc.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/notes/widgets/notes_shimmer_widget.dart';
import 'package:taskify/utils/widgets/custom_dimissible.dart';
import 'package:taskify/utils/widgets/shake_widget.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../bloc/dashboard_stats/dash_board_stats_bloc.dart';
import '../../bloc/dashboard_stats/dash_board_stats_event.dart';
import '../../bloc/dashboard_stats/dash_board_stats_state.dart';
import '../../bloc/setting/settings_event.dart';
import '../../bloc/todos/todos_bloc.dart';
import '../../bloc/todos/todos_event.dart';
import '../../bloc/todos/todos_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../config/constants.dart';
import '../../data/model/dashboard_stats/dashboard_stats_model.dart';
import '../../data/model/todos/todo_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_text.dart';
import 'package:heroicons/heroicons.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/search_pop_up.dart';
import '../notes/widgets/priority_field.dart';
import '../widgets/custom_cancel_create_button.dart';
import '../widgets/no_data.dart';
import '../widgets/custom_textfields/custom_textfield.dart';
import '../widgets/search_field.dart';
import '../widgets/side_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../../../src/generated/i18n/app_localizations.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key});

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  DateTime now = DateTime.now();
  final GlobalKey<FormState> _createTodoKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController startsController = TextEditingController();
  final GlobalKey globalKeyOne = GlobalKey();
  final GlobalKey globalKeyTwo = GlobalKey();
  final GlobalKey globalKeyThree = GlobalKey();
  bool isLoadingMore = false;
  String? selectedPriority;
  int? selectedPriorityId;
  bool? isLoading = true;
  bool? isFirst = false;
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = "";
  bool isListening =
      false; // Flag to track if speech recognition is in progress
  bool dialogShown = false;
  FocusNode? titleFocus, descFocus, startsFocus, endFocus = FocusNode();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  String priorityname = "Priority";
  bool shouldDisableEdit = true;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  static final bool _onDevice = false;

  double level = 0.0;
  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);
  String? selectedCategory;
  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
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
    BlocProvider.of<TodosBloc>(context).add(TodosList());
    BlocProvider.of<SettingsBloc>(context)
        .add(SettingsList("general_settings"));
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

  String getResponsiveRadius(double percentage) {
    return '${percentage}%';
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
    context.read<TodosBloc>().add(SearchTodos(_lastWords));
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

  void _handleCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  void _onCreateTodos() {
    if (titleController.text.isNotEmpty && selectedCategory != null) {
      final newNote = TodosModel(
        title: titleController.text.toString(),
        description: descController.text.toString(),
        priority: selectedCategory,
      );

      context.read<TodosBloc>().add(AddTodos(newNote));
      final todosBloc = BlocProvider.of<TodosBloc>(context);
      todosBloc.stream.listen((state) {
        if (state is TodosCreateSuccess) {
          if (mounted) {
            Navigator.pop(context);
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.createdsuccessfully,
                color: AppColors.primary);
          }
        }
        if (state is TodosCreateError) {
          flutterToastCustom(msg: state.errorMessage);
        }
      });
      todosBloc.add(const TodosList());
    } else {
      flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleasefilltherequiredfield);
    }
  }

  String calculateCompletionPercentage(List<StatusWiseProjects> todoStats) {
    if (todoStats.isEmpty) return "0";

    // Get completed todos count
    double completed = todoStats
        .firstWhere(
          (item) => item.title == "Completed Todos",
          orElse: () =>
              StatusWiseProjects(title: "Completed Todos", totalProjects: 0),
        )
        .totalProjects!
        .toDouble();

    // Get total todos count
    double total =
        todoStats.fold(0, (sum, item) => sum + item.totalProjects!).toDouble();

    // Prevent division by zero
    if (total == 0) return "0";

    // Calculate percentage
    double percentage = (completed / total) * 100;

    // Return as int if whole number, otherwise keep decimal
    return percentage % 1 == 0
        ? percentage.toInt().toString()
        : percentage.toStringAsFixed(1);
  }

  void _onEditTodos(id, title, desc, priority) async {
    if (titleController.text.isNotEmpty) {
      final updatedNote = TodosModel(
        id: id,
        title: titleController.text,
        description: descController.text,
        priority: selectedCategory ?? priority,
      );
      context.read<TodosBloc>().add(UpdateTodos(updatedNote));
      final todosBloc = BlocProvider.of<TodosBloc>(context);
      todosBloc.stream.listen((state) {
        if (state is TodosEditSuccess) {
          if (mounted) {
            router.pop(context);
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.updatedsuccessfully,
                color: AppColors.primary);
          }
        }
        if (state is TodosCreateError) {
          flutterToastCustom(msg: state.errorMessage);
        }
      });
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
    // Navigator.pop(context);
  }

  void _onDeleteTodos(todos) {
    context.read<TodosBloc>().add(DeleteTodos(todos));
    final setting = context.read<TodosBloc>();
    setting.stream.listen((state) {
      if (state is TodosDeleteSuccess) {
        if (mounted) {
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      } else if (state is TodosError) {
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

    BlocProvider.of<TodosBloc>(context).add(TodosList());
    BlocProvider.of<SettingsBloc>(context)
        .add(SettingsList("general_settings"));
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
                                      .read<TodosBloc>()
                                      .add(SearchTodos(""));
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
                        context.read<TodosBloc>().add(SearchTodos(value));
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
        child: BlocConsumer<TodosBloc, TodosState>(
          listener: (context, state) {
            if (state is TodosPaginated) {
              isLoadingMore = false;
              setState(() {});
            }
          },
          builder: (context, state) {
            if (state is TodosLoading) {
              return const NotesShimmer();
            } else if (state is TodosPaginated) {
              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (!state.hasReachedMax &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent &&
                      isLoadingMore == false) {
                    isLoadingMore = true;
                    setState(() {});
                    context.read<TodosBloc>().add(LoadMoreTodos(_lastWords));
                  }
                  return false;
                },
                child: state.todos.isNotEmpty
                    ? _todosLists(
                        isLightTheme,
                        state.hasReachedMax,
                        state.todos,
                      )
                    : NoData(
                        isImage: true,
                      ),
              );
            } else if (state is TodosError) {
              return SizedBox();
            } else if (state is TodosSuccess) {
              // Show initial list of notes
              return ListView.builder(
                padding: EdgeInsets.only(bottom: 30.h),
                shrinkWrap: true,
                itemCount:
                    state.todos.length + 1, // Add 1 for the loading indicator
                itemBuilder: (context, index) {
                  if (index < state.todos.length) {
                    final todos = state.todos[index];
                    String? dateCreated;
                    DateTime createdDate =
                        parseDateStringFromApi(todos.createdAt!);
                    dateCreated = dateFormatConfirmed(createdDate, context);
                    String priority = todos.priority!;
                    return state.todos.isEmpty
                        ? NoData(
                            isImage: true,
                          )
                        : _todosListContainer(todos, isLightTheme, state.todos,
                            index, dateCreated, priority);
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
            // Handle other states
            return const Text("");
          },
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
        title: AppLocalizations.of(context)!.todos,
        isAdd: true,
        onPress: () {
          _createEditTodos(isLightTheme: isLightTheme, isCreate: true);
        },
      ),
    );
  }

  Widget _todosLists(isLightTheme, hasReachedMax, todoList) {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 30.h),
      shrinkWrap: true,
      itemCount: hasReachedMax
          ? todoList.length + 1 // No extra item if all data is loaded
          : todoList.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          // Return the statistics container as the first item
          return BlocConsumer<DashBoardStatsBloc, DashBoardStatsState>(
            listener: (context, state) {},
            builder: (context, state) {
              print("fvghjk $state");
              if (state is DashBoardStatsLoading) {
                BlocProvider.of<DashBoardStatsBloc>(context).add(StatsList());

                return const NotesShimmer();
              }
              if (state is DashBoardStatsSuccess) {
                List<StatusWiseProjects> todoStats = [
                  StatusWiseProjects(
                      title: "Completed Todos",
                      totalProjects:
                          context.read<DashBoardStatsBloc>().completedTodos),
                  StatusWiseProjects(
                      title: "Pending Todos",
                      totalProjects:
                          context.read<DashBoardStatsBloc>().pendingTodos),
                ];

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Container(
                      height: 210.h,
                      decoration: BoxDecoration(
                          boxShadow: [
                            isLightTheme
                                ? MyThemes.lightThemeShadow
                                : MyThemes.darkThemeShadow,
                          ],
                          color: Theme.of(context).colorScheme.containerDark,
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: EdgeInsets.only(top: 10.h),
                        child: Column(
                          children: [
                            CustomText(
                              text: AppLocalizations.of(context)!.statistics,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                              size: 20.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            // SizedBox(height: 10),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    height: 170.h,
                                    width: 180.w, // Adjust chart size
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SfCircularChart(
                                          margin: EdgeInsets.zero,
                                          series: <CircularSeries>[
                                            DoughnutSeries<StatusWiseProjects,
                                                String>(
                                              dataSource: todoStats,
                                              xValueMapper:
                                                  (StatusWiseProjects data,
                                                          _) =>
                                                      data.title,
                                              yValueMapper:
                                                  (StatusWiseProjects data,
                                                          _) =>
                                                      data.totalProjects,
                                              pointColorMapper:
                                                  (StatusWiseProjects data,
                                                          _) =>
                                                      data.title ==
                                                              "Completed Todos"
                                                          ? Colors.green
                                                          : Colors.red,
                                              explode: true,
                                              explodeIndex: 1,
                                              dataLabelSettings:
                                                  DataLabelSettings(
                                                labelIntersectAction:
                                                    LabelIntersectAction.shift,
                                                isVisible: true,
                                                showZeroValue: false,
                                                labelPosition:
                                                    ChartDataLabelPosition
                                                        .outside,
                                                connectorLineSettings:
                                                    ConnectorLineSettings(
                                                  width: 2,
                                                  type: ConnectorType.curve,
                                                ),
                                              ),
                                              innerRadius:
                                                  getResponsiveRadius(80),
                                              radius: getResponsiveRadius(60),
                                              animationDuration: 1000,
                                            ),
                                          ],
                                        ),

                                        // Display percentage in the center of the doughnut
                                        Positioned(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "${calculateCompletionPercentage(todoStats)}%", // Function to calculate percentage
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                "Done",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(
                                    height: 150.h,
                                    width: 120.w,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.w),
                                            child: Container(
                                                // color: Colors.red,
                                                child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: AppColors.greenColor,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Expanded(
                                                  child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .done,
                                                    // Only the category will truncate
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: 5), // Adds spacing
                                                Text(
                                                  "${context.read<DashBoardStatsBloc>().completedTodos}",
                                                  // This will always be fully visible
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ))),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w),
                                          child: Container(
                                            // color: Colors.red,
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: AppColors.red,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Expanded(
                                                  child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .pending,
                                                    // Only the category will truncate
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: 5), // Adds spacing
                                                Text(
                                                  "${context.read<DashBoardStatsBloc>().pendingTodos}",
                                                  // This will always be fully visible
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // SizedBox(height: 20.h),

                                  // Space between chart and legend
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                );
              }
              return SizedBox();
            },
          );
        } else if (index < todoList.length + 1) {
          // Return todo items (with index-1 to account for statistics at top)
          final todos = todoList[index - 1];
          String? dateCreated;
          DateTime createdDate = parseDateStringFromApi(todos.createdAt!);
          dateCreated = dateFormatConfirmed(createdDate, context);
          String priority = todos.priority!;

          return _todosListContainer(
              todos, isLightTheme, todoList, index - 1, dateCreated, priority);
        } else {
          // Loading indicator at the bottom
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
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

  Future<void> _createEditTodos(
      {isLightTheme,
      isCreate,
      todos,
      todosModel,
      int? id,
      title,
      desc,
      priority}) {
    if (isCreate) {
      titleController.text = '';
      descController.text = '';
    } else {
      titleController.text = title;
      descController.text = desc ?? "";
      priority = priority;
    }
    return showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: const [],
                borderRadius: BorderRadius.circular(25),
                color: Theme.of(context).colorScheme.backGroundColor,
              ),
              height: 500.h,
              child: Center(
                child: Form(
                  key: _createTodoKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: BackArrow(
                          title: isCreate == false
                              ? AppLocalizations.of(context)!.edittodo
                              : AppLocalizations.of(context)!.createtodo,
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
                      CustomTextFields(
                          height: 112.h,
                          keyboardType: TextInputType.multiline,
                          title: AppLocalizations.of(context)!.description,
                          hinttext: AppLocalizations.of(context)!
                              .pleaseenterdescription,
                          controller: descController,
                          onSaved: (value) {},
                          onFieldSubmitted: (value) {
                            _fieldFocusChange(
                              context,
                              descFocus!,
                              startsFocus,
                            );
                          },
                          isLightTheme: isLightTheme,
                          isRequired: false),
                      SizedBox(
                        height: 15.h,
                      ),
                      PriorityField(
                        isRequired: true,
                        isLightTheme: isLightTheme,
                        priority: priority ?? "",
                        isCreate: isCreate,
                        selectedCategoryy: selectedCategory ?? "",
                        onCategorySelected: _handleCategorySelected,
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                      BlocBuilder<TodosBloc, TodosState>(
                          builder: (context, state) {
                        if (state is TodosEditSuccessLoading) {
                          return CreateCancelButtom(
                            isLoading: true,
                            isCreate: isCreate,
                            onpressCreate: isCreate == true
                                ? () async {}
                                : () {
                                    _onEditTodos(id, title, desc, priority);
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
                                    _onEditTodos(id, title, desc, priority);
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
                                  _onCreateTodos();
                                }
                              : () {
                                  _onEditTodos(id, title, desc, priority);
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
  }

  Widget _todosListContainer(TodosModel todos, bool isLightTheme,
      List<TodosModel> todosModel, int index, dateCreated, priority) {
    String? date;
    if (todos.createdAt != null) {
      date = formatDateFromApi(todos.createdAt!, context);
    }
    return index == 0
        ? ShakeWidget(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                child: DismissibleCard(
                  title: todos.id!.toString(),
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
                              todosModel.removeAt(index);
                            });
                            _onDeleteTodos(todos);
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
                      _createEditTodos(
                          isLightTheme: isLightTheme,
                          isCreate: false,
                          todos: todos,
                          todosModel: todosModel,
                          id: todos.id,
                          title: todos.title,
                          desc: todos.description,
                          priority: todos.priority);
                      // Perform the edit action if needed
                      return false; // Prevent dismiss
                    }
                    // flutterToastCustom(
                    //     msg: AppLocalizations.of(context)!.isDemooperation);
                    return false; // Default case
                  },
                  dismissWidget: _todoCard(isLightTheme, todos, priority, date),
                  onDismissed: (DismissDirection direction) {
                    // This will not be called if `confirmDismiss` returned `false`
                    if (direction == DismissDirection.endToStart) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          todosModel.removeAt(index);
                        });
                        _onDeleteTodos(todos);
                      });
                    }
                  },
                )),
          )
        : Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
            child: DismissibleCard(
              title: todos.id!.toString(),
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
                          todosModel.removeAt(index);
                        });
                        _onDeleteTodos(todos);
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
                  _createEditTodos(
                      isLightTheme: isLightTheme,
                      isCreate: false,
                      todos: todos,
                      todosModel: todosModel,
                      id: todos.id,
                      title: todos.title,
                      desc: todos.description,
                      priority: todos.priority);
                  // Perform the edit action if needed
                  return false; // Prevent dismiss
                }
                // flutterToastCustom(
                //     msg: AppLocalizations.of(context)!.isDemooperation);
                return false; // Default case
              },
              dismissWidget: _todoCard(isLightTheme, todos, priority, date),
              onDismissed: (DismissDirection direction) {
                // This will not be called if `confirmDismiss` returned `false`
                if (direction == DismissDirection.endToStart) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      todosModel.removeAt(index);
                    });
                    _onDeleteTodos(todos);
                  });
                }
              },
            ));
  }

  Widget _todoCard(isLightTheme, todos, priority, dateCreated) {
    bool status = false;
    if (todos.isCompleted == 1) {
      status = true;
    } else {
      status = false;
    }
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
          ],
          color: Theme.of(context).colorScheme.containerDark,
          borderRadius: BorderRadius.circular(12)),
      // height: 140.h,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.h, left: 20.h, right: 20.h),
            child: SizedBox(
              width: double.infinity,
              // color: Colors.red,
              // height: 70.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 10,
                        child: CustomText(
                          textDecoration: status == true
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          text: todos.title!,
                          size: 16,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.centerRight,

                          height: 20.h,
                          // color: AppColors.red,
                          child: Checkbox(
                            side: BorderSide(
                              color: AppColors.greyColor,
                              width: 2.0,
                            ),
                            activeColor: AppColors.primary,
                            value: todos.isCompleted ==
                                1, // Directly check model state
                            onChanged: (bool? value) {
                              if (value != null) {
                                setState(() {
                                  todos.isCompleted =
                                      value ? 1 : 0; // Update model directly
                                });

                                // If using Bloc, dispatch the event to update state in backend
                                context.read<TodosBloc>().add(ReadStatusTodos(
                                    todos.id!, todos.isCompleted));
                                BlocProvider.of<DashBoardStatsBloc>(context)
                                    .add(StatsList());

                                // );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  SizedBox(
                    // color: Colors.red,
                    // height: 40.h,
                    // width: 270.w,
                    child: CustomText(
                      text: todos.description != null ? todos.description! : "",
                      size: 12.sp,
                      color: AppColors.greyColor,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(
            color: AppColors.greyForgetColor,
            thickness: 0.5,
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10.h, left: 20.h, right: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
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
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 18.h,
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: _getSolidPriorityColor(priority)),
                        borderRadius: BorderRadius.circular(20),
                        color: _getPriorityColor(priority)),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                          // bottom: 3.h,
                          left: 10.w,
                          right: 10.w,
                        ),
                        child: CustomText(
                          text: priority.isEmpty ? "" : priority,
                          size: 11,
                          color: _getSolidPriorityColor(priority),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Color _getPriorityColor(priority) {
    if (priority == "high") {
      return AppColors.redColor.withValues(alpha: 0.10);
    } else if (priority == "low") {
      return AppColors.greenColor.withValues(alpha: 0.10);
    } else if (priority == "medium") {
      return AppColors.yellow.withValues(alpha: 0.10);
    }
    return Colors.black;
  }

  Color _getSolidPriorityColor(priority) {
    if (priority == "high") {
      return AppColors.redColor;
    } else if (priority == "low") {
      return AppColors.greenColor;
    } else if (priority == "medium") {
      return AppColors.yellow;
    }
    return Colors.black;
  }
}
