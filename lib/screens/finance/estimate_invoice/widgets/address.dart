import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/model/finance/address.dart';
import '../../../../bloc/theme/theme_bloc.dart';
import '../../../../bloc/theme/theme_state.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../../utils/widgets/toast_widget.dart';
import '../../../widgets/custom_cancel_create_button.dart';
import '../../../widgets/custom_textfields/custom_textfield.dart';
import '../../../../utils/widgets/custom_text.dart';

class AddressFormDialog extends StatefulWidget {
  final bool? isCreate;
  final AddressModel? model;
  final Function(String?, String?, String?, String?, String?, String?, String?)
      onSelected;

  AddressFormDialog(
      {super.key, this.isCreate, this.model, required this.onSelected});

  @override
  State<AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController contactController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  final TextEditingController cityController = TextEditingController();

  final TextEditingController stateController = TextEditingController();

  final TextEditingController countryController = TextEditingController();

  final TextEditingController zipController = TextEditingController();
  @override
  void initState() {


      nameController.text = widget.model!.name;
      contactController.text = widget.model!.contact ;
      addressController.text = widget.model!.address ;
      cityController.text = widget.model!.city ;
      stateController.text = widget.model!.state ;
      countryController.text = widget.model!.country ;
      zipController.text = widget.model!.zip ;
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(10.r), // Set the desired radius here
      ),
      backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,
      title: CustomText(
        text: AppLocalizations.of(context)!.address,
        color: Theme.of(context).colorScheme.textClrChange,
        size: 20.sp,
        fontWeight: FontWeight.w700,
        maxLines: null, // Allow unlimited lines
      ),
      content: SizedBox(
          width: 600.w, // custom width using screen util
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 20.h,
                ),
                CustomTextFields(
                  title: AppLocalizations.of(context)!.name,
                  hinttext: AppLocalizations.of(context)!.pleaseentername,
                  controller: nameController,
                  onSaved: (value) {},
                  onFieldSubmitted: (value) {},
                  isLightTheme: isLightTheme,
                  isRequired: true,
                ),
                SizedBox(
                  height: 10.h,
                ),
                CustomTextFields(
                  title: AppLocalizations.of(context)!.contact,
                  hinttext: AppLocalizations.of(context)!.pleaseentercontact,
                  controller: contactController,
                  onSaved: (value) {},
                  onFieldSubmitted: (value) {},
                  isLightTheme: isLightTheme,
                  isRequired: false,
                ),
                SizedBox(
                  height: 10.h,
                ),
                CustomTextFields(
                  height: 112.h,
                  title: AppLocalizations.of(context)!.address,
                  hinttext: AppLocalizations.of(context)!.pleaseenteraddress,
                  controller: addressController,
                  onSaved: (value) {},
                  onFieldSubmitted: (value) {},
                  isLightTheme: isLightTheme,
                  isRequired: false,
                ),
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  children: [
                    Expanded(
                        child: CustomTextFields(
                      height: 112.h,
                      title: AppLocalizations.of(context)!.city,
                      hinttext: AppLocalizations.of(context)!.city,
                      controller: cityController,
                      onSaved: (value) {},
                      onFieldSubmitted: (value) {},
                      isLightTheme: isLightTheme,
                      isRequired: false,
                    )),
                    Expanded(
                        child: CustomTextFields(
                      height: 112.h,
                      title: AppLocalizations.of(context)!.state,
                      hinttext: AppLocalizations.of(context)!.state,
                      controller: stateController,
                      onSaved: (value) {},
                      onFieldSubmitted: (value) {},
                      isLightTheme: isLightTheme,
                      isRequired: false,
                    )),
                  ],
                ),
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextFields(
                        height: 112.h,
                        title: AppLocalizations.of(context)!.country,
                        hinttext: AppLocalizations.of(context)!.country,
                        controller: countryController,
                        onSaved: (value) {},
                        onFieldSubmitted: (value) {},
                        isLightTheme: isLightTheme,
                        isRequired: false,
                      ),
                    ),
                    // SizedBox(height: 10.h,),
                    Expanded(
                      child: CustomTextFields(
                        height: 112.h,
                        title: AppLocalizations.of(context)!.zipcode,
                        hinttext: AppLocalizations.of(context)!.zipcode,
                        controller: zipController,
                        onSaved: (value) {},
                        onFieldSubmitted: (value) {},
                        isLightTheme: isLightTheme,
                        isRequired: false,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )),
      actions: [
        Padding(
          padding: EdgeInsets.only(top: 28.h),
          child: CreateCancelButtom(
            title: AppLocalizations.of(context)!.apply,
            onpressCancel: () {
              Navigator.pop(context);
            },
            onpressCreate: () {
              if (nameController.text.isEmpty) {
                // Show toast message
                flutterToastCustom(msg: AppLocalizations.of(context)!.pleasefilltherequiredfield);

                return; // Don't proceed further if name is empty
              }
              widget.onSelected(
                  nameController.text,
                  contactController.text,
                  addressController.text,
                  cityController.text,
                  stateController.text,
                  countryController.text,
                  zipController.text);
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}
