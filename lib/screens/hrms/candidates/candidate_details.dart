import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:go_router/go_router.dart';

import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/data/model/candidate/candidate_model.dart';

import '../../../bloc/candidate/candidates_bloc.dart';
import '../../../bloc/candidate/candidates_event.dart';
import '../../../bloc/candidate/candidates_state.dart';
import '../../../bloc/languages/language_switcher_bloc.dart';
import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/constants.dart';
import '../../../config/internet_connectivity.dart';
import '../../../data/localStorage/hive.dart';
import '../../../routes/routes.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/back_arrow.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/no_internet_screen.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/detail_page_menu.dart';
import '../../widgets/side_bar.dart';

class CandidateDetails extends StatefulWidget {
  final CandidateModel? candidateModel;
  const CandidateDetails({super.key,this.candidateModel});

  @override
  State<CandidateDetails> createState() => _CandidateDetailsState();
}

class _CandidateDetailsState extends State<CandidateDetails> {
  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final _key = GlobalKey<ExpandableFabState>();
  bool isRtl = false;
  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }
  void _onDeleteCandidate(candidateId) {
    context.read<CandidatesBloc>().add(DeleteCandidates(candidateId));
    final setting = context.read<CandidatesBloc>();
    setting.stream.listen((state) {
      if (state is CandidatesDeleteSuccess) {
        if (mounted) {
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
          BlocProvider.of<CandidatesBloc>(context).add(CandidatesList());

          context.pushReplacement('/candidates');
        }
      } else if (state is CandidatesError) {
        flutterToastCustom(
          msg: state.errorMessage,
        );
      }
      // BlocProvider.of<TodosBloc>(context).add(TodosList());
    });
  }
  void _onEditCandidate() {
    _key.currentState?.toggle();
    var candidate = widget.candidateModel;
    CandidateModel candidateModel = CandidateModel(
        id: candidate!.id,
        name: candidate.name,
        email: candidate.email,
        phone: candidate.phone,
        source: candidate.source,
        position: candidate.position,
        attachments: candidate.attachments,
        status: candidate.status);
    context.read<PermissionsBloc>().isEditCandidate == true
        ?    router.push(
      '/createupdatecandidate',
      extra: {
        'isCreate': false,
        'candidateModel': candidateModel
      },
    )
        : null;
  }
  @override
  void initState() {
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
    _checkRtlLanguage();
    super.initState();
  }
  Future<void> _checkRtlLanguage() async {
    final languageCode = await HiveStorage().getLanguage();
    setState(() {
      isRtl = LanguageBloc.instance.isRtlLanguage(languageCode ?? defaultLanguage);

    });
  }
  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : Scaffold(
            backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: context
            .read<PermissionsBloc>()
            .isDeleteCandidate ==
            true ||
            context
                .read<PermissionsBloc>()
                .isEditCandidate ==
                true
            ? detailMenu(

isChat: false,



            isDiscuss: true,
            isEdit:context
                .read<PermissionsBloc>()
                .isEditCandidate,
            isDelete: context
                .read<PermissionsBloc>()
                .isDeleteCandidate,
            key: _key,
            context: context,
            onpressdiscuss: () {

              _key.currentState?.toggle();
             router.push(
                "/candidatemoreTabs",
                extra: {"isDetail": false, "id":widget.candidateModel!.id,"name":widget.candidateModel!.name },
              );
            },
            onpressEdit: () {
              _onEditCandidate();
              // Navigator.pop(context);
            },
            onpressDelete: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10
                          .r), // Set the desired radius here
                    ),
                    backgroundColor: Theme
                        .of(context)
                        .colorScheme
                        .alertBoxBackGroundColor,
                    title: Text(
                      AppLocalizations.of(context)!
                          .confirmDelete,
                    ),
                    content: Text(
                      AppLocalizations.of(context)!
                          .areyousure,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          _onDeleteCandidate(widget.candidateModel!.id);
                        },
                        child: Text(
                            AppLocalizations.of(context)!
                                .delete),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop(false); // Cancel deletion
                        },
                        child: Text(
                            AppLocalizations.of(context)!
                                .cancel),
                      ),
                    ],
                  );
                },
              );
            })
            : SizedBox.shrink(),
            body: SideBar(
              context: context,
              controller: sideBarController,
              underWidget: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: BackArrow(
                        onTap: () {

                            router.pop();

                        },
                        title: AppLocalizations.of(context)!.candidatedetail,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    _body(isLightTheme)
                  ],
                ),
              ),
            ));
  }

  _body(isLightTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        children: [
          _candidateCard(context),
          _candidatePersonalDetailsCard(context,widget.candidateModel),
        ],
      ),
    );
  }

  String getInitials(String fullName) {
    // Split the full name into parts
    List<String> nameParts = fullName.split(' ');

    // Get the first letter of the first and last name
    String firstNameInitial = nameParts[0][0].toUpperCase();
    String lastNameInitial = nameParts.length > 1 ? nameParts[1][0].toUpperCase() : '';

    // Combine initials and return
    return '$firstNameInitial$lastNameInitial';
  }
  Widget _candidateCard(context) {
   var  candidate = widget.candidateModel;
   String initials = getInitials(candidate!.name!);

   return customContainer(
        context: context,
        addWidget: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    child: CustomText(
                      text: initials!= "" ? initials: "",
                      fontWeight: FontWeight.w700,
                      size: 14,
                      color: AppColors.pureWhiteColor,
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  CustomText(
                    text: candidate.name ?? "",
                    fontWeight: FontWeight.w700,
                    size: 24,
                    color: Theme.of(context).colorScheme.textClrChange,
                  ),
                ],
              ),
              SizedBox(
                height: 20.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 150.w),
                    child: IntrinsicWidth(
                      child: Container(
                        alignment: Alignment.center,
                        height: 35.h,
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                       // color: Colors.blue
                          gradient: LinearGradient(
                            colors: [Colors.blue,Colors.purple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          // color:AppColors.primary.withValues(alpha: 0.4),
                        ),
                        child: CustomText(
                          text: candidate.position!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          color: AppColors.whiteColor,
                          size: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 150.w),
                    child: IntrinsicWidth(
                      child: Container(
                        alignment: Alignment.center,
                        height: 35.h,
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        // color: AppColors.primary
                          gradient: LinearGradient(
                            colors: [Colors.blue,Colors.purple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          // color:AppColors.primary.withValues(alpha: 0.4),
                        ),
                        child: CustomText(
                          text: candidate.status!.name!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          color: AppColors.whiteColor,
                          size: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
            ],
          ),
        ));
  }


  Widget _candidatePersonalDetailsCard(context,candidate) {
    String dateCreated = formatDateFromApi(candidate.createdAt!, context);

    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 20.h),
      child:  customContainer(
        width: 600.w,
        context: context,
        addWidget: Padding(
          padding: EdgeInsets
              .symmetric(
              horizontal:
              18.w,
              vertical:
              20.h),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment
                .start,
            crossAxisAlignment:
            CrossAxisAlignment
                .start,

            children: [


              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child:
                    _details(
                        label: AppLocalizations
                            .of(context)!
                            .phonenumber,
                        title: candidate.phone ??
                            "-"),
                  ),
                  SizedBox(
                    width:
                    30.w,
                  ),
                  Expanded(
                    child: _details(
                        label: AppLocalizations
                            .of(context)!
                            .email,
                        title: candidate.email??
                            "-"),
                  ),
                ],
              ),
              SizedBox(
                height: 8.h,
              ),
              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _details(
                        label: AppLocalizations
                            .of(context)!
                            .position,
                        title: candidate.position ??
                            "-"),
                  ),
                  SizedBox(
                    width:
                    30.w,
                  ),
                  Expanded(
                    child: _details(
                        label: AppLocalizations
                            .of(context)!
                            .source,
                        title: candidate.source ??
                            "-"),
                  ),
                ],
              ),
              SizedBox(
                height: 8.h,
              ),
              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
crossAxisAlignment: CrossAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _details(
                    
                        label: AppLocalizations
                            .of(context)!
                            .status,
                        title: candidate.status.name ??
                            "-"),
                  ),
                  SizedBox(
                    width:
                    30.w,
                  ),
                  Expanded(
                    child: _details(
                        label: AppLocalizations
                            .of(context)!
                            .createdat,
                        title: dateCreated != "" ?dateCreated:
                            "-"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _details(
      {required String label, required String title}) {
    return SizedBox(
      // width: iswidth == true ? 290 : 140.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            color: Theme
                .of(context)
                .colorScheme
                .textClrChange,
            size: 15.sp,
            fontWeight: FontWeight.w600,
          ),
          CustomText(
            text: title,
            color: Theme
                .of(context)
                .colorScheme
                .textClrChange,
            size: 13.sp,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }
}
