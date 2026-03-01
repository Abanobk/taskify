import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slidable_bar/slidable_bar.dart';
import '../../src/generated/i18n/app_localizations.dart';import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

class SlackScreen extends StatefulWidget {
  const SlackScreen({super.key});

  @override
  State<SlackScreen> createState() => _SlackScreenState();
}

class _SlackScreenState extends State<SlackScreen> {

  TextEditingController slackBotTokenController = TextEditingController();


  final SlidableBarController sideBarController =
  SlidableBarController(initialStatus: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BlocProvider.of<SettingsBloc>(context).add(const SettingsList("slack_settings"));
  }
  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    void updateSlackSettings(BuildContext context) {
      if( slackBotTokenController.text.isNotEmpty ) {
        context.read<SettingsBloc>().add(UpdateSettingsSlack(
            slackBotToken: slackBotTokenController.text,
           ));
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
    slackBotTokenController.text =  context.read<SettingsBloc>().slackBotToken??"";

    return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    SizedBox(height: 30.h,),
    CustomTextFields(
    height: 114.h,
    title: AppLocalizations.of(
    context)!
        .slackbottoken,
    hinttext: "Slack bot token",
    controller: slackBotTokenController,
    onSaved: (value) {},
    onFieldSubmitted: (value) {},
    isLightTheme: isLightTheme,
    isRequired: true),

    SizedBox(height: 10.h,),
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
        : () => updateSlackSettings(context),
    ),
    ],
    );
    }
    if (state is SettingsLoading ) {
    return NotesShimmer();
    }
    if (state is SettingsSlackUpdated) {
    flutterToastCustom(
    msg: AppLocalizations.of(context)!.updatedsuccessfully,
    color: AppColors.primary);
    context
        .read<SettingsBloc>()
        .add(const SettingsList("slack_settings"));

    }

    if (state is SettingSlackEditError) {
    flutterToastCustom(msg: state.errorMessage);
    context
        .read<SettingsBloc>()
        .add(const SettingsList("slack_settings"));
    }
    return SizedBox();
    }));
  }
}
