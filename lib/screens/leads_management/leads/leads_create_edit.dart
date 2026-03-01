import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../src/generated/i18n/app_localizations.dart';

import 'package:taskify/bloc/leads/leads_bloc.dart';
import 'package:taskify/bloc/leads/leads_state.dart';
import 'package:taskify/config/app_images.dart';
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
import '../../../utils/widgets/back_arrow.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/no_internet_screen.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../leave_request/widgets/single_userfield.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../widgets/custom_textfields/custom_textfield.dart';
import '../../widgets/validation.dart';
import '../widgets/lead_satge_list.dart';
import '../widgets/leads_source_list.dart';
import '../../../routes/routes.dart';
class CreateEditLeads extends StatefulWidget {
  final bool? isCreate;
  final LeadModel? leadsModel;
  const CreateEditLeads({super.key, this.isCreate, this.leadsModel});

  @override
  State<CreateEditLeads> createState() => _CreateEditLeadsState();
}

class _CreateEditLeadsState extends State<CreateEditLeads> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  bool? isLoading;


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
  String defaultCountryLocal="";





  String selectedLeadSource= '';
  int? selectedID;
  String selectedLeadStage= '';
  int? selectedLeadStageID;
  String selectedUsersName= '';
  int? selectedUsersNameID;
  String selectedUsersEmail = '';
  String selectedUsersProfile = '';

  LeadModel? currentLead;
  String? countryCodeNumber;
  String? countryCode;
  String? countryIsoCode;

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  void _handleLeadSourceSelected(String category, int catID) {
    setState(() {
      selectedLeadSource = category;
      selectedID = catID;
    });
  }
  void _handleLeadStageSelected(String category, int catID) {
    setState(() {
      selectedLeadStage = category;
      selectedLeadStageID = catID;
    });
  }  void handleSingleUsersSelected(String category, int catID,String email,String profile) {
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
    if (widget.leadsModel != null && widget.isCreate==false) {
      _initializeControllers();
    }else{
      defaultCountryLocal = defaultCountry;
    }
  }

  void _initializeControllers() {

    currentLead = widget.leadsModel!;
    defaultCountryLocal=currentLead!.countryIsoCode??
    "";
    selectedLeadSource=currentLead!.leadSource!;
    selectedID = currentLead!.leadSourceId;
    selectedLeadStage=currentLead!.leadStage!;
    selectedLeadStageID = currentLead!.leadStageId;
    selectedUsersName=currentLead!.assignedUser!.name!;
    selectedUsersNameID = currentLead!.assignedTo;
    firstNameController.text = currentLead!.firstName!;
    lastNameController.text = currentLead!.lastName!;
    emailController.text = currentLead!.email!;
    jobTitleController.text = currentLead!.jobTitle??"";
    industryController.text = currentLead!.industry??"";
    companyController.text = currentLead!.company??"";
    websiteController.text = currentLead!.website??"";
    linkedInController.text = currentLead!.linkedin??"";
    instagramController.text = currentLead!.instagram??"";
    facebookController.text = currentLead!.facebook??"";
    pinterestController.text = currentLead!.pinterest??"";
    cityController.text = currentLead!.city??"";
    stateController.text = currentLead!.state??"";
    zipCodeController.text = currentLead!.zip??"";
    countryController.text = currentLead!.country??"";
    countryCode = currentLead!.countryIsoCode??defaultCountry;
    countryCodeNumber=currentLead!.countryCode??defaultCountryCode;
    countryIsoCode = currentLead!.countryCode??defaultCountryCode;
    phoneController.text = currentLead!.phone!;


  }

  void _validateAndSubmitForm() {
    if (widget.isCreate == true) {
      _onCreateLeads();
    } else {
      _onEditLeads(currentLead!);
    }
  }

  void _onCreateLeads() {
    if (firstNameController.text.isNotEmpty && lastNameController.text.isNotEmpty&&companyController.text.isNotEmpty&&
        emailController.text.isNotEmpty&&
        selectedLeadStageID != null && selectedID != null&&
        selectedUsersNameID != null ) {
print("cdfvgbhjn $countryCode");
print("cdfvgbhjn $countryCodeNumber");

      context.read<LeadBloc>().add(CreateLead(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text,
        phone: phoneController.text,
        countryCode: countryCodeNumber??defaultCountryCode,
        countryIsoCode: countryCode??defaultCountry,
        leadSourceId: selectedID,
        leadSource: selectedLeadSource,
        leadStageId: selectedLeadStageID,
        leadStage: selectedLeadStage,
        assignedTo: selectedUsersNameID,
        assignedUser: selectedUsersName,
        jobTitle: jobTitleController.text,
        industry: industryController.text,
        company: companyController.text,
        website: websiteController.text,
        linkedin: linkedInController.text,
        instagram: instagramController.text,
        facebook: facebookController.text,
        pinterest: pinterestController.text,
        city: cityController.text,
        state: stateController.text,
        zip: zipCodeController.text,
         country: countryIsoCode,

      ));
    } else {
      flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleasefilltherequiredfield);
    }
  }

  void _onEditLeads(candidate) async {
    if (firstNameController.text.isNotEmpty && lastNameController.text.isNotEmpty&&companyController.text.isNotEmpty &&
        emailController.text.isNotEmpty&&
        selectedLeadStageID != null &&selectedID != null &&
        selectedUsersNameID != null ) {
      print("bhjvn${countryCode}");
      context.read<LeadBloc>().add(UpdateLead(
        id: widget.leadsModel!.id!,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text,
        phone: phoneController.text,
        countryCode: countryCodeNumber,
        countryIsoCode: countryCode,
        leadSourceId: selectedID,
        leadSource: selectedLeadSource,
        leadStageId: selectedLeadStageID,
        leadStage: selectedLeadStage,
        assignedTo: selectedUsersNameID,
        assignedUser: selectedUsersName,
        jobTitle: jobTitleController.text,
        industry: industryController.text,
        company: companyController.text,
        website: websiteController.text,
        linkedin: linkedInController.text,
        instagram: instagramController.text,
        facebook: facebookController.text,
        pinterest: pinterestController.text,
        city: cityController.text,
        state: stateController.text,
        zip: zipCodeController.text,
        country: countryIsoCode,

      ));
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
                      ? AppLocalizations.of(context)!.createlead
                      : AppLocalizations.of(context)!.editlead,
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
          context.read<LeadBloc>().add( LeadLists());
        }
        if (state is LeadError) {
          flutterToastCustom(msg: state.errorMessage);
          context.read<LeadBloc>().add( LeadLists());
        }
        if (state is LeadEditError) {
          flutterToastCustom(msg: state.errorMessage);
          context.read<LeadBloc>().add( LeadLists());
        }
        if (state is LeadCreateSuccess) {
          context.read<LeadBloc>().add( LeadLists());
          if (mounted) {
            Navigator.pop(context);
            // router.go('/notes');
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.createdsuccessfully,
                color: AppColors.primary);
          }
        }
        if (state is LeadEditSuccess) {
          context.read<LeadBloc>().add( LeadLists());
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
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _personalDetails(isLightTheme),
        _professionalDetails(isLightTheme),
        _socialLinks(isLightTheme),
        _addressDetails(isLightTheme),
      ],
    );
  }
Widget _personalDetails(isLightTheme){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Container(
                // color: Colors.red,
                child: Image.asset(AppImages.personalImage, height: 20.h, width: 20.w),
              ),
              SizedBox(width: 10.w,),
              CustomText(
                text: AppLocalizations.of(context)!.personaldetails,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 20.sp,
                fontWeight: FontWeight.w900,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 15.h,
        ),
        // Divider(),
        CustomTextFields(
          title: AppLocalizations.of(context)!.firstname,
          hinttext: AppLocalizations.of(context)!.pleaseenterfirstrname,
          controller: firstNameController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: true,
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          title: AppLocalizations.of(context)!.lastname,
          hinttext: AppLocalizations.of(context)!.pleaseenterlastrname,
          controller: lastNameController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: true,
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          title: AppLocalizations.of(context)!.email,
          hinttext: AppLocalizations.of(context)!.email,
          controller: emailController,
          keyboardType: TextInputType.text,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: true,
        ),
        SizedBox(
          height: 15.h,
        ),
        _buildPhoneNumberField(true),
        SizedBox(
          height: 15.h,
        ),
        LeadSourceList(
          isRequired: true,
          isCreate: widget.isCreate!,
          leadSource:selectedID,
          name: selectedLeadSource ,
          onSelected: _handleLeadSourceSelected,
        ),
        SizedBox(
          height: 15.h,
        ),
        LeadStageList(
          isRequired: true,
          isCreate: widget.isCreate!,
          LeadStage:selectedLeadStageID,
          name: selectedLeadStage ,
          onSelected: _handleLeadStageSelected,
        ),
        SizedBox(
          height: 15.h,
        ),
        SingleUserField(
          title: AppLocalizations.of(context)!.assignto,
          isRequired: true,
          isEditLeaveReq: widget.isCreate,
          userId: [selectedUsersNameID??0],
          isCreate: widget.isCreate!,
          name: selectedUsersName,
          from: true,
          index: 0,
          onSelected: handleSingleUsersSelected,
        ),
      ],
    );
}
Widget _professionalDetails(isLightTheme){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 20.h,),
        // Divider(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Container(
                // color: Colors.red,
                child: Image.asset(AppImages.professionalImage,  height: 20.h, width: 20.w),
              ),
              SizedBox(width: 10.w,),
              CustomText(
                text: AppLocalizations.of(context)!.professiondetails,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 20.sp,
                fontWeight: FontWeight.w900,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          title: AppLocalizations.of(context)!.jobtitle,
          hinttext: AppLocalizations.of(context)!.jobtitle,
          controller: jobTitleController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: false,
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          title: AppLocalizations.of(context)!.industry,
          hinttext: AppLocalizations.of(context)!.industry,
          controller: industryController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: false,
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          title: AppLocalizations.of(context)!.company,
          hinttext: AppLocalizations.of(context)!.company,
          controller: companyController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: true,
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          title: AppLocalizations.of(context)!.website,
          hinttext: AppLocalizations.of(context)!.website,
          controller: websiteController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: false,
        ),
        SizedBox(
          height: 15.h,
        )

      ],
    );
}
Widget _socialLinks(isLightTheme){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 20.h,),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Container(
                // color: Colors.red,
                child: Image.asset(AppImages.socialImage,  height: 20.h, width: 20.w),
              ),
              SizedBox(width: 10.w,),
              CustomText(
                text: AppLocalizations.of(context)!.sociallinks,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 20.sp,
                fontWeight: FontWeight.w900,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          title: AppLocalizations.of(context)!.linkedin,
          hinttext: AppLocalizations.of(context)!.linkedin,
          controller: linkedInController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: false,
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          title: AppLocalizations.of(context)!.instagram,
          hinttext: AppLocalizations.of(context)!.instagram,
          controller: instagramController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: false,
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          title: AppLocalizations.of(context)!.facebook,
          hinttext: AppLocalizations.of(context)!.facebook,
          controller: facebookController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: false,
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          title: AppLocalizations.of(context)!.pinterest,
          hinttext: AppLocalizations.of(context)!.pinterest,
          controller: pinterestController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: false,
        ),
        SizedBox(
          height: 15.h,
        ),

      ],
    );
}
Widget _addressDetails(isLightTheme){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 20.h,),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Container(
                // color: Colors.red,
                child: Image.asset(AppImages.addressImage, height: 20.h, width: 20.w),
              ),
              SizedBox(width: 10.w,),
              CustomText(
                text: AppLocalizations.of(context)!.address,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 20.sp,
                fontWeight: FontWeight.w900,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          title: AppLocalizations.of(context)!.city,
          hinttext: AppLocalizations.of(context)!.city,
          controller: cityController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: false,
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          title: AppLocalizations.of(context)!.state,
          hinttext: AppLocalizations.of(context)!.state,
          controller: stateController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: false,
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          title: AppLocalizations.of(context)!.zipcode,
          hinttext: AppLocalizations.of(context)!.zipcode,
          controller: zipCodeController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: false,
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          title: AppLocalizations.of(context)!.country,
          hinttext: AppLocalizations.of(context)!.country,
          controller: countryController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: false,
        ),
        SizedBox(
          height: 15.h,
        )

      ],
    );
}
  Widget _buildPhoneNumberField(isRequired) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.phonenumber,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16.sp,
                fontWeight: FontWeight.w700,
              ),
              if (isRequired)
                const Text(
                  " *",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        Container(
          height: 40.h,
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.greyColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  width: 70.w,
                  child: CountryCodePicker(
                    dialogBackgroundColor:
                        Theme.of(context).colorScheme.containerDark,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                    padding: EdgeInsets.zero,
                    showFlag: true,
                    onChanged: (country) {
                      setState(() {

                        countryCodeNumber = country.dialCode;
                        countryIsoCode = country.name;
                        countryCode = country.code;
                        print("countryCodeNumber $countryCodeNumber");
                        print("countryIsoCode $countryIsoCode");
                        print("countryCode $countryCode");
                      });
                    },
                    initialSelection: defaultCountryLocal !="" ?defaultCountryLocal :defaultCountry ,
                    showCountryOnly: false,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                  ),
                ),
              ),
              Container(
                color: AppColors.greyForgetColor,
                width: 0.5.w,
              ),
              SizedBox(width: 10.w),
              Expanded(
                flex: 6,
                child: Container(
                  padding: EdgeInsets.zero,
                  child: TextFormField(
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                    controller: phoneController,
                    keyboardType: TextInputType.number,
                    validator: (val) => StringValidation.validateField(
                      val!,
                      AppLocalizations.of(context)!.required,
                    ),
                    decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .pleaseenterphonenumber,
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: (40.h - 17.sp) / 2,
                          horizontal: 10.w,
                        )),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
