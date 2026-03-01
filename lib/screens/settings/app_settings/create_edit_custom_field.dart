import 'package:flutter/material.dart';

import 'package:heroicons/heroicons.dart';
import 'package:taskify/bloc/custom_fields/custom_field_bloc.dart';
import 'package:taskify/bloc/permissions/permissions_event.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/data/model/custom_field/custom_field_model.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../bloc/clients/client_bloc.dart';
import '../../../bloc/clients/client_event.dart';
import '../../../bloc/clients/client_state.dart';
import '../../../bloc/custom_fields/custom_field_event.dart';
import '../../../bloc/custom_fields/custom_field_state.dart';
import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../config/internet_connectivity.dart';
import '../../../routes/routes.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_switch.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/no_internet_screen.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../hrms/widgets/constList.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../widgets/custom_textfields/custom_textfield.dart';

class CreateEditCustomFieldScreen extends StatefulWidget {
  final bool? isCreate;

  final CustomFieldModel? customFieldModel;
  const CreateEditCustomFieldScreen({
    super.key,
    this.isCreate,
    this.customFieldModel,
  });

  @override
  State<CreateEditCustomFieldScreen> createState() =>
      _CreateEditCustomFieldScreenState();
}

class _CreateEditCustomFieldScreenState
    extends State<CreateEditCustomFieldScreen> {
  // State variables
  CustomFieldModel? currentCustomField;
  String? countryCode;
  String? countryIsoCode;

  bool? isLoading;
  int? clientId;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isRequired = false;
  bool istableShown = false;

  // Form controllers

  final TextEditingController fieldLabelController = TextEditingController();
  List<TextEditingController> optionControllers = [];

  String selectedMode = "";
  String selectedFieldType = "";

  // Connectivity
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  ConnectivityResult connectivityCheck = ConnectivityResult.none;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
    _initializePermissions();
    _initializeClientData();
      // optionControllers.add(TextEditingController());

  }

  void _addOptionField() {
    setState(() {
      optionControllers.add(TextEditingController());
    });
  }

  void _removeOptionField(int index) {
    setState(() {
      optionControllers[index].dispose();
      optionControllers.removeAt(index);
    });
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

  List<String> getOptionValuesList() {
    return optionControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty) // optional: ignore empty values
        .toList();
  }

  String getOptionValuesCommaSeparated() {
    return getOptionValuesList().join(', ');
  }

  void _initializePermissions() {
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
  }

  void _initializeClientData() {
    if (widget.isCreate == false && widget.customFieldModel != null) {
      _setupEditMode();
    }
  }

  void _setupEditMode() {
    clientId = widget.customFieldModel!.id;
    currentCustomField = widget.customFieldModel!;
    selectedMode = currentCustomField!.module!;
    fieldLabelController.text = currentCustomField!.fieldLabel!;
    selectedFieldType = currentCustomField!.fieldType!;
    final options = currentCustomField?.options ?? [];
    optionControllers =
        options.map((opt) => TextEditingController(text: opt)).toList();
    print("optionserreer  ${optionControllers.length}");
    isRequired = currentCustomField!.required == "1" ? true : false;
    istableShown = currentCustomField!.showInTable == "1" ? true : false;

    _initializeControllers();
  }

  void _initializeControllers() {
    // filepath = currentCustomField!.profile;
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _disposeControllers();
    for (var controller in optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _disposeControllers() {
    fieldLabelController.dispose();
  }

  // Helper Methods

  void _handleModeSelected(String? mode) {
    setState(() {
      selectedMode = mode!;
    });
  }

  void _handleFieldTypeSelected(String? mode) {
    setState(() {
      selectedFieldType = mode!;
    });
    print(" fvmvc $selectedFieldType");
  }

  void _refreshClientData() {
    // BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask(clientId: []));
    // BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList(clientId: [widget.clientModel!.id!]));
    // BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    // BlocProvider.of<ClientidBloc>(context).add(ClientIdListId(widget.clientModel!.id!));
    // BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
    router.pop();
  }

  // Form Validation Methods
  bool _validateRequiredFields() {
    print("crtyuhi ${fieldLabelController.text}  ${selectedMode}");
    return fieldLabelController.text.isNotEmpty && selectedMode != "";
  }

  void _validateAndSubmitForm() {
    if (!_validateRequiredFields()) {
      flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleasefilltherequiredfield);
      return;
    }

    if (widget.isCreate == true) {
      onCreateCustomField();
    } else {
      onUpdateCustomField(currentCustomField!);
    }
  }

  // Client Operations
  void onCreateCustomField() {
    isLoading = true;
    final newCustomField = _buildCustomFieldModel(isCreate: true);
    context.read<CustomFieldBloc>().add(CreateCustomField(
          customModel: newCustomField,
        ));
    _listenCustomFieldBloc(context.read<CustomFieldBloc>());
  }

  void onUpdateCustomField(CustomFieldModel currentCustonField) {

    isLoading = true;
    final CustomFieldModel updatedFields = currentCustonField.copyWith(
      id: currentCustonField.id,
      module: selectedMode.toLowerCase(),
      fieldType: selectedFieldType.toLowerCase().replaceAll(' ', ''),
      fieldLabel: fieldLabelController.text,
      required: isRequired == true ? "1" : "0",
      options: getOptionValuesList(),
      showInTable: istableShown == true ? "1" : "0",
    );

    BlocProvider.of<CustomFieldBloc>(context).add(UpdateCustomField(customModel: updatedFields));

    _listenCustomFieldBloc(context.read<CustomFieldBloc>());
  }

  CustomFieldModel _buildCustomFieldModel({bool isCreate = false}) {
    print("fgvhbjn $isRequired");
    print("fgvhbjn $istableShown");
    return CustomFieldModel(
      module: selectedMode.toLowerCase(),
      fieldType: selectedFieldType.toLowerCase().replaceAll(' ', ''),
      fieldLabel: fieldLabelController.text,
      required: isRequired == true ? "1" : "0",
      options: getOptionValuesList(),
      showInTable: istableShown == true ? "1" : "0",

    );
  }

  void _listenCustomFieldBloc(CustomFieldBloc bloc) {
    print("tyguhio ");
    bloc.stream.listen((state) {
      print("tyguhio we $state ");
      if (state is CustomFieldCreateSuccess) {
        _handleCustomFieldSuccess();
      } else if (state is CustomFieldCreateError) {
        _handleCustomFieldError(state.errorMessage);
      } else if (state is ClientEditSuccess) {
        _handleCustomFieldEditSuccess();
      } else if (state is CustomFieldEditError) {
        _handleCustomFieldError(state.errorMessage);
      }
    });
  }

  void _handleCustomFieldSuccess() {
    isLoading = false;
    if (mounted) {
      flutterToastCustom(
          msg: AppLocalizations.of(context)!.createdsuccessfully,
          color: AppColors.primary);
      context.read<CustomFieldBloc>().add(CustomFieldLists());
      Navigator.pop(context);
    }
  }

  void _handleCustomFieldEditSuccess() {
    if (mounted) {
      isLoading = false;
      context.read<ClientBloc>().add(ClientList());
      _refreshClientData();
      Navigator.pop(context);
      flutterToastCustom(
          msg: AppLocalizations.of(context)!.updatedsuccessfully,
          color: AppColors.primary);
    }
  }

  void _handleCustomFieldError(String errorMessage) {
    isLoading = false;
    flutterToastCustom(msg: errorMessage);
  }

  // UI Components

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
                if (widget.isCreate == false) {
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
                    if (widget.isCreate == false) {
                      _refreshClientData();
                    } else {
                      router.pop();
                    }
                  },
                  title: widget.isCreate == true
                      ? AppLocalizations.of(context)!.createcustomfield
                      : AppLocalizations.of(context)!.editcustomfield,
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
            SizedBox(
              height: 20.h,
            ),
            _buildActionButtons(),
            SizedBox(
              height: 40.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields(bool isLightTheme) {
    print("fghj ${optionControllers.length}");
    print("fghj ${optionControllers}");
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSelectField(
              title: AppLocalizations.of(context)!.module,
              items: ["Project", "Task"],
              initialValue: selectedMode,
              isCreate: true,
              isRequired: true,
              onSelected: _handleModeSelected),
          SizedBox(height: 15.h),
          _buildTextField(
            title: AppLocalizations.of(context)!.fieldlabel,
            hint: AppLocalizations.of(context)!.fieldlabel,
            controller: fieldLabelController,
            isRequired: true,
          ),
          SizedBox(height: 15.h),
          _buildIsRequiredSwitch(),
          SizedBox(height: 15.h),
          CustomSelectField(
              title: AppLocalizations.of(context)!.fieldtype,
              items: [
                "Text",
                "Number",
                "Password",
                "Text Area",
                "Radio",
                "Date",
                "Check Box",
                "Select"
              ],
              initialValue: selectedFieldType,
              isCreate: true,
              isRequired: true,
              onSelected: _handleFieldTypeSelected),
          // SizedBox(height: 15.h),
          // _buildIsTableRequired(),
          SizedBox(height: 15.h),
          if (selectedFieldType == "Check Box" ||
              selectedFieldType == "checkbox" ||
              selectedFieldType == "Radio" ||
              selectedFieldType == "radio" ||
              selectedFieldType == "Select" ||
              selectedFieldType == "select")
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: CustomText(
                text: AppLocalizations.of(context)!.options,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16.sp,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (selectedFieldType == "Check Box" ||
              selectedFieldType == "checkbox" ||
              selectedFieldType == "Radio" ||
              selectedFieldType == "radio" ||
              selectedFieldType == "Select" ||
              selectedFieldType == "select") ...[
            // Build a text field for each option controller
            for (int i = 0; i < optionControllers.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Stack(
                  children: [
                    _buildTextField(
                      title: "",
                      hint: AppLocalizations.of(context)!.options,
                      controller: optionControllers[i],
                      isRequired: false,
                    ),
                    Positioned(
                      right: 10,
                      top: -20,
                      bottom: 0,
                      child: InkWell(
                        onTap: () => _removeOptionField(i),
                        child: HeroIcon(
                          HeroIcons.minusCircle,
                          style: HeroIconStyle.solid,
                          color: Colors.red.shade400,
                          size: 25.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 20.h),

            // Add Options button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: _addOptionField,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      height: 40.h,
                      width: 100.w,
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      child: CustomText(
                        text: AppLocalizations.of(context)!.addoptions,
                        size: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.pureWhiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ]
        ]);
  }

  Widget _buildTextField({
    required String title,
    required String hint,
    required TextEditingController controller,
    bool isRequired = false,
    bool isPassword = false,
  }) {
    return CustomTextFields(
      title: title,
      hinttext: hint,
      controller: controller,
      onSaved: (value) {},
      isLightTheme: Theme.of(context).brightness == Brightness.light,
      isRequired: isRequired,
      isPassword: isPassword,
    );
  }

  Widget _buildActionButtons() {
    return BlocBuilder<CustomFieldBloc, CustomFieldState>(
      builder: (context, state) {
        final isLoading =
            state is CustomFieldCreateLoading || state is CustomFieldEditLoading;
        return CreateCancelButtom(
          isLoading: isLoading,
          isCreate: widget.isCreate,
          onpressCancel: () => Navigator.pop(context),
          onpressCreate: () => _validateAndSubmitForm(),
        );
      },
    );
  }

  Widget _buildIsRequiredSwitch() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Row(
        children: [
          IsCustomSwitch(
            isCreate: widget.isCreate,
            status: isRequired,
            onStatus: (status) => setState(() => isRequired = status),
          ),
          SizedBox(width: 20.w),
          CustomText(
            text: AppLocalizations.of(context)!.isrequired,
            fontWeight: FontWeight.w400,
            size: 12.sp,
            color: Theme.of(context).colorScheme.textClrChange,
          )
        ],
      ),
    );
  }


}
