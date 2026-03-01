
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/settings/app_settings/widgets/custom_list.dart';
import '../../../bloc/setting/settings_bloc.dart';
import '../../../bloc/setting/settings_event.dart';
import '../../../bloc/setting/settings_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/internet_connectivity.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../routes/routes.dart';
import '../../../utils/widgets/back_arrow.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/no_internet_screen.dart';
import '../../../utils/widgets/toast_widget.dart';
import 'package:taskify/screens/status/widgets/notes_shimmer_widget.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../widgets/custom_textfields/custom_textfield.dart';

class MediaStorageScreen extends StatefulWidget {
  const MediaStorageScreen({super.key});

  @override
  State<MediaStorageScreen> createState() => _MediaStorageScreenState();
}

class _MediaStorageScreenState extends State<MediaStorageScreen> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  TextEditingController accessKeyController = TextEditingController();
  TextEditingController secretKeyController = TextEditingController();
  TextEditingController regionController = TextEditingController();
  TextEditingController bucketController = TextEditingController();

  ValueNotifier<String?> selectedStorage = ValueNotifier<String?>(null);

  bool isAws = false;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
    _loadInitialSettings();
  }

  void _initializeConnectivity() {
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() {
          _connectionStatus = results;
        });
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
        });
      }
    });
  }

  void _loadInitialSettings() {
    BlocProvider.of<SettingsBloc>(context).add(const SettingsList("media_storage_settings"));
  }

  void _handleStorageSelected(String category) {
    selectedStorage.value = category;
    setState(() {
      isAws = category == "Amazone AWS S3" || category == "s3";
    });
  }

  void updateMediaStorageSettings(BuildContext context) {
    if (selectedStorage.value != null && selectedStorage.value!.isNotEmpty) {
      var type = selectedStorage.value == "Amazon AWS S3" ? "s3" : "local";

      context.read<SettingsBloc>().add(UpdateSettingsMediaStorage(
        storage: type,
        s3AccessKey: accessKeyController.text,
        s3BucketKey: bucketController.text,
        s3RegionKey: regionController.text,
        s3SecretKey: secretKeyController.text,
      ));
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    selectedStorage.dispose();
    accessKeyController.dispose();
    secretKeyController.dispose();
    regionController.dispose();
    bucketController.dispose();
    super.dispose();
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
              _buildAppBar(isLightTheme),
              SizedBox(height: 30.h),
              _buildMediaStorageBody(isLightTheme)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isLightTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 0.h),
          child: Container(
            decoration: BoxDecoration(boxShadow: [
              isLightTheme
                  ? MyThemes.lightThemeShadow
                  : MyThemes.darkThemeShadow,
            ]),
            child: BackArrow(
              title: AppLocalizations.of(context)!.mediastoragetype,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildMediaStorageBody(bool isLightTheme) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsSuccess) {
          selectedStorage.value = context.read<SettingsBloc>().mediaStorageType ?? "";
        }

        if (state is SettingsMediaStorageUpdated) {
          // Use post-frame callback to avoid setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            flutterToastCustom(
              msg: AppLocalizations.of(context)!.updatedsuccessfully,
              color: AppColors.primary,
            );
            Navigator.pop(context);
            context.read<SettingsBloc>().add(const SettingsList("media_storage_settings"));
          });
        }

        if (state is SettingMediaStorageEditError) {
          flutterToastCustom(msg: state.errorMessage);
          context.read<SettingsBloc>().add(const SettingsList("media_storage_settings"));
        }
      },
      builder: (context, state) {
        if (state is SettingsSuccess) {
          return _buildSettingsSuccessView(context, isLightTheme);
        }

        if (state is MediaStorageSettingEditSuccessLoading) {
          return NotesShimmer();
        }

        if (state is SettingsLoading) {
          return NotesShimmer(height: 45.h, title: true);
        }

        return SizedBox();
      },
    );
  }

  Widget _buildSettingsSuccessView(BuildContext context, bool isLightTheme) {
    return Column(
      children: [
        ValueListenableBuilder<String?>(
          valueListenable: selectedStorage,
          builder: (context, value, child) {
            return CustomListField(
              onFollowUpTypeSelected: (String ) {  },
              onStatusSelected: (String ) {  },
              title: "storage",
              isRequired: true,
              name: value ?? "",
              onStorageSelected: _handleStorageSelected,
              onrequestMethodSelected: (String) {},
              onTypeSelected: (String) {},
              onSmtpEncryptionSelected: (String) {},
            );
          },
        ),
        SizedBox(height: 15.h),
        ValueListenableBuilder<String?>(
          valueListenable: selectedStorage,
          builder: (context, value, child) {
            return isAws
                ? _buildAwsInputFields(isLightTheme)
                : SizedBox();
          },
        ),
        SizedBox(height: 20.h),
        CreateCancelButtom(
          isCreate: false,
          isLoading: false,
          onpressCancel: () {
            Navigator.pop(context);
          },
          onpressCreate: () => updateMediaStorageSettings(context),
        ),
        SizedBox(height: 100.h),
      ],
    );
  }

  Widget _buildAwsInputFields(bool isLightTheme) {
    return Column(
      children: [
        CustomTextFields(
          onSaved: (String) {},
          title: AppLocalizations.of(context)!.awsaccesskey,
          hinttext: AppLocalizations.of(context)!.pleaseenterawsaccesskey,
          controller: accessKeyController,
          isLightTheme: isLightTheme,
          isRequired: true,
        ),
        SizedBox(height: 15.h),
        CustomTextFields(
          onSaved: (String) {},
          title: AppLocalizations.of(context)!.awssecretkey,
          hinttext: AppLocalizations.of(context)!.pleaseenterawssecretkey,
          controller: secretKeyController,
          isLightTheme: isLightTheme,
          isRequired: true,
        ),
        SizedBox(height: 15.h),
        CustomTextFields(
          onSaved: (String) {},
          title: AppLocalizations.of(context)!.awsregion,
          hinttext: AppLocalizations.of(context)!.pleaseenterawsregion,
          controller: regionController,
          isLightTheme: isLightTheme,
          isRequired: true,
        ),
        SizedBox(height: 15.h),
        CustomTextFields(
          title: AppLocalizations.of(context)!.awsbucket,
          hinttext: AppLocalizations.of(context)!.pleaseenterawsbucket,
          controller: bucketController,
          isLightTheme: isLightTheme,
          isRequired: true,
          onSaved: (String) {},
        ),
      ],
    );
  }
}