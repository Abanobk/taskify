import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:taskify/bloc/candidate_interviews/candidate_interviews_bloc.dart';
import 'package:taskify/bloc/candidate_interviews/candidate_interviews_state.dart';
import 'package:taskify/data/model/interview/interview_model.dart';
import '../../../../bloc/candidate_interviews/candidate_interviews_event.dart';
import '../../../../bloc/interviews/interviews_bloc.dart';
import '../../../../bloc/interviews/interviews_event.dart';
import '../../../../bloc/interviews/interviews_state.dart';
import '../../../../bloc/permissions/permissions_bloc.dart';
import '../../../../bloc/permissions/permissions_event.dart';
import '../../../../bloc/theme/theme_bloc.dart';
import '../../../../bloc/theme/theme_state.dart';
import '../../../../config/app_images.dart';
import '../../../../config/colors.dart';
import '../../../../config/strings.dart';

import '../../../../routes/routes.dart';
import '../../../../src/generated/i18n/app_localizations.dart';import '../../../../utils/widgets/custom_dimissible.dart';
import '../../../../utils/widgets/custom_text.dart';
import '../../../../utils/widgets/my_theme.dart';

import '../../../../utils/widgets/shake_widget.dart';
import '../../../../utils/widgets/toast_widget.dart';
import '../../../notes/widgets/notes_shimmer_widget.dart';

import '../../../widgets/no_data.dart';


class CandidateInterviewsScreen extends StatefulWidget {
  final int? id;
  final String? name;
  const CandidateInterviewsScreen({super.key,this.id,this.name});

  @override
  State<CandidateInterviewsScreen> createState() => _CandidateInterviewsScreenState();
}

class _CandidateInterviewsScreenState extends State<CandidateInterviewsScreen> {
  bool? isLoading = true;
  bool? isFirst;
  bool isLoadingMore = false;

  String? statusname;
  bool? isFirstTimeUSer;

  @override
  void initState() {
    BlocProvider.of<CandidateInterviewssBloc>(context).add(CandidateInterviewsList(id: widget.id));
print("tfuyio ${widget.name}");
print("tfuyio ${widget.id}");
    // TODO: implement initState
    super.initState();

  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    BlocProvider.of<CandidateInterviewssBloc>(context).add(CandidateInterviewsList(id: widget.id));

    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());

    setState(() {
      isLoading = false;
    });
  }

  void onShowCaseCompleted() {
    _setIsFirst(false);
  }
  _setIsFirst(value) async {
    isFirst = value;
    var box = await Hive.openBox(authBox);
    box.put("isFirstCase", value);
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return RefreshIndicator(
      color: AppColors.primary, // Spinner color
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      onRefresh: _onRefresh,
      child: BlocConsumer<CandidateInterviewssBloc, CandidateInterviewsState>(
        listener: (context, state) {
          if (state is InterviewsSuccess) {
            isLoadingMore = false;
            setState(() {});
          }  if (state is InterviewsDeleteSuccess) {
            flutterToastCustom(
                msg: AppLocalizations.of(context)!
                    .deletedsuccessfully,
                color: AppColors.red);
            BlocProvider.of<CandidateInterviewssBloc>(context).add(CandidateInterviewsList(id: widget.id));
          } if (state is CandidateInterviewssDeleteSuccess) {
            flutterToastCustom(
                msg: AppLocalizations.of(context)!
                    .deletedsuccessfully,
                color: AppColors.red);
            BlocProvider.of<CandidateInterviewssBloc>(context).add(CandidateInterviewsList(id: widget.id));
          }
          if (state is CandidateInterviewssCreateSuccess) {
            flutterToastCustom(
                msg: AppLocalizations.of(context)!
                    .createdsuccessfully,
                color: AppColors.red);
            BlocProvider.of<CandidateInterviewssBloc>(context).add(CandidateInterviewsList(id: widget.id));
          } if (state is CandidateInterviewssEditSuccess) {
            flutterToastCustom(
                msg: AppLocalizations.of(context)!
                    .updatedsuccessfully,
                color: AppColors.red);
            BlocProvider.of<CandidateInterviewssBloc>(context).add(CandidateInterviewsList(id: widget.id));
          }  if (state is CandidateInterviewssCreateError) {
            flutterToastCustom(
                msg: state.errorMessage,
                color: AppColors.red);
            BlocProvider.of<CandidateInterviewssBloc>(context).add(CandidateInterviewsList(id: widget.id));
          }   if (state is CandidateInterviewssDeleteError) {
            flutterToastCustom(
                msg: state.errorMessage,
                color: AppColors.red);
            BlocProvider.of<CandidateInterviewssBloc>(context).add(CandidateInterviewsList(id: widget.id));
          } if (state is CandidateInterviewssEditError) {
            flutterToastCustom(
                msg: state.errorMessage,
                color: AppColors.red);
            BlocProvider.of<CandidateInterviewssBloc>(context).add(CandidateInterviewsList(id: widget.id));
          }
        },
        builder: (context, state) {
          print("Interviews Bloc $state");
          if (state is CandidateInterviewssLoading || state is CandidateInterviewssEditSuccessLoading) {
            return const NotesShimmer();
          } else if (state is CandidateInterviewssPaginated) {
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
                      .add(LoadMoreInterviews(""));
                }
                return false;
              },
              child: state.CandidateInterviewss.isNotEmpty
                  ? _interviewLists(
                isLightTheme,
                state.hasReachedMax,
                state.CandidateInterviewss,
              )
                  : NoData(
                isImage: true,
              ),
            );
          } else if (state is CandidateInterviewssError) {
            return SizedBox();
          } else if (state is CandidateInterviewssEditSuccess) {
            BlocProvider.of<InterviewsBloc>(context).add(InterviewsList());
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.updatedsuccessfully,
                color: AppColors.primary);
          } else if (state is CandidateInterviewssEditError) {
            BlocProvider.of<CandidateInterviewssBloc>(context).add(CandidateInterviewsList());
            flutterToastCustom(
                msg: state.errorMessage, color: AppColors.primary);
          } else if (state is CandidateInterviewssSuccess) {
            // Show initial list of notes
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 10, // Horizontal spacing
                mainAxisSpacing: 10, // Vertical spacing
                childAspectRatio: 1, // Width/Height ratio
              ),
              itemCount: state.CandidateInterviewss.length +
                  1, // Add 1 for the loading indicator
              itemBuilder: (context, index) {
                if (index < state.CandidateInterviewss.length) {
                  final interview = state.CandidateInterviewss[index];
                  return state.CandidateInterviewss.isEmpty
                      ? NoData(
                    isImage: true,
                  )
                      : _interviewListContainer(
                    interview,
                    isLightTheme,
                    state.CandidateInterviewss,
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
          } else if (state is CandidateInterviewssCreateSuccess) {
            Navigator.pop(context);
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.createdsuccessfully,
                color: AppColors.primary);
            BlocProvider.of<CandidateInterviewssBloc>(context).add(CandidateInterviewsList());

          }
          // Handle other states
          return const Text("");
        },
      ),
    );
  }
  Widget _interviewLists(isLightTheme, hasReachedMax, interviewList) {
    // statusList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

    // Reverse the list so the last item appears first
    // statusList = statusList.reversed.toList();
    return ListView.builder(
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
    );
  }
  Widget _interviewListContainer(InterviewModel interview, bool isLightTheme,
      List<InterviewModel> statusModel, int index) {
    return index == 0
        ? ShakeWidget(
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
          child: DismissibleCard(
            title: interview.id!.toString(),
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
                        statusModel.removeAt(index);

                      });
                      context.read<CandidateInterviewssBloc>().add(DeleteCandidateInterview(interview.id!));
                    });
                    // Return false to prevent the dismissible from animating
                    return false;
                  }

                  return false; // Always return false since we handle deletion manually
                } catch (e) {
                  print("Error in dialog: $e");
                  return false;
                }// Return the result of the dialog
              } else if (direction == DismissDirection.startToEnd) {
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
                print("tyuiom ewe ${widget.id}");
                router.push(
                  '/createeditinterview',
                  extra: {
                    'isCreate': false,
                    'interviewModel': interviewModel,
                    'candidateId':widget.id,
                    'candidateName':widget.name
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
              if (direction == DismissDirection.endToStart) {
                WidgetsBinding.instance.addPostFrameCallback((_) {  setState(() {
                  statusModel.removeAt(index);

                });
    context.read<CandidateInterviewssBloc>().add(DeleteCandidateInterview(interview.id!));

    });
              }
            },
          )),
    )
        : Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
        child: DismissibleCard(
          title: interview.id!.toString(),
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
                      statusModel.removeAt(index);

                    });
                    context.read<CandidateInterviewssBloc>().add(DeleteCandidateInterview(interview.id!));
                  });
                  // Return false to prevent the dismissible from animating
                  return false;
                }

                return false; // Always return false since we handle deletion manually
              } catch (e) {
                print("Error in dialog: $e");
                return false;
              }// Return the result of the dialog
            } else if (direction == DismissDirection.startToEnd) {
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
              print("tyuiom ewe ${widget.id}");
              router.push(
                '/createeditinterview',
                extra: {
                  'isCreate': false,
                  'interviewModel': interviewModel,
                  'candidateId':widget.id,
                  'candidateName':widget.name
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
            if (direction == DismissDirection.endToStart) {
              WidgetsBinding.instance.addPostFrameCallback((_) {  setState(() {
                statusModel.removeAt(index);

              });
              context.read<CandidateInterviewssBloc>().add(DeleteCandidateInterview(interview.id!));

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
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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



              ],
            ),
            SizedBox(height: 10.h,),
            _buildChip("Candidate", interview.interviewerName.toString(),
                Icons.person_outline, AppImages.nameImage, true, true),
            _buildChip("Interviewer", interview.interviewerName.toString(),
                Icons.record_voice_over, AppImages.emailImage, true, true),
            _buildChip("Round", interview.round, Icons.phone_outlined,
                AppImages.phoneImage, true, true),
            _buildChip("Location", interview.location ?? "",
                Icons.location_history, AppImages.sourceImage, true, true),
            Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: _buildChip("Mode", interview.mode, Icons.record_voice_over,
                  AppImages.interviewImage, false, true),
            ),

            Padding(
              padding: EdgeInsets.only(left: 30.w),
              child: IntrinsicWidth(
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
      String label,
      String text,
      IconData? icon,
      String images,
      bool? isIconRequired,
      bool? isLabelRequired,
      ) {
    return Tooltip(
      message: label,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
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
            if (isIconRequired == true)
              Container(
                child: Image.asset(
                  images,
                  height: 20.h,
                  width: 20.w,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.error,
                    size: 20.sp,
                    color: Colors.red,
                  ),
                ),
              ),

              SizedBox(
                width: 10.w,
              ),
            if (isLabelRequired == true)
              CustomText(
                text: "$label :",
                color: Colors.grey,
                size: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            if (isLabelRequired == true)
              SizedBox(
                width: 10.w,
              ),
            Expanded(
              child: CustomText(
                text: text,
                color: Colors.grey,
                size: 12.sp,
                maxLines: 10,
                softwrap: true, // Use softWrap instead of softwrap
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
