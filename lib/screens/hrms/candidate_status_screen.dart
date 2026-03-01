import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/notes/widgets/notes_shimmer_widget.dart';
import 'package:taskify/utils/widgets/custom_dimissible.dart';
import 'package:taskify/utils/widgets/shake_widget.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../bloc/candidate_status/candidates_status_bloc.dart';
import '../../bloc/candidate_status/candidates_status_event.dart';
import '../../bloc/candidate_status/candidates_status_state.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/permissions/permissions_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../config/constants.dart';
import '../../data/model/candidate_status/candidate_status_model.dart';
import '../../../src/generated/i18n/app_localizations.dart';

import '../../utils/widgets/custom_text.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/no_permission_screen.dart';
import '../../utils/widgets/search_pop_up.dart';
import '../status/widgets/color_fiield.dart';
import '../widgets/custom_cancel_create_button.dart';
import '../widgets/no_data.dart';
import '../widgets/custom_textfields/custom_textfield.dart';
import '../widgets/search_field.dart';
import '../widgets/side_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import '../widgets/speech_to_text.dart';

class CandidateStatusScreen extends StatefulWidget {
  const CandidateStatusScreen({super.key});

  @override
  State<CandidateStatusScreen> createState() => _CandidateStatusScreenState();
}

class _CandidateStatusScreenState extends State<CandidateStatusScreen> {
  DateTime now = DateTime.now();
  final GlobalKey<FormState> _createEditCandidateKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  String searchWord = "";
  bool isLoadingMore = false;

  List<ConnectivityResult> _connectionCandidate = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late SpeechToTextHelper speechHelper;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  String? selectedColorName;
  String? colorIs;
  bool? isLoading = true;

  int? selectedColorId;

  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);
  String? selectedCategory;

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
          _connectionCandidate = results;
        });
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionCandidate = value;
          });
        });
      }
    });
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          context
              .read<CandidatesStatusBloc>()
              .add(SearchCandidatesStatus(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    super.initState();
    BlocProvider.of<CandidatesStatusBloc>(context).add(CandidatesStatusList());
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
  }

  void _onCreateCandidate() {
    if (titleController.text.isNotEmpty) {

      context.read<CandidatesStatusBloc>().add(CreateCandidatesStatus(
            name: titleController.text.toString(),
            color: selectedColorName?.toLowerCase() ?? "",
          ));

      // CandidateBloc.add(CandidateList());
    } else {
      flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleasefilltherequiredfield);
    }
  }

  void _onEditCandidate(id, title, color) async {
    if (titleController.text.isNotEmpty && color != null) {
      print("grnhvkjm $color");
      context.read<CandidatesStatusBloc>().add(UpdateCandidatesStatus(
          id: id, name: titleController.text, color: color));
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
    Navigator.pop(context);
  }

  void _onDeleteCandidateStatus(candidateCandidate) {
    print("dfghjn ");
    context
        .read<CandidatesStatusBloc>()
        .add(DeleteCandidatesStatus(candidateCandidate.id));

      // BlocProvider.of<TodosBloc>(context).add(TodosList());

  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    BlocProvider.of<CandidatesStatusBloc>(context).add(CandidatesStatusList());
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return _connectionCandidate.contains(connectivityCheck)
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
                                      .read<CandidatesStatusBloc>()
                                      .add(SearchCandidatesStatus(""));
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
                        context
                            .read<CandidatesStatusBloc>()
                            .add(SearchCandidatesStatus(value));
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
    print("jrgnvc ");
    return Expanded(
      child: RefreshIndicator(
        color: AppColors.primary, // Spinner color
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        onRefresh: _onRefresh,
        child: BlocConsumer<CandidatesStatusBloc, CandidatesStatusState>(
          listener: (context, state) {
            if (state is CandidatesStatusSuccess) {
              isLoadingMore = false;
              setState(() {});
            }
          },
          builder: (context, state) {
            print("jrgnvc$state ");
            if (state is CandidatesStatusLoading) {
              return const NotesShimmer();
            } else if (state is CandidatesStatusPaginated) {
              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (!state.hasReachedMax &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent &&
                      isLoadingMore == false) {
                    isLoadingMore = true;
                    setState(() {});
                    context
                        .read<CandidatesStatusBloc>()
                        .add(LoadMoreCandidatesStatus(searchWord));
                  }
                  return false;
                },
                child: state.CandidatesStatus.isNotEmpty
                    ? _CandidateLists(
                        isLightTheme,
                        state.hasReachedMax,
                        state.CandidatesStatus,
                      )
                    : NoData(
                        isImage: true,
                      ),
              );
            }
            else if (state is CandidatesStatusError) {
              BlocProvider.of<CandidatesStatusBloc>(context)
                  .add(CandidatesStatusList());
              flutterToastCustom(
                  msg: state.errorMessage, color: AppColors.primary);
            }
            else if (state is CandidatesStatusEditSuccess) {
              BlocProvider.of<CandidatesStatusBloc>(context)
                  .add(CandidatesStatusList());
              flutterToastCustom(
                  msg: AppLocalizations.of(context)!.updatedsuccessfully,
                  color: AppColors.primary);
            }
            else if (state is CandidatesStatusEditError) {
              BlocProvider.of<CandidatesStatusBloc>(context)
                  .add(CandidatesStatusList());
              flutterToastCustom(
                  msg: state.errorMessage, color: AppColors.primary);
            } if (state is CandidatesStatusDeleteSuccess) {

                flutterToastCustom(
                    msg: state.message,
                    color: AppColors.primary);
                BlocProvider.of<CandidatesStatusBloc>(context)
                    .add(CandidatesStatusList());

            } else if (state is CandidatesStatusDeleteError) {
              BlocProvider.of<CandidatesStatusBloc>(context)
                  .add(CandidatesStatusList());
              flutterToastCustom(
                  msg: state.errorMessage, color: AppColors.primary);
            } else if (state is CandidatesStatusSuccess) {
              // Show initial list of notes
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  crossAxisSpacing: 10, // Horizontal spacing
                  mainAxisSpacing: 10, // Vertical spacing
                  childAspectRatio: 1, // Width/Height ratio
                ),
                itemCount: state.CandidatesStatus.length +
                    1, // Add 1 for the loading indicator
                itemBuilder: (context, index) {
                  if (index < state.CandidatesStatus.length) {
                    final Candidate = state.CandidatesStatus[index];
                    String? dateCreated;
                    DateTime createdDate =
                        parseDateStringFromApi(Candidate.createdAt!);
                    dateCreated = dateFormatConfirmed(createdDate, context);
                    return state.CandidatesStatus.isEmpty
                        ? NoData(
                            isImage: true,
                          )
                        : _CandidateListContainer(
                            Candidate,
                            isLightTheme,
                            state.CandidatesStatus,
                            index,
                            dateCreated,
                            "color");
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
            } else if (state is CandidatesStatusCreateSuccess) {
              Navigator.pop(context);
              flutterToastCustom(
                  msg: AppLocalizations.of(context)!.createdsuccessfully,
                  color: AppColors.primary);
              BlocProvider.of<CandidatesStatusBloc>(context)
                  .add(CandidatesStatusList());

              selectedColorName = "";
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
        iscreatePermission: context.read<PermissionsBloc>().isCreateCandidateStatus,
        title: AppLocalizations.of(context)!.candidatestatus,
        isAdd: context.read<PermissionsBloc>().isCreateCandidateStatus,
        onPress: () {
          _createEditCandidate(isLightTheme: isLightTheme, isCreate: true);
        },
      ),
    );
  }

  Widget _CandidateLists(isLightTheme, hasReachedMax, CandidateList) {
    // CandidateList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

    // Reverse the list so the last item appears first
    // CandidateList = CandidateList.reversed.toList();
    return  context
        .read<PermissionsBloc>()
        .isManageCandidate ==
        true
        ? CandidateList.isNotEmpty
        ?ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: hasReachedMax
          ? CandidateList.length // No extra item if all data is loaded
          : CandidateList.length + 1,
      itemBuilder: (context, index) {
        if (index < CandidateList.length) {
          final Candidate = CandidateList[index];
          String? dateCreated;
          DateTime createdDate = parseDateStringFromApi(Candidate.createdAt!);
          dateCreated = dateFormatConfirmed(createdDate, context);
          return CandidateList.isEmpty
              ? NoData(
                  isImage: true,
                )
              : _CandidateListContainer(Candidate, isLightTheme, CandidateList,
                  index, dateCreated, Candidate.color);
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
    ): NoData(
      isImage: true,
    )
        : NoPermission();
  }

  Future<void> _createEditCandidate({
    isLightTheme,
    isCreate,
    Candidate,
    Candidatees,
    int? id,
    title,
    color,
  }) {
    if (isCreate) {
      titleController.text = '';

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
                height: 300.h,
                child: Form(
                  key: _createEditCandidateKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: BackArrow(
                          isBottomSheet: true,
                          title: isCreate == false
                              ? AppLocalizations.of(context)!.edit
                              : AppLocalizations.of(context)!.create,
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
                      BlocBuilder<CandidatesStatusBloc, CandidatesStatusState>(

                          builder: (context, state) {
                            print("vghbjnmk $state");
                        if (state is CandidatesStatusEditSuccessLoading) {
                          return CreateCancelButtom(
                            isLoading: true,
                            isCreate: isCreate,
                            onpressCreate: isCreate == true
                                ? () async {}
                                : () {
                                    _onEditCandidate(id, title, color);
                                    // context.read<TodosBloc>().add(const TodosList());
                                    // Navigator.pop(context);
                                  },
                            onpressCancel: () {
                              Navigator.pop(context);
                            },
                          );
                        }
                        if (state is CandidatesStatusCreateSuccessLoading) {
                          return CreateCancelButtom(
                            isLoading: true,
                            isCreate: isCreate,
                            onpressCreate: isCreate == true
                                ? () async {
                                    // _onCreateTodos();
                                  }
                                : () {
                                    _onEditCandidate(id, title, color);
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
                                  _onCreateCandidate();
                                }
                              : () {
                                  _onEditCandidate(id, titleController.text,
                                      selectedColorName);
                                  // context.read<TodosBloc>().add(const TodosList());
                                  // Navigator.pop(context);
                                },
                          onpressCancel: () {
                            Navigator.pop(context);
                          },
                        );
                      }),
                      SizedBox(
                        height: 20.h,
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  Widget _CandidateListContainer(
      CandidateStatusModel Candidate,
      bool isLightTheme,
      List<CandidateStatusModel> CandidateModel,
      int index,
      dateCreated,
      color) {
    return index == 0
        ? ShakeWidget(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                child: DismissibleCard(
                  title: Candidate.id!.toString(),
                  direction: context.read<PermissionsBloc>().isDeleteCandidateStatus== true &&
                      context.read<PermissionsBloc>().isEditCandidateStatus == true
                      ? DismissDirection.horizontal // Allow both directions
                      : context.read<PermissionsBloc>().isDeleteCandidateStatus  == true
                      ? DismissDirection.endToStart // Allow delete
                      : context.read<PermissionsBloc>().isEditCandidateStatus == true
                      ? DismissDirection.startToEnd // Allow edit
                      : DismissDirection.none,
                  confirmDismiss: (DismissDirection direction) async {
                    if (direction == DismissDirection.endToStart &&
                        context.read<PermissionsBloc>().isDeleteCandidate ==
                            true) {
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
                              CandidateModel.removeAt(index);

                            });
                            _onDeleteCandidateStatus(Candidate);
                          });
                          // Return false to prevent the dismissible from animating
                          return false;
                        }

                        return false; // Always return false since we handle deletion manually
                      } catch (e) {
                        print("Error in dialog: $e");
                        return false;
                      } // Return the result of the dialog
                    } else if (direction == DismissDirection.startToEnd &&
                        context.read<PermissionsBloc>().isEditCandidate ==
                            true) {
                      _createEditCandidate(
                        isLightTheme: isLightTheme,
                        isCreate: false,
                        Candidate: Candidate,
                        Candidatees: CandidateModel,
                        id: Candidate.id,
                        title: Candidate.name,
                        color: Candidate.color,
                      );
                      // Perform the edit action if needed
                      return false; // Prevent dismiss
                    }
                    // flutterToastCustom(
                    //     msg: AppLocalizations.of(context)!.isDemooperation);
                    return false; // Default case
                  },
                  dismissWidget: _CandidateCard(isLightTheme, Candidate, color),
                  onDismissed: (DismissDirection direction) {
                    // This will not be called if `confirmDismiss` returned `false`
                    if (direction == DismissDirection.endToStart &&
                        context.read<PermissionsBloc>().isDeleteCandidate ==
                            true) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                        CandidateModel.removeAt(index);
                      });
                        _onDeleteCandidateStatus(Candidate);

                      });
                    }
                  },
                )),
          )
        : Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
            child: DismissibleCard(
              title: Candidate.id!.toString(),
              confirmDismiss: (DismissDirection direction) async {
                if (direction == DismissDirection.endToStart &&
                    context.read<PermissionsBloc>().isDeleteCandidate ==
                        true) {
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
                          CandidateModel.removeAt(index);

                        });
                        _onDeleteCandidateStatus(Candidate);
                      });
                      // Return false to prevent the dismissible from animating
                      return false;
                    }

                    return false; // Always return false since we handle deletion manually
                  } catch (e) {
                    print("Error in dialog: $e");
                    return false;
                  } // Return the result of the dialog
                } else if (direction == DismissDirection.startToEnd &&
                    context.read<PermissionsBloc>().isEditCandidate ==
                        true) {
                  _createEditCandidate(
                    isLightTheme: isLightTheme,
                    isCreate: false,
                    Candidate: Candidate,
                    Candidatees: CandidateModel,
                    id: Candidate.id,
                    title: Candidate.name,
                    color: Candidate.color,
                  );
                  // Perform the edit action if needed
                  return false; // Prevent dismiss
                }
                // flutterToastCustom(
                //     msg: AppLocalizations.of(context)!.isDemooperation);
                return false; // Default case
              },
              dismissWidget: _CandidateCard(isLightTheme, Candidate, color),
              onDismissed: (DismissDirection direction) {
                // This will not be called if `confirmDismiss` returned `false`
                if (direction == DismissDirection.endToStart &&
                    context.read<PermissionsBloc>().isDeleteCandidate ==
                        true) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      CandidateModel.removeAt(index);
                    });
                    _onDeleteCandidateStatus(Candidate);

                  });
                }
              },
            ));
  }

  Widget _CandidateCard(isLightTheme, Candidate, color) {
    Color? colorOfCandidate;
    String? CandidateColor = "";
    switch (color) {
      case "primary":
      case "Primary":
        colorOfCandidate = AppColors.primary;
        CandidateColor = "Primary";
        break;
      case "secondary":
      case "Secondary":
        colorOfCandidate = Color(0xFF8592a3);
        CandidateColor = "Secondary";
        break;
      case "success":
      case "Success":
        colorOfCandidate = Colors.green;
        CandidateColor = "Success";
        break;
      case "danger":
      case "Danger":
        colorOfCandidate = Colors.red;
        CandidateColor = "Danger";
        break;
      case "warning":
      case "Warning":
        colorOfCandidate = Color(0xFFfaab01);
        CandidateColor = "Warning";
        break;
      case "info":
      case "Info":
        colorOfCandidate = Color(0xFF36c3ec);
        CandidateColor = "Info";
        break;
      case "dark":
      case "Dark":
        colorOfCandidate = Colors.black;
        CandidateColor = "Dark";
        break;
      default:
        colorOfCandidate = Colors.grey;
        CandidateColor = "Secondary"; // Fallback color
    }
    String dateCreated = formatDateFromApi(Candidate.createdAt!, context);
    String dateUpdated = formatDateFromApi(Candidate.updatedAt!, context);
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "#${Candidate.id.toString()}",
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
                    text: Candidate.name!,
                    size: 16.sp,
                    color: Theme.of(context).colorScheme.textClrChange,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(
                    height: 18.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize
                        .min, // Important to prevent Row from stretching full width
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: 25.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: colorOfCandidate,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: CustomText(
                            text: CandidateColor,
                            color: AppColors.whiteColor,
                            size: 14.sp,
                            fontWeight: FontWeight.w600,
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                            softwrap: true,
                          ),
                        ),
                      ),
                    ],
                  )

                  // Row(
                  //   mainAxisSize: MainAxisSize.min, // Important: wrap content width
                  //   children: [
                  //     Container(
                  //       alignment: Alignment.center,
                  //       height: 25.h,
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(10),
                  //         color: colorOfCandidate ?? Colors.transparent,
                  //       ),
                  //       child: Center(
                  //         child: Padding(
                  //           padding: EdgeInsets.symmetric(horizontal: 10.w),
                  //           child: CustomText(
                  //             text: Candidate.title!,
                  //             color: AppColors.whiteColor,
                  //             size: 14.sp,
                  //             fontWeight: FontWeight.w600,
                  //             maxLines: 2,
                  //             overflow: TextOverflow.visible,
                  //             softwrap: true,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  //       child: Container(
                  //         width: 1.5,
                  //         height: 18,
                  //         color: Colors.grey.shade400,
                  //       ),
                  //     ),
                  //     Container(
                  //       alignment: Alignment.center,
                  //       height: 25.h,
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(10),
                  //         color: colorOfCandidate ?? Colors.transparent,
                  //       ),
                  //       child: Center(
                  //         child: Padding(
                  //           padding: EdgeInsets.symmetric(horizontal: 10.w),
                  //           child: CustomText(
                  //             text: CandidateColor,
                  //             color: AppColors.whiteColor,
                  //             size: 14.sp,
                  //             fontWeight: FontWeight.w600,
                  //             maxLines: 2,
                  //             overflow: TextOverflow.visible,
                  //             softwrap: true,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // )
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
