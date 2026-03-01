
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/workspace/workspace_bloc.dart';
import 'package:taskify/bloc/workspace/workspace_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/model/workspace/workspace_model.dart';
import 'package:taskify/screens/notes/widgets/notes_shimmer_widget.dart';
import 'package:taskify/screens/widgets/edit_delete_pop.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/permissions/permissions_event.dart';
import '../../bloc/workspace/workspace_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import 'dart:async';
import '../../config/constants.dart';

import '../../data/localStorage/hive.dart';

import '../../utils/widgets/custom_text.dart';
import 'package:heroicons/heroicons.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/custom_switch.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/toast_widget.dart';
import '../../utils/widgets/search_pop_up.dart';
import '../../utils/widgets/user_client_list_for_grid.dart';
import '../task/Widget/users_field.dart';
import '../widgets/custom_cancel_create_button.dart';

import '../widgets/custom_textfields/custom_textfield.dart';
import '../widgets/custom_toast.dart';
import '../widgets/no_data.dart';
import '../widgets/clients_field.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/search_field.dart';
import '../widgets/side_bar.dart';
import '../widgets/speech_to_text.dart';
import '../widgets/user_client_box.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class WorkspaceScreen extends StatefulWidget {
  final bool? fromNoti;
  const WorkspaceScreen({super.key, this.fromNoti});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController startsController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  String selectedCategory = '';
  bool isLoadingMore = false;
  DateTime selectedDateStarts = DateTime.now();

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;

  String _searchQuery = '';

  void listenForPermissions() async {
    final status = await Permission.microphone.status;
    switch (status) {
      case PermissionStatus.denied:
        requestForPermission();
        break;
      case PermissionStatus.granted:
        break;
      case PermissionStatus.limited:
        break;
      case PermissionStatus.permanentlyDenied:
        break;
      case PermissionStatus.restricted:
        break;
      case PermissionStatus.provisional: // Handle the provisional case
        break;
    }
  }

  Future<void> requestForPermission() async {
    await Permission.microphone.request();
  }

  final GlobalKey globalKeyAdd = GlobalKey();
  final GlobalKey ipe = GlobalKey();
  final GlobalKey arch = GlobalKey();

  List<String>? usersName;
  int? idOfWorkspace;
  List<int>? selectedusersNameId;
  List<String>? clientsName;
  String? role;
  bool? hasAllDataAccess;
  List<int>? selectedclientsNameId;
  bool? visiblestatus = true;
  bool? visiblestatusPrimary = true;
  int? visiblePartialIs;
  int? visiblePartialIsPrimary;
  bool isSwitchToggled = false; // Track switch interaction
  bool isSwitchToggledprimary = false; // Track switch interaction

  bool shouldDisableEdit = true;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  late SpeechToTextHelper speechHelper;

  FocusNode? titleFocus, descFocus, startsFocus, endFocus = FocusNode();
  final SlidableBarController sideBarController =
  SlidableBarController(initialStatus: false);

  void handleStatusSelectedVisiblestatus(bool status, int id) {

    setState(() {
      visiblestatus = status;
      isSwitchToggled = true;
      if (visiblestatus == true) {
        setState(() {
          visiblePartialIs = 1;
        });
      } else if (visiblestatus == false) {
        setState(() {
          visiblePartialIs = 0;
        });
      }

    });

  }

  void handleStatusSelectedVisiblestatusPrimary(bool status, int id) {

    setState(() {
      visiblestatusPrimary = status;
      isSwitchToggledprimary = true;
      if (visiblestatusPrimary == true) {
        setState(() {
          visiblePartialIsPrimary = 1;
        });
      } else if (visiblestatusPrimary == false) {
        setState(() {
          visiblePartialIsPrimary = 0;
        });
      }

    });
    idOfWorkspace = id;

  }


  void _handleUsersSelected(List<String> category, List<int> catId,
      void Function(void Function()) setState) {
    setState(() {
      usersName = category;
      selectedusersNameId = catId;
    });
  }

  void _handleClientSelected(List<String> category, List<int> catId,
      void Function(void Function()) setState) {
    setState(() {
      clientsName = category;
      selectedclientsNameId = catId;
    });
  }

  void _onCreateWorkspace() {
    if (titleController.text.isNotEmpty && titleController.text != "") {
      final newNote = WorkspaceModel(
        title: titleController.text.toString(),
        primaryWorkspace: visiblePartialIs,
        userIds: selectedusersNameId ?? [],
        clientIds: selectedclientsNameId ?? [],
      );
      context.read<WorkspaceBloc>().add(AddWorkspace(newNote));
      final setting = context.read<WorkspaceBloc>();
      setting.stream.listen((state) {

        if (state is WorkspaceCreateSuccess) {
          if (mounted) {
            // context.read<WorkspaceBloc>().add(const WorkspaceList());
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.createdsuccessfully,
                color: AppColors.primary);
            context.read<WorkspaceBloc>().add(const WorkspaceList());
            Navigator.pop(context);
            // router.push('/workspaces');
            // router.go("/workspace");
          }
        }
        if (state is WorkspaceCreateError) {
          flutterToastCustom(msg: state.errorMessage);
        }
      });

      // _createNotesKey.currentState!.save();
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }
  void _onEditWorkspace(id, title, primary, user, userid, client, clientid) async {
    visiblePartialIs ??= 1;

    if (titleController.text.isNotEmpty && visiblePartialIs != null) {
      final updated = WorkspaceModel(
        id: id,
        title: titleController.text,
        primaryWorkspace: visiblePartialIs ?? primary,
        userIds: selectedusersNameId ?? userid,
        clientIds: selectedclientsNameId ?? clientid,
      );
      if (isSwitchToggled) {
        BlocProvider.of<WorkspaceBloc>(context).add(CreateRemoveWorkspace(
          id: id ?? 0, defaultPrimary: visiblePartialIs!,
        ));
        isSwitchToggled = false; // Reset flag after API call
      }
      context.read<WorkspaceBloc>().add(UpdateWorkspace(updated));

    } else {
      customToasts(
          message:AppLocalizations.of(context)!.pleasefilltherequiredfield,
          backgroundColor: AppColors.red);
    }
  }


  void _onDeleteWorkspace(id) {
    context.read<WorkspaceBloc>().add(WorkspaceRemove(id: id));
    final setting = context.read<WorkspaceBloc>();
    setting.stream.listen((state) {

      if(state is WorkspaceDeleteSuccess) {
        if (mounted) {
          context.read<WorkspaceBloc>().add(const WorkspaceList());

          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      } if (state is WorkspaceError) {
        flutterToastCustom(msg: state.errorMessage);
      }

    });
  }

  bool? isLoading = true;

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    BlocProvider.of<WorkspaceBloc>(context).add(WorkspaceList());
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());

    setState(() {
      isLoading = false;
    });
  }

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
          context
              .read<WorkspaceBloc>()
              .add(SearchWorkspace(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    BlocProvider.of<WorkspaceBloc>(context).add(const WorkspaceList());
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    super.initState();
  }

  void _getRoleAndHasDataAccess() async {
    role = await HiveStorage.getRole();
    hasAllDataAccess = await HiveStorage.getAllDataAccess();
  }


  @override
  Widget build(BuildContext context) {
    context.read<PermissionsBloc>().isManageWorkspace;
    context.read<PermissionsBloc>().iscreateWorkspace;
    context.read<PermissionsBloc>().iseditWorkspace;
    context.read<PermissionsBloc>().isdeleteWorkspace;

    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        body: SideBar(
          context: context,
          controller: sideBarController,
          underWidget: SizedBox(
            // height: 400,
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(
                  height: 20.h,
                ),
                appBar(isLightTheme),
                SizedBox(
                  height: 20.h,
                ),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .textFieldColor,
                            ),
                            onPressed: () {
                              // Clear the search field
                              searchController.clear();
                              // Optionally trigger the search event with an empty string
                              context
                                  .read<WorkspaceBloc>()
                                  .add(WorkspaceList());
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
                          Theme.of(context).colorScheme.textFieldColor,
                        ),
                        onPressed: () {
                          if (speechHelper.isListening) {
                            speechHelper.stopListening();
                          } else {
                            speechHelper.startListening(context, searchController, SearchPopUp());
                          }
                        },
                      ),

                    ],
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    context
                        .read<WorkspaceBloc>()
                        .add(SearchWorkspace(value));
                    setState(() {});
                  },
                ),

                // SizedBox(height: 20.h),
                _body(isLightTheme)
                // TaskListView()
              ],
            ),
          ),
        ));
  }

  Widget _body(isLightTheme) {
    return Expanded(
      child: RefreshIndicator(
          color: AppColors.primary, // Spinner color
          backgroundColor: Theme.of(context).colorScheme.backGroundColor,
          onRefresh: _onRefresh,
          child: workspaceBlocList(isLightTheme)),
    );
  }

  Widget workspaceBlocList(isLightTheme) {
    return AbsorbPointer(
      absorbing: false,
      child: BlocConsumer<WorkspaceBloc, WorkspaceState>(
        listener: (context, state) {
          // Handle side effects based on state changes here
          // if (state is WorkspacePaginated) {}
          if (state is WorkspaceEditSuccess) {
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.updatedsuccessfully,
                color: AppColors.primary);
            context.read<WorkspaceBloc>().add(const WorkspaceList());
            Navigator.pop(context);
          }
          if (state is WorkspaceEditError) {
            flutterToastCustom(msg: state.errorMessage);
            context.read<WorkspaceBloc>().add(const WorkspaceList());
          }
        },
        buildWhen: (previous, current) {
          return previous != current;
        },
        builder: (context, state) {


          if (state is WorkspacePaginated) {
            return NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (!state.hasReachedMax &&
                    state.isLoading &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  context
                      .read<WorkspaceBloc>()
                      .add(LoadMoreWorkspace(searchQuery: _searchQuery));
                  return true;
                }
                return false;
              },
              child: state.workspace.isNotEmpty
                  ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.h),
                child: Stack(
                  children: [
                    MasonryGridView.count(
                      padding: EdgeInsets.only(top: 10.h, bottom: 50.h),
                      crossAxisCount: 2,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                      itemCount: state.workspace.length, // Remove the +2
                      itemBuilder: (context, index) {
                        if (index < state.workspace.length) {
                          WorkspaceModel work = state.workspace[index];
                          DateTime createdDate =
                          parseDateStringFromApi(work.createdAt!);
                          String? date =
                          dateFormatConfirmed(createdDate, context);

                          return _workspaceListCard(
                              isLightTheme, work, state.isLoading, date);
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
                    // if ( !state.hasReachedMax)
                    //   Positioned(
                    //     bottom: 0,
                    //     left: 0,
                    //     right: 0,
                    //     child: SizedBox(
                    //       height: 50.h,
                    //       width: double.infinity,
                    //       child: Center(
                    //         child: SpinKitFadingCircle(
                    //           color: AppColors.primary,
                    //           size: 40.0,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
              )
                  : NoData(isImage: true),
            );
          }
          if (state is WorkspaceEditSuccessLoading) {
            return GridShimmer();
          }
          if (state is WorkspaceLoading) {
            return GridShimmer();
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _workspaceListCard(isLightTheme, work, isLoading, date) {
    return Padding(
        padding: EdgeInsets.all(5.w),
        child: Stack(
          children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
                child: Container(
                  // width: 180.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.containerDark,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      isLightTheme
                          ? MyThemes.lightThemeShadow
                          : MyThemes.darkThemeShadow,
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 7.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 18.w),
                              child: CustomText(
                                text: "#${work.id.toString()}",
                                size: 12.29.sp,
                                color:
                                Theme.of(context).colorScheme.textClrChange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            context.read<PermissionsBloc>().iscreateWorkspace ==
                                true ||
                                context
                                    .read<PermissionsBloc>()
                                    .iseditWorkspace ==
                                    true
                                ? SizedBox(
                              // color: Colors.red,
                              height: 30.h,
                              child: Container(
                                  width: 30.w,
                                  // color: Colors.yellow,
                                  margin: EdgeInsets.zero,
                                  padding: EdgeInsets.zero,
                                  child: CustomPopupMenuButton(
                                    isEditAllowed: context
                                        .read<PermissionsBloc>()
                                        .iseditWorkspace ==
                                        true,
                                    isDeleteAllowed: context
                                        .read<PermissionsBloc>()
                                        .isdeleteWorkspace ==
                                        true,
                                    onSelected: (value) async {
                                      if (value == 'Edit') {
                                        List<String> userName = [];
                                        List<String> clientNmae = [];
                                        if (work.users != null) {
                                          for (var user in work.users!) {
                                            userName.add(user.firstName!);
                                          }
                                        }
                                        if (work.clients != null) {
                                          for (var client
                                          in work.clients!) {
                                            clientNmae
                                                .add(client.firstName!);
                                          }
                                        }

                                        await createEditWorkspace(
                                            false,
                                            isLightTheme,
                                            work.id,
                                            work.title,
                                            userName,
                                            work.userIds,
                                            clientNmae,
                                            work.clientIds,
                                            work.id,
                                            work.primaryWorkspace);
                                      } else if (value == "Delete") {
                                        // if (isDemo) {
                                        //   flutterToastCustom(
                                        //       msg: AppLocalizations.of(
                                        //               context)!
                                        //           .isDemooperation);
                                        // } else {
                                        await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape:
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius
                                                    .circular(10
                                                    .r), // Set the desired radius here
                                              ),
                                              backgroundColor: Theme.of(
                                                  context)
                                                  .colorScheme
                                                  .alertBoxBackGroundColor,
                                              title: Text(
                                                AppLocalizations.of(
                                                    context)!
                                                    .confirmDelete,
                                              ),
                                              content: Text(
                                                AppLocalizations.of(
                                                    context)!
                                                    .areyousure,
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    _onDeleteWorkspace(
                                                        work.id);
                                                    Navigator.of(
                                                        context)
                                                        .pop(
                                                        true); // Confirm deletion
                                                  },
                                                  child: const Text(
                                                      'Delete'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(
                                                        context)
                                                        .pop(
                                                        false); // Cancel deletion
                                                  },
                                                  child: const Text(
                                                      'Cancel'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        // }
                                      }
                                    },
                                  )),
                            )
                                : const SizedBox.shrink()
                            // EditDeleteWidget()
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          child: InkWell(
                            onTap: () {},
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          userClientDialog(
                                            from: 'user',
                                            context: context,
                                            title: AppLocalizations.of(context)!
                                                .allusers,
                                            list: work.users!.isEmpty
                                                ? []
                                                : work.users!.isEmpty
                                                ? CustomText(
                                                textAlign:
                                                TextAlign.center,
                                                text:
                                                AppLocalizations.of(
                                                    context)!
                                                    .nodata,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .textClrChange)
                                                : work.users,
                                          );
                                        },
                                        child: RowUserClientGridList(
                                            list: work.users!, title: "user")),
                                    InkWell(
                                        onTap: () {
                                          userClientDialog(
                                            context: context,
                                            from: 'client',
                                            title: AppLocalizations.of(context)!
                                                .allclients,
                                            list: work.clients!.isEmpty
                                                ? []
                                                : work.clients!.isEmpty
                                                ? CustomText(
                                                textAlign:
                                                TextAlign.center,
                                                text:
                                                AppLocalizations.of(
                                                    context)!
                                                    .nodata,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .textClrChange)
                                                : work.clients,
                                          );
                                        },
                                        child: RowUserClientGridList(
                                            list: work.clients!,
                                            title: "client")),
                                  ],
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  height: 20.h,
                                  // alignment:
                                  //     Alignment.centerLeft,
                                  //   color: Colors.red,
                                  child: CustomText(
                                    text: work.title!,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                    size: 15,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 8.h,
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    DefaultWorkspaceSwitch(
                                      id: work.id!,
                                      idDefault: work.defaultWorkspace,
                                      onStatus:
                                      handleStatusSelectedVisiblestatus,
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    CustomText(
                                      text: AppLocalizations.of(context)!
                                          .defaultworkspcae,
                                      color: AppColors.greyColor,
                                      size: 8,
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: const HeroIcon(
                                        HeroIcons.calendar,
                                        style: HeroIconStyle.solid,
                                        color: AppColors.blueColor,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 2.w,
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: SizedBox(
                                        width: 70.w,
                                        child: CustomText(
                                          text: date,
                                          color: AppColors.greyColor,
                                          size: 10.sp,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )),
            // idOfWorkspace == work.id
            //     ? Positioned(
            //         right: 0,
            //         child: Container(
            //           height: 20.h,
            //           width: 20.w,
            //           color: AppColors.primary,
            //           child: HeroIcon(
            //             HeroIcons.check,
            //             style: HeroIconStyle.outline,
            //             size: 15.sp,
            //             color: AppColors.pureWhiteColor,
            //           ),
            //         ),
            //       )
            //     : SizedBox.shrink(),
          ],
        ));
  }

  Widget workspaceLists(isLightTheme, hasReachedMax, workspace, isLoading) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.h),
        // height: 500,
        width: double.infinity,
        child: Stack(children: [
          Container(
            color: AppColors.red,
            child: GridView.builder(
              padding: EdgeInsets.only(top: 10.h),
              // physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 1.w,
                mainAxisSpacing: 1.w,
                childAspectRatio: 1 / 1.2,
              ),
              shrinkWrap: true,
              itemCount: hasReachedMax
                  ? workspace.length
                  : workspace.length + 2, // Number of items in the grid
              itemBuilder: (BuildContext context, int index) {
                if (index < workspace.length) {
                  WorkspaceModel work = workspace[index];
                  DateTime createdDate =
                  parseDateStringFromApi(work.createdAt!);
                  String? date = dateFormatConfirmed(createdDate, context);
                  return Stack(
                    children: [
                      Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 10.h),
                          child: Container(
                            width: 180.w,
                            decoration: BoxDecoration(
                              color:
                              Theme.of(context).colorScheme.containerDark,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                isLightTheme
                                    ? MyThemes.lightThemeShadow
                                    : MyThemes.darkThemeShadow,
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 7.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 18.w),
                                        child: CustomText(
                                          text: "#${work.id.toString()}",
                                          size: 12.29.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .textClrChange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      context
                                          .read<PermissionsBloc>()
                                          .iscreateWorkspace ==
                                          true ||
                                          context
                                              .read<PermissionsBloc>()
                                              .iseditWorkspace ==
                                              true
                                          ? SizedBox(
                                        // color: Colors.red,
                                        height: 30.h,
                                        child: Container(
                                            width: 30.w,
                                            // color: Colors.yellow,
                                            margin: EdgeInsets.zero,
                                            padding: EdgeInsets.zero,
                                            child: CustomPopupMenuButton(
                                              isEditAllowed: context
                                                  .read<
                                                  PermissionsBloc>()
                                                  .iseditWorkspace ==
                                                  true,
                                              isDeleteAllowed: context
                                                  .read<
                                                  PermissionsBloc>()
                                                  .isdeleteWorkspace ==
                                                  true,
                                              onSelected: (value) async {
                                                if (value == 'Edit') {
                                                  List<String> userName =
                                                  [];
                                                  List<String>
                                                  clientNmae = [];
                                                  if (work.users !=
                                                      null) {
                                                    for (var user
                                                    in work.users!) {
                                                      userName.add(user
                                                          .firstName!);
                                                    }
                                                  }
                                                  if (work.clients !=
                                                      null) {
                                                    for (var client
                                                    in work
                                                        .clients!) {
                                                      clientNmae.add(client
                                                          .firstName!);
                                                    }
                                                  }

                                                  await createEditWorkspace(
                                                      false,
                                                      isLightTheme,
                                                      work.id,
                                                      work.title,
                                                      userName,
                                                      work.userIds,
                                                      clientNmae,
                                                      work.clientIds,
                                                      work.id,
                                                      work.primaryWorkspace);
                                                } else if (value ==
                                                    "Delete") {
                                                  await showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              10.r), // Set the desired radius here
                                                        ),
                                                        backgroundColor: Theme
                                                            .of(context)
                                                            .colorScheme
                                                            .alertBoxBackGroundColor,
                                                        title: Text(
                                                          AppLocalizations.of(
                                                              context)!
                                                              .confirmDelete,
                                                        ),
                                                        content: Text(
                                                          AppLocalizations.of(
                                                              context)!
                                                              .areyousure,
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed:
                                                                () {
                                                              _onDeleteWorkspace(
                                                                  work.id);
                                                              Navigator.of(
                                                                  context)
                                                                  .pop(
                                                                  true); // Confirm deletion
                                                            },
                                                            child: const Text(
                                                                'Delete'),
                                                          ),
                                                          TextButton(
                                                            onPressed:
                                                                () {
                                                              Navigator.of(
                                                                  context)
                                                                  .pop(
                                                                  false); // Cancel deletion
                                                            },
                                                            child: const Text(
                                                                'Cancel'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                            )),
                                      )
                                          : const SizedBox.shrink()
                                      // EditDeleteWidget()
                                    ],
                                  ),
                                  Padding(
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 18.w),
                                    child: InkWell(
                                      onTap: () {},
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                  onTap: () {
                                                    userClientDialog(
                                                      from: 'user',
                                                      context: context,
                                                      title:
                                                      AppLocalizations.of(
                                                          context)!
                                                          .allusers,
                                                      list: work.users!.isEmpty
                                                          ? []
                                                          : work.users!.isEmpty
                                                          ? CustomText(
                                                          textAlign:
                                                          TextAlign
                                                              .center,
                                                          text: AppLocalizations.of(
                                                              context)!
                                                              .nodata,
                                                          color: Theme.of(
                                                              context)
                                                              .colorScheme
                                                              .textClrChange)
                                                          : work.users,
                                                    );
                                                  },
                                                  child: RowUserClientGridList(
                                                      list: work.users!,
                                                      title: "user")),
                                              InkWell(
                                                  onTap: () {
                                                    userClientDialog(
                                                      context: context,
                                                      from: 'client',
                                                      title:
                                                      AppLocalizations.of(
                                                          context)!
                                                          .allclients,
                                                      list: work
                                                          .clients!.isEmpty
                                                          ? []
                                                          : work.clients!
                                                          .isEmpty
                                                          ? CustomText(
                                                          textAlign:
                                                          TextAlign
                                                              .center,
                                                          text: AppLocalizations.of(
                                                              context)!
                                                              .nodata,
                                                          color: Theme.of(
                                                              context)
                                                              .colorScheme
                                                              .textClrChange)
                                                          : work.clients,
                                                    );
                                                  },
                                                  child: RowUserClientGridList(
                                                      list: work.clients!,
                                                      title: "client")),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5.h,
                                          ),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 20.h,
                                            // alignment:
                                            //     Alignment.centerLeft,
                                            //   color: Colors.red,
                                            child: CustomText(
                                              text: work.title!,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .textClrChange,
                                              size: 15,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 8.h,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              DefaultWorkspaceSwitch(
                                                id: work.id!,
                                                idDefault:
                                                work.defaultWorkspace,
                                                onStatus:
                                                handleStatusSelectedVisiblestatus,
                                              ),
                                              SizedBox(
                                                width: 5.w,
                                              ),
                                              CustomText(
                                                text: AppLocalizations.of(
                                                    context)!
                                                    .defaultworkspcae,
                                                color: AppColors.greyColor,
                                                size: 8,
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20.h,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: const HeroIcon(
                                                  HeroIcons.calendar,
                                                  style: HeroIconStyle.solid,
                                                  color: AppColors.blueColor,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 2.w,
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: SizedBox(
                                                  width: 70.w,
                                                  child: CustomText(
                                                    text: date,
                                                    color: AppColors.greyColor,
                                                    size: 10.sp,
                                                    maxLines: 1,
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )),

                    ],
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ),
          //     if (!hasReachedMax && isLoading)
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: SizedBox(
          //     height: 50.h,
          //     width: double.infinity,
          //     child: Center(
          //       child: SpinKitFadingCircle(
          //         color: AppColors.primary,
          //         size: 40.0,
          //       ),
          //     ),
          //   ),
          // ),
        ]));
  }

  Widget appBar(isLightTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: BackArrow(
        iscreatePermission: context.read<PermissionsBloc>().iscreateWorkspace,
        isFromNotification: widget.fromNoti,
        fromNoti: "workspace",
        title: AppLocalizations.of(context)!.workspaceFromDrawer,
        isAdd: context.read<PermissionsBloc>().iscreateWorkspace,
        onPress: () async {
          await createEditWorkspace(
              true, isLightTheme, 0, "", "", [], "", [], 0, 0);
        },
      ),
    );
  }

  Widget button() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          highlightColor: Colors.transparent, // No highlight on tap
          splashColor: Colors.transparent,
          onTap: () {
            // router.pop(context);
          },
          child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.textsubColor,
                  borderRadius: BorderRadius.circular(6)),
              height: 30.h,
              width: 120,
              margin: EdgeInsets.symmetric(vertical: 10.h),
              child: CustomText(
                text: AppLocalizations.of(context)!.cancel,
                size: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.pureWhiteColor,
              )),
        ),
        SizedBox(
          width: 20.w,
        ),
        InkWell(
          highlightColor: Colors.transparent, // No highlight on tap
          splashColor: Colors.transparent,
          onTap: () {
            // router.pop(context);
          },
          child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.purple2Color,
                  borderRadius: BorderRadius.circular(6)),
              height: 30.h,
              width: 120,
              margin: EdgeInsets.symmetric(vertical: 10.h),
              child: CustomText(
                text: AppLocalizations.of(context)!.create,
                size: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.pureWhiteColor,
              )),
        )
      ],
    );
  }

  Future<void> createEditWorkspace(
      isCreate,
      isLightTheme,
      id,
      title,
      user,
      userid,
      client,
      clientid,
      index,
      visiblePartialIs,
      ) {
    if (!isCreate) {

      if (visiblePartialIs == 1) {
        visiblestatus = true;
      } else if (visiblePartialIs == 0) {
        visiblestatus = false;
      }
      titleController.text = title ?? '';
      usersName = user;
      clientsName = client;
    } else {
      // Clear the text fields for creating a new workspace
      titleController.clear();
    }
    _getRoleAndHasDataAccess();
    return showModalBottomSheet<void>(
      isScrollControlled:
      true, // Ensures the sheet adjusts when keyboard appears
      context: context,
      builder: (BuildContext context) {

        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom, // Adjusts for keyboard
              ),
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: const [],
                    borderRadius: BorderRadius.circular(25),
                    color: Theme.of(context).colorScheme.backGroundColor,
                  ),
                  height: 500.h,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Column(
                        mainAxisSize:
                        MainAxisSize.min, // Adjusts height dynamically
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18.w),
                            child: BackArrow(
                              iscreatePermission: context
                                  .read<PermissionsBloc>()
                                  .iscreateWorkspace,
                              isBottomSheet: true,
                              title: isCreate == true
                                  ? AppLocalizations.of(context)!
                                  .createworkspace
                                  : AppLocalizations.of(context)!.editworkspace,
                              iSBackArrow: false,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          CustomTextFields(
                            title: AppLocalizations.of(context)!.title,
                            hinttext:
                            AppLocalizations.of(context)!.pleaseentertitle,
                            controller: titleController,
                            onSaved: (v) {},
                            onFieldSubmitted: (v) {},
                            isLightTheme: isLightTheme,
                            isRequired: true,
                          ),
                          SizedBox(height: 15.h),
                          UsersField(
                            isRequired: false,
                            isCreate: isCreate!,
                            usersname: usersName ?? [],
                            usersid: (userid ?? []).cast<int>(),
                            project: const [],
                            onSelected: (selectedNames, selectedIds) {
                              _handleUsersSelected(
                                  selectedNames, selectedIds, setState);
                            },
                          ),
                          SizedBox(height: 15.h),
                          ClientField(
                            isCreate: isCreate!,
                            usersname: clientsName ?? [],
                            project: const [],
                            clientsid: (clientid ?? []).cast<int>(),
                            onSelected: (selectedNames, selectedIds) {
                              _handleClientSelected(
                                  selectedNames, selectedIds, setState);
                            },
                          ),
                          SizedBox(height: 20.h),
                          hasAllDataAccess == true && role == "admin"
                              ? Padding(
                            padding:
                            EdgeInsets.symmetric(horizontal: 20.w),
                            child: Row(
                              children: [
                                PrimaryWorkspaceSwitch(
                                  // primaryWorkspace: int.tryParse(visiblestatus.toString()) ?? 0,
                                  primaryWorkspace: visiblePartialIsPrimary ?? 0,
                                  onStatus:
                                  handleStatusSelectedVisiblestatusPrimary,
                                  id: id,
                                ),
                                SizedBox(width: 20.w),
                                CustomText(
                                  text: AppLocalizations.of(context)!
                                      .primaryworkspcae,
                                  color: AppColors.greyColor,
                                  size: 12,
                                ),
                              ],
                            ),
                          )
                              : SizedBox(),
                          SizedBox(height: 25.h),
                          BlocBuilder<WorkspaceBloc, WorkspaceState>(
                              builder: (context, state) {
                                if (state is WorkspaceCreateSuccessLoading) {
                                  return CreateCancelButtom(
                                    isLoading: true,
                                    isCreate: isCreate,
                                    onpressCreate: isCreate == true
                                        ? () async {
                                      print("Creating workspace...");
                                      // onCreateWorkspace();
                                    }
                                        : () {
                                      print("Editing workspace...");
                                    },
                                    onpressCancel: () {
                                      Navigator.pop(context);
                                    },
                                  );
                                }
                                if (state is WorkspaceEditSuccessLoading) {
                                  return CreateCancelButtom(
                                    isLoading: true,
                                    isCreate: isCreate,
                                    onpressCreate: isCreate == true
                                        ? () async {
                                      print("Creating workspace...");
                                    }
                                        : () {
                                      print("Editing workspace...");
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
                                    _onCreateWorkspace();
                                  }
                                      : () {
                                    _onEditWorkspace(
                                        id,
                                        title,
                                        visiblePartialIs,
                                        user,
                                        userid,
                                        client,
                                        clientid);
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
              ),
            );
          },
        );
      },
    );
  }
}
