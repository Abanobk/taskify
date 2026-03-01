import 'dart:async';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/widgets/custom_container.dart';
import '../../../bloc/roles/role_bloc.dart';
import '../../../bloc/roles/role_event.dart';
import '../../../bloc/roles/role_state.dart';
import '../../../bloc/setting/settings_bloc.dart';
import '../../../bloc/setting/settings_event.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/user_profile/user_profile_bloc.dart';
import '../../../config/internet_connectivity.dart';
import '../../../src/generated/i18n/app_localizations.dart';

import '../../../routes/routes.dart';
import '../../../utils/widgets/back_arrow.dart';
import '../../../utils/widgets/custom_dimissible.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/no_internet_screen.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../notes/widgets/notes_shimmer_widget.dart';

class UpdatePermissionsScreen extends StatefulWidget {
  const UpdatePermissionsScreen({super.key});

  @override
  State<UpdatePermissionsScreen> createState() =>
      _UpdatePermissionsScreenState();
}

class _UpdatePermissionsScreenState extends State<UpdatePermissionsScreen> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  bool isAllSelected = false;
  bool isAllSelectedProject = false;
  Map<int, bool> expandedItems = {};
  bool? isLoading = true;
  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }
  void _onDeleteRole({required int id}) {
    BlocProvider.of<RoleBloc>(context).add(DeleteRole(id));
  }

  Future<void> _onRefresh() async {
    BlocProvider.of<RoleBloc>(context).add(RoleList());
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
    BlocProvider.of<RoleBloc>(context).add(RoleList());
    BlocProvider.of<SettingsBloc>(context)
        .add(const SettingsList("media_storage_settings"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : Scaffold(
            floatingActionButton:
                (context.read<UserProfileBloc>().role == "admin")
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 22.h),
                        child: FloatingActionButton(
                          isExtended: true,
                          onPressed: () {
                            context.read<UserProfileBloc>().role == "admin"
                                ? router.push(
                                    '/permissions',
                                    extra: {
                                      "roleId": 0,
                                      "roleName": "",
                                      "isCreate": true
                                    },
                                  )
                                : null;
                          },
                          backgroundColor: AppColors.primary,
                          child: const Icon(
                            Icons.add,
                            color: AppColors.whiteColor,
                          ), // Background color of the FAB
                        ),
                      )
                    : SizedBox.shrink(),
            backgroundColor: Theme.of(context).colorScheme.backGroundColor,
            body: Column(
              children: [
                appbar(isLightTheme),
                SizedBox(height: 30.h),
                RolePermissionBody(isLightTheme)
              ],
            ),
          );
  }

  Widget appbar(isLightTheme) {
    return Row(
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
                  child: BackArrow(
                    title: AppLocalizations.of(context)!.permissions,
                  )),
            ],
          ),
        )
      ],
    );
  }

  Widget RolePermissionBody(isLightTheme) {
    return Expanded(
      child: RefreshIndicator(
          color: AppColors.primary, // Spinner color
          backgroundColor: Theme.of(context).colorScheme.backGroundColor,
          onRefresh: _onRefresh,
          child: BlocBuilder<RoleBloc, RoleState>(
            builder: (context, state) {
              print("jsZFKd $state");
              if (state is RoleSuccess) {
                print("rgljzdfmv,  ${state.isLoadingMore}");
                return NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (scrollInfo is ScrollStartNotification) {
                        FocusScope.of(context).unfocus(); // Dismiss keyboard
                      }
                      // Check if the user has scrolled to the end and load more notes if needed
                      if (!state.isLoadingMore &&
                          scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                        print("a hs;dklxz,g fd fhknvdx,");
                        setState(() {});
                        context.read<RoleBloc>().add(RoleLoadMore());
                      }
                      return false;
                    },
                    child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 100.h),
                        // physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.isLoadingMore
                            ? state.role.length
                            : state.role.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index < state.role.length) {
                            var role = state.role[index];
                            final isSelected = index == state.selectedIndex;
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.h, horizontal: 18.w),
                              child: DismissibleCard(
                                title: role.id.toString(),
                                confirmDismiss:
                                    (DismissDirection direction) async {
                                  if (direction ==
                                      DismissDirection.endToStart) {
                                    if (role.name == "admin") {
                                      flutterToastCustom(
                                          msg: "Admin has all the permissions");
                                    } else {
                                      final result = await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .alertBoxBackGroundColor,
                                            title: Text(
                                                AppLocalizations.of(context)!
                                                    .confirmDelete),
                                            content: Text(
                                                AppLocalizations.of(context)!
                                                    .areyousure),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                },
                                                child: Text(AppLocalizations.of(
                                                        context)!
                                                    .delete),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                },
                                                child: Text(AppLocalizations.of(
                                                        context)!
                                                    .cancel),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      return result;
                                    }
                                  } else if (direction ==
                                      DismissDirection.startToEnd) {
                                    if (role.name == "admin") {
                                      flutterToastCustom(
                                          msg: "Admin has all the permissions");
                                    } else {
                                      router.push(
                                        '/permissions',
                                        extra: {
                                          "roleId": role.id,
                                          "roleName": role.name,
                                          "isCreate": false
                                        },
                                      );
                                    }
                                  }
                                  return false;
                                },
                                dismissWidget: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 0.h, horizontal: 0.w),
                                  child: customContainer(
                                    // height: 40.h,
                                    context: context,
                                    addWidget: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 18.w, vertical: 5.h),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 10,
                                                child: CustomText(
                                                  text: role.name!,
                                                  fontWeight: FontWeight.w500,
                                                  size: 18.sp,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  color: isSelected
                                                      ? AppColors.purple
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .textClrChange,
                                                ),
                                              ),
                                              Expanded(
                                                  flex: 1,
                                                  child: GlowContainer(
                                                    shape: BoxShape.circle,
                                                    glowColor: isLightTheme
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                            .withValues(
                                                                alpha: 0.1)
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                            .withValues(
                                                                alpha: 0.3),
                                                    blurRadius: 10,
                                                    spreadRadius: 1,
                                                    child: Container(
                                                      alignment: Alignment
                                                          .center, // Center content inside the container
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .backGroundColor,
                                                      ),
                                                      child: IconButton(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        constraints:
                                                            BoxConstraints(),
                                                        splashColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        icon: Icon(
                                                          (expandedItems[
                                                                      index] ??
                                                                  false)
                                                              ? Icons
                                                                  .keyboard_arrow_up
                                                              : Icons
                                                                  .keyboard_arrow_down,
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .textClrChange,
                                                          size: 30,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            expandedItems[
                                                                    index] =
                                                                !(expandedItems[
                                                                        index] ??
                                                                    false);
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        ),
                                        if (expandedItems[index] ?? false)
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 2.h,
                                                bottom: 10.h,
                                                left: 15.w,
                                                right: 15.w),
                                            child: Wrap(
                                              spacing: 8
                                                  .w, // Horizontal spacing between badges
                                              runSpacing: 8
                                                  .h, // Vertical spacing when wrapping to new line
                                              children: [
                                                if (role.name?.toLowerCase() == 'admin') // Special case for Admin
                                                  Chip(
                                                    label: Text(
                                                      'Admin Has All the Permissions',
                                                      style: TextStyle(color: Colors.white, fontSize: 13.sp),
                                                    ),
                                                    backgroundColor: Colors.green,
                                                  )
                                                else if (role.permissions == null || role.permissions!.isEmpty) // Check for null or empty list
                                                  Chip(
                                                    label: Text(
                                                      'No Permissions Assigned',
                                                      style: TextStyle(color: Colors.white, fontSize: 13.sp),
                                                    ),
                                                    backgroundColor: Colors.red, // Use a different color to indicate no permissions
                                                  )
                                                else
                                                  ...role.permissions!.map((permission) {
                                                    return Chip(
                                                      label: Text(
                                                        permission.replaceAll('_', ' ').toUpperCase(),
                                                        style: TextStyle(color: Colors.white, fontSize: 13.sp),
                                                      ),
                                                      backgroundColor: AppColors.primary,
                                                    );
                                                  }).toList(), // Convert the mapped iterable to a list
                                              ],

                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                onDismissed: (DismissDirection direction) {
                                  if (direction ==
                                      DismissDirection.endToStart) {
                                    if (role.name == "admin") {
                                      flutterToastCustom(
                                          msg: "Admin cannot be deleted");
                                    } else {
                                      setState(() {
                                        state.role.removeAt(index);
                                        _onDeleteRole(id: role.id!);
                                      });
                                    }
                                  }
                                },
                              ),
                            );
                          } else {
                            return !state.isLoadingMore
                                ?Padding(
                              padding: const EdgeInsets
                                  .symmetric(vertical: 0),
                              child: Center(
                                child: const SpinKitFadingCircle(
                                  color: AppColors
                                      .primary,
                                  size: 40.0,
                                ),
                              ),
                            )
                                : const SizedBox.shrink();
                          }

                        }));
              }
              if (state is RoleError) {
                flutterToastCustom(
                    msg: AppLocalizations.of(context)!.deletedsuccessfully,
                    color: AppColors.primary);
                BlocProvider.of<RoleBloc>(context).add(RoleList());
              }
              if (state is RoleDeleteSuccess) {
                BlocProvider.of<RoleBloc>(context).add(RoleList());
              }
              return NotesShimmer(
                count: 12,
                height: 50.h,
              );
            },
          )),
    );
  }
}
