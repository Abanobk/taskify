

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hive/hive.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taskify/bloc/candidate_attachment/candidate_attachment_bloc.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/utils/widgets/custom_text.dart';

import '../../../../bloc/permissions/permissions_bloc.dart';
import '../../../../bloc/permissions/permissions_event.dart';

import '../../../../bloc/theme/theme_bloc.dart';
import '../../../../bloc/theme/theme_state.dart';

import '../../../../config/app_images.dart';
import '../../../../config/internet_connectivity.dart';
import '../../../../config/strings.dart';
import '../../../../data/model/interview/interview_model.dart';

import '../../../../routes/routes.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../../utils/widgets/back_arrow.dart';
import '../../../../utils/widgets/toast_widget.dart';

import '../../../widgets/speech_to_text.dart';
import 'attachments_candidate.dart';
import 'interviews_candidate.dart';

class CandidateMoreTabs extends StatefulWidget {
  final bool? fromDetail;
  final int? id;
  final String? name;
  const CandidateMoreTabs({super.key, this.fromDetail, this.id,this.name});

  @override
  State<CandidateMoreTabs> createState() => _CandidateMoreTabsState();
}

class _CandidateMoreTabsState extends State<CandidateMoreTabs>
    with TickerProviderStateMixin {
  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  bool? isLoading = true;
  bool isLoadingMore = false;
  int _selectedIndex = 0;
  String? selectedColorName;
  final Connectivity _connectivity = Connectivity();
  TextEditingController searchController = TextEditingController();
  TextEditingController mediaSearchController = TextEditingController();
  TextEditingController activityLogSearchController = TextEditingController();
  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();
  String fromDate = "";
  String toDate = "";
  TextEditingController startDateBetweenController = TextEditingController();
  TextEditingController endDateBetweenController = TextEditingController();
  TextEditingController startDateBetweenstartController =
      TextEditingController();
  TextEditingController endDateBetweenendController = TextEditingController();
  String fromDateBetween = "";
  String toDateBetween = "";
  String fromEndDateBetweenStart = "";
  String toDateEndBetweenEnd = "";
  late SpeechToTextHelper speechHelper;
  String selectedTabText = "";
  int isWhichIndex = 0;
  DateTime selectedDateStarts = DateTime.now();
  DateTime? selectedDateEnds = DateTime.now();
  DateTime selectedDateBetweenStarts = DateTime.now();
  DateTime? selectedDateBetweenEnds = DateTime.now();
  DateTime selectedDateEndBetweenStarts = DateTime.now();
  DateTime? selectedDateEndBetweenEnds = DateTime.now();
  bool? isFirstTimeUSer;
  bool? isFirst;
  String mileStoneSearchQuery = '';
  String mediaSearchQuery = '';
  String activityLogSearchQuery = '';

  TextEditingController titleController = TextEditingController();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late TabController _tabController;

  String? statusname;
  bool isDownloading = false;
  double progress = 0.0;

  List<String> status = ["Complete", "Incomplete"];
  final ValueNotifier<String> filterNameNotifier =
      ValueNotifier<String>('Date between');

  String filterName = 'Date between';

  void _navigateToIndex(int index) {
    setState(() {
      _selectedIndex = index;
      if (index < _tabController.length) {
        _tabController.animateTo(index);
      }
    });
  }

  _getFirstTimeUser() async {
    var box = await Hive.openBox(authBox);
    isFirstTimeUSer = box.get(firstTimeUserKey) ?? true;
  }

  Future<void> downloadFile(file, fileName) async {
    print("sjfgdjk $fileName");
    // Check storage permissions (only needed for Android)
    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        print("Storage permission denied");
        return;
      }
    }

    try {
      setState(() {
        isDownloading = true;
        progress = 0.0;
      });

      Dio dio = Dio();
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = "${directory.path}/$fileName";
      print("sofudlgj asas $filePath");
      await dio.download(
        file,
        filePath,
        onReceiveProgress: (received, total) {
          setState(() {
            progress = (received / total);
            print("sofudlgj $progress");
          });
        },
      );

      setState(() {
        isDownloading = false;
      });

      flutterToastCustom(
          msg: "Download completed: $fileName", color: AppColors.primary);
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e")),
      );
    }
  }

  _setIsFirst(value) async {
    isFirst = value;
    var box = await Hive.openBox(authBox);
    box.put("isFirstCase", value);
  }

  void onShowCaseCompleted() {
    _setIsFirst(false);
  }

  @override
  void initState() {
    super.initState();

    // Use local variable, no need to store as field
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {}
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {}
    });
    int tabLength = 0;
    if (context.read<PermissionsBloc>().isManageMedia == true) tabLength++;
    if (context.read<PermissionsBloc>().isManageTask == true) tabLength++;
    _tabController =
        TabController(length: tabLength > 0 ? tabLength : 1, vsync: this);

    _getFirstTimeUser();
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    // if your SpeechToTextHelper needs disposal
    _tabController.dispose();
    searchController.dispose();
    mediaSearchController.dispose();
    activityLogSearchController.dispose();
    super.dispose();
  }

  ValueNotifier<List<File>> selectedFilesNotifier = ValueNotifier([]);

  @override
  Widget build(BuildContext context) {
    Future<void> _pickFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'jpg',
          'jpeg',
          'png',
        ],
      );

      if (result != null) {
        List<File> pickedFiles =
            result.paths.whereType<String>().map((path) => File(path)).toList();

        // Update the ValueNotifier
        selectedFilesNotifier.value = [
          ...selectedFilesNotifier.value,
          ...pickedFiles
        ];

        print("Selected Files: ${selectedFilesNotifier.value}");
      }
    }

    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              _appBar(isLightTheme),
              SizedBox(height: 20.h),

              Expanded(
                  child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  context.read<PermissionsBloc>().isManageMedia == true
                      ? CandidateAttachmentScreen(id: widget.id)
                      : SizedBox.shrink(),
                  context.read<PermissionsBloc>().isManageInterview == true
                      ? CandidateInterviewsScreen(id: widget.id!,name:widget.name)
                      : SizedBox.shrink(),
                ],
              )),
              // Add bottom space to ensure content is visible behind the floating bar
              // SizedBox(height: 60.h),
            ],
          ),

          // Floating action button
          Visibility(
            visible: _selectedIndex != 2 &&
                _selectedIndex != 3, // Hide for index 2 and 3
            child: Positioned(
              right: 20.w,
              bottom: 100.h,
              child: FloatingActionButton(
                isExtended: true,
                onPressed: () {
                  print("fuhdcnu $_selectedIndex");
                   if (_selectedIndex == 1 && context.read<PermissionsBloc>().isCreateInterview == true) {
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
                      extra: {'isCreate': true, 'interviewModel': interviewModel,'candidateId':widget.id,
                        'candidateName':widget.name},
                    );
                    // router.push(
                    //   '/createeditinterview',
                    //   extra: {
                    //     'isCreate': true,
                    //     'interviewModel': interviewModel,
                    //     'candidateId':widget.id,
                    //     'candidateName':widget.name
                    //   },
                    // );
                  }
                   else if (_selectedIndex == 0 &&
                      context.read<PermissionsBloc>().iscreateMedia == true) {
                    _uploadFile(
                      pickFile: _pickFile,
                      selectedFileName: selectedFilesNotifier,
                    );
                  } else {
                    // Handle no permission or invalid index
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Action not permitted")),
                    );
                  }
                },
                backgroundColor: AppColors.primary,
                child: const Icon(
                  Icons.add,
                  color: AppColors.whiteColor,
                ),
              ),
              // return empty widget if condition not met
            ),
          ),

          // Floating bottom navigation
          Positioned(
            bottom: 20.h,
            left: 18.w,
            right: 18.w,
            child: _floatingBottomNavBar(context, isLightTheme),
          ),
        ],
      ),
    );
  }

  Widget _tabItem(HeroIcons icon, String text, Color color, int index,
      {bool isTab = true}) {
    bool isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        if (isTab) {
          _navigateToIndex(index);
          isWhichIndex = index;
        } else {
          // Handle non-tab navigation (e.g., push a new route)
          router.push('/interviews', extra: {'id': widget.id});
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeroIcon(
            icon,
            style: HeroIconStyle.outline,
            size: 18.sp,
            color: color,
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: isSelected
                ? Padding(
                    padding: EdgeInsets.only(top: 3.h),
                    child: Text(
                      text,
                      key: ValueKey(text),
                      style: TextStyle(
                          fontSize: 9.sp, fontWeight: FontWeight.bold),
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _appBar(isLightTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: BackArrow(
        onTap: () {
          router.pop();
        },
        projectId: widget.id,
        discussionScreen: "candidateDiscussion",
        iSBackArrow: true,

        iscreatePermission: context.read<PermissionsBloc>().isCreateCandidate,
        title: (() {
          switch (_selectedIndex) {
            case 0:
              return AppLocalizations.of(context)!.attachment;
            case 1:
              return AppLocalizations.of(context)!.interviews;
            default:
              return AppLocalizations.of(context)!.attachment;
          }
        })(),
        onPress: () {

          // _createEditStatus(isLightTheme: isLightTheme, isCreate: true);
        },
      ),
    );
  }

  Widget _floatingBottomNavBar(BuildContext context, bool isLightTheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: isLightTheme
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isLightTheme
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isLightTheme
                    ? Colors.black.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (context.read<PermissionsBloc>().isManageMedia == true)
                _tabItem(
                    HeroIcons.document, "Attachments", AppColors.photoColor, 0),
              if (context.read<PermissionsBloc>().isManageTask == true)
                _tabItem(
                    HeroIcons.globeAlt, "Interviews", AppColors.primary, 1),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadFile({pickFile, selectedFileName}) {
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
              height: 420.h,
              child: Padding(
                padding:  EdgeInsets.all(16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Container(
                                height: 40.h,
                                width: 40.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.greyColor
                                      .withValues(alpha: 0.3),
                                ),
                                child: HeroIcon(
                                  HeroIcons.cloudArrowUp,
                                  style: HeroIconStyle.outline,
                                  size: 25.sp,
                                  color: AppColors.greyColor,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10.w),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Upload files",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      Text("Select and upload the files ",
                                          style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 35.w,
                          // color: Colors.red,
                          child: Center(
                            child: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                     SizedBox(height: 16.h),
                    Container(
                      decoration: const BoxDecoration(
                          border: DashedBorder.fromBorderSide(
                              dashLength: 15,
                              side: BorderSide(
                                  color: AppColors.greyColor, width: 1)),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          Container(
                              height: 70.h,
                              width: 70.w,
                              decoration: BoxDecoration(
                                // color: Colors.red,
                                image: DecorationImage(
                                    image: AssetImage(AppImages.cloudGif),
                                    fit: BoxFit.cover),
                              )),
                          const SizedBox(height: 8),
                          FittedBox(
                            child: CustomText(
                                text: AppLocalizations.of(context)!
                                    .chooseafileorclickbelow,
                                size: 20.sp,
                                textAlign:
                                    TextAlign.center, // Center align if needed
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .textClrChange),
                          ),
                          CustomText(
                            text: AppLocalizations.of(context)!.formatfile,
                            color: AppColors.greyColor,
                            size: 15.sp,
                            textAlign: TextAlign
                                .center, // Make sure it wraps instead of cutting off
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: pickFile,
                            child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(6)),
                                height: 30.h,
                                width: 100.w,
                                margin: EdgeInsets.symmetric(vertical: 10.h),
                                child: CustomText(
                                  text:
                                      AppLocalizations.of(context)!.browsefile,
                                  size: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.pureWhiteColor,
                                )),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    InkWell(
                      onTap: () {
                        context.read<CandidateAttachmentBloc>().add(UploadAttachment(
                            id: widget.id!,
                            media: selectedFilesNotifier.value));
                        selectedFilesNotifier.value = [];
                        router.pop();
                        BlocProvider.of<CandidateAttachmentBloc>(context)
                            .add(AttachmentList(id: widget.id));

                      },
                      child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6)),
                          height: 30.h,
                          width: 100.w,
                          margin: EdgeInsets.symmetric(vertical: 10.h),
                          child: CustomText(
                            text: AppLocalizations.of(context)!.upload,
                            size: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.pureWhiteColor,
                          )),
                    ),
                    // if (selectedFilesNotifier.value.isNotEmpty)
                    //   Padding(
                    //     padding: const EdgeInsets.only(top: 12),
                    //     child: Text("Selected File: ${selectedFilesNotifier.value}"),
                    //   ),
                  ],
                ),
              ),
            ),
          );
        });
  }


}
