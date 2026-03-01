import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../src/generated/i18n/app_localizations.dart';

import 'package:taskify/utils/widgets/custom_text.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_event.dart';

import '../../bloc/theme/theme_state.dart';
import '../../routes/routes.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int valueHolder = 1;
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.bgColorChange,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            vertical: height * 0.06, horizontal: width * 0.033),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                InkWell(
                    highlightColor: Colors.transparent, // No highlight on tap
                    splashColor: Colors.transparent,
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back_outlined)),
                const SizedBox(
                  width: 10,
                ),
                CustomText(
                  text:AppLocalizations.of(context)!.settings,
                  color: Theme.of(context).colorScheme.textColorChange,
                  size: 24,
                ),
              ],
            ),
            BlocBuilder<ThemeBloc, ThemeState>(builder: (context, themeState) {
              return SwitchListTile(
                title: Text(AppLocalizations.of(context)!.darkmode, ),
                value: themeState is DarkThemeState,
                onChanged: (value) {
                  context.read<ThemeBloc>().add(ToggleThemeEvent());
                },
              );
            }),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
              ),
              child: InkWell(
                highlightColor: Colors.transparent, // No highlight on tap
                splashColor: Colors.transparent,
                onTap: () {
                  BlocProvider.of<AuthBloc>(context).add(LoggedOut(
                    context: context,
                  ));
              router.go('/login') ; },
                child: CustomText(
                    text: AppLocalizations.of(context)!.signout,
                    color: Theme.of(context).colorScheme.textColorChange),
              ),
            )
          ],
        ),
      ),
    );
  }
}
