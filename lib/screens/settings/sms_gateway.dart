import 'dart:convert';
import '../../src/generated/i18n/app_localizations.dart';import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hive/hive.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/localStorage/hive.dart';
import 'package:taskify/data/model/settings/sms_gateway.dart';
import 'package:taskify/screens/status/widgets/notes_shimmer_widget.dart';
import 'package:taskify/screens/widgets/custom_container.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import '../../bloc/setting/settings_bloc.dart';
import '../../bloc/setting/settings_event.dart';
import '../../bloc/setting/settings_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../utils/widgets/custom_text.dart';
import '../widgets/custom_cancel_create_button.dart';
import '../widgets/custom_textfields/custom_textfield.dart';
import 'app_settings/widgets/custom_list.dart';

class SmsGateway extends StatefulWidget {
  const SmsGateway({super.key});

  @override
  State<SmsGateway> createState() => _SmsGatewayState();
}

class _SmsGatewayState extends State<SmsGateway> with TickerProviderStateMixin {
  TextEditingController baseUrlController = TextEditingController();
  TextEditingController sccountSIDController = TextEditingController();
  TextEditingController tokenController = TextEditingController();
  TextEditingController authTokenController = TextEditingController();
  TextEditingController keyController = TextEditingController();
  TextEditingController keyForFormDataController = TextEditingController();
  TextEditingController keyForParamController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  TextEditingController valueForFormDataController = TextEditingController();
  TextEditingController valueForParamController = TextEditingController();
  TextEditingController authorizationController = TextEditingController();
  TextEditingController tokenMadeController = TextEditingController();
  TextEditingController textJsonController = TextEditingController();
  late TabController _tabController;
  String? selectedMethod;

  bool isToken = false;
  String TokenFromBase64 = "";
  String getSMSToken = "";
  List<Map<dynamic, dynamic>> headerList = [];
  List<Map<String, String>> formDataList = [];
  List<Map<String, String>> paramList = [];
  final List<String> placeholders = [
    "{only_mobile_number}",
    "{country_code}",
    "{message}",
  ];
  void _handleMethodSelected(String category) {
    if (selectedMethod != category) {
      setState(() {
        selectedMethod = category;
      });
    }
  }

  void addRow(List<Map<String, String>> headerDataList) {
    String newKey = keyController.text.trim();
    String newValue = valueController.text.trim();

    if (newKey.isNotEmpty && newValue.isNotEmpty) {
      // Check if the key-value pair already exists
      bool exists = headerDataList.any((element) =>
          element.containsKey(newKey) && element[newKey] == newValue);

      if (!exists) {
        setState(() {
          headerDataList
              .insert(0, {newKey: newValue}); // Add new entry at the top
          keyController.clear();
          valueController.clear();
        });

        HiveStorage.putSMSGatewayHeader(headerList);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("This key-value pair already exists!")));
      }
    }

    Navigator.pop(context); // Close the dialog
  }

  void _deleteRow(int index, List<Map<String, String>> headerDataList) {
    setState(() {
      headerDataList.removeAt(index); // Remove the item at the given index
    });

    // Update Hive storage after deletion
    HiveStorage.putSMSGatewayHeader(headerDataList);
  }

  void updateSmsGatewaySettings(BuildContext context) {
    print("dsfcvjhxk m ${valueController.text}");
    List<Map<String, String>> headers = [
      if (keyController.text.isNotEmpty)
        {keyController.text: valueController.text},
      if (tokenMadeController.text.isNotEmpty)
        {"Authorization": tokenMadeController.text},
    ];

    List<Map<String, String>> body = [
      if (keyForFormDataController.text.isNotEmpty)
        {keyForFormDataController.text: valueForFormDataController.text},
    ];

    List<Map<String, String>> params = [
      if (keyForParamController.text.isNotEmpty)
        {keyForParamController.text: valueForParamController.text},
    ];
    print("edfnfned $body");
    final updated = SmsGatewayModel(
      baseUrl: baseUrlController.text,
      method: selectedMethod!,
      endpoint: 'sms_gateway_settings',
      headers: headers,
      body: body,
      params: params,
      textFormatData: textJsonController.text,
    );

    TokenFromBase64 = "";
    context.read<SettingsBloc>().add(UpdateSettingsSmsHeader(updated));
  }

  void addFormdataRow() {
    String newKey = keyForFormDataController.text.trim();
    String newValue = valueForFormDataController.text.trim();
    if (newValue.isNotEmpty && newKey.isNotEmpty) {
      setState(() {
        formDataList.insert(0, {newKey: newValue});

        keyForFormDataController.clear();
        valueForFormDataController.clear();
      });
    }
    HiveStorage.putSMSGatewayFormData(formDataList);
    Navigator.pop(context); // Close the dialog
  }

  void addParamRow() {
    String newKey = keyForParamController.text.trim();
    String newValue = valueForParamController.text.trim();

    if (newKey.isNotEmpty && newValue.isNotEmpty) {
      setState(() {
        paramList.insert(0, {newKey: newValue});
        keyForParamController.clear();
        valueForParamController.clear();
      });
    }
    HiveStorage.putSMSGatewayParam(paramList);
    Navigator.pop(context); // Close the dialog
  }

  void loadSavedHeaders() {
    var box = Hive.box('headerBox');
    List<dynamic>? savedHeaders = box.get('headerList');

    if (savedHeaders != null) {
      setState(() {
        headerList = List<Map<dynamic, dynamic>>.from(savedHeaders);
      });
    }
    print("fjdjgj ${headerList.length}");
  }

  void loadSavedFormData() {
    var box = Hive.box('headerBox');
    List<dynamic>? savedHeaders = box.get('FormDataList');

    if (savedHeaders != null) {
      setState(() {
        formDataList = List<Map<String, String>>.from(savedHeaders);
      });
    }
    print("fjdjgj ${formDataList.length}");
  }

  void loadSavedParam() {
    var box = Hive.box('headerBox');
    List<dynamic>? savedHeaders = box.get('paramList');

    if (savedHeaders != null) {
      setState(() {
        paramList = List<Map<String, String>>.from(savedHeaders);
      });
    }
    print("fjdjgj ${paramList.length}");
  }

  void deleteRow(int index) {
    setState(() {
      headerList.removeAt(index);
    });
  }

  void deleteFormDataRow(int index) {
    setState(() {
      formDataList.removeAt(index);
    });
  }

  void deleteParamRow(int index) {
    setState(() {
      paramList.removeAt(index);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BlocProvider.of<SettingsBloc>(context)
        .add(const SettingsList("sms_gateway_settings"));
    loadSavedHeaders();

    _tabController = TabController(length: 2, vsync: this);

    // Listen for tab changes
    _tabController.addListener(() {
      setState(() {});
    });
    // Preserve baseUrlController's value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsBloc = context.read<SettingsBloc>();
      if (baseUrlController.text.isEmpty) {
        baseUrlController.text = settingsBloc.baseUrl ?? "";
      }
    });
    selectedMethod = context.read<SettingsBloc>().method ?? "";
  }

  // getSmsToken() async {
  //   tokenMadeController.text = (await HiveStorage.getSMSGatewayToken())!;
  //   print("ksfdlkfgD ${authTokenController.text}");
  // }

  String getToken() {
    String credentials = "${authTokenController.text}:${authTokenController}";
    String encodedToken = base64Encode(utf8.encode(credentials));
    setState(() {
      TokenFromBase64 = encodedToken;
    });
    // tokenMadeController = TextEditingController(text: "Basic $TokenFromBase64");
    // HiveStorage.putSMSGatewayAuthToken(TokenFromBase64);

    return encodedToken;
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
      if (state is SettingsSuccess) {
        context.read<SettingsBloc>().dateformat;
      }
    }, builder: (context, state) {
      var headerDataList = context.read<SettingsBloc>().headerDataList;
      var bodyFormDataList = context.read<SettingsBloc>().bodyFormDataList;
      var paramDataList = context.read<SettingsBloc>().paramDataList;
      print("rfjfdjzxf ${headerDataList.length}");

      print("lSDGFldgmg $state");
      if (state is SettingsSuccess) {
        return Stack(children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 30.h),
                CustomTextFields(
                    height: 114.h,
                    title: AppLocalizations.of(context)!.baseurl,
                    hinttext: "",
                    controller: baseUrlController,
                    onSaved: (value) {},
                    onFieldSubmitted: (value) {},
                    isLightTheme: isLightTheme,
                    isRequired: true),
                SizedBox(
                  height: 15.h,
                ),
                CustomListField(
                  onStorageSelected: (String) {},
                  title: "requestMethod",
                  isRequired: true,
                  name: selectedMethod ?? "",
                  // typeName: "",
                  onTypeSelected: (String t) {},
                  onFollowUpTypeSelected: (String ) {  },
                  onStatusSelected: (String ) {  },
                  onrequestMethodSelected: _handleMethodSelected,
                  onSmtpEncryptionSelected: (String) {},
                ),
                SizedBox(
                  height: 15.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomText(
                        text: AppLocalizations.of(context)!
                            .createauthorizationtoken,
                        color: Theme.of(context)
                            .colorScheme
                            .textClrChange, // Default color for unselected
                        fontWeight: FontWeight.w700,
                        size: 22.sp,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                CustomTextFields(
                    height: 114.h,
                    title: AppLocalizations.of(context)!.accountsid,
                    hinttext: "",
                    controller: sccountSIDController,
                    onSaved: (value) {},
                    onFieldSubmitted: (value) {},
                    isLightTheme: isLightTheme,
                    isRequired: false),
                SizedBox(
                  height: 15.h,
                ),
                CustomTextFields(
                    height: 114.h,
                    title: AppLocalizations.of(context)!.authtoken,
                    hinttext: "",
                    controller: authTokenController,
                    onSaved: (value) {},
                    onFieldSubmitted: (value) {},
                    isLightTheme: isLightTheme,
                    isRequired: false),
                SizedBox(
                  height: 15.h,
                ),
                InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () {
                    setState(() {
                      if (sccountSIDController.text.isEmpty &&
                          authTokenController.text.isEmpty) {
                        flutterToastCustom(
                            msg: AppLocalizations.of(context)!
                                .pleaseprovidebothaccoundsidandauthtoken);
                      } else {
                        isToken = true;
                        getToken();
                      }
                    });
                  },
                  child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6)),
                      height: 30.h,
                      width: 100.w,
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      child: CustomText(
                        text: AppLocalizations.of(context)!.create,
                        size: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.pureWhiteColor,
                      )),
                ),
                isToken
                    ? SizedBox(
                        height: 15.h,
                      )
                    : SizedBox(),
                isToken
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomText(
                                text:
                                    "${AppLocalizations.of(context)!.authorization} :\nBasic $TokenFromBase64",
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                                fontWeight: FontWeight.w700,
                                softwrap: true,
                                size: 15.sp,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
                isToken
                    ? SizedBox(
                        height: 10.h,
                      )
                    : SizedBox(),
                isToken
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                                onTap: () {
                                  Clipboard.setData(new ClipboardData(
                                          text: TokenFromBase64))
                                      .then((_) {
                                    // TokenFromBase64 = "";
                                    flutterToastCustom(
                                        msg: "copied",
                                        color: AppColors.primary);
                                  });
                                },
                                child: HeroIcon(
                                  HeroIcons.clipboardDocument,
                                  color: Colors.orange,
                                )),
                          ],
                        ),
                      )
                    : SizedBox(),
                SizedBox(
                  height: 15.h,
                ),
                Container(
                  height: 50,
                  color: AppColors.primary,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomText(
                          text: AppLocalizations.of(context)!.header,
                          color: AppColors
                              .pureWhiteColor, // Default color for unselected
                          fontWeight: FontWeight.w700,
                          size: 22.sp,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: AppLocalizations.of(context)!.addheaderdata,
                        color: AppColors
                            .greyForgetColor, // Default color for unselected
                        fontWeight: FontWeight.w700,
                        size: 12.sp,
                      ),
                      InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (ctx) => StatefulBuilder(builder:
                                      (BuildContext context,
                                          void Function(void Function())
                                              setState) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10
                                            .r), // Set the desired radius here
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .alertBoxBackGroundColor,
                                      // backgroundColor: Theme.of(context)
                                      //     .colorScheme
                                      //     .AlertBoxBackGroundColor,
                                      contentPadding: EdgeInsets.zero,
                                      content: Container(
                                          constraints:
                                              BoxConstraints(maxHeight: 900.h),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                height: 30.h,
                                              ),
                                              CustomTextFields(
                                                  height: 114.h,
                                                  title: AppLocalizations.of(
                                                          context)!
                                                      .key,
                                                  hinttext: "",
                                                  controller: keyController,
                                                  onSaved: (value) {},
                                                  onFieldSubmitted: (value) {},
                                                  isLightTheme: isLightTheme,
                                                  isRequired: false),
                                              SizedBox(
                                                height: 10.h,
                                              ),
                                              CustomTextFields(
                                                  height: 114.h,
                                                  title: AppLocalizations.of(
                                                          context)!
                                                      .value,
                                                  hinttext: "",
                                                  controller: valueController,
                                                  onSaved: (value) {},
                                                  onFieldSubmitted: (value) {},
                                                  isLightTheme: isLightTheme,
                                                  isRequired: false),
                                            ],
                                          )),
                                      actions: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(top: 20.h),
                                          child: CreateCancelButtom(
                                              title:
                                                  AppLocalizations.of(context)!
                                                      .ok,
                                              onpressCancel: () {
                                                // _userSearchController.clear();
                                                Navigator.pop(context);
                                              },
                                              onpressCreate: () {
                                                print(
                                                    "fbhdgjcxnm  ${valueController.text}");
                                                tokenMadeController.text =
                                                    valueController.text;
                                                authorizationController.text =
                                                    keyController.text;
                                                addRow(headerDataList);
                                              }),
                                        ),
                                      ],
                                    );
                                  }));
                        },
                        child: Container(
                          height: 20.h,
                          width: 20.w,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              color: AppColors.primary),
                          child: Center(
                            child: HeroIcon(
                              size: 13.sp,
                              HeroIcons.plus,
                              style: HeroIconStyle.outline,
                              color: AppColors.pureWhiteColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                // Stack(children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
                    child: InkWell(
                      onTap: () {},
                      child: customContainer(
                          addWidget: Column(
                            children: [
                              CustomTextFields(
                                  height: 114.h,
                                  title: "",
                                  hinttext: AppLocalizations.of(context)!
                                      .authorization,
                                  controller: authorizationController,
                                  onSaved: (value) {},
                                  onFieldSubmitted: (value) {},
                                  isLightTheme: isLightTheme,
                                  isRequired: false),
                              SizedBox(
                                height: 15.h,
                              ),
                              CustomTextFields(
                                  height: 114.h,
                                  title:
                                      AppLocalizations.of(context)!.authtoken,
                                  hinttext: "",
                                  controller: tokenMadeController,
                                  onSaved: (value) {},
                                  onFieldSubmitted: (value) {},
                                  isLightTheme: isLightTheme,
                                  isRequired: false),
                              SizedBox(
                                height: 15.h,
                              ),
                            ],
                          ),
                          context: context),
                    ),
                  ),
                  // Positioned(
                  //   top: 5,
                  //   right: 20,
                  //   left: 350,
                  //   child: GlowContainer(
                  //       shape: BoxShape.circle,
                  //       glowColor: Theme.of(context)
                  //           .colorScheme
                  //           .primary
                  //           .withValues(alpha: 0.6),
                  //       child: Container(
                  //           width: 40.w,
                  //           height: 30.h,
                  //           decoration: BoxDecoration(
                  //               color: Theme.of(context)
                  //                   .colorScheme
                  //                   .backGroundColor,
                  //               shape: BoxShape.circle),
                  //           child: HeroIcon(
                  //             HeroIcons.trash,
                  //             size: 20.sp,
                  //             color: Colors.red,
                  //           ))),
                  // )
                // ]),
                SizedBox(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: headerDataList.length,
                        itemBuilder: (context, index) {
                          var entry = headerDataList[index]
                              .entries
                              .first; // Get key-value pair
                          print("rfjfdjzxf qswa ${headerDataList.length}");
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 18.w, vertical: 5.h),
                            child: customContainer(
                              addWidget: IntrinsicHeight(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    /// **Text Section**
                                    Expanded(
                                      // This allows text to take available space in the Row
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 18.w, vertical: 10.h),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomText(
                                              text: "Key: ${entry.key}",
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .textClrChange,
                                              fontWeight: FontWeight.w500,
                                              size: 15.sp,
                                              maxLines: 2, // Allows wrapping
                                              softwrap: true,
                                              overflow: TextOverflow.visible,
                                            ),
                                            SizedBox(height: 10.h),
                                            CustomText(
                                              text: "Value: ${entry.value}",
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .textClrChange,
                                              fontWeight: FontWeight.w500,
                                              size: 15.sp,
                                              maxLines: 2, // Allows wrapping
                                              softwrap: true,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    /// **Delete Icon Section**
                                    InkWell(
                                      onTap: () {
                                        _deleteRow(index, headerDataList);
                                      },
                                      child: Container(
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade300,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(17.4),
                                            bottomRight: Radius.circular(17.4),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: HeroIcon(
                                          size: 20,
                                          HeroIcons.trash,
                                          style: HeroIconStyle.outline,
                                          color: AppColors.pureWhiteColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              context: context,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // CreateCancelButtom(
                //   isCreate: false,
                //   isLoading: false,
                //   onpressCancel: () {
                //     Navigator.pop(context);
                //   },
                //   onpressCreate: true == false
                //       ? () async {}
                //       : () => updateSmsGatewaySettings(context),
                // ),
                SizedBox(
                  height: 10.h,
                ),
                Container(
                  height: 50,
                  color: AppColors.primary,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomText(
                          text: AppLocalizations.of(context)!.body,
                          color: AppColors
                              .pureWhiteColor, // Default color for unselected
                          fontWeight: FontWeight.w700,
                          size: 22.sp,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                bodySmsGateway(isLightTheme, bodyFormDataList),
                paramOfSmsGateway(isLightTheme, paramDataList),
                SizedBox(
                  height: 100.h,
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.w),
              child: Container(
                height: 80.h,
                color: Theme.of(context).colorScheme.containerDark,
                child: CreateCancelButtom(
                  isCreate: false,
                  isLoading: false,
                  onpressCancel: () {
                    Navigator.pop(context);
                  },
                  onpressCreate: true == false
                      ? () async {}
                      : () => updateSmsGatewaySettings(context),
                ),
              ),
            ),
          ),
        ]);
      }
      if (state is SettingsLoading ||
          state is HeaderSettingEditSuccessLoading) {
        return NotesShimmer();
      }
      if (state is SettingsHeaderUpdated) {
        flutterToastCustom(
            msg: AppLocalizations.of(context)!.updatedsuccessfully,
            color: AppColors.primary);
        context
            .read<SettingsBloc>()
            .add(const SettingsList("sms_gateway_settings"));
        // Navigator.pop(context);
      }
      if (state is SettingHeaderEditError) {
        flutterToastCustom(msg: state.errorMessage);
        context
            .read<SettingsBloc>()
            .add(const SettingsList("sms_gateway_settings"));
      }
      if (state is SettingsError) {
        flutterToastCustom(msg: state.errorMessage);
        context
            .read<SettingsBloc>()
            .add(const SettingsList("sms_gateway_settings"));
      }
      return Container();
    });
  }

  Widget paramOfSmsGateway(
      bool isLightTheme, List<Map<String, String>> paramDataList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),
        Container(
          height: 50,
          color: AppColors.primary,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomText(
                  text: AppLocalizations.of(context)!.params,
                  color: AppColors.pureWhiteColor,
                  fontWeight: FontWeight.w700,
                  size: 22.sp,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 15.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.addparams,
                color: AppColors.greyForgetColor,
                fontWeight: FontWeight.w700,
                size: 12.sp,
              ),
              InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (ctx) => StatefulBuilder(builder:
                              (BuildContext context,
                                  void Function(void Function()) setState) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.r), // Set the desired radius here
                              ),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .alertBoxBackGroundColor,
                              // backgroundColor: Theme.of(context)
                              //     .colorScheme
                              //     .AlertBoxBackGroundColor,
                              contentPadding: EdgeInsets.zero,
                              content: Container(
                                  constraints: BoxConstraints(maxHeight: 900.h),
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 30.h,
                                      ),
                                      CustomTextFields(
                                          height: 114.h,
                                          title:
                                              AppLocalizations.of(context)!.key,
                                          hinttext: "",
                                          controller: keyForParamController,
                                          onSaved: (value) {},
                                          onFieldSubmitted: (value) {},
                                          isLightTheme: isLightTheme,
                                          isRequired: false),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      CustomTextFields(
                                          height: 114.h,
                                          title: AppLocalizations.of(context)!
                                              .value,
                                          hinttext: "",
                                          controller: valueForParamController,
                                          onSaved: (value) {},
                                          onFieldSubmitted: (value) {},
                                          isLightTheme: isLightTheme,
                                          isRequired: false),
                                    ],
                                  )),
                              actions: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(top: 20.h),
                                  child: CreateCancelButtom(
                                      title: AppLocalizations.of(context)!.ok,
                                      onpressCancel: () {
                                        // _userSearchController.clear();
                                        Navigator.pop(context);
                                      },
                                      onpressCreate: addParamRow),
                                ),
                              ],
                            );
                          }));
                },
                child: Container(
                  height: 20.h,
                  width: 20.w,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: AppColors.primary),
                  child: Center(
                    child: HeroIcon(
                      size: 13.sp,
                      HeroIcons.plus,
                      style: HeroIconStyle.outline,
                      color: AppColors.pureWhiteColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20.h,
        ),
        // This is the fix - change from Row to Column
        // Put ListView in a Column instead of a Row
        Container(
          // height: 300,
          // color: Colors.red,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: paramDataList.length,
            itemBuilder: (context, index) {
              var entry = paramDataList[index].entries.first;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 5.h),
                child: customContainer(
                  addWidget: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 18.w, vertical: 10.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: "Key: ${entry.key}",
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                  fontWeight: FontWeight.w500,
                                  size: 15.sp,
                                  maxLines: 2,
                                  softwrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                                SizedBox(height: 10.h),
                                CustomText(
                                  text: "Value: ${entry.value}",
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                  fontWeight: FontWeight.w500,
                                  size: 15.sp,
                                  maxLines: 2,
                                  softwrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.red.shade300,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(17.4),
                              bottomRight: Radius.circular(17.4),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: HeroIcon(
                            size: 20,
                            HeroIcons.trash,
                            style: HeroIconStyle.outline,
                            color: AppColors.pureWhiteColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  context: context,
                ),
              );
            },
          ),
        ),
        SizedBox(
          height: 20.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: placeHolders(),
        ),
        // CreateCancelButtom(
        //   isCreate: false,
        //   isLoading: false,
        //   onpressCancel: () {
        //     Navigator.pop(context);
        //   },
        //   onpressCreate: true == false
        //       ? () async {
        //           // onCreateClient();
        //         }
        //       : () {
        //           // onUpdateClient(currentClient!);
        //         },
        // ),
      ],
    );
  }

  Widget TextJsonSmsGateway(isLightTheme) {
    return Column(
      children: [
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
            height: 114.h,
            title: AppLocalizations.of(context)!.textjson,
            hinttext: "",
            controller: textJsonController,
            onSaved: (value) {},
            onFieldSubmitted: (value) {},
            isLightTheme: isLightTheme,
            isRequired: true),
        SizedBox(
          height: 15.h,
        ),
        // CreateCancelButtom(
        //   isCreate: false,
        //   isLoading: false,
        //   onpressCancel: () {
        //     Navigator.pop(context);
        //   },
        //   onpressCreate: true == false
        //       ? () async {
        //           // onCreateClient();
        //         }
        //       : () {
        //           // onUpdateClient(currentClient!);
        //         },
        // ),
      ],
    );
  }

  Widget bodySmsGateway(bool isLightTheme, bodyFormDataList) {
    return Container(
      // height: 500,
      // color: Colors.red,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                height: 40.h,
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.primary, // Highlight color
                  tabs: [
                    Tab(
                      child: Container(
                        child: Center(
                          child: CustomText(
                            text: AppLocalizations.of(context)!.textjson,
                            color: _tabController.index == 0
                                ? AppColors.pureWhiteColor
                                : Theme.of(context).colorScheme.textClrChange,
                            fontWeight: FontWeight.w700,
                            size: 15.sp,
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: Center(
                        child: CustomText(
                          text: AppLocalizations.of(context)!.formdata,
                          color: _tabController.index == 1
                              ? AppColors.pureWhiteColor
                              : Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w700,
                          size: 15.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Builder(
              builder: (context) {
                // Listen to tab changes
                return TabControllerListener(
                  controller: _tabController,
                  builder: (context, index) {
                    // Return only the widget for the current tab
                    return index == 0
                        ? TextJsonSmsGateway(isLightTheme)
                        : formDataSmsGateway(isLightTheme, bodyFormDataList);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget formDataSmsGateway(isLightTheme, bodyFormDataList) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: AppLocalizations.of(context)!.addbodydataparamvalue,
                  color:
                      AppColors.greyForgetColor, // Default color for unselected
                  fontWeight: FontWeight.w700,
                  size: 12.sp,
                ),
                InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (ctx) => StatefulBuilder(builder:
                                (BuildContext context,
                                    void Function(void Function()) setState) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10.r), // Set the desired radius here
                                ),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .alertBoxBackGroundColor,
                                // backgroundColor: Theme.of(context)
                                //     .colorScheme
                                //     .AlertBoxBackGroundColor,
                                contentPadding: EdgeInsets.zero,

                                content: Container(
                                    constraints:
                                        BoxConstraints(maxHeight: 900.h),
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: 30.h,
                                        ),
                                        CustomTextFields(
                                            height: 114.h,
                                            title: AppLocalizations.of(context)!
                                                .key,
                                            hinttext: "",
                                            controller:
                                                keyForFormDataController,
                                            onSaved: (value) {},
                                            onFieldSubmitted: (value) {},
                                            isLightTheme: isLightTheme,
                                            isRequired: false),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        CustomTextFields(
                                            height: 114.h,
                                            title: AppLocalizations.of(context)!
                                                .value,
                                            hinttext: "",
                                            controller:
                                                valueForFormDataController,
                                            onSaved: (value) {},
                                            onFieldSubmitted: (value) {},
                                            isLightTheme: isLightTheme,
                                            isRequired: false),
                                      ],
                                    )),
                                actions: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 20.h),
                                    child: CreateCancelButtom(
                                        title: AppLocalizations.of(context)!.ok,
                                        onpressCancel: () {
                                          // _userSearchController.clear();
                                          Navigator.pop(context);
                                        },
                                        onpressCreate: addFormdataRow),
                                  ),
                                ],
                              );
                            }));
                  },
                  child: Container(
                    height: 20.h,
                    width: 20.w,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: AppColors.primary),
                    child: Center(
                      child: HeroIcon(
                        size: 13.sp,
                        HeroIcons.plus,
                        style: HeroIconStyle.outline,
                        color: AppColors.pureWhiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListView.builder(
                    padding: EdgeInsets.only(top: 10.h),
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: bodyFormDataList.length,
                    itemBuilder: (context, index) {
                      var entry = bodyFormDataList[index].entries.first;
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.h),
                        child: customContainer(
                          addWidget: IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                /// **Text Section**
                                Expanded(
                                  // This allows text to take available space in the Row
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 18.w, vertical: 10.h),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: "Key: ${entry.key}",
                                          color: Theme.of(context)
                                              .colorScheme
                                              .textClrChange,
                                          fontWeight: FontWeight.w500,
                                          size: 15.sp,
                                          maxLines: 2, // Allows wrapping
                                          softwrap: true,
                                          overflow: TextOverflow.visible,
                                        ),
                                        SizedBox(height: 10.h),
                                        CustomText(
                                          text: "Value: ${entry.value}",
                                          color: Theme.of(context)
                                              .colorScheme
                                              .textClrChange,
                                          fontWeight: FontWeight.w500,
                                          size: 15.sp,
                                          maxLines: 2, // Allows wrapping
                                          softwrap: true,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                /// **Delete Icon Section**
                                Container(
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade300,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(17.4),
                                      bottomRight: Radius.circular(17.4),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: HeroIcon(
                                    size: 20,
                                    HeroIcons.trash,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.pureWhiteColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          context: context,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            placeHolders(),
            // SizedBox(height: 30.h,),
            // CreateCancelButtom(
            //   isCreate: false,
            //   isLoading: false,
            //   onpressCancel: () {
            //     Navigator.pop(context);
            //   },
            //   onpressCreate: true == false
            //       ? () async {
            //           // onCreateClient();
            //         }
            //       : () {
            //           // onUpdateClient(currentClient!);
            //         },
            // ),
          ],
        ),
      ),
    );
  }

  Widget placeHolders() {
    return Column(
      children: [
        SizedBox(
          height: 20.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomText(
              text: AppLocalizations.of(context)!.availableplaceholder,
              color: Theme.of(context)
                  .colorScheme
                  .textClrChange, // Default color for unselected
              fontWeight: FontWeight.w700,
              size: 15.sp,
            ),
          ],
        ),
        SizedBox(
          height: 15.h,
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            itemCount: placeholders.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 5.h,
                ),
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    Clipboard.setData(
                            new ClipboardData(text: placeholders[index]))
                        .then((_) {
                      flutterToastCustom(
                          msg: "copied", color: AppColors.primary);
                    });
                  },
                  child: customContainer(
                      addWidget: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 18.w, vertical: 10.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: placeholders[index],
                              color: Theme.of(context)
                                  .colorScheme
                                  .textClrChange, // Default color for unselected
                              fontWeight: FontWeight.w700,
                              size: 12.sp,
                            ),
                            HeroIcon(HeroIcons.clipboardDocument,
                                color: Colors.orange)
                          ],
                        ),
                      ),
                      context: context),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TabControllerListener extends StatefulWidget {
  final TabController controller;
  final Widget Function(BuildContext, int) builder;

  const TabControllerListener(
      {Key? key, required this.controller, required this.builder})
      : super(key: key);

  @override
  _TabControllerListenerState createState() => _TabControllerListenerState();
}

class _TabControllerListenerState extends State<TabControllerListener> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.controller.index;
    widget.controller.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    if (currentIndex != widget.controller.index) {
      setState(() {
        currentIndex = widget.controller.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, currentIndex);
  }
}
