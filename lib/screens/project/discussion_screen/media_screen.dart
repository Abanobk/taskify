import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hive/hive.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/permissions/permissions_event.dart';
import '../../../bloc/project_discussion/project_media/project_media_bloc.dart';
import '../../../bloc/project_discussion/project_media/project_media_state.dart';
import '../../../bloc/project_discussion/project_milestone/project_milestone_bloc.dart';
import '../../../bloc/project_discussion/project_milestone/project_milestone_event.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/colors.dart';
import '../../../config/constants.dart';
import '../../../config/strings.dart';
import '../../../data/model/project/media.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_dimissible.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/search_pop_up.dart';
import '../../../utils/widgets/shake_widget.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../notes/widgets/notes_shimmer_widget.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/no_data.dart';
import '../../widgets/no_permission_screen.dart';
import '../../widgets/search_field.dart';
import '../../widgets/speech_to_text.dart';

class MediaScreen extends StatefulWidget {
  final int? id;
  const MediaScreen({super.key, this.id});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  TextEditingController mediaSearchController = TextEditingController();
  bool isLoading = true;
  String mediaSearchQuery = '';
  bool isFirst = false;
  bool isLoadingMore = false;
  bool isFirstTimeUSer = true;
  final GlobalKey _one = GlobalKey();
  OverlayEntry? _overlayEntry;

  // Store last media list for rendering during download
  List<MediaModel> lastMediaList = [];
  bool hasReachedMax = false;

  late SpeechToTextHelper speechHelper;

  @override
  void initState() {
    super.initState();
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          mediaSearchController.text = result;
          context.read<ProjectMilestoneBloc>().add(SearchProjectMilestone(
              widget.id, mediaSearchQuery, "", "", "", "", "", "", ""));
        });
        Navigator.pop(context);
      },
    );
    _getFirstTimeUser();
    context.read<ProjectMediaBloc>().add(MediaList(id: widget.id));
    speechHelper.initSpeech();
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    mediaSearchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    BlocProvider.of<ProjectMilestoneBloc>(context)
        .add(MileStoneList(id: widget.id));
    BlocProvider.of<ProjectMediaBloc>(context).add(MediaList(id: widget.id));
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getFirstTimeUser() async {
    var box = await Hive.openBox(authBox);
    setState(() {
      isFirstTimeUSer = box.get(firstTimeUserKey) ?? true;
      isFirst = box.get("isFirstCase") ?? false;
    });
  }

  Future<void> _setIsFirst(bool value) async {
    setState(() {
      isFirst = value;
    });
    var box = await Hive.openBox(authBox);
    await box.put("isFirstCase", value);
  }

  void onShowCaseCompleted() {
    _setIsFirst(false);
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    bool isLightTheme = currentTheme is LightThemeState;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      onRefresh: _onRefresh,
      child: context.read<PermissionsBloc>().isManageProject == true
          ? Column(
              children: [
                CustomSearchField(
                  isLightTheme: isLightTheme,
                  controller: mediaSearchController,
                  suffixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (mediaSearchController.text.isNotEmpty)
                          SizedBox(
                            width: 20.w,
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
                                setState(() {
                                  mediaSearchController.clear();
                                  mediaSearchQuery = '';
                                });
                                context
                                    .read<ProjectMediaBloc>()
                                    .add(SearchMedia("", widget.id));
                              },
                            ),
                          ),
                        SizedBox(
                          width: 30.w,
                          child: IconButton(
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
                                speechHelper.startListening(context,
                                    mediaSearchController, SearchPopUp());
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      mediaSearchQuery = value;
                    });
                    context
                        .read<ProjectMediaBloc>()
                        .add(SearchMedia(value, widget.id));
                  },
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: BlocConsumer<ProjectMediaBloc, ProjectMediaState>(
                    listener: (context, state) {
                      print("Bloc state: $state");
                      if (state is ProjectMediaPaginated) {
                        lastMediaList = state.ProjectMedia;
                        hasReachedMax = state.hasReachedMax;
                        isLoadingMore = false;
                        setState(() {});
                      } else if (state is DownloadSuccess) {
                        _removeProgressOverlay(); // Remove overlay on success
                        flutterToastCustom(msg: "Download completed: ${state.fileName}", color: AppColors.primary);
                        Future.delayed(Duration(milliseconds: 500), () {
                          context.read<ProjectMediaBloc>().add(SilentMediaRefresh(id: widget.id));
                        });
                      } else if (state is DownloadFailure) {
                        _removeProgressOverlay(); // Remove overlay on failure
                        flutterToastCustom(msg: "Download failed: ${state.error}", color: AppColors.red);
                      } else if (state is DownloadInProgress) {
                        showToastWithProgress(context, state.progress, state.fileName);
                      } else if (state is ProjectMediaDeleteSuccess) {
                        flutterToastCustom(
                            msg: AppLocalizations.of(context)!.deletedsuccessfully, color: AppColors.red);
                        context.read<ProjectMediaBloc>().add(MediaList(id: widget.id));
                      } else if (state is ProjectMediaError) {
                        flutterToastCustom(msg: state.errorMessage, color: AppColors.red);
                      }
                    },
                    builder: (context, state) {
                      print(
                          "Current state: $state, lastMediaList length: ${lastMediaList.length}");

                      Widget buildMediaList(
                          List<MediaModel> mediaList, bool reachedMax) {
                        return NotificationListener<ScrollNotification>(
                          onNotification: (scrollInfo) {
                            if (scrollInfo is ScrollStartNotification) {
                              FocusScope.of(context).unfocus();
                            }
                            if (!reachedMax &&
                                scrollInfo.metrics.pixels ==
                                    scrollInfo.metrics.maxScrollExtent &&
                                !isLoadingMore) {
                              isLoadingMore = true;
                              setState(() {});
                              // context.read<ProjectMediaBloc>().add(LoadMoreMedia(widget.id));
                            }
                            return false;
                          },
                          child: context
                                      .read<PermissionsBloc>()
                                      .isManageProject ==
                                  true
                              ? mediaList.isNotEmpty
                                  ? ListView.builder(
                                      padding: EdgeInsets.only(
                                          left: 18.w,
                                          right: 18.w,
                                          bottom: 70.h),
                                      shrinkWrap: true,
                                      itemCount: reachedMax
                                          ? mediaList.length
                                          : mediaList.length + 1,
                                      itemBuilder: (context, index) {
                                        if (index < mediaList.length) {
                                          MediaModel media = mediaList[index];
                                          String? startDate;
                                          String? endDate;

                                          if (media.updatedAt != null) {
                                            startDate = formatDateFromApi(
                                                media.updatedAt!, context);
                                          }
                                          if (media.createdAt != null) {
                                            endDate = formatDateFromApi(
                                                media.createdAt!, context);
                                          }

                                          return (index == 0 && isFirstTimeUSer)
                                              ? ShakeWidget(
                                                  child: Showcase(
                                                    onTargetClick: () {
                                                      ShowCaseWidget.of(context)
                                                          .completed(_one);
                                                      if (ShowCaseWidget.of(
                                                                  context)
                                                              .activeWidgetId ==
                                                          1) {
                                                        onShowCaseCompleted();
                                                      }
                                                      _setIsFirst(false);
                                                    },
                                                    disposeOnTap: true,
                                                    key: _one,
                                                    title: AppLocalizations.of(
                                                            context)!
                                                        .swipe,
                                                    titleAlignment:
                                                        Alignment.center,
                                                    descriptionAlignment:
                                                        Alignment.center,
                                                    description:
                                                        "${AppLocalizations.of(context)!.swipelefttodelete} \n${AppLocalizations.of(context)!.swiperighttoedit}",
                                                    tooltipBackgroundColor:
                                                        AppColors.primary,
                                                    textColor: Colors.white,
                                                    child: ShakeWidget(
                                                        child: mediaCard(
                                                            mediaList,
                                                            index,
                                                            media,
                                                            startDate,
                                                            endDate)),
                                                  ),
                                                )
                                              : mediaCard(mediaList, index,
                                                  media, startDate, endDate);
                                        } else {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 0),
                                            child: Center(
                                              child: reachedMax
                                                  ? const Text('')
                                                  : const SpinKitFadingCircle(
                                                      color: AppColors.primary,
                                                      size: 40.0,
                                                    ),
                                            ),
                                          );
                                        }
                                      },
                                    )
                                  : NoData(isImage: true)
                              : NoPermission(),
                        );
                      }

                      if (state is ProjectMediaLoading) {
                        return const NotesShimmer();
                      } else if (state is ProjectMediaPaginated) {
                        return buildMediaList(
                            state.ProjectMedia, state.hasReachedMax);
                      } else if (state is DownloadInProgress) {
                        return buildMediaList(lastMediaList, hasReachedMax);
                      } else if (state is ProjectMediaUploadSuccess ||
                          state is ProjectMediaError ||
                          state is DownloadSuccess ||
                          state is DownloadFailure ||
                          state is ProjectMediaDeleteSuccess) {
                        if (lastMediaList.isNotEmpty) {
                          return buildMediaList(lastMediaList, hasReachedMax);
                        } else {
                          context
                              .read<ProjectMediaBloc>()
                              .add(MediaList(id: widget.id));
                          return const NotesShimmer();
                        }
                      }

                      return lastMediaList.isNotEmpty
                          ? buildMediaList(lastMediaList, hasReachedMax)
                          : const NotesShimmer();
                    },
                  ),
                ),
              ],
            )
          : const NoPermission(),
    );
  }

  void _removeProgressOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void showToastWithProgress(BuildContext context, double progress, String fileName) {
    print("Attempting to show overlay for $fileName with progress: $progress");
    _removeProgressOverlay(); // Remove any existing overlay
    OverlayState? overlayState = Overlay.of(context);
    if (overlayState == "") {
      print("Error: OverlayState is null, cannot insert overlay");
      return;
    }

    _overlayEntry = OverlayEntry(
      opaque: false, // Allow underlying content to show through semi-transparent background
      builder: (context) {
        // Debug: Print the resolved containerDark color
        final containerColor = Theme.of(context).colorScheme.containerDark;
        print("Resolved containerDark color: $containerColor");

        // Use a fallback color if containerDark is pure white or transparent
        final backgroundColor = (containerColor == Colors.white || containerColor.a < 50)
            ? AppColors.pureWhiteColor // Fallback to blue for visibility
            : containerColor.withValues(alpha: 0.9);

        return AbsorbPointer(
          absorbing: true, // Block all user input
          child: Stack(
            children: [
              // Semi-transparent background to dim the entire screen
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5), // Dim the background
                ),
              ),
              // Centered progress dialog
              Center(
                child: Material(
                  elevation: 8.0,
                  borderRadius: BorderRadius.circular(17.4),
                  color: Colors.transparent, // Material is transparent to show Container
                  child: Container(
                    width: 300.w, // Fixed width for the dialog
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17.4),
                      color: backgroundColor, // Use computed background color
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Minimize column size
                        children: [
                          CustomText(
                            text: "Downloading $fileName",
                            color: Theme.of(context).colorScheme.textClrChange ,
                            size: 16.sp,
                            fontWeight: FontWeight.bold,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10.h),
                          CustomText(
                            text: "${(progress.clamp(0.0, 1.0) * 100).toStringAsFixed(0)}%",
                            color: Theme.of(context).colorScheme.textClrChange ,
                            size: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          SizedBox(height: 15.h),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.withValues(alpha: 0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            minHeight: 8.h,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    print("Inserting overlay into OverlayState");
    overlayState.insert(_overlayEntry!);
  }

  Widget mediaCard(projectMedia, index, media, startDate, endDate) {
    return DismissibleCard(
      key: ValueKey(media.id),
      direction: context.read<PermissionsBloc>().isdeleteMedia == true
          ? DismissDirection.endToStart
          : DismissDirection.none,
      title: index.toString(),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Handle edit if needed
        }
        if (direction == DismissDirection.endToStart &&
            context.read<PermissionsBloc>().isdeleteMedia == true) {
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
                  projectMedia.removeAt(index);
                });
                context
                    .read<ProjectMediaBloc>()
                    .add(DeleteProjectMedia(id: media.id));
              });
              // Return false to prevent the dismissible from animating
              return false;
            }

            return false; // Always return false since we handle deletion manually
          } catch (e) {
            print("Error in dialog: $e");
            return false;
          } // Return the result of the dialog
        }
        ;
        return false; // Default case
      },
      onDismissed: (DismissDirection direction) {
        if (direction == DismissDirection.endToStart &&
            context.read<PermissionsBloc>().isdeleteMedia == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              projectMedia.removeAt(index);
            });
            context
                .read<ProjectMediaBloc>()
                .add(DeleteProjectMedia(id: media.id));
          });
        }
      },
      dismissWidget: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: customContainer(
          context: context,
          addWidget: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: "#${media.id.toString()}",
                          size: 14.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w700,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        InkWell(
                          onTap: () {
                            context.read<ProjectMediaBloc>().add(StartDownload(
                                fileUrl: media.file, fileName: media.fileName));
                          },
                          child: GlowContainer(
                            shape: BoxShape.circle,
                            glowColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.6),
                            child: CircleAvatar(
                              radius: 15.sp,
                              backgroundColor:
                                  Theme.of(context).colorScheme.backGroundColor,
                              child: HeroIcon(
                                HeroIcons.arrowDown,
                                style: HeroIconStyle.outline,
                                size: 15.sp,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.all(10),
                            height: 50.h,
                            width: 50.w,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(media.preview),
                                  fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Expanded(
                          flex: 3,
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: CustomText(
                                        text: media.fileName,
                                        size: 15.sp,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textClrChange,
                                        fontWeight: FontWeight.w700,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      text: media.fileSize,
                                      size: 12.sp,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textClrChange,
                                      fontWeight: FontWeight.w700,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 10.h),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        text: startDate,
                                        size: 12.sp,
                                        color: AppColors.greyColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      Center(
                                        child: Icon(
                                          Icons.compare_arrows,
                                          color: AppColors.greyColor,
                                          size: 20,
                                        ),
                                      ),
                                      CustomText(
                                        text: endDate,
                                        size: 12.sp,
                                        color: AppColors.greyColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
