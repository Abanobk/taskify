import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import '../../../bloc/activity_log/activity_log_bloc.dart';
import '../../../bloc/activity_log/activity_log_event.dart';
import '../../../bloc/activity_log/activity_log_state.dart';
import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/permissions/permissions_event.dart';
import '../../../bloc/project_discussion/project_milestone/project_milestone_bloc.dart';
import '../../../bloc/project_discussion/project_milestone/project_milestone_event.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/user_profile/user_profile_bloc.dart';
import '../../../config/app_images.dart';
import '../../../config/colors.dart';
import '../../../config/constants.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/circularprogress_indicator.dart';
import '../../../utils/widgets/custom_dimissible.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/search_pop_up.dart';
import '../../../utils/widgets/shake_widget.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../notes/widgets/notes_shimmer_widget.dart';
import '../../widgets/no_data.dart';
import '../../widgets/search_field.dart';
import '../../widgets/speech_to_text.dart';

class ProjectActivityLogScreen extends StatefulWidget {
  final int? id;
  const ProjectActivityLogScreen({super.key,this.id});

  @override
  State<ProjectActivityLogScreen> createState() => _ProjectActivityLogScreenState();
}

class _ProjectActivityLogScreenState extends State<ProjectActivityLogScreen> {
  bool? isLoading = true;
  @override
  void initState() {
    activityLogSearchController.addListener(() {
      setState(() {});
    });
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          activityLogSearchController.text = result;
          context
              .read<ActivityLogBloc>()
              .add(SearchActivityLog("", widget.id, "project"));

        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    super.initState();
  }
  late SpeechToTextHelper speechHelper;
  String activityLogSearchQuery = '';
  TextEditingController activityLogSearchController = TextEditingController();
  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    // filterCount = 0;
    BlocProvider.of<ProjectMilestoneBloc>(context)
        .add(MileStoneList(id: widget.id));
    BlocProvider.of<ActivityLogBloc>(context)
        .add(AllActivityLogList(type: "project", typeId: widget.id));

    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());

    setState(() {
      isLoading = false;
    });
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
      child: Column(
        children: [
          CustomSearchField(
            isLightTheme: isLightTheme,
            controller: activityLogSearchController,
            suffixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (activityLogSearchController.text.isNotEmpty)
                    SizedBox(
                      width: 20.w,
                      // color: AppColors.red,
                      child: IconButton(
                        highlightColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.clear,
                          size: 20.sp,
                          color: Theme.of(context).colorScheme.textFieldColor,
                        ),
                        onPressed: () {
                          // Clear the search field
                          setState(() {
                            activityLogSearchController.clear();
                          });
                          // Optionally trigger the search event with an empty string
                          context
                              .read<ActivityLogBloc>()
                              .add(SearchActivityLog("", widget.id, "project"));
                        },
                      ),
                    ),
                  SizedBox(
                    width: 30.w,
                    child: IconButton(
                      icon: Icon(
                        !speechHelper.isListening ? Icons.mic_off : Icons.mic,
                        size: 20.sp,
                        color: Theme.of(context).colorScheme.textFieldColor,
                      ),
                      onPressed: () {
                        if (speechHelper.isListening) {
                          speechHelper.stopListening();
                        } else {
                          speechHelper.startListening(
                              context, activityLogSearchController, SearchPopUp());
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            onChanged: (value) {
              activityLogSearchQuery = value;
              context.read<ActivityLogBloc>().add(SearchActivityLog(
                  activityLogSearchQuery, widget.id, "project"));
            },
          ),
          SizedBox(height: 10.h),
          BlocConsumer<ActivityLogBloc, ActivityLogState>(
            listener: (context, state) {
              if (state is ActivityLogDeleteSuccess) {
                flutterToastCustom(
                    msg: AppLocalizations.of(context)!.deletedsuccessfully,
                    color: AppColors.primary);
                BlocProvider.of<ActivityLogBloc>(context)
                    .add(AllActivityLogList());
              } else if (state is ActivityLogError) {
                BlocProvider.of<ActivityLogBloc>(context)
                    .add(AllActivityLogList());

                flutterToastCustom(msg: state.errorMessage);
              } else if (state is ActivityLogDeleteError) {
                BlocProvider.of<ActivityLogBloc>(context)
                    .add(AllActivityLogList());

                flutterToastCustom(msg: state.errorMessage);
              }
            },
            builder: (context, state) {
              print("efrdjxnm  $state");
              if (state is ActivityLogLoading) {
                return Expanded(
                  child: NotesShimmer(
                    height: 190.h,
                    count: 4,
                  ),
                );
              }
              else if (state is ActivityLogPaginated) {
                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (!state.hasReachedMax &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      context
                          .read<ActivityLogBloc>()
                          .add(LoadMoreActivityLog(""));
                    }
                    return false;
                  },
                  child: state.activityLog.isNotEmpty
                      ? _activityLogList(
                      isLightTheme, state.hasReachedMax, state.activityLog)

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
        ],
      ),
    );
  }
  Widget _activityLogList(isLightTheme, hasReachedMax, activityLog) {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: 0.h),
        // shrinkWrap: true,
        itemCount: hasReachedMax
            ? activityLog.length // No extra item if all data is loaded
            : activityLog.length + 1, // Add 1 for the loading indicator
        itemBuilder: (context, index) {
          if (index < activityLog.length) {
            final activity = activityLog[index];
            String? dateCreated;
            dateCreated = formatDateFromApi(activity.createdAt!, context);
            return index == 0
                ? ShakeWidget(
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 10.h, horizontal: 18.w),
                  child: DismissibleCard(
                    title: activityLog[index].id.toString(),
                    confirmDismiss: (DismissDirection direction) async {
                      if (direction == DismissDirection.endToStart) {
                        // Right to left swipe (Delete action)
                        final result = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.r), // Set the desired radius here
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
                                    Navigator.of(context)
                                        .pop(true); // Confirm deletion
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.delete,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
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
                        return result;
                      }
                      return false;
                    },
                    dismissWidget: _activityChild(
                        isLightTheme, activityLog[index], dateCreated),
                    direction: context
                        .read<PermissionsBloc>()
                        .isdeleteActivityLog ==
                        true
                        ? DismissDirection.endToStart
                        : DismissDirection.none,
                    onDismissed: (DismissDirection direction) {
                      if (direction == DismissDirection.endToStart) {
                        setState(() {
                          activityLog.removeAt(index);
                          context.read<ActivityLogBloc>().add(DeleteActivityLog(activity.id));

                        });
                      }
                    },
                  )),
            )
                : Padding(
                padding:
                EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
                child: DismissibleCard(
                  title: activityLog[index].id.toString(),
                  confirmDismiss: (DismissDirection direction) async {
                    if (direction == DismissDirection.endToStart) {
                      // Right to left swipe (Delete action)
                      final result = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10.r), // Set the desired radius here
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
                                  Navigator.of(context)
                                      .pop(true); // Confirm deletion
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.delete,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
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
                      return result;
                    }
                    return false;
                  },
                  dismissWidget: _activityChild(
                      isLightTheme, activityLog[index], dateCreated),
                  direction:
                  context.read<PermissionsBloc>().isdeleteActivityLog ==
                      true
                      ? DismissDirection.endToStart
                      : DismissDirection.none,
                  onDismissed: (DismissDirection direction) {
                    if (direction == DismissDirection.endToStart) {
                      setState(() {
                        activityLog.removeAt(index);
                        context.read<ActivityLogBloc>().add(DeleteActivityLog(activity.id));
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
      ),
    );
  }
  Widget _activityChild(isLightTheme, activityLog, dateCreated) {
    String? profilePic;
    if (context.read<UserProfileBloc>().profilePic != null) {
      profilePic = context.read<UserProfileBloc>().profilePic;
    }
    return Container(
        decoration: BoxDecoration(
            boxShadow: [
              isLightTheme
                  ? MyThemes.lightThemeShadow
                  : MyThemes.darkThemeShadow,
            ],
            color: Theme.of(context).colorScheme.containerDark,
            borderRadius: BorderRadius.circular(12)),
        // height: 170.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 3,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                      EdgeInsets.only(top: 20.h, left: 18.w, right: 18.w),
                      child: SizedBox(
                        // height: 40.h,

                        // color: Colors.yellow,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: "#${activityLog.id.toString()}",
                                          size: 12.sp,
                                          color: AppColors.projDetailsSubText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        SizedBox(
                                          height: 15.h,
                                        ),
                                        SizedBox(
                                          // color: Colors.red,
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                // width:30.w,
                                                // alignment: Alignment.center,
                                                child: CircleAvatar(
                                                  radius: 25.r,
                                                  backgroundColor:
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .backGroundColor,
                                                  child: profilePic != null
                                                      ? CircleAvatar(
                                                    backgroundImage:
                                                    NetworkImage(
                                                        profilePic),
                                                    radius: 25
                                                        .r, // Size of the profile image
                                                  )
                                                      : CircleAvatar(
                                                    radius: 25
                                                        .r, // Size of the profile image
                                                    backgroundColor:
                                                    Colors.grey[200],
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 20.sp,
                                                      color: Colors.grey,
                                                    ), // Replace with your image URL
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10.w,
                                              ),
                                              SizedBox(
                                                width: 140.w,
                                                // color: Colors.orange,
                                                child: CustomText(
                                                  text: activityLog.actorName ??
                                                      "",
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .textClrChange,
                                                  size: 17,
                                                  maxLines: 2,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 0.w),
                                          child: SizedBox(
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start, // Align text to the top
                                                  children: [
                                                    HeroIcon(
                                                      HeroIcons.envelope,
                                                      style:
                                                      HeroIconStyle.outline,
                                                      color: AppColors
                                                          .projDetailsSubText,
                                                      size: 20.sp,
                                                    ),
                                                    SizedBox(width: 10.w),
                                                    ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                          maxWidth: 180
                                                              .w), // Adjust width accordingly
                                                      child: CustomText(
                                                        text: activityLog
                                                            .message ??
                                                            "No message",
                                                        color: Colors.grey,
                                                        size: 15,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        maxLines: null,
                                                        softwrap: true,
                                                        overflow: TextOverflow
                                                            .visible,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10.w,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    HeroIcon(
                                                      HeroIcons.clock,
                                                      style:
                                                      HeroIconStyle.outline,
                                                      color: AppColors
                                                          .projDetailsSubText,
                                                      size: 20.sp,
                                                    ),
                                                    SizedBox(
                                                      width: 10.w,
                                                    ),
                                                    Container(
                                                      // width: 220.w,
                                                      alignment:
                                                      Alignment.topLeft,
                                                      // color: Colors.orange,
                                                      child: CustomText(
                                                        text: dateCreated,
                                                        color: Colors.grey,
                                                        size: 15,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20.w,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Divider(color: colors.darkColor),
                  ]),
            ),
            Flexible(
              flex: 1,
              child: Container(
                // color: Colors.red,
                child: Image.asset(AppImages.activityImage,
                    height: 70.h, width: 70.w),
              ),
            )
          ],
        ));
  }

}
