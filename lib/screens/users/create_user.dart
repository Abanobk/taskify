import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../bloc/project/project_bloc.dart';
import '../../bloc/project/project_event.dart';
import '../../bloc/roles/role_bloc.dart';
import '../../bloc/roles/role_event.dart';

import 'package:taskify/utils/widgets/toast_widget.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'dart:io';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';
import '../../bloc/user_id/userid_bloc.dart';
import '../../bloc/user_id/userid_event.dart';
import '../../config/constants.dart';
import '../../data/localStorage/hive.dart';
import '../../data/model/user_model.dart';
import '../../data/repositories/Profile/profile_repo.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_text.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/no_internet_screen.dart';
import '../widgets/custom_date.dart';
import '../widgets/custom_cancel_create_button.dart';

import '../widgets/custom_toast.dart';
import '../widgets/custom_textfields/custom_textfield.dart';
import '../widgets/role_field.dart';
import '../widgets/validation.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class CreateUserScreen extends StatefulWidget {
  final bool? isCreate;
  final bool? fromDetail;
  final List<User>? user;
  final User? userModel;

  const CreateUserScreen({
    super.key,
    this.isCreate,
    this.fromDetail,
    this.userModel,
    this.user,
  });

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  User? currentUser;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController dojController = TextEditingController();
  TextEditingController conpasswordController = TextEditingController();
  TextEditingController addrerssController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController zipcodeController = TextEditingController();
  TextEditingController startsController = TextEditingController();
  TextEditingController endController = TextEditingController();

  File? _image;
  String? filepath;
  String initialCountry = defaultCountry;
  PhoneNumber number = PhoneNumber(isoCode: defaultCountry);
  String? formatteddobDate;
  String? formatteddojDate;
  DateTime? selectedDobDate;
  DateTime? selectedDojDate;
  String? selectedLabel;
  String? selectedemailLabel;
  int? stateSelectedIndex = 1;
  int? emailSelectedIndex;
  String? fromDate;
  String? toDate;
  bool? isLoading;
  String? selectedRoleName;
  int? selectedRoleId;
  String? formattedDoj;
  String? formattedDob;

  DateTime? selectedDateStarts;
  DateTime? selectedDateEnds;

  String selectedCategory = '';
  bool? hasPermission;
  String? countryCode;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void handleStatusSelected(String category, int catId) {
    setState(() {
      selectedRoleName = category;
      selectedRoleId = catId;
    });

  }

  List<Color> statusColor = [
    Colors.orange,
    Colors.lightBlueAccent,
    Colors.deepPurpleAccent,
    Colors.red
  ];
  FocusNode? phoneFocus,
      emailFocus,
      lastnameFocus,
      firstnameFocus,
      addressFocus,
      cityFocus,
      companyFocus,
      stateFocus,
      countryFocus,
      passwardFocus,
      conpasswardFocus,
      dobFocus,
      dojFocus,
      zipFocus = FocusNode();

  Future<void> _pickImage() async {

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (widget.isCreate != true) {
        await ProfileRepo().updateProfile(
            type: "user",
            profile: File(pickedFile.path),
            id: widget.userModel!.id); // Save the selected image
      }
      setState(() {
        filepath = pickedFile.name;
        _image = File(pickedFile.path);

      });
    } else {

    }
  }

  void _onCreateUser() {


    if (lastNameController.text.isNotEmpty &&
        firstNameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        conpasswordController.text.isNotEmpty &&
        selectedRoleId != null &&
        emailController.text.isNotEmpty) {
      if (!emailController.text.contains('@')) {
        flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleaseenteravalidemail,
        );
      }
      if (passwordController.text.length < 6) {
        flutterToastCustom(
          msg: AppLocalizations.of(context)!.passwordtooshort,
        );
      } else if (passwordController.text != conpasswordController.text) {
        flutterToastCustom(
            msg: AppLocalizations.of(context)!.passworddomntmatch);
      }
      Map<String, dynamic> userUpdates = {};
      userUpdates['firstName'] = firstNameController.text;
      userUpdates['lastName'] = lastNameController.text;
      userUpdates['role'] =
          selectedRoleId != null && selectedRoleId.toString().isNotEmpty
              ? selectedRoleId.toString()
              : widget.userModel!.roleId!.toString();
      userUpdates['email'] = emailController.text;
      userUpdates['phone'] = phoneController.text;
      userUpdates['countryCode'] = countryCode ?? defaultCountryCode;
      userUpdates['password'] = passwordController.text;
      userUpdates['passwordConfirmation'] = conpasswordController.text;
      userUpdates['dob'] = fromDate;
      userUpdates['doj'] = toDate;
      userUpdates['address'] = addrerssController.text;
      userUpdates['city'] = cityController.text;
      userUpdates['state'] = stateController.text;
      userUpdates['country'] = countryController.text;
      userUpdates['zip'] = zipcodeController.text;
      userUpdates['status'] = stateSelectedIndex ?? 0;
      if (filepath != null &&
          filepath!.isNotEmpty &&
          !(filepath!.startsWith('http') && filepath!.startsWith('https'))) {

        userUpdates['profile'] = filepath;
      } else {
        userUpdates['profile'] = null;
      }
      if (phoneController.text.isNotEmpty) {
        userUpdates['countryCode'] = countryCode ?? defaultCountryCode;
      }
      User newUser = User(
          firstName: userUpdates['firstName'],
          lastName: userUpdates['lastName'],
          role: userUpdates['role'],
          email: userUpdates['email'],
          phone: userUpdates['phone'],
          password: userUpdates['password'],
          passwordConfirmation: userUpdates['passwordConfirmation'],
          dob: userUpdates['dob'],
          doj: userUpdates['doj'],
          address: userUpdates['address'],
          city: userUpdates['city'],
          state: userUpdates['state'],
          country: userUpdates['country'],
          zip: userUpdates['zip'],
          profile: userUpdates['profile'],
          status: stateSelectedIndex ?? 0,
          requireEv: emailSelectedIndex ?? 1

          // Populate other fields...
          );
      isLoading = true;
      BlocProvider.of<UserBloc>(context)
          .add(UsersCreated(newUser, _image, filepath));
      final setting = context.read<UserBloc>();
      setting.stream.listen((state) {
        if (state is UserCreateSuccess) {
          if (mounted) {

            isLoading = false;
            BlocProvider.of<UserBloc>(context).add(UserList());
            Navigator.pop(context);
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.createdsuccessfully,
                color: AppColors.primary);
          }
        }
        if (state is UserCreateError ) {
          isLoading = false;
          BlocProvider.of<UserBloc>(context).add(UserList());
          router.pop(context);
          flutterToastCustom(msg: state.errorMessage);
        } if ( state is UserSuccessCreateLoading ) {
          isLoading = false;
          BlocProvider.of<UserBloc>(context).add(UserList());

        }
      });


      // BlocProviflutterToastsoc>(context).add(TaskCreated(title: '',statusId:"",priorityId:"",startDate:"",dueDate:"",du, desc: '', project: null, userId: [], token: null, note: '');
      // return;
      // }
    } else {
      BlocProvider.of<UserBloc>(context).add(UserList());
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  void _onUpdateUser(User currentUser) {

    if (!emailController.text.contains('@')) {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleaseenteravalidemail,
      );
    } else if (passwordController.text != conpasswordController.text) {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.passworddomntmatch,
      );
    }
    if (lastNameController.text.isNotEmpty &&
        firstNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty) {
      Map<String, dynamic> userUpdates = {};
      // Always update basic fields
      userUpdates['id'] = currentUser.id;
      userUpdates['firstName'] = firstNameController.text;
      userUpdates['lastName'] = lastNameController.text;
      userUpdates['role'] =
          selectedRoleId != null && selectedRoleId.toString().isNotEmpty
              ? selectedRoleId.toString()
              : widget.userModel!.roleId!.toString();
      userUpdates['email'] = emailController.text;
      userUpdates['phone'] = phoneController.text;
      userUpdates['countryCode'] = countryCode ?? defaultCountryCode;
      userUpdates['password'] = passwordController.text;
      userUpdates['passwordConfirmation'] = conpasswordController.text;
      userUpdates['dob'] = fromDate;
      userUpdates['doj'] = toDate;
      userUpdates['address'] = addrerssController.text;
      userUpdates['city'] = cityController.text;
      userUpdates['state'] = stateController.text;
      userUpdates['country'] = countryController.text;
      userUpdates['zip'] = zipcodeController.text;
      userUpdates['status'] = stateSelectedIndex ?? 0;

      // Conditionally add the 'profile' field only if there's a new value
      if (filepath!.isNotEmpty &&
          !(filepath!.startsWith('http') && filepath!.startsWith('https'))) {
        userUpdates['profile'] = filepath;
      }
      if (phoneController.text.isNotEmpty) {
        userUpdates['phone'] = phoneController.text;
        userUpdates['countryCode'] = countryCode ?? defaultCountryCode;
      } else {
        userUpdates['phone'] = null;
        userUpdates['countryCode'] = null; // Set to null if no phone
      }

      // Create the updatedUser with the conditional map
      User updatedUser = currentUser.copyWith(
        id: userUpdates['id'],
        firstName: userUpdates['firstName'],
        lastName: userUpdates['lastName'],
        role: userUpdates['role'],
        email: userUpdates['email'],
        phone: userUpdates['phone'],
        countryCode: userUpdates['countryCode'],
        password: userUpdates['password'],
        passwordConfirmation: userUpdates['passwordConfirmation'],
        dob: userUpdates['dob'],
        doj: userUpdates['doj'],
        address: userUpdates['address'],
        city: userUpdates['city'],
        state: userUpdates['state'],
        country: userUpdates['country'],
        zip: userUpdates['zip'],
        status: userUpdates['status'],
        profile: filepath,
        // Only set 'profile' if it's in the map (if the profile has changed)
      );

      isLoading = true;
      BlocProvider.of<UserBloc>(context).add(UpdateUsers(updatedUser));

      final user = context.read<UserBloc>();
      user.stream.listen((state) {

        if (state is UserEditSuccess) {
          if (mounted) {
            isLoading = false;
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.updatedsuccessfully,
                color: AppColors.primary);
            router.pop(context);
            // BlocProvider.of<UseridBloc>(context).add(UserIdListId(widget.userModel!.id));
            BlocProvider.of<UserBloc>(context).add(UserList());


          }
        }
        if (state is UserEditError) {

          isLoading = false;
          flutterToastCustom(msg: state.errorMessage);
        }
      });
      BlocProvider.of<UserBloc>(context).add(UserList());
    } else {
      customToasts(message: AppLocalizations.of(context)!.pleasefilltherequiredfield);
    }
  }

  DateTime? parsedDate;
  void getRoleAndHasDataAccess() async {
    hasPermission = await HiveStorage.getAllDataAccess();
  }

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
    getRoleAndHasDataAccess();
// Initialize currentUser
    BlocProvider.of<RoleBloc>(context).add(RoleList());
    if (widget.isCreate == false) {
      currentUser = widget.userModel!;
      var isEditUser = widget.userModel!;
      if (isEditUser.dob != null &&
          isEditUser.dob!.isNotEmpty &&
          isEditUser.dob != "") {
        parsedDate = parseDateStringFromApi(isEditUser.dob!);
        formattedDob = dateFormatConfirmed(parsedDate!, context);
        selectedDobDate = parsedDate;
      }

      //
      if (isEditUser.doj != null &&
          isEditUser.doj!.isNotEmpty &&
          isEditUser.doj != "") {
        DateTime parsedDojDate = parseDateStringFromApi(isEditUser.doj!);
        selectedDojDate = parsedDojDate;
        formattedDoj = dateFormatConfirmed(parsedDojDate, context);
      }

      filepath = isEditUser.profile;
      selectedRoleName = widget.userModel!.role;
      firstNameController = TextEditingController(text: isEditUser.firstName);
      lastNameController = TextEditingController(text: isEditUser.lastName);
      emailController = TextEditingController(text: isEditUser.email);
      phoneController = TextEditingController(text: isEditUser.phone);
      roleController = TextEditingController(text: isEditUser.role);
      addrerssController = TextEditingController(text: isEditUser.address);
      cityController = TextEditingController(text: isEditUser.city);
      stateController = TextEditingController(text: isEditUser.state);
      countryController = TextEditingController(text: isEditUser.country);
      zipcodeController = TextEditingController(text: isEditUser.zip);
      selectedLabel = isEditUser.state;
      dobController = TextEditingController(text: formattedDob);
      stateSelectedIndex = isEditUser.status;
      dojController = TextEditingController(text: formattedDoj);
    } else {

    }
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
        : PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, Object? result) async {
              if (!didPop) {

                if (widget.fromDetail == true && widget.isCreate == false ) {
                  BlocProvider.of<TaskBloc>(context)
                      .add(AllTaskListOnTask(userId: [widget.userModel!.id!]));
                  BlocProvider.of<ProjectBloc>(context).add(
                      ProjectDashBoardList(userId: [widget.userModel!.id!]));
                  // BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
                  BlocProvider.of<UseridBloc>(context)
                      .add(UserIdListId(widget.userModel!.id));
                  router.pop(context);
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 20.w, right: 20.w, top: 0.h),
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
                                  child: InkWell(
                                    onTap: () {
                                      if (widget.fromDetail == true && widget.isCreate == false) {
                                        BlocProvider.of<TaskBloc>(context).add(
                                            AllTaskListOnTask(userId: [
                                          widget.userModel!.id!
                                        ]));
                                        BlocProvider.of<ProjectBloc>(context)
                                            .add(ProjectDashBoardList(userId: [
                                          widget.userModel!.id!
                                        ]));
                                        // BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
                                        BlocProvider.of<UseridBloc>(context)
                                            .add(UserIdListId(
                                                widget.userModel!.id));
                                        router.pop(context);
                                      } else {
                                        router.pop(context);
                                      }
                                    },
                                    child: BackArrow(
                                      title: widget.isCreate == false
                                          ? AppLocalizations.of(context)!
                                              .edituser
                                          : AppLocalizations.of(context)!
                                              .createuser,
                                    ),
                                  )),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 30.h),
                    SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextFields(
                                title: AppLocalizations.of(context)!.firstname,
                                hinttext: AppLocalizations.of(context)!
                                    .pleaseenterfirstrname,
                                controller: firstNameController,
                                onSaved: (value) {},
                                onFieldSubmitted: (value) {
                                  _fieldFocusChange(
                                    context,
                                    firstnameFocus!,
                                    lastnameFocus,
                                  );
                                },
                                isLightTheme: isLightTheme,
                                isRequired: true),
                            SizedBox(
                              height: 15.h,
                            ),
                            CustomTextFields(
                                title: AppLocalizations.of(context)!.lastname,
                                hinttext: AppLocalizations.of(context)!
                                    .pleaseenterlastrname,
                                controller: lastNameController,
                                onSaved: (value) {},
                                onFieldSubmitted: (value) {
                                  _fieldFocusChange(
                                    context,
                                    lastnameFocus!,
                                    emailFocus,
                                  );
                                },
                                isLightTheme: isLightTheme,
                                isRequired: true),
                            SizedBox(
                              height: 15.h,
                            ),
                            CustomTextFields(
                                title: AppLocalizations.of(context)!.email,
                                hinttext: AppLocalizations.of(context)!
                                    .pleaseenteremail,
                                controller: emailController,
                                onSaved: (value) {},
                                onFieldSubmitted: (value) {
                                  _fieldFocusChange(
                                    context,
                                    emailFocus!,
                                    phoneFocus,
                                  );
                                },
                                isLightTheme: isLightTheme,
                                isRequired: true),
                            SizedBox(
                              height: 15.h,
                            ),
                            _phoneNumberField(isLightTheme),
                            SizedBox(
                              height: 15.h,
                            ),
                            hasPermission == true
                                ? CustomTextFields(
                                    isPassword: true,
                                    keyboardType: TextInputType.text,
                                    title:
                                        AppLocalizations.of(context)!.password,
                                    hinttext: AppLocalizations.of(context)!
                                        .pleaseenterpassword,
                                    controller: passwordController,
                                    onSaved: (value) {},
                                    onFieldSubmitted: (value) {
                                      _fieldFocusChange(
                                        context,
                                        passwardFocus!,
                                        conpasswardFocus,
                                      );
                                    },
                                    isLightTheme: isLightTheme,
                                    isRequired:
                                        widget.isCreate == true ? true : false)
                                : const SizedBox.shrink(),

                            hasPermission == true
                                ? SizedBox(
                                    height: 15.h,
                                  )
                                : const SizedBox.shrink(),

                            hasPermission == true
                                ? CustomTextFields(
                                    isPassword: true,
                                    keyboardType: TextInputType.text,
                                    title: AppLocalizations.of(context)!
                                        .conPassword,
                                    hinttext: AppLocalizations.of(context)!
                                        .pleaseenterconpassword,
                                    controller: conpasswordController,
                                    onSaved: (value) {},
                                    onFieldSubmitted: (value) {
                                      _fieldFocusChange(
                                        context,
                                        conpasswardFocus!,
                                        addressFocus,
                                      );
                                    },
                                    isLightTheme: isLightTheme,
                                    isRequired:
                                        widget.isCreate == true ? true : false)
                                : const SizedBox.shrink(),
                            hasPermission == true
                                ? SizedBox(
                                    height: 15.h,
                                  )
                                : const SizedBox.shrink(),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    // flex: 5,
                                    child: DatePickerWidget(
                                      width: true,
                                      size: 12.sp,
                                      dateController: dobController,
                                      title: AppLocalizations.of(context)!.dob,
                                      onTap: () async {
                                        final DateTime? dateTime =
                                            await showOmniDateTimePicker(
                                                firstDate: DateTime(1910),
                                                context: context,
                                                type:
                                                    OmniDateTimePickerType.date,
                                                initialDate: parsedDate ?? DateTime.now() ,
                                                isShowSeconds: false,
                                                barrierColor: Theme.of(context)
                                                    .colorScheme
                                                    .containerDark);
                                        setState(() {
                                          selectedDateStarts = dateTime!;
                                          fromDate = dateFormatConfirmedToApi(
                                              selectedDateStarts!);
                                          if (selectedDateEnds != null) {
                                            toDate = dateFormatConfirmedToApi(selectedDateEnds!);
                                          }
                                          dobController.text =
                                              dateFormatConfirmed(
                                                  selectedDateStarts!, context);
                                        }); // Print the picked date
                                      },
                                      isLightTheme: isLightTheme,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Expanded(
                                    // flex: 5,
                                    child: DatePickerWidget(
                                      size: 12.sp,
                                      dateController: dojController,
                                      title: AppLocalizations.of(context)!.doj,
                                      onTap: () async {
                                        final DateTime? dateTime =
                                            await showOmniDateTimePicker(
                                              lastDate: DateTime.now(),
                                              firstDate: DateTime(1910),
                                          type: OmniDateTimePickerType.date,
                                          initialDate: selectedDateEnds,
                                          isShowSeconds: false,
                                          context:
                                              context, // Ensure only date picker is shown
                                          barrierColor: Theme.of(context)
                                              .colorScheme
                                              .containerDark,
                                        );

                                        setState(() {

                                          selectedDateEnds = dateTime!;
                                          dojController.text =
                                              dateFormatConfirmed(
                                                  selectedDateEnds!, context);
                                        });
                                      },
                                      isLightTheme: isLightTheme,
                                    ),
                                  )
                                  // 03
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 15.h,
                            ),
                            // RoleField(isLightTheme),
                            RoleField(
                              isRequired: true,
                              isCreate: widget.isCreate ?? false,
                              name: selectedRoleName ?? "",
                              onSelected: handleStatusSelected,
                              fromProfile: false,
                            ),
                            SizedBox(
                              height: 15.h,
                            ),
                            CustomTextFields(
                                title: AppLocalizations.of(context)!.address,
                                hinttext: AppLocalizations.of(context)!
                                    .pleaseenteraddress,
                                controller: addrerssController,
                                onSaved: (value) {},
                                onFieldSubmitted: (value) {
                                  _fieldFocusChange(
                                    context,
                                    addressFocus!,
                                    cityFocus,
                                  );
                                },
                                isLightTheme: isLightTheme,
                                isRequired: false),
                            SizedBox(
                              height: 15.h,
                            ),

                            CustomTextFields(
                                // keyboardType:  TextInputType.multiline,
                                title: AppLocalizations.of(context)!.state,
                                hinttext: AppLocalizations.of(context)!
                                    .pleaseenterstate,
                                controller: stateController,
                                onSaved: (value) {},
                                onFieldSubmitted: (value) {
                                  _fieldFocusChange(
                                    context,
                                    stateFocus!,
                                    countryFocus,
                                  );
                                },
                                isLightTheme: isLightTheme,
                                isRequired: false),
                            SizedBox(
                              height: 15.h,
                            ),
                            CustomTextFields(
                                title: AppLocalizations.of(context)!.city,
                                hinttext: AppLocalizations.of(context)!
                                    .pleaseentercity,
                                controller: cityController,
                                onSaved: (value) {},
                                onFieldSubmitted: (value) {
                                  _fieldFocusChange(
                                    context,
                                    cityFocus!,
                                    companyFocus,
                                  );
                                },
                                isLightTheme: isLightTheme,
                                isRequired: false),
                            SizedBox(
                              height: 15.h,
                            ),
                            _profileImageField(isLightTheme),

                            SizedBox(
                              height: 15.h,
                            ),
                            CustomTextFields(
                                // keyboardType:  TextInputType.multiline,
                                title: AppLocalizations.of(context)!.country,
                                hinttext: AppLocalizations.of(context)!
                                    .pleaseentercountry,
                                controller: countryController,
                                onSaved: (value) {},
                                onFieldSubmitted: (value) {
                                  _fieldFocusChange(
                                    context,
                                    countryFocus!,
                                    zipFocus,
                                  );
                                },
                                isLightTheme: isLightTheme,
                                isRequired: false),
                            SizedBox(
                              height: 15.h,
                            ),
                            CustomTextFields(
                                // keyboardType:  TextInputType.multiline,
                                title: AppLocalizations.of(context)!.zipcode,
                                hinttext: AppLocalizations.of(context)!
                                    .pleaseenterzipcode,
                                controller: zipcodeController,
                                onSaved: (value) {},
                                onFieldSubmitted: (value) {},
                                isLightTheme: isLightTheme,
                                isRequired: false),
                            SizedBox(
                              height: 15.h,
                            ),
                            _userActivatedOrNot(isLightTheme, widget.isCreate),
                            hasPermission == true
                                ? SizedBox(
                                    height: 15.h,
                                  )
                                : const SizedBox.shrink(),
                            widget.isCreate == true && hasPermission == true
                                ? _requireEmailVerification(
                                    isLightTheme, widget.isCreate)
                                : const SizedBox.shrink(),
                            SizedBox(
                              height: 20.h,
                            ),
                            BlocBuilder<UserBloc, UserState>(
                                builder: (context, state) {

                              if (state is UserSuccessCreateLoading) {
                                return CreateCancelButtom(
                                  isLoading: isLoading,
                                  isCreate: widget.isCreate,
                                  onpressCancel: () {
                                    Navigator.pop(context);
                                  },
                                  onpressCreate: widget.isCreate == true
                                      ? () async {

                                          _onCreateUser();
                                          // Navigator.pop(context);
                                        }
                                      : () {
                                          if (currentUser != null) {
                                            _onUpdateUser(currentUser!);
                                          } else {
                                            print("No current user available");
                                          }

                                          // Navigator.pop(context);
                                        },
                                );
                              }
                              if (state is UserSuccessEditLoading) {
                                return CreateCancelButtom(
                                  isLoading: true,
                                  isCreate: widget.isCreate,
                                  onpressCancel: () {
                                    Navigator.pop(context);
                                  },
                                  onpressCreate: widget.isCreate == true
                                      ? () async {

                                          _onCreateUser();
                                          // Navigator.pop(context);
                                        }
                                      : () {
                                          if (currentUser != null) {
                                            _onUpdateUser(currentUser!);
                                          } else {
                                            print("No current user available");
                                          }

                                          // Navigator.pop(context);
                                        },
                                );
                              }
                              return CreateCancelButtom(
                                isCreate: widget.isCreate,
                                onpressCancel: () {
                                  Navigator.pop(context);
                                },
                                onpressCreate: widget.isCreate == true
                                    ? () async {

                                        _onCreateUser();
                                        // Navigator.pop(context);
                                      }
                                    : () {
                                        if (currentUser != null) {
                                          _onUpdateUser(currentUser!);
                                        } else {
                                          print("No current user available");
                                        }

                                        // Navigator.pop(context);
                                      },
                              );
                            }),

                            Container(
                              // color: Colors.red,
                              height: 70.h,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ));
  }

  Widget _phoneNumberField(isLightTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),
          child: CustomText(
            text: AppLocalizations.of(context)!.phonenumber,
            // text: getTranslated(context, 'myweeklyTask'),
            color: Theme.of(context).colorScheme.textClrChange,
            size: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Container(
          height: 40.h,
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.greyColor),
            borderRadius: BorderRadius.circular(12),
          ),
          // decoration: DesignConfiguration.shadow(),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  // color: Colors.red,
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
                        countryCode = country.code;
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
                // color: colors.red,
                // height: 40.h,
                width: 0.5.w,
              ),
              SizedBox(
                width: 10.w,
              ),
              Expanded(
                flex: 6,
                child: Container(
                  padding: EdgeInsets.zero,
                  // color: Colors.yellow,
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
                    onSaved: (String? value) {
                      // context.read<AuthenticationProvider>().setSingUp(value);
                    },
                    onFieldSubmitted: (v) {
                      _fieldFocusChange(
                        context,
                        phoneFocus!,
                        emailFocus,
                      );
                    },
                    decoration: InputDecoration(
                        // labelText: "firstname",
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
                        ) // Center the text vertically
                        // border: OutlineInputBorder(
                        //     borderRadius: BorderRadius.circular(10),
                        //     borderSide:
                        //     BorderSide(color: colors.hintColor)),
                        // focusedBorder:  OutlineInputBorder(
                        //     borderRadius: BorderRadius.circular(10),
                        //     borderSide:
                        //     BorderSide(color: colors.hintColor)),
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

  Widget _profileImageField(isLightTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),
          child: Row(
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.profilePicture,
                // text: getTranslated(context, 'myweeklyTask'),
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Container(
            // padding: EdgeInsets.symmetric(horizontal: 10.w),
            height: 40.h,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              // color: Colors.red,
              border: Border.all(color: AppColors.greyColor),
              borderRadius: BorderRadius.circular(12),
            ),
            // decoration: DesignConfiguration.shadow(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      _pickImage();
                    },
                    child: _image == null
                        ? CustomText(
                            text: AppLocalizations.of(context)!.choosefile,
                            fontWeight: FontWeight.w400,
                            size: 14.sp,
                            color: Theme.of(context).colorScheme.textClrChange,
                          )
                        : CustomText(
                            text: AppLocalizations.of(context)!.choosefile,
                            fontWeight: FontWeight.w400,
                            size: 14.sp,
                            color: Theme.of(context).colorScheme.textClrChange,
                          ),
                  ),
                  SizedBox(
                    width: 15.w,
                  ),
                  Container(
                    color: AppColors.greyForgetColor,
                    // color: colors.red,
                    height: 40.h,
                    width: 0.5.w,
                  ),
                  SizedBox(
                    width: 15.w,
                  ),
                  widget.isCreate == true
                      ? _image == null
                          ? SizedBox(
                              width: 200.w,
                              child: CustomText(
                                text:
                                    AppLocalizations.of(context)!.nofilechosen,
                                fontWeight: FontWeight.w400,
                                size: 14.sp,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : SizedBox(
                              // color: Colors.red,
                              width: 200.w,
                              child: CustomText(
                                overflow: TextOverflow.ellipsis,
                                text: filepath!,
                                fontWeight: FontWeight.w400,
                                size: 14.sp,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                              ),
                            )
                      : SizedBox(
                          // color: Colors.red,
                          width: 200.w,
                          child: CustomText(
                              overflow: TextOverflow.ellipsis,
                              text: filepath!,
                              fontWeight: FontWeight.w400,
                              size: 14.sp,
                              maxLines: 1,
                              color:
                                  Theme.of(context).colorScheme.textClrChange),
                        ),
                ],
              ),
            )),
        SizedBox(
          height: 15.w,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),
          child: CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 25,
            backgroundImage: filepath != null
                ? (filepath!.startsWith("http")
                    ? NetworkImage(filepath!) as ImageProvider
                    : FileImage(File(_image!.path)) as ImageProvider)
                : null,
            child: filepath == null && _image == null
                ? Icon(
                    Icons.person,
                    size: 25.sp,
                    color: Colors.grey.shade200,
                  )
                : null, // Optionally provide a placeholder or handle null case
          ),
        )
      ],
    );
  }

  Widget _userActivatedOrNot(isLightTheme, isCreate) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30.h,
                child: CustomText(
                  text: AppLocalizations.of(context)!.state,
                  // text: getTranslated(context, 'myweeklyTask'),
                  color: Theme.of(context).colorScheme.textClrChange,
                  size: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                width: 5.w,
              ),
              SizedBox(
                height: 30.h,
                width: 270,
                // color: Colors.red,
                child: CustomText(
                  text: AppLocalizations.of(context)!.ifDeactivate,
                  // text: getTranslated(context, 'myweeklyTask'),
                  color: AppColors.greyColor,
                  size: 8,
                  maxLines: 2,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Container(
            // padding: EdgeInsets.symmetric(horizontal: 10.w),
            height: 40.h,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              // color: Colors.red,
              border: Border.all(color: AppColors.greyColor),
              borderRadius: BorderRadius.circular(12),
            ),
            // decoration: DesignConfiguration.shadow(),
            child: ToggleSwitch(
              cornerRadius: 11.r,
              activeBgColor: const [AppColors.primary],
              inactiveBgColor: Colors.transparent,
              minHeight: 40.h,
              minWidth: double.infinity,
              initialLabelIndex: stateSelectedIndex, // Set the initial index
              totalSwitches: 2,
              labels: const ['Deactive', 'Active'],
              onToggle: (index) {
                if (hasPermission == false) {
                  stateSelectedIndex == 0;
                } else {
                  stateSelectedIndex = index ?? 0;
                  selectedLabel = index == 0 ? 'Deactive' : 'Active';
                }
                // Capture the selected index here

                // Perform your actions based on the selected value
              },
            ))
      ],
    );
  }

  Widget _requireEmailVerification(isLightTheme, isCreate) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),
          child: Row(
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.requireEmailVerification,
                // text: getTranslated(context, 'myweeklyTask'),
                color: AppColors.greyColor,
                size: 8,
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Container(
            // padding: EdgeInsets.symmetric(horizontal: 10.w),
            height: 40.h,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              // color: Colors.red,
              border: Border.all(color: AppColors.greyColor),
              borderRadius: BorderRadius.circular(12),
            ),
            // decoration: DesignConfiguration.shadow(),
            child: Padding(
              padding: const EdgeInsets.all(0.1),
              child: ToggleSwitch(
                // radiusStyle: true,
                cornerRadius: 12,
                activeBgColor: const [AppColors.primary],
                inactiveBgColor: Colors.transparent,
                minHeight: 40,
                minWidth: double.infinity / 2,
                initialLabelIndex: 1,
                totalSwitches: 2,
                labels: const ['Yes', 'No'],
                onToggle: (index) {
                  emailSelectedIndex = index;
                  selectedemailLabel = index == 0 ? 'Active' : 'Deactive';

                  },
              ),
            ))
      ],
    );
  }
}
