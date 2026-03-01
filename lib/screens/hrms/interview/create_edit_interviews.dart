import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:taskify/bloc/interviews/interviews_bloc.dart';
import 'package:taskify/bloc/interviews/interviews_event.dart';
import 'package:taskify/bloc/interviews/interviews_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/data/model/interview/interview_model.dart';
import 'package:taskify/screens/hrms/widgets/candidate_list.dart';
import '../../../bloc/candidate_interviews/candidate_interviews_bloc.dart';
import '../../../bloc/candidate_interviews/candidate_interviews_event.dart';
import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/permissions/permissions_event.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/constants.dart';
import '../../../config/internet_connectivity.dart';
import '../../../routes/routes.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/back_arrow.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/no_internet_screen.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../widgets/custom_date.dart';
import '../../widgets/custom_textfields/custom_textfield.dart';
import '../widgets/constList.dart';
import '../widgets/interviewer_list.dart';

class CreateEditInterviews extends StatefulWidget {
  final int? candidateId;
  final String? candidateName;
  final bool? isCreate;
  final InterviewModel? interviewModel;
  const CreateEditInterviews({super.key, this.isCreate, this.interviewModel,this.candidateId,this.candidateName});

  @override
  State<CreateEditInterviews> createState() => _CreateEditInterviewsState();
}

class _CreateEditInterviewsState extends State<CreateEditInterviews> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  String? selectedColorName;
  bool? isLoading;
  String storedDateTime="";
  ValueNotifier<List<File>> selectedFilesNotifier = ValueNotifier([]);

  TextEditingController titleController = TextEditingController();
  TextEditingController roundController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController startController = TextEditingController();

  String? selectedCandidate;
  int? selectedCandidateId;
  String? selectedInterviewer;
  int? selectedInterviewerId;
  String? selectedMode;
  String? selectedStatus;

  DateTime selectedDateStarts = DateTime.now();
  DateTime selectedDateEnds = DateTime.now();
  String? toPassStartDate = "";
  InterviewModel? currentInterview;
  String? datePart;
  String? timePart;
  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  void _handleCandidateSelected(String? status, int? statusId) {
    setState(() {
      selectedCandidate = status;
      selectedCandidateId = statusId;
    });
  }

  void _handleIntervierSelected(String? status, int? statusId) {
    setState(() {
      selectedInterviewer = status;
      selectedInterviewerId = statusId;
    });
  }

  void _handleModeSelected(String? mode) {
    setState(() {
      selectedMode = mode;
    });
  }

  void _handleStatusSelected(String? status) {
    setState(() {
      selectedStatus = status;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
    _initializePermissions();
    _initializeCandidateData();
  }

  void _initializeConnectivity() {
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() => _connectionStatus = results);
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() => _connectionStatus = value);
        });
      }
    });
  }

  void _initializePermissions() {
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
  }

  void _initializeCandidateData() {
    print("tyuiopretrt  ${widget.candidateId}");
    if(widget.candidateId !=0 ){
      selectedCandidateId = widget.candidateId;
      selectedCandidate=widget.candidateName;
    }
    if (widget.interviewModel != null) {
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    print("tyuhik #${widget.candidateId}");
    currentInterview = widget.interviewModel!;

    if(widget.candidateId !=0){
    selectedCandidateId = widget.candidateId;
    selectedCandidate=widget.candidateName;
    }else{
      selectedCandidateId =  currentInterview!.candidateId;
      selectedCandidate = currentInterview!.candidateName;
    }
    selectedInterviewerId = currentInterview!.interviewerId;
    selectedInterviewer = currentInterview!.interviewerName;
    roundController.text = currentInterview!.round!;
    locationController.text = currentInterview!.location!;
    selectedMode = currentInterview!.mode;
    selectedStatus = currentInterview!.status;
    if (currentInterview!.scheduledAt != "") {
      final rawDateTime = currentInterview!.scheduledAt!;
      final dateTime = DateTime.parse(rawDateTime);

      final formated =
          "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
      final timePart =
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
      DateTime parsedDate = parseDateStringFromApi(formated);
      datePart = dateFormatConfirmed(parsedDate, context);

      startController.text = '📅 $datePart 🕒 $timePart';
    }
    print("gyhjk ${selectedCandidateId}");
  }

  void _validateAndSubmitForm() {
    if (widget.isCreate == true) {
      _onCreateInterview();
    } else {
      _onEditInterview(currentInterview!);
    }
  }

  void _onCreateInterview() {
    if (roundController.text.isNotEmpty &&
        selectedCandidateId != null &&
        selectedInterviewerId != null &&
        selectedMode != null &&
        selectedStatus != null &&
        datePart != null) {

      context.read<InterviewsBloc>().add(CreateInterviews(
          candidateId: selectedCandidateId,
          candidateName: selectedColorName,
          interviewerId: selectedInterviewerId,
          interviewerName: selectedInterviewer,
          round: roundController.text,
          scheduledAt:storedDateTime,
          location: locationController.text,
          mode: selectedMode!.toLowerCase(),
          status: selectedStatus!.toLowerCase()));

      // CandidateBloc.add(CandidateList());
    } else {
      flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleasefilltherequiredfield);
    }
  }

  void _onEditInterview(candidate) async {
    if (roundController.text.isNotEmpty &&
        selectedCandidateId != null &&
        selectedInterviewerId != null &&
        selectedMode != null &&
        selectedStatus != null &&
        datePart != null) {
      print("rtyuio");
 if(widget.candidateId!=0){
   context.read<CandidateInterviewssBloc>().add(UpdateCandidateInterview(
       id: currentInterview!.id,
       candidateId: selectedCandidateId,
       candidateName: selectedCandidate,
       interviewerId: selectedInterviewerId,
       interviewerName: selectedInterviewer,
       round: roundController.text,
       scheduledAt:storedDateTime != ""? storedDateTime:widget.interviewModel!.scheduledAt!,
       location: locationController.text,
       mode: selectedMode!.toLowerCase(),
       status: selectedStatus!.toLowerCase()));
 }else{
   context.read<InterviewsBloc>().add(UpdateInterviews(
       id: currentInterview!.id,
       candidateId: selectedCandidateId,
       candidateName: selectedCandidate,
       interviewerId: selectedInterviewerId,
       interviewerName: selectedInterviewer,
       round: roundController.text,
       scheduledAt:storedDateTime != ""? storedDateTime:widget.interviewModel!.scheduledAt!,
       location: locationController.text,
       mode: selectedMode!.toLowerCase(),
       status: selectedStatus!.toLowerCase()));
 }
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    bool isLightTheme = currentTheme is LightThemeState;

    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, Object? result) async {
              if (!didPop) {
                router.pop();
              }
            },
            child: Scaffold(
              backgroundColor: Theme.of(context).colorScheme.backGroundColor,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(isLightTheme),
                    SizedBox(height: 30.h),
                    _buildForm(isLightTheme),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildHeader(bool isLightTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 0.h),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    isLightTheme
                        ? MyThemes.lightThemeShadow
                        : MyThemes.darkThemeShadow,
                  ],
                ),
                child: BackArrow(
                  onTap: () {
                    if (widget.isCreate == false) {
                      router.pop();
                    } else {
                      router.pop();
                    }

                  },
                  title: widget.isCreate == true
                      ? AppLocalizations.of(context)!.createinterview
                      : AppLocalizations.of(context)!.updateinterview,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm(bool isLightTheme) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15.h),
            _buildFormFields(isLightTheme),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }
  Widget _buildActionButtons() {
    return BlocConsumer<InterviewsBloc, InterviewsState>(
      listener: (context, state) {
        if(state is InterviewsCreateError){
          flutterToastCustom(msg: state.errorMessage);
          context.read<InterviewsBloc>().add(const InterviewsList());

        } if(state is InterviewsError){
          flutterToastCustom(msg: state.errorMessage);
          context.read<InterviewsBloc>().add(const InterviewsList());

        } if(state is InterviewsEditError){
          flutterToastCustom(msg: state.errorMessage);
          // context.read<CandidatesBloc>().add(const CandidatesList());

        }if(state is InterviewsCreateSuccess){
          BlocProvider.of<CandidateInterviewssBloc>(context).add(CandidateInterviewsList(id: widget.candidateId));
          flutterToastCustom(
              msg: AppLocalizations.of(context)!
                  .createdsuccessfully,
              color: AppColors.primary);
          // context.read<CandidatesBloc>().add(const CandidatesList());

        }
        if(state is InterviewsCreateSuccess){
          if (mounted) {
            Navigator.pop(context);
            // router.go('/notes');
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.createdsuccessfully,
                color: AppColors.primary);
          }
          BlocProvider.of<CandidateInterviewssBloc>(context).add(CandidateInterviewsList(id: widget.candidateId));

        }
        if(state is InterviewsEditSuccess){
          if (mounted) {
            Navigator.pop(context);
            // router.go('/notes');
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.updatedsuccessfully,
                color: AppColors.primary);
          }
          BlocProvider.of<CandidateInterviewssBloc>(context).add(CandidateInterviewsList(id: widget.candidateId));

        }
      },
      builder: (context, state) {
        print(
          "ioejfefio #$state"
        );
        final isLoading = state is InterviewsLoading || state is InterviewsEditSuccessLoading;
        return Padding(
          padding:  EdgeInsets.only(bottom  : 28.h),
          child: CreateCancelButtom(
            isLoading: isLoading,
            isCreate: widget.isCreate,
            onpressCancel: () => Navigator.pop(context),
            onpressCreate: () => _validateAndSubmitForm(),
          ),
        );
      },
    );
  }

  // Widget _buildActionButtons() {
  //   return BlocBuilder<InterviewsBloc, InterviewsState>(
  //     builder: (context, state) {
  //       if(state is InterviewsCreateSuccess){
  //
  //       }
  //       final isLoading = state is ClientLoadingCreate || state is ClientLoadingEdit;
  //   return CreateCancelButtom(
  //     isLoading: isLoading,
  //     isCreate: widget.isCreate,
  //     onpressCancel: () => Navigator.pop(context),
  //     onpressCreate: () => _validateAndSubmitForm(),
  //   );
  //     },
  //   );
  // }

  Widget _buildFormFields(isLightTheme) {
    return Column(
      children: [
        CandidateField(
          isOpenDialog:widget.candidateId!=0?"candidateInterview":"",
            isRequired: true,
            isCreate: widget.isCreate!,
            username: selectedCandidate ?? "",
            status: const [],
            candidatesId: selectedCandidateId,
            onSelected: _handleCandidateSelected),
        SizedBox(
          height: 15.h,
        ),
        InterviewerListField(
          isRequired: true,
          isEditLeaveReq: widget.isCreate,
          inteviewerId: [selectedInterviewerId!],
          isCreate: widget.isCreate!,
          name: selectedInterviewer ?? "",
          from: false,
          index: 0,
          onSelected: _handleIntervierSelected,
        ),
        // InterviewerField(
        //     isRequired: true,
        //     isCreate: widget.isCreate!,
        //     username: selectedInterviewer ?? "",
        //     status: const [],
        //     interviewId: selectedInterviewerId,
        //     onSelected: _handleIntervierSelected),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          title: AppLocalizations.of(context)!.round,
          hinttext: AppLocalizations.of(context)!.pleaseenterround,
          controller: roundController,
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
          child: DatePickerWidget(
            star: true,
            size: 12.sp,
            dateController: startController,
            title: AppLocalizations.of(context)!.starts,
            onTap: () async {
              DateTime? selectedDate = await showOmniDateTimePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1600).subtract(const Duration(days: 3652)),
                lastDate: DateTime.now().add(const Duration(days: 3652)),
                is24HourMode: false,
                isShowSeconds: false,
                minutesInterval: 1,
                secondsInterval: 1,
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                constraints: const BoxConstraints(
                  maxWidth: 350,
                  maxHeight: 650,
                ),
                transitionBuilder: (context, anim1, anim2, child) {
                  return FadeTransition(
                    opacity: anim1.drive(Tween(begin: 0, end: 1)),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 200),
                barrierDismissible: true,
                selectableDayPredicate: (dateTime) {
                  if (dateTime == DateTime(2023, 2, 25)) {
                    return false;
                  } else {
                    return true;
                  }
                },
              );

              if (selectedDate != null) {
                 storedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate);

                // Optional: Print or use it elsewhere
                print('Stored DateTime: $storedDateTime');
                datePart = dateFormatConfirmed(selectedDate, context);
                timePart = DateFormat('hh:mm a').format(selectedDate);

                // Combine both
                startController.text = '📅 $datePart 🕒 $timePart';
              }
            },
            isLightTheme: isLightTheme,
          ),
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          title: AppLocalizations.of(context)!.location,
          hinttext: AppLocalizations.of(context)!.location,
          controller: locationController,
          keyboardType: TextInputType.text,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: false,
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomSelectField(
            title: AppLocalizations.of(context)!.mode,
            items: ["Online", "Offline"],
            initialValue: selectedMode,
            isCreate: true,
            isRequired: true,
            onSelected: _handleModeSelected),
        SizedBox(
          height: 15.h,
        ),
        CustomSelectField(
            title: AppLocalizations.of(context)!.status,
            items: ["Scheduled", "Completed", "Cancelled"],
            initialValue: selectedStatus ?? "".toLowerCase(),
            isCreate: true,
            isRequired: true,
            onSelected: _handleStatusSelected),
        SizedBox(
          height: 15.h,
        ),
        // StatusField(
        //   status: 1,
        //   isRequired: true,
        //   isCreate: widget.isCreate!,
        //   name: selectedStatus ?? "",
        //   index: widget.index!,
        //   onSelected: _handleStatusSelected,
        // ),
      ],
    );
  }
}
