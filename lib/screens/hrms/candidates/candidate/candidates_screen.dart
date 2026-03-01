import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/candidate/candidates_bloc.dart';
import 'package:taskify/bloc/candidate/candidates_event.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/model/candidate/candidate_model.dart';
import 'package:taskify/screens/notes/widgets/notes_shimmer_widget.dart';
import 'package:taskify/utils/widgets/custom_dimissible.dart';
import 'package:taskify/utils/widgets/shake_widget.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../../../bloc/candidate/candidates_state.dart';
import '../../../../bloc/permissions/permissions_bloc.dart';
import '../../../../bloc/permissions/permissions_event.dart';
import '../../../../bloc/theme/theme_bloc.dart';
import '../../../../bloc/theme/theme_state.dart';
import '../../../../config/app_images.dart';
import '../../../../config/constants.dart';

import '../../../../config/internet_connectivity.dart';
import '../../../../routes/routes.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../../utils/widgets/custom_text.dart';
import '../../../../utils/widgets/my_theme.dart';
import '../../../../utils/widgets/no_permission_screen.dart';
import '../../../../utils/widgets/search_pop_up.dart';

import '../../../widgets/no_data.dart';

import '../../../widgets/search_field.dart';
import '../../../widgets/side_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import '../../../widgets/speech_to_text.dart';
import '../widgets/interviews_dialogbox.dart';

class CandidateScreen extends StatefulWidget {
  const CandidateScreen({super.key});

  @override
  State<CandidateScreen> createState() => _CandidateScreenState();
}

class _CandidateScreenState extends State<CandidateScreen> {
  DateTime now = DateTime.now();
  TextEditingController titleController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController startsController = TextEditingController();
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

  ConnectivityResult connectivityCheck = ConnectivityResult.none;

  bool? isLoading = true;

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
          searchController.text = result;
          context.read<CandidatesBloc>().add(SearchCandidates(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    super.initState();
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    BlocProvider.of<CandidatesBloc>(context).add(CandidatesList());
  }

  void _onDeleteCandidate(candidate) {
    context.read<CandidatesBloc>().add(DeleteCandidates(candidate.id));
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    BlocProvider.of<CandidatesBloc>(context).add(CandidatesList());
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
                                      .read<CandidatesBloc>()
                                      .add(SearchCandidates(""));
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
                        context.read<CandidatesBloc>().add(SearchCandidates(value));
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
        child: BlocConsumer<CandidatesBloc, CandidatesState>(
          listener: (context, state) {
            if (state is CandidatesPaginated) {
              isLoadingMore = false;
              setState(() {});
            }
          },
          builder: (context, state) {
            print("fnjuhdkcm,$state");
            if (state is CandidatesLoading) {
              return const NotesShimmer();
            } else if (state is CandidatesPaginated) {
              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (!state.hasReachedMax &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent &&
                      isLoadingMore == false) {
                    isLoadingMore = true;
                    setState(() {});
                    context
                        .read<CandidatesBloc>()
                        .add(LoadMoreCandidates(searchWord));
                  }
                  return false;
                },
                child: state.Candidates.isNotEmpty
                    ? _candidatesLists(
                        isLightTheme,
                        state.hasReachedMax,
                        state.Candidates,
                      )
                    : NoData(
                        isImage: true,
                      ),
              );
            } else if (state is CandidatesError) {
              return SizedBox();
            } else if (state is CandidatesEditSuccess) {
              BlocProvider.of<CandidatesBloc>(context).add(CandidatesList());
              flutterToastCustom(
                  msg: AppLocalizations.of(context)!.updatedsuccessfully,
                  color: AppColors.primary);
            }  else  if (state is CandidatesDeleteSuccess) {
              BlocProvider.of<CandidatesBloc>(context).add(CandidatesList());

              flutterToastCustom(
                    msg: AppLocalizations.of(context)!.deletedsuccessfully,
                    color: AppColors.primary);
            } else if (state is CandidatesError) {
              flutterToastCustom(
                msg: state.errorMessage,
              );
            }else if (state is CandidatesEditError) {
              BlocProvider.of<CandidatesBloc>(context).add(CandidatesList());
              flutterToastCustom(
                  msg: state.errorMessage, color: AppColors.primary);
            } else if (state is CandidatesSuccess) {
              // Show initial list of notes
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  crossAxisSpacing: 10, // Horizontal spacing
                  mainAxisSpacing: 10, // Vertical spacing
                  childAspectRatio: 1, // Width/Height ratio
                ),
                itemCount: state.Candidates.length +
                    1, // Add 1 for the loading indicator
                itemBuilder: (context, index) {
                  if (index < state.Candidates.length) {
                    final candidate = state.Candidates[index];
                    String? dateCreated;
                    DateTime createdDate =
                        parseDateStringFromApi(candidate.createdAt!);
                    dateCreated = dateFormatConfirmed(createdDate, context);
                    return state.Candidates.isEmpty
                        ? NoData(
                            isImage: true,
                          )
                        : _candidateListContainer(candidate, isLightTheme,
                            state.Candidates, index, dateCreated);
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
            } else if (state is CandidatesCreateSuccess) {
              Navigator.pop(context);
              flutterToastCustom(
                  msg: AppLocalizations.of(context)!.createdsuccessfully,
                  color: AppColors.primary);
              BlocProvider.of<CandidatesBloc>(context).add(CandidatesList());
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

        iscreatePermission: context.read<PermissionsBloc>().isCreateCandidate ,
        title: AppLocalizations.of(context)!.candidates,
        isAdd: context.read<PermissionsBloc>().isCreateCandidate
        ,
        onPress: () {
          print("kjfvnm");
          CandidateModel candidateModel = CandidateModel(
              name: "", email: "", phone: "", source: "", position: "");
          context.read<PermissionsBloc>().isCreateCandidate == true
              ? router.push(
                  '/createupdatecandidate',
                  extra: {'isCreate': true, 'candidateModel': candidateModel},
                )
              : null;
        },
      ),
    );
  }

  Widget _candidatesLists(isLightTheme, hasReachedMax, candidatesList) {
print("fgvhjjk $hasReachedMax");
    return context
        .read<PermissionsBloc>()
        .isManageCandidate ==
        true
        ? candidatesList.isNotEmpty
        ?ListView.builder(

      padding: EdgeInsets.only(bottom: 30.h),
      itemCount: hasReachedMax
          ? candidatesList.length // No extra item if all data is loaded
          : candidatesList.length + 1,
      itemBuilder: (context, index) {
        if (index < candidatesList.length) {
          final status = candidatesList[index];
          String? dateCreated;
          DateTime createdDate = parseDateStringFromApi(status.createdAt!);
          dateCreated = dateFormatConfirmed(createdDate, context);
          return candidatesList.isEmpty
              ? NoData(
                  isImage: true,
                )
              : _candidateListContainer(
                  status, isLightTheme, candidatesList, index, dateCreated);
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

  Widget _candidateListContainer(CandidateModel candidate, bool isLightTheme,
      List<CandidateModel> candidateModel, int index, dateCreated) {
    return index == 0
        ? ShakeWidget(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                child: DismissibleCard(
                  title: candidate.id!.toString(),
                  direction: context.read<PermissionsBloc>().isDeleteCandidate== true &&
                      context.read<PermissionsBloc>().isEditCandidate == true
                      ? DismissDirection.horizontal // Allow both directions
                      : context.read<PermissionsBloc>().isDeleteCandidate  == true
                      ? DismissDirection.endToStart // Allow delete
                      : context.read<PermissionsBloc>().isEditCandidate == true
                      ? DismissDirection.startToEnd // Allow edit
                      : DismissDirection.none,
                  confirmDismiss: (DismissDirection direction) async {
                    if (direction == DismissDirection.endToStart &&
                        context.read<PermissionsBloc>().isDeleteCandidate ==
                            true) {
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
                              candidateModel.removeAt(index);

                            });
                            _onDeleteCandidate(candidate);                          });
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
                      print("Edit tapped");
                      CandidateModel candidateModel = CandidateModel(
                          id: candidate.id,
                          name: candidate.name,
                          email: candidate.email,
                          phone: candidate.phone,
                          source: candidate.source,
                          position: candidate.position,
                          attachments: candidate.attachments,
                          status: candidate.status);
                      await Future.delayed(Duration(milliseconds: 100));
                      print("fkuhkdnc ${candidateModel.id}");
                      router.push(
                        '/createupdatecandidate',
                        extra: {
                          'isCreate': false,
                          'candidateModel': candidateModel
                        },
                      );

                      return false;
                    }
                    return false; // Default case
                  },
                  dismissWidget: _candidateCard(isLightTheme, candidate),
                  onDismissed: (DismissDirection direction) {
                    // This will not be called if `confirmDismiss` returned `false`
                    if (direction == DismissDirection.endToStart &&
                        context.read<PermissionsBloc>().isDeleteCandidate ==
                            true) {
    WidgetsBinding.instance.addPostFrameCallback((_) { setState(() {
                        candidateModel.removeAt(index);

                      });
    _onDeleteCandidate(candidate);
                      });
                    }
                  },
                )),
          )
        : Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
            child: DismissibleCard(
              title: candidate.id!.toString(),
              confirmDismiss: (DismissDirection direction) async {
                if (direction == DismissDirection.endToStart &&
                    context.read<PermissionsBloc>().isDeleteCandidate ==
                        true) {
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
                          candidateModel.removeAt(index);

                        });
                        _onDeleteCandidate(candidate);                          });
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
                  print("Edit tapped");
                  CandidateModel candidateModel = CandidateModel(
                      id: candidate.id,
                      name: candidate.name,
                      email: candidate.email,
                      phone: candidate.phone,
                      source: candidate.source,
                      position: candidate.position,
                      attachments: candidate.attachments,
                      status: candidate.status);
                  await Future.delayed(Duration(milliseconds: 100));
                  print("fkuhkdnc ${candidateModel.id}");
                  router.push(
                    '/createupdatecandidate',
                    extra: {
                      'isCreate': false,
                      'candidateModel': candidateModel
                    },
                  );

                  return false;
                }
                return false; // Default case
              },
              dismissWidget: _candidateCard(isLightTheme, candidate),
              onDismissed: (DismissDirection direction) {
                // This will not be called if `confirmDismiss` returned `false`
                if (direction == DismissDirection.endToStart &&
                    context.read<PermissionsBloc>().isDeleteCandidate ==
                        true) {
                  WidgetsBinding.instance.addPostFrameCallback((_) { setState(() {
                    candidateModel.removeAt(index);

                  });
                  _onDeleteCandidate(candidate);
                  });
                }
              },
            ));
  }

  Widget _candidateCard(
    isLightTheme,
    candidate,
  ) {
    String dateCreated = formatDateFromApi(candidate.createdAt!, context);
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        try {


          router.push('/candidatedetails',
              extra: {"candidateModel": candidate});
        } catch (e) {
          print("Navigation failed: $e");
        }
      },
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
          ],
          color: Theme.of(context).colorScheme.containerDark,
          borderRadius: BorderRadius.circular(12),
          //   gradient: LinearGradient(
          //   colors: [ Color(0xff1E3B70),Color(0xff29539B)],
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: "#${candidate.id.toString()}",
                    color: AppColors.greyColor,
                    size: 15.sp,
                    fontWeight: FontWeight.normal,
                  ),
                  Tooltip(
                    message: "View Interviews", // The tooltip message to display
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => InterviewDialog(candidate),
                        );
                      },
                      child: Container(
                        height: 20.h,
                        width: 20.w,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(AppImages.joInterviewImage),
                          ),
                        ),
                        // color: Colors.red, // Commented out as it conflicts with decoration
                        // child: Image.asset(AppImages.joInterviewImage, height: 15.h, width: 15.w), // Commented out as decoration is used
                      ),
                    ),
                  ),
                ],
              ),
              CustomText(
                text: candidate.name,
                color: AppColors.primary,
                size: 24.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(
                height: 5.h,
              ),
              IntrinsicWidth(
                child: Container(
                  alignment: Alignment.center,
                  height: 25.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),

                    // color:AppColors.primary.withValues(alpha: 0.4),
                  ),
                  child: CustomText(
                    text: candidate.position,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    color: AppColors.whiteColor,
                    size: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.backGroundColor,
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 18.w, vertical: 5.h),
                    child: Column(
                      children: [
                        _buildChip("Email", candidate.email,
                            Icons.email_outlined, AppImages.emailImage),
                        _buildChip("Phone", candidate.phone ?? "-",
                            Icons.phone_outlined, AppImages.phoneImage),
                        _buildChip("Source", candidate.source, Icons.language,
                            AppImages.sourceImage),
                        _buildChip("Created Date", dateCreated,
                            Icons.calendar_month, AppImages.createdImage),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(label, String text, icon, images) {
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
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon(
              //   icon,
              //   size: 15  ,
              //   color: Colors.white, // This is needed, white becomes the mask base.
              // ),
              Container(
                // color: Colors.red,
                child: Image.asset(images, height: 15.h, width: 15.w),
              ),
              SizedBox(
                width: 10.w,
              ),
              Text(text,
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ));
  }
}
