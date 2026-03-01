import 'dart:async';
import '../../../src/generated/i18n/app_localizations.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../bloc/leads_source/lead_source_bloc.dart';
import '../../bloc/leads_source/lead_source_event.dart';
import '../../bloc/leads_source/lead_source_state.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/permissions/permissions_event.dart';
import '../../utils/widgets/no_data.dart';
import '../../utils/widgets/no_permission_screen.dart';
import '../../utils/widgets/notes_shimmer_widget.dart';
import '../../utils/widgets/toast_widget.dart';
import '../widgets/custom_textfields/custom_textfield.dart';

import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/back_arrow.dart';
import '../../utils/widgets/custom_dimissible.dart';
import '../../utils/widgets/custom_text.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/no_internet_screen.dart';
import '../../utils/widgets/search_pop_up.dart';
import '../widgets/custom_cancel_create_button.dart';
import '../widgets/search_field.dart';
import '../widgets/side_bar.dart';
import '../widgets/speech_to_text.dart';

class LeadSourceScreen extends StatefulWidget {
  const LeadSourceScreen({super.key});

  @override
  State<LeadSourceScreen> createState() => _LeadSourceScreenState();
}

class _LeadSourceScreenState extends State<LeadSourceScreen> {
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
          context.read<LeadSourceBloc>().add(SearchLeadSource(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    super.initState();
    BlocProvider.of<LeadSourceBloc>(context).add(LeadSourceLists());
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
  }
  void _onEditLeadSource(id, title ) async {
    if (titleController.text.isNotEmpty ) {
      context.read<LeadSourceBloc>().add(UpdateLeadSource(
        id: id, title: titleController.text.isNotEmpty?titleController.text :title));
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
    // Navigator.pop(context);
  }
  void _onCreateLeadSource() {
    if (titleController.text.isNotEmpty) {
      context.read<LeadSourceBloc>().add(CreateLeadSource(
        title: titleController.text.toString(),
      ));
    } else {
      flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleasefilltherequiredfield);
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    BlocProvider.of<LeadSourceBloc>(context).add(LeadSourceLists());
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());

    setState(() {
      isLoading = false;
    });
  }
  void _onDeleteLeadSource(int source) {
    context.read<LeadSourceBloc>().add(DeleteLeadSource(source));
  }
  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
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
                    iscreatePermission: context.read<PermissionsBloc>().isCreateLeads,
                    iSBackArrow: true,
                    title: AppLocalizations.of(context)!.leadsource,
                    isAdd: context.read<PermissionsBloc>().isCreateLeads,
                    onPress: () {
                      _createEditLeads(
                          isCreate: true,
                          isLightTheme: isLightTheme,
                          leadName: "",id:0);
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
                                  .read<LeadSourceBloc>()
                                  .add(SearchLeadSource(""));
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
                    context.read<LeadSourceBloc>().add(SearchLeadSource(value));
                  },
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: RefreshIndicator(
                      color: AppColors.primary, // Spinner color
                      backgroundColor:
                          Theme.of(context).colorScheme.backGroundColor,
                      onRefresh: _onRefresh,
                      child: BlocConsumer<LeadSourceBloc, LeadSourceState>(
                          listener: (context, state) {
                        if (state is LeadSourceSuccess) {
                          isLoadingMore = false;
                          setState(() {});
                        }
                      }, builder: (context, state) {
                        print("sefzgzghz $state");
                        if (state is LeadSourceSuccess) {
                          return Container(
                              child: context
                                  .read<PermissionsBloc>()
                                  .isManageLeads ==
                                  true
                                  ? state.LeadSource.isNotEmpty
                                  ?Container(
                              child: ListView.builder(
                            padding: EdgeInsets.only(bottom: 0.h),
                            // shrinkWrap: true,
                                itemCount: state.isLoadingMore
                                    ? state.LeadSource.length // No extra item if all data is loaded
                                    : state.LeadSource.length + 1,
                            itemBuilder: (context, index) {
                              if(index <state.LeadSource.length) {
                                return _leadsCard(
                                    isLightTheme, state.LeadSource[index],state.LeadSource,index);
                              }else {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 0),
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
                          )): NoData(
                                isImage: true,
                              )
                                  : NoPermission());
                        }
                        if (state is LeadSourceError) {
                          flutterToastCustom(
                              msg: state.errorMessage,
                              color: AppColors.primary);
                          BlocProvider.of<LeadSourceBloc>(context)
                              .add(LeadSourceLists());
                        }
                        if (state is LeadSourceEditError) {
                          BlocProvider.of<LeadSourceBloc>(context)
                              .add(LeadSourceLists());
                          flutterToastCustom(
                              msg: state.errorMessage,
                              color: AppColors.primary);
                        }
                        if (state is LeadSourceCreateError) {
                          BlocProvider.of<LeadSourceBloc>(context)
                              .add(LeadSourceLists());
                          flutterToastCustom(
                              msg: state.errorMessage,
                              color: AppColors.primary);
                        }if (state is LeadSourceCreateError) {
                          BlocProvider.of<LeadSourceBloc>(context)
                              .add(LeadSourceLists());
                          flutterToastCustom(
                              msg: state.errorMessage,
                              color: AppColors.primary);
                        }
                        if (state is LeadSourceLoading) {
                          return const NotesShimmer();
                        }
                        if (state is LeadSourceEditSuccess) {
                          flutterToastCustom(
                              msg: AppLocalizations.of(context)!
                                  .updatedsuccessfully,
                              color: AppColors.primary);
                          BlocProvider.of<LeadSourceBloc>(context)
                              .add(LeadSourceLists());
                        }   if (state is LeadSourceDeleteSuccess) {
                          flutterToastCustom(
                              msg: AppLocalizations.of(context)!
                                  .deletedsuccessfully,
                              color: AppColors.primary);
                          BlocProvider.of<LeadSourceBloc>(context)
                              .add(LeadSourceLists());
                        }
                        if (state is LeadSourceCreateSuccess) {
                          flutterToastCustom(
                              msg: AppLocalizations.of(context)!
                                  .createdsuccessfully,
                              color: AppColors.primary);
                          Navigator.pop(context);
                          BlocProvider.of<LeadSourceBloc>(context)
                              .add(LeadSourceLists());
                        }
                        return SizedBox();
                      })),
                ),
              ]),
            ));
  }

  Widget _leadsCard(isLightTheme,source,sourceList,index) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
        child: DismissibleCard(
          title: source.id.toString(),
          confirmDismiss: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart&& context.read<PermissionsBloc>().isEditLeads== true) {
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
                      sourceList.removeAt(index);

                    });
                    _onDeleteLeadSource(source.id!);
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
              _createEditLeads(
                  isCreate: false,
                  isLightTheme: isLightTheme,
                  leadName: source.name,
              id:source.id);

              return false; // Prevent dismiss
            }


            return false;
          },
          dismissWidget: InkWell(
            highlightColor: Colors.transparent, // No highlight on tap
            splashColor: Colors.transparent,
            onTap: () {},
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
                    CustomText(
                      text: "# ${source.id}",
                      size: 14.sp,
                      color:AppColors.greyColor,
                      fontWeight: FontWeight.w700,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                    ),
                    CustomText(
                      text:source.name,
                      size: 20.sp,
                      color: Theme.of(context).colorScheme.textClrChange,
                      fontWeight: FontWeight.w700,
                      softwrap: true,
                      // maxLines: 1,
                      // overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          direction: context.read<PermissionsBloc>().isDeleteLeads == true &&
              context.read<PermissionsBloc>().isEditLeads == true
              ? DismissDirection.horizontal // Allow both directions
              : context.read<PermissionsBloc>().isDeleteLeads  == true
              ? DismissDirection.endToStart // Allow delete
              : context.read<PermissionsBloc>().isEditLeads  == true
              ? DismissDirection.startToEnd // Allow edit
              : DismissDirection.none,
          onDismissed: (DismissDirection direction) {
            if (direction == DismissDirection.endToStart &&context.read<PermissionsBloc>().isDeleteLeads == true) {
              WidgetsBinding.instance.addPostFrameCallback((_) {   setState(() {
                sourceList.removeAt(index);
              });
              _onDeleteLeadSource(source.id!);

              });
            } else if (direction == DismissDirection.startToEnd) {

            }
          },
        ));
  }

  Future<void> _createEditLeads({isCreate, isLightTheme, leadName,id}) {
    if (isCreate) {
      titleController.text = '';

      // selectedColor=color;
    } else {
      titleController.text = leadName;
    }
    return showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(// This ensures the modal content updates
              builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  boxShadow: const [],
                  borderRadius: BorderRadius.circular(25),
                  color: Theme.of(context).colorScheme.backGroundColor,
                ),
                height: 250.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: BackArrow(
                        isBottomSheet: true,
                        title: isCreate == false
                            ? AppLocalizations.of(context)!.editlead
                            : AppLocalizations.of(context)!.createlead,
                        iSBackArrow: false,
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    CustomTextFields(
                      title: AppLocalizations.of(context)!.name,
                      hinttext: AppLocalizations.of(context)!.pleaseentertitle,
                      controller: titleController,
                      onSaved: (value) {},
                      onFieldSubmitted: (value) {},
                      isLightTheme: isLightTheme,
                      isRequired: true,
                    ),

                    SizedBox(
                      height: 25.h,
                    ),
                    CreateCancelButtom(
                      isCreate: isCreate,
                      onpressCreate: isCreate == true
                          ? () async {
                              _onCreateLeadSource();
                            }
                          : () {
                              _onEditLeadSource(id, titleController.text);
                              context.read<LeadSourceBloc>().add( LeadSourceLists());
                              Navigator.pop(context);
                            },
                      onpressCancel: () {
                        Navigator.pop(context);
                      },
                    )

                  ],
                ),
              ),
            );
          });
        });
  }
}
