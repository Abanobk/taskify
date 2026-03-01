
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/model/meetings/meeting_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../bloc/meeting/meeting_bloc.dart';
import '../../bloc/meeting/meeting_event.dart';
import '../../bloc/meeting/meeting_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../../config/constants.dart';
import '../../data/GlobalVariable/globalvariable.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_text.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/no_internet_screen.dart';
import '../../utils/widgets/toast_widget.dart';
import '../task/Widget/users_field.dart';
import '../widgets/custom_date.dart';
import '../widgets/custom_cancel_create_button.dart';

import '../widgets/clients_field.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../../../src/generated/i18n/app_localizations.dart';

import '../widgets/custom_textfields/custom_textfield.dart';

class CreateMeetingScreen extends StatefulWidget {
  final bool? isCreate;
  final List<MeetingModel>? meeting;
  final int? index;
  final MeetingModel? meetingModel;
  const CreateMeetingScreen(
      {super.key, this.isCreate, this.index, this.meetingModel, this.meeting});

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController dojController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController addrerssController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController zipcodeController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController startsController = TextEditingController();
  TextEditingController endController = TextEditingController();

  String initialCountry = defaultCountry;
  PhoneNumber number = PhoneNumber(isoCode: defaultCountry);
  String selectedUser = '';
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  List<int>? selectedClientId;
  List<String>? selectedClient;
  List<String>? usersName;
  List<int>? selectedusersNameId;
  String? fromDate;
  String? toDate;
  String? strtTime;
  String? endTime;
  String? formattedTimeStart;
  String? formattedTimeEnd;
  DateTime? selectedDateStarts;
  DateTime? selectedDateEnds;
  TimeOfDay? _timestart;
  TimeOfDay? _timeend;
  String formatTimeOfDay(TimeOfDay timeOfDay) {
    // Convert TimeOfDay to DateTime
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);

    // Format to 12-hour time (hh:mm AM/PM)
    return DateFormat('hh:mm a').format(dateTime);
  }

  void _selectstartTime() async {
    // Show the time picker dialog
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _timestart ??
          TimeOfDay.now(), // Use current time if _timestart is null
    );

    // If the user picks a valid time
    if (newTime != null) {
      setState(() {
        _timestart = newTime; // Update _timestart with the selected time
        // Format time as HH:MM
        formattedTimeStart =
        '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';

      });
    }
  }


  void _selectendTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _timeend ?? TimeOfDay.now(),
    );

    if (newTime != null) {
      setState(() {
        _timeend = newTime;

        // Format as HH:MM
        formattedTimeEnd =
        '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';


      });
    }
  }

  void handleUsersSelected(List<String> category, List<int> catId) {
    setState(() {
      usersName = category;
      selectedusersNameId = catId;

    });

  }

  void handleClientSelected(List<String> category, List<int> catId) {
    setState(() {
      selectedClient = category;
      selectedClientId = catId;
    });

  }

  String selectedCategory = '';

  List<Color> statusColor = [
    Colors.orange,
    Colors.lightBlueAccent,
    Colors.deepPurpleAccent,
    Colors.red
  ];
  FocusNode? phoneFocus,
      emailFocus,
      addressFocus,
      cityFocus,
      stateFocus,
      countryFocus,
      zipFocus = FocusNode();

  List<int>? listOfuserId = [];
  List<int>? listOfclientId = [];
  void onCreateMeeting(BuildContext context) {

    if (titleController.text.isNotEmpty &&
        fromDate != null &&
        fromDate!.isNotEmpty &&
        toDate != null &&
        toDate!.isNotEmpty &&
        formattedTimeStart != null &&
        formattedTimeEnd != null) {

      final meetingBloc = BlocProvider.of<MeetingBloc>(context);
      meetingBloc.add(AddMeetings(
        MeetingModel(
          title: titleController.text,
          startDate: fromDate!,
          endDate: toDate!,
          startTime: formattedTimeStart!,
          endTime: formattedTimeEnd!,
          userIds: selectedusersNameId??[],
          clientIds: selectedClientId ?? [],
        ),
      ));
      meetingBloc.stream.listen((state) {
        if (state is MeetingCreateSuccess) {
          meetingBloc.add(const MeetingLists());
          router.push('/meetings');

          flutterToastCustom(
              msg: AppLocalizations.of(navigatorKey.currentContext!)!.createdsuccessfully,
              color: AppColors.primary);

        }
        if (state is MeetingCreateError) {
          flutterToastCustom(msg: state.errorMessage);
        }
      });
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  void onUpdateMeeting(context, id) {
    final meetingBloc = BlocProvider.of<MeetingBloc>(context);
    meetingBloc.add(MeetingUpdateds(MeetingModel(
      id: id!,
      title: titleController.text,
      startDate: fromDate ?? widget.meetingModel!.startDate,
      endDate: toDate ?? widget.meetingModel!.endDate,
      startTime: formattedTimeStart ?? widget.meetingModel!.startTime,
      endTime: formattedTimeEnd ?? widget.meetingModel!.endTime,
      userIds: selectedusersNameId == null
          ? widget.meetingModel!.userIds
          : selectedusersNameId!,
      clientIds: selectedClientId == null
          ? widget.meetingModel!.clientIds
          : selectedClientId!,
    )));

    meetingBloc.stream.listen((state) {
      if (state is MeetingEditSuccess) {


        Navigator.pop(context);
        flutterToastCustom(
            msg: AppLocalizations.of(context)!.updatedsuccessfully,
            color: AppColors.primary);  BlocProvider.of<MeetingBloc>(context).add(const MeetingLists());
      }

      if (state is MeetingEditError) {
        flutterToastCustom(msg: state.errorMessage);
        BlocProvider.of<MeetingBloc>(context).add(const MeetingLists());
      }
    });
  }

  String formatDate(String date) {
    // Parse the input date string
    DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(date);

    // Format it to the desired output
    return DateFormat('dd, MMM yyyy').format(parsedDate);
  }

  @override
  void initState() {
// Initialize currentUser
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
    if (widget.isCreate == false) {
      var endDate;
      var startDate;
if(widget.meetingModel!= null){
  var startDateApi =
  parseDateStringFromApi(widget.meetingModel!.startDate!);
   startDate = dateFormatConfirmed(startDateApi, context);
  selectedDateStarts = startDateApi;
}
if(widget.meetingModel != null) {
  var endDateApi = parseDateStringFromApi(widget.meetingModel!.endDate!);
  endDate = dateFormatConfirmed(endDateApi, context);
  selectedDateEnds = endDateApi;
}
      List<String>? listOfuser = [];
      if (widget.meetingModel != null) {
        for (var ids in widget.meetingModel!.users!) {
          listOfuser.add(ids.firstName!);
          listOfuserId!.add(ids.id!);
        }
      }
      List<String>? listOfclients = [];
      if (widget.meetingModel != null) {
        for (var ids in widget.meetingModel!.clients!) {
          listOfclients.add(ids.firstName!);
          listOfclientId!.add(ids.id!);
        }
      }
      _timestart = convertToTimeOfDay(widget.meetingModel!.startTime!);
      _timeend = convertToTimeOfDay(widget.meetingModel!.endTime!);
      titleController =
          TextEditingController(text: widget.meetingModel!.title!);
      startsController = TextEditingController(text: "$startDate <-> $endDate");
      endController = TextEditingController(text: endDate);
      formattedTimeStart = widget.meetingModel!.startTime;
      formattedTimeEnd = widget.meetingModel!.endTime;
      usersName = listOfuser;
      selectedClient = listOfclients;
    } else {}
    super.initState();
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
    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : Scaffold(
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
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
                    title: widget.isCreate == true
                        ? AppLocalizations.of(context)!.createmeeting
                        : AppLocalizations.of(context)!.editmeeting,
                  )),
            ],
          ),
        )
      ],
    );
  }

  Widget body(isLightTheme) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextFields(
            title: AppLocalizations.of(context)!.title,
            hinttext: AppLocalizations.of(context)!.pleaseentertitle,
            controller: titleController,
            onSaved: (value) {},
            onFieldSubmitted: (value) {},
            isLightTheme: isLightTheme,
            isRequired: true,
          ),
          SizedBox(
            height: 15.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: DateRangePickerWidget(
              dateController: startsController, // Use only one controller
              title: AppLocalizations.of(context)!.date,

              titlestartend: AppLocalizations.of(context)!.selectstartenddate,
               selectedDateEnds: selectedDateEnds,
                    selectedDateStarts: selectedDateStarts,
                    isLightTheme: isLightTheme,
                    onTap: (start, end) {
                      setState(() {
                        selectedDateEnds = end;
                        selectedDateStarts = start;

                        // Show both start and end dates in the same controller
                        startsController.text =
                        "${dateFormatConfirmed(selectedDateStarts!, context)} <-> ${dateFormatConfirmed(selectedDateEnds!, context)}";

                        // Assign values for API submission
                        fromDate = dateFormatConfirmedToApi(start!);
                        toDate = dateFormatConfirmedToApi(end!);
                      });
                    },
            ),
          ),
          SizedBox(
            height: 15.h,
          ),
          SizedBox(
            height: 10.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                startTime(isLightTheme),
                SizedBox(
                  width: 10.w,
                ),
                endTimeOfMeeting(isLightTheme)
              ],
            ),
          ),
          SizedBox(
            height: 15.h,
          ),
                  UsersField(
            isMeeting: true,
            isRequired: false,
            isCreate: widget.isCreate!,
            usersname: usersName ?? [],
            usersid: listOfuserId!,
            project: const [],
            // index: widget.index,
            onSelected: handleUsersSelected),
          SizedBox(
            height: 15.h,
          ),
                  ClientField(
            isCreate: widget.isCreate!,
            usersname: selectedClient ?? [],
            clientsid: listOfclientId!,
            project: const [],
            onSelected: handleClientSelected),
          SizedBox(
            height: 15.h,
          ),
          BlocBuilder<MeetingBloc, MeetingState>(builder: (context, state) {
            if (state is MeetingEditSuccessLoading) {
              return CreateCancelButtom(
                isLoading: true,
                isCreate: widget.isCreate,
                onpressCreate: widget.isCreate == true
                    ? () async {
                  onCreateMeeting(context);
                }
                    : () {
                  onUpdateMeeting(context, widget.meetingModel!.id);

                },
                onpressCancel: () {
                  Navigator.pop(context);
                },
              );
            }
            if (state is MeetingCreateSuccessLoading) {
              return CreateCancelButtom(
                isLoading: true,
                isCreate: widget.isCreate,
                onpressCreate: widget.isCreate == true
                    ? () async {
                  onCreateMeeting(context);
                  // context.read<LeaveRequestBloc>().add(LeaveRequestList());
                }
                    : () {
                  onUpdateMeeting(context, widget.meetingModel!.id);
                  // context.read<LeaveRequestBloc>().add(LeaveRequestList());

                  // Navigator.pop(context);
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
                onCreateMeeting(context);
                // context.read<LeaveRequestBloc>().add(LeaveRequestList());
              }
                  : () {
                onUpdateMeeting(context, widget.meetingModel!.id);
                // context.read<LeaveRequestBloc>().add(LeaveRequestList());

                // Navigator.pop(context);
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

  Widget startsField(isLightTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.starts,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
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
          padding: EdgeInsets.symmetric(horizontal: 0.w),
          height: 40.h,
          width: double.infinity,
          // margin: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.greyColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.textClrChange,
            ),
            readOnly: true,
            onTap: () {
              // Call the date picker here when tapped
              // showCustomDateRangePicker(
              //   context,
              //   dismissible: true,
              //   minimumDate: DateTime.now().subtract(const Duration(days: 30)),
              //   maximumDate: DateTime.now().add(const Duration(days: 30)),
              //   endDate: selectedDateEnds,
              //   startDate: selectedDateStarts,
              //   backgroundColor: Theme.of(context).colorScheme.containerDark,
              //   primaryColor: AppColors.primary,
              //   onApplyClick: (start, end) {
              //     setState(() {
              //       if (start.isBefore(DateTime.now())) {
              //         start = DateTime
              //             .now(); // Reset the start date to today if earlier
              //       }
              //
              //       // If the end date is not selected or is null, set it to the start date
              //       if (end.isBefore(start) || selectedDateEnds == null) {
              //         end =
              //             start; // Set the end date to the start date if not selected
              //       }
              //       selectedDateEnds = end;
              //       selectedDateStarts = start;
              //
              //       startsController.text =
              //           dateFormatConfirmed(selectedDateStarts!, context);
              //       endController.text =
              //           dateFormatConfirmed(selectedDateEnds!, context);
              //       fromDate = dateFormatConfirmed(start, context);
              //       toDate = dateFormatConfirmed(end, context);
              //
              //     });
              //   },
              //   onCancelClick: () {
              //     setState(() {
              //       // Handle cancellation if necessary
              //     });
              //   },
              // );
            },
            controller: startsController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.selectdate,
              hintStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: AppColors.greyForgetColor,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: (50.h - 20.sp) / 2,
                horizontal: 10.w,
              ),
              // contentPadding: EdgeInsets.only(
              //     bottom: 15.h, left: 10.w,right: 10.w
              // ),
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }

  Widget endsField(isLightTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomText(
              text: AppLocalizations.of(context)!.ends,
              // text: getTranslated(context, 'myweeklyTask'),
              color: Theme.of(context).colorScheme.textClrChange,
              size: 16,
              fontWeight: FontWeight.w700,
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
        SizedBox(
          height: 5.h,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 0.w),
          height: 40.h,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.greyColor),
            borderRadius: BorderRadius.circular(12),
          ),
          // decoration: DesignConfiguration.shadow(),
          child: TextFormField(
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.textClrChange,
            ),
            readOnly: true,
            controller: endController,
            keyboardType: TextInputType.text,
            // validator: (val) => StringValidation.validateField(
            //   val!,
            //   getTranslated(context, 'required'),
            // ),
            cursorColor: AppColors.greyForgetColor,
            cursorWidth: 1.w,
            enableInteractiveSelection: false,
            onSaved: (String? value) {
              // context.read<AuthenticationProvider>().setSingUp(value);
            },
            onFieldSubmitted: (v) {
              // _fieldFocusChange(
              //   context,
              //   firstnameFocus!,
              //   lastnameFocus,
              // );
            },
            decoration: InputDecoration(
              // labelText: "firstname",
                hintText: AppLocalizations.of(context)!.selectdate,
                hintStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    color: AppColors.greyForgetColor),
                labelStyle: const TextStyle(
                  // fontFamily: fontFamily,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: AppColors.greyForgetColor,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: (50.h - 20.sp) / 2,
                  horizontal: 10.w,
                ), // Centext vertically
                border: InputBorder.none),
          ),
        )
      ],
    );
  }

  Widget startTime(isLightTheme) {
    return Expanded(
        child: Container(
          // margin: EdgeInsets.only(left: 20.w, right: 10.w),
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
                highlightColor: Colors.transparent, // No highlight on tap
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
                        color: AppColors.greyForgetColor),
                    SizedBox(
                      width: 10.w,
                    ),
                    CustomText(
                      text: widget.isCreate == true
                          ? (_timestart != null
                          ? _timestart!.format(context)
                          : "Select Time") // Check for null before calling `format`
                          : formattedTimeStart!,
                      fontWeight: FontWeight.w400,
                      size: 14.sp,
                      color: Theme.of(context).colorScheme.textClrChange,
                    )
                  ],
                ),
              ),
            )));
  }

  Widget endTimeOfMeeting(isLightTheme) {
    return Expanded(
        child: Container(
          // margin: EdgeInsets.only(right: 20.w, left: 10.w),
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
                highlightColor: Colors.transparent, // No highlight on tap
                splashColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    _selectendTime();
                  });
                },
                child: Row(
                  children: [
                    const HeroIcon(
                        size: 20,
                        HeroIcons.clock,
                        style: HeroIconStyle.outline,
                        color: AppColors.greyForgetColor),
                    SizedBox(
                      width: 10.w,
                    ),
                    CustomText(
                      text: widget.isCreate == true
                          ? (_timeend != null
                          ? _timeend!.format(context)
                          : "Select Time")
                          : formattedTimeEnd!,
                      fontWeight: FontWeight.w400,
                      size: 14.sp,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                  ],
                ),
              ),
            )));
  }
}