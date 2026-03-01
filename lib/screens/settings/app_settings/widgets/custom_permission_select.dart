import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';

import '../../../../data/model/settings/permission_role.dart';
import '../../../../src/generated/i18n/app_localizations.dart';import '../../../../utils/widgets/custom_text.dart';
import '../../../widgets/custom_container.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomPermissionSelect extends StatefulWidget {
  final String title;
  final bool isAllSelected;
  final bool isCreate;
  final List<PermissionsAssigned> permissions;
  final bool isExpanded;
  final Function(bool) onExpandChanged;
  final Function(List<int?>) onPermissionSelected; // ✅ Add callback

  CustomPermissionSelect({
    required this.title,
    required this.isCreate,
    required this.isAllSelected,
    required this.permissions,
    required this.isExpanded,
    required this.onExpandChanged,
    required this.onPermissionSelected, // ✅ Initialize callback
  });

  @override
  _CustomPermissionSelectState createState() => _CustomPermissionSelectState();
}

class _CustomPermissionSelectState extends State<CustomPermissionSelect> {
  late bool _isExpanded;
  bool isSelectAllChecked = false;
  List<bool> previousState = []; // To save previous state of permissions

  bool isSelectAll = false;

  // Store previous states before selecting all
  List<PermissionsAssigned> get permissions => widget.permissions;
  List<PermissionsAssigned> localPermissions = [];
  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    localPermissions =
        widget.permissions.map((perm) => perm.copyWith()).toList();
  }

  // Track the state before "select all"
  List<int> previousSelections = [];

  // void toggleSelectAll(bool? value) {
  //   setState(() {
  //     bool newValue = value ?? !isSelectAll;
  //
  //     if (!newValue) {
  //       // Restore previous selections when unchecking "Select All"
  //       for (var i = 0; i < localPermissions.length; i++) {
  //         localPermissions[i] = widget.permissions[i].copyWith();
  //       }
  //     } else {
  //       // Select all permissions
  //       for (var perm in localPermissions) {
  //         perm.isAssigned = 1;
  //       }
  //     }
  //
  //     isSelectAll = newValue;
  //
  //     // Notify parent widget with selected permission IDs
  //     widget.onPermissionSelected(getSelectedPermissionIds());
  //   });
  // }
  void toggleSelectAll(bool? value) {
    setState(() {
      isSelectAll = value ?? !isSelectAll;

      for (var perm in widget.permissions) {
        perm.isAssigned = isSelectAll ? 1 : 0;
      }

      widget.onPermissionSelected(getSelectedPermissionIds());
    });
  }

  // void toggleSelectAll(bool? value) {
  //   setState(() {
  //     bool newValue = value ?? !isSelectAll;
  //
  //     for (var perm in widget.permissions) {
  //       perm.isAssigned = newValue ? 1 : 0;
  //     }
  //
  //     isSelectAll = newValue;
  //     widget.onPermissionSelected(getSelectedPermissionIds());
  //   });
  // }

  List<int> allIds = [];

  @override
  void didUpdateWidget(covariant CustomPermissionSelect oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isExpanded != widget.isExpanded) {
      setState(() {
        _isExpanded = widget.isExpanded;
      });
    }
    if (widget.isAllSelected != oldWidget.isAllSelected) {
      setState(() {
        isSelectAll = widget.isAllSelected;
        for (var perm in widget.permissions) {
          perm.isAssigned = isSelectAll ? 1 : 0;
        }
        widget.onPermissionSelected(getSelectedPermissionIds());
      });
    }
    // if (widget.isAllSelected != oldWidget.isAllSelected) {
    //   setState(() {
    //     if (widget.isAllSelected) {
    //       // Select all permissions
    //       for (var perm in localPermissions) {
    //         perm.isAssigned = 1;
    //       }
    //     } else {
    //       // Restore original permission values
    //       for (var i = 0; i < localPermissions.length; i++) {
    //         localPermissions[i] = widget.permissions[i].copyWith();
    //       }
    //     }
    //
    //     isSelectAll = widget.isAllSelected;
    //
    //     // Update parent with selected IDs
    //     widget.onPermissionSelected(getSelectedPermissionIds());
    //   });
    // }
  }

  void togglePermission(int index, bool? value) {
    setState(() {
      widget.permissions[index] = widget.permissions[index].copyWith(
        isAssigned: value! ? 1 : 0,
      );

      // Automatically update "Select All" checkbox
      isSelectAll = widget.permissions.every((perm) => perm.isAssigned == 1);
      widget.onPermissionSelected(getSelectedPermissionIds());
    });
  }

  // void togglePermission(int index, bool? value) {
  //   setState(() {
  //     widget.permissions[index] = widget.permissions[index].copyWith(
  //       isAssigned: value! ? 1 : 0,
  //     );
  //
  //     // Check if all are selected
  //     isSelectAll = widget.permissions.every((perm) => perm.isAssigned == 1);
  //
  //     widget.onPermissionSelected(getSelectedPermissionIds());
  //   });
  // }

  // void togglePermission(int index, bool? value) {
  //   setState(() {
  //     widget.permissions[index] = widget.permissions[index].copyWith(
  //       isAssigned: value! ? 1 : 0,
  //     );
  //
  //     // Update "Select All" checkbox
  //     isSelectAll = widget.permissions.every((perm) => perm.isAssigned == 1);
  //     print("Toggled permission at index $index to: ${widget.permissions[index].isAssigned}");
  //
  //   });
  // }

  // void togglePermission(int index, bool? value) {
  //   setState(() {
  //     List<PermissionsAssigned> updatedPermissions = List.from(widget.permissions);
  //     updatedPermissions[index] = updatedPermissions[index].copyWith(
  //       isAssigned: value! ? 1 : 0,
  //     );
  //
  //     widget.permissions.clear();
  //     widget.permissions.addAll(updatedPermissions); // Replace the list reference
  //
  //     // Update "Select All" checkbox
  //     isSelectAll = widget.permissions.every((perm) => perm.isAssigned == 1);
  //   });
  // }

  void checkIfAllSelected() {
    setState(() {
      isSelectAll = permissions.every((p) => p.isAssigned == 1);
    });
  }

  List<int?> getSelectedPermissionIds() {
    return widget.permissions
        .where((permission) => permission.isAssigned == 1)
        .map((permission) => permission.id)
        .toList();
  }

  // void checkIfAllSelected() {
  //   setState(() {
  //     isSelectAll = permissions.every((p) => p.isAssigned == 1);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    print("kefDLKGFdngldK ${widget.permissions}");
    widget.permissions.forEach((action) {
      print("hbbh ${action.id}");
      if (action.isAssigned == 0) {
        print("knl sGVDN ${action.id}");
      }
    });
    List<int> ids = [];
    // if (widget.isAllSelected) {
    //   for (var perm in widget.permissions) {
    //     perm.isAssigned = 1;
    //   }
    // }

    isSelectAll = widget.permissions.every((perm) => perm.isAssigned == 1);
    ids.addAll(widget.permissions.map((perm) => perm.id).whereType<int>());

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
          widget.onExpandChanged(_isExpanded);
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        child: AnimatedSize(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: customContainer(
            height: _isExpanded ? 140.h : 60.h,
            context: context,
            addWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Theme.of(context).colorScheme.textClrChange,
                          ),
                          SizedBox(width: 10.w),
                          CustomText(
                            text: widget.title,
                            fontWeight: FontWeight.w700,
                            size: 15.sp,
                            color: Theme.of(context).colorScheme.textClrChange,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          CustomText(
                            text: AppLocalizations.of(context)!.selectall,
                            fontWeight: FontWeight.w400,
                            size: 12.sp,
                            color: Theme.of(context).colorScheme.textClrChange,
                          ),
                          TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 300),
                              tween: Tween<double>(
                                  begin: 1.0, end: isSelectAll ? 1.5 : 1.2),
                              curve: Curves.easeInOut,
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: 1.5,
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
                                    value: isSelectAll,
                                    onChanged: toggleSelectAll,
                                  ),
                                );
                              })
                        ],
                      ),
                    ],
                  ),
                ),
                if (_isExpanded)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    child: Column(
                      children: [
                        Divider(
                          color: Theme.of(context).colorScheme.dividerClrChange,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:
                              widget.permissions.asMap().entries.map((entry) {
                            int index = entry.key;
                            PermissionsAssigned perm = entry.value;
                            return permissionCheckbox(
                              label: perm.action![0].toUpperCase() +
                                  perm.action!.substring(1),
                              value: perm.isAssigned ?? 0,
                              onChanged: (value) =>
                                  togglePermission(index, value),
                              context: context,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget permissionCheckbox({
    required String label,
    required int value,
    required BuildContext context,
    required ValueChanged<bool?> onChanged,
  }) {
    return Column(
      children: [
        CustomText(
          text: label,
          fontWeight: FontWeight.w400,
          size: 12.sp,
          color: Theme.of(context).colorScheme.textClrChange,
        ),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween<double>(begin: 1.0, end: value == 1 ? 1.5 : 1.2),
          curve: Curves.easeInOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Checkbox.adaptive(
                activeColor: AppColors.primary,
                checkColor: Colors.white,
                side: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                value: value == 1,
                onChanged: (bool? newValue) => onChanged(newValue),
              ),
            );
          },
        ),
      ],
    );
  }
}
