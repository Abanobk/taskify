import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/config/colors.dart';
import '../../src/generated/i18n/app_localizations.dart';import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../bloc/setting/settings_bloc.dart';
import '../../bloc/setting/settings_event.dart';
import '../../bloc/setting/settings_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../data/GlobalVariable/globalvariable.dart';
import '../../utils/widgets/toast_widget.dart';
import '../notes/widgets/notes_shimmer_widget.dart';
import '../widgets/custom_cancel_create_button.dart';
import '../widgets/custom_textfields/custom_textfield.dart';

class WhatsappScreen extends StatefulWidget {
  const WhatsappScreen({super.key});

  @override
  State<WhatsappScreen> createState() => _WhatsappScreenState();
}

class _WhatsappScreenState extends State<WhatsappScreen> {
  TextEditingController whatsappTokenController = TextEditingController();
  TextEditingController whatsPhoneNumberIdController = TextEditingController();

  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BlocProvider.of<SettingsBloc>(context).add(const SettingsList("whatsapp_settings"));
    whatsappTokenController.text =  context.read<SettingsBloc>().whatsappAccessToken??"";
    whatsPhoneNumberIdController.text =  context.read<SettingsBloc>().whatsappPhoneNumberId??"";
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    void updateWhatsAppSettings(BuildContext context) {
      if( whatsappTokenController.text.isNotEmpty && whatsappTokenController.text.isNotEmpty) {
        context.read<SettingsBloc>().add(UpdateSettingsWhatsApp(
            phoneNumId: whatsappTokenController.text,
            accessToken: whatsappTokenController.text));
        flutterToastCustom(
            msg: AppLocalizations.of(
                navigatorKey.currentContext!)!
                .updatedsuccessfully,
            color: AppColors.primary);
      }else{

        flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
        );


      }   }
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
    if (state is SettingsSuccess) {
    }
    }, builder: (context, state) {
    print("lSDGFldgmg $state");
    if (state is SettingsSuccess) {
    whatsappTokenController.text =  context.read<SettingsBloc>().whatsappAccessToken??"";
    whatsPhoneNumberIdController.text =  context.read<SettingsBloc>().whatsappPhoneNumberId??"";

    return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    SizedBox(
    height: 30.h,
    ),
    CustomTextFields(
    height: 114.h,
    title:
    AppLocalizations.of(context)!.whatsAppaccesstoken,
    hinttext: "Please enter whatsapp access token",
    controller: whatsappTokenController,
    onSaved: (value) {},
    onFieldSubmitted: (value) {},
    isLightTheme: isLightTheme,
    isRequired: true),
    SizedBox(
    height: 10.h,
    ),
    CustomTextFields(
    height: 114.h,
    title:
    AppLocalizations.of(context)!.whatsAppphonenumberid,
    hinttext: "Please enter whatsapp phone number ID",
    controller: whatsPhoneNumberIdController,
    onSaved: (value) {},
    onFieldSubmitted: (value) {},
    isLightTheme: isLightTheme,
    isRequired: true),
    SizedBox(
    height: 10.h,
    ),
    CreateCancelButtom(
    isCreate: false,
    isLoading: false,
    onpressCancel: () {
    Navigator.pop(context);
    },
    onpressCreate: true == false
    ? () async {
    // onCreateClient();
    }
        : () {
    updateWhatsAppSettings(context);
    // onUpdateClient(currentClient!);
    },
    ),
    ],
    );
    }
    if (state is SettingsLoading ||
    state is WhatsappSettingEditSuccessLoading) {
    return NotesShimmer();
    }
    if (state is SettingsWhatsAppUpdated) {
    flutterToastCustom(
    msg: AppLocalizations.of(context)!.updatedsuccessfully,
    color: AppColors.primary);
    context
        .read<SettingsBloc>()
        .add(const SettingsList("whatsapp_settings"));
    // Navigator.pop(context);
    }

    if (state is SettingWhatsappEditError) {
    flutterToastCustom(msg: state.errorMessage);
    context
        .read<SettingsBloc>()
        .add(const SettingsList("whatsapp_settings"));
    }
    return SizedBox();
    }));
  }
}
