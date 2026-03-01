import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/bloc/privacy_aboutus_termscond/privacy_aboutus_termscond_event.dart';
import 'package:taskify/config/colors.dart';
import '../../../src/generated/i18n/app_localizations.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../bloc/privacy_aboutus_termscond/privacy_aboutus_termscond_bloc.dart';
import '../../bloc/privacy_aboutus_termscond/privacy_aboutus_termscond_state.dart';
import '../../data/localStorage/hive.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/back_arrow.dart';

import '../widgets/html_widget.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  String? aboutUs; // Use String? for nullable
  String role = ""; // Track loading state

  @override
  void initState() {
    super.initState();
    _getRole();
    BlocProvider.of<PrivacyAboutusTermsCondBloc>(context).add(GetAboutUs());
  }

  Future<void> _getRole() async {
    role = await HiveStorage.getRole();
    print("fhDZFKh ${role.runtimeType}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        body: BlocBuilder<PrivacyAboutusTermsCondBloc,
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
          if (state is AboutUsValue) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    BackArrow(
                      isPen: role == "admin" ? true:false,
                      onPress: () {
                        if(role == "admin" ) {
                          router.push('/UpdateAboutUs', extra: {
                            'privacyPolicy': state.aboutUs,
                            "from": "about"
                          });
                        }
                      },
                      iSBackArrow: true,
                      fromDash: false,
                      title: AppLocalizations.of(context)!.aboutus,
                    ),
                    SizedBox(height: 20.h),
                   htmlWidget(state.aboutUs, context),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            );
          } if (state is AboutUsValue) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    BackArrow(
                      isPen: role == "admin" ? true:false,
                      onPress: () {
                        if(role == "admin" ) {
                          router.push('/UpdateAboutUs', extra: {
                            'privacyPolicy': state.aboutUs,
                            "from": "about"
                          });
                        }
                      },
                      iSBackArrow: true,
                      fromDash: false,
                      title: AppLocalizations.of(context)!.aboutus,
                    ),
                    SizedBox(height: 20.h),
                   htmlWidget(state.aboutUs, context),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            );
          }
          return Container();
        }));
  }
}
