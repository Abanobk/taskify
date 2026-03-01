import 'package:flutter/material.dart';
import 'package:taskify/bloc/auth/auth_bloc.dart';
import 'package:taskify/screens/leave_request/widgets/single_userfield.dart';
import 'package:taskify/screens/leave_request/widgets/status_leave_req.dart';

import '../../bloc/leave_request/leave_request_bloc.dart';
import '../../bloc/leave_request/leave_request_event.dart';
import '../../bloc/leave_request/leave_request_state.dart';
import '../../config/constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import 'package:taskify/config/colors.dart';

import 'package:taskify/utils/widgets/back_arrow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';

import '../../bloc/theme/theme_state.dart';

import '../../data/GlobalVariable/globalvariable.dart';
import '../../data/model/leave_request/create_update_model.dart';
import '../../data/model/leave_request/leave_req_model.dart';
import '../../utils/widgets/custom_text.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/custom_switch.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/no_internet_screen.dart';
import '../../utils/widgets/toast_widget.dart';
import 'package:intl/intl.dart';
import 'package:heroicons/heroicons.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../task/Widget/users_field.dart';
import '../widgets/custom_date.dart';
import '../widgets/custom_cancel_create_button.dart';
import '../widgets/custom_textfields/custom_textfield.dart';
import '../../src/generated/i18n/app_localizations.dart';


class CreateLeaveRequestScreen extends StatefulWidget {
  final bool? isCreate;
  final List<LeaveRequests> leaveReq;
  final int? index;
  const CreateLeaveRequestScreen(
      {super.key, this.isCreate, required this.leaveReq, this.index});

  @override
  State<CreateLeaveRequestScreen> createState() =>
      _CreateLeaveRequestScreenState();
}

class _CreateLeaveRequestScreenState extends State<CreateLeaveRequestScreen> {
  String days = "0";
  String timeInDiff = "00:00";

  String selectedCategory = '';
  int _currentIndex = 0;
  String status = "pending";
  DateTime? startDate;
  DateTime? endDate;
  TextEditingController phoneController = TextEditingController();
  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController addrerssController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController zipcodeController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  TextEditingController daysController = TextEditingController();

  TimeOfDay _timestart = const TimeOfDay(hour: 9, minute: 00);
  TimeOfDay _timeend = const TimeOfDay(hour: 5, minute: 00);

  String? strtTime;
  String? endTime;
  bool? hasEditor;
  String? role;
  List<String>? usersName;
  List<int>? selectedusersNameId;
  String? singleUsersName;
  int? selectedSingleusersNameId;

  String? toPassStartDate = "";
  String? toPassEndDate;

  String? userName;

  bool statusOfPartial = true;
  String statusOfPartialIs = "off";
  bool visiblestatus = true;
  bool partialaVisible = true;
  String visiblePartialIs = "off";
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  String? formattedTimeStart;
  String? formattedTimeEnd;

  DateTime selectedDateStarts = DateTime.now();
  DateTime? selectedDateEnds = DateTime.now();

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
    super.initState();
    hasEditor = context
        .read<AuthBloc>()
        .isLeaveEditor;
    role = GlobalUserData.roleIS;

    if (widget.isCreate == false) {
      singleUsersName = widget.leaveReq[widget.index!].userName;

      if (widget.leaveReq[widget.index!].partialLeave == "on") {
        statusOfPartial = true;
      } else if (widget.leaveReq[widget.index!].partialLeave == "off") {
        statusOfPartial = false;
      }

      if (widget.leaveReq[widget.index!].leaveVisibleToAll == "off") {
        visiblestatus = false;
      } else if (widget.leaveReq[widget.index!].leaveVisibleToAll == "on") {
        visiblestatus = true;
      }

      if (widget.leaveReq[widget.index!].status == "Pending" ||
          widget.leaveReq[widget.index!].status == "pending") {
        _currentIndex = 0;
      } else if (widget.leaveReq[widget.index!].status == "Approved" ||
          widget.leaveReq[widget.index!].status == "approved") {
        _currentIndex = 1;
      } else if (widget.leaveReq[widget.index!].status == "Rejected" ||
          widget.leaveReq[widget.index!].status == "rejected") {
        _currentIndex = 2;
      }
      status=widget.leaveReq[widget.index!].status!.toLowerCase();
      // Parse fromDate and toDate if they are Strings
      DateTime fromDate =
      DateTime.parse(widget.leaveReq[widget.index!].fromDate!);
      DateTime toDate = DateTime.parse(widget.leaveReq[widget.index!].toDate!);

      // Set toPassStartDate to the formatted fromDate
      toPassStartDate = DateFormat("yyyy-MM-dd").format(fromDate);

      // Use the formatted date strings in the TextEditingController
      startController = TextEditingController(text: "${DateFormat('d, MMM yyyy').format(fromDate)}  <->  ${DateFormat('d, MMM yyyy').format(toDate)}");
      // endController = TextEditingController(text: DateFormat('d, MMM yyyy').format(toDate));

      days = widget.leaveReq[widget.index!].duration.toString();
      reasonController = TextEditingController(text: widget.leaveReq[widget.index!].reason);
    } else {
      DateTime now = DateTime.now();

      // Set toPassStartDate to today's date
      toPassStartDate = DateFormat("yyyy-MM-dd").format(now);

      // startController = TextEditingController(text: formattedDate);
      // endController = TextEditingController(text: formattedDate);
    }
  }

  void _selectstartTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _timestart,
    );

    if (newTime != null) {
      setState(() {
        _timestart = newTime;

        // Format as HH:MM:SS
        formattedTimeStart =
        '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString()
            .padLeft(2, '0')}';
      });
    }
  }

  void _selectendTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _timeend,
    );

    if (newTime != null) {
      setState(() {
        _timeend = newTime;

        // Format as HH:MM
        formattedTimeEnd =
        '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString()
            .padLeft(2, '0')}';
      });
    }
  }

  void handleUsersSelected(List<String> category, List<int> catId) {
    setState(() {
      usersName = category;
      selectedusersNameId = catId;
    });
  }

  void handleSingleUsersSelected(String category, int catId,String email,String profile) {
    setState(() {
      singleUsersName = category;
      selectedSingleusersNameId = catId;
    });
  }

  void handleStatusSelectedPartial(bool status) {
    setState(() {
      partialaVisible = status;
    });
  }

  void handleStatusSelectedPartialstatus(bool status) {
    setState(() {
      visiblestatus = status;

      if (visiblestatus == true) {
        setState(() {
          visiblePartialIs = "on";
        });
      } else if (visiblestatus == false) {
        setState(() {
          visiblePartialIs = "off";
        });
      }
    });
  }

  void handleStatusSelectedVisiblestatus(bool status) {
    setState(() {
      visiblestatus = status;

      if (visiblestatus == true) {
        setState(() {
          visiblePartialIs = "on";
        });
      } else if (visiblestatus == false) {
        setState(() {
          visiblePartialIs = "off";
        });
      }
    });
  }

  void onCreateLeaveReq(BuildContext context) {
    final successMessage = AppLocalizations.of(context)!.createdsuccessfully;

    String isVisible;
    if (visiblestatus == true) {
      isVisible = "on";
    } else {
      isVisible = "off";
    }
    String? timeFrom;
    String? timeto;

    if (reasonController.text.isNotEmpty &&
        toPassStartDate != null &&
        toPassEndDate != null &&
        selectedSingleusersNameId != null) {
      if (partialaVisible == true) {
        if (formattedTimeStart != null && formattedTimeEnd != null) {
          timeFrom = changeTimeFormat(formattedTimeStart!);
          timeto = changeTimeFormat(formattedTimeEnd!);
        } else {
          flutterToastCustom(
            msg: AppLocalizations.of(context)!.pleasefilltime,
          );
        }
      }
      context.read<LeaveRequestBloc>().add(CreateLeaveRequest(
        reason: reasonController.text,
        fromDate: toPassStartDate!,
        toDate: toPassEndDate!,
        fromTime: partialaVisible == false ? "" : timeFrom ?? "",
        toTime: partialaVisible == false ? "" : timeto ?? "",
        status: status,
        leaveVisibleToAll: isVisible,
        visibleToIds: isVisible == "off" ? selectedusersNameId! : [],
        userId: selectedSingleusersNameId ?? 0,
        partialLeave: statusOfPartialIs,
      ));

      final setting = context.read<LeaveRequestBloc>();
      setting.stream.listen((state) {
        if (state is LeaveRequestCreateSuccess) {
          flutterToastCustom(msg: successMessage, color: AppColors.primary);
          context.read<LeaveRequestBloc>().add(const LeaveRequestList(""));
          Navigator.pop(navigatorKey.currentContext!);
        }
        if (state is LeaveRequestCreateError) {
          context.read<LeaveRequestBloc>().add(const LeaveRequestList(""));
          flutterToastCustom(msg: state.errorMessage);
        }
      });
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  void onEditLeaveRequest(id) async {
    String? timeFrom;
    String? timeto;
    String? removeAmFromTime;
    String? removeAmToTime;
    if (formattedTimeStart != null) {
      timeFrom = changeTimeFormat(formattedTimeStart!);
    }
    if (widget.leaveReq[widget.index!].fromTime != null) {
      removeAmFromTime = widget.leaveReq[widget.index!].fromTime!
          .replaceAll(RegExp(r'(AM|PM)'), '')
          .trim();
    }
    if (widget.leaveReq[widget.index!].toTime != null) {
      removeAmToTime = widget.leaveReq[widget.index!].toTime!
          .replaceAll(RegExp(r'(AM|PM)'), '')
          .trim();
    }
    if (formattedTimeEnd != null) {
      timeto = changeTimeFormat(formattedTimeEnd!);
    }

    if (_currentIndex == 0) {
      status = "pending";
    } else if (_currentIndex == 1) {
      status == "approved";
    } else if (_currentIndex == 2) {
      status == "rejected";
    }
    if (status == "Pending") {
      status = "pending";
    } else if (status == "Approved") {
      status == "approved";
    } else if (status == "Rejected") {
      status == "rejected";
    }


    final updatedRequestD = CreateUpdateModel().copyWith(
      id: widget.leaveReq[widget.index!].id,
      reason: reasonController.text.isEmpty
          ? widget.leaveReq[widget.index!].reason
          : reasonController.text,
      fromDate: toPassStartDate == null
          ? widget.leaveReq[widget.index!].fromDate
          : toPassStartDate!,
      toDate: toPassEndDate == null
          ? widget.leaveReq[widget.index!].toDate
          : toPassEndDate!,
      fromTime: partialaVisible == false ? "" : (timeFrom ?? removeAmFromTime),
      toTime: partialaVisible == false ? "" : (timeto ?? removeAmToTime),

      status: status.toLowerCase(),
      leaveVisibleToAll: visiblePartialIs,
      partialLeave: visiblePartialIs,
      visibleToIds: selectedusersNameId == null
          ? widget.leaveReq[widget.index!].visibleToIds
          : selectedusersNameId!,
      // partialLeave: statusOfPartialIs,
      // Other fields
    );
    context.read<LeaveRequestBloc>().add(UpdateLeaveRequest(updatedRequestD));
    final setting = context.read<LeaveRequestBloc>();
    setting.stream.listen((state) {
      if (state is LeaveRequestEditSuccess) {
        if (mounted) {
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.updatedsuccessfully,
              color: AppColors.primary);

          context.read<LeaveRequestBloc>().add(LeaveRequestList(""));
          Navigator.pop(context);
        }
      }
      if (state is LeaveRequestEditError) {
        flutterToastCustom(msg: state.errorMessage);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    _connectivitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;

    hasEditor = context
        .read<AuthBloc>()
        .isLeaveEditor;

    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .backGroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            appbar(isLightTheme),
            SizedBox(height: 30.h),
            body(isLightTheme)
          ],
        ),
      ),
    );
  }

  Widget body(isLightTheme) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleUserField(
                isEditLeaveReq: widget.isCreate,
                userId: widget.leaveReq.isNotEmpty
                    ? [widget.leaveReq[widget.index!].userId!]
                    : [],
                isCreate: widget.isCreate!,
                name: singleUsersName ?? "",
                index: widget.index!,
                onSelected: handleSingleUsersSelected,
              )
              // : const SizedBox.shrink(),
            ],
          ),
          // hasEditor == true && role == 'admin'
          //     ?
          SizedBox(
            height: 15.h,
          ),
          // : const SizedBox.shrink(),
          Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 0.h),
            child: Row(
              children: [
                CustomSwitch(
                  isPartial: true,
                  isCreate: widget.isCreate,
                  status: partialaVisible,
                  onStatus: handleStatusSelectedPartial,
                ),
                SizedBox(
                  width: 20.w,
                ),
                CustomText(
                  text: AppLocalizations.of(context)!.partialleave,
                  fontWeight: FontWeight.w400,
                  size: 12.sp,
                  color: Theme
                      .of(context)
                      .colorScheme
                      .textClrChange,
                )
              ],
            ),
          ),
          const SizedBox(
            height: 15.0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: DateRangePickerWidget(
                    star: true,
                    size: 12.sp,
                    dateController: startController,
                    title: AppLocalizations.of(context)!.startsandends,
                    selectedDateEnds: selectedDateEnds,
                    selectedDateStarts: selectedDateStarts,
                    isLightTheme: isLightTheme,
                    onTap: (start, end) {
                      setState(() {
                        // If the end date is not selected or is null, set it to the start date
                        if (end!.isBefore(start!) ||
                            selectedDateEnds == null) {
                          end =
                              start; // Set the end date to the start date if not selected
                        }
                        selectedDateStarts = start;
                        selectedDateEnds = end;

                        startController.text = "${dateFormatConfirmed(
                            selectedDateStarts, context)} <-> ${dateFormatConfirmed(selectedDateEnds!, context)}";
                        endController.text =
                            dateFormatConfirmed(selectedDateEnds!, context);

                        // Check for same dates
                        if (selectedDateEnds!
                            .isBefore(selectedDateStarts)) {
                          flutterToastCustom(
                              msg: "End date cannot be before start date");
                          return; // Exit the function
                        }

                        // Prepare dates for passing or further processing
                        toPassStartDate =
                            dateFormatConfirmedToApi(selectedDateStarts);
                        toPassEndDate =
                            dateFormatConfirmedToApi(selectedDateEnds!);

                        // Calculate the difference in days
                        DateTime startDate = DateTime(
                          selectedDateStarts.year,
                          selectedDateStarts.month,
                          selectedDateStarts.day,
                        );

                        DateTime endDate = DateTime(
                          selectedDateEnds!.year,
                          selectedDateEnds!.month,
                          selectedDateEnds!.day,
                        );

                        int difference =
                            endDate
                                .difference(startDate)
                                .inDays;

                        // Add 1 to include both the start and end date
                        if (difference >= 0) {
                          difference += 1; // Adjust for inclusive days
                        } else {
                          difference = 0; // Handle negative differences
                        }

                        days = difference.toString();
                      });
                    },
                    // onTapp: () async {
                    //   // Call the date picker here when tapped
                    //   // showCustomDateRangePicker(
                    //   //   context,
                    //   //   dismissible: true,
                    //   //   minimumDate: DateTime.now().subtract(Duration(
                    //   //       days: 3)),
                    //   //   // Prevent selecting dates before today
                    //   //   maximumDate: DateTime(2199),
                    //   //   endDate: selectedDateEnds,
                    //   //   startDate: selectedDateStarts,
                    //   //   backgroundColor:
                    //   //   Theme
                    //   //       .of(context)
                    //   //       .colorScheme
                    //   //       .containerDark,
                    //   //   primaryColor: AppColors.primary,
                    //   //   onApplyClick: (start, end) {
                    //   //     setState(() {
                    //   //       // If the end date is not selected or is null, set it to the start date
                    //   //       if (end.isBefore(start) ||
                    //   //           selectedDateEnds == null) {
                    //   //         end =
                    //   //             start; // Set the end date to the start date if not selected
                    //   //       }
                    //   //       selectedDateStarts = start;
                    //   //       selectedDateEnds = end;
                    //   //
                    //   //       startController.text = dateFormatConfirmed(
                    //   //           selectedDateStarts, context);
                    //   //       endController.text =
                    //   //           dateFormatConfirmed(selectedDateEnds!, context);
                    //   //
                    //   //       // Check for same dates
                    //   //       if (selectedDateEnds!
                    //   //           .isBefore(selectedDateStarts)) {
                    //   //         flutterToastCustom(
                    //   //             msg: "End date cannot be before start date");
                    //   //         return; // Exit the function
                    //   //       }
                    //   //
                    //   //       // Prepare dates for passing or further processing
                    //   //       toPassStartDate =
                    //   //           dateFormatConfirmedToApi(selectedDateStarts);
                    //   //       toPassEndDate =
                    //   //           dateFormatConfirmedToApi(selectedDateEnds!);
                    //   //
                    //   //       // Calculate the difference in days
                    //   //       DateTime startDate = DateTime(
                    //   //         selectedDateStarts.year,
                    //   //         selectedDateStarts.month,
                    //   //         selectedDateStarts.day,
                    //   //       );
                    //   //
                    //   //       DateTime endDate = DateTime(
                    //   //         selectedDateEnds!.year,
                    //   //         selectedDateEnds!.month,
                    //   //         selectedDateEnds!.day,
                    //   //       );
                    //   //
                    //   //       int difference =
                    //   //           endDate
                    //   //               .difference(startDate)
                    //   //               .inDays;
                    //   //
                    //   //       // Add 1 to include both the start and end date
                    //   //       if (difference >= 0) {
                    //   //         difference += 1; // Adjust for inclusive days
                    //   //       } else {
                    //   //         difference = 0; // Handle negative differences
                    //   //       }
                    //   //
                    //   //       days = difference.toString();
                    //   //     });
                    //   //   },
                    //   //   onCancelClick: () {
                    //   //     setState(() {
                    //   //       // Handle cancellation if necessary
                    //   //     });
                    //   //   },
                    //   // );
                    // },
                    // isLightTheme: isLightTheme,
                  ),
                ),
                SizedBox(width: 10.w,),
                // Expanded(
                //   flex: 5,
                //   child: DateRangePickerWidget(
                //     star: true,
                //     size: 12.sp,
                //     dateController: endController,
                //     title: AppLocalizations.of(context)!.ends,
                //     isLightTheme: isLightTheme,
                //   ),
                // ),
                // SizedBox(width: 10.w,),
                Expanded(
                    flex: 2,
                    child: daysField(
                      isLightTheme,
                      statusOfPartial,
                      days,
                      AppLocalizations.of(context)!.days,
                      context
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          partialaVisible == true
              ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              children: [
                Expanded(flex: 3, child: fromTimeField(isLightTheme)),
                Expanded(flex: 3, child: toTimeField(isLightTheme)),

              ],
            ),
          )
              : const SizedBox.shrink(),

          SizedBox(
            height: 15.h,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 0.h),
            child: Row(
              children: [
                CustomVisibleSwitch(
                  isPartial: false,
                  // id: widget.LeaveReq!.id!,
                  visiblestatus: visiblestatus,
                  onStatus: handleStatusSelectedPartialstatus,
                  // primaryWorkspace: widget.LeaveReq!.,
                ),
                SizedBox(
                  width: 20.w,
                ),
                CustomText(
                  text: AppLocalizations.of(context)!.visibletoall,
                  fontWeight: FontWeight.w400,
                  size: 12.sp,
                  color: Theme
                      .of(context)
                      .colorScheme
                      .textClrChange,
                )
              ],
            ),
          ),
          SizedBox(
            height: 15.h,
          ),
          visiblestatus == false
              ? UsersField(
              isRequired: false,
              isCreate: widget.isCreate!,
              usersname: usersName ?? [],
              usersid: widget.isCreate == true
                  ? []
                  : widget.leaveReq[widget.index!].visibleToIds!,
              project: const [],
              onSelected: handleUsersSelected)
              : const SizedBox.shrink(),
          visiblestatus == false
              ? SizedBox(
            height: 15.h,
          )
              : const SizedBox.shrink(),
          CustomTextFields(
            title: AppLocalizations.of(context)!.reason,
            hinttext: AppLocalizations.of(context)!.pleaseenterreason,
            controller: reasonController,
            onSaved: (value) {},
            onFieldSubmitted: (value) {},
            isLightTheme: isLightTheme,
            isRequired: true,
          ),
          SizedBox(
            height: 25.h,
          ),
          statusOfLeaveRequest(isLightTheme),
          SizedBox(
            height: 15.h,
          ),
          BlocBuilder<LeaveRequestBloc, LeaveRequestState>(
              builder: (context, state) {
                if (state is LeaveRequestCreateSuccess) {}
                if (state is LeaveRequestCreateLoading) {
                  return CreateCancelButtom(
                    isLoading: true,
                    isCreate: widget.isCreate,
                    onpressCreate: widget.isCreate == true
                        ? () async {}
                        : () {
                      onEditLeaveRequest(widget.leaveReq[widget.index!].id);
                    },
                    onpressCancel: () {
                      Navigator.pop(context);
                    },
                  );
                }
                if (state is LeaveRequestEditLoading) {
                  return CreateCancelButtom(
                    isLoading: true,
                    isCreate: widget.isCreate,
                    onpressCreate: widget.isCreate == true
                        ? () async {

                    }
                        : () {
                      onEditLeaveRequest(widget.leaveReq[widget.index!].id);
                    },
                    onpressCancel: () {
                      Navigator.pop(context);
                    },
                  );
                }
                return CreateCancelButtom(
                  isCreate: widget.isCreate,
                  onpressCreate: widget.isCreate == true
                      ? () async {
                    onCreateLeaveReq(context);
                  }
                      : () {
                    onEditLeaveRequest(widget.leaveReq[widget.index!].id);
                  },
                  onpressCancel: () {
                    Navigator.pop(context);
                  },
                );
              }),
        ],
      ),
    );
  }

  Widget appbar(isLightTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 0.h),
          child: Column(
            children: [
              Container(
                  decoration: BoxDecoration(boxShadow: [
                    isLightTheme
                        ? MyThemes.lightThemeShadow
                        : MyThemes.darkThemeShadow,
                  ]),
                  // color: Colors.red,
                  // width: 300.w,
                  child: BackArrow(
                      title: widget.isCreate == false
                          ? AppLocalizations.of(context)!.editleaverequest
                          : AppLocalizations.of(context)!.createleavereq)),
            ],
          ),
        )
      ],
    );
  }

  Widget statusOfLeaveRequest(isLightTheme) {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 10.w),
      height: 40.h,
      // width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      decoration: BoxDecoration(
        // color: Colors.red,
        border: Border.all(color: AppColors.greyColor),
        // color: Theme.of(context).colorScheme.containerDark,
        borderRadius: BorderRadius.circular(12.r),
      ),
      // decoration: DesignConfiguration.shadow(),
      child: ToggleSwitch(
        // customTextStyles:[TextStyle(fontWeight: FontWeight.w400,
        //     fontSize: 12,
        //     color: colors.greyForgetColor)],
        fontSize: 12.sp,
        activeFgColor: Colors.white,
        // Set active text color
        inactiveFgColor: Theme
            .of(context)
            .colorScheme
            .textClrChange,
        // activeBgColors: [[Colors.yellow],[Colors.green],[Colors.red]],
        onToggle: (index) {
          setState(() {
            _currentIndex = index!;
            status = ['Pending', 'Approved', 'Rejected'][_currentIndex];
          });
        },
        cornerRadius: 10.r,

        activeBgColor: const [AppColors.primary],
        dividerColor: Colors.grey,
        inactiveBgColor: Colors.transparent,
        minHeight: 40.h,
        minWidth: double.infinity,
        initialLabelIndex: _currentIndex,
        // Ensure this is up-to-date
        totalSwitches: 3,

        labels: const ['Pending', 'Approved', 'Rejected'],
      ),
    );
  }


  Widget fromTimeField(isLightTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.fromtime,
                // text: getTranslated(context, 'myweeklyTask'),
                color: Theme
                    .of(context)
                    .colorScheme
                    .textClrChange,
                size: 16,
                fontWeight: FontWeight.w500,
              ),
              const CustomText(
                text: " *",
                // text: getTranslated(context, 'myweeklyTask'),
                color: AppColors.red,
                size: 15,
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Container(
            margin: EdgeInsets.only(left: 10.w, right: 10.w),
            padding: EdgeInsets.symmetric(horizontal: 0.w),
            height: 40.h,
            // margin: EdgeInsets.only(left: 20, right: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyColor),
              borderRadius: BorderRadius.circular(12),
            ),
            // decoration: DesignConfiguration.shadow(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: InkWell(
                splashColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    _selectstartTime();
                  });
                },
                child: Row(
                  children: [
                    const HeroIcon(
                      size: 20,
                      HeroIcons.clock,
                      style: HeroIconStyle.outline,
                      color: AppColors.greyForgetColor,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    CustomText(
                      text: _timestart.format(context),
                      fontWeight: FontWeight.w400,
                      size: 14.sp,
                      color: Theme
                          .of(context)
                          .colorScheme
                          .textClrChange,
                    ),
                  ],
                ),
              ),
            ))
      ],
    );
  }

  Widget toTimeField(isLightTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.totime,
                // text: getTranslated(context, 'myweeklyTask'),
                color: Theme
                    .of(context)
                    .colorScheme
                    .textClrChange,
                size: 16,
                fontWeight: FontWeight.w500,
              ),
              const CustomText(
                text: " *",
                // text: getTranslated(context, 'myweeklyTask'),
                color: AppColors.red,
                size: 15,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Container(
            margin: const EdgeInsets.only(right: 10, left: 10),
            padding: EdgeInsets.symmetric(horizontal: 0.w),
            height: 40.h,
            // margin: EdgeInsets.only(left: 20, right: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyColor),
              borderRadius: BorderRadius.circular(12),
            ),
            // decoration: DesignConfiguration.shadow(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: InkWell(
                splashColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    _selectendTime();
                  });
                },
                child: Row(
                  children: [
                    HeroIcon(
                      size: 20.sp,
                      HeroIcons.clock,
                      style: HeroIconStyle.outline,
                      color: AppColors.greyForgetColor,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    CustomText(
                      text: _timeend.format(context),
                      fontWeight: FontWeight.w400,
                      size: 14.sp,
                      color: Theme
                          .of(context)
                          .colorScheme
                          .textClrChange,
                    ),
                  ],
                ),
              ),
            ))
      ],
    );
  }

}
