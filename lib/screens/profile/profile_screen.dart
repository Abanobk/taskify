import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:taskify/config/strings.dart';
import 'package:taskify/screens/authentication/login_screen.dart';
import 'dart:io';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/languages/language_switcher_bloc.dart';

import '../../bloc/profile_picture/profile_pic_bloc.dart';
import '../../bloc/profile_picture/profile_pic_event.dart';
import '../../bloc/profile_picture/profile_pic_state.dart';
import '../../bloc/roles/role_bloc.dart';
import '../../bloc/roles/role_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../bloc/user_profile/user_profile_bloc.dart';
import '../../bloc/user_profile/user_profile_event.dart';
import '../../bloc/user_profile/user_profile_state.dart';
import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../data/GlobalVariable/globalvariable.dart';
import '../../data/localStorage/hive.dart';
import '../../data/repositories/account_deletetion/account_deletion_repo.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/widgets/toast_widget.dart';
import '../widgets/custom_textfields/custom_textfield.dart';
import '../widgets/validation.dart';
import '../../../src/generated/i18n/app_localizations.dart';


class ProfileScreenn extends StatefulWidget {
  const ProfileScreenn({super.key});

  @override
  State<ProfileScreenn> createState() => _ProfileScreennState();
}

class _ProfileScreennState extends State<ProfileScreenn> {
  TextEditingController nameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController conpasswordController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  String selectedCategory = '';
  String? countryCode;
  String? countryIsoCode;
  FocusNode nameFocusNode = FocusNode();
  String selectedRole = '';
  String? passwordWidget;
  String? conasswordWidget;
  bool? isEdit = false;
  bool? hasPermission;
  // File? _image;
  String? filepath;
  bool isRtl = false;
  // final ImagePicker _picker = ImagePicker();
  String? selectedRoleName;
  String? profilephoto;
  int? selectedRoleId;
  TextEditingController phoneController = TextEditingController();
  void handleRoleSelected(String category, int catId) {
    setState(() {
      selectedRoleName = category;
      selectedRoleId = catId;
    });

  }

  String? profilePic;
  @override
  void initState() {
    BlocProvider.of<RoleBloc>(context).add(RoleList());
    photoWidget = context.read<UserProfileBloc>().profilePic;
    context.read<UserProfileBloc>().add(ProfileListGet());
    _checkRtlLanguage();
   // context.read<ProfilePicBloc>().add(LoadSavedImage());
    firstNameWidget = context.read<UserProfileBloc>().firstname ?? "First Name";
    lastNameWidget = context.read<UserProfileBloc>().lastName ?? "LastName";
    emailWidget = context.read<UserProfileBloc>().email ?? "Email";
    addressWidget = context.read<UserProfileBloc>().address ?? "Address";
    cityINWidget = context.read<UserProfileBloc>().city ?? "City";
    phoneInWidget = context.read<UserProfileBloc>().phone ?? "Phone";
    roleInWidget = context.read<UserProfileBloc>().roleId?.toString() ?? "Role";
    photoWidget = context.read<UserProfileBloc>().profilePic ?? "Photo";
    selectedRoleName = context.read<UserProfileBloc>().role ?? "Role";
    countryIsoCode =
        context.read<UserProfileBloc>().countryIsoCode ?? "Country Code";
    countryCode = context.read<UserProfileBloc>().countryCode ?? "Country Code";
    passwordController.text = "";
    conpasswordController.text = "";
    nameController = TextEditingController(text: "$firstNameWidget");
    lastnameController = TextEditingController(text: "$lastNameWidget");
    emailController = TextEditingController(text: "$emailWidget");
    addressController = TextEditingController(text: "$addressWidget");
    cityController = TextEditingController(text: "$cityINWidget");
    phoneController = TextEditingController(text: "$phoneInWidget");
    super.initState();
  }

  _getDeleteAllData() async {
    var authbox = await Hive.openBox(authBox);
    await authbox.delete(authBox);


    var themeebox = await Hive.openBox(themeBox);
    await themeebox.delete(themeBox);


    var usersbox = await Hive.openBox(userBox);
    await usersbox.delete(userBox);


    var permissionbox = await Hive.openBox(permissionsBox);
    await permissionbox.delete(permissionsBox);


    var settingsBoxx = await Hive.openBox(settingsBox);
    await settingsBoxx.delete(settingsBox);

  }

  Future<void> _checkRtlLanguage() async {
    final languageCode = await HiveStorage().getLanguage();
    isRtl =
        LanguageBloc.instance.isRtlLanguage(languageCode ?? defaultLanguage);
    setState(() {});
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed
    nameController.dispose();
    genderController.dispose();
    emailController.dispose();
    passwordController.dispose();
    addressController.dispose();
    roleController.dispose();
    cityController.dispose();

    nameFocusNode.dispose();
    super.dispose();
  }

  String? firstNameWidget;
  String? demo;
  String? changedFirst;
  int? id;
  String? role;
  String? lastNameWidget;
  String? changedLast;
  String? genderWidget;
  String? emailWidget;
  String? changedEmail;
  String? addressWidget;
  String? changedaddress;
  String? cityINWidget;
  String? phoneInWidget;
  String? changedcity;
  String? roleInWidget;
  String? photoWidget;

  String? photoFromHive;

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.backGroundColor,
              borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: HeroIcon(
                  HeroIcons.camera,
                  style: HeroIconStyle.outline,
                  color: Theme.of(context).colorScheme.textClrChange,
                ),
                title: CustomText(
                  text: AppLocalizations.of(context)!.camera,
                  color: Theme.of(context).colorScheme.textClrChange,
                ),
                onTap: () {

                  context
                      .read<ProfilePicBloc>()
                      .add(PickImageFromCamera(context: context));
                  Navigator.pop(navigatorKey.currentContext!);

                },
              ),
              ListTile(
                leading: HeroIcon(
                  HeroIcons.photo,
                  style: HeroIconStyle.outline,
                  color: Theme.of(context).colorScheme.textClrChange,
                ),
                title: CustomText(
                  text: AppLocalizations.of(context)!.gallery,
                  color: Theme.of(context).colorScheme.textClrChange,
                ),
                onTap: () {
                  context
                      .read<ProfilePicBloc>()
                      .add(PickImageFromGallery(context: context));
                  Navigator.pop(navigatorKey.currentContext!);
                  // flutterToastCustom(
                  //     msg: AppLocalizations.of(navigatorKey.currentContext!)!
                  //         .updatedsuccessfully,
                  //     color: AppColors.primary);
                  // _pickImage(ImageSource.gallery);
                  // Handle the music option
                  // Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<UserProfileBloc>(context).add(ProfileListGet());
    hasPermission = context.read<AuthBloc>().hasAllDataAccess;
    BlocProvider.of<UserProfileBloc>(context).add(ProfileListGet());
    profilephoto = context.read<UserProfileBloc>().profilePic ?? "";
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
      BlocProvider.of<UserProfileBloc>(context).add(ProfileList());
      BlocProvider.of<UserProfileBloc>(context).add(ProfileListGet());
      if (!didPop) {
        router.pop(context);
      }
    },
    child:Scaffold(
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      body: Stack(
        // alignment: Alignment.center, // Aligns all children to the center by default
        children: <Widget>[
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Theme.of(context).colorScheme.backGroundColor,
          ),
          Positioned(
            top: 0.h,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: 160.h,
              color: AppColors.primary,
            ),
          ),
          _profileAppbar(),
          _profilePicture(),
          _profileEdit(),
          _profileDetails(isLightTheme),
          SizedBox(
            height: 60.h,
          ),
        ],
      ),
    ));
  }

  Widget _profileDetails(isLightTheme) {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {


      if (state is UserProfileSuccess) {

        id = context.read<UserProfileBloc>().userId;
        role = context.read<UserProfileBloc>().role;

        return Positioned(
            top: 230,
            left: 18.w,
            right: 18.w,
            bottom: 0,
            child: SingleChildScrollView(
                child: Container(
              // height: 563.h,
              width: 350.w,
              decoration: BoxDecoration(
                // color: AppColors.red
                color: Theme.of(context).colorScheme.backGroundColor,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  // if(isDemo){
                                  //   flutterToastCustom(msg: AppLocalizations.of(context)!.isDemooperation);
                                  // }else{
                                    isEdit =
                                    !isEdit!;
                                  // }  // Toggle the value of isEdit
                                });
                                // nameFocusNode.requestFocus();
                              },
                              child: HeroIcon(
                                isEdit!
                                    ? HeroIcons.arrowUturnLeft
                                    : HeroIcons.pencilSquare,
                                style: HeroIconStyle.outline,
                                size: 18.sp,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CustomTextFields(
                          title: AppLocalizations.of(context)!.firstname,
                          hinttext: "",
                          controller:
                              TextEditingController(text: firstNameWidget),
                          onchange: (value) {
                            demo = value;
                            firstNameWidget = value;
                            nameController.text = value!;
                          },
                          onSaved: (value) {
                            firstNameWidget = value;
                            nameController.text = value!;
                          },
                          readonly: isEdit == true ? false : true,
                          onFieldSubmitted: (value) {
                          },
                          isLightTheme: isLightTheme,
                          isRequired: false),
                      SizedBox(
                        height: 10.h,
                      ),
                      CustomTextFields(
                          title: AppLocalizations.of(context)!.lastname,
                          hinttext: "",
                          controller: lastnameController,
                          onSaved: (value) {},
                          readonly: isEdit == true ? false : true,
                          isLightTheme: isLightTheme,
                          isRequired: false),
                      SizedBox(
                        height: 10.h,
                      ),
                      CustomTextFields(
                          title: AppLocalizations.of(context)!.email,
                          hinttext: "",
                          controller: emailController,
                          onSaved: (value) {},
                          readonly: isEdit == true &&
                                  hasPermission == true &&
                                  role == "admin"
                              ? true
                              : false,
                          onFieldSubmitted: (value) {
                          },
                          isLightTheme: isLightTheme,
                          isRequired: false),
                      SizedBox(
                        height: 10.h,
                      ),
                      CustomTextFields(
                          isPassword: true,
                          title: AppLocalizations.of(context)!.password,
                          hinttext:
                              AppLocalizations.of(context)!.pleaseenterpassword,
                          readonly: isEdit == true ? false : true,
                          controller: passwordController,
                          onSaved: (value) {},
                          onFieldSubmitted: (value) {},
                          isLightTheme: isLightTheme,
                          isRequired: false),
                      SizedBox(
                        height: 10.h,
                      ),
                      CustomTextFields(
                          isPassword: true,
                          title: AppLocalizations.of(context)!.conPassword,
                          hinttext: AppLocalizations.of(context)!
                              .pleaseenterconpassword,
                          controller: conpasswordController,
                          readonly: isEdit == true ? false : true,
                          onSaved: (value) {},
                          onFieldSubmitted: (value) {},
                          isLightTheme: isLightTheme,
                          isRequired: false),
                      SizedBox(
                        height: 10.h,
                      ),
                      CustomTextFields(
                          title: AppLocalizations.of(context)!.address,
                          hinttext: "",
                          controller: addressController,
                          onSaved: (value) {},
                          readonly: isEdit == true ? false : true,
                          onFieldSubmitted: (value) {
                            // _fieldFocusChange(
                            //   context,
                            //   budgetFocus!,
                            //   descFocus,
                            // );
                          },
                          isLightTheme: isLightTheme,
                          isRequired: false),
                      SizedBox(
                        height: 10.h,
                      ),
                      CustomTextFields(
                          title: AppLocalizations.of(context)!.city,
                          hinttext: "",
                          controller: cityController,
                          onSaved: (value) {},
                          readonly: isEdit == true ? false : true,
                          onFieldSubmitted: (value) {
                            // _fieldFocusChange(
                            //   context,
                            //   budgetFocus!,
                            //   descFocus,
                            // );
                          },
                          isLightTheme: isLightTheme,
                          isRequired: false),
                      SizedBox(
                        height: 10.h,
                      ),
                      _phoneNumberField(isLightTheme, isEdit),
                      SizedBox(
                        height: 30.h,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: Row(
                          mainAxisAlignment: isEdit == false
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.center,
                          children: [
                            isEdit == true
                                ? InkWell(
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      // if (passwordController.text.isNotEmpty && conpasswordController.text.isNotEmpty) {
                                      if (passwordController.text !=
                                          conpasswordController.text) {
                                        flutterToastCustom(
                                          msg: AppLocalizations.of(context)!
                                              .passworddomntmatch,
                                        );
                                      } else {
                                        context.read<UserProfileBloc>().add(ProfileDetailsUpdateList(
                                              firstname:
                                                  nameController.text.isEmpty
                                                      ? firstNameWidget!
                                                      : nameController.text,
                                              lastname: lastnameController
                                                      .text.isEmpty
                                                  ? lastNameWidget!
                                                  : lastnameController.text,
                                              role: selectedRoleId != null
                                                  ? int.tryParse(selectedRoleId
                                                          .toString()) ??
                                                      0 // Default to 0 if parsing fails
                                                  : int.tryParse(roleInWidget
                                                          .toString()) ??
                                                      0,
                                              email:
                                                  emailController.text.isEmpty
                                                      ? emailWidget!
                                                      : emailController.text,
                                              address:
                                                  addressController.text.isEmpty
                                                      ? addressWidget!
                                                      : addressController.text,
                                              password: passwordController
                                                      .text.isEmpty
                                                  ? passwordWidget
                                                  : passwordController.text,
                                              conPassword: conpasswordController
                                                      .text.isEmpty
                                                  ? conasswordWidget
                                                  : conpasswordController.text,
                                              phone:
                                                  phoneController.text.isEmpty
                                                      ? phoneInWidget!
                                                      : phoneController.text,
                                              countryCode: countryCode!,
                                              countryIsoCode: countryIsoCode!,
                                              city: cityController.text.isEmpty
                                                  ? cityINWidget!
                                                  : cityController.text,
                                            ));
                                        final todosBloc =
                                            BlocProvider.of<UserProfileBloc>(
                                                context);
                                        todosBloc.stream.listen((state) {
                                          if (state
                                              is UserDetailUpdateSuccess) {

                                            navigatorKey.currentContext!
                                                  .read<UserProfileBloc>()
                                                  .add(ProfileListGet());
                                              flutterToastCustom(
                                                  msg: AppLocalizations.of(
                                                      navigatorKey.currentContext!)!
                                                      .updatedsuccessfully,
                                                  color: AppColors.primary);
                                              isEdit = false;
                                            }

                                          if (state is UserDetailUpdateError) {
                                            flutterToastCustom(
                                                msg: state.error);
                                          }
                                        });
                                      }
                                    },
                                    child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        height: 32.h,
                                        width: 130,
                                        margin: EdgeInsets.only(top: 10.h),
                                        child: CustomText(
                                          text: AppLocalizations.of(context)!
                                              .update,
                                          size: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.pureWhiteColor,
                                        )),
                                  )
                                : const SizedBox.shrink(),
                            role == "admin"
                                ? SizedBox()
                                : Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10.w),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                       if(isDemo){
                                         flutterToastCustom(msg: AppLocalizations.of(context)!.isDemooperation);

                                       }else{
                                         showDialog(
                                           context: context,
                                           builder: (context) {
                                             return AlertDialog(
                                               shape: RoundedRectangleBorder(
                                                 borderRadius:
                                                 BorderRadius.circular(10
                                                     .r), // Set the desired radius here
                                               ),
                                               backgroundColor: Theme.of(context)
                                                   .colorScheme
                                                   .alertBoxBackGroundColor,
                                               title: Text(
                                                   AppLocalizations.of(context)!
                                                       .confirmDelete),
                                               content: Text(AppLocalizations.of(
                                                   context)!
                                                   .areyousureyouwanttodeleteaccount),
                                               actions: [
                                                 TextButton(
                                                   onPressed: () async {
                                                     AccountDeletion()
                                                         .getDeleteAccount();

                                                     _getDeleteAllData();
                                                     Navigator.push(
                                                         context,
                                                         CupertinoPageRoute(
                                                             builder: (context) =>
                                                             const LoginScreen())); // Confirm deletion
                                                   },
                                                   child: Text(
                                                       AppLocalizations.of(
                                                           context)!
                                                           .delete),
                                                 ),
                                                 SizedBox(
                                                   width: 20.w,
                                                 ),
                                                 TextButton(
                                                   onPressed: () {
                                                     Navigator.of(context).pop(
                                                         false); // Cancel deletion
                                                   },
                                                   child: Text(
                                                       AppLocalizations.of(
                                                           context)!
                                                           .cancel),
                                                 ),
                                               ],
                                             );
                                           },
                                         );
                                       }
                                      },
                                      child: Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: AppColors.red,
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          height: 32.h,
                                          width: 130.w,
                                          margin: EdgeInsets.only(top: 10.h),
                                          child: CustomText(
                                            text: AppLocalizations.of(context)!
                                                .deleteAcount,
                                            size: 10.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.pureWhiteColor,
                                          )),
                                    ),
                                  )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 60.h,
                      ),
                    ],
                  ),
                ),
              ),
            )));
      }
          if (state is UserDetailUpdateError) {

            id = context.read<UserProfileBloc>().userId;
            role = context.read<UserProfileBloc>().role;

            return Positioned(
                top: 230,
                left: 18.w,
                right: 18.w,
                bottom: 0,
                child: SingleChildScrollView(
                    child: Container(
                      // height: 563.h,
                      width: 350.w,
                      decoration: BoxDecoration(
                        // color: AppColors.red
                        color: Theme.of(context).colorScheme.backGroundColor,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          // if(isDemo){
                                          //   flutterToastCustom(msg: AppLocalizations.of(context)!.isDemooperation);
                                          // }else{
                                          isEdit =
                                          !isEdit!;
                                          // }  // Toggle the value of isEdit
                                        });
                                        // nameFocusNode.requestFocus();
                                      },
                                      child: HeroIcon(
                                        isEdit!
                                            ? HeroIcons.arrowUturnLeft
                                            : HeroIcons.pencilSquare,
                                        style: HeroIconStyle.outline,
                                        size: 18.sp,
                                        color:
                                        Theme.of(context).colorScheme.textClrChange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              CustomTextFields(
                                  title: AppLocalizations.of(context)!.firstname,
                                  hinttext: "",
                                  controller:
                                  TextEditingController(text: context.read<UserProfileBloc>().firstname),
                                  onchange: (value) {
                                    demo = value;
                                    // firstNameWidget = value;
                                    nameController.text = value!;
                                  },
                                  onSaved: (value) {
                                    // firstNameWidget = value;
                                    nameController.text = value!;
                                  },
                                  readonly: isEdit == true ? false : true,
                                  onFieldSubmitted: (value) {
                                  },
                                  isLightTheme: isLightTheme,
                                  isRequired: false),
                              SizedBox(
                                height: 10.h,
                              ),
                              CustomTextFields(
                                  title: AppLocalizations.of(context)!.lastname,
                                  hinttext: "",
                                  controller:TextEditingController(text: context.read<UserProfileBloc>().lastName),

                                  onSaved: (value) {},
                                  readonly: isEdit == true ? false : true,
                                  isLightTheme: isLightTheme,
                                  isRequired: false),
                              SizedBox(
                                height: 10.h,
                              ),
                              CustomTextFields(
                                  title: AppLocalizations.of(context)!.email,
                                  hinttext: "",
                                  controller: TextEditingController(text: context.read<UserProfileBloc>().email),
                                  onSaved: (value) {},
                                  readonly: isEdit == true &&
                                      hasPermission == true &&
                                      role == "admin"
                                      ? true
                                      : false,
                                  onFieldSubmitted: (value) {
                                  },
                                  isLightTheme: isLightTheme,
                                  isRequired: false),
                              SizedBox(
                                height: 10.h,
                              ),
                              CustomTextFields(
                                  isPassword: true,
                                  title: AppLocalizations.of(context)!.password,
                                  hinttext:
                                  AppLocalizations.of(context)!.pleaseenterpassword,
                                  readonly: isEdit == true ? false : true,
                                  controller: TextEditingController(text: ""),
                                  onSaved: (value) {},
                                  onFieldSubmitted: (value) {},
                                  isLightTheme: isLightTheme,
                                  isRequired: false),
                              SizedBox(
                                height: 10.h,
                              ),
                              CustomTextFields(
                                  isPassword: true,
                                  title: AppLocalizations.of(context)!.conPassword,
                                  hinttext: AppLocalizations.of(context)!
                                      .pleaseenterconpassword,
                                  controller: TextEditingController(text: ""),
                                  readonly: isEdit == true ? false : true,
                                  onSaved: (value) {},
                                  onFieldSubmitted: (value) {},
                                  isLightTheme: isLightTheme,
                                  isRequired: false),
                              SizedBox(
                                height: 10.h,
                              ),
                              CustomTextFields(
                                  title: AppLocalizations.of(context)!.address,
                                  hinttext: "",
                                  controller: TextEditingController(text: context.read<UserProfileBloc>().address??""),
                                  onSaved: (value) {},
                                  readonly: isEdit == true ? false : true,
                                  onFieldSubmitted: (value) {
                                    // _fieldFocusChange(
                                    //   context,
                                    //   budgetFocus!,
                                    //   descFocus,
                                    // );
                                  },
                                  isLightTheme: isLightTheme,
                                  isRequired: false),
                              SizedBox(
                                height: 10.h,
                              ),
                              CustomTextFields(
                                  title: AppLocalizations.of(context)!.city,
                                  hinttext: "",
                                  controller: TextEditingController(text: context.read<UserProfileBloc>().city??""),
                                  onSaved: (value) {},
                                  readonly: isEdit == true ? false : true,
                                  onFieldSubmitted: (value) {
                                    // _fieldFocusChange(
                                    //   context,
                                    //   budgetFocus!,
                                    //   descFocus,
                                    // );
                                  },
                                  isLightTheme: isLightTheme,
                                  isRequired: false),
                              SizedBox(
                                height: 10.h,
                              ),
                              _phoneNumberField(isLightTheme, isEdit),
                              SizedBox(
                                height: 30.h,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18.w),
                                child: Row(
                                  mainAxisAlignment: isEdit == false
                                      ? MainAxisAlignment.center
                                      : MainAxisAlignment.center,
                                  children: [
                                    isEdit == true
                                        ? InkWell(
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        // if (passwordController.text.isNotEmpty && conpasswordController.text.isNotEmpty) {
                                        if (passwordController.text !=
                                            conpasswordController.text) {
                                          flutterToastCustom(
                                            msg: AppLocalizations.of(context)!
                                                .passworddomntmatch,
                                          );
                                        } else {
                                          context
                                              .read<UserProfileBloc>()
                                              .add(ProfileDetailsUpdateList(
                                            firstname:
                                            nameController.text.isEmpty
                                                ? firstNameWidget!
                                                : nameController.text,
                                            lastname: lastnameController
                                                .text.isEmpty
                                                ? lastNameWidget!
                                                : lastnameController.text,
                                            role: selectedRoleId != null
                                                ? int.tryParse(selectedRoleId
                                                .toString()) ??
                                                0 // Default to 0 if parsing fails
                                                : int.tryParse(roleInWidget
                                                .toString()) ??
                                                0,
                                            email:
                                            emailController.text.isEmpty
                                                ? emailWidget!
                                                : emailController.text,
                                            address:
                                            addressController.text.isEmpty
                                                ? addressWidget!
                                                : addressController.text,
                                            password: passwordController
                                                .text.isEmpty
                                                ? passwordWidget
                                                : passwordController.text,
                                            conPassword: conpasswordController
                                                .text.isEmpty
                                                ? conasswordWidget
                                                : conpasswordController.text,
                                            phone:
                                            phoneController.text.isEmpty
                                                ? phoneInWidget!
                                                : phoneController.text,
                                            countryCode: countryCode!,
                                            countryIsoCode: countryIsoCode!,
                                            city: cityController.text.isEmpty
                                                ? cityINWidget!
                                                : cityController.text,
                                          ));
                                          final todosBloc =
                                          BlocProvider.of<UserProfileBloc>(
                                              context);
                                          todosBloc.stream.listen((state) {
                                            if (state
                                            is UserDetailUpdateSuccess) {

                                              navigatorKey.currentContext!
                                                  .read<UserProfileBloc>()
                                                  .add(ProfileListGet());
                                              flutterToastCustom(
                                                  msg: AppLocalizations.of(
                                                      navigatorKey.currentContext!)!
                                                      .updatedsuccessfully,
                                                  color: AppColors.primary);
                                              isEdit = false;
                                            }

                                            if (state is UserDetailUpdateError) {
                                              navigatorKey.currentContext!
                                                  .read<UserProfileBloc>()
                                                  .add(ProfileListGet());
                                              flutterToastCustom(
                                                  msg: state.error);
                                            }
                                          });
                                        }
                                      },
                                      child: Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius:
                                              BorderRadius.circular(6)),
                                          height: 32.h,
                                          width: 130,
                                          margin: EdgeInsets.only(top: 10.h),
                                          child: CustomText(
                                            text: AppLocalizations.of(context)!
                                                .update,
                                            size: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.pureWhiteColor,
                                          )),
                                    )
                                        : const SizedBox.shrink(),
                                    role == "admin"
                                        ? SizedBox()
                                        : Padding(
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 10.w),
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        onTap: () {
                                          if(isDemo){
                                            flutterToastCustom(msg: AppLocalizations.of(context)!.isDemooperation);

                                          }else{
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(10
                                                        .r), // Set the desired radius here
                                                  ),
                                                  backgroundColor: Theme.of(context)
                                                      .colorScheme
                                                      .alertBoxBackGroundColor,
                                                  title: Text(
                                                      AppLocalizations.of(context)!
                                                          .confirmDelete),
                                                  content: Text(AppLocalizations.of(
                                                      context)!
                                                      .areyousureyouwanttodeleteaccount),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () async {
                                                        AccountDeletion()
                                                            .getDeleteAccount();

                                                        _getDeleteAllData();
                                                        Navigator.push(
                                                            context,
                                                            CupertinoPageRoute(
                                                                builder: (context) =>
                                                                const LoginScreen())); // Confirm deletion
                                                      },
                                                      child: Text(
                                                          AppLocalizations.of(
                                                              context)!
                                                              .delete),
                                                    ),
                                                    SizedBox(
                                                      width: 20.w,
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop(
                                                            false); // Cancel deletion
                                                      },
                                                      child: Text(
                                                          AppLocalizations.of(
                                                              context)!
                                                              .cancel),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        },
                                        child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: AppColors.red,
                                                borderRadius:
                                                BorderRadius.circular(6)),
                                            height: 32.h,
                                            width: 130.w,
                                            margin: EdgeInsets.only(top: 10.h),
                                            child: CustomText(
                                              text: AppLocalizations.of(context)!
                                                  .deleteAcount,
                                              size: 10.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.pureWhiteColor,
                                            )),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 60.h,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )));
          }
      // if (state is UserProfileLoading) {
      //   return Positioned(
      //       top: 200.h, left: 40.w, right: 40.w, child: const ProfileShimmer());
      // }
      return Positioned(
          top: 230,
          left: 18.w,
          right: 18.w,
          bottom: 0,
          child: SingleChildScrollView(
              child: Container(
                // height: 563.h,
                width: 350.w,
                decoration: BoxDecoration(
                  // color: AppColors.red
                  color: Theme.of(context).colorScheme.backGroundColor,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    isEdit =
                                    !isEdit!; // Toggle the value of isEdit
                                  });
                                  // nameFocusNode.requestFocus();
                                },
                                child: HeroIcon(
                                  isEdit!
                                      ? HeroIcons.arrowUturnLeft
                                      : HeroIcons.pencilSquare,
                                  style: HeroIconStyle.outline,
                                  size: 18.sp,
                                  color:
                                  Theme.of(context).colorScheme.textClrChange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CustomTextFields(
                            title: AppLocalizations.of(context)!.firstname,
                            hinttext: "",
                            controller:
                            TextEditingController(text: firstNameWidget),
                            onchange: (value) {
                              demo = value;
                              firstNameWidget = value;
                              nameController.text = value!;
                            },
                            onSaved: (value) {
                              firstNameWidget = value;
                              nameController.text = value!;
                            },
                            readonly: isEdit == true ? false : true,
                            onFieldSubmitted: (value) {
                              // _fieldFocusChange(
                              //   context,
                              //   budgetFocus!,
                              //   descFocus,
                              // );
                            },
                            isLightTheme: isLightTheme,
                            isRequired: false),
                        SizedBox(
                          height: 10.h,
                        ),
                        CustomTextFields(
                            title: AppLocalizations.of(context)!.lastname,
                            hinttext: "",
                            controller: lastnameController,
                            onSaved: (value) {},
                            readonly: isEdit == true ? false : true,
                            isLightTheme: isLightTheme,
                            isRequired: false),
                        SizedBox(
                          height: 10.h,
                        ),
                        CustomTextFields(
                            title: AppLocalizations.of(context)!.email,
                            hinttext: "",
                            controller: emailController,
                            onSaved: (value) {},
                            readonly: isEdit == true &&
                                hasPermission == true &&
                                role == "admin"
                                ? true
                                : false,
                            onFieldSubmitted: (value) {
                              // _fieldFocusChange(
                              //   context,
                              //   budgetFocus!,
                              //   descFocus,
                              // );
                            },
                            isLightTheme: isLightTheme,
                            isRequired: false),
                        SizedBox(
                          height: 10.h,
                        ),
                        CustomTextFields(
                            isPassword: true,
                            title: AppLocalizations.of(context)!.password,
                            hinttext:
                            AppLocalizations.of(context)!.pleaseenterpassword,
                            readonly: isEdit == true ? false : true,
                            controller: passwordController,
                            onSaved: (value) {},
                            onFieldSubmitted: (value) {},
                            isLightTheme: isLightTheme,
                            isRequired: false),
                        SizedBox(
                          height: 10.h,
                        ),
                        CustomTextFields(
                            isPassword: true,
                            title: AppLocalizations.of(context)!.conPassword,
                            hinttext: AppLocalizations.of(context)!
                                .pleaseenterconpassword,
                            controller: conpasswordController,
                            readonly: isEdit == true ? false : true,
                            onSaved: (value) {},
                            onFieldSubmitted: (value) {},
                            isLightTheme: isLightTheme,
                            isRequired: false),
                        SizedBox(
                          height: 10.h,
                        ),
                        CustomTextFields(
                            title: AppLocalizations.of(context)!.address,
                            hinttext: "",
                            controller: addressController,
                            onSaved: (value) {},
                            readonly: isEdit == true ? false : true,
                            onFieldSubmitted: (value) {
                              // _fieldFocusChange(
                              //   context,
                              //   budgetFocus!,
                              //   descFocus,
                              // );
                            },
                            isLightTheme: isLightTheme,
                            isRequired: false),
                        SizedBox(
                          height: 10.h,
                        ),
                        CustomTextFields(
                            title: AppLocalizations.of(context)!.city,
                            hinttext: "",
                            controller: cityController,
                            onSaved: (value) {},
                            readonly: isEdit == true ? false : true,
                            onFieldSubmitted: (value) {
                              // _fieldFocusChange(
                              //   context,
                              //   budgetFocus!,
                              //   descFocus,
                              // );
                            },
                            isLightTheme: isLightTheme,
                            isRequired: false),
                        SizedBox(
                          height: 10.h,
                        ),
                        _phoneNumberField(isLightTheme, isEdit),
                        SizedBox(
                          height: 30.h,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          child: Row(
                            mainAxisAlignment: isEdit == false
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.center,
                            children: [
                              isEdit == true
                                  ? InkWell(
                                splashColor: Colors.transparent,
                                onTap: () {
                                  if(!isDemo ){
                                    flutterToastCustom(msg: AppLocalizations.of(context)!.isDemooperation);

                                  }else {
                                    // if (passwordController.text.isNotEmpty && conpasswordController.text.isNotEmpty) {
                                    if (passwordController.text !=
                                        conpasswordController.text) {
                                      flutterToastCustom(
                                        msg: AppLocalizations.of(context)!
                                            .passworddomntmatch,
                                      );
                                    } else {
                                      context
                                          .read<UserProfileBloc>()
                                          .add(ProfileDetailsUpdateList(
                                        firstname:
                                        nameController.text.isEmpty
                                            ? firstNameWidget!
                                            : nameController.text,
                                        lastname: lastnameController
                                            .text.isEmpty
                                            ? lastNameWidget!
                                            : lastnameController.text,
                                        role: selectedRoleId != null
                                            ? int.tryParse(selectedRoleId
                                            .toString()) ??
                                            0 // Default to 0 if parsing fails
                                            : int.tryParse(roleInWidget
                                            .toString()) ??
                                            0,
                                        email:
                                        emailController.text.isEmpty
                                            ? emailWidget!
                                            : emailController.text,
                                        address:
                                        addressController.text.isEmpty
                                            ? addressWidget!
                                            : addressController.text,
                                        password: passwordController
                                            .text.isEmpty
                                            ? passwordWidget
                                            : passwordController.text,
                                        conPassword: conpasswordController
                                            .text.isEmpty
                                            ? conasswordWidget
                                            : conpasswordController.text,
                                        phone:
                                        phoneController.text.isEmpty
                                            ? phoneInWidget!
                                            : phoneController.text,
                                        countryCode: countryCode!,
                                        countryIsoCode: countryIsoCode!,
                                        city: cityController.text.isEmpty
                                            ? cityINWidget!
                                            : cityController.text,
                                      ));
                                      final todosBloc =
                                      BlocProvider.of<UserProfileBloc>(
                                          context);
                                      todosBloc.stream.listen((state) {
                                        if (state
                                        is UserDetailUpdateSuccess) {

                                          navigatorKey.currentContext!
                                                .read<UserProfileBloc>()
                                                .add(ProfileListGet());
                                            flutterToastCustom(
                                                msg: AppLocalizations.of(
                                                    navigatorKey.currentContext!)!
                                                    .updatedsuccessfully,
                                                color: AppColors.primary);
                                            isEdit = false;
                                          }

                                        if (state is UserDetailUpdateError) {
                                          flutterToastCustom(
                                              msg: state.error);
                                        }
                                      });
                                    }
                                  }
                                },
                                child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius:
                                        BorderRadius.circular(6)),
                                    height: 32.h,
                                    width: 130,
                                    margin: EdgeInsets.only(top: 10.h),
                                    child: CustomText(
                                      text: AppLocalizations.of(context)!
                                          .update,
                                      size: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.pureWhiteColor,
                                    )),
                              )
                                  : const SizedBox.shrink(),
                              role == "admin"
                                  ? SizedBox()
                                  : Padding(
                                padding:
                                EdgeInsets.symmetric(horizontal: 10.w),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                  if(isDemo ){
                                    flutterToastCustom(msg: AppLocalizations.of(context)!.isDemooperation);

                                  }else{
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(10
                                                .r), // Set the desired radius here
                                          ),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .alertBoxBackGroundColor,
                                          title: Text(
                                              AppLocalizations.of(context)!
                                                  .confirmDelete),
                                          content: Text(AppLocalizations.of(
                                              context)!
                                              .areyousureyouwanttodeleteaccount),
                                          actions: [
                                            TextButton(
                                              onPressed: () async {
                                                AccountDeletion()
                                                    .getDeleteAccount();

                                                _getDeleteAllData();
                                                Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(
                                                        builder: (context) =>
                                                        const LoginScreen())); // Confirm deletion
                                              },
                                              child: Text(
                                                  AppLocalizations.of(
                                                      context)!
                                                      .delete),
                                            ),
                                            SizedBox(
                                              width: 20.w,
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(
                                                    false); // Cancel deletion
                                              },
                                              child: Text(
                                                  AppLocalizations.of(
                                                      context)!
                                                      .cancel),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                  },
                                  child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: AppColors.red,
                                          borderRadius:
                                          BorderRadius.circular(6)),
                                      height: 32.h,
                                      width: 130.w,
                                      margin: EdgeInsets.only(top: 10.h),
                                      child: CustomText(
                                        text: AppLocalizations.of(context)!
                                            .deleteAcount,
                                        size: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.pureWhiteColor,
                                      )),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 60.h,
                        ),
                      ],
                    ),
                  ),
                ),
              )));
    });
  }

  Widget _phoneNumberField(isLightTheme, isEdit) {
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
            size: 16.sp,
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
              SizedBox(
                // color: Colors.red,
                width: 70.w,
                child: isEdit == false
                    ? SizedBox(
                        child: Center(
                            child: CustomText(
                          text:  context.read<UserProfileBloc>().countryCode != null && context.read<UserProfileBloc>().countryCode != ""
                              ? context.read<UserProfileBloc>().countryCode!
                              : "",
                          fontWeight: FontWeight.w500,
                          size: 14.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                        )),
                      )
                    : CountryCodePicker(
                        dialogBackgroundColor:
                            Theme.of(context).colorScheme.containerDark,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                        padding: EdgeInsets.zero,
                        showFlag: false,
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
                child: Container(
                  padding: EdgeInsets.zero,
                  // color: Colors.yellow,
                  child: TextFormField(
                    readOnly: isEdit == true ? false : true,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                    controller: TextEditingController(text: context.read<UserProfileBloc>().phone),
                    keyboardType: TextInputType.number,
                    validator: (val) => StringValidation.validateField(
                      val!,
                      AppLocalizations.of(context)!.required,
                    ),
                    decoration: InputDecoration(
                      // labelText: "firstname",
                      hintText:
                          AppLocalizations.of(context)!.pleaseenterphonenumber,
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
                      contentPadding: EdgeInsets.only(
                          bottom: (50.h - 30.h) / 2,
                          left: 10.w,
                          right: 10.w), // Center the text vertically
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

  Widget _profileEdit() {

    return Positioned(
      top: 170.h,
      right: 130.w,
      child:BlocBuilder<UserProfileBloc, UserProfileState>(builder: (context, state) {
        if (state is UserProfileError ) {
          flutterToastCustom(msg: state.error);
        }
        return InkWell(
          splashColor: Colors.transparent,
          onTap: () {
            // if(isDemo ){
            //   flutterToastCustom(msg: AppLocalizations.of(context)!.isDemooperation);
            // }else{
              _showModalBottomSheet(context);
              BlocProvider.of<UserProfileBloc>(context).add(ProfileListGet());
            // }

          },
          child: Container(
            height: 30.h,
            width: 30.w,
            decoration: BoxDecoration(
              // boxShadow: [
              //   isLightTheme
              //       ? MyThemes.lightThemeShadow
              //       : MyThemes.darkThemeShadow,
              // ],
                color: Theme
                    .of(context)
                    .colorScheme
                    .backGroundColor,
                borderRadius: BorderRadius.circular(50)),
            child: HeroIcon(
              size: 18.sp,
              HeroIcons.pencilSquare,
              style: HeroIconStyle.outline,
              color: Theme
                  .of(context)
                  .colorScheme
                  .textClrChange,
            ),
          ),
        );
      }));
  }

  Widget _profilePicture() {
    return BlocConsumer<ProfilePicBloc, ProfilePicState>(
      listener: (context, state) {

        if (state is ImagePickerSuccess) {

        }
        if (state is ImagePickerFailure) {

        }
      },
      builder: (context, state) {

        if (state is ImagePickerLoading) {
          return Padding(
              padding: EdgeInsets.only(top: 100.h),
              child: SizedBox(
                width: 430.w,
                // alignment: Alignment.center,
                child: CircleAvatar(
                    radius: 60.r,
                    backgroundColor: Theme.of(context).colorScheme.backGroundColor,
                    child: CircleAvatar(
                      radius: 56.r,
                      backgroundColor: Colors.grey[200],
                      child: SpinKitFadingCircle(
                        color: AppColors.primary,
                        size: 40.sp,
                      ),
                    )),
              ));
        }
        if (state is ImagePickerSuccess) {
          return Padding(
            padding: EdgeInsets.only(top: 100.h),
            child: SizedBox(
              width: 430.w,
              // alignment: Alignment.center,
              child: CircleAvatar(
                  radius: 60.r,
                  backgroundColor:
                      Theme.of(context).colorScheme.backGroundColor,
                  child: CircleAvatar(
                    radius: 56.r,
                    backgroundImage: FileImage(File(state.image.path)),

                    // backgroundImage: NetworkImage(profilephoto!),
                    backgroundColor: Colors.grey[200],
                  )),
            ),
          );
        }
        else if (state is ImagePickerFailure) {
            flutterToastCustom(msg: state.error);
          return  Padding(
            padding: EdgeInsets.only(top: 100.h),
            child: SizedBox(
                width: 430.w,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor:
                  Theme.of(context).colorScheme.backGroundColor,
                  child: CircleAvatar(
                    radius: 56,
                    backgroundImage: NetworkImage(photoWidget!),
                  ),
                )),
          );

        }
        else if (state is ImagePickerInitial) {

          return Padding(
            padding: EdgeInsets.only(top: 100.h),
            child: SizedBox(
                width: 430.w,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor:
                      Theme.of(context).colorScheme.backGroundColor,
                  child: CircleAvatar(
                    radius: 56,
                    backgroundImage: NetworkImage(photoWidget!),
                  ),
                )),
          );
        }
        return Padding(
          padding: EdgeInsets.only(top: 100.h),
          child: SizedBox(
            width: 430.w,
            // alignment: Alignment.center,
            child: CircleAvatar(
                radius: 60.r,
                backgroundColor: Theme.of(context).colorScheme.backGroundColor,
                child: CircleAvatar(
                  radius: 56.r,
                  backgroundImage: NetworkImage(photoWidget!),

                  // backgroundImage: NetworkImage(profilephoto!),
                  backgroundColor: Colors.grey[200],
                )),
          ),
        );
      },
    );
  }

  Widget _profileAppbar() {
    return Positioned(
      top: 50.h,
      child: SizedBox(
        width: MediaQuery.of(context).size.width, // Full width of the screen
        // color: Colors.orange,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  BlocProvider.of<UserProfileBloc>(context).add(ProfileList());
                  BlocProvider.of<UserProfileBloc>(context).add(ProfileListGet());

                    router.pop(context);

                },
                child: Container(
                  height: 30.h,
                  width: 30.w,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: AppColors.pureWhiteColor),
                  child: isRtl
                      ? HeroIcon(
                          size: 18.sp,
                          HeroIcons.chevronRight,
                          style: HeroIconStyle.outline,
                          color: AppColors.primary,
                        )
                      : HeroIcon(
                          size: 18.sp,
                          HeroIcons.chevronLeft,
                          style: HeroIconStyle.outline,
                          color: AppColors.primary,
                        ),
                ),
              ),
              SizedBox(
                width: 50.w,
              ),
              // First item (centered)
              Container(
                // Adjust padding as needed
                // color: Colors.teal,
                alignment: Alignment.center, // Center the item
                child: CustomText(
                  text: AppLocalizations.of(context)!.profile,
                  fontWeight: FontWeight.w700,
                  size: 20,
                  color: AppColors.pureWhiteColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
