// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:intl/intl.dart';
// import 'package:taskify/bloc/custom_fields/custom_field_bloc.dart';
// import 'package:taskify/config/colors.dart';
// import '../../../../bloc/custom_fields/custom_field_state.dart';
// import '../../../../bloc/theme/theme_bloc.dart';
// import '../../../../bloc/theme/theme_state.dart';
//
// import '../../../../config/constants.dart';
// import '../../../../data/model/custom_field/custom_field_model.dart';
// import '../../../../utils/widgets/custom_text.dart';
// import '../../../../utils/widgets/toast_widget.dart';
// import '../../../bloc/custom_fields/custom_field_event.dart';
// import '../../../data/model/task/task_model.dart';
// import '../../widgets/custom_date.dart';
// import '../../widgets/custom_fields/customFieldRadio.dart';
// import '../../widgets/custom_fields/customfield_checkbox.dart';
// import '../../widgets/custom_fields/customfield_dropdown.dart';
// import '../../widgets/custom_textfields/custom_textfield.dart';
//
//
// class CustomFieldTaskPage extends StatefulWidget {
//   final Tasks tasksModel;
//   final bool isCreate; // Add isCreate parameter
//   final GlobalKey<CustomFieldTaskPageState> key;
//
//   const CustomFieldTaskPage({
//     required this.tasksModel,
//     required this.isCreate,
//     required this.key,
//   }) : super(key: key);
//
//   Map<String, dynamic> getFieldValues() {
//     return key.currentState?.getFieldValues() ?? {};
//   }
//
//   @override
//   State<CustomFieldTaskPage> createState() => CustomFieldTaskPageState();
// }
//
// class CustomFieldTaskPageState extends State<CustomFieldTaskPage> {
//   final Map<String, TextEditingController> _textControllers = {};
//   final Map<String, dynamic> _fieldValues = {};
//   Map<String, TextEditingController> _dateControllers = {};
//
//   Map<String, DateTime?> _selectedDateStarts = {};
//
//
//   late List<CustomFieldModel> fields;
//
//   String formattedDate = "";
//
//   @override
//   void initState() {
//     super.initState();
//     BlocProvider.of<CustomFieldBloc>(context).add(CustomFieldLists());
//     _initializeFields();
//   }
//
//   void _initializeFields() {
//     if (widget.isCreate) {
//       fields = [];
//     } else {
//       fields = (widget.tasksModel.customFields ?? [])
//           .map((f) => CustomFieldModel.fromJson(f.toJson()))
//           .toList();
//       _initializeFieldsAndControllers();
//     }
//   }
//
//   void _initializeFieldsAndControllers({Map<String, dynamic>? initialValues}) {
//     final rawValues = widget.isCreate ? null : widget.tasksModel.customFieldValues;
//     final Map<String, dynamic> initValues = initialValues ?? {};
//
//     if (!widget.isCreate && rawValues != null) {
//       final rawMap = rawValues.toJson();
//       rawMap.forEach((key, value) {
//         initValues[key] = value is List && value.isNotEmpty ? value : value;
//       });
//     }
//
//     for (final field in fields) {
//       final fieldId = field.id.toString();
//       final fieldType = field.fieldType;
//       final isRequired = field.required == '1' || field.required == true;
//       final value = initValues[fieldId];
//
//       print('Initializing field $fieldId: type = $fieldType, isRequired = $isRequired, value = $value, options = ${field.options}');
//
//       switch (fieldType) {
//         case 'text':
//         case 'number':
//         case 'password':
//         case 'textarea':
//           _textControllers[fieldId] = TextEditingController(text: value?.toString() ?? '');
//           _fieldValues[fieldId] = value?.toString() ?? '';
//           break;
//
//         case 'date':
//           String formattedDate = '';
//           DateTime? parsedDate;
//
//           if (!widget.isCreate && value != null) {
//             try {
//               if (value is String && value.isNotEmpty) {
//                 parsedDate = parseDateStringFromApi(value);
//                 if (parsedDate.year >= 1900 && parsedDate.year <= 2100) {
//                   formattedDate = dateFormatConfirmed(parsedDate, context);
//                 }
//               } else if (value is int) {
//                 parsedDate = DateTime.fromMillisecondsSinceEpoch(value);
//                 if (parsedDate.year >= 1900 && parsedDate.year <= 2100) {
//                   formattedDate = dateFormatConfirmed(parsedDate, context);
//                 }
//               }
//             } catch (e) {
//               print('Date parse failed for $value: $e');
//             }
//           } else if (isRequired) {
//             parsedDate = DateTime.now();
//             formattedDate = dateFormatConfirmed(parsedDate, context);
//           }
//
//           _dateControllers[fieldId] = TextEditingController(text: _fieldValues[fieldId]);
//           _fieldValues[fieldId] = formattedDate;
//           _selectedDateStarts[fieldId] = parsedDate;
//           break;
//
//         case 'checkbox':
//           List<String> selectedValues = [];
//           if (!widget.isCreate && value != null) {
//             if (value is List) {
//               selectedValues = List<String>.from(value)
//                   .where((v) => field.options?.contains(v) == true && v != '0')
//                   .toList();
//             } else if (value is String && field.options?.contains(value) == true && value != '0') {
//               selectedValues = [value];
//             }
//             print('Update mode - Field $fieldId: Initial selectedValues = $selectedValues');
//           } else if (isRequired && field.options != null && field.options!.isNotEmpty) {
//             selectedValues = [field.options!.first];
//             print('Create mode - Field $fieldId: Set default value for required field = $selectedValues');
//           } else {
//             print('Field $fieldId: No initial value set (isRequired = $isRequired, options = ${field.options})');
//           }
//           // _fieldValues[fieldId] = selectedValues;
//           print('Initialized checkbox field $fieldId: ${_fieldValues[fieldId]}');
//           break;
//
//         case 'radio':
//           if (value != null &&
//               value is String &&
//               field.options?.contains(value) == true) {
//             _fieldValues[fieldId] = value;
//           } else if (isRequired && field.options?.isNotEmpty == true) {
//             _fieldValues[fieldId] = field.options!.first;
//           } else {
//             _fieldValues[fieldId] = null;
//           }
//           print(
//               'After initialization, _fieldValues[$fieldId] = ${_fieldValues[fieldId]}');
//           break;
//         case 'select':
//           _fieldValues[fieldId] = field.options?.contains(value) == true
//               ? value
//               : (isRequired && field.options?.isNotEmpty == true ? field.options!.first : null);
//           print('Initialized ${fieldType} field $fieldId: ${_fieldValues[fieldId]}');
//           break;
//       }
//     }
//   }
//
//   // Map<String, dynamic> getFieldValues() {
//   //   final Map<String, dynamic> result = Map.from(_fieldValues);
//   //
//   //   _textControllers.forEach((key, controller) {
//   //     if (fields.any((field) =>
//   //         field.id.toString() == key && field.fieldType != 'checkbox')) {
//   //       result[key] = controller.text;
//   //     }
//   //   });
//   //
//   //   print('Field Values: $result');
//   //   return result;
//   // }
//   // Map<String, dynamic> getFieldValues() {
//   //   final Map<String, dynamic> result = {};
//   //
//   //   for (final field in fields) {
//   //     final fieldId = field.id.toString();
//   //     final fieldType = field.fieldType;
//   //
//   //     // For date field, store formatted date only if it's a date field
//   //     if (fieldType == 'date') {
//   //       final date = _dateStartValues[fieldId];
//   //       if (date != null) {
//   //         result[fieldId] = date.toIso8601String(); // or use formatted string
//   //       } else {
//   //         result[fieldId] = null;
//   //       }
//   //     } else if (['text', 'number', 'password', 'textarea'].contains(fieldType)) {
//   //       result[fieldId] = _textControllers[fieldId]?.text ?? '';
//   //     } else {
//   //       result[fieldId] = _fieldValues[fieldId];
//   //     }
//   //   }
//   //
//   //   print('Filtered Field Values: $result');
//   //   return result;
//   // }
//   // Map<String, dynamic> getFieldValues() { /////////// LAST WORKING
//   //   final Map<String, dynamic> result = {};
//   //
//   //   for (final field in fields) {
//   //     final fieldId = field.id.toString();
//   //     final fieldType = field.fieldType;
//   //
//   //     if (fieldType == 'date') {
//   //       if (_selectedDateStarts[fieldId] != null) {
//   //         result[fieldId] = DateFormat('yyyy-MM-dd').format(_selectedDateStarts[fieldId]!);
//   //       } else {
//   //         final displayDate = _dateControllers[fieldId]?.text;
//   //         if (displayDate != null && displayDate.isNotEmpty) {
//   //           try {
//   //             final parsedDate = formatDateFromApiAsDate(displayDate, context);
//   //             result[fieldId] = parsedDate != null ? DateFormat('yyyy-MM-dd').format(parsedDate) : null;
//   //           } catch (e) {
//   //             print('Failed to parse date for field $fieldId: $displayDate, error: $e');
//   //             result[fieldId] = null;
//   //           }
//   //         } else {
//   //           result[fieldId] = null;
//   //         }
//   //       }
//   //     } else if (['text', 'number', 'password', 'textarea'].contains(fieldType)) {
//   //       result[fieldId] = _textControllers[fieldId]?.text ?? '';
//   //     } else {
//   //       result[fieldId] = _fieldValues[fieldId];
//   //     }
//   //   }
//   //
//   //   print('Field Values for API: $result');
//   //   return result;
//   // }
//   Map<String, dynamic> getFieldValues() {
//     final Map<String, dynamic> result = {};
//
//     for (final field in fields) {
//       final fieldId = field.id.toString();
//       final fieldType = field.fieldType;
//
//       if (fieldType == 'date') {
//         final displayDate = _dateControllers[fieldId]?.text;
//         if (displayDate != null && displayDate.isNotEmpty) {
//           try {
//             final parsedDate = formatDateFromApiAsDate(displayDate, context);
//             result[fieldId] = parsedDate != null ? DateFormat('yyyy-MM-dd').format(parsedDate) : null;
//           } catch (e) {
//             print('Failed to parse date for field $fieldId: $displayDate, error: $e');
//             result[fieldId] = null;
//           }
//         } else {
//           result[fieldId] = null;
//         }
//       } else if (['text', 'number', 'password', 'textarea'].contains(fieldType)) {
//         result[fieldId] = _textControllers[fieldId]?.text ?? '';
//       } else if (fieldType == 'checkbox') {
//         result[fieldId] = _fieldValues[fieldId] ?? null;
//         print('Checkbox field $fieldId in getFieldValues: ${_fieldValues[fieldId]}');
//       } else if (fieldType == 'radio' || fieldType == 'select') {
//         result[fieldId] = _fieldValues[fieldId] ?? null;
//       } else {
//         result[fieldId] = _fieldValues[fieldId];
//       }
//     }
//
//     print('Field Values for API: $result');
//     return result;
//   }
//   bool validateFields() {
//     for (final field in fields) {
//       final fieldId = field.id.toString();
//       final isRequired = field.required == '1' || field.required == true;
//       final fieldLabel = field.fieldLabel ?? 'Field $fieldId';
//       final fieldType = field.fieldType;
//
//       if (isRequired) {
//         final value = _fieldValues[fieldId];
//         print('Validating field $fieldId ($fieldLabel, type: $fieldType): value = $value');
//
//         if (fieldType == 'date') {
//           final controller = _dateControllers[fieldId];
//           if (controller?.text.isEmpty ?? true) {
//             flutterToastCustom(msg: '$fieldLabel ${AppLocalizations.of(context)!.isrequired}', color: AppColors.red);
//             print('Validation failed: $fieldLabel (date) is required and empty');
//             return false;
//           }
//         } else if (['text', 'number', 'password', 'textarea'].contains(fieldType)) {
//           final controller = _textControllers[fieldId];
//           if (controller?.text.isEmpty ?? true) {
//             flutterToastCustom(msg: '$fieldLabel ${AppLocalizations.of(context)!.isrequired}', color: AppColors.red);
//             print('Validation failed: $fieldLabel ($fieldType) is required and empty');
//             return false;
//           }
//         } else if (fieldType == 'select' && (value == null || value.toString().isEmpty)) {
//           flutterToastCustom(msg: '$fieldLabel ${AppLocalizations.of(context)!.isrequired}', color: AppColors.red);
//           print('Validation failed: $fieldLabel (select) is required and empty');
//           return false;
//         } else if (fieldType == 'radio' && (value == null || value.toString().isEmpty)) {
//           flutterToastCustom(msg: '$fieldLabel ${AppLocalizations.of(context)!.isrequired}', color: AppColors.red);
//           print('Validation failed: $fieldLabel (radio) is required and empty');
//           return false;
//         } else if (fieldType == 'checkbox' && (value == null || (value is List && value.isEmpty))) {
//           flutterToastCustom(msg: '$fieldLabel ${AppLocalizations.of(context)!.isrequired}', color: AppColors.red);
//           print('Validation failed: $fieldLabel (checkbox) is required and empty');
//           return false;
//         }
//       }
//     }
//     print('All required fields validated successfully');
//     return true;
//   }
//
//   Widget getFieldWidget(CustomFieldModel field) {
//     final themeBloc = context.read<ThemeBloc>();
//     final isLightTheme = themeBloc.currentThemeState is LightThemeState;
//
//     final fieldId = field.id.toString();
//     final fieldType = field.fieldType;
//     final label = field.fieldLabel;
//     final isRequired = field.required == '1' || field.required == true;
//
//     final currentFieldOptions = field.options?.cast<String>() ?? [];
//
//     print(
//         'Rendering field $fieldId: type = $fieldType, label = $label, isRequired = $isRequired, _fieldValues[$fieldId] = ${_fieldValues[fieldId]}');
//
//     switch (fieldType) {
//       case 'number':
//       case 'text':
//         return Padding(
//           padding: EdgeInsets.only(top: 10.h),
//           child: CustomTextFields(
//             height: 42.h,
//             title: label ?? '',
//             hinttext: AppLocalizations.of(context)!.enter,
//             controller: _textControllers[fieldId]!,
//             onSaved: (val) => _fieldValues[fieldId] = val,
//             onFieldSubmitted: (val) => _fieldValues[fieldId] = val,
//             isLightTheme: isLightTheme,
//             isRequired: isRequired,
//             currency: false,
//             keyboardType: fieldType == 'number'
//                 ? TextInputType.number
//                 : TextInputType.text,
//             inputFormatters: fieldType == 'number'
//                 ? [FilteringTextInputFormatter.digitsOnly]
//                 : [],
//           ),
//         );
//
//       case 'password':
//         return Padding(
//           padding: EdgeInsets.only(top: 10.h),
//           child: CustomTextFields(
//             title: label ?? '',
//             hinttext: AppLocalizations.of(context)!.enter,
//             controller: _textControllers[fieldId]!,
//             isLightTheme: isLightTheme,
//             isRequired: isRequired,
//             isPassword: true,
//             onSaved: (String? b) {},
//           ),
//         );
//
//       case 'textarea':
//         return Padding(
//           padding: EdgeInsets.only(top: 10.h),
//           child: CustomTextFields(
//             height: 112.h,
//             keyboardType: TextInputType.multiline,
//             title: label ?? '',
//             hinttext: AppLocalizations.of(context)!.enter,
//             controller: _textControllers[fieldId]!,
//             isLightTheme: isLightTheme,
//             isRequired: isRequired,
//             onSaved: (String? a) {},
//           ),
//         );
//
//       case 'radio':
//         String? selectedRadioValue = _fieldValues[fieldId] is String &&
//             currentFieldOptions.contains(_fieldValues[fieldId])
//             ? _fieldValues[fieldId]
//             : isRequired && currentFieldOptions.isNotEmpty
//             ? currentFieldOptions.first
//             : null;
//
//         if (currentFieldOptions.isEmpty) {
//           return Padding(
//             padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
//             child: CustomText(
//               text: 'No options available for ${label ?? ''}',
//               color: Theme.of(context).colorScheme.textClrChange,
//               size: 16.sp,
//             ),
//           );
//         }
//
//         return Padding(
//           padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   CustomText(
//                     text: label ?? '',
//                     color: Theme.of(context).colorScheme.textClrChange,
//                     size: 16.sp,
//                     fontWeight: FontWeight.w700,
//                   ),
//                   SizedBox(width: 5.w),
//                   if (isRequired)
//                     CustomText(
//                       text: '*',
//                       color: AppColors.red,
//                       size: 16.sp,
//                       fontWeight: FontWeight.w700,
//                     ),
//                 ],
//               ),
//               SizedBox(height: 10.h),
//               CustomRadioList(
//                 options: currentFieldOptions,
//                 groupValue: selectedRadioValue??"", // Remove default empty string
//                 onChanged: (val) {
//                   setState(() {
//                     _fieldValues[fieldId] = val;
//                     print('Updated _fieldValues[$fieldId]: ${_fieldValues[fieldId]}');
//                   });
//                 },
//                 inactiveBorderColor: Theme.of(context).colorScheme.whitepurpleChange,
//               ),
//             ],
//           ),
//         );
//
//       case 'checkbox':
//       // Ensure _fieldValues[fieldId] is initialized as a List<String>
//         if (_fieldValues[fieldId] == null) {
//           _fieldValues[fieldId] = [];
//         }
//         List<String> selectedList = List<String>.from(_fieldValues[fieldId] ?? []);
//
//         return Padding(
//           padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
//           child: CustomFieldCheckbox(
//             options: currentFieldOptions,
//             selectedValues: selectedList,
//             onChanged: (List<String> newSelected) {
//               setState(() {
//                 _fieldValues[fieldId] = newSelected.where((v) {
//                   print('Processing value v: $v');
//                   bool isKept = v != '0';
//                   print('Is $v kept? $isKept');
//                   return isKept;
//                 }).toList();
//                 print('Updated checkbox field $fieldId: ${_fieldValues[fieldId]}');
//                 print('Updated checkbox field $fieldId: ${_fieldValues[fieldId]}');
//               });
//             },
//             label: label ?? '',
//             required: isRequired,
//             padding: EdgeInsets.zero,
//           ),
//         );
//
//       case 'select':
//         final dropdownItems = currentFieldOptions
//             .toSet()
//             .toList()
//             .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//             .toList();
//
//         String? selectedValueSingle = _fieldValues[fieldId] is String &&
//             currentFieldOptions.contains(_fieldValues[fieldId])
//             ? _fieldValues[fieldId]
//             : null;
//
//         return Padding(
//           padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   CustomText(
//                     text: label ?? '',
//                     color: Theme.of(context).colorScheme.textClrChange,
//                     size: 16.sp,
//                     fontWeight: FontWeight.w700,
//                   ),
//                   if (isRequired)
//                     CustomText(
//                       text: '*',
//                       color: Theme.of(context).colorScheme.textClrChange,
//                       size: 16.sp,
//                       fontWeight: FontWeight.w700,
//                     ),
//                 ],
//               ),
//               SizedBox(height: 10.h),
//               ReusableDropdownDialog<String>(
//                 items: dropdownItems,
//                 value: selectedValueSingle,
//                 hintText: label,
//                 onChanged: (val) {
//                   print('Selected value: $val (${val.runtimeType})');
//                   setState(() {
//                     _fieldValues[fieldId] = val;
//                   });
//                 },
//                 borderRadius: 12,
//                 borderColor: Theme.of(context).colorScheme.containerDark,
//               ),
//             ],
//           ),
//         );
//
//       case 'date':
//         _dateControllers.putIfAbsent(
//           fieldId,
//               () => TextEditingController(text: _fieldValues[fieldId] ?? ''),
//         );
//
//         return Padding(
//           padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   CustomText(
//                     text: label ?? '',
//                     color: Theme.of(context).colorScheme.textClrChange ?? Colors.black,
//                     size: 16.sp,
//                     fontWeight: FontWeight.w700,
//                   ),
//                   if (isRequired)
//                     CustomText(
//                       text: '*',
//                       color: AppColors.red,
//                       size: 16.sp,
//                       fontWeight: FontWeight.w700,
//                     ),
//                 ],
//               ),
//               SizedBox(height: 10.h),
//               DatePickerWidget(
//                 dateController: _dateControllers[fieldId]!,
//                 title: '',
//                 titlestartend: label ?? 'Select Date',
//                 onTap: () async {
//                   DateTime initialDate = _selectedDateStarts[fieldId] ?? DateTime.now();
//
//                   final pickedDate = await showDatePicker(
//                     context: context,
//                     initialDate: initialDate,
//                     firstDate: DateTime(2000, 1, 1),
//                     lastDate: DateTime(2100, 12, 31),
//                     builder: (context, child) {
//                       return Theme(
//                         data: Theme.of(context).copyWith(
//                           colorScheme: ColorScheme.light(
//                             primary: AppColors.primary,
//                             onPrimary: Colors.white,
//                             surface: Theme.of(context).colorScheme.containerDark ?? Colors.white,
//                             onSurface: Theme.of(context).textTheme.bodyLarge!.color ?? Colors.black,
//                           ),
//                         ),
//                         child: child!,
//                       );
//                     },
//                   );
//
//                   if (pickedDate != null) {
//                     setState(() {
//                       _selectedDateStarts[fieldId] = pickedDate;
//                       formattedDate = dateFormatConfirmed(pickedDate, context);
//                       _dateControllers[fieldId]!.text = formattedDate;
//                       _fieldValues[fieldId] = formattedDate;
//                       print('Picked date for field $fieldId: $pickedDate -> $formattedDate');
//                     });
//                   }
//                 },
//                 isLightTheme: isLightTheme,
//               ),
//             ],
//           ),
//         );
//
//       default:
//         return SizedBox.shrink();
//     }
//   }
//
//   Future<void> submitToAPI() async {
//     if (!validateFields()) return;
//
//     final fieldValues = getFieldValues();
//
//     Map<String, dynamic> apiData = {
//       'task_id': widget.tasksModel.id,
//       'custom_field_values': fieldValues,
//     };
//
//     print('Data to send to API: $apiData');
//     // Add API call logic here (same for create and update)
//   }
//
//   @override
//   void dispose() {
//     _textControllers.values.forEach((controller) => controller.dispose());
//     _dateControllers.values.forEach((controller) => controller.dispose());
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return widget.isCreate
//         ? BlocBuilder<CustomFieldBloc, CustomFieldState>(
//       builder: (context, state) {
//         if (state is CustomFieldSuccess) {
//           // Filter fields where module == "project"
//           fields = state.CustomField
//               .where((field) => field.module == "task")
//               .toList();
//
//           _initializeFieldsAndControllers(); // Initialize with empty values
//
//           return ListView(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             padding: EdgeInsets.zero,
//             children: [
//               ...fields.map((field) => getFieldWidget(field)).toList(),
//               const SizedBox(height: 20),
//             ],
//           );
//         } else if (state is CustomFieldLoading) {
//           return Center(child: CircularProgressIndicator());
//         } else {
//           return Center(child: Text('Failed to load custom fields'));
//         }
//       },
//     )
//         : ListView(
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       padding: EdgeInsets.zero,
//       children: [
//         // Filter fields for update mode as well
//         ...fields
//             .where((field) => field.module == "task")
//             .map((field) => getFieldWidget(field))
//             .toList(),
//         const SizedBox(height: 20),
//       ],
//     );
//   }
// }
