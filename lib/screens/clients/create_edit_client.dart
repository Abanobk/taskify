import 'package:flutter/material.dart';
import '../../../src/generated/i18n/app_localizations.dart';

import 'package:image_picker/image_picker.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:taskify/bloc/permissions/permissions_event.dart';
import 'package:taskify/data/model/clients/all_client_model.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../bloc/client_id/clientid_bloc.dart';
import '../../bloc/client_id/clientid_event.dart';
import '../../bloc/clients/client_bloc.dart';
import '../../bloc/clients/client_event.dart';
import '../../bloc/clients/client_state.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/project/project_bloc.dart';
import '../../bloc/project/project_event.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import 'dart:io';
import '../../config/constants.dart';
import '../../data/localStorage/hive.dart';
import '../../data/repositories/Profile/profile_repo.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_switch.dart';
import '../../utils/widgets/custom_text.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/no_internet_screen.dart';
import '../../utils/widgets/toast_widget.dart';
import '../widgets/custom_date.dart';
import '../widgets/custom_cancel_create_button.dart';
import '../widgets/custom_textfields/custom_textfield.dart';
import '../widgets/validation.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class CreateEditClientScreen extends StatefulWidget {
  final bool? isCreate;
  final bool? fromDetail;
  final int? index;
  final AllClientModel? clientModel;
  const CreateEditClientScreen({
    super.key,
    this.isCreate,
    this.index,
    this.clientModel,
    this.fromDetail,
  });

  @override
  State<CreateEditClientScreen> createState() => _CreateEditClientScreenState();
}

class _CreateEditClientScreenState extends State<CreateEditClientScreen> {
  // State variables
  AllClientModel? currentClient;
  String? countryCode;
  String? countryIsoCode;
  int? _selectedStateIndex = 0;
  int? _selectedEmailVeriIndex = 0;
  bool? isLoading;
  int? clientId;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isInternalPurpose = false;
  bool? hasPermission;
  bool? hasAllDataAccess;
  String? role;
  File? _image;
  String? filepath;
  DateTime? selectedDateStarts;
  String? dob;
  String? doj;
  
  // Form controllers
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController dojController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController conpasswordController = TextEditingController();
  final TextEditingController addrerssController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController zipcodeController = TextEditingController();

  // Focus nodes
  final FocusNode phoneFocus = FocusNode();
  final FocusNode firstnameFocus = FocusNode();
  final FocusNode lastnameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode addressFocus = FocusNode();
  final FocusNode cityFocus = FocusNode();
  final FocusNode companyFocus = FocusNode();
  final FocusNode stateFocus = FocusNode();
  final FocusNode countryFocus = FocusNode();
  final FocusNode passwardFocus = FocusNode();
  final FocusNode conpasswardFocus = FocusNode();
  final FocusNode dobFocus = FocusNode();
  final FocusNode dojFocus = FocusNode();
  final FocusNode zipFocus = FocusNode();

  // Connectivity
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  ConnectivityResult connectivityCheck = ConnectivityResult.none;

  int? selectedRoleId;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
    _initializePermissions();
    _initializeClientData();
  }

  void _initializeConnectivity() {
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() => _connectionStatus = results);
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() => _connectionStatus = value);
        });
      }
    });
  }

  void _initializePermissions() {
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    _getPermission();
    getRoleAndHasDataAccess();
  }

  void _initializeClientData() {
    if (widget.isCreate == false && widget.clientModel != null) {
      _setupEditMode();
    }
  }

  void _setupEditMode() {
    clientId = widget.clientModel!.id;
    currentClient = widget.clientModel!;
    isInternalPurpose = currentClient!.internalPurpose == 1;
    
    _initializeControllers();
    _initializeDates();
  }

  void _initializeControllers() {
    firstNameController.text = currentClient!.firstName ?? '';
    lastNameController.text = currentClient!.lastName ?? '';
    emailController.text = currentClient!.email ?? '';
    phoneController.text = currentClient!.phone ?? '';
    roleController.text = currentClient!.role ?? '';
    addrerssController.text = currentClient!.address ?? '';
    cityController.text = currentClient!.city ?? '';
    stateController.text = currentClient!.state ?? '';
    countryController.text = currentClient!.country ?? '';
    companyController.text = currentClient!.company ?? '';
    zipcodeController.text = currentClient!.zip ?? '';
    filepath = currentClient!.profile;
  }

  void _initializeDates() {
    if (currentClient!.dob != null && currentClient!.dob!.isNotEmpty) {
      final parsedDate = parseDateStringFromApi(currentClient!.dob!);
      dobController.text = dateFormatConfirmed(parsedDate, context);
    }
    if (currentClient!.doj != null && currentClient!.doj!.isNotEmpty) {
      final parsedDate = parseDateStringFromApi(currentClient!.doj!);
      dojController.text = dateFormatConfirmed(parsedDate, context);
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _disposeControllers();
    _disposeFocusNodes();
    super.dispose();
  }

  void _disposeControllers() {
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    dobController.dispose();
    dojController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    conpasswordController.dispose();
    addrerssController.dispose();
    companyController.dispose();
    cityController.dispose();
    roleController.dispose();
    stateController.dispose();
    countryController.dispose();
    zipcodeController.dispose();
  }

  void _disposeFocusNodes() {
    phoneFocus.dispose();
    firstnameFocus.dispose();
    lastnameFocus.dispose();
    emailFocus.dispose();
    addressFocus.dispose();
    cityFocus.dispose();
    companyFocus.dispose();
    stateFocus.dispose();
    countryFocus.dispose();
    passwardFocus.dispose();
    conpasswardFocus.dispose();
    dobFocus.dispose();
    dojFocus.dispose();
    zipFocus.dispose();
  }

  // Helper Methods
  void _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (widget.isCreate == false) {
        await ProfileRepo().updateProfile(
          type: "client",
          profile: File(pickedFile.path),
          id: widget.clientModel!.id!,
        );
      }
      setState(() {
        filepath = pickedFile.name;
        _image = File(pickedFile.path);
      });
    }
  }

  void _handleDateSelection(DateTime selectedDate, bool isDob) {
    setState(() {
      selectedDateStarts = selectedDate;
      if (isDob) {
        dob = dateFormatConfirmedToApi(selectedDateStarts!);
        dobController.text = dateFormatConfirmed(selectedDateStarts!, context);
      } else {
        doj = dateFormatConfirmedToApi(selectedDateStarts!);
        dojController.text = dateFormatConfirmed(selectedDateStarts!, context);
      }
    });
  }

  void _refreshClientData() {
    BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask(clientId: []));
    BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList(clientId: [widget.clientModel!.id!]));
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    BlocProvider.of<ClientidBloc>(context).add(ClientIdListId(widget.clientModel!.id!));
    BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
  }

  // Form Validation Methods
  bool _validateRequiredFields() {
    return firstNameController.text.isNotEmpty &&
           lastNameController.text.isNotEmpty &&
           emailController.text.isNotEmpty &&
           (widget.isCreate == true ? passwordController.text.isNotEmpty : true);
  }

  bool _isValidEmail() {
    return emailController.text.contains('@');
  }

  bool _doPasswordsMatch() {
    return passwordController.text == conpasswordController.text;
  }

  void _validateAndSubmitForm() {
    if (!_validateRequiredFields()) {
      flutterToastCustom(msg: AppLocalizations.of(context)!.pleasefilltherequiredfield);
      return;
    }

    if (!_isValidEmail()) {
      flutterToastCustom(msg: AppLocalizations.of(context)!.pleaseenteravalidemail);
      return;
    }

    if (widget.isCreate == true && !_doPasswordsMatch()) {
      flutterToastCustom(msg: AppLocalizations.of(context)!.passworddomntmatch);
      return;
    }

    if (widget.isCreate == true) {
      onCreateClient();
    } else {
      onUpdateClient(currentClient!);
    }
  }

  // Client Operations
  void onCreateClient() {
    isLoading = true;
    final newClient = _buildClientModel(isCreate: true);
    context.read<ClientBloc>().add(ClientsCreated(newClient, _image, filepath));
    _listenToClientBloc(context.read<ClientBloc>());
  }

  void onUpdateClient(AllClientModel currentClient) {
    isLoading = true;
    final updatedUser = currentClient.copyWith(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      role: selectedRoleId?.toString(),
      email: emailController.text,
      phone: phoneController.text,
      countryCode: phoneController.text.isNotEmpty ? (countryCode ?? defaultCountryCode) : "",
      password: passwordController.text,
      passwordConfirmation: conpasswordController.text,
      address: addrerssController.text,
      dob: dob,
      company: companyController.text,
      internalPurpose: isInternalPurpose ? 1 : 0,
      doj: doj,
      city: cityController.text,
      state: stateController.text,
      country: countryController.text,
      zip: zipcodeController.text,
      profile: null,
      status: _selectedStateIndex ?? 0,
      emailVerificationMailSent: _selectedEmailVeriIndex ?? 0
    );

    BlocProvider.of<ClientBloc>(context).add(UpdateClients(updatedUser));
    _listenToClientBloc(context.read<ClientBloc>());
  }

  AllClientModel _buildClientModel({bool isCreate = false}) {
    return AllClientModel(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      company: companyController.text,
      email: emailController.text,
      password: isCreate ? passwordController.text : null,
      passwordConfirmation: isCreate ? conpasswordController.text : null,
      address: addrerssController.text,
      role: selectedRoleId?.toString(),
      countryCode: phoneController.text.isEmpty ? "" : (countryCode ?? defaultCountryCode),
      countryIsoCode: countryIsoCode,
      city: cityController.text,
      internalPurpose: isInternalPurpose ? 1 : 0,
      doj: doj,
      dob: dob,
      state: stateController.text,
      country: countryController.text,
      zip: zipcodeController.text,
      phone: phoneController.text,
      profile: null,
      status: _selectedStateIndex ?? 0,
      emailVerificationMailSent: _selectedEmailVeriIndex ?? 0
    );
  }

  void _listenToClientBloc(ClientBloc bloc) {
    bloc.stream.listen((state) {
      if (state is ClientSuccessCreate) {
        _handleClientSuccess();
      } else if (state is ClientCreateError) {
        _handleClientError(state.errorMessage);
      } else if (state is ClientEditSuccess) {
        _handleClientEditSuccess();
      } else if (state is ClientEditError) {
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
      context.read<ClientBloc>().add(ClientList());
      Navigator.pop(context);
    }
  }

  void _handleClientEditSuccess() {
    if (mounted) {
      isLoading = false;
      context.read<ClientBloc>().add(ClientList());
      _refreshClientData();
      Navigator.pop(context);
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.updatedsuccessfully,
        color: AppColors.primary
      );
    }
  }

  void _handleClientError(String errorMessage) {
    isLoading = false;
    flutterToastCustom(msg: errorMessage);
  }

  // UI Components
  Widget _buildProfileImageField(bool isLightTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppLocalizations.of(context)!.profilePicture),
        SizedBox(height: 5.h),
        _buildFilePickerContainer(isLightTheme),
        SizedBox(height: 15.w),
        _buildProfileAvatar(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: CustomText(
        text: title,
        color: Theme.of(context).colorScheme.textClrChange,
        size: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildFilePickerContainer(bool isLightTheme) {
    return Container(
      height: 40.h,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            _buildFilePickerButton(isLightTheme),
            SizedBox(width: 15.w),
            Container(
              color: AppColors.greyForgetColor,
              height: 40.h,
              width: 0.5.w,
            ),
            SizedBox(width: 15.w),
            _buildFileNameText(isLightTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePickerButton(bool isLightTheme) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: _pickImage,
      child: CustomText(
        text: AppLocalizations.of(context)!.choosefile,
        fontWeight: FontWeight.w400,
        size: 14.sp,
        color: Theme.of(context).colorScheme.textClrChange,
      ),
    );
  }

  Widget _buildFileNameText(bool isLightTheme) {
    return SizedBox(
      width: 200.w,
      child: CustomText(
        overflow: TextOverflow.ellipsis,
        text: filepath ?? AppLocalizations.of(context)!.nofilechosen,
        fontWeight: FontWeight.w400,
        size: 14.sp,
        color: Theme.of(context).colorScheme.textClrChange,
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: CircleAvatar(
        backgroundColor: Colors.grey,
        radius: 25,
        backgroundImage: _getProfileImage(),
        child: _buildDefaultAvatar(),
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (filepath == null) return null;
    return filepath!.startsWith("http")
        ? NetworkImage(filepath!) as ImageProvider
        : FileImage(File(_image!.path)) as ImageProvider;
  }

  Widget? _buildDefaultAvatar() {
    if (filepath != null || _image != null) return null;
    return Icon(
      Icons.person,
      size: 25.sp,
      color: Colors.grey.shade200,
    );
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
                if (widget.fromDetail == true && widget.isCreate == false) {
                  _refreshClientData();
                } else {
                  router.pop(context);
                }
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
                    if (widget.fromDetail == true && widget.isCreate == false) {
                      _refreshClientData();
                    } else {
                      router.pop(context);
                    }
                  },
                  title: widget.isCreate == true
                      ? AppLocalizations.of(context)!.createclient
                      : AppLocalizations.of(context)!.editclient,
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
            _buildInternalPurposeSwitch(),
            SizedBox(height: 15.h),
            _buildFormFields(isLightTheme),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields(bool isLightTheme) {
    return Column(
      children: [
        _buildTextField(
          title: AppLocalizations.of(context)!.firstname,
          hint: AppLocalizations.of(context)!.pleaseenterfirstrname,
          controller: firstNameController,
          focusNode: firstnameFocus,
          nextFocus: lastnameFocus,
          isRequired: true,
        ),
        SizedBox(height: 15.h),
        _buildTextField(
          title: AppLocalizations.of(context)!.lastname,
          hint: AppLocalizations.of(context)!.pleaseenterlastrname,
          controller: lastNameController,
          focusNode: lastnameFocus,
          nextFocus: emailFocus,
          isRequired: true,
        ),
        SizedBox(height: 15.h),
        _buildTextField(
          title: AppLocalizations.of(context)!.email,
          hint: AppLocalizations.of(context)!.pleaseenteremail,
          controller: emailController,
          focusNode: emailFocus,
          nextFocus: phoneFocus,
          isRequired: true,
        ),
        SizedBox(height: 15.h),
        _buildPhoneNumberField(),
        SizedBox(height: 15.h),
        _buildPasswordFields(isLightTheme),
        SizedBox(height: 15.h),
        _buildDatePickerRow(),
        SizedBox(height: 15.h),
        _buildAddressFields(isLightTheme),
        SizedBox(height: 15.h),
        _buildProfileImageField(isLightTheme),
        SizedBox(height: 15.h),
        _buildCompanyField(isLightTheme),
        SizedBox(height: 15.h),
        _buildLocationFields(isLightTheme),
        SizedBox(height: 15.h),
        if (hasAllDataAccess == true && role == "admin") ...[
          _buildUserStatusToggle(),
          SizedBox(height: 15.h),
          _buildEmailVerificationToggle(),
          SizedBox(height: 20.h),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required String title,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    bool isRequired = false,
    bool isPassword = false,
  }) {
    return CustomTextFields(
      title: title,
      hinttext: hint,
      controller: controller,
      onSaved: (value) {},
      onFieldSubmitted: (value) {
        _fieldFocusChange(context, focusNode, nextFocus);
      },
      isLightTheme: Theme.of(context).brightness == Brightness.light,
      isRequired: isRequired,
      isPassword: isPassword,
    );
  }

  Widget _buildPasswordFields(bool isLightTheme) {
    return Column(
      children: [
        if (widget.isCreate == true) ...[
          _buildTextField(
            title: AppLocalizations.of(context)!.password,
            hint: AppLocalizations.of(context)!.pleaseenterpassword,
            controller: passwordController,
            focusNode: passwardFocus,
            nextFocus: conpasswardFocus,
            isRequired: true,
            isPassword: true,
          ),
          SizedBox(height: 15.h),
          _buildTextField(
            title: AppLocalizations.of(context)!.conPassword,
            hint: AppLocalizations.of(context)!.pleaseenterconpassword,
            controller: conpasswordController,
            focusNode: conpasswardFocus,
            nextFocus: addressFocus,
            isRequired: true,
            isPassword: true,
          ),
        ],
      ],
    );
  }

  Widget _buildAddressFields(bool isLightTheme) {
    return Column(
      children: [
        _buildTextField(
          title: AppLocalizations.of(context)!.address,
          hint: AppLocalizations.of(context)!.pleaseenteraddress,
          controller: addrerssController,
          focusNode: addressFocus,
          nextFocus: cityFocus,
        ),
      ],
    );
  }

  Widget _buildCompanyField(bool isLightTheme) {
    return _buildTextField(
      title: AppLocalizations.of(context)!.company,
      hint: AppLocalizations.of(context)!.pleaseentercompanyname,
      controller: companyController,
      focusNode: companyFocus,
      nextFocus: stateFocus,
    );
  }

  Widget _buildLocationFields(bool isLightTheme) {
    return Column(
      children: [
        _buildTextField(
          title: AppLocalizations.of(context)!.state,
          hint: AppLocalizations.of(context)!.pleaseenterstate,
          controller: stateController,
          focusNode: stateFocus,
          nextFocus: countryFocus,
        ),
        SizedBox(height: 15.h),
        _buildTextField(
          title: AppLocalizations.of(context)!.city,
          hint: AppLocalizations.of(context)!.pleaseentercity,
          controller: cityController,
          focusNode: cityFocus,
          nextFocus: companyFocus,
        ),
        SizedBox(height: 15.h),
        _buildTextField(
          title: AppLocalizations.of(context)!.country,
          hint: AppLocalizations.of(context)!.pleaseentercountry,
          controller: countryController,
          focusNode: countryFocus,
          nextFocus: zipFocus,
        ),
        SizedBox(height: 15.h),
        _buildTextField(
          title: AppLocalizations.of(context)!.zipcode,
          hint: AppLocalizations.of(context)!.pleaseenterzipcode,
          controller: zipcodeController,
          focusNode: zipFocus,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return BlocBuilder<ClientBloc, ClientState>(
      builder: (context, state) {
        final isLoading = state is ClientLoadingCreate || state is ClientLoadingEdit;
        return CreateCancelButtom(
          isLoading: isLoading,
          isCreate: widget.isCreate,
          onpressCancel: () => Navigator.pop(context),
          onpressCreate: () => _validateAndSubmitForm(),
        );
      },
    );
  }

  Future<void> _getPermission() async {
    hasPermission = await HiveStorage.getHasAllDataAccess();
  }

  Future<void> getRoleAndHasDataAccess() async {
    role = await HiveStorage.getRole();
    hasAllDataAccess = await HiveStorage.getAllDataAccess();
  }

  Widget _buildInternalPurposeSwitch() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Row(
        children: [
          IsCustomSwitch(
            isCreate: widget.isCreate,
            status: isInternalPurpose,
            onStatus: (status) => setState(() => isInternalPurpose = status),
          ),
          SizedBox(width: 20.w),
          CustomText(
            text: AppLocalizations.of(context)!.isInternamPurpose,
            fontWeight: FontWeight.w400,
            size: 12.sp,
            color: Theme.of(context).colorScheme.textClrChange,
          )
        ],
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: CustomText(
            text: AppLocalizations.of(context)!.phonenumber,
            color: Theme.of(context).colorScheme.textClrChange,
            size: 16.sp,
            fontWeight: FontWeight.w700,
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
                    dialogBackgroundColor: Theme.of(context).colorScheme.containerDark,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                    padding: EdgeInsets.zero,
                    showFlag: true,
                    onChanged: (country) {
                      setState(() {
                        countryCode = country.dialCode;
                        countryIsoCode = country.name;
                      });
                    },
                    initialSelection: defaultCountry,
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
                      hintText: AppLocalizations.of(context)!.pleaseenterphonenumber,
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
                      )
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: DatePickerWidget(
              dateController: dobController,
              title: AppLocalizations.of(context)!.dob,
              onTap: () async {
                final DateTime? dateTime = await showOmniDateTimePicker(
                  lastDate: DateTime.now(),
                  firstDate: DateTime(1910),
                  context: context,
                  type: OmniDateTimePickerType.date,
                  initialDate: selectedDateStarts ?? DateTime.now(),
                  isShowSeconds: false,
                  barrierColor: Theme.of(context).colorScheme.containerDark
                );
                if (dateTime != null) {
                  _handleDateSelection(dateTime, true);
                }
              },
              isLightTheme: Theme.of(context).brightness == Brightness.light,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            flex: 3,
            child: DatePickerWidget(
              dateController: dojController,
              title: AppLocalizations.of(context)!.doj,
              onTap: () async {
                final DateTime? dateTime = await showOmniDateTimePicker(
                  barrierDismissible: true,
                  context: context,
                  type: OmniDateTimePickerType.date,
                  initialDate: selectedDateStarts ?? DateTime.now(),
                  isShowSeconds: false,
                  barrierColor: Theme.of(context).colorScheme.containerDark
                );
                if (dateTime != null) {
                  _handleDateSelection(dateTime, false);
                }
              },
              isLightTheme: Theme.of(context).brightness == Brightness.light,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildUserStatusToggle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: CustomText(
                  text: AppLocalizations.of(context)!.status,
                  color: Theme.of(context).colorScheme.textClrChange,
                  size: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: CustomText(
                  text: AppLocalizations.of(context)!.ifDeactivate,
                  color: AppColors.greyColor,
                  size: 8.sp,
                  maxLines: 2,
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        Container(
          height: 40.h,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.greyColor),
            color: Theme.of(context).colorScheme.containerDark,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              Theme.of(context).brightness == Brightness.light
                ? MyThemes.lightThemeShadow
                : MyThemes.darkThemeShadow,
            ]
          ),
          child: ToggleSwitch(
            cornerRadius: 11,
            activeBgColor: const [AppColors.primary],
            inactiveBgColor: Theme.of(context).colorScheme.containerDark,
            minHeight: 40,
            minWidth: double.infinity,
            initialLabelIndex: _selectedStateIndex,
            totalSwitches: 2,
            labels: const ['Deactive', 'Active'],
            onToggle: (index) {
              if (hasPermission == true) {
                setState(() {
                  _selectedStateIndex = index ?? 0;
                });
              }
            },
          )
        )
      ],
    );
  }

  Widget _buildEmailVerificationToggle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: CustomText(
            text: AppLocalizations.of(context)!.requireEmailVerification,
            color: Theme.of(context).colorScheme.textClrChange,
            size: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 5.h),
        Container(
          height: 40.h,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.greyColor),
            color: Theme.of(context).colorScheme.containerDark,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              Theme.of(context).brightness == Brightness.light
                ? MyThemes.lightThemeShadow
                : MyThemes.darkThemeShadow,
            ]
          ),
          child: Padding(
            padding: const EdgeInsets.all(0.1),
            child: ToggleSwitch(
              cornerRadius: 12,
              activeBgColor: const [AppColors.primary],
              inactiveBgColor: Theme.of(context).colorScheme.containerDark,
              minHeight: 40,
              minWidth: double.infinity / 2,
              initialLabelIndex: _selectedEmailVeriIndex,
              totalSwitches: 2,
              labels: const ['No', 'Yes'],
              onToggle: (index) {
                if (hasPermission == true) {
                  setState(() {
                    _selectedEmailVeriIndex = index ?? 1;
                  });
                }
              },
            ),
          )
        )
      ],
    );
  }
}
