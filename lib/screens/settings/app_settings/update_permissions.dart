import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/bloc/roles/role_event.dart';
import 'package:taskify/config/colors.dart';

import 'package:taskify/screens/settings/app_settings/widgets/custom_permission_select.dart';
import '../../../bloc/roles/role_bloc.dart';
import '../../../bloc/roles/role_state.dart';
import '../../../bloc/setting/settings_bloc.dart';
import '../../../bloc/setting/settings_event.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/internet_connectivity.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../routes/routes.dart';
import '../../../utils/widgets/back_arrow.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/no_internet_screen.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../notes/widgets/notes_shimmer_widget.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../widgets/custom_textfields/custom_textfield.dart';

class PermissionsToRole extends StatefulWidget {
  final int roleId;
  final String roleName;
  final bool isCreate;
  const PermissionsToRole(
      {super.key,
      required this.roleId,
      required this.roleName,
      required this.isCreate});

  @override
  State<PermissionsToRole> createState() => _PermissionsToRoleState();
}

class _PermissionsToRoleState extends State<PermissionsToRole> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  TextEditingController nameController = TextEditingController();
  bool isAllSelected = false;
  bool isAllSelectedExpand = false;
  bool isLoading = true;
  bool isExpanded = false;
  int _selectedIndex = 1;
  // Map<int, PermissionsWithCMED> previousPermissions = {};
  Map<int, bool> expandedPermissions = {}; // Track expansion state
  List<int> selectIds = [];

  final List<String> access = ["All Data Access ", "Allocated Data Access"];
  List<int?> selectedPermissionIds = []; // ✅ Store selected permissions

  void updateSelectedPermissions(List<int?> ids) {
    print("Received IDs: $ids"); // Debug print to see incoming IDs

    Future.delayed(Duration.zero, () {
      if (mounted) {
        setState(() {
          selectedPermissionIds = ids;

          // Explicitly convert and filter non-null integers
          selectIds =
              ids.where((id) => id != null).map((id) => id!).toSet().toList();

          print(
              "Updated selectIds: $selectIds"); // Debug print to verify selectIds
        });
      }
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
    print("skd dfkzx;l ${widget.isCreate}");
    nameController.text = widget.roleName;

    BlocProvider.of<SettingsBloc>(context)
        .add(const SettingsList("media_storage_settings"));
    setState(() {
      isLoading = true;
    });
    if (widget.isCreate == false) {
      BlocProvider.of<RoleBloc>(context)
          .add(RolePermissionList(roleId: widget.roleId));
    } else {
      BlocProvider.of<RoleBloc>(context).add(RolePermissionInitialList());
    }
    setState(() {
      isLoading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<RoleBloc>().state;
      if (state is RoleSuccess) {
        final selectedRole =
            state.role.firstWhere((role) => role.id == widget.roleId);
        final hasAccessAllData =
            selectedRole.permissions!.contains("access_all_data");
        _selectedIndex = hasAccessAllData ? 0 : 1;
      }
    });
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
            backgroundColor: Theme.of(context).colorScheme.backGroundColor,
            body: Stack(children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    appbar(isLightTheme),
                    SizedBox(height: 30.h),
                    createUpdatePermissionBody(isLightTheme)
                  ],
                ),
              ),
              isLoading == true
                  ? SizedBox()
                  : Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0.w),
                        child: Container(
                          height: 80.h,
                          color: Theme.of(context).colorScheme.containerDark,
                          child: CreateCancelButtom(
                              isCreate: widget.isCreate,
                              isLoading: false,
                              onpressCancel: () {
                                Navigator.pop(context);
                                BlocProvider.of<RoleBloc>(context).add(DeleteRole(widget.roleId));
                              },
                              onpressCreate: () {
                                final state = context.read<RoleBloc>().state;
                                if (state is RoleOfPermissionSuccess) {
                                  final roleBloc = context.read<RoleBloc>();

                                  if (roleBloc.isAllDataAccess == true) {
                                    List<int> selectedId = [];
                                    // Collect all permission IDs
                                    for (var permission in state.roleList) {
                                      if (permission.category == 'All_datas') {
                                        for (var p in permission
                                            .permissionsAssigned!) {
                                          print("ghzj $selectedId");
                                          selectedId.add(p.id!);
                                          print("ghzj Afetr $selectedId");
                                        }
                                      }
                                      if (!widget.isCreate) {
                                        context.read<RoleBloc>().add(UpdateRole(
                                              id: widget.roleId,
                                              ids: selectedId,
                                              name: widget.roleName,
                                            ));
                                      }
                                      if (widget.isCreate) {
                                        context.read<RoleBloc>().add(CreateRole(
                                              ids: selectedId,
                                              name: nameController.text,
                                            ));
                                      }
                                    }
                                  } else {
                                    // Remove the ID associated with "All_datas"
                                    selectIds.removeWhere((id) {
                                      return state.roleList.any((permission) =>
                                          permission.category == "All_datas" &&
                                          permission.permissionsAssigned!
                                              .any((p) => p.id == id));
                                    });

                                    if (widget.isCreate) {
                                      if (nameController.text.isNotEmpty) {
                                        context.read<RoleBloc>().add(CreateRole(
                                              ids: selectIds,
                                              name: nameController.text,
                                            ));
                                      } else {
                                        flutterToastCustom(
                                          msg: AppLocalizations.of(context)!
                                              .pleasefilltherequiredfield,
                                        );
                                      }
                                    } else {
                                      context.read<RoleBloc>().add(UpdateRole(
                                            id: widget.roleId,
                                            ids: selectIds,
                                            name: widget.roleName,
                                          ));
                                    }
                                  }
                                }
                                if (state is RoleOfPermissionInitialList) {
                                  final roleBloc = context.read<RoleBloc>();

                                  if (roleBloc.isAllDataAccess == true) {
                                    List<int> selectedId = [];
                                    // Collect all permission IDs
                                    for (var permission in state.roleList) {
                                      if (permission.category == 'All_datas') {
                                        for (var p in permission
                                            .permissionsAssigned!) {
                                          print("ghzj $selectedId");
                                          selectedId.add(p.id!);
                                          print("ghzj Afetr $selectedId");
                                        }
                                      }
                                      if (!widget.isCreate) {
                                        context.read<RoleBloc>().add(UpdateRole(
                                              id: widget.roleId,
                                              ids: selectedId,
                                              name: widget.roleName,
                                            ));
                                      }
                                      if (widget.isCreate) {
                                        context.read<RoleBloc>().add(CreateRole(
                                              ids: selectedId,
                                              name: nameController.text,
                                            ));
                                      }
                                    }
                                  } else {
                                    print("xfcgmhhmcxm");
                                    // Remove the ID associated with "All_datas"
                                    // selectIds.removeWhere((id) {
                                    //   return state.roleList.any((permission) =>
                                    //   permission.category == "All_datas" &&
                                    //       permission.permissionsAssigned!
                                    //           .any((p) => p.id == id));
                                    // });
                                    print("rjrfbk $selectIds");
                                    if (widget.isCreate) {
                                      if (nameController.text.isNotEmpty) {
                                        context.read<RoleBloc>().add(CreateRole(
                                              ids: selectIds,
                                              name: nameController.text,
                                            ));
                                      } else {
                                        flutterToastCustom(
                                          msg: AppLocalizations.of(context)!
                                              .pleasefilltherequiredfield,
                                        );
                                      }
                                    } else {
                                      context.read<RoleBloc>().add(UpdateRole(
                                            id: widget.roleId,
                                            ids: selectIds,
                                            name: widget.roleName,
                                          ));
                                    }
                                  }
                                }
                              }
                              // ✅ Correct function call
                              ),
                        ),
                      ),
                    ),
            ]),
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
                    onTap: () {
                      BlocProvider.of<RoleBloc>(context).add(RoleList());
                      router.pop();
                    },
                    title: widget.isCreate
                        ? AppLocalizations.of(context)!.createpermissions
                        : AppLocalizations.of(context)!.updatepermissions,
                  )),
            ],
          ),
        )
      ],
    );
  }

  Widget createUpdatePermissionBody(isLightTheme) {
    return BlocBuilder<RoleBloc, RoleState>(builder: (context, state) {
      print("dfxcmzxgmv $state");
      if (state is RoleSuccess) {
        return SettingUpdateShimmer(
          count: 12,
        );
      }
      if (state is RoleOfPermissionSuccess) {
        if (widget.isCreate) {
          selectIds = [];
        } else {
          selectIds = state.roleList
              .expand((role) => role.permissionsAssigned ?? [])
              .where((permission) => permission.isAssigned == 1)
              .map((permission) => permission.id as int)
              .toList();
        }
        print("glknrgl $selectIds");

        return Column(children: [
          CustomTextFields(
              title: AppLocalizations.of(context)!.name,
              hinttext: "",
              controller: nameController,
              onSaved: (value) {},
              onFieldSubmitted: (value) {},
              isLightTheme: isLightTheme,
              isRequired: true),

          SizedBox(
            height: 20.w,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity, // Make the buttons take full width
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ToggleButtons(
                    isSelected: [_selectedIndex == 0, _selectedIndex == 1],
                    onPressed: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });

                      print("jgbjkfz  $_selectedIndex");
                      Future.microtask(() {
                        if (_selectedIndex == 0) {
                          int? allDataPermissionId;

                          final allDataRole = state.roleList
                              .where((role) => role.category == "All_datas")
                              .firstOrNull;

                          if (allDataRole != null &&
                              allDataRole.permissionsAssigned != null) {
                            allDataPermissionId =
                                allDataRole.permissionsAssigned!.first.id;

                            print(
                                "Selected 'All_datas' permission ID: $allDataPermissionId");

                            if (allDataPermissionId != null) {
                              context.read<RoleBloc>().add(AllDataAccess(
                                    allAccessDataId: allDataPermissionId,
                                    isAllDataSelected: true,
                                    roleList: state.roleList,
                                  ));
                            }
                          }
                        } else {
                          context.read<RoleBloc>().add(AllDataAccess(
                                allAccessDataId: 0,
                                isAllDataSelected: false,
                                roleList: state.roleList,
                              ));
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    selectedColor: Colors.white,
                    color: Theme.of(context).colorScheme.textClrChange,
                    fillColor: AppColors.primary,
                    constraints: BoxConstraints.expand(
                      width: (constraints.maxWidth / access.length) -
                          4, // Equal width for each button
                    ),
                    children: access
                        .asMap()
                        .entries
                        .map((entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: CustomText(
                                text: entry.value,
                                textAlign: TextAlign.center,
                                color: _selectedIndex == entry.key
                                    ? Colors.white // Change color when selected
                                    : Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                fontWeight: FontWeight.bold,
                                size: 12,
                                maxLines: 1,
                                overflow:  TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
            ),
          ),

          SizedBox(
            height: 20.w,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Row(
                    children: [
                      TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 300),
                        tween: Tween<double>(
                            begin: 1.0, end: isAllSelected ? 1.5 : 1.3),
                        curve: Curves.easeInOut,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale:
                                scale, // Smoothly animates scale without adding space
                            child: Checkbox.adaptive(
                              activeColor: AppColors.primary,
                              checkColor: Colors.white,
                              side: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              value: isAllSelected,
                              onChanged: (value) {
                                setState(() {
                                  isAllSelected = value!;
                                });
                              },
                            ),
                          );
                        },
                      ),
                      CustomText(
                        text: AppLocalizations.of(context)!.selectall,
                        fontWeight: FontWeight.w400,
                        size: 12.sp,
                        color: Theme.of(context).colorScheme.textClrChange,
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 300),
                          tween: Tween<double>(
                              begin: 1.0, end: isAllSelectedExpand ? 1.5 : 1.3),
                          curve: Curves.easeInOut,
                          builder: (context, scale, child) {
                            return Transform.scale(
                                scale:
                                    scale, // Smoothly animates scale without adding space
                                child: Checkbox.adaptive(
                                    activeColor: AppColors.primary,
                                    checkColor: Colors.white,
                                    side: BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    value: isAllSelectedExpand,
                                    onChanged: (value) {
                                      setState(() {
                                        isAllSelectedExpand = value!;
                                        // Update all permissions' expanded state
                                        for (int i = 0;
                                            i < state.roleList.length;
                                            i++) {
                                          expandedPermissions[i] =
                                              isAllSelectedExpand;
                                        }
                                      });
                                    }));
                          }),
                      CustomText(
                        text: AppLocalizations.of(context)!.expandall,
                        fontWeight: FontWeight.w400,
                        size: 12.sp,
                        color: Theme.of(context).colorScheme.textClrChange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ListView for the role list and permissions
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: state.roleList
                .where((role) => role.category != "All_datas")
                .length, // ✅ Exclude "All_datas"
            itemBuilder: (context, index) {
              final filteredRoles = state.roleList
                  .where((role) => role.category != "All_datas")
                  .toList(); // ✅ Create a filtered list
              final role = filteredRoles[index];

              return CustomPermissionSelect(
                isAllSelected: isAllSelected,
                onPermissionSelected:
                    updateSelectedPermissions, // ✅ Pass callback
                title: role.category!
                    .replaceAll('_', ' '), // ✅ Bind category from model
                permissions:
                    role.permissionsAssigned!, // ✅ Pass permissions from model
                isExpanded: expandedPermissions[index] ?? false,
                onExpandChanged: (isExpanded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        expandedPermissions[index] = isExpanded;
                      });
                    }
                  });
                },
                isCreate: widget.isCreate,
              );
            },
          ),

          SizedBox(
            height: 15.h,
          ),

          SizedBox(
            height: 100.h,
          ),
        ]);
      }
      if (state is RoleOfPermissionInitialList) {
        if (widget.isCreate) {
          // selectIds = []; // Might be resetting selectIds to empty
        } else {
          selectIds = state.roleList
              .expand((role) => role.permissionsAssigned ?? [])
              .where((permission) => permission.isAssigned == 1)
              .map((permission) => permission.id as int)
              .toList();
        }

        return Column(children: [
          CustomTextFields(
              title: AppLocalizations.of(context)!.name,
              hinttext: "",
              controller: nameController,
              onSaved: (value) {},
              onFieldSubmitted: (value) {},
              isLightTheme: isLightTheme,
              isRequired: true),

          SizedBox(
            height: 20.w,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity, // Make the buttons take full width
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ToggleButtons(
                    isSelected: [_selectedIndex == 0, _selectedIndex == 1],
                    onPressed: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });

                      print("jgbjkfz  $_selectedIndex");
                      Future.microtask(() {
                        if (_selectedIndex == 0) {
                          int? allDataPermissionId;

                          final allDataRole = state.roleList
                              .where((role) => role.category == "All_datas")
                              .firstOrNull;

                          if (allDataRole != null &&
                              allDataRole.permissionsAssigned != null) {
                            allDataPermissionId =
                                allDataRole.permissionsAssigned!.first.id;

                            print(
                                "Selected 'All_datas' permission ID: $allDataPermissionId");

                            if (allDataPermissionId != null) {
                              context.read<RoleBloc>().add(AllDataAccess(
                                    allAccessDataId: allDataPermissionId,
                                    isAllDataSelected: true,
                                    roleList: state.roleList,
                                  ));
                            }
                          }
                        } else {
                          context.read<RoleBloc>().add(AllDataAccess(
                                allAccessDataId: 0,
                                isAllDataSelected: false,
                                roleList: state.roleList,
                              ));
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    selectedColor: Colors.white,
                    color: Theme.of(context).colorScheme.textClrChange,
                    fillColor: AppColors.primary,
                    constraints: BoxConstraints.expand(
                      width: (constraints.maxWidth / access.length) -
                          4, // Equal width for each button
                    ),
                    children: access
                        .asMap()
                        .entries
                        .map((entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: CustomText(
                                text: entry.value,
                                textAlign: TextAlign.center,
                                color: _selectedIndex == entry.key
                                    ? Colors.white // Change color when selected
                                    : Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                fontWeight: FontWeight.bold,
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
            ),
          ),

          SizedBox(
            height: 20.w,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Row(
                    children: [
                      TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 300),
                          tween: Tween<double>(
                              begin: 1.0, end: isAllSelected ? 1.5 : 1.3),
                          curve: Curves.easeInOut,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale:
                                  scale, // Smoothly animates scale without adding space
                              child: Checkbox.adaptive(
                                activeColor: AppColors.primary,
                                checkColor: Colors.white,
                                side: BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                value: isAllSelected,
                                onChanged: (value) {
                                  setState(() {
                                    isAllSelected = value!;
                                    print("l;zgrmz $isAllSelected");
                                  });
                                },
                              ),
                            );
                          }),
                      CustomText(
                        text: AppLocalizations.of(context)!.selectall,
                        fontWeight: FontWeight.w400,
                        size: 12.sp,
                        color: Theme.of(context).colorScheme.textClrChange,
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 300),
                          tween: Tween<double>(
                              begin: 1.0, end: isAllSelectedExpand ? 1.5 : 1.3),
                          curve: Curves.easeInOut,
                          builder: (context, scale, child) {
                            return Transform.scale(
                                scale:
                                    scale, // Smoothly animates scale without adding space
                                child: Checkbox.adaptive(
                                    activeColor: AppColors.primary,
                                    checkColor: Colors.white,
                                    side: BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    value: isAllSelectedExpand,
                                    onChanged: (value) {
                                      setState(() {
                                        isAllSelectedExpand = value!;
                                        // Update all permissions' expanded state
                                        for (int i = 0;
                                            i < state.roleList.length;
                                            i++) {
                                          expandedPermissions[i] =
                                              isAllSelectedExpand;
                                        }
                                      });
                                    }));
                          }),
                      CustomText(
                        text: AppLocalizations.of(context)!.expandall,
                        fontWeight: FontWeight.w400,
                        size: 12.sp,
                        color: Theme.of(context).colorScheme.textClrChange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ListView for the role list and permissions
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: state.roleList
                .where((role) => role.category != "All_datas")
                .length, // ✅ Exclude "All_datas"
            itemBuilder: (context, index) {
              final filteredRoles = state.roleList
                  .where((role) => role.category != "All_datas")
                  .toList(); // ✅ Create a filtered list
              final role = filteredRoles[index];

              return CustomPermissionSelect(
                isAllSelected: isAllSelected,
                onPermissionSelected:
                    updateSelectedPermissions, // ✅ Pass callback
                title: role.category!
                    .replaceAll('_', ' '), // ✅ Bind category from model
                permissions:
                    role.permissionsAssigned!, // ✅ Pass permissions from model
                isExpanded: expandedPermissions[index] ?? false,
                onExpandChanged: (isExpanded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        expandedPermissions[index] = isExpanded;
                      });
                    }
                  });
                },
                isCreate: widget.isCreate,
              );
            },
          ),

          SizedBox(
            height: 15.h,
          ),

          SizedBox(
            height: 100.h,
          ),
        ]);
      }
      if (state is RoleError) {
        BlocProvider.of<RoleBloc>(context)
            .add(RolePermissionList(roleId: widget.roleId));
        return NotesShimmer();
      }
      if (state is UpdateRoleSuccess) {
        BlocProvider.of<RoleBloc>(context)
            .add(RolePermissionList(roleId: widget.roleId));
      }
      if (state is PreselectedIdsSuccess) {
        BlocProvider.of<RoleBloc>(context)
            .add(RolePermissionList(roleId: widget.roleId));
      }
      if (state is RoleOfPermissionCreatedSuccess) {
        router.pop();
        BlocProvider.of<RoleBloc>(context).add(RoleList());
      }
      return SizedBox();
    });
  }
}
