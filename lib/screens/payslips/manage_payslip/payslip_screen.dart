import 'dart:math';
import '../../../routes/routes.dart';
import '../../../src/generated/i18n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:slidable_bar/slidable_bar.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:heroicons/heroicons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import '../../../bloc/payslip/payslip/payslip/payslip_bloc.dart';
import '../../../bloc/payslip/payslip/payslip/payslip_event.dart';
import '../../../bloc/payslip/payslip/payslip/payslip_state.dart';
import '../../../bloc/permissions/permissions_bloc.dart';

import '../../../bloc/setting/settings_bloc.dart';


import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';

import '../../../config/colors.dart';
import '../../../config/constants.dart';
import '../../../data/localStorage/hive.dart';
import '../../../data/model/payslip/payslip_model.dart';
import '../../../utils/widgets/back_arrow.dart';
import '../../../utils/widgets/custom_dimissible.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/no_data.dart';
import '../../../utils/widgets/no_permission_screen.dart';
import '../../../utils/widgets/notes_shimmer_widget.dart';
import '../../../utils/widgets/search_pop_up.dart';
import '../../../utils/widgets/shake_widget.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../widgets/search_field.dart';


class PayslipScreen extends StatefulWidget {
  const PayslipScreen({super.key});

  @override
  State<PayslipScreen> createState() => _PayslipScreenState();
}

class _PayslipScreenState extends State<PayslipScreen> with TickerProviderStateMixin{
  final GlobalKey globalKeyOne = GlobalKey();
  final GlobalKey globalKeyTwo = GlobalKey();
  final GlobalKey globalKeyThree = GlobalKey();

  TextEditingController startsController = TextEditingController();
  TextEditingController endController = TextEditingController();

  TextEditingController searchController = TextEditingController();


  final ValueNotifier<String> filterNameNotifier =
  ValueNotifier<String>('Clients');
  String filterName = 'Clients';
  bool? isLoading = true;
  bool? isFirst = false;
  String searchword = "";
  String? searchValue = "";
  List<int> userSelectedId = [];
  List<int> userSelectedIdS = [];
  List<String> userSelectedname = [];

  List<int> clientSelectedIdS = [];
  List<String> clientSelectedname = [];

  List<int> prioritySelectedIdS = [];
  List<String> prioritySelectedname = [];

  List<int> projectSelectedIdS = [];
  List<String> projectSelectedname = [];

  List<int> statusSelectedIdS = [];
  List<String> statusSelectedname = [];


  String? fromDate;
  String? toDate;
  String? currency;
  String? currencyPosition;

  bool isListening =
  false; // Flag to track if speech recognition is in progress
  bool dialogShown = false;
  bool? clientSelected = false;
  bool? clientDisSelected = false;
  bool? priorityDisSelected = false;
  bool? userDisSelected = false;
  bool? projectDisSelected = false;
  bool? statusDisSelected = false;
  bool? dateDisSelected = false;
  bool? userSelected = false;
  bool? statusSelected = false;
  bool? prioritySelected = false;
  bool? projectSelected = false;
  bool? dateSelected = false;

  int filterSelectedId = 0;
  int filterCount = 0;
  String filterSelectedNmae = "";

  DateTime selectedDateStarts = DateTime.now();
  DateTime? selectedDateEnds = DateTime.now();

  bool shouldDisableEdit = true;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  static final bool _onDevice = false;
  final SlidableBarController sideBarController =
  SlidableBarController(initialStatus: false);

  double level = 0.0;
  final List<String> filter = [
    'Clients',
    'Users',
    'Status',
    'Priorities',
    'Projects',
    'Date'
  ];
  String monthDate="";
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

  final SpeechToText _speechToText = SpeechToText();
  String _lastWords = "";
  @override
  void initState() {
    currency = context.read<SettingsBloc>().currencySymbol;
    currencyPosition = context.read<SettingsBloc>().currencyPosition;
    BlocProvider.of<PayslipBloc>(context).add(AllPayslipList());
    super.initState();
    getIsFirst();
  }

  String formatMonthYear(String inputDate) {
    // Parse the string to a DateTime (adding "-01" to make it a valid date)
    DateTime parsedDate = DateFormat("yyyy-MM").parse(inputDate);

    // Format to "MMM, yyyy" (e.g., May, 2025)
    monthDate = DateFormat("MMMM, yyyy").format(parsedDate);
    return monthDate;
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
      (() {});
    }
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

    // Trigger search event with the updated result
    context.read<PayslipBloc>().add(SearchPayslips(_lastWords));
  }



  getIsFirst() async {
    isFirst = await HiveStorage.isFirstTime();
  }


  void onDeletePayslip(Payslip) {
    context.read<PayslipBloc>().add(DeletePayslip(Payslip));
    final setting = context.read<PayslipBloc>();
    setting.stream.listen((state) {
      if (state is PayslipDeleteSuccess) {
        if (mounted) {
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is PayslipDeleteError) {
        flutterToastCustom(msg: state.errorMessage);
      }
    });
    BlocProvider.of<PayslipBloc>(context).add(AllPayslipList());

  }

  Future<void> _onRefresh() async {

    BlocProvider.of<PayslipBloc>(context).add(AllPayslipList());

  }

  @override
  Widget build(BuildContext context) {
    context.read<PermissionsBloc>().isManagePayslip;
    context.read<PermissionsBloc>().iscreatePayslip;
    context.read<PermissionsBloc>().iseditPayslip;
    context.read<PermissionsBloc>().isdeletePayslip;

    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;

    return Scaffold(

      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      body: Column(
        children: [
          _PayslipAppbar(),
          SizedBox(height: 20.h),
          CustomSearchField(
            isLightTheme: isLightTheme,
            controller: searchController,
            suffixIcon: SizedBox(
              child: Row(
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
                          color: Theme.of(context).colorScheme.textFieldColor,
                        ),
                        onPressed: () {
                          // Clear the search field
                          searchController.clear();
                          // Optionally trigger the search event with an empty string
                          context.read<PayslipBloc>().add(SearchPayslips(""));
                        },
                      ),
                    ),
                  SizedBox(
                    width: 30.w,
                    child: IconButton(
                      icon: Icon(
                        _speechToText.isNotListening
                            ? Icons.mic_off
                            : Icons.mic,
                        size: 20.sp,
                        color: Theme.of(context).colorScheme.textFieldColor,
                      ),
                      onPressed: () {
                        if (_speechToText.isNotListening) {
                          _startListening();
                        } else {
                          _stopListening();
                        }
                      },
                    ),
                  ),
                  // BlocBuilder<PayslipFilterCountBloc, PayslipFilterCountState>(
                  //   builder: (context, state) {
                  //
                  //     return SizedBox(
                  //       width: 35.w,
                  //       child: Stack(
                  //         children: [
                  //           IconButton(
                  //             icon: HeroIcon(
                  //               HeroIcons.adjustmentsHorizontal,
                  //               style: HeroIconStyle.solid,
                  //               color: Theme.of(context).colorScheme.textFieldColor,
                  //               size: 30.sp,
                  //             ),
                  //             onPressed: () {
                  //
                  //               BlocProvider.of<ClientBloc>(context)
                  //                   .add(ClientList());
                  //               BlocProvider.of<StatusMultiBloc>(context)
                  //                   .add(StatusMultiList());
                  //               BlocProvider.of<PriorityMultiBloc>(context)
                  //                   .add(PriorityMultiList());
                  //               BlocProvider.of<ProjectMultiBloc>(context)
                  //                   .add(ProjectMultiList());
                  //               BlocProvider.of<UserBloc>(context).add(UserList());
                  //               _filterDialog(context, isLightTheme);
                  //             },
                  //           ),
                  //           if (state.count > 0)
                  //             Positioned(
                  //               right: 5.w,
                  //               top: 7.h,
                  //               child: Container(
                  //                 padding: EdgeInsets.zero,
                  //                 alignment: Alignment.center,
                  //                 height: 12.h,
                  //                 width: 10.w,
                  //                 decoration: BoxDecoration(
                  //                   color: AppColors.primary,
                  //                   shape: BoxShape.circle,
                  //                 ),
                  //                 child: CustomText(
                  //                   text: state.count.toString(),
                  //                   color: Colors.white,
                  //                   size: 6,
                  //                   textAlign: TextAlign.center,
                  //                   fontWeight: FontWeight.bold,
                  //                 ),
                  //               ),
                  //             ),
                  //         ],
                  //       ),
                  //     );
                  //   },
                  // )

                ],
              ),
            ),
            onChanged: (value) {
              searchword = value;
              context.read<PayslipBloc>().add(SearchPayslips(value));
            },
          ),
          SizedBox(height: 20.h),
          _PayslipBlocList(isLightTheme),
          SizedBox(
            height: 60.h,
          ),
        ],
      ),
    );
  }


  Widget _PayslipAppbar() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: BackArrow(
          isAdd: true,
          iscreatePermission: context.read<PermissionsBloc>().iscreatePayslip,
          iSBackArrow: true,
          fromDash: true,
          isFav: true,
          onPress:(){
            router.push(
              '/createupdatepayslipModel',
              extra: {'isCreate': true, "payslipModel": PayslipModel.empty()},
            );
          },
          title: AppLocalizations.of(context)!.payslip,
        ));
  }

  Widget _PayslipBlocList(isLightTheme) {
    return Expanded(
      child: RefreshIndicator(
        color: AppColors.primary, // Spinner color
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        onRefresh: _onRefresh,
        child: (context.read<PermissionsBloc>().isManagePayslip == true)
            ?  FutureBuilder(
            future: Future.delayed(Duration(seconds: 1)), // Delay by 2 seconds
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const NotesShimmer(); // Show loading indicator while waiting
              }
              return BlocConsumer<PayslipBloc, PayslipState>(
                listener: (context, state) {

                  if (state is PayslipPaginated) {
                  }
                },
                builder: (context, state) {
                  print("zgknfdvm , $state");

                  if (state is PayslipLoading) {
                    return const NotesShimmer();
                  } else if (state is PayslipPaginated) {

                    return NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        if (scrollInfo is ScrollStartNotification) {
                          FocusScope.of(context).unfocus(); // Dismiss keyboard
                        }
                        if (!state.hasReachedMax &&
                            scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                          context.read<PayslipBloc>().add(LoadMore(
                              searchQuery: searchValue!,
                              projectId: projectSelectedIdS,
                              clientId: clientSelectedIdS,
                              userId: userSelectedIdS,
                              statusId: statusSelectedIdS,
                              priorityId: prioritySelectedIdS,
                              fromDate: fromDate,
                              toDate: toDate));
                        }
                        return false;
                      },
                      child: state.Payslip.isNotEmpty
                          ? ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          itemCount: state.hasReachedMax
                              ? state.Payslip.length
                              : state.Payslip.length + 1,
                          itemBuilder: (context, index) {
                            if (index < state.Payslip.length) {
                              PayslipModel Payslip = state.Payslip[index];
                              String? date;
                              if (Payslip.createdAtDate != null) {
                                var dateCreated =
                                parseDateStringFromApi(Payslip.createdAtDate!);
                                date = dateFormatConfirmed(
                                    dateCreated, context);
                              }
                              return index == 0
                                  ? ShakeWidget(
                                  child: _listOfProject(
                                      Payslip,
                                      isLightTheme,
                                      date,
                                      state.Payslip,
                                      index,state.Payslip[index]))
                                  : _listOfProject(Payslip, isLightTheme, date,
                                  state.Payslip, index,state.Payslip[index]);
                            } else {
                              // Show a loading indicator when more notes are being loaded
                              return Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 0),
                                child: Center(
                                  child: state.hasReachedMax
                                      ? const Text('')
                                      : const SpinKitFadingCircle(
                                    color: AppColors.primary,
                                    size: 40.0,
                                  ),
                                ),
                              );
                            }
                          })
                      // ? PayslipList(isLightTheme,state.hasReachedMax,state.Payslip)
                          : NoData(
                        isImage: true,
                      ),
                    );
                  }

                  return const Text("");
                },
              );})
            : NoPermission(),
      ),
    );
  }


  Widget _listOfProject(Payslip, isLightTheme, date, statePayslip, index,PayslipModel) {
    String basicSalary = currencyPosition == "before"
        ? "$currency ${Payslip.basicSalary}"
        : "${Payslip.basicSalary} $currency";
    String netPay = currencyPosition == "before"
        ? "$currency ${Payslip.netPay}"
        : "${Payslip.netPay} $currency";
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: DismissibleCard(
          direction: context.read<PermissionsBloc>().isdeletePayslip == true &&
              context.read<PermissionsBloc>().iseditPayslip == true
              ? DismissDirection.horizontal // Allow both directions
              : context.read<PermissionsBloc>().isdeletePayslip == true
              ? DismissDirection.endToStart // Allow delete
              : context.read<PermissionsBloc>().iseditPayslip == true
              ? DismissDirection.startToEnd // Allow edit
              : DismissDirection.none,
          title: Payslip.id.toString(),
          confirmDismiss: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart  ) {
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
                      statePayslip.removeAt(index);

                    });
                    onDeletePayslip(Payslip.id);
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
            else if (direction == DismissDirection.startToEnd) {
              router.push(
                '/createupdatepayslipModel',
                extra: {'isCreate': false, "payslipModel": Payslip},
              );
              BlocProvider.of<PayslipBloc>(context).add(AllPayslipListOnPayslip());
              return false; // Prevent dismiss
            }
            // flutterToastCustom(msg: AppLocalizations.of(context)!.isDemooperation);

            return false; // Default case
          },
          dismissWidget: InkWell(
            highlightColor: Colors.transparent, // No highlight on tap
            splashColor: Colors.transparent,
            onTap: () {

              router.push(
                '/Payslipdetail',
                extra: {
                  "id": Payslip.id,
                  // your list of LeaveRequests
                },
              );
            },
            child: Container(
                decoration: BoxDecoration(
                    boxShadow: [
                      isLightTheme
                          ? MyThemes.lightThemeShadow
                          : MyThemes.darkThemeShadow,
                    ],
                    color: Theme.of(context).colorScheme.containerDark,
                    borderRadius: BorderRadius.circular(12)),
                // height: 140.h,
                child:  Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 20.h, left: 20.h, right: 20.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(  // Replace Container(width: double.infinity)
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                  children: [
                                    InkWell(
                                      onTap: (){
                                        router.push(
                                          '/payslipdetails',
                                          extra: {"payslipModel": Payslip},
                                        );

                                      },
                                      child: CustomText(
                                        text: "PSL-${Payslip.id.toString()}",
                                        size: 14.sp,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                  ],
                                ),
                                SizedBox(height: 10.h,),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: double.infinity),
                                  child: IntrinsicWidth(
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 20.h,
                                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.blue.shade800,
                                      ),
                                      child: CustomText(
                                        text: Payslip.status == 0 ?"Unpaid":"Paid",

                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        color: AppColors.whiteColor,
                                        size: 13.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                 SizedBox(height: 8.h),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h,),
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 18.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20.sp,
                            backgroundImage: NetworkImage(Payslip.user.profileImage??""),
                          ),
                          SizedBox(
                            width: 10.h,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                // width: 59.w,
                                // color: Colors.red,
                                child: CustomText(
                                  text: Payslip.user.name??"",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  size: 16.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                // width: 59.w,
                                // color: Colors.red,
                                child: CustomText(
                                  text:Payslip.user.email??"",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  size: 12.sp,
                                  color: AppColors.greyColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),


                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h,),
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 18.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            // width: 59.w,
                            // color: Colors.red,
                            child: CustomText(
                              text:AppLocalizations.of(context)!.basicsalary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              size: 12.sp,
                              color: Theme.of(context)
                                  .colorScheme
                                  .textClrChange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            // width: 59.w,
                            // color: Colors.red,
                            child: CustomText(
                              text: basicSalary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              size: 14.sp,
                              color: AppColors.greyColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),


                        ],
                      ),
                    ),
                    SizedBox(height: 10.h,),
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 18.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            // width: 59.w,
                            // color: Colors.red,
                            child: CustomText(
                              text:AppLocalizations.of(context)!.netpay,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              size: 12.sp,
                              color: Theme.of(context)
                                  .colorScheme
                                  .textClrChange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            // width: 59.w,
                            // color: Colors.red,
                            child: CustomText(
                              text: netPay,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              size: 14.sp,
                              color: AppColors.greyColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),


                        ],
                      ),
                    ),
                    Divider(color: Theme.of(context).colorScheme.dividerClrChange),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h, left: 20.h, right: 20.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const HeroIcon(
                                HeroIcons.calendar,
                                style: HeroIconStyle.solid,
                                color: AppColors.blueColor,
                              ),
                              SizedBox(width: 20.w),
                              CustomText(
                                text: formatMonthYear(Payslip.month) ,
                                color: AppColors.greyColor,
                                size: 15.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
            ),
          ),
          onDismissed: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart &&
                context.read<PermissionsBloc>().isdeletePayslip == true) {
              // Perform delete action
              WidgetsBinding.instance.addPostFrameCallback((_) { setState(() {
                statePayslip.removeAt(index);

              });
              onDeletePayslip(Payslip.id);

              });

            } else if (direction == DismissDirection.startToEnd &&
                context.read<PermissionsBloc>().iseditPayslip == true) {
              print("rjlg 'xgjv' ");
              // Perform edit action
            }
          },
        ));
  }
}
