import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../bloc/notifications/push_notification/notification_push_bloc.dart';
import '../../bloc/notifications/push_notification/notification_push_event.dart';
import '../../bloc/notifications/system_notification/notification_bloc.dart';
import '../../bloc/notifications/system_notification/notification_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../data/model/notification/notification_model.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_text.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/no_internet_screen.dart';
import '../widgets/html_widget.dart';
import '../widgets/side_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'detail_user_list.dart';
import '../../src/generated/i18n/app_localizations.dart';


class NotificationDetailScreen extends StatefulWidget {
  final int? id;
  final String? title;
  final String? project;
  final String? user;
  final String? status;
  final String? message;
  final String? createdAt;
  final String? updatedAt;
  final List<NotiUsers>? users;
  final List<NotiClient>? clients;
  final int? index;
  const NotificationDetailScreen(
      {super.key,
      this.id,
      this.project,
      this.title,
      this.user,
      this.status,
      this.message,
      this.users,
        this.createdAt,
        this.updatedAt,
      this.clients,
      this.index});

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController budgetController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController startsController = TextEditingController();
  TextEditingController endController = TextEditingController();

  DateTime selectedDateStarts = DateTime.now();
  DateTime selectedDateEnds = DateTime.now();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  String selectedCategory = '';


  String? datestart;
  String? dateEnd;
  String? timestart;
  String? timeEnd;

  final SlidableBarController sideBarController =
  SlidableBarController(initialStatus: false);

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return  _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        :PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (!didPop) {

            BlocProvider.of<NotificationBloc>(context).add(NotificationList());

            BlocProvider.of<NotificationPushBloc>(context).add(NotificationPushList());
            router.pop(context);

          }
        },
        child:Scaffold(
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      body:  SideBar(
      context: context,
      controller: sideBarController,
      underWidget:SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 0.h),
                  child: Column(
                    children: [

                      Container(
                          decoration: BoxDecoration(boxShadow: [
                            isLightTheme
                                ? MyThemes.lightThemeShadow
                                : MyThemes.darkThemeShadow,
                          ]),
                          // color: Colors.red,
                          // width: 300.w,
                          child: InkWell(
                            onTap: (){
                              BlocProvider.of<NotificationPushBloc>(context).add(NotificationPushList());
                              BlocProvider.of<NotificationBloc>(context).add(NotificationList());

                            },
                            child: BackArrow(
                              title: AppLocalizations.of(context)!.notificationdetail,
                            ),
                          )),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 30.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Container(
                // height: 750.h,
                // width: 390.w,
                // height: 300.h,
                width: 390.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).colorScheme.containerDark,
                  boxShadow: [
                    isLightTheme
                        ? MyThemes.lightThemeShadow
                        : MyThemes.darkThemeShadow,
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 15.h,
                    ),
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 18.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: widget.title!,
                            // text: getTranslated(context, 'myweeklyTask'),
                            color: Theme.of(context).colorScheme.textClrChange,
                            size: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          SizedBox(
                            height: 15.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              widget.users!.isEmpty
                                  ? const SizedBox.shrink()
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: AppLocalizations.of(context)!.notificationusers,
                                          // text: getTranslated(context, 'myweeklyTask'),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .textClrChange,
                                          size: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            DetailUserList(list: widget.users!,)// this circle avatar we created add icon
                                          ],
                                        ),
                                      ],
                                    ),
                              widget.users!.isEmpty
                                  ? const SizedBox.shrink()
                                  : SizedBox(
                                      width: 50.w,
                                    ),
                              widget.clients!.isEmpty
                                  ? const SizedBox.shrink()
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        CustomText(
                                          text:
                                          AppLocalizations.of(context)!.notificationclients,
                                          // text: getTranslated(context, 'myweeklyTask'),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .textClrChange,
                                          size: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        ),
                                        SizedBox(
                                          width: 75.w,
                                          height: 35,
                                          // color: Colors.yellow,
                                          child: Stack(children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                for (int i = 0;
                                                    i <
                                                        (widget.clients
                                                                ?.length ??
                                                            0);
                                                    i++)
                                                  if (i < 3)
                                                    Align(
                                                      widthFactor: 0.75,
                                                      child: CircleAvatar(
                                                        radius: 15,
                                                        backgroundColor:
                                                            Colors.white,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                              color: AppColors
                                                                  .greyColor,
                                                              width: 1.5,
                                                            ),
                                                          ),
                                                          child: CircleAvatar(
                                                            radius: 15,
                                                            backgroundImage:
                                                                NetworkImage(widget
                                                                    .clients![i]
                                                                    .photo!),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                              ],
                                            ),
                                            if ((widget.clients?.length ?? 0) >
                                                3)
                                              Positioned(
                                                left: 37.w,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color:
                                                          AppColors.pureWhiteColor,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        AppColors.primary,
                                                    radius: 15,
                                                    child: CustomText(
                                                      text:
                                                          '${widget.clients!.length - 3}+',
                                                      color:
                                                          AppColors.pureWhiteColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ]),
                                        ),
                                      ],
                                    )
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),

                    _statusField(isLightTheme),
                    SizedBox(
                      height: 15.h,
                    ),

                    _messageField(isLightTheme),
                    SizedBox(
                      height: 15.h,
                    ),
                    widget.createdAt != null
                        ? Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 18.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text:
                            "${AppLocalizations.of(context)!.createdat}:  ",
                            size: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context)
                                .colorScheme
                                .textClrChange,
                          ) ,
                          CustomText(
                            text:
                            "${widget.createdAt} ",
                            size: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context)
                                .colorScheme
                                .textClrChange,
                          )
                        ],
                      ),
                    )
                        : const SizedBox.shrink(),
                    SizedBox(
                      height: 5.h,
                    ),
                    widget.updatedAt != null
                        ? Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 18.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text:
                            "${AppLocalizations.of(context)!.updatedAt}:  ",
                            size: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context)
                                .colorScheme
                                .textClrChange,
                          ) ,
                          CustomText(
                            text:
                            "${widget.updatedAt} ",
                            size: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context)
                                .colorScheme
                                .textClrChange,
                          )
                        ],
                      ),
                    )
                        : const SizedBox.shrink(),
                    SizedBox(
                      height: 15.h,
                    ),
                  ],
                ),
              ),
            )

          ],
        ),
      ),
    )));
  }


  Widget _statusField(isLightTheme) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: AppLocalizations.of(context)!.status,
            // text: getTranslated(context, 'myweeklyTask'),
            color: Theme.of(context).colorScheme.textClrChange,
            size: 14.sp,
            fontWeight: FontWeight.w800,
          ),
          SizedBox(
            height: 5.h,
          ),
          Container(
            alignment: Alignment.center,
            height: 25.h,
            width: 110.w, //
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color:widget.status == "Unread"? AppColors
                    .red:AppColors.yellow), // Set the height of the dropdown
            child: Center(
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 0.5),
                  child: CustomText(
                    text: widget.status!,
                    color: AppColors.whiteColor,
                    size: 15,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageField(isLightTheme) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: AppLocalizations.of(context)!.message,
            // text: getTranslated(context, 'myweeklyTask'),
            color: Theme.of(context).colorScheme.textClrChange,
            size: 14.sp,
            fontWeight: FontWeight.w800,
          ),
          SizedBox(
            height: 5.h,
          ),
          htmlWidget(widget.message!,context)


        ],
      ),
    );
  }
}
