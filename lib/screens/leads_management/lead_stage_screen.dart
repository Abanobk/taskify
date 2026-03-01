import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/leads_stage/lead_stage_bloc.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/model/leads/lead_stage.dart';
import 'package:taskify/screens/status/widgets/color_fiield.dart';
import 'package:taskify/screens/widgets/custom_cancel_create_button.dart';
import 'package:taskify/screens/widgets/custom_textfields/custom_textfield.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import 'package:taskify/screens/widgets/search_field.dart';
import 'package:taskify/screens/widgets/side_bar.dart';
import 'package:taskify/screens/widgets/speech_to_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../bloc/leads_stage/lead_stage_event.dart';
import '../../bloc/leads_stage/lead_stage_state.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/permissions/permissions_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../config/constants.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/back_arrow.dart';
import '../../utils/widgets/custom_dimissible.dart';
import '../../utils/widgets/custom_text.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/no_permission_screen.dart';
import '../../utils/widgets/notes_shimmer_widget.dart';
import '../../utils/widgets/search_pop_up.dart';
import '../../utils/widgets/shake_widget.dart';
import '../../utils/widgets/toast_widget.dart';
import '../../src/generated/i18n/app_localizations.dart';

class LeadStageScreen extends StatefulWidget {
  const LeadStageScreen({super.key});

  @override
  State<LeadStageScreen> createState() => _LeadStageScreenState();
}

class _LeadStageScreenState extends State<LeadStageScreen> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  String searchWord = "";
  bool? isLoading = true;
  bool isLoadingMore = false;
  String? selectedColorName;
  final Connectivity _connectivity = Connectivity();
  TextEditingController searchController = TextEditingController();
  late SpeechToTextHelper speechHelper;
  TextEditingController titleController = TextEditingController();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final GlobalKey<FormState> _createEditPriorityKey = GlobalKey<FormState>();
  final SlidableBarController sideBarController =
  SlidableBarController(initialStatus: false);

  @override
  void initState() {
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results != "ConnectivityResult.none") {
        setState(() {
          _connectionStatus = results;
        });
        _initializeApp();
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results != "ConnectivityResult.none") {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
          _initializeApp();
        });
      }
    });
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          // context.read<ActivityLogBloc>().add(SearchActivityLog(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    super.initState();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    // also clean up if SpeechToTextHelper uses any resources
    super.dispose();
  }
  void _initializeApp() {
    searchController.addListener(() {
      setState(() {});
    });
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          context.read<LeadStageBloc>().add(SearchLeadStage(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();

    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    BlocProvider.of<LeadStageBloc>(context).add(LeadStageLists());
  }
  void _onEditLeadStage(id, oldTitle, oldColor) async {
    final newTitle = titleController.text.isNotEmpty ? titleController.text : oldTitle;
    // final newColor = selectedColorName ?? oldColor;
    final newColor = (selectedColorName ?? oldColor).toLowerCase();

    if (newTitle.isNotEmpty && newColor.isNotEmpty) {
      print("COLOR TO NEW $newColor");
      context.read<LeadStageBloc>().add(UpdateLeadStage(
        id: id,
        title: newTitle,
        color: newColor,
      ));
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  void _onCreateLeadStage(title, color) {
    print("rtfuyhuyio$color");
    if (titleController.text.isNotEmpty) {
      context.read<LeadStageBloc>().add(CreateLeadStage(
        title: titleController.text.toString(),
        color: selectedColorName?.toLowerCase() ?? "",
      ));
      final leadStageBloc = BlocProvider.of<LeadStageBloc>(context);
      leadStageBloc.stream.listen((state) {
        if (state is LeadStageSuccess) {
          if (mounted) {

            flutterToastCustom(
                msg: AppLocalizations.of(context)!.createdsuccessfully,
                color: AppColors.primary);
          }
        }
        if (state is LeadStageCreateError) {
          flutterToastCustom(msg: state.errorMessage);
        }
      });
      leadStageBloc.add(LeadStageLists());
    } else {
      flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleasefilltherequiredfield);
    }
  }


  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    BlocProvider.of<LeadStageBloc>(context).add(LeadStageLists());
    setState(() {
      isLoading = false;
    });
  }
  void onDeleteLeadStage(int stage) {
    context.read<LeadStageBloc>().add(DeleteLeadStage(stage));
  }
  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : Scaffold(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .backGroundColor,
        body: SideBar(
          context: context,
          controller: sideBarController,
          underWidget: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                _appBar(isLightTheme),
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
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .textFieldColor,
                            ),
                            onPressed: () {
                              // Clear the search field
                              setState(() {
                                searchController.clear();
                              });
                              // Optionally trigger the search event with an empty string
                              context
                                  .read<LeadStageBloc>()
                                  .add(SearchLeadStage(""));
                            },
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          !speechHelper.isListening
                              ? Icons.mic_off
                              : Icons.mic,
                          size: 20.sp,
                          color:
                          Theme
                              .of(context)
                              .colorScheme
                              .textFieldColor,
                        ),
                        onPressed: () {
                          if (speechHelper.isListening) {
                            speechHelper.stopListening();
                          } else {
                            speechHelper.startListening(context,
                                searchController, SearchPopUp());
                          }
                        },
                      ),
                    ],
                  ),
                  onChanged: (value) {
                    searchWord = value;
                    context
                        .read<LeadStageBloc>()
                        .add(SearchLeadStage(value));
                  },
                ),
                SizedBox(height: 20.h),
                _body(isLightTheme)
              ],
            ),
          ),
        ));
  }

  Widget _appBar(isLightTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: BackArrow(
        iSBackArrow: true,
        iscreatePermission: true,
        title: AppLocalizations.of(context)!.leadstages,
        isAdd: true,
        onPress: () {
          _createEditPriority(isLightTheme: isLightTheme, isCreate: true);

        },
      ),
    );
  }

  Widget _body(isLightTheme) {
    return Expanded(
        child: RefreshIndicator(
            color: AppColors.primary, // Spinner color
            backgroundColor: Theme
                .of(context)
                .colorScheme
                .backGroundColor,
            onRefresh: _onRefresh,
            child: BlocConsumer<LeadStageBloc, LeadStageState>(
                listener: (context, state) {
                  if (state is LeadStageSuccess) {
                    isLoadingMore = false;
                    setState(() {});
                  }
                },
                builder: (context, state) {
                  print("sefzgzghz $state");
                  if (state is LeadStageLoading) {
                    return const NotesShimmer();
                  }
                  if (state is LeadStageEditSuccess) {
                    flutterToastCustom(
                        msg: AppLocalizations.of(context)!.updatedsuccessfully,
                        color: AppColors.primary);
                    Navigator.pop(context);
                    BlocProvider.of<LeadStageBloc>(context).add(LeadStageLists());

                  }
                  if (state is LeadStageCreateSuccess) {
                    flutterToastCustom(
                        msg: AppLocalizations.of(context)!.createdsuccessfully,
                        color: AppColors.primary);
                    Navigator.pop(context);
                    BlocProvider.of<LeadStageBloc>(context).add(LeadStageLists());

                  }
                  if (state is LeadStageSuccess) {
                    return NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        if (!state.isLoadingMore &&
                            scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent &&
                            isLoadingMore == false) {
                          isLoadingMore = true;
                          setState(() {});
                          context
                              .read<LeadStageBloc>()
                              .add(LeadStageLoadMore(searchWord));
                        }
                        return false;
                      },
                      child: state.LeadStage.isNotEmpty
                          ? _stageLists(
                        isLightTheme,
                        state.isLoadingMore,
                        state.LeadStage,
                      )
                          : NoData(
                        isImage: true,
                      ),
                    );
                  }
                  if(state is LeadStageError){
                    flutterToastCustom(
                        msg: state.errorMessage,
                        color: AppColors.primary);
                    BlocProvider.of<LeadStageBloc>(context).add(LeadStageLists());

                  }
                  if(state is LeadStageEditError){
                    BlocProvider.of<LeadStageBloc>(context).add(LeadStageLists());
                    flutterToastCustom(
                        msg: state.errorMessage,
                        color: AppColors.primary);
                  }
                  if(state is LeadStageCreateError){
                    BlocProvider.of<LeadStageBloc>(context).add(LeadStageLists());
                    flutterToastCustom(
                        msg: state.errorMessage,
                        color: AppColors.primary);
                  }
                  if(state is LeadStageDeleteSuccess){
                    BlocProvider.of<LeadStageBloc>(context).add(LeadStageLists());
                    flutterToastCustom(
                        msg: AppLocalizations.of(context)!.deletedsuccessfully,
                        color: AppColors.primary);
                  }
                  return SizedBox.shrink();
                })));
  }
  Widget _stageLists(isLightTheme, hasReachedMax, priorityList) {
    return context
        .read<PermissionsBloc>()
        .isManageLeads ==
        true
        ? priorityList.isNotEmpty
        ?ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: hasReachedMax
          ? priorityList.length // No extra item if all data is loaded
          : priorityList.length + 1,
      itemBuilder: (context, index) {
        if (index < priorityList.length) {
          final status = priorityList[index];
          String? dateCreated;
          DateTime createdDate = parseDateStringFromApi(status.createdAt!);
          dateCreated = dateFormatConfirmed(createdDate, context);
          return priorityList.isEmpty
              ? NoData(
            isImage: true,
          )
              : _priorityListContainer(
              status, isLightTheme, priorityList, index, dateCreated, status.color);
        } else {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Center(
              child: hasReachedMax
                  ? const Text('')
                  : const SpinKitFadingCircle(
                color: AppColors.primary,
                size: 40.0,
              ),
            ),
          );
        }
      },
    ): NoData(
      isImage: true,
    )
        : NoPermission();
  }
  Widget _priorityListContainer(LeadStageModel lead, bool isLightTheme,
      List<LeadStageModel> leadModel, int index, dateCreated, color) {
    return index == 0
        ? ShakeWidget(
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
          child: DismissibleCard(
            title: lead.id!.toString(),
            direction: context.read<PermissionsBloc>().isDeleteLeads == true &&
                context.read<PermissionsBloc>().isEditLeads == true
                ? DismissDirection.horizontal // Allow both directions
                : context.read<PermissionsBloc>().isDeleteLeads  == true
                ? DismissDirection.endToStart // Allow delete
                : context.read<PermissionsBloc>().isEditLeads  == true
                ? DismissDirection.startToEnd // Allow edit
                : DismissDirection.none,
            confirmDismiss: (DismissDirection direction) async {
              if (direction == DismissDirection.endToStart) {
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
                        leadModel.removeAt(index);

                      });
                      onDeleteLeadStage(lead.id!);
                    });
                    // Return false to prevent the dismissible from animating
                    return false;
                  }

                  return false; // Always return false since we handle deletion manually
                } catch (e) {
                  print("Error in dialog: $e");
                  return false;
                }// Return the result of the dialog
              } else if (direction == DismissDirection.startToEnd) {
                _createEditPriority(
                    isLightTheme: isLightTheme,
                    isCreate: false,
                    id: lead.id,
                    title: lead.name,
                    color: lead.color);
                // Perform the edit action if needed
                return false; // Prevent dismiss
              }
              // flutterToastCustom(
              //     msg: AppLocalizations.of(context)!.isDemooperation);
              return false; // Default case
            },
            dismissWidget: _priorityCard(
              isLightTheme,
              lead,
              color,
            ),
            onDismissed: (DismissDirection direction) {
              // This will not be called if `confirmDismiss` returned `false`
              if (direction == DismissDirection.endToStart
                  && context.read<PermissionsBloc>().isDeleteLeads == true) {
                WidgetsBinding.instance.addPostFrameCallback((_) {   setState(() {
                  leadModel.removeAt(index);
                });
                onDeleteLeadStage(lead.id!);

                });
              }
            },
          )),
    )
        : Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
        child: DismissibleCard(
          title: lead.id!.toString(),
          confirmDismiss: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart&& context.read<PermissionsBloc>().isDeleteLeads == true) {
              // Right to left swipe (Delete action)
              final result = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10.r), // Set the desired radius here
                    ),
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .alertBoxBackGroundColor,
                    title:
                    Text(AppLocalizations.of(context)!.confirmDelete),
                    content: Text(AppLocalizations.of(context)!.areyousure),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop(true); // Confirm deletion
                        },
                        child: Text(AppLocalizations.of(context)!.delete),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop(false); // Cancel deletion
                        },
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                    ],
                  );
                },
              );
              return result; // Return the result of the dialog
            } else if (direction == DismissDirection.startToEnd&& context.read<PermissionsBloc>().isEditLeads == true) {
              _createEditPriority(
                  isLightTheme: isLightTheme,
                  isCreate: false,
                  id: lead.id,
                  title: lead.name,
                  color: lead.color);
              return false; // Prevent dismiss
            }
            return false; // Default case
          },
          dismissWidget: _priorityCard(
            isLightTheme,
            lead,
            color,
          ),
          onDismissed: (DismissDirection direction) {
            // This will not be called if `confirmDismiss` returned `false`
            if (direction == DismissDirection.endToStart&& context.read<PermissionsBloc>().isDeleteLeads == true) {
              setState(() {
                leadModel.removeAt(index);
                onDeleteLeadStage(lead.id!);
              });
            }
          },
        ));
  }
  Widget _priorityCard(
      isLightTheme,
      status,
      color,
      ) {
    Color? colorOfStatus ;
    switch (color) {
      case "primary":
        colorOfStatus = AppColors.primary;
        break;
      case "secondary":
        colorOfStatus = Color(0xFF8592a3);
        break;
      case "success":
        colorOfStatus = Colors.green;
        break;
      case "danger":
        colorOfStatus = Colors.red;
        break;
      case "warning":
        colorOfStatus = Color(0xFFfaab01);
        break;
      case "info":
        colorOfStatus = Color(0xFF36c3ec);
        break;
      case "dark":
        colorOfStatus = Colors.black;
        break;
      default:
        colorOfStatus = Colors.grey; // Fallback color
    }
    String  dateCreated = formatDateFromApi(status.createdAt!, context);
    String  dateUpdated = formatDateFromApi(status.updatedAt!, context);

    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
          ],
          color: Theme.of(context).colorScheme.containerDark,
          borderRadius: BorderRadius.circular(12)),
      // height: 100.h,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.h),
            child: SizedBox(
              width: double.infinity,
              // color: Colors.red,
              // height: 70.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "#${status.id.toString()}",
                    size: 14.sp,
                    color:
                    Theme.of(context).colorScheme.textClrChange,
                    fontWeight: FontWeight.w700,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5.h,),
                  CustomText(
                    text: status.name!,
                    size: 16.sp,
                    color: Theme.of(context).colorScheme.textClrChange,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(
                    height: 18.h,
                  ),
                  Row(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: 25.h,
                        // width: 110.w, //
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: colorOfStatus), // Set the height of the dropdown
                        child: Center(
                          child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: CustomText(
                                text: status.name!,
                                color: AppColors.whiteColor,
                                size: 14.sp,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      ),


                    ],
                  ),
                  SizedBox(height: 5.h,),

                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color:  Theme
                    .of(context)
                    .colorScheme
                    .backGroundColor,
              ),
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 18.w,vertical: 5.h),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CustomText(
                          text:"📅 ${ AppLocalizations.of(context)!.createdat} : ",
                          size: 13.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w600,
                        ),  CustomText(
                          text:dateCreated,
                          size: 12.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h,),
                    Row(
                      children: [
                        CustomText(
                          text:"📅 ${ AppLocalizations.of(context)!.updatedAt} : ",
                          size: 13.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w600,
                        ),  CustomText(
                          text: dateUpdated,
                          size: 12.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],

      ),
    );
  }
  Future<void> _createEditPriority(
      {isLightTheme, isCreate, int? id, title, color}) {
    if (isCreate) {
      titleController.text = '';
    } else {
      titleController.text = title;
      selectedColorName = color;
    }
    return showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(// This ensures the modal content updates
              builder: (context, setState) {
                void _handleAccessSelected(String colorName) {
                  setState(() {
                    selectedColorName = colorName;
                    print("tbhnjmk $selectedColorName");
                    // Debugging
                  });
                }

                return Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: const [],
                      borderRadius: BorderRadius.circular(25),
                      color: Theme.of(context).colorScheme.backGroundColor,
                    ),
                    height: 340.h,
                    child: Center(
                      child: Form(
                        key: _createEditPriorityKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                              child: BackArrow(
                                isBottomSheet: true,
                                isAdd: false,
                                title: isCreate == false
                                    ? AppLocalizations.of(context)!.editstatus
                                    : AppLocalizations.of(context)!.createstatus,
                                iSBackArrow: false,
                                iscreatePermission:  false,
                                onPress: (){
                                  print("dgfkgv ");
                                  _createEditPriority(isLightTheme: isLightTheme, isCreate: true);

                                },
                              ),
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            CustomTextFields(
                              title: AppLocalizations.of(context)!.title,
                              hinttext:
                              AppLocalizations.of(context)!.pleaseentertitle,
                              controller: titleController,
                              onSaved: (value) {},
                              onFieldSubmitted: (value) {},
                              isLightTheme: isLightTheme,
                              isRequired: true,
                            ),
                            SizedBox(
                              height: 15.h,
                            ),
                            ColorField(
                              isRequired: true,
                              isCreate: isCreate ?? false,
                              name: selectedColorName ?? "",
                              onSelected: _handleAccessSelected,
                            ),
                            SizedBox(
                              height: 15.h,
                            ),
                            SizedBox(
                              height: 25.h,
                            ),
                            BlocBuilder<LeadStageBloc, LeadStageState>(
                                builder: (context, state) {
                                  if (state is LeadStageEditSuccessLoading) {
                                    return CreateCancelButtom(
                                      isLoading: true,
                                      isCreate: isCreate,
                                      onpressCreate: isCreate == true
                                          ? () async {}
                                          : () {
                                        _onEditLeadStage(id, title, color);
                                        // context.read<TodosBloc>().add(const TodosList());
                                        // Navigator.pop(context);
                                      },
                                      onpressCancel: () {
                                        Navigator.pop(context);
                                      },
                                    );
                                  }
                                  if (state is LeadStageCreateSuccessLoading) {
                                    return CreateCancelButtom(
                                      isLoading: true,
                                      isCreate: isCreate,
                                      onpressCreate: isCreate == true
                                          ? () async {
                                        _onCreateLeadStage(title, color);
                                      }
                                          : () {
                                        _onEditLeadStage(id, title, color);
                                        // context.read<TodosBloc>().add(const TodosList());
                                        // Navigator.pop(context);
                                      },
                                      onpressCancel: () {
                                        Navigator.pop(context);
                                      },
                                    );
                                  }
                                  return CreateCancelButtom(
                                    isCreate: isCreate,
                                    onpressCreate: isCreate == true
                                        ? () async {
                                      _onCreateLeadStage(title, color);
                                    }
                                        : () {
                                      _onEditLeadStage(id, title, color);
                                      // context.read<TodosBloc>().add(const TodosList());
                                      // Navigator.pop(context);
                                    },
                                    onpressCancel: () {
                                      Navigator.pop(context);
                                    },
                                  );
                                })
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
        });
  }
}