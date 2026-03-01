import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/interviews/interviews_bloc.dart';
import 'package:taskify/bloc/interviews/interviews_event.dart';
import 'package:taskify/bloc/interviews/interviews_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/model/interview/interview_model.dart';
import 'package:taskify/screens/notes/widgets/notes_shimmer_widget.dart';
import 'package:taskify/utils/widgets/custom_dimissible.dart';
import 'package:taskify/utils/widgets/shake_widget.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/permissions/permissions_event.dart';
import '../../../bloc/todos/todos_bloc.dart';
import '../../../bloc/todos/todos_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/app_images.dart';
import '../../../config/internet_connectivity.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/no_permission_screen.dart';
import '../../../utils/widgets/search_pop_up.dart';

import '../../widgets/no_data.dart';

import '../../widgets/search_field.dart';
import '../../widgets/side_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import '../../widgets/speech_to_text.dart';
import '../../../routes/routes.dart';
class InterviewsScreen extends StatefulWidget {
  const InterviewsScreen({super.key});

  @override
  State<InterviewsScreen> createState() => _InterviewsScreenState();
}

class _InterviewsScreenState extends State<InterviewsScreen> {
  String searchWord = "";
  bool isLoadingMore = false;
  String? selectedPriority;
  List<String>? selectedRoleName;
  int? selectedPriorityId;
  List<int>? selectedRoleId;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late SpeechToTextHelper speechHelper;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  TextEditingController searchController = TextEditingController();

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
          context.read<InterviewsBloc>().add(SearchInterviews(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    super.initState();
    BlocProvider.of<InterviewsBloc>(context).add(InterviewsList());
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
  }

  void _onDeleteInterview(todos) {
    context.read<InterviewsBloc>().add(DeleteInterviews(todos));
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

    BlocProvider.of<InterviewsBloc>(context).add(InterviewsList());
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
                                      .read<InterviewsBloc>()
                                      .add(SearchInterviews(""));
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
                            .read<InterviewsBloc>()
                            .add(SearchInterviews(value));
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
        child: BlocConsumer<InterviewsBloc, InterviewsState>(
          listener: (context, state) {
            if (state is InterviewsSuccess) {
              isLoadingMore = false;
              setState(() {});
            }
          },
          builder: (context, state) {
            print("Interviews Bloc $state");
            if (state is InterviewsLoading ||
                state is InterviewsEditSuccessLoading) {
              return const NotesShimmer();
            } else if (state is InterviewsPaginated) {
              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (!state.hasReachedMax &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent &&
                      isLoadingMore == false) {
                    print("ekfsndm ");
                    isLoadingMore = true;
                    setState(() {});
                    context
                        .read<InterviewsBloc>()
                        .add(LoadMoreInterviews(searchWord));
                  }
                  return false;
                },
                child: state.Interviews.isNotEmpty
                    ? _interviewLists(
                        isLightTheme,
                        state.hasReachedMax,
                        state.Interviews,
                      )
                    : NoData(
                        isImage: true,
                      ),
              );
            } else if (state is InterviewsError) {
              return SizedBox();
            } else if (state is InterviewsEditSuccess) {
              BlocProvider.of<InterviewsBloc>(context).add(InterviewsList());
              flutterToastCustom(
                  msg: AppLocalizations.of(context)!.updatedsuccessfully,
                  color: AppColors.primary);
            } else if (state is InterviewsEditError) {
              BlocProvider.of<InterviewsBloc>(context).add(InterviewsList());
              flutterToastCustom(
                  msg: state.errorMessage, color: AppColors.primary);
            } else if (state is InterviewsDeleteSuccess) {
              BlocProvider.of<InterviewsBloc>(context).add(InterviewsList());
              flutterToastCustom(
                  msg: AppLocalizations.of(context)!.deletedsuccessfully, color: AppColors.red);
            } else if (state is InterviewsSuccess) {
              // Show initial list of notes
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  crossAxisSpacing: 10, // Horizontal spacing
                  mainAxisSpacing: 10, // Vertical spacing
                  childAspectRatio: 1, // Width/Height ratio
                ),
                itemCount: state.Interviews.length +
                    1, // Add 1 for the loading indicator
                itemBuilder: (context, index) {
                  if (index < state.Interviews.length) {
                    final interview = state.Interviews[index];

                    return state.Interviews.isEmpty
                        ? NoData(
                            isImage: true,
                          )
                        : _interviewListContainer(
                            interview,
                            isLightTheme,
                            state.Interviews,
                            index,
                          );
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
            } else if (state is InterviewsCreateSuccess) {

              flutterToastCustom(
                  msg: AppLocalizations.of(context)!.createdsuccessfully,
                  color: AppColors.primary);
              BlocProvider.of<InterviewsBloc>(context).add(InterviewsList());

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
        iscreatePermission: context.read<PermissionsBloc>().isCreateInterview,
        title: AppLocalizations.of(context)!.interviews,
        isAdd: context.read<PermissionsBloc>().isCreateInterview,
        onPress: () {
          print("kjfvnm");
          InterviewModel interviewModel = InterviewModel(
            candidateId: 0,
            candidateName: '',
            interviewerId: 0,
            interviewerName: '',
            round: '',
            scheduledAt: '',
            mode: '',
            location: '',
            status: '',
          );
          router.push(
            '/createeditinterview',
            extra: {'isCreate': true, 'interviewModel': interviewModel,},
          );
        },
      ),
    );
  }

  Widget _interviewLists(isLightTheme, hasReachedMax, interviewList) {
    // statusList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

    // Reverse the list so the last item appears first
    // statusList = statusList.reversed.toList();
    return Container(
        child: context
        .read<PermissionsBloc>()
        .isManageInterview ==
        true
        ? interviewList.isNotEmpty
        ?ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: hasReachedMax
          ? interviewList.length // No extra item if all data is loaded
          : interviewList.length + 1,
      itemBuilder: (context, index) {
        if (index < interviewList.length) {
          final status = interviewList[index];
          // String? dateCreated;
          // DateTime createdDate = parseDateStringFromApi(status.createdAt!);
          // dateCreated = dateFormatConfirmed(createdDate, context);
          return interviewList.isEmpty
              ? NoData(
                  isImage: true,
                )
              : _interviewListContainer(
                  status, isLightTheme, interviewList, index);
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
            : NoPermission(),);
  }

  Widget _interviewListContainer(InterviewModel interview, bool isLightTheme,
      List<InterviewModel> statusModel, int index) {
    return index == 0
        ? ShakeWidget(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                child: DismissibleCard(
                  title: interview.id!.toString(),
                  direction: context.read<PermissionsBloc>().isDeleteInterview== true &&
                      context.read<PermissionsBloc>().isEditInterview == true
                      ? DismissDirection.horizontal // Allow both directions
                      : context.read<PermissionsBloc>().isDeleteInterview  == true
                      ? DismissDirection.endToStart // Allow delete
                      : context.read<PermissionsBloc>().isEditInterview  == true
                      ? DismissDirection.startToEnd // Allow edit
                      : DismissDirection.none,
                  confirmDismiss: (DismissDirection direction) async {
                    if (direction == DismissDirection.endToStart && context.read<PermissionsBloc>().isDeleteInterview  == true)

                    {
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
                              statusModel.removeAt(index);

                            });
                            _onDeleteInterview(interview.id);
                          });
                          // Return false to prevent the dismissible from animating
                          return false;
                        }

                        return false; // Always return false since we handle deletion manually
                      } catch (e) {
                        print("Error in dialog: $e");
                        return false;
                      } // Return the result of the dialog
                    } else if (direction == DismissDirection.startToEnd&& context.read<PermissionsBloc>().isEditInterview  == true) {
                      print("ejkdjb  ${interview.candidateName}");
                      InterviewModel interviewModel = InterviewModel(
                        id: interview.id,
                        candidateId: interview.candidateId,
                        candidateName: interview.candidateName,
                        interviewerId: interview.interviewerId,
                        interviewerName: interview.interviewerName,
                        round: interview.round,
                        scheduledAt: interview.scheduledAt,
                        mode: interview.mode,
                        location: interview.location,
                        status: interview.status,
                      );
                      router.push(
                        '/createeditinterview',
                        extra: {
                          'isCreate': false,
                          'interviewModel': interviewModel
                        },
                      );
                      // Perform the edit action if needed
                      return false; // Prevent dismiss
                    }
                    // flutterToastCustom(
                    //     msg: AppLocalizations.of(context)!.isDemooperation);
                    return false; // Default case
                  },
                  dismissWidget: _interviewCard(isLightTheme, interview),
                  onDismissed: (DismissDirection direction) {
                    // This will not be called if `confirmDismiss` returned `false`
                    if (direction == DismissDirection.endToStart&& context.read<PermissionsBloc>().isDeleteInterview  == true) {
    WidgetsBinding.instance.addPostFrameCallback((_) { setState(() {
                        statusModel.removeAt(index);
                      });
    _onDeleteInterview(interview.id);

    });
                    }
                  },
                )),
          )
        : Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
            child: DismissibleCard(
              title: interview.id!.toString(),
              direction: context.read<PermissionsBloc>().isDeleteInterview== true &&
                  context.read<PermissionsBloc>().isEditInterview == true
                  ? DismissDirection.horizontal // Allow both directions
                  : context.read<PermissionsBloc>().isDeleteInterview  == true
                  ? DismissDirection.endToStart // Allow delete
                  : context.read<PermissionsBloc>().isEditInterview  == true
                  ? DismissDirection.startToEnd // Allow edit
                  : DismissDirection.none,
              confirmDismiss: (DismissDirection direction) async {
                if (direction == DismissDirection.endToStart && context.read<PermissionsBloc>().isDeleteInterview  == true)

                {
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
                          statusModel.removeAt(index);

                        });
                        _onDeleteInterview(interview.id);
                      });
                      // Return false to prevent the dismissible from animating
                      return false;
                    }

                    return false; // Always return false since we handle deletion manually
                  } catch (e) {
                    print("Error in dialog: $e");
                    return false;
                  } // Return the result of the dialog
                } else if (direction == DismissDirection.startToEnd&& context.read<PermissionsBloc>().isEditInterview  == true) {
                  print("ejkdjb  ${interview.candidateName}");
                  InterviewModel interviewModel = InterviewModel(
                    id: interview.id,
                    candidateId: interview.candidateId,
                    candidateName: interview.candidateName,
                    interviewerId: interview.interviewerId,
                    interviewerName: interview.interviewerName,
                    round: interview.round,
                    scheduledAt: interview.scheduledAt,
                    mode: interview.mode,
                    location: interview.location,
                    status: interview.status,
                  );
                  router.push(
                    '/createeditinterview',
                    extra: {
                      'isCreate': false,
                      'interviewModel': interviewModel
                    },
                  );
                  // Perform the edit action if needed
                  return false; // Prevent dismiss
                }
                // flutterToastCustom(
                //     msg: AppLocalizations.of(context)!.isDemooperation);
                return false; // Default case
              },
              dismissWidget: _interviewCard(isLightTheme, interview),
              onDismissed: (DismissDirection direction) {
                // This will not be called if `confirmDismiss` returned `false`
                if (direction == DismissDirection.endToStart&& context.read<PermissionsBloc>().isDeleteInterview  == true) {
                  WidgetsBinding.instance.addPostFrameCallback((_) { setState(() {
                    statusModel.removeAt(index);
                  });
                  _onDeleteInterview(interview.id);

                  });
                }
              },
            ));
  }

  Widget _interviewCard(isLightTheme, interview) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
        ],
        color: Theme.of(context).colorScheme.containerDark,
        borderRadius: BorderRadius.circular(12),
        //   gradient: LinearGradient(
        //   colors: [Colors.blue.withValues(alpha: 0.7),Colors.purple.withValues(alpha: 0.7)],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
      ),

      // height: 100.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: "#${interview.id.toString()}",
              size: 14.sp,
              color: Theme.of(context).colorScheme.textClrChange,
              fontWeight: FontWeight.w700,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 10.h,),
            _buildChip("Candidate", interview.candidateName,
                Icons.person_outline, AppImages.nameImage, true, true),
            _buildChip("Interviewer", interview.interviewerName,
                Icons.record_voice_over, AppImages.emailImage, true, true),
            _buildChip("Round", interview.round, Icons.phone_outlined,
                AppImages.phoneImage, true, true),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildChip("Location", interview.location ?? "",
                    Icons.location_history, AppImages.sourceImage, true, true),
              ],
            ),
            _buildChip("Mode", interview.mode, Icons.record_voice_over,
                AppImages.interviewModeImage, true, true),

            Row(
              children: [
                Container(
                  // color: Colors.red,
                  child: Image.asset(AppImages.interviewStatusImage, height: 20.h, width: 20.w),
                ),
                SizedBox(width: 10.w,),
                IntrinsicWidth(
                  child: Container(
                    alignment: Alignment.center,
                    height: 25.h,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue.shade800,
                    ),
                    child: CustomText(
                      text: interview.status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      color: AppColors.whiteColor,
                      size: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            _buildChip(
                "Schedule At",
                interview.scheduledAt ?? "",
                Icons.watch_later_outlined,
                AppImages.createdImage,
                true,
                false),
            // _buildChip("Created At", interview.cretedAt ?? "",
            //     Icons.watch_later_outlined, AppImages.sourceImage, true),
            // _buildChip("Upodated At", interview.updatedAt ?? "",
            //     Icons.watch_later_outlined, AppImages.sourceImage, true),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(
      label, String text, icon, images, bool? isIconRequired, isLabelRequired) {
    return Tooltip(
        message: label,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(10),
          // border: Border.all(color: Colors.blueAccent, width: 1),
        ),
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        waitDuration: Duration(milliseconds: 300),
        showDuration: Duration(seconds: 2),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // if (isIconRequired == true) Icon(icon),
              if (isIconRequired == true)
                Container(
                  // color: Colors.red,
                  child: Image.asset(images, height: 20.h, width: 20.w),
                ),
              SizedBox(
                width: 10.w,
              ),
              if (isLabelRequired == true)
                CustomText(
                    text: "$label :",
                    color: Colors.grey,
                    size: 16.sp,
                    fontWeight: FontWeight.bold),

              if (isLabelRequired == true)
                SizedBox(
                  width: 10.w,
                ),
              if (isLabelRequired == true && (label?.length ?? 0) > 8) // or whatever threshold fits
                Flexible(
                  child: CustomText(
                    text: text,
                    color: Colors.grey,
                    size: 14.sp,
                    softwrap: true,
                    maxLines: 2,
                    fontWeight: FontWeight.w500,
                  ),
                )
              else
                CustomText(
                  text: text,
                  color: Colors.grey,
                  size: 14.sp,
                  softwrap: true,
                  maxLines: 2,
                  fontWeight: FontWeight.w500,
                ),

            ],
          ),
        ));
  }
}
