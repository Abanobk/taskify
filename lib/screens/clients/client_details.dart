import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:heroicons/heroicons.dart';

import 'package:taskify/config/constants.dart';
import 'package:taskify/data/model/Project/all_project.dart';
import 'package:taskify/data/model/clients/all_client_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/screens/clients/widgets/app_delegates.dart';
import 'package:taskify/screens/clients/widgets/loading_widget.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../bloc/client_id/clientid_bloc.dart';
import '../../bloc/client_id/clientid_event.dart';
import '../../bloc/client_id/clientid_state.dart';
import '../../bloc/project/project_state.dart';
import '../../bloc/clients/client_bloc.dart';
import '../../bloc/clients/client_event.dart';
import '../../bloc/clients/client_state.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/permissions/permissions_event.dart';
import '../../bloc/project/project_bloc.dart';
import '../../bloc/project/project_event.dart';
import '../../bloc/setting/settings_bloc.dart';
import '../../bloc/setting/settings_event.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/task/task_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../../src/generated/i18n/app_localizations.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_container.dart';
import '../../utils/widgets/custom_dimissible.dart';
import '../../utils/widgets/custom_text.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/row_dashboard.dart';
import '../../utils/widgets/status_priority_row.dart';
import '../../utils/widgets/toast_widget.dart';
import '../widgets/custom_container.dart';
import '../widgets/detail_container.dart';
import '../widgets/detail_page_menu.dart';
import '../widgets/html_widget.dart';
import '../widgets/no_data.dart';
import '../widgets/side_bar.dart';
import '../widgets/user_client_box.dart';
import 'package:taskify/screens/clients/widgets/project_tasks.dart';

class ClientDetailsScreen extends StatefulWidget {
  final int id;
  final String? isClient;

  const ClientDetailsScreen({super.key, required this.id, this.isClient});

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen>
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
  Assigned? assigned;
  AllClientModel? clientModel;
  bool isLoadingMore = false;
  String currency = "";
  String dateUpdated = "";
  String dateCreated = "";
  int? id;

  String statusOfClient = "Inactive";
  String isNavigated = ""; // Declare a variable to track navigation

  final SlidableBarController sideBarController =
  SlidableBarController(initialStatus: false);
  final _key = GlobalKey<ExpandableFabState>();
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
    currency = context
        .read<SettingsBloc>()
        .currencySymbol!;

    BlocProvider.of<TaskBloc>(context)
        .add(AllTaskListOnTask(clientId: [widget.id]));
    BlocProvider.of<ProjectBloc>(context)
        .add(ProjectDashBoardList(clientId: [widget.id]));
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    BlocProvider.of<ClientidBloc>(context).add(ClientIdListId(widget.id));
    BlocProvider.of<ProjectBloc>(context).add(
        ProjectDashBoardList(clientId: [widget.id]));
  }

  Future<void> _onRefresh() async {
    BlocProvider.of<TaskBloc>(context)
        .add(AllTaskListOnTask(clientId: [widget.id]));
    BlocProvider.of<ProjectBloc>(context)
        .add(ProjectDashBoardList(clientId: [widget.id]));
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    BlocProvider.of<ClientidBloc>(context).add(ClientIdListId(
      widget.id,
    ));
    BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
  }

  void _onDeleteClient(clientId) {
    final setting = context.read<ClientBloc>();
    BlocProvider.of<ClientBloc>(context).add(DeleteClients(clientId));
    setting.stream.listen((state) {
      if (state is ClientDeleteSuccess) {
        if (mounted) {
          Navigator.of(context).pop();
          router.replace('/client');
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is ClientError) {
        if (mounted) {
          Navigator.of(context).pop();
          router.replace('/client');
          flutterToastCustom(
              msg: state.errorMessage,
              color: AppColors.primary);
        }
      }
      if (state is ClientDeleteError) {
        if (mounted) {
          Navigator.of(context).pop();
          router.replace('/client');
          flutterToastCustom(msg: state.errorMessage);
        }
      }
    });
  }

  void _onEditClient(clientModel) {
    _key.currentState?.toggle();
    if (context
        .read<PermissionsBloc>()
        .iseditClient == true) {
      router.push(
        '/createclient',
        extra: {
          'isCreate': false,
          "clientModel": clientModel,
          "fromDetail": true
        },
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _connectivitySubscription.cancel();
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
          BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
          BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask());
        },
        child: BlocConsumer<ClientidBloc, ClientidState>(
            listener: (BuildContext context, state) {
              if (state is ClientidWithId) {
                for (var client in state.client) {
                  if (client.id == widget.id) {
                    if (client.status == 1) {
                      statusOfClient = "Active";
                    } else {
                      statusOfClient = "Inactive";
                    }
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
          if (state is ClientInitial) {
            return LoadingWidget(title: AppLocalizations.of(context)!
                .clientdetails,);
          }
          if (state is ClientIdError) {
            return SizedBox(
              child: CustomText(
                text: state.errorMessage,
                color: Theme
                    .of(context)
                    .colorScheme
                    .textClrChange,
                size: 15,
                fontWeight: FontWeight.w700,
              ),
            );
          }
          if (state is ClientidLoading) {
            return LoadingWidget(title: AppLocalizations.of(context)!
                .clientdetails,);
          }
          else if (state is ClientidWithId) {
            for (var client in state.client) {
              if (client.id == widget.id) {
                AllClientModel selectedUser = state.client.firstWhere((
                    client) => client.id == widget.id);
                id = selectedUser.id;
                statusOfClient = (client.status == 1) ? "Active" : "Inactive";
                clientModel = AllClientModel(
                    id: selectedUser.id,
                    profile: selectedUser.profile,
                    firstName: selectedUser.firstName,
                    lastName: selectedUser.lastName,
                    role: selectedUser.role,
                    company: selectedUser.company,
                    email: selectedUser.email,
                    phone: selectedUser.phone,
                    countryCode: selectedUser.countryCode,
                    type: selectedUser.type,
                    dob: selectedUser.dob,
                    doj: selectedUser.doj,
                    address: selectedUser.address,
                    city: selectedUser.city,
                    state: selectedUser.state,
                    country: selectedUser.country,
                    zip: selectedUser.zip,
                    status: selectedUser.status,
                    createdAt: selectedUser.createdAt,
                    updatedAt: selectedUser.updatedAt,
                    assigned: selectedUser.assigned,
                    internalPurpose: selectedUser.internalPurpose,
                    emailVerificationMailSent: selectedUser
                        .emailVerificationMailSent,
                    emailVerifiedAt: selectedUser.emailVerifiedAt
                );

                // Assign values to individual variables
                uploadPicture = selectedUser.profile;
                firstName = selectedUser.firstName;
                lastName = selectedUser.lastName;
                role = selectedUser.role;
                company = selectedUser.company;
                email = selectedUser.email;
                phone = selectedUser.phone;
                countryCode = selectedUser.countryCode;
                type = selectedUser.type;
                dob = selectedUser.dob;
                doj = selectedUser.doj;
                address = selectedUser.address;
                city = selectedUser.city;
                stateOfCity = selectedUser.state;
                country = selectedUser.country;
                zip = selectedUser.zip;
                status = selectedUser.status;
                createdAt = selectedUser.createdAt;
                updatedAt = selectedUser.updatedAt;
                assigned = selectedUser.assigned;
                internalPurpose = selectedUser.internalPurpose;
                emailVerifiedAt = selectedUser.emailVerifiedAt;
                emailVerificationMailSent =
                    selectedUser.emailVerificationMailSent;
                profile = selectedUser.profile;
                if (client.updatedAt != null) {
                  dateUpdated =
                      formatDateFromApi(client.updatedAt!, context);
                }
                if (client.createdAt != null) {
                  dateCreated =
                      formatDateFromApi(client.createdAt!, context);
                }

                return Scaffold(
                    backgroundColor:
                    Theme
                        .of(context)
                        .colorScheme
                        .backGroundColor,
                    floatingActionButtonLocation: ExpandableFab.location,
                    floatingActionButton: context
                        .read<PermissionsBloc>()
                        .isdeleteProject ==
                        true ||
                        context
                            .read<PermissionsBloc>()
                            .iseditProject ==
                            true
                        ? detailMenu(

                      isChat: false,


                        isDiscuss: false,
                        isEdit: context
                            .read<PermissionsBloc>()
                            .iseditProject,
                        isDelete: context
                            .read<PermissionsBloc>()
                            .isdeleteProject,
                        key: _key,
                        context: context,
                        onpressEdit: () {
                          _onEditClient(client);
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
                                      _onDeleteClient(widget.id);
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
                        underWidget: RefreshIndicator(
                          color:
                          AppColors.primary, // Spinner color
                          backgroundColor: Theme
                              .of(context)
                              .colorScheme
                              .backGroundColor,
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
                                              BoxDecoration(
                                                  boxShadow: [
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

                                                  BlocProvider.of<
                                                      ProjectBloc>(
                                                      context)
                                                      .add(
                                                      ProjectDashBoardList());
                                                  BlocProvider.of<
                                                      TaskBloc>(
                                                      context)
                                                      .add(
                                                      AllTaskListOnTask());
                                                },
                                                child: BackArrow(
                                                  title: AppLocalizations
                                                      .of(context)!
                                                      .clientdetails,
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
                                      MainAxisAlignment
                                          .start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        SizedBox(height: 20.h,),
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
                                              Colors.white,
                                              child: Container(
                                                decoration:
                                                BoxDecoration(
                                                  shape: BoxShape
                                                      .circle,
                                                  border: Border
                                                      .all(
                                                    color: AppColors
                                                        .greyColor,
                                                    width:
                                                    1.5.w,
                                                  ),
                                                ),
                                                child:
                                                CircleAvatar(
                                                  backgroundColor:
                                                  Colors
                                                      .transparent,
                                                  radius: 45.r,
                                                  backgroundImage:
                                                  NetworkImage(
                                                      profile!),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20.h,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 18.w),
                                          child: customContainer(
                                            width: 600.w,
                                            context: context,
                                            addWidget: Padding(
                                              padding: EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                  10.w,
                                                  vertical:
                                                  10.h),
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      HeroIcon(
                                                        HeroIcons
                                                            .userCircle,
                                                        style: HeroIconStyle
                                                            .outline,
                                                        color: Theme
                                                            .of(
                                                            context)
                                                            .colorScheme
                                                            .textClrChange,
                                                      ),
                                                      SizedBox(
                                                        width:
                                                        5.w,
                                                      ),

                                                      CustomText(
                                                        text: AppLocalizations
                                                            .of(
                                                            context)!
                                                            .personalinfo,
                                                        // text: getTranslated(context, 'myweeklyTask'),
                                                        color: Theme
                                                            .of(
                                                            context)
                                                            .colorScheme
                                                            .textClrChange,
                                                        size: 15,
                                                        fontWeight:
                                                        FontWeight
                                                            .w700,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10.h,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .start,

                                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      _details(
                                                          label: AppLocalizations
                                                              .of(context)!
                                                              .firstname,
                                                          title: firstName ??
                                                              ""),
                                                      SizedBox(
                                                        width:
                                                        30.w,
                                                      ),
                                                      _details(
                                                          label: AppLocalizations
                                                              .of(context)!
                                                              .lastname,
                                                          title: client
                                                              .lastName ??
                                                              ""),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 8.h,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .start,

                                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      _details(
                                                          label: AppLocalizations
                                                              .of(context)!
                                                              .email,
                                                          title: client.email ??
                                                              ""),
                                                      SizedBox(
                                                        width:
                                                        30.w,
                                                      ),
                                                      client.countryCode !=
                                                          null &&
                                                          client.countryCode !=
                                                              ""
                                                          ? _details(
                                                          label: AppLocalizations
                                                              .of(context)!
                                                              .phonenumber,
                                                          title:
                                                          "${client
                                                              .countryCode} ${client
                                                              .phone ?? "-"}")
                                                          : _details(
                                                          label:
                                                          AppLocalizations.of(
                                                              context)!
                                                              .phonenumber,
                                                          title: "-"),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15.h,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 18.w),
                                          child: customContainer(
                                            width: 600.w,
                                            context: context,
                                            addWidget: Padding(
                                              padding: EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                  10.w,
                                                  vertical:
                                                  10.h),
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      HeroIcon(
                                                        HeroIcons
                                                            .mapPin,
                                                        style: HeroIconStyle
                                                            .outline,
                                                        color: Theme
                                                            .of(
                                                            context)
                                                            .colorScheme
                                                            .textClrChange,
                                                      ),
                                                      SizedBox(
                                                        width:
                                                        5.w,
                                                      ),
                                                      CustomText(
                                                        text: AppLocalizations
                                                            .of(
                                                            context)!
                                                            .addressinfo,
                                                        // text: getTranslated(context, 'myweeklyTask'),
                                                        color: Theme
                                                            .of(
                                                            context)
                                                            .colorScheme
                                                            .textClrChange,
                                                        size: 15,
                                                        fontWeight:
                                                        FontWeight
                                                            .w700,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10.h,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .start,

                                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      _details(
                                                          label: AppLocalizations
                                                              .of(context)!
                                                              .city,
                                                          title: client.city ??
                                                              "-"),
                                                      SizedBox(
                                                        width:
                                                        30.w,
                                                      ),
                                                      _details(
                                                          label: AppLocalizations
                                                              .of(context)!
                                                              .country,
                                                          title: client
                                                              .country ??
                                                              "-"),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 8.h,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .start,

                                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      _details(
                                                          label: AppLocalizations
                                                              .of(context)!
                                                              .zipcode,
                                                          title: client.zip ??
                                                              "-"),
                                                      SizedBox(
                                                        width:
                                                        30.w,
                                                      ),
                                                      _details(
                                                          label: AppLocalizations
                                                              .of(context)!
                                                              .state,
                                                          title: client.state ??
                                                              "-"),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 8.h,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .start,

                                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      _details(
                                                          iswidth:
                                                          true,
                                                          label: AppLocalizations
                                                              .of(context)!
                                                              .address,
                                                          title: client
                                                              .address ??
                                                              "-"),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15.h,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 18.w),
                                          child: customContainer(
                                              width: 600.w,
                                              context: context,
                                              addWidget: Padding(
                                                padding: EdgeInsets
                                                    .symmetric(
                                                    horizontal:
                                                    10.w,
                                                    vertical:
                                                    10.h),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        _details(
                                                            label: AppLocalizations
                                                                .of(context)!
                                                                .createdat,
                                                            title:
                                                            dateCreated),
                                                        SizedBox(
                                                          width:
                                                          30.w,
                                                        ),
                                                        _details(
                                                            label: AppLocalizations
                                                                .of(context)!
                                                                .updatedAt,
                                                            title:
                                                            dateUpdated),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              )),
                                        ),
                                        SizedBox(
                                          height: 15.h,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 18.w),
                                          child: customContainer(
                                            width: 600.w,
                                            context: context,
                                            addWidget: singleDetails(
                                                context: context,
                                                label: AppLocalizations
                                                    .of(
                                                    context)!
                                                    .role,
                                                title:
                                                client.role ??
                                                    "-"),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15.h,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 18.w),
                                          child: customContainer(
                                            width: 600.w,
                                            context: context,
                                            addWidget: singleDetails(
                                                context: context,
                                                label: AppLocalizations
                                                    .of(
                                                    context)!
                                                    .company,
                                                title: client
                                                    .company ??
                                                    "-"),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15.h,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 18.w),
                                          child: customContainer(
                                            width: 600.w,
                                            context: context,
                                            addWidget: singleDetails(
                                                context: context,
                                                label: AppLocalizations
                                                    .of(
                                                    context)!
                                                    .status,
                                                title:
                                                statusOfClient,
                                                button: true,
                                                color:
                                                client
                                                    .emailVerificationMailSent ==
                                                    1
                                                    ? Colors
                                                    .green
                                                    : Colors
                                                    .red),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15.h,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 18.w),
                                          child: customContainer(
                                            width: 600.w,
                                            context: context,
                                            addWidget: singleDetails(
                                                context: context,
                                                isTickIcon: true,
                                                label: AppLocalizations
                                                    .of(
                                                    context)!
                                                    .verifiedemail,
                                                title: client
                                                    .emailVerificationMailSent ==
                                                    1
                                                    ? "Email Verified"
                                                    : "Not Verified",
                                                button: false,
                                                color:
                                                client
                                                    .emailVerificationMailSent ==
                                                    1
                                                    ? Colors
                                                    .green
                                                    : Colors
                                                    .red),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15.h,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 18.w),
                                          child: customContainer(
                                            width: 600.w,
                                            context: context,
                                            addWidget: singleDetails(
                                                context: context,
                                                label: AppLocalizations
                                                    .of(
                                                    context)!
                                                    .isInternamPurposeOnly,
                                                title:
                                                internalPurpose == 0
                                                    ? AppLocalizations
                                                    .of(
                                                    context)!
                                                    .off
                                                    : AppLocalizations
                                                    .of(
                                                    context)!
                                                    .on,
                                                button: true,
                                                color:
                                                client.internalPurpose ==
                                                    1
                                                    ? Colors
                                                    .green
                                                    : Colors
                                                    .red),
                                          ),
                                        ),


                                      ])
                              ),
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
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    tabs: [
                                      Tab(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                12.r),
                                          ),
                                          width: double.infinity,
                                          child: Center(
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .tasks,
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
                                            borderRadius: BorderRadius.circular(
                                                12.r),
                                          ),
                                          width: double.infinity,
                                          child: Center(
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .projectwithCounce,
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
                              controller:
                              _tabController,
                              children: [
                                ProjectTasksPage(
                                  clientId: widget.id,
                                  currency: currency,
                                  showTabs: false,
                                  initialTab: 0,
                                ),
                                ProjectTasksPage(
                                  clientId: widget.id,
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
              .clientdetails,);
        }));
  }

  void _showUserClientDialog({
    required BuildContext context,
    required String from,
    required String title,
    required List<dynamic> list,
  }) {
    userClientDialog(
      context: context,
      from: from,
      title: title,
      list: list,
    );
  }

  void onDeleteTask(task) {
    context.read<TaskBloc>().add(DeleteTask(task));
    final setting = context.read<TaskBloc>();
    setting.stream.listen((state) {
      if (state is TaskDeleteSuccess) {
        if (mounted) {
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
          BlocProvider.of<TaskBloc>(context).add(AllTaskList());
        }
      }
      if (state is TaskDeleteError) {
        flutterToastCustom(msg: state.errorMessage);
      }
    });
  }


  void _onDeleteProject({required int id}) {
    final setting = context.read<ProjectBloc>();
    BlocProvider.of<ProjectBloc>(context).add(DeleteProject(id));
    setting.stream.listen((state) {
      if (state is ProjectDeleteSuccess) {
        if (mounted) {
          BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is ProjectDeleteError) {
        if (mounted) {
          BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
          // flutterToastCustom(msg: state.errorMessage);
        }
      }
    });
  }

  Widget projectList(stateProject, index, project, date, isLightTheme,
      currency) {
    return DismissibleCard(
      direction: context
          .read<PermissionsBloc>()
          .isdeleteProject == true &&
          context
              .read<PermissionsBloc>()
              .iseditProject == true
          ? DismissDirection.horizontal
          : context
          .read<PermissionsBloc>()
          .isdeleteProject == true
          ? DismissDirection.endToStart
          : context
          .read<PermissionsBloc>()
          .iseditProject == true
          ? DismissDirection.startToEnd
          : DismissDirection.none,
      title: stateProject[index].id.toString(),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (context
              .read<PermissionsBloc>()
              .iseditProject == true) {
            _navigateToEditProject(project);
            return false;
          }
          return false;
        }

        if (direction == DismissDirection.endToStart) {
          try {
            final result = await showDialog<bool>(
              context: context,
              barrierDismissible:
              false, // Prevent dismissing by tapping outside
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  backgroundColor:
                  Theme.of(context).colorScheme.alertBoxBackGroundColor,
                  title: Text(
                    AppLocalizations.of(context)!.confirmDelete,
                  ),
                  content: Text(
                    AppLocalizations.of(context)!.areyousure,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        print(
                            "User confirmed deletion - about to pop with true");
                        Navigator.of(context).pop(true); // Confirm deletion
                      },
                      child: Text(
                        AppLocalizations.of(context)!.ok,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        print(
                            "User cancelled deletion - about to pop with false");
                        Navigator.of(context).pop(false); // Cancel deletion
                      },
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                      ),
                    ),
                  ],
                );
              },
            );

            print("Dialog result received: $result");
            print("About to return from confirmDismiss: ${result ?? false}");

            // If user confirmed deletion, handle it here instead of in onDismissed
            if (result == true) {
              print("Handling deletion directly in confirmDismiss");
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  stateProject.removeAt(index);

                });
                _onDeleteProject(id: stateProject[index].id);
              });
              // Return false to prevent the dismissible from animating
              return false;
            }

            return false; // Always return false since we handle deletion manually
          } catch (e) {
            print("Error in dialog: $e");
            return false;
          }
        }

        return false;
      },
      onDismissed: (DismissDirection direction) {
        if (direction == DismissDirection.endToStart &&
            context
                .read<PermissionsBloc>()
                .isdeleteProject == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {    setState(() {
            stateProject.removeAt(index);
          });
    _onDeleteProject(id: stateProject[index].id);

    });
        }
      },
      dismissWidget: Padding(
        padding: EdgeInsets.symmetric( horizontal: 18.w),
        child: InkWell(
          onTap: () => _navigateToProjectDetail(stateProject[index].id),
          child: buildCustomContainer(
            context: context,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProjectHeader(project),
                  _buildProjectTitleAndBudget(project, currency),
                  _buildProjectDescription(project),
                  _buildProjectStatusRow(project),
                  _buildProjectUsersAndClients(project),
                  _buildProjectDate(date),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectHeader(project) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: "#${project.id.toString()}",
          size: 14.sp,
          color: Theme
              .of(context)
              .colorScheme
              .textClrChange,
          fontWeight: FontWeight.w700,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Row(
          children: [
            HeroIcon(
              HeroIcons.clipboardDocumentList,
              style: HeroIconStyle.outline,
              color: AppColors.primary,
            ),
            project.taskCount > 1
                ? CustomText(
              text: " ${project.taskCount.toString()} ${AppLocalizations.of(
                  context)!.tasksFromDrawer}",
              size: 14.sp,
              color: Theme
                  .of(context)
                  .colorScheme
                  .textClrChange,
              fontWeight: FontWeight.w700,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
                : CustomText(
              text: " ${project.taskCount.toString()} ${AppLocalizations.of(
                  context)!.task}",
              size: 14.sp,
              color: Theme
                  .of(context)
                  .colorScheme
                  .textClrChange,
              fontWeight: FontWeight.w700,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProjectTitleAndBudget(project, currency) {
    return Padding(
      padding: EdgeInsets.only(top: 0.h),
      child: SizedBox(
        width: 300.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              width: 200.w,
              height: 40.h,
              child: CustomText(
                text: project.title!,
                size: 24,
                color: Theme
                    .of(context)
                    .colorScheme
                    .textClrChange,
                fontWeight: FontWeight.w700,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            project.budget!.isNotEmpty
                ? Container(
              alignment: Alignment.centerRight,
              height: 40.h,
              child: CustomText(
                text: "${currency != null ? "$currency" : ""}${project.budget}",
                size: 14,
                color: Theme
                    .of(context)
                    .colorScheme
                    .textClrChange,
                fontWeight: FontWeight.w700,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectDescription(project) {
    return Column(
      children: [
        if (project.description != null && project.description != "")
          SizedBox(height: 5.h),
        if (project.description != null && project.description != "")
          htmlWidget(project.description!, context, width: 290.w, height: 36.h)
        else
          Container(height: 0.h),
      ],
    );
  }

  Widget _buildProjectStatusRow(project) {
    return SizedBox(
      width: 300.w,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0.h),
        child: statusClientRow(
            project.status, project.priority, context, false),
      ),
    );
  }

  Widget _buildProjectUsersAndClients(project) {
    final users = project.users ?? [];
    final clients = project.clients ?? [];

    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: SizedBox(
        height: 60.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: InkWell(
                onTap: () =>
                    _showUserClientDialog(
                      context: context,
                      from: "user",
                      title: AppLocalizations.of(context)!.allusers,
                      list: users,
                    ),
                child: RowDashboard(list: users, title: "user"),
              ),
            ),
            if (users.isNotEmpty) SizedBox(width: 40.w),
            Expanded(
              child: InkWell(
                onTap: () =>
                    _showUserClientDialog(
                      context: context,
                      from: "client",
                      title: AppLocalizations.of(context)!.allclients,
                      list: clients,
                    ),
                child: RowDashboard(list: clients, title: "client"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectDate(String? date) {
    return date != null
        ? Padding(
      padding: EdgeInsets.only(top: 5.h),
      child: Row(
        children: [
          SizedBox(
            width: 15.w,
            child: const HeroIcon(
              HeroIcons.calendar,
              style: HeroIconStyle.outline,
            ),
          ),
          SizedBox(width: 5.w),
          CustomText(
            text: date,
            size: 12.26,
            fontWeight: FontWeight.w300,
            color: Theme
                .of(context)
                .colorScheme
                .textClrChange,
          ),
        ],
      ),
    )
        : SizedBox.shrink();
  }

  void _navigateToEditProject(project) {
    List<String>? userList = [];
    List<String>? clientList = [];
    List<String>? tagList = [];

    if (project.users != null) {
      for (var user in project.users!) {
        userList.add(user.firstName!);
      }
    }
    if (project.clients != null) {
      for (var client in project.clients!) {
        clientList.add(client.firstName!);
      }
    }

    if (project.tags != null) {
      for (var tag in project.tags!) {
        tagList.add(tag.title!);
      }
    }

    router.push(
      '/createproject',
      extra: {
        "id": project.id,
        "isCreate": false,
        "title": project.title,
        "desc": project.description,
        "start": project.startDate ?? "",
        "end": project.endDate ?? "",
        "budget": project.budget,
        'priority': project.priority,
        'priorityId': project.priorityId,
        'statusId': project.statusId,
        'note': project.note,
        "clientNames": clientList,
        "userNames": userList,
        "tagNames": tagList,
        "userId": project.userId,
        "tagId": project.tagIds,
        "clientId": project.clientId,
        "access": project.taskAccessibility,
        'status': project.status,
      },
    );
  }

  void _navigateToProjectDetail(int id) {
    router.push('/projectdetails', extra: {
      "id": id,
      "projectModel":ProjectModel.empty()
    });
  }

  Widget _details(
      {required String label, required String title, bool? iswidth}) {
    return SizedBox(
      width: iswidth == true ? 290 : 140.w,
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
            size: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          CustomText(
            text: title,
            color: Theme
                .of(context)
                .colorScheme
                .textClrChange,
            size: 12.sp,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }

}
