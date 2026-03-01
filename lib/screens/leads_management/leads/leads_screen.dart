import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../src/generated/i18n/app_localizations.dart';

import '../../../bloc/leads/leads_bloc.dart';
import '../../../bloc/leads/leads_event.dart';
import '../../../bloc/leads/leads_state.dart';
import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/permissions/permissions_event.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/app_images.dart';
import '../../../config/internet_connectivity.dart';
import '../../../data/model/leads/leads_model.dart';
import '../../../data/repositories/lead/lead_repo.dart';
import '../../../utils/widgets/back_arrow.dart';
import '../../../utils/widgets/custom_dimissible.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/no_data.dart';
import '../../../utils/widgets/no_internet_screen.dart';
import '../../../utils/widgets/no_permission_screen.dart';
import '../../../utils/widgets/notes_shimmer_widget.dart';
import '../../../utils/widgets/search_pop_up.dart';
import '../../../utils/widgets/toast_widget.dart';

import '../../widgets/search_field.dart';
import '../../widgets/side_bar.dart';
import '../../widgets/speech_to_text.dart';
import '../../../routes/routes.dart';
class LeadScreen extends StatefulWidget {
  const LeadScreen({super.key});

  @override
  State<LeadScreen> createState() => _LeadScreenState();
}

class _LeadScreenState extends State<LeadScreen> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late SpeechToTextHelper speechHelper;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;

  TextEditingController searchController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);

  String searchWord = "";
  bool isLoading = false;
  bool isLoadingMore = false;
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
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          context.read<LeadBloc>().add(SearchLead(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    super.initState();
    BlocProvider.of<LeadBloc>(context).add(LeadLists());
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
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

  void _onDeleteLead(int source) {
    context.read<LeadBloc>().add(DeleteLead(source));
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
        : Scaffold(
            backgroundColor: Theme.of(context).colorScheme.backGroundColor,
            body: SideBar(
              context: context,
              controller: sideBarController,
              underWidget: Column(children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: BackArrow(
                    iscreatePermission:
                        context.read<PermissionsBloc>().isCreateLeads,
                    iSBackArrow: true,
                    title: AppLocalizations.of(context)!.leads,
                    isAdd: context.read<PermissionsBloc>().isCreateLeads,
                    onPress: () {
                      LeadModel model = LeadModel.empty();

                      router.push(
                        '/createeditleads',
                        extra: {'isCreate': true, "leadModel": model},
                      );
                    },
                  ),
                ),
                SizedBox(height: 20.h),
                CustomSearchField(
                  isLightTheme: isLightTheme,
                  controller: searchController,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (searchController.text.isNotEmpty)
                        SizedBox(
                          width: 20.w,
                          // color: AppColors.red,
                          child: IconButton(
                            highlightColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.clear,
                              size: 20.sp,
                              color:
                                  Theme.of(context).colorScheme.textFieldColor,
                            ),
                            onPressed: () {
                              // Clear the search field
                              setState(() {
                                searchController.clear();
                              });
                              // Optionally trigger the search event with an empty string
                              context
                                  .read<LeadBloc>()
                                  .add(SearchLead(""));
                            },
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          !speechHelper.isListening ? Icons.mic_off : Icons.mic,
                          size: 20.sp,
                          color: Theme.of(context).colorScheme.textFieldColor,
                        ),
                        onPressed: () {
                          if (speechHelper.isListening) {
                            speechHelper.stopListening();
                          } else {
                            speechHelper.startListening(
                                context, searchController, SearchPopUp());
                          }
                        },
                      ),
                    ],
                  ),
                  onChanged: (value) {
                    searchWord = value;
                    context.read<LeadBloc>().add(SearchLead(value));
                  },
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: RefreshIndicator(
                      color: AppColors.primary, // Spinner color
                      backgroundColor:
                          Theme.of(context).colorScheme.backGroundColor,
                      onRefresh: _onRefresh,
                      child: BlocConsumer<LeadBloc, LeadState>(
                          listener: (context, state) {
                        if (state is LeadSuccess) {
                          isLoadingMore = false;
                          setState(() {});
                        }
                      }, builder: (context, state) {
                        print("yuhjikm $state");
                        if (state is LeadSuccess) {
                          return Container(
                            child: context
                                        .read<PermissionsBloc>()
                                        .isManageLeads ==
                                    true
                                ? state.Lead.isNotEmpty
                                    ? ListView.builder(
                                        padding: EdgeInsets.only(bottom: 50.h),
                                        // shrinkWrap: true,
                                        itemCount: state.isLoadingMore
                                            ? state.Lead
                                                .length // No extra item if all data is loaded
                                            : state.Lead.length + 1,
                                        itemBuilder: (context, index) {
                                          if (index < state.Lead.length) {
                                            return _leadsCard(
                                                isLightTheme,
                                                state.Lead[index],
                                                state.Lead,
                                                index);
                                          } else {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 0),
                                              child: Center(
                                                child: isLoadingMore
                                                    ? const Text('')
                                                    : const SpinKitFadingCircle(
                                                        color:
                                                            AppColors.primary,
                                                        size: 40.0,
                                                      ),
                                              ),
                                            );
                                          }
                                        },
                                      )
                                    : NoData(
                                        isImage: true,
                                      )
                                : NoPermission(),
                          );
                        }
                        if (state is LeadError) {
                          flutterToastCustom(
                              msg: state.errorMessage,
                              color: AppColors.primary);
                        }
                        if (state is LeadEditError) {
                          BlocProvider.of<LeadBloc>(context).add(LeadLists());
                          flutterToastCustom(
                              msg: state.errorMessage,
                              color: AppColors.primary);
                        }
                        if (state is LeadCreateError) {
                          BlocProvider.of<LeadBloc>(context).add(LeadLists());
                          flutterToastCustom(
                              msg: state.errorMessage,
                              color: AppColors.primary);
                        }
                        if (state is LeadError) {
                          BlocProvider.of<LeadBloc>(context).add(LeadLists());
                          flutterToastCustom(
                              msg: state.errorMessage,
                              color: AppColors.primary);
                        }
                        if (state is LeadLoading ||state is LeadCreateLoading||state is LeadEditLoading) {
                          return const NotesShimmer();
                        }
                        if (state is LeadEditSuccess) {
                          flutterToastCustom(
                              msg: AppLocalizations.of(context)!
                                  .updatedsuccessfully,
                              color: AppColors.primary);
                          BlocProvider.of<LeadBloc>(context).add(LeadLists());
                        }   if (state is LeadDeleteSuccess) {
                          flutterToastCustom(
                              msg: AppLocalizations.of(context)!
                                  .deletedsuccessfully,
                              color: AppColors.red);
                          BlocProvider.of<LeadBloc>(context).add(LeadLists());
                        }
                        if (state is LeadCreateSuccess) {
                          flutterToastCustom(
                              msg: AppLocalizations.of(context)!
                                  .createdsuccessfully,
                              color: AppColors.primary);
                          Navigator.pop(context);
                          BlocProvider.of<LeadBloc>(context).add(LeadLists());
                        }
                        return SizedBox();
                      })),
                ),
              ]),
            ));
  }

  Widget _leadsCard(isLightTheme, lead, leadList, index) {
    String getInitials(String firstName, String lastName) {
      String first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
      String last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
      return '$first$last';
    }
    print("uhjkm ${lead.leadStageColor}");
    final String stageTitle = lead.leadStageColor ?? "";
    final matchedColor = colorList.firstWhere(
          (item) => item['title'].toString().toLowerCase() == stageTitle.toLowerCase(),
      orElse: () => {"color": AppColors.primary},
    );
    final Color leadStageColor = matchedColor['color'];

    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
        child: DismissibleCard(
          title: lead.id.toString(),
          direction: context.read<PermissionsBloc>().isDeleteLeads == true &&
                  context.read<PermissionsBloc>().isEditLeads == true
              ? DismissDirection.horizontal // Allow both directions
              : context.read<PermissionsBloc>().isDeleteLeads == true
                  ? DismissDirection.endToStart // Allow delete
                  : context.read<PermissionsBloc>().isEditLeads == true
                      ? DismissDirection.startToEnd // Allow edit
                      : DismissDirection.none,
          confirmDismiss: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart &&
                context.read<PermissionsBloc>().isDeleteLeads == true) {
              // Right to left swipe (Delete action)
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
                      leadList.removeAt(index);

                    });
                    _onDeleteLead(lead.id!);
                  });
                  // Return false to prevent the dismissible from animating
                  return false;
                }

                return false; // Always return false since we handle deletion manually
              } catch (e) {
                print("Error in dialog: $e");
                return false;
              }// Return the result of the dialog
            } else if (direction == DismissDirection.startToEnd &&
                context.read<PermissionsBloc>().isEditLeads == true) {
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
                        if (lead.isConverted == false)
                          InkWell(
                            onTap: () async {
                              Map<String, dynamic> result =
                                  await LeadsRepo().convertLeadToClient(
                                id: lead.id,
                                token: true,
                              );

                              flutterToastCustom(
                                  msg: result['message'],
                                  color: AppColors.primary);
                              BlocProvider.of<LeadBloc>(context)
                                  .add(LeadLists());
                            },
                            child: Tooltip(
                                message: "Convert Lead to Client",
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(10),
                                  // border: Border.all(color: Colors.blueAccent, width: 1),
                                ),
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                waitDuration: Duration(milliseconds: 300),
                                showDuration: Duration(seconds: 2),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                child: Container(
                                  // color: Colors.red,
                                  child: Image.asset(AppImages.convertImage,
                                      height: 20.h, width: 20.w),
                                )),
                          ),
                      ],
                    ),

                    SizedBox(
                      height: 10.h,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 20.r,
                          child: CustomText(
                            text: getInitials(lead.firstName, lead.lastName),
                            color: Theme.of(context).colorScheme.textClrChange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          width: 5.w,
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 180.w), // Max width cap
                          child: IntrinsicWidth(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              height: 25.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: leadStageColor,
                              ),
                              child: Center(
                                child: CustomText(
                                  text: lead.leadStage,
                                  color: AppColors.whiteColor,
                                  size: 14.sp,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        )


                      ],
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "${lead.firstName} ${lead.lastName}",
                          size: 18.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w700,
                          softwrap: true,
                          // maxLines: 1,
                          // overflow: TextOverflow.ellipsis,
                        ),
                        CustomText(
                          text: "@ ${lead.company}",
                          size: 14.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w400,
                          softwrap: true,
                          // maxLines: 1,
                          // overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          color: AppColors.orangeColor,
                        ),
                        SizedBox(
                          width: 5.w,
                        ),
                        CustomText(
                          text: lead.email,
                          size: 14.sp,
                          color: AppColors.orangeColor,
                          fontWeight: FontWeight.w500,
                          softwrap: true,
                          // maxLines: 1,
                          // overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.call,
                          color: AppColors.yellow,
                        ),
                        SizedBox(
                          width: 5.w,
                        ),
                        CustomText(
                          text: lead.phone,
                          size: 14.sp,
                          color: AppColors.yellow,
                          fontWeight: FontWeight.w500,
                          softwrap: true,
                          // maxLines: 1,
                          // overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    ([lead.linkedin, lead.website, lead.instagram, lead.pinterest]
                        .any((link) => link != null && link.trim().isNotEmpty))
                        ? SizedBox(height: 20.h)
                        : SizedBox.shrink(),

                    buildSocialIcons(lead),
                    SizedBox(
                      height: 5.h,
                    ),
                    lead.isConverted == true
                        ? CustomText(
                            text: "Converted to Client At:${lead.updatedAt}",
                            size: 14.sp,
                            color: AppColors.greyColor,
                            fontWeight: FontWeight.w500,
                            softwrap: true,
                            // maxLines: 1,
                            // overflow: TextOverflow.ellipsis,
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
          onDismissed: (DismissDirection direction) {
            if (direction == DismissDirection.endToStart &&
                context.read<PermissionsBloc>().isDeleteLeads == true) {
              WidgetsBinding.instance.addPostFrameCallback((_) {    setState(() {
                leadList.removeAt(index);
              });
              _onDeleteLead(lead.id!);

              });
            } else if (direction == DismissDirection.startToEnd) {}
          },
        ));
  }
  Widget buildSocialIcons(LeadModel lead) {
    bool hasNoSocialLinks = [lead.linkedin, lead.website, lead.instagram, lead.pinterest]
        .every((link) => link == null || link.trim().isEmpty);

    if (hasNoSocialLinks) return SizedBox.shrink();

    return Container(
      // width: 200.w,
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (lead.linkedin != null && lead.linkedin!.trim().isNotEmpty)
            _socialIcon("assets/images/png/linkedin.png", lead.linkedin!),
          if (lead.website != null && lead.website!.trim().isNotEmpty)
            _socialIcon("assets/images/png/website.png", lead.website!),
          if (lead.instagram != null && lead.instagram!.trim().isNotEmpty)
            _socialIcon("assets/images/png/instagram.png", lead.instagram!),
          if (lead.pinterest != null && lead.pinterest!.trim().isNotEmpty)
            _socialIcon("assets/images/png/pinterest.png", lead.pinterest!),
        ],
      ),
    );
  }

  Widget _socialIcon(String assetPath, String urlStr) {
    return InkWell(
      onTap: () async {
        final url = Uri.parse(urlStr);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          print('Could not launch $url');
        }
      },
      child: Padding(
        padding:  EdgeInsets.only(right: 18.w),
        child: CircleAvatar(
          backgroundImage: AssetImage(assetPath),
          radius: 10.r,
        ),
      ),
    );
  }

}
