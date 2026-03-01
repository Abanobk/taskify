import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:taskify/bloc/task/task_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/model/leads/leads_model.dart';
import 'package:taskify/utils/widgets/custom_text.dart';
import 'package:taskify/utils/widgets/no_data.dart';
import 'package:taskify/utils/widgets/no_permission_screen.dart';
import 'package:taskify/utils/widgets/notes_shimmer_widget.dart';
import 'package:taskify/utils/widgets/custom_dimissible.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/bloc/task/task_bloc.dart';
import 'package:taskify/bloc/task/task_event.dart';

import 'package:taskify/bloc/permissions/permissions_bloc.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/utils/widgets/my_theme.dart';


import '../../../bloc/leads/leads_bloc.dart';
import '../../../bloc/leads/leads_event.dart';
import '../../../bloc/leads/leads_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../routes/routes.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../widgets/custom_container.dart';


class InfoPage extends StatefulWidget {
  final LeadModel model;
  final String currency;
  final bool showTabs;
  final int initialTab;

  const InfoPage({
    Key? key,
    required this.model,
    required this.currency,
    this.showTabs = true,
    this.initialTab = 0,
  }) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool isLoading = false;
  bool isLoadingMore = false;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<LeadBloc>(context).add(LeadLists());

    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showTabs) {
      return Column(
        children: [
          TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            padding: EdgeInsets.zero,
            labelPadding: EdgeInsets.zero,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.primary,
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            tabs: [
              Tab(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.info,
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
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.followups,
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
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTasksTab(),
                _buildProjectsTab(),
              ],
            ),
          ),
        ],
      );
    } else {
      return widget.initialTab == 0 ? _buildTasksTab() : _buildProjectsTab();
    }
  }

  Widget _buildTasksTab() {
    return (context.read<PermissionsBloc>().isManageLeads == true)
        ? Padding(
      padding: EdgeInsets
          .symmetric(
          horizontal:
          18.w,
          vertical:
          10.h),
      child: SingleChildScrollView(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            customContainer(
                width: 600.w,
                context: context,
                addWidget:  Padding(
                  padding: EdgeInsets
                      .symmetric(
                      horizontal:
                      10.w,
                      vertical:
                      10.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const HeroIcon(
                            HeroIcons.userCircle,
                            style: HeroIconStyle.solid,
                            color: AppColors.blueColor,
                          ),
                          SizedBox(width: 10.w,),
                          CustomText(
                            text:AppLocalizations.of(context)!.contactinfo,
                            color: Theme
                                .of(context)
                                .colorScheme
                                .textClrChange,
        
                            size: 16.sp,
                            fontWeight: FontWeight.w800,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
        
                          ),
                        ],
                      ),
                      _details(label: AppLocalizations.of(context)!.name, title: "${widget.model.firstName!} ${widget.model.lastName!}"),
                      _details(label: AppLocalizations.of(context)!.email, title: widget.model.email!),
                      _details(label: AppLocalizations.of(context)!.phonenumber, title:"${getFlagEmoji(widget.model.countryIsoCode??"")} ${ widget.model.countryCode??""} ${ widget.model.phone!}")
        
                    ],
                  ),
                )),
                    SizedBox(
                      height: 15.h,
                    ),
                    customContainer(
                width: 600.w,
                context: context,
                addWidget:  Padding(
                  padding: EdgeInsets
                      .symmetric(
                      horizontal:
                      10.w,
                      vertical:
                      10.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const HeroIcon(
                            HeroIcons.buildingOffice2,
                            style: HeroIconStyle.solid,
                            color: AppColors.blueColor,
                          ),
                          SizedBox(width: 10.w,),
                          CustomText(
                            text:AppLocalizations.of(context)!.companyinfo,
                            color: Theme
                                .of(context)
                                .colorScheme
                                .textClrChange,
        
                            size: 16.sp,
                            fontWeight: FontWeight.w800,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
        
                          ),
                        ],
                      ),
                      _details(label: AppLocalizations.of(context)!.company, title: widget.model.company??""),
                      _details(label: AppLocalizations.of(context)!.jobtitle, title: widget.model.jobTitle??""),
                      _details(label: AppLocalizations.of(context)!.industry, title: widget.model.industry??"")
        
                    ],
                  ),
                )),
                    SizedBox(
                      height: 15.h,
                    ), customContainer(
                        width: 600.w,
                        context: context,
                        addWidget:  Padding(
                          padding: EdgeInsets
                              .symmetric(
                              horizontal:
                              10.w,
                              vertical:
                              10.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const HeroIcon(
                                    HeroIcons.mapPin,
                                    style: HeroIconStyle.solid,
                                    color: AppColors.blueColor,
                                  ),
                                  SizedBox(width: 10.w,),
                                  CustomText(
                                    text:AppLocalizations.of(context)!.addressinfo,
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .textClrChange,
        
                                    size: 16.sp,
                                    fontWeight: FontWeight.w800,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
        
                                  ),
                                ],
                              ),
                              _details(label: AppLocalizations.of(context)!.city, title: widget.model.city??""),
                              _details(label: AppLocalizations.of(context)!.state, title: widget.model.state??""),
                              _details(label: AppLocalizations.of(context)!.zipcode, title: widget.model.zip??""),
                              _details(label: AppLocalizations.of(context)!.country, title: widget.model.country??"")

                            ],
                          ),
                        )),
                  ],
                ),
      ),
        )
        : NoPermission();
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    BlocProvider.of<LeadBloc>(context).add(LeadLists());
    setState(() {
      isLoading = false;
    });
  }
  Widget _buildProjectsTab() {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return context.read<PermissionsBloc>().isManageLeads == true
        ? RefreshIndicator(
        color: AppColors.primary, // Spinner color
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        onRefresh: _onRefresh,
        child:
        BlocConsumer<LeadBloc, LeadState>(listener: (context, state) {
          if (state is LeadSuccess) {
            isLoadingMore = false;
            setState(() {});
          }
        }, builder: (context, state) {
          print("yuhjikm $state");
          if (state is LeadSuccess) {
            List<FollowUps> followUpList = [];
            if (state.Lead.isNotEmpty) {
              for (var i = 0; i < state.Lead.length; i++) {
                followUpList.addAll(state.Lead[i].followUps ?? []);

              }
            }

            return Container(
              child: context.read<PermissionsBloc>().isManageLeads == true
                  ? followUpList.isNotEmpty
                  ?  ListView.builder(
                padding: EdgeInsets.only(bottom: 50.h),
                // shrinkWrap: true,
                itemCount: state.isLoadingMore
                    ? followUpList
                    .length // No extra item if all data is loaded
                    : followUpList.length + 1,
                itemBuilder: (context, index) {
                  print("dfghjjklm ${followUpList}");
                  if (index < followUpList.length) {
                    return _leadsCard(isLightTheme,
                        followUpList[index], followUpList, index);
                  } else {
                    return Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 0),
                      child: Center(
                        child: isLoadingMore
                            ? const Text('')
                            : const SpinKitFadingCircle(
                          color: AppColors.primary,
                          size: 40.0,
                        ),
                      ),
                    );
                  }
                },
              )

                  : SingleChildScrollView(
                child: NoData(
                  isImage: true,
                ),
              )
                  : NoPermission(),
            );
          }
          if (state is LeadError) {
            flutterToastCustom(
                msg: state.errorMessage, color: AppColors.primary);
          }
          if (state is LeadEditError) {
            BlocProvider.of<LeadBloc>(context).add(LeadLists());
            flutterToastCustom(
                msg: state.errorMessage, color: AppColors.primary);
          }
          if (state is LeadCreateError) {
            BlocProvider.of<LeadBloc>(context).add(LeadLists());
            flutterToastCustom(
                msg: state.errorMessage, color: AppColors.primary);
          }
          if (state is LeadLoading) {
            return const NotesShimmer();
          }
          if (state is LeadEditSuccess) {
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.updatedsuccessfully,
                color: AppColors.primary);
            BlocProvider.of<LeadBloc>(context).add(LeadLists());
          }
          if (state is LeadCreateSuccess) {
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.createdsuccessfully,
                color: AppColors.primary);
            Navigator.pop(context);
            BlocProvider.of<LeadBloc>(context).add(LeadLists());
          }
          return SizedBox();
        }))
        : const NoPermission();
  }



  Widget _leadsCard(isLightTheme, lead, leadList, index) {
    String getInitials(String firstName, String lastName) {
      String first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
      String last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
      return '$first$last';
    }
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
        child: DismissibleCard(
          title: lead.id.toString(),
          direction: context.read<PermissionsBloc>().isDeleteLeads == true &&
              context.read<PermissionsBloc>().isEditLeads == true
              ? DismissDirection.horizontal // Allow both directions
              : context.read<PermissionsBloc>().isDeleteLeads  == true
              ? DismissDirection.endToStart // Allow delete
              : context.read<PermissionsBloc>().isEditLeads  == true
              ? DismissDirection.startToEnd // Allow edit
              : DismissDirection.none,
          confirmDismiss: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart&& context.read<PermissionsBloc>().isDeleteLeads== true) {
              // Right to left swipe (Delete action)
              final result = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10.r), // Set the desired radius here
                    ),
                    backgroundColor:
                    Theme.of(context).colorScheme.alertBoxBackGroundColor,
                    title: Text(AppLocalizations.of(context)!.confirmDelete),
                    content: Text(AppLocalizations.of(context)!.areyousure),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // Confirm deletion
                        },
                        child: Text(AppLocalizations.of(context)!.delete),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // Cancel deletion
                        },
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                    ],
                  );
                },
              );
              return result; // Return the result of the dialog
            }
            else if (direction == DismissDirection.startToEnd && context.read<PermissionsBloc>().isEditLeads == true) {
              router
                ..push(
                  '/createeditleads',
                  extra: {'isCreate': false, "leadModel": lead},
                );

              return false; // Prevent dismiss
            }

            return false;
          },
          dismissWidget: InkWell(
            highlightColor: Colors.transparent, // No highlight on tap
            splashColor: Colors.transparent,
            onTap: () {

              print("fvghjnkml,");
              router.push('/leaddetail', extra: {

                "id": lead.id,

              });


            },
            child: Container(
              decoration: BoxDecoration(
                  boxShadow: [
                    isLightTheme
                        ? MyThemes.lightThemeShadow
                        : MyThemes.darkThemeShadow,
                  ],
                  color: Theme.of(context).colorScheme.containerDark,
                  borderRadius: BorderRadius.circular(12)),
              width: double.infinity,
              // height: 175.h,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Divider(color: colors.darkColor),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: "# ${lead.id}",
                          size: 14.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w700,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                      ],
                    ),

                    SizedBox(height: 10.h,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20.r,
                          child: CustomText(text: getInitials(lead.firstName,lead.lastName), color: Theme.of(context).colorScheme.textClrChange,
                            fontWeight: FontWeight.w700,),
                        ),
                        SizedBox(width: 5.w,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: lead.firstName,
                              size: 18.sp,
                              color: Theme.of(context).colorScheme.textClrChange,
                              fontWeight: FontWeight.w700,
                              softwrap: true,
                              // maxLines: 1,
                              // overflow: TextOverflow.ellipsis,
                            ), CustomText(
                              text: "${lead.jobTitle} @ ${lead.company}",
                              size: 14.sp,
                              color: Theme.of(context).colorScheme.textClrChange,
                              fontWeight: FontWeight.w400,
                              softwrap: true,
                              // maxLines: 1,
                              // overflow: TextOverflow.ellipsis,
                            ),

                          ],
                        ),


                      ],
                    ),
                    SizedBox(height: 10.h,),
                    Row(
                      children: [
                        Icon(Icons.email_outlined,color: AppColors.orangeColor,),
                        SizedBox(width: 5.w,),
                        CustomText(
                          text: lead.email,
                          size: 14.sp,
                          color:AppColors.orangeColor,
                          fontWeight: FontWeight.w500,
                          softwrap: true,
                          // maxLines: 1,
                          // overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h,),
                    lead.isConverted == true?  CustomText(
                      text: "Converted to Client At:${lead.updatedAt}",
                      size: 14.sp,
                      color:AppColors.greyColor,
                      fontWeight: FontWeight.w500,
                      softwrap: true,
                      // maxLines: 1,
                      // overflow: TextOverflow.ellipsis,
                    ):SizedBox.shrink(),

                  ],
                ),
              ),
            ),
          ),
          onDismissed: (DismissDirection direction) {
            if (direction == DismissDirection.endToStart&&
                context.read<PermissionsBloc>().isDeleteLeads== true) {
              setState(() {
                leadList.removeAt(index);
                onDeleteTask(lead.id!);
              });
            } else if (direction == DismissDirection.startToEnd) {}
          },
        ));
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


  Widget _details(
      {required String label, required String title, }) {
    return SizedBox(
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 18.w,vertical: 5.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: label,
              color: Theme
                  .of(context)
                  .colorScheme
                  .textClrChange,
              fontWeight: FontWeight.w400,
              size: 12.sp,

            ),
            CustomText(
              text: title,
              color: Theme
                  .of(context)
                  .colorScheme
                  .textClrChange,

              size: 14.sp,
              fontWeight: FontWeight.w600,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,

            ),
          ],
        ),
      ),
    );
  }
  String getFlagEmoji(String countryCode) {
    return countryCode.toUpperCase().codeUnits.map((char) {
      return String.fromCharCode(char + 127397);
    }).join();
  }

}