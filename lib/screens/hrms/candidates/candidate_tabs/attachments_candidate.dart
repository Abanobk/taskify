import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/candidate/candidates_bloc.dart';
import 'package:taskify/bloc/candidate/candidates_event.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/notes/widgets/notes_shimmer_widget.dart';
import 'package:taskify/utils/widgets/custom_dimissible.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import '../../../../bloc/candidate_attachment/candidate_attachment_bloc.dart';
import '../../../../bloc/candidate_attachment/candidate_attachment_state.dart';
import '../../../../bloc/permissions/permissions_bloc.dart';
import '../../../../bloc/permissions/permissions_event.dart';


import '../../../../config/internet_connectivity.dart';
import '../../../../data/model/candidate/attachment_candidate.dart';
import '../../../../src/generated/i18n/app_localizations.dart';import '../../../../utils/widgets/custom_text.dart';

import '../../../../utils/widgets/no_permission_screen.dart';


import '../../../widgets/custom_container.dart';
import '../../../widgets/no_data.dart';

import '../../../widgets/side_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import '../../../widgets/speech_to_text.dart';

class CandidateAttachmentScreen extends StatefulWidget {
  final int? id;
  const CandidateAttachmentScreen({super.key, this.id});

  @override
  State<CandidateAttachmentScreen> createState() => _CandidateAttachmentScreenState();
}

class _CandidateAttachmentScreenState extends State<CandidateAttachmentScreen> {
  TextEditingController mediaSearchController = TextEditingController();
  bool isLoading = true;
  bool isFirstTimeUser = true;
  bool isLoadingMore = false;

  String searchWord = "";

  OverlayEntry? _overlayEntry;
  late SpeechToTextHelper speechHelper;
  TextEditingController searchController = TextEditingController();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;


  final SlidableBarController sideBarController =
  SlidableBarController(initialStatus: false);

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
    BlocProvider.of<CandidateAttachmentBloc>(context)
        .add(AttachmentList(id: widget.id));

  }

  @override
  void dispose() {
    mediaSearchController.dispose();
    _connectivitySubscription.cancel();

    _removeProgressOverlay();
    super.dispose();
  }





  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    context.read<CandidateAttachmentBloc>().add(SilentAttachmentRefresh(id: widget.id));
    context.read<PermissionsBloc>().add(GetPermissions());
    setState(() {
      isLoading = false;
    });
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
                            color: Theme.of(context).colorScheme.textClrChange,
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


  void _removeProgressOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _getFileIcon(String mimeType) {
    switch (mimeType) {
      case 'application/pdf':
        return Icon(Icons.picture_as_pdf, size: 40.sp, color: AppColors.red);
      case 'image/jpeg':
      case 'image/png':
        return Icon(Icons.image, size: 40.sp, color: AppColors.primary);
      case 'application/msword':
      case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        return Icon(Icons.description, size: 40.sp, color: AppColors.orangeYellowishColor);
      default:
        return Icon(Icons.insert_drive_file, size: 40.sp, color: AppColors.greyColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return  _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : Scaffold(
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
    body: SideBar(
    context: context,
    controller: sideBarController,
    underWidget:RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      onRefresh: _onRefresh,
      child: context.read<PermissionsBloc>().isManageCandidate == true
          ? Column(
        children: [

          Expanded(
            child: BlocConsumer<CandidateAttachmentBloc, CandidateAttachmentState>(
              listener: (context, state) {
                if (state is CandidateAttachmentPaginated ||
                    state is DownloadInProgressCandidate ||
                    state is DownloadSuccessCandidate ||
                    state is DownloadFailureCandidate) {
                  setState(() {
                    isLoadingMore = false;
                  });
                }
                if (state is DownloadInProgressCandidate) {

                  showToastWithProgress(context, state.progress, state.fileName);
                } else if (state is DownloadSuccessCandidate) {
                  _removeProgressOverlay();
                  flutterToastCustom(
                    msg: "Downloaded: ${state.fileName} to ${state.filePath}",
                    color: AppColors.primary,
                  );
                  context.read<CandidateAttachmentBloc>().add(SilentAttachmentRefresh(id: widget.id));
                } else if (state is DownloadFailureCandidate) {
                  _removeProgressOverlay();
                  flutterToastCustom(
                    msg: "Download failed: ${state.error}",
                    color: AppColors.red,
                  );
                  context.read<CandidateAttachmentBloc>().add(SilentAttachmentRefresh(id: widget.id));
                } else if (state is CandidateAttachmentDeleteSuccess) {
                  flutterToastCustom(
                    msg: AppLocalizations.of(context)!.deletedsuccessfully,
                    color: AppColors.red,
                  );
                } else if (state is CandidateAttachmentUploadSuccess) {
                  Navigator.of(context).pop(true);
                  flutterToastCustom(
                    msg: AppLocalizations.of(context)!.upload,
                    color: AppColors.primary,
                  );
                } else if (state is CandidateAttachmentError) {
                  flutterToastCustom(
                    msg: state.errorMessage,
                    color: AppColors.red,
                  );
                }
              },
              builder: (context, state) {
                print("Current state: $state");
                Widget buildAttachmentList(
                    List<CandidateAttachment> attachments,
                    bool hasReachedMax,
                    Map<String, double> downloadProgress,
                    ) {
                  return NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (scrollInfo is ScrollStartNotification) {
                        FocusScope.of(context).unfocus();
                      }
                      if (!hasReachedMax &&
                          scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                          !isLoadingMore) {
                        setState(() {
                          isLoadingMore = true;
                        });
                        context.read<CandidateAttachmentBloc>().add(
                          AttachmentLoadMore(mediaSearchController.text, widget.id!),
                        );
                      }
                      return false;
                    },
                    child: context.read<PermissionsBloc>().isManageCandidate == true
                        ? attachments.isNotEmpty
                        ? ListView.builder(
                      padding: EdgeInsets.only(left: 18.w, right: 18.w, bottom: 70.h),
                      shrinkWrap: true,
                      itemCount: hasReachedMax ? attachments.length : attachments.length + 1,
                      itemBuilder: (context, index) {
                        if (index < attachments.length) {
                          final media = attachments[index];
                          final progress = downloadProgress[media.name] ?? 0.0;
                          return mediaCard(
                            attachments,
                            index,
                            media,
                            null,
                            null,
                            progress,
                          );
                        } else {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Center(
                              child: isLoadingMore
                                  ? SpinKitFadingCircle(
                                color: AppColors.primary,
                                size: 40.sp,
                              )
                                  : const SizedBox(),
                            ),
                          );
                        }
                      },
                    )
                        : const NoData(isImage: true)
                        : const NoPermission(),
                  );
                }

                if (state is CandidateAttachmentLoading) {
                  return const NotesShimmer();
                } else if (state is CandidateAttachmentPaginated) {
                  return buildAttachmentList(
                    state.CandidateAttachments,
                    state.hasReachedMax,
                    state.downloadProgress,
                  );
                } else if (state is DownloadInProgressCandidate) {
                  return buildAttachmentList(
                    state.CandidateAttachments,
                    state.hasReachedMax,
                    state.downloadProgress,
                  );
                } else if (state is DownloadSuccessCandidate) {
                  return buildAttachmentList(
                    state.CandidateAttachments,
                    state.hasReachedMax,
                    {},
                  );
                } else if (state is DownloadFailureCandidate) {
                  return buildAttachmentList(
                    state.CandidateAttachments,
                    state.hasReachedMax,
                    {},
                  );
                } else if (state is CandidateAttachmentUploadSuccess ||
                    state is CandidateAttachmentDeleteSuccess ||
                    state is CandidateAttachmentError) {
                  context.read<CandidateAttachmentBloc>().add(AttachmentList(id: widget.id));
                  return const NotesShimmer();
                }
                return const NotesShimmer();
              },
            ),
          ),
        ],
      )
          : const NoPermission(),
    )));
  }

  Widget mediaCard(
      List<CandidateAttachment> attachment,
      int index,
      CandidateAttachment media,
      String? startDate,
      String? endDate,
      double progress,
      ) {
    return DismissibleCard(
      key: ValueKey(media.id),
      direction: context.read<PermissionsBloc>().isDeleteCandidate == true
          ? DismissDirection.endToStart
          : DismissDirection.none,
      title: index.toString(),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.endToStart &&
            context.read<PermissionsBloc>().isDeleteCandidate == true) {
          final result = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,
                title: Text(AppLocalizations.of(context)!.confirmDelete),
                content: Text(AppLocalizations.of(context)!.areyousure),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(AppLocalizations.of(context)!.ok),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                ],
              );
            },
          );

          if (result == true) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                attachment.removeAt(index);
              });
              context.read<CandidateAttachmentBloc>().add(DeleteCandidateAttachment(id: media.id));
            });
            return false;
          }
        }
        return false;
      },
      onDismissed: (DismissDirection direction) {},
      dismissWidget: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: customContainer(
          context: context,
          addWidget: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
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
                      onTap: progress > 0 && progress < 1
                          ? null
                          : () {
                        context.read<CandidateAttachmentBloc>().add(
                          StartDownloadAttachment(
                            fileUrl: media.downloadUrl ?? "",
                            fileName: media.name ?? "",
                            media: attachment,
                            id: widget.id!,
                          ),
                        );
                      },
                      child: GlowContainer(
                        shape: BoxShape.circle,
                        glowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                        child: CircleAvatar(
                          radius: 15.sp,
                          backgroundColor: Theme.of(context).colorScheme.backGroundColor,
                          child: progress > 0 && progress < 1
                              ? SizedBox(
                            width: 15.sp,
                            height: 15.sp,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 2.w,
                              color: AppColors.primary,
                            ),
                          )
                              : HeroIcon(
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
                        child: media.viewUrl != null &&
                            (media.mimeType!.contains('image') || media.mimeType!.contains('pdf'))
                            ? Image.network(
                          media.viewUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => _getFileIcon(media.mimeType ?? ""),
                        )
                            : _getFileIcon(media.mimeType ?? ""),
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: CustomText(
                                  text: media.name ?? "",
                                  size: 15.sp,
                                  color: Theme.of(context).colorScheme.textClrChange,
                                  fontWeight: FontWeight.w700,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: CustomText(
                                  text: media.size.toString(),
                                  size: 12.sp,
                                  color: Theme.of(context).colorScheme.textClrChange,
                                  fontWeight: FontWeight.w700,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: CustomText(
                                  text: media.mimeType.toString(),
                                  size: 12.sp,
                                  color: Theme.of(context).colorScheme.textClrChange,
                                  fontWeight: FontWeight.w700,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}