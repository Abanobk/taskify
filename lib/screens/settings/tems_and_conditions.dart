import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/colors.dart';
import '../../src/generated/i18n/app_localizations.dart';import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../bloc/privacy_aboutus_termscond/privacy_aboutus_termscond_bloc.dart';
import '../../bloc/privacy_aboutus_termscond/privacy_aboutus_termscond_event.dart';
import '../../bloc/privacy_aboutus_termscond/privacy_aboutus_termscond_state.dart';
import '../../data/localStorage/hive.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/back_arrow.dart';
import '../widgets/html_widget.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  String? termsAndConditions; // Use String? for nullable
  String role = ""; // Track loading state

  @override
  void initState() {
    super.initState();
    _getRole();
    BlocProvider.of<PrivacyAboutusTermsCondBloc>(context).add( GetTermsAndCondition());
  }
  Future<void> _getRole() async {
    role = await HiveStorage.getRole();
    print("fhDZFKh ${role.runtimeType}");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,

      body: BlocBuilder<PrivacyAboutusTermsCondBloc, PrivacyAboutusTermsCondState>(
        builder: (context, state) {
          print("dfghjk $state");
          if(state is PriLoading) {
            return  Center(
              child: const SpinKitFadingCircle(
                color: AppColors.primary,
                size: 40.0,
              ),
            );
          }

          if(state is TermsAndConditionValue) {
            print("djkgfnvcj ${state.terms}");
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        BackArrow(
                          isPen: role == "admin" ? true:false,
                          onPress: () {
                            if(role == "admin" ) {
                              router.push('/UpdateAboutUs', extra: {
                                'privacyPolicy': state.terms,
                                "from": "terms"
                              });
                            }
                          },
                          iSBackArrow: true,
                          fromDash: false,
                          title:
                          AppLocalizations.of(context)!.termsandconditions,
                        ),
                        SizedBox(height: 20.h),
                       // Show content only if not loading
                          htmlWidget(state.terms, context),
                      ],
                    ),
                  ),
                ),

              ],
            );
          }
          return Container();
    }));
  }
}
