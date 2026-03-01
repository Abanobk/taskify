import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import 'package:taskify/bloc/leads/leads_bloc.dart';
import 'package:taskify/bloc/leads/leads_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/data/model/leads/leads_model.dart';
import '../../../bloc/leads/leads_event.dart';
import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/permissions/permissions_event.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/constants.dart';
import '../../../config/internet_connectivity.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/back_arrow.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/no_internet_screen.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../leave_request/widgets/single_userfield.dart';
import '../../settings/app_settings/widgets/custom_list.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../widgets/custom_date.dart';
import '../../widgets/html_widget.dart';
import '../../widgets/note_editor.dart';
import '../../../routes/routes.dart';

class CreateEditLeadsFollowUps extends StatefulWidget {
  final bool? isCreate;
  final FollowUps? leadsModel;

  final int leadId;
  const CreateEditLeadsFollowUps({super.key, this.isCreate, this.leadsModel,required this.leadId});

  @override
  State<CreateEditLeadsFollowUps> createState() =>
      _CreateEditLeadsFollowUpsState();
}

class _CreateEditLeadsFollowUpsState extends State<CreateEditLeadsFollowUps> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  bool? isLoading;

  TextEditingController followupDateController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  DateTime? selectedDateStarts;
  String? datePart;
  String? timePart;
  String storedDateTime = "";
  String? fromDate;
  DateTime? selectedDateEnds;
  DateTime? parsedDate;
  String selectedFollowUpType="call";
  String? notes;
  String? status;

  void _handleMethodSelected(String category) {
    if (selectedFollowUpType != category) {
      setState(() {
        selectedFollowUpType = category;
      });
    }
  }

  void _handleMethodSelectedStatus(String category) {
    if (status != category) {
      setState(() {
        status = category;
      });
    }
  }

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController jobTitleController = TextEditingController();
  TextEditingController industryController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController linkedInController = TextEditingController();
  TextEditingController instagramController = TextEditingController();
  TextEditingController facebookController = TextEditingController();
  TextEditingController pinterestController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  String defaultCountryLocal = "";

  String selectedLeadSource = '';
  int? selectedID;
  String selectedLeadStage = '';
  int? selectedLeadStageID;
  String selectedUsersName = '';
  String selectedUsersEmail = '';
  String selectedUsersProfile = '';
  int? selectedUsersNameID;

  FollowUps? currentLead;
  String? countryCodeNumber;
  String? countryCode;
  String? countryIsoCode;

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }


  void handleSingleUsersSelected(
      String category, int catID, String email, String profile) {
    setState(() {
      selectedUsersName = category;
      selectedUsersNameID = catID;
      selectedUsersEmail = email;
      selectedUsersProfile = profile;
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

    if (widget.leadsModel != null && widget.isCreate == false) {
      _initializeControllers();
    } else {
      defaultCountryLocal = defaultCountry;
    }
  }

  void _initializeControllers() {
    currentLead = widget.leadsModel!;

    selectedUsersName = currentLead!.assignedTo!.name!;
    selectedFollowUpType = currentLead!.type!;
    selectedUsersNameID = currentLead!.assignedTo!.id;
    status = currentLead!.status!;
    notes = widget.leadsModel!.note;
    if (currentLead!.followUpAt != "") {
      final rawDateTime = currentLead!.followUpAt!;
      final dateTime = DateTime.parse(rawDateTime);
      timePart = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
      final onlyDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
      datePart = DateFormat('yyyy-MM-dd').format(onlyDate);
      followupDateController.text = '📅 $datePart 🕒 $timePart';
    }
  }

  void _validateAndSubmitForm() {
    if (widget.isCreate == true) {
      _onCreateLeadsFollowUp();
    } else {
      _onEditLeadsFollowUp(currentLead!);
    }
  }

  void _listenToClientBloc(LeadBloc bloc) {
    bloc.stream.listen((state) {
      if (state is LeadCreateFollowUpSuccess) {
        _handleClientSuccess();
      } else if (state is LeadCreateFollowUpError) {
        _handleClientError(state.errorMessage);
      } else if (state is LeadEditFollowUpError) {
        _handleClientEditSuccess();
      } else if (state is LeadEditError) {
        _handleClientError(state.errorMessage);
      }
    });
  }

  void _handleClientSuccess() {
    isLoading = false;
    if (mounted) {
      flutterToastCustom(
          msg: AppLocalizations.of(context)!.createdsuccessfully,
          color: AppColors.primary
      );
      context.read<LeadBloc>().add(LeadLists());
      Navigator.pop(context);
    }
  }

  void _handleClientEditSuccess() {
    if (mounted) {
      isLoading = false;
      context.read<LeadBloc>().add(LeadLists());
      _refreshClientData();
      Navigator.pop(context);
      flutterToastCustom(
          msg: AppLocalizations.of(context)!.updatedsuccessfully,
          color: AppColors.primary
      );
    }
  }
  void _refreshClientData() {
    context.read<LeadBloc>().add(LeadLists());

  }
  void _handleClientError(String errorMessage) {
    isLoading = false;
    flutterToastCustom(msg: errorMessage);
  }
  void _onCreateLeadsFollowUp() {


      if (selectedUsersNameID != "" &&
          selectedFollowUpType != "" &&
          datePart != null) {
        DateTime dateTime = DateFormat('dd-MM-yyyy hh:mm a').parse("$datePart $timePart");
        String formatted = DateFormat("yyyy-MM-dd'T'HH:mm").format(dateTime);

        AssignedUser model = AssignedUser(
          id: selectedUsersNameID,
          name: selectedUsersName,
          email: selectedUsersEmail,
          profilePicture: selectedUsersProfile,
        );
print("fghjk ${status??"pending".toLowerCase()}");
        context.read<LeadBloc>().add(CreateLeadFollow(
          leadId: widget.leadId,
          type: selectedFollowUpType.replaceAll('-', '').toLowerCase(),
          note: notes,
          status: (status ?? "pending").toLowerCase(),
          assignedTo: model,
          followupAt: formatted,
        ));
        _listenToClientBloc(context.read<LeadBloc>());
      } else {
        flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
        );
      }

  }


  void _onEditLeadsFollowUp(candidate) async {
    print("fghjkl $selectedUsersNameID");
    print("fghjkl $selectedFollowUpType");
    if (selectedUsersNameID != "" &&
        selectedFollowUpType != "" &&
        datePart != "") {

      AssignedUser model = AssignedUser(
          id: selectedUsersNameID,
          name: selectedUsersName,
          email: selectedUsersEmail,
          profilePicture: selectedUsersProfile);
      context.read<LeadBloc>().add(UpdateLeadFollowUp(
          id: widget.leadsModel!.id!,
          type: selectedFollowUpType.replaceAll('-', '').toLowerCase(),
          note: notes,
          status: (status ?? "pending").toLowerCase(),
          assignedTo: model,
          followupAt: "$datePart\T$timePart"));
      _listenToClientBloc(context.read<LeadBloc>());
    } else {
      flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleasefilltherequiredfield);
    }
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

                      // _refreshClientData();
                    } else {
                      router.pop();
                    }
                  },
                  title: widget.isCreate == true
                      ? AppLocalizations.of(context)!.createleadfollowups
                      : AppLocalizations.of(context)!.updateleadfollowups,
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
            _buildFormFields(isLightTheme),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return BlocConsumer<LeadBloc, LeadState>(
      listener: (context, state) {
        if (state is LeadCreateError) {
          flutterToastCustom(msg: state.errorMessage);
          context.read<LeadBloc>().add(LeadLists());
        }
        if (state is LeadError) {
          flutterToastCustom(msg: state.errorMessage);
          context.read<LeadBloc>().add(LeadLists());
        }
        if (state is LeadEditError) {
          flutterToastCustom(msg: state.errorMessage);
          context.read<LeadBloc>().add(LeadLists());
        }
        if (state is LeadCreateSuccess) {
          context.read<LeadBloc>().add(LeadLists());
          if (mounted) {
            Navigator.pop(context);
            // router.go('/notes');
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.createdsuccessfully,
                color: AppColors.primary);
          }
        } if (state is LeadEditFollowUpSuccess) {
          context.read<LeadBloc>().add(LeadLists());
          if (mounted) {
            Navigator.pop(context);
            // router.go('/notes');
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.updatedsuccessfully,
                color: AppColors.primary);
          }
        }
        if (state is LeadEditSuccess) {
          context.read<LeadBloc>().add(LeadLists());
          if (mounted) {
            Navigator.pop(context);
            // router.go('/notes');
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.updatedsuccessfully,
                color: AppColors.primary);
          }
        }
      },
      builder: (context, state) {
        print("LeadFollowUp State  $state");
        final isLoading =
            state is LeadCreateLoading || state is LeadEditSuccessLoading;
        return Padding(
          padding: EdgeInsets.only(bottom: 28.h),
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

  Widget _buildFormFields(isLightTheme) {
    print("ghbjklm, $notes");
    final unescape = HtmlUnescape();
    final displayText = unescape.convert(notes ?? "");
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleUserField(
          title: AppLocalizations.of(context)!.assignto,
          isRequired: true,
          isEditLeaveReq: widget.isCreate,
          userId: [selectedUsersNameID ?? 0],
          isCreate: widget.isCreate!,
          name: selectedUsersName,
          from: true,
          index: 0,
          onSelected: handleSingleUsersSelected,
        ),
        SizedBox(
          height: 15.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: DatePickerWidget(
            star: true,
            size: 12.sp,
            dateController: followupDateController,
            title: AppLocalizations.of(context)!.followupdate,
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
                storedDateTime =
                    DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate);

                // Optional: Print or use it elsewhere
                print('Stored DateTime: $storedDateTime');
                datePart = dateFormatConfirmed(selectedDate, context);
                timePart = DateFormat('hh:mm a').format(selectedDate);
print("ghjkl ${datePart}  ${timePart}");
                // Combine both
                followupDateController.text = '📅 $datePart 🕒 $timePart';
              }
            },
            isLightTheme: isLightTheme,
          ),
        ),

        SizedBox(
          height: 5.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: CustomText(
            text: AppLocalizations.of(context)!.followupdatedetail,
            color: Theme.of(context).colorScheme.textClrChange,
            size: 12.sp,
            fontWeight: FontWeight.w400,
            overflow: TextOverflow.ellipsis,
            softwrap: true,
            maxLines: 2,
          ),
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomListField(
          onStorageSelected: (String) {},
          title: "followupType",
          isRequired: true,
          name: selectedFollowUpType ,
          // typeName: "",
          onTypeSelected: (String t) {},
          onFollowUpTypeSelected: _handleMethodSelected,
          onSmtpEncryptionSelected: (String) {},
          onStatusSelected: (String) {},
          onrequestMethodSelected: (String) {},
        ),
        SizedBox(
          height: 5.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: CustomText(
            text: AppLocalizations.of(context)!.followupdatedetailcategories,
            color: Theme.of(context).colorScheme.textClrChange,
            size: 12.sp,
            fontWeight: FontWeight.w400,
            overflow: TextOverflow.ellipsis,
            softwrap: true,
            maxLines: 2,
          ),
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomListField(
          onStorageSelected: (String) {},
          title: "status",
          isRequired: false,
          name: status ?? "",
          // typeName: "",
          onTypeSelected: (String t) {},
          onFollowUpTypeSelected: (String t) {},
          onStatusSelected: _handleMethodSelectedStatus,
          onSmtpEncryptionSelected: (String) {},
          onrequestMethodSelected: (String) {},
        ),
        SizedBox(
          height: 15.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: CustomText(
            text: AppLocalizations.of(context)!.note,
            color: Theme.of(context).colorScheme.textClrChange,
            size: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: IntrinsicHeight(
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => NotesDescription(
                              title: "title",
                              description: notes ?? "",
                              onNoteSaved: (value) {
                                setState(() {
                                  notes = value;
                                });
                              },
                            )));
              },
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: 40.h, // Minimum height
                  // maxHeight is unlimited (will expand based on content)
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 5.h),
                  child: ExpandableHtmlNoteWidget(
                    text: displayText,
                    context: context,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: CustomText(
            text: AppLocalizations.of(context)!.notesdetail,
            color: Theme.of(context).colorScheme.textClrChange,
            size: 12.sp,
            fontWeight: FontWeight.w400,
            overflow: TextOverflow.ellipsis,
            softwrap: true,
            maxLines: 2,
          ),
        ),
        SizedBox(
          height: 30.h,
        ),
        // CustomTextFields(
        //   height: 114.h,
        //     title: AppLocalizations.of(context)!.note,
        //     hinttext: AppLocalizations.of(context)!.pleaseenternotes, controller: noteController,
        //     onSaved: (value) {},isLightTheme: isLightTheme)
        // QuillEditorPage()
      ],
    );
  }
}
