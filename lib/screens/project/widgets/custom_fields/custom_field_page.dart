import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:taskify/bloc/custom_fields/custom_field_bloc.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/utils/widgets/no_data.dart';
import '../../../../bloc/custom_fields/custom_field_event.dart';
import '../../../../bloc/custom_fields/custom_field_state.dart';
import '../../../../bloc/theme/theme_bloc.dart';
import '../../../../bloc/theme/theme_state.dart';
import '../../../../config/constants.dart';
import '../../../../data/model/Project/all_project.dart';
import '../../../../data/model/custom_field/custom_field_model.dart';
import '../../../../src/generated/i18n/app_localizations.dart';import '../../../../utils/widgets/custom_text.dart';
import '../../../../utils/widgets/toast_widget.dart';
import '../../../widgets/custom_date.dart';
import '../../../widgets/custom_fields/customFieldRadio.dart';
import '../../../widgets/custom_fields/customfield_checkbox.dart';
import '../../../widgets/custom_fields/customfield_dropdown.dart';
import '../../../widgets/custom_textfields/custom_textfield.dart';

class CustomFieldPage extends StatefulWidget {
  final ProjectModel projectModel;
  final bool isCreate;
  final bool isDetails;
  final GlobalKey<CustomFieldPageState> key;

  const CustomFieldPage({
    required this.projectModel,
    required this.isCreate,
    this.isDetails = false,
    required this.key,
  }) : super(key: key);

  Map<String, dynamic> getFieldValues() {
    return key.currentState?.getFieldValues() ?? {};
  }

  @override
  State<CustomFieldPage> createState() => CustomFieldPageState();
}

class CustomFieldPageState extends State<CustomFieldPage> {
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, TextEditingController> _dateControllers = {};
  final Map<String, DateTime?> _selectedDateStarts = {};
  final Map<String, dynamic> _fieldValues = {};
  late List<CustomFieldModel> fields;
  bool _fieldsInitialized = false;

  @override
  void initState() {
    super.initState();
    print("ghnjk,l ${widget.projectModel.customFieldValues}");
    print('initState: isCreate = ${widget.isCreate}, projectModel.customFields = ${widget.projectModel.customFields?.map((f) => f.toJson())}');
    print('projectModel.customFieldValues = ${widget.projectModel.customFieldValues?.toJson()}');
    if (widget.isCreate) {
      BlocProvider.of<CustomFieldBloc>(context).add(CustomFieldLists());
      fields = [];
    } else {
      fields = (widget.projectModel.customFields ?? [])
          .map((f) => CustomFieldModel.fromJson(f.toJson()))
          .toList();
      print('Fields loaded in initState: ${fields.map((f) => {'id': f.id, 'type': f.fieldType, 'label': f.fieldLabel}).toList()}');
      _initializeFieldsAndControllers();
      setState(() {
        _fieldsInitialized = true;
      });
    }
  }

  void _initializeFieldsAndControllers({Map<String, dynamic>? initialValues}) {
    final rawValues = widget.isCreate ? null : widget.projectModel.customFieldValues;
    final Map<String, dynamic> initValues = initialValues ?? {};

    if (!widget.isCreate && rawValues != null) {
      final rawMap = rawValues.toJson();
      rawMap.forEach((key, value) {
        initValues[key] = value;
      });
    }

    print('Raw customFieldValues: ${widget.projectModel.customFieldValues?.toJson()}');
    print('Initializing fields: isCreate = ${widget.isCreate}, initValues = $initValues');
    print('Fields to initialize: ${fields.map((f) => {'id': f.id, 'type': f.fieldType, 'label': f.fieldLabel, 'options': f.options}).toList()}');

    if (_fieldsInitialized) {
      print('Clearing previous controllers and values');
      _textControllers.forEach((key, controller) => controller.dispose());
      _textControllers.clear();
      _dateControllers.forEach((key, controller) => controller.dispose());
      _dateControllers.clear();
      _fieldValues.clear();
      _selectedDateStarts.clear();
    }

    if (fields.isEmpty) {
      print('WARNING: No fields to initialize. Check widget.projectModel.customFields.');
    }

    for (final field in fields) {
      final fieldId = field.id.toString();
      final fieldType = field.fieldType;
      final isRequired = field.required == '1' || field.required == true;
      final value = initValues[fieldId];

      print('Initializing field $fieldId: type = $fieldType, required = $isRequired, initial value = $value, options = ${field.options}');

      switch (fieldType) {

        case 'text':
          String initialText = '';
          if (value != null) {
            if (value is List) {
              initialText = value.join(', ');
            } else {
              initialText = value.toString();
            }
          } else {
            if (!widget.isCreate) {
              print('API value for field $fieldId ($fieldType) is null and isCreate is false, setting to "select"');
              initialText = 'select';
            } else {
              print('API value for field $fieldId ($fieldType) is null and isCreate is true, setting to empty string');
              initialText = '';
            }
          }
          final controller = TextEditingController(text: initialText);
          controller.addListener(() {
            _fieldValues[fieldId] = controller.text.isEmpty ?'':controller.text;
            print('Updated _fieldValues[$fieldId] ($fieldType): ${controller.text}');
          });
          _textControllers[fieldId] = controller;
          _fieldValues[fieldId] = initialText;
          print('Initialized _fieldValues[$fieldId] ($fieldType): ${_fieldValues[fieldId]}');
          break;

        case 'number':
        case 'password':
        case 'textarea':
          String initialText = '';
          if (value != null) {
            if (value is List) {
              initialText = value.join(', ');
            } else {
              initialText = value.toString();
            }
          } else {
            print('API value for field $fieldId ($fieldType) is null, setting to empty string');
            initialText = '';
          }
          final controller = TextEditingController(text: initialText);
          controller.addListener(() {
            _fieldValues[fieldId] = controller.text.isEmpty ?'':controller.text;
            print('Updated _fieldValues[$fieldId] ($fieldType): ${controller.text}');
          });
          _textControllers[fieldId] = controller;
          _fieldValues[fieldId] = initialText;
          print('Initialized _fieldValues[$fieldId] ($fieldType): ${_fieldValues[fieldId]}');
          break;

        case 'date':
          DateTime? parsedDate;
          String formattedDate = '';
          final originalValue = initValues[fieldId];
          dynamic fieldValue = originalValue;

          if (fieldValue != null) {
            if (fieldValue is List && fieldValue.isNotEmpty && fieldValue.first is String) {
              fieldValue = fieldValue.first;
            }

            if (fieldValue is String && fieldValue.isNotEmpty) {
              try {
                parsedDate = parseDateStringFromApi(fieldValue);
                if (parsedDate.year >= 1900 && parsedDate.year <= 2100) {
                  formattedDate = dateFormatConfirmed(parsedDate, context);
                  _selectedDateStarts[fieldId] = parsedDate;
                }
              } catch (e) {
                print('Date parse failed for $fieldValue: $e');
              }
            } else if (fieldValue is int) {
              try {
                parsedDate = DateTime.fromMillisecondsSinceEpoch(fieldValue);
                if (parsedDate.year >= 1900 && parsedDate.year <= 2100) {
                  formattedDate = dateFormatConfirmed(parsedDate, context);
                  _selectedDateStarts[fieldId] = parsedDate;
                }
              } catch (e) {
                print('Timestamp parse failed for $fieldValue: $e');
              }
            }
          }

          if (widget.isCreate) {
            formattedDate = '';
          }

          final controller = TextEditingController(text: formattedDate);
          controller.addListener(() {
            _fieldValues[fieldId] = controller.text.isEmpty ?'':controller.text;
            print('Updated _fieldValues[$fieldId] (date): ${controller.text}');
          });
          _dateControllers[fieldId] = controller;
          _fieldValues[fieldId] = formattedDate;
          print('Initialized _fieldValues[$fieldId] (date): ${_fieldValues[fieldId]}');
          break;

        case 'checkbox':
          List<String> checkboxValue = [];

          if (value is List) {
            checkboxValue = List<String>.from(value)
                .where((v) => field.options?.contains(v) == true && v != '0')
                .toList();
          } else if (value is String && field.options?.contains(value) == true && value != '0') {
            checkboxValue = [value];
          }

          if (widget.isCreate && checkboxValue.isEmpty && isRequired && (field.options?.isNotEmpty ?? false)) {
            checkboxValue = [field.options!.first];
          }

          _fieldValues[fieldId] = checkboxValue;
          print('Initialized checkbox _fieldValues[$fieldId]: ${_fieldValues[fieldId]}');
          break;

        case 'select':
        case 'radio':
          String defaultValue = isRequired && (field.options?.isNotEmpty ?? false) ? field.options!.first : '';
          String selectedValue = defaultValue;
          if (value != null) {
            String stringValue = value is List && value.isNotEmpty ? value.first.toString() : value.toString();
            if (field.options?.contains(stringValue) == true) {
              selectedValue = stringValue;
            }
          }
          _fieldValues[fieldId] = selectedValue;
          print('Initialized $fieldType _fieldValues[$fieldId]: ${_fieldValues[fieldId]}');
          break;
      }
    }

    _fieldsInitialized = true;
  }

  Map<String, dynamic> getFieldValues() {
    final Map<String, dynamic> result = {};

    for (final field in fields) {
      final fieldId = field.id.toString();
      final fieldType = field.fieldType;
      if (fieldType == 'date') {
        if (_selectedDateStarts[fieldId] != null) {
          result[fieldId] = DateFormat('yyyy-MM-dd').format(_selectedDateStarts[fieldId]!);
        } else {
          result[fieldId] = _dateControllers[fieldId]?.text.isNotEmpty == true
              ? _dateControllers[fieldId]!.text
              : null;
        }
        print('Returning date for $fieldId: ${result[fieldId]}');
      } else if (['text', 'number', 'password', 'textarea'].contains(fieldType)) {
        String textValue = _textControllers[fieldId]?.text ?? '';
        result[fieldId] = textValue.isEmpty ? null : textValue;
        print('Returning text for $fieldId: ${result[fieldId]}');
      } else if (fieldType == 'checkbox') {
        final rawValue = _fieldValues[fieldId];
        if (rawValue is List) {
          result[fieldId] = rawValue.map((e) => e.toString()).toList();
        } else {
          result[fieldId] = [];
        }
        print('Returning checkbox for $fieldId: ${result[fieldId]}');
      } else if (fieldType == 'select' || fieldType == 'radio') {
        result[fieldId] = _fieldValues[fieldId]?.toString() ?? '';
        print('Returning $fieldType for $fieldId: ${result[fieldId]}');
      }
    }

    print('Field Values for API: $result');
    print('Current Custom Field Values: $_fieldValues');
    return result;
  }

  bool validateFields() {
    for (final field in fields) {
      final fieldId = field.id.toString();
      final isRequired = field.required == '1' || field.required == true;
      final fieldLabel = field.fieldLabel ?? 'Field $fieldId';
      final fieldType = field.fieldType;

      if (isRequired) {
        print('Validating required field $fieldId ($fieldLabel, type: $fieldType)');

        if (['text', 'number', 'password', 'textarea'].contains(fieldType)) {
          final controller = _textControllers[fieldId];
          final textValue = controller?.text ?? '';
          print('Text field validation - controller text: "$textValue"');

          if (textValue.isEmpty) {
            flutterToastCustom(
                msg: '$fieldLabel ${AppLocalizations.of(context)!.isrequired}',
                color: AppColors.red);
            print('Validation failed: $fieldLabel ($fieldType) is required and empty');
            return false;
          }
        } else if (fieldType == 'date') {
          final controller = _dateControllers[fieldId];
          final dateValue = controller?.text ?? '';
          print('Date field validation - controller text: "$dateValue"');

          if (dateValue.isEmpty) {
            flutterToastCustom(
                msg: '$fieldLabel ${AppLocalizations.of(context)!.isrequired}',
                color: AppColors.red);
            print('Validation failed: $fieldLabel ($fieldType) is required and empty');
            return false;
          }
        } else {
          final value = _fieldValues[fieldId];
          print('Non-text field validation - _fieldValues value: $value');

          if (fieldType == 'select' && (value == null || value.toString().isEmpty)) {
            print('Validation failed: $fieldLabel (select) is required and empty');
            flutterToastCustom(
                msg: '$fieldLabel ${AppLocalizations.of(context)!.isrequired}',
                color: AppColors.red);
            return false;
          } else if (fieldType == 'radio' && (value == null || value.toString().isEmpty)) {
            print('Validation failed: $fieldLabel (radio) is required and empty');
            flutterToastCustom(
                msg: '$fieldLabel ${AppLocalizations.of(context)!.isrequired}',
                color: AppColors.red);
            return false;
          } else if (fieldType == 'checkbox' && (value == null || (value is List && value.isEmpty))) {
            print('Validation failed: $fieldLabel (checkbox) is required and empty');
            flutterToastCustom(
                msg: '$fieldLabel ${AppLocalizations.of(context)!.isrequired}',
                color: AppColors.red);
            return false;
          }
        }
      } else {
        print('Field $fieldId ($fieldLabel, type: $fieldType) is not required');
      }
    }
    print('All required fields validated successfully');
    return true;
  }

  Widget getFieldWidget(CustomFieldModel field) {
    final themeBloc = context.read<ThemeBloc>();
    final isLightTheme = themeBloc.currentThemeState is LightThemeState;
    final fieldId = field.id.toString();
    final fieldType = field.fieldType;
    final label = field.fieldLabel;
    final isRequired = field.required == '1' || field.required == true;
    final currentFieldOptions = field.options?.cast<String>() ?? [];

    // Initialize _fieldValues[fieldId] if not set
    if (!_fieldValues.containsKey(fieldId)) {
      print('WARNING: _fieldValues[$fieldId] not initialized. Setting default value.');
      _fieldValues[fieldId] = fieldType == 'checkbox' ? [] : '';
    }

    print('Rendering field $fieldId: type = $fieldType, label = $label, isRequired = $isRequired, value = ${_fieldValues[fieldId]}, options = $currentFieldOptions');

    switch (fieldType) {
      case 'number':
      case 'text':
      case 'password':
      case 'textarea':
        if (!_textControllers.containsKey(fieldId)) {
          // Ensure _fieldValues[fieldId] is a string, default to ''
          final initialText = (_fieldValues[fieldId] ?? '').toString();
          final controller = TextEditingController(text: initialText);
          controller.addListener(() {
            _fieldValues[fieldId] = controller.text.isEmpty ?'':controller.text;
            print('Updated _fieldValues[$fieldId] ($fieldType): ${controller.text}');
          });
          _textControllers[fieldId] = controller;
          _fieldValues[fieldId] = initialText; // Update _fieldValues to ensure consistency
          print('Initialized new controller for $fieldId with text: $initialText');
        }

        // Fallback: If controller.text is null, set it to ''
        if (_textControllers[fieldId]!.text == "") {
          print('WARNING: controller.text for $fieldId is null, setting to empty string');
          _textControllers[fieldId]!.text = '';
          _fieldValues[fieldId] = '';
        }

        print('Text field $fieldId controller text: ${_textControllers[fieldId]!.text}');

        return Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: CustomTextFields(
            height: fieldType == 'textarea' ? 112.h : 42.h,
            title: label ?? '',
            hinttext: AppLocalizations.of(context)!.enter,
            controller: _textControllers[fieldId]!,
            isLightTheme: isLightTheme,
            isRequired: isRequired,
            isDetails: widget.isDetails,
            isPassword: fieldType == 'password',
            keyboardType: fieldType == 'number'
                ? TextInputType.number
                : fieldType == 'textarea'
                ? TextInputType.multiline
                : TextInputType.text,
            readonly: widget.isDetails,
            inputFormatters: fieldType == 'number' ? [FilteringTextInputFormatter.digitsOnly] : [],
            onSaved: (String? w) {},
          ),
        );

      case 'radio':
        String selectedRadio = _fieldValues[fieldId] is String ? _fieldValues[fieldId] : '';
        if (isRequired && selectedRadio.isEmpty && currentFieldOptions.isNotEmpty) {
          selectedRadio = currentFieldOptions.first;
          _fieldValues[fieldId] = selectedRadio;
        }

        if (currentFieldOptions.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
            child: CustomText(
              text: 'No options available for ${label ?? ''}',
              color: Theme.of(context).colorScheme.textClrChange,
              size: 16.sp,
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomText(
                    text: label ?? '',
                    color: Theme.of(context).colorScheme.textClrChange,
                    size: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(width: 5.w),
                  if (isRequired)
                    CustomText(
                      text: '*',
                      color: AppColors.red,
                      size: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                ],
              ),
              SizedBox(height: 10.h),
              IgnorePointer(
                ignoring: widget.isDetails,
                child: CustomRadioList(
                  isDetails: widget.isDetails,
                  options: currentFieldOptions,
                  groupValue: selectedRadio,
                  onChanged: (val) {
                    if (val != "" && val.isNotEmpty) {
                      setState(() {
                        _fieldValues[fieldId] = val;
                        print('Updated radio _fieldValues[$fieldId]: $val');
                      });
                    }
                  },
                  inactiveBorderColor: Theme.of(context).colorScheme.whitepurpleChange,
                ),
              ),
            ],
          ),
        );

      case 'checkbox':
        List<String> selectedList = [];

        if (_fieldValues[fieldId] is List) {
          selectedList = List<String>.from(_fieldValues[fieldId])
              .where((v) => field.options?.contains(v) == true && v != '0')
              .toList();
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
          child: IgnorePointer(
            ignoring: widget.isDetails,
            child: CustomFieldCheckbox(
              options: field.options!,
              selectedValues: selectedList,
              isDetails: widget.isDetails,
              onChanged: (List<String> newSelected) {
                setState(() {
                  final filtered = newSelected.where((v) => v != '0').toList();
                  _fieldValues[fieldId] = filtered;
                  print('Updated checkbox field $fieldId: ${_fieldValues[fieldId]}');
                  submitToAPI();
                });
              },
              label: label ?? '',
              required: isRequired,
              padding: EdgeInsets.zero,
            ),
          ),
        );

      case 'select':
        final dropdownItems = currentFieldOptions
            .toSet()
            .toList()
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList();

        String? selectedValueSingle = _fieldValues[fieldId] is String && currentFieldOptions.contains(_fieldValues[fieldId])
            ? _fieldValues[fieldId]
            : null;

        if (currentFieldOptions.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
            child: CustomText(
              text: 'No options available for ${label ?? ''}',
              color: Theme.of(context).colorScheme.textClrChange,
              size: 16.sp,
            ),
          );
        }

        print('Selected value for dropdown $fieldId: $selectedValueSingle');

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomText(
                    text: label ?? '',
                    color: Theme.of(context).colorScheme.textClrChange,
                    size: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  if (isRequired)
                    CustomText(
                      text: '*',
                      color: Theme.of(context).colorScheme.textClrChange,
                      size: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                ],
              ),
              SizedBox(height: 10.h),
              IgnorePointer(
                ignoring: widget.isDetails,
                child: ReusableDropdownDialog<String>(
                  items: dropdownItems,
                  isDetails: widget.isDetails,
                  value: selectedValueSingle,
                  hintText: label ?? AppLocalizations.of(context)!.enter,
                  onChanged: (val) {
                    setState(() {
                      _fieldValues[fieldId] = val ?? '';
                      print('Updated select _fieldValues[$fieldId]: ${_fieldValues[fieldId]}');
                    });
                  },
                  borderRadius: 12,
                  borderColor: Theme.of(context).colorScheme.containerDark,
                ),
              ),
            ],
          ),
        );

      case 'date':
        if (!_dateControllers.containsKey(fieldId)) {
          final controller = TextEditingController(text: (_fieldValues[fieldId] ?? '').toString());
          controller.addListener(() {
            _fieldValues[fieldId] = controller.text.isEmpty ?'':controller.text;
            print('Updated _fieldValues[$fieldId] (date): ${controller.text}');
          });
          _dateControllers[fieldId] = controller;
        }

        print('Date field $fieldId controller text: ${_dateControllers[fieldId]!.text}');

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: label ?? "",
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16.sp,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: 10.h),
              DatePickerWidget(
                isDetails: widget.isDetails,
                dateController: _dateControllers[fieldId]!,
                title: "",
                titlestartend: "",
                onTap: () async {
                  DateTime? initialDate;
                  try {
                    initialDate = _selectedDateStarts[fieldId] ??
                        (_dateControllers[fieldId]!.text.isNotEmpty
                            ? DateFormat('MM-dd-yyyy').parse(_dateControllers[fieldId]!.text)
                            : DateTime.now());
                  } catch (e) {
                    print('Failed to parse initial date for $fieldId: ${_dateControllers[fieldId]!.text}, error: $e');
                    initialDate = DateTime.now();
                  }

                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: DateTime(2000, 1, 1),
                    lastDate: DateTime(2100, 12, 31),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppColors.primary,
                            onPrimary: Colors.white,
                            surface: Theme.of(context).colorScheme.containerDark,
                            onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _selectedDateStarts[fieldId] = pickedDate;
                      final formattedDate = dateFormatConfirmed(pickedDate, context);
                      _dateControllers[fieldId]!.text = formattedDate;
                      _fieldValues[fieldId] = formattedDate;
                      print('Updated date for $fieldId: $formattedDate');
                    });
                  }
                },
                isLightTheme: isLightTheme,
              ),
            ],
          ),
        );

      default:
        return SizedBox.shrink();
    }
  }

  Future<void> submitToAPI() async {
    if (!validateFields()) return;

    final fieldValues = getFieldValues();

    Map<String, dynamic> apiData = {
      'project_id': widget.projectModel.id,
      'custom_field_values': fieldValues,
    };

    print('Data to send to API: $apiData');
    // Add API call logic here
  }

  @override
  void dispose() {
    _textControllers.forEach((_, controller) => controller.dispose());
    _dateControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('build: isCreate = ${widget.isCreate}, fields = ${fields.map((f) => {'id': f.id, 'type': f.fieldType, 'label': f.fieldLabel}).toList()}');
    if ((!_fieldsInitialized || fields.isEmpty)) {
    // if (!widget.isCreate && (!_fieldsInitialized || fields.isEmpty)) {
      print('Fields not initialized yet or empty, showing loading indicator');
      return const Center(child: NoData(isImage: true,message: "No custom fields for this project !",));
    }

    return widget.isCreate
        ? BlocBuilder<CustomFieldBloc, CustomFieldState>(
      builder: (context, state) {
        print('CustomFieldBloc state: $state');
        if (state is CustomFieldSuccess) {
          final newFields = state.CustomField
              .where((field) => field.module == "project")
              .toList();

          if (!_fieldsInitialized ||
              fields.length != newFields.length ||
              fields.map((f) => f.id).join(',') != newFields.map((f) => f.id).join(',')) {
            print('Updating fields: newFields = ${newFields.map((f) => {'id': f.id, 'type': f.fieldType, 'label': f.fieldLabel}).toList()}');
            fields = newFields;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _initializeFieldsAndControllers();
                setState(() {
                  _fieldsInitialized = true;
                });
              }
            });
          }

          print('Fields loaded: ${fields.map((f) => f.toJson()).toList()}');
          return ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              ...fields.map((field) => getFieldWidget(field)).toList(),
              const SizedBox(height: 20),
            ],
          );
        } else if (state is CustomFieldLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const Center(child: Text('Failed to load custom fields'));
        }
      },
    )
        : ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        ...fields
            .where((field) => field.module == "project")
            .map((field) => getFieldWidget(field))
            .toList(),
        const SizedBox(height: 20),
      ],
    );
  }
}