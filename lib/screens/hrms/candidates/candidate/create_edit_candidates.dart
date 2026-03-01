import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/bloc/candidate/candidates_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../bloc/candidate/candidates_bloc.dart';
import '../../../../bloc/candidate/candidates_event.dart';
import '../../../../bloc/permissions/permissions_bloc.dart';
import '../../../../bloc/permissions/permissions_event.dart';
import '../../../../bloc/theme/theme_bloc.dart';
import '../../../../bloc/theme/theme_state.dart';
import '../../../../config/internet_connectivity.dart';
import '../../../../data/model/candidate/candidate_model.dart';
import '../../../../routes/routes.dart';
import '../../../../src/generated/i18n/app_localizations.dart';import '../../../../utils/widgets/back_arrow.dart';
import '../../../../utils/widgets/custom_text.dart';
import '../../../../utils/widgets/my_theme.dart';
import '../../../../utils/widgets/no_internet_screen.dart';
import '../../../../utils/widgets/toast_widget.dart';
import '../../../widgets/custom_cancel_create_button.dart';
import '../../../widgets/custom_container.dart';
import '../../../widgets/custom_textfields/custom_textfield.dart';
import '../../../widgets/validation.dart';
import '../../widgets/candidate_status_widget.dart';

class CreateEditCandidates extends StatefulWidget {
  final bool? isCreate;
  final CandidateModel? candidateModel;
  const CreateEditCandidates({super.key, this.isCreate, this.candidateModel});

  @override
  State<CreateEditCandidates> createState() => _CreateEditCandidatesState();
}

class _CreateEditCandidatesState extends State<CreateEditCandidates> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  String? selectedColorName;
  bool? isLoading;
  int? candidateId;
  CandidateModel? currentCandidate;
  String? filepath;
  ValueNotifier<List<File>> selectedFilesNotifier = ValueNotifier([]);

  List<File>? pickedFile;


  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController(text: "");
  TextEditingController positionController = TextEditingController(text: "");
  TextEditingController sourceController = TextEditingController(text: "");

  String? selectedStatus;
  int? selectedStatusId;

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
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
    if (widget.isCreate == false && widget.candidateModel != null) {
      _setupEditMode();
    }
  }

  void _setupEditMode() {
    candidateId = widget.candidateModel!.id;
    currentCandidate = widget.candidateModel!;
    selectedStatus= widget.candidateModel!.status!.name;
    selectedStatusId= widget.candidateModel!.status!.id;
    _initializeControllers();
  }

  void _initializeControllers() {
    nameController.text = currentCandidate!.name ?? '';
    emailController.text = currentCandidate!.email ?? '';
    phoneController.text = currentCandidate!.phone ?? '';
    positionController.text = currentCandidate!.position ?? '';
    sourceController.text = currentCandidate!.source ?? '';
  }
  void _handleStatusSelected(String? status, int? statusId) {
    setState(() {
      selectedStatus = status;
      selectedStatusId = statusId;
    });
  }
  void _validateAndSubmitForm() {


    if (widget.isCreate == true) {
      _onCreateCandidate();
    } else {
       _onEditCandidate(currentCandidate!);
    }
  }
  void _onCreateCandidate() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final position = positionController.text.trim();
    final source = sourceController.text.trim();

    final emailError = StringValidation.validateEmail(email); // 👈 your function

    if (name.isNotEmpty &&
        email.isNotEmpty &&
        emailError == null &&
        selectedStatusId != null &&
        position.isNotEmpty &&
        source.isNotEmpty) {

      context.read<CandidatesBloc>().add(
        CreateCandidates(
          name: name,
          email: email,
          phone: phone,
          position: position,
          source: source,
          statusId: selectedStatusId!,
          attachment: selectedFilesNotifier.value,
        ),
      );
    } else {
      String errorMessage;

      if (emailError != null) {
        errorMessage = emailError;
      } else {
        errorMessage = AppLocalizations.of(context)!.pleasefilltherequiredfield;
      }

      flutterToastCustom(msg: errorMessage);
    }
  }


  void _onEditCandidate(candidate) async {
    if (nameController.text.isNotEmpty && emailController.text.isNotEmpty && selectedStatusId != null && positionController.text.isNotEmpty && sourceController.text.isNotEmpty) {
print("fjedmc ${currentCandidate!.id}");
        CandidateModel model= CandidateModel(
          id: currentCandidate!.id!,
          name: nameController.text,
          email: emailController.text,
          phone: phoneController.text.isNotEmpty ?phoneController.text :widget.candidateModel!.phone,
          position: positionController.text.isNotEmpty ?positionController.text :widget.candidateModel!.position,
          source: sourceController.text.isNotEmpty ?sourceController.text :widget.candidateModel!.source,

        );
      context.read<CandidatesBloc>().add(UpdateCandidates(
          model,selectedFilesNotifier.value,selectedStatus !=null ?selectedStatusId!:widget.candidateModel!.status!.id!));
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
    Navigator.pop(context);
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: [
        'pdf', 'doc', 'docx', 'xls', 'jpg', 'xlsx', 'png', 'zip', 'rar', 'txt'
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
  Widget _buildFileNameText(bool isLightTheme) {
    return SizedBox(
      width: 180.w,
      child: CustomText(
        overflow: TextOverflow.ellipsis,
        text: filepath ?? AppLocalizations.of(context)!.nofilechosen,
        fontWeight: FontWeight.w400,
        size: 14.sp,
        maxLines: 2,
        color: Theme.of(context).colorScheme.textClrChange,
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
                      // _refreshClientData();
                    } else {
                      router.pop();
                    }
                    router.pop();                  },
                  title: widget.isCreate == true
                      ? AppLocalizations.of(context)!.addnewcandidate
                      : AppLocalizations.of(context)!.updatecandidate,
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
    return BlocConsumer<CandidatesBloc, CandidatesState>(
      listener: (context, state) {
        if(state is CandidatesCreateError){
          flutterToastCustom(msg: state.errorMessage);
          context.read<CandidatesBloc>().add(const CandidatesList());

        } if(state is CandidatesError){
          flutterToastCustom(msg: state.errorMessage);
          context.read<CandidatesBloc>().add(const CandidatesList());

        } if(state is CandidatesEditError){
          flutterToastCustom(msg: state.errorMessage);
          // context.read<CandidatesBloc>().add(const CandidatesList());

        }
        if(state is CandidatesCreateSuccess){
          context.read<CandidatesBloc>().add(const CandidatesList());
          if (mounted) {
            Navigator.pop(context);
            // router.go('/notes');
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.createdsuccessfully,
                color: AppColors.primary);
          }
        }
        if(state is CandidatesEditSuccess){
          context.read<CandidatesBloc>().add(const CandidatesList());
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
        final isLoading = state is CandidatesLoading || state is CandidatesEditSuccessLoading;
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

  Widget _buildFormFields(isLightTheme) {
    return Column(
      children: [
        CustomTextFields(
          title: AppLocalizations.of(context)!.fullname,
          hinttext: AppLocalizations.of(context)!.pleaseenterfullname,
          controller: nameController,
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
          hinttext: AppLocalizations.of(context)!.pleaseenteremail,
          controller: emailController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: true,
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          title: AppLocalizations.of(context)!.phonenumber,
          hinttext: AppLocalizations.of(context)!.pleaseenterphonenumber,
          controller: phoneController,
          keyboardType: TextInputType.phone,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: false,
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          title: AppLocalizations.of(context)!.position,
          hinttext: AppLocalizations.of(context)!.position,
          controller: positionController,
          keyboardType: TextInputType.text,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: true,
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          title: AppLocalizations.of(context)!.source,
          hinttext: AppLocalizations.of(context)!.source,
          controller: sourceController,
          keyboardType: TextInputType.text,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: true,
        ),
        SizedBox(
          height: 15.h,
        ),
        _buildFilePickerContainer(isLightTheme),
        SizedBox(
          height: 15.h,
        ),
        SingleCandidateStatusField(
            isRequired: true,
            isCreate: widget.isCreate!,
            username: selectedStatus ?? "",
            status: const [],
            candidatesStatusId: selectedStatusId,
            onSelected: _handleStatusSelected),
        SizedBox(
          height: 25.h,
        ),
      ],
    );
  }

  Widget _buildFilePickerContainer(bool isLightTheme) {
    print("klgrj v ${selectedFilesNotifier.value.isNotEmpty}");
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: customContainer(
          width: 600.w,
          context: context,
          addWidget: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomText(
                      text: AppLocalizations.of(context)!.attachment,
                      // text: getTranslated(context, 'myweeklyTask'),
                      color: Theme.of(context).colorScheme.textClrChange,
                      size: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    CustomText(
                      text: AppLocalizations.of(context)!.optional,
                      // text: getTranslated(context, 'myweeklyTask'),
                      color: AppColors.greyColor,
                      size: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
                Container(
                  height: 40.h,
                  width: double.infinity,
                  // margin: const EdgeInsets.symmetric(horizontal: 20),
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
                ),
                SizedBox(
                  height: 10.h,
                ),
                ValueListenableBuilder<List<File>>(
                  valueListenable: selectedFilesNotifier,
                  builder: (context, files, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: AppLocalizations.of(context)!.acceptedfile,
                          color: AppColors.greyColor,
                          size: 12,
                          fontWeight: FontWeight.w700,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (files.isNotEmpty) _buildProfileAvatar(files),
                      ],
                    );
                  },
                )

              ],
            ),
          )),
    );
  }

  Widget _buildProfileAvatar(List<File> files) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 20.h),
      child: Container(
        height: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: files.isNotEmpty
            ? PageView.builder(
          controller: PageController(viewportFraction: 0.6),
          itemCount: files.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      files[index],
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      selectedFilesNotifier.value = List.from(files)..removeAt(index);
                    },
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.black.withValues(alpha: 0.6),
                      child: Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        )
            : Center(child: _buildDefaultAvatar()),
      ),
    );
  }


  Widget _buildDefaultAvatar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person, size: 80, color: Colors.grey),
        SizedBox(height: 10),
        Text(
          "No Image Selected",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // ImageProvider? _getProfileImage() {
  //
  //   return  FileImage(File(pickedFile!.path)) as ImageProvider;
  // }
  Widget _buildFilePickerButton(bool isLightTheme) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: _pickFile,
      child: CustomText(
        text: AppLocalizations.of(context)!.choosefile,
        fontWeight: FontWeight.w400,
        size: 14.sp,
        color: Theme.of(context).colorScheme.textClrChange,
      ),
    );
  }
}
