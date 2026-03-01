import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import 'package:taskify/config/colors.dart';
import '../../../routes/routes.dart';
import '../../../src/generated/i18n/app_localizations.dart';

import 'package:taskify/config/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/screens/clients/widgets/app_delegates.dart';
import 'package:taskify/screens/clients/widgets/loading_widget.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';

import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import '../../../bloc/lead_id/leadid_bloc.dart';
import '../../../bloc/lead_id/leadid_event.dart';
import '../../../bloc/lead_id/leadid_state.dart';
import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/permissions/permissions_event.dart';
import '../../../bloc/setting/settings_bloc.dart';
import '../../../bloc/setting/settings_event.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../config/internet_connectivity.dart';
import '../../../data/model/leads/leads_model.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/no_internet_screen.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/side_bar.dart';
import 'follow_up_lead_detail.dart';
import 'info_lead_details.dart';

class LeadDetailsScreen extends StatefulWidget {
  final int id;

  const LeadDetailsScreen({
    super.key,
    required this.id,
  });

  @override
  State<LeadDetailsScreen> createState() => _LeadDetailsScreenState();
}

class _LeadDetailsScreenState extends State<LeadDetailsScreen>
    with TickerProviderStateMixin {
  String initialCountry = defaultCountry;
  PhoneNumber number = PhoneNumber(isoCode: defaultCountry);

  DateTime selectedDateStarts = DateTime.now();
  DateTime selectedDateEnds = DateTime.now();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  String selectedCategory = '';
  String? firstName;
  String? uploadPicture;
  String? lastName;
  String? role;
  String? company;
  String? email;
  String? phone;
  String? countryCode;
  String? countryIsoCode;
  String? password;
  String? passwordConfirmation;
  String? type;
  String? dob;
  String? doj;
  String? address;
  String? city;
  String? stateOfCity;
  String? country;
  String? zip;
  String? profile;
  int? status;
  int? internalPurpose;
  int? emailVerificationMailSent;
  String? emailVerifiedAt;
  String? createdAt;
  String? updatedAt;
  LeadModel? leadModel;
  bool isLoadingMore = false;
  String currency = "";
  String dateUpdated = "";
  String dateCreated = "";
  int? id;

  String jobTitle = "";
  String leadStage = "";
  String leadSource = "";
  String industry = "";
  String assignedUser = "";
  String assignedUserEmail = "";
  String assignedUserProfile = "";
  String website = "";
  String linkedIn = "";
  String instagram = "";
  String pinterest = "";
  String leadStageColorIn = "";

  String statusOfClient = "Inactive";
  String isNavigated = ""; // Declare a variable to track navigation

  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
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
    _tabController = TabController(length: 2, vsync: this);

    // Listen for tab changes
    _tabController.addListener(() {
      setState(() {});
    });
    context.read<SettingsBloc>().add(const SettingsList("general_settings"));
    currency = context.read<SettingsBloc>().currencySymbol!;

    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    BlocProvider.of<LeadIdBloc>(context).add(LeadIdListId(widget.id));
  }

  Future<void> _onRefresh() async {
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _connectivitySubscription.cancel();
  }
  final List<Map<String, dynamic>> colorList = [
    {"title": "Primary", "color": AppColors.primary},
    {"title": "Secondary", "color": const Color(0xFF8996a6)},
    {"title": "Success", "color": const Color(0xFF3ffb01)},
    {"title": "Danger", "color": const Color(0xFFcc251b)},
    {"title": "Warning", "color": const Color(0xFFf9aa00)},
    {"title": "Info", "color": const Color(0xFF38c2f8)},
    {"title": "Dark", "color": const Color(0xFF060606)},
  ];
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
            child: BlocConsumer<LeadIdBloc, LeadidState>(
                listener: (BuildContext context, state) {
              if (state is LeadidWithId) {
                for (var client in state.Lead) {
                  if (client.id == widget.id) {
                    // if (client.status == 1) {
                    //   statusOfClient = "Active";
                    // } else {
                    //   statusOfClient = "Inactive";
                    // }
                    if (client.updatedAt != null) {
                      dateUpdated =
                          formatDateFromApi(client.updatedAt!, context);
                    }
                    if (client.createdAt != null) {
                      dateCreated =
                          formatDateFromApi(client.createdAt!, context);
                    }
                  }
                }
              }
            }, builder: (context, state) {
              print("cfgvhjnkm $state");
              if (state is LeadidInitial) {
                return LoadingWidget(title: AppLocalizations.of(context)!
                    .leaddetails,);
              }
              if (state is LeadIdError) {
                return SizedBox(
                  child: CustomText(
                    text: state.errorMessage,
                    color: Theme.of(context).colorScheme.textClrChange,
                    size: 15,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }
              if (state is LeadidLoading) {
                return LoadingWidget(title: AppLocalizations.of(context)!
                    .leaddetails,);
              } else if (state is LeadidWithId) {
                for (var client in state.Lead) {
                  if (client.id == widget.id) {

                    LeadModel selectedUser = state.Lead.firstWhere(
                        (client) => client.id == widget.id);
                    id = selectedUser.id;
                    leadModel = LeadModel(
                      id: selectedUser.id,
                      jobTitle: selectedUser.jobTitle,
                      firstName: selectedUser.firstName,
                      lastName: selectedUser.lastName,
                      company: selectedUser.company,
                      email: selectedUser.email,
                      phone: selectedUser.phone,
                      leadStage: selectedUser.leadStage!,
                      leadSource: selectedUser.leadSource!,
                      countryCode: selectedUser.countryCode,
                      industry: selectedUser.industry,
                      leadStageColor: selectedUser.leadStageColor,
                      assignedUser: AssignedUser(
                          profilePicture:
                              selectedUser.assignedUser!.profilePicture,
                          name: selectedUser.assignedUser!.name,
                          email: selectedUser.assignedUser!.email),
                      linkedin: selectedUser.linkedin,
                      instagram: selectedUser.instagram,
                      website: selectedUser.website,
                      city: selectedUser.city,
                      state: selectedUser.state,
                      country: selectedUser.country,
                      zip: selectedUser.zip,
                      createdAt: selectedUser.createdAt,
                      updatedAt: selectedUser.updatedAt,
                    );

                    // Assign values to individual variables
                    firstName = selectedUser.firstName;
                    lastName = selectedUser.lastName;
                    jobTitle = selectedUser.jobTitle ?? '';
                    leadStage = selectedUser.leadStage!;
                    assignedUserEmail = selectedUser.assignedUser!.email ?? "";
                    assignedUserProfile =
                        selectedUser.assignedUser!.profilePicture ?? "";

                    website = selectedUser.website ?? "";
                    instagram = selectedUser.instagram ?? "";
                    instagram = selectedUser.instagram ?? "";
                    pinterest = selectedUser.pinterest ?? "";
                    leadStageColorIn = selectedUser.leadStageColor ?? "";

                    leadSource = selectedUser.leadSource!;
                    industry = selectedUser.industry ?? "";
                    assignedUser = selectedUser.assignedUser!.name!;

                    company = selectedUser.company;
                    email = selectedUser.email;
                    phone = selectedUser.phone;
                    countryCode = selectedUser.countryCode;
                    // type = selectedUser.type;
                    // dob = selectedUser.dob;
                    // doj = selectedUser.doj;
                    // address = selectedUser.address;
                    city = selectedUser.city;
                    stateOfCity = selectedUser.state;
                    country = selectedUser.country;
                    zip = selectedUser.zip;
                    createdAt = selectedUser.createdAt;
                    updatedAt = selectedUser.updatedAt;

                    final String stageTitle = leadStageColorIn;
                    final matchedColor = colorList.firstWhere(
                          (item) => item['title'].toString().toLowerCase() == stageTitle.toLowerCase(),
                      orElse: () => {"color": AppColors.primary},
                    );
                    final Color leadStageColor = matchedColor['color'];
                    if (client.updatedAt != null) {
                      dateUpdated =
                          formatDateFromApi(client.updatedAt!, context);
                    }
                    if (client.createdAt != null) {
                      dateCreated =
                          formatDateFromApi(client.createdAt!, context);
                    }
                    String getInitials(String firstName, String lastName) {
                      String first = firstName.isNotEmpty
                          ? firstName[0].toUpperCase()
                          : '';
                      String last =
                          lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
                      return '$first$last';
                    }

                    return Scaffold(
                        backgroundColor:
                            Theme.of(context).colorScheme.backGroundColor,
                        body: SideBar(
                            context: context,
                            controller: sideBarController,
                            underWidget: RefreshIndicator(
                              color: AppColors.primary, // Spinner color
                              backgroundColor:
                                  Theme.of(context).colorScheme.backGroundColor,
                              onRefresh: _onRefresh,
                              child: NestedScrollView(
                                headerSliverBuilder: (BuildContext context,
                                        bool innerBoxIsScrolled) =>
                                    [
                                  SliverToBoxAdapter(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 20.w,
                                              right: 20.w,
                                              top: 0.h),
                                          child: Column(
                                            children: [
                                              Container(
                                                  decoration:
                                                      BoxDecoration(boxShadow: [
                                                    isLightTheme
                                                        ? MyThemes
                                                            .lightThemeShadow
                                                        : MyThemes
                                                            .darkThemeShadow,
                                                  ]),
                                                  // color: Colors.red,
                                                  // width: 300.w,
                                                  child: InkWell(
                                                    onTap: () {
                                                      router.pop();

                                                      // BlocProvider.of<
                                                      //     ProjectBloc>(
                                                      //     context)
                                                      //     .add(
                                                      //     ProjectDashBoardList());
                                                      // BlocProvider.of<
                                                      //     TaskBloc>(
                                                      //     context)
                                                      //     .add(
                                                      //     AllTaskListOnTask());
                                                    },
                                                    child: BackArrow(
                                                      title:
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .leaddetails,
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        SizedBox(
                                          height: 20.h,
                                        ),
                                        Padding(
                                          padding:  EdgeInsets.symmetric(horizontal: 18.h),
                                          child: customContainer(
                                              width: 600.w,
                                              context: context,
                                              addWidget: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.w,
                                                    vertical: 10.h),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 45.r,
                                                          backgroundColor:
                                                              AppColors.primary,
                                                          child: CustomText(
                                                            text: getInitials(
                                                                firstName ?? "",
                                                                lastName ?? ""),
                                                            color:AppColors.whiteColor,
                                                            size: 30,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 10.h,
                                                    ),
                                                    CustomText(
                                                      text: firstName ?? "",
                                                      // text: getTranslated(context, 'myweeklyTask'),
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .textClrChange,
                                                      size: 20.sp,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    // SizedBox(height: 2.h,),
                                                    CustomText(
                                                      text: lastName ?? "",
                                                      // text: getTranslated(context, 'myweeklyTask'),
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .textClrChange,
                                                      size: 20.sp,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    SizedBox(
                                                      height: 5.h,
                                                    ),
                                                    jobTitle!=""  ? CustomText(
                                                      text: jobTitle,
                                                      // text: getTranslated(context, 'myweeklyTask'),
                                                      color: AppColors.greyColor,
                                                      size: 15.sp,
                                                      fontWeight: FontWeight.w500,
                                                    ):SizedBox.shrink(),
                                                    SizedBox(
                                                      height: 5.h,
                                                    ),
                                                    CustomText(
                                                      text: company ?? "",
                                                      // text: getTranslated(context, 'myweeklyTask'),
                                                      color: AppColors.greyColor,
                                                      size: 15.sp,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    Divider(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .dividerClrChange),
                                                    _details(
                                                        label:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .leadstage,
                                                        title: leadStage,leadStageColor:leadStageColor),
                                                    SizedBox(
                                                      height: 8.w,
                                                    ),
                                                    _details(
                                                        label:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .leadsource,
                                                        title: leadSource),
                                                    SizedBox(
                                                      height: 8.w,
                                                    ),
                                                    _details(
                                                        label:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .industry,
                                                        title: industry),
                                                    SizedBox(
                                                      height: 8.w,
                                                    ),
                                                    _details(
                                                        label:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .created,
                                                        title: dateCreated),
                                                    SizedBox(
                                                      height: 8.w,
                                                    ),
                                                    _assignedTo(
                                                        label:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .assignedto,
                                                        title: assignedUser,
                                                        email: assignedUserEmail,
                                                        name: assignedUser,
                                                        image:
                                                            assignedUserProfile)
                                                  ],
                                                ),
                                              )),
                                        ),
                                        SizedBox(
                                          height: 20.h,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 18.w,),
                                          child: customContainer(
                                            width: 600.w,
                                            context: context,
                                            addWidget: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 18.w,
                                                  vertical: 18.h
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .sociallinks,
                                                    // text: getTranslated(context, 'myweeklyTask'),
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .textClrChange,
                                                    size: 15.sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  SizedBox(
                                                    height: 10.h,
                                                  ),
                                                 linkedIn!=""?   _socialLinks(
                                                      label: "LinkedIn",
                                                      url: linkedIn,
                                                      icon:
                                                          "assets/images/png/linkedin.png"):SizedBox.shrink(),
                                                  website!=""?   _socialLinks(
                                                      label: "Website",
                                                      url: website,
                                                      icon:
                                                          "assets/images/png/website.png"):SizedBox.shrink(),
                                                  instagram!=""?   _socialLinks(
                                                      label: "Instagram",
                                                      url: instagram,
                                                      icon:
                                                          "assets/images/png/instagram.png") :SizedBox.shrink(),
                                                  instagram!=""?  _socialLinks(
                                                      label: "Pinterest",
                                                      url: pinterest,
                                                      icon:
                                                          "assets/images/png/pinterest.png"):SizedBox.shrink()
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ])),
                                  SliverPersistentHeader(
                                    pinned: true,
                                    delegate: AppBarDelegate(
                                      SizedBox.shrink(),
                                      // Or use Container() if needed
                                      minHeight: 40.h,
                                      // Ensure it matches the desired height
                                      maxHeight: 40
                                          .h, // Keep both values the same to prevent stretching
                                    ),
                                  ),
                                  SliverPersistentHeader(
                                    pinned: true,
                                    delegate: SliverAppBarDelegate(
                                      TabBar(
                                        controller: _tabController,
                                        dividerColor: Colors.transparent,
                                        padding: EdgeInsets.zero,
                                        labelPadding: EdgeInsets.zero,
                                        labelColor: Colors.white,
                                        // Selected tab text color
                                        unselectedLabelColor: AppColors.primary,
                                        // Unselected tab text color
                                        indicator: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                        ),
                                        tabs: [
                                          Tab(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                              width: double.infinity,
                                              child: Center(
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .info,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15.sp,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Tab(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.backGroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                              width: double.infinity,
                                              child: Center(
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .followups,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15.sp,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                                body: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    InfoPage(
                                      model: selectedUser,
                                      currency: currency,
                                      showTabs: false,
                                      initialTab: 0,
                                    ),
                                    FollowUpsDetailsPage(
                                      leadId:widget.id,
                                      model: selectedUser,
                                      currency: currency,
                                      showTabs: false,
                                      initialTab: 1,
                                    ),
                                  ],
                                ),
                              ),
                            )));
                  }
                }
              }
              return LoadingWidget(title: AppLocalizations.of(context)!
                  .leaddetails,);
            }));
  }

  Widget _details(
      {required String label, required String title,Color? leadStageColor}) {
    return SizedBox(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: label,
              color: Theme.of(context).colorScheme.textClrChange,
              size: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(width: 10.w,),
          label == AppLocalizations.of(
              context)!
              .leadstage ?  ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 180.w), // Max width cap
              child: IntrinsicWidth(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  height: 25.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: leadStageColor!,
                  ),
                  child: Center(
                    child: CustomText(
                      text: title,
                      color: AppColors.whiteColor,
                      size: 14.sp,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ):   Flexible(
              child: CustomText(
                text: title,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 12.sp,
                maxLines: 2,
                softwrap: true,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _assignedTo(
      {required String label,
      required String title,
      required String email,
      required String name,
      required String image}) {
    return SizedBox(
      // width: iswidth == true ? 290 : 140.w,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: label,
              color: Theme.of(context).colorScheme.textClrChange,
              size: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(image),
                    radius: 18.r, // Size of the profile image
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: title,
                        color: Theme.of(context).colorScheme.textClrChange,
                        size: 12.sp,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w400,
                      ),
                      CustomText(
                        text: email,
                        color: Theme.of(context).colorScheme.textClrChange,
                        size: 12.sp,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _socialLinks(
      {required String label, required String icon, required String url}) {
    return SizedBox(
      // width: iswidth == true ? 290 : 140.w,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(icon),
              radius: 10.r, // Size of the profile image
            ),
            SizedBox(
              width: 10.w,
            ),
          Flexible(
            child:  CustomText(
              text: url,
              color: Theme.of(context).colorScheme.textClrChange,
              size: 15.sp,
              maxLines: 2,
              softwrap: true,
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.w600,
            ),
          )
          ],
        ),
      ),
    );
  }
}
