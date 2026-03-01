import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/bloc/privacy_aboutus_termscond/privacy_aboutus_termscond_event.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../bloc/privacy_aboutus_termscond/privacy_aboutus_termscond_bloc.dart';
import '../../bloc/privacy_aboutus_termscond/privacy_aboutus_termscond_state.dart';
import '../../data/localStorage/hive.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/back_arrow.dart';
import '../widgets/html_widget.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  final String title;
  final String from;

  const PrivacyPolicyScreen(
      {super.key, required this.title, required this.from});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String role = "";

  @override
  void initState() {
    super.initState();
    _getRole();
    BlocProvider.of<PrivacyAboutusTermsCondBloc>(context)
        .add(GetPrivacyPolicy());
  }

  Future<void> _getRole() async {
    role = await HiveStorage.getRole();
    print("fhDZFKh ${role.runtimeType}");
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrivacyAboutusTermsCondBloc,
        PrivacyAboutusTermsCondState>(builder: (context, state) {
      print("desrsar  $state");
      if (state is PriLoading) {
        return Center(
          child: const SpinKitFadingCircle(
            color: AppColors.primary,
            size: 40.0,
          ),
        );
      }
      if (state is PrivacyPolicyValue) {
        print("dfghjk${ state.privacyPolicy}");
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.backGroundColor,
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // SizedBox(height: 20.h),
                      BackArrow(
                        isPen: role == "admin" ? true : false,
                        onPress: () {
                          if (role == "admin") {
                            router.push('/UpdateAboutUs', extra: {
                              'privacyPolicy': state.privacyPolicy,
                              "from": "privacy"
                            });
                          }
                        },
                        iSBackArrow: true,
                        fromDash: false,
                        title: AppLocalizations.of(context)!.privacypolicy,
                      ),
                      SizedBox(height: 20.h),
                      // Content for the privacy policy

                      htmlWidget(
                        state.privacyPolicy,
                        context,
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
      if (state is PrivacyUpdatedSuccess) {
        print("dfghjk${ state.privacyPolicy}");
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.backGroundColor,
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // SizedBox(height: 20.h),
                      BackArrow(
                        isPen: role == "admin" ? true : false,
                        onPress: () {
                          if (role == "admin") {
                            router.push('/UpdateAboutUs', extra: {
                              'privacyPolicy': state.privacyPolicy,
                              "from": "privacy"
                            });
                          }
                        },
                        iSBackArrow: true,
                        fromDash: false,
                        title: AppLocalizations.of(context)!.privacypolicy,
                      ),
                      SizedBox(height: 20.h),
                      // Content for the privacy policy

                      htmlWidget(
                        state.privacyPolicy,
                        context,
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Container();
    });
  }
}
