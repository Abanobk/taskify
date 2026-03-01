import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/workspace/workspace_bloc.dart';
import '../../bloc/workspace/workspace_event.dart';
import '../../bloc/dashboard_stats/dash_board_stats_bloc.dart';
import '../../bloc/dashboard_stats/dash_board_stats_event.dart';
import '../../config/colors.dart';
import 'package:hive/hive.dart';
import '../../config/strings.dart';

class DefaultWorkspaceSwitch extends StatefulWidget {
  final int? idDefault;
  final Function(bool, int) onStatus;
  final int? id;
  final int? status;

  const DefaultWorkspaceSwitch(
      {super.key,
        this.idDefault,
        this.status,
        required this.onStatus,
        this.id});

  @override
  State<DefaultWorkspaceSwitch> createState() => _DefaultWorkspaceSwitchState();
}

class _DefaultWorkspaceSwitchState extends State<DefaultWorkspaceSwitch> {
  bool? hasPermission;
  bool? _currentStatus;
  int? defaultWorkspace;

  @override
  void initState() {
    print("jkl,;. ewre ${widget.idDefault}");
    print("jkl,;. ewre ${widget.id}");
    if (widget.idDefault == 0) {
      _currentStatus = false;
    } else if (widget.idDefault == 1) {
      _currentStatus = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterSwitch(
      height: 15.h,
      width: 30.w,
      padding: 2.w,
      toggleSize: 15.sp,
      borderRadius: 10.r,
      inactiveColor: AppColors.greyColor.withValues(alpha: 0.5),
      activeColor: AppColors.primary,
      value: _currentStatus!,
      onToggle: (value) {

        widget.onStatus(_currentStatus!, widget.id!);

        setState(() {
          _currentStatus = value;
          widget.onStatus(_currentStatus!, widget.id!);
          print("tghyjkl ${_currentStatus!}   $value");
        });
        if (_currentStatus == true) {
          defaultWorkspace = 1;
        } else {
          defaultWorkspace = 0;
        }
        widget.onStatus(_currentStatus!, widget.id!);
        BlocProvider.of<WorkspaceBloc>(context).add(CreateRemoveWorkspace(
            id: widget.id != null ? widget.id! : 0,
            defaultPrimary: defaultWorkspace!));

        context.read<DashBoardStatsBloc>().totalTodos.toString();
        context.read<DashBoardStatsBloc>().totalProject.toString();
        context.read<DashBoardStatsBloc>().totalTask.toString();
        context.read<DashBoardStatsBloc>().totaluser.toString();
        context.read<DashBoardStatsBloc>().totalClient.toString();
        context.read<DashBoardStatsBloc>().totalMeeting.toString();
      },// Use the local state variable
    );
  }
}

class PrimaryWorkspaceSwitch extends StatefulWidget {
  // final bool status;
  final bool? isPartial;
  final bool? idDefault;
  final Function(bool, int) onStatus;
  final int? id;
  final int? primaryWorkspace;

  const PrimaryWorkspaceSwitch(
      {super.key,
        this.isPartial,
        this.idDefault,
        required this.onStatus,
        this.primaryWorkspace,
        this.id});

  @override
  State<PrimaryWorkspaceSwitch> createState() => _PrimaryWorkspaceSwitchState();
}

class _PrimaryWorkspaceSwitchState extends State<PrimaryWorkspaceSwitch> {
  bool? hasPermission;
  bool? _currentStatus;
  int? id;
  int? primaryWorkspace;

  @override
  void initState() {
    print("zsdgfxg ${widget.primaryWorkspace}");
    getHasAllDataAccess();
    id = widget.id;

    super.initState();
  }

  Future<bool> getHasAllDataAccess() async {
    Box box = await Hive.openBox(userBox);
    hasPermission = await box.get('hasAllDataAccess');
    primaryWorkspace = widget.primaryWorkspace;

    setState(() {
      if (widget.primaryWorkspace != null) {
        print("ubhnfJK ${widget.primaryWorkspace}");
        print("ubhnfJK ${hasPermission}");
        if (widget.primaryWorkspace == 0) {
          _currentStatus = false;
        } else {
          _currentStatus = true;
        }
      }
    });
    return hasPermission!;
  }


  @override
  Widget build(BuildContext context) {
    return FlutterSwitch(
      height: 15.h,
      width: 30.w,
      padding: 2.w,
      toggleSize: 15.sp,
      borderRadius: 10.r,
      inactiveColor: AppColors.greyColor.withValues(alpha: 0.5),
      activeColor: AppColors.primary,
      value: hasPermission == true ? _currentStatus ?? false : false,  // Use the local state variable
      onToggle: (value) {
        widget.onStatus(_currentStatus!, widget.id!);
        if (hasPermission == true) {
          setState(() {
            _currentStatus = value;
            widget.onStatus(_currentStatus!, widget.id!);
            print("tghyjkl ${_currentStatus!}   $value");
          });
          if (_currentStatus == true) {
            primaryWorkspace = 1;
          } else {
            primaryWorkspace = 0;
          }
          widget.onStatus(_currentStatus!, widget.id!);
        } else {
          print("tryujikl waqedwa");
          _currentStatus = false;
        }
      },
    );
  }
}

class CustomSwitch extends StatefulWidget {
  final bool? status;
  final bool? visiblestatus;
  final bool? isPartial;
  final bool? idDefault;
  final bool? isCreate;
  final Function(bool) onStatus;
  final int? id;
  final int? primaryWorkspace;

  const CustomSwitch(
      {super.key,
        this.status,
        this.isPartial,
        this.isCreate,
        this.visiblestatus,
        this.idDefault,
        required this.onStatus,
        this.primaryWorkspace,
        this.id});

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  bool? hasPermission;
  late bool _currentStatus;
  int? primaryWorkspace;

  @override
  void initState() {
    primaryWorkspace = widget.primaryWorkspace;
    _currentStatus = widget.status!;
    print("jkl,;. ewre ${widget.status!}");
    super.initState();
  }

  setWorkspace(workspcaId) async {
    var box = await Hive.openBox(userBox);
    box.put('workspace_id', workspcaId);
    print("tgyhujikl workSpaceId ${box.get('workspace_id')}");
  }

  @override
  Widget build(BuildContext context) {
    print("tghjk ${widget.status}");
    return FlutterSwitch(
      height: 15.h,
      width: 30.w,
      padding: 2.w,
      toggleSize: 15.sp,
      borderRadius: 10.r,
      inactiveColor: AppColors.greyColor.withValues(alpha: 0.5),
      activeColor: AppColors.primary,
      value: _currentStatus,
      // Use the local state variable
      onToggle: (value) {
        _currentStatus = value;
        widget.onStatus(_currentStatus);
        print("rtyuik fduigfdgn $value");
        if (widget.isCreate == false) {
          if (widget.isPartial == true) {
            widget.onStatus(_currentStatus);
          } else if (widget.isPartial == false) {
            widget.onStatus(_currentStatus);
          } else if (widget.idDefault == true) {
            print("rtyuik fduigfdgn $value");
            print("rtyuik fduigfdgn $hasPermission");
            widget.idDefault == true ? setWorkspace(widget.id) : null;
            BlocProvider.of<DashBoardStatsBloc>(context).add(StatsList());
            widget.onStatus(_currentStatus);
            if (hasPermission == true) {
              setState(() {
                _currentStatus = value;
                widget.onStatus(
                  _currentStatus,
                );
                print("tghyjkl $_currentStatus   $value");
              });
              if (_currentStatus == true) {
                primaryWorkspace = 1;
              } else {
                primaryWorkspace = 0;
              }
              BlocProvider.of<WorkspaceBloc>(context).add(CreateRemoveWorkspace(
                  id: widget.id != null ? widget.id! : 0,
                  defaultPrimary: widget.primaryWorkspace!));
              widget.onStatus(_currentStatus);
            } else {
              print("tryujikl waqedwa");
              _currentStatus = false;
            }
          }
        }
      },
    );
  }
}

class CustomVisibleSwitch extends StatefulWidget {
  final bool? status;
  final bool? visiblestatus;
  final bool? isPartial;
  final bool? idDefault;
  final Function(bool) onStatus;
  final int? id;
  final int? primaryWorkspace;

  const CustomVisibleSwitch(
      {super.key,
        this.status,
        this.isPartial,
        this.visiblestatus,
        this.idDefault,
        required this.onStatus,
        this.primaryWorkspace,
        this.id});

  @override
  State<CustomVisibleSwitch> createState() => _CustomVisibleSwitchState();
}

class _CustomVisibleSwitchState extends State<CustomVisibleSwitch> {
  bool? hasPermission;
  late bool _currentStatus;

  @override
  void initState() {
    print("ertfghuynjmk ${widget.visiblestatus}");
    _currentStatus = widget.visiblestatus!;
    if (widget.idDefault == true) {
      print("ertfghuynjmk ");
      print("tghjk rrr  ${widget.onStatus}");
      print("tghjk fbvfg ${widget.status}");
      _currentStatus = widget.status!;
      hasPermission = context.read<AuthBloc>().hasAllDataAccess;
      print("jkl,;. $hasPermission");
      print("jkl,;.sedrfer ew  ${widget.primaryWorkspace}");
      if (widget.primaryWorkspace != null) {
        if (widget.primaryWorkspace == 0) {
          _currentStatus = false;
        } else {
          _currentStatus = true;
        }
      }
    }
    super.initState();
  }

  setWorkspace(workspcaId) async {
    var box = await Hive.openBox(userBox);
    box.put('workspace_id', workspcaId);
    print("tgyhujikl workSpaceId ${box.get('workspace_id')}");
  }

  @override
  Widget build(BuildContext context) {
    print("rtyuik fduigfdgn $_currentStatus");
    print("tghjk ${widget.status}");
    return FlutterSwitch(
        height: 15.h,
        width: 30.w,
        padding: 2.w,
        toggleSize: 15.sp,
        borderRadius: 10.r,
        inactiveColor: AppColors.greyColor.withValues(alpha: 0.5),
        activeColor: AppColors.primary,
        value: _currentStatus,
        onToggle: (value) {
          _currentStatus = value;
          widget.onStatus(_currentStatus);
        }
      // },
    );
  }
}

class IsCustomSwitch extends StatefulWidget {
  final bool? status;
  final bool? isCreate;
  final Function(bool) onStatus;
  final int? id;

  const IsCustomSwitch(
      {super.key,
        this.status,
        this.isCreate,
        required this.onStatus,
        this.id});

  @override
  State<IsCustomSwitch> createState() =>
      _IsCustomSwitchState();
}

class _IsCustomSwitchState
    extends State<IsCustomSwitch> {
  late bool _currentStatus;

  @override
  void initState() {
    _currentStatus = widget.status!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterSwitch(
      height: 15.h,
      width: 30.w,
      padding: 2.w,
      toggleSize: 15.sp,
      borderRadius: 10.r,
      inactiveColor: AppColors.greyColor.withValues(alpha: 0.5),
      activeColor: AppColors.primary,
      value: _currentStatus,
      onToggle: (value) {
        _currentStatus = value;
        widget.onStatus(_currentStatus);
        if (widget.isCreate == false) {}
      },
    );
  }
}
