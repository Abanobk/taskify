import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/bloc/workspace/workspace_bloc.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/dashboard_stats/dash_board_stats_bloc.dart';
import '../../../bloc/dashboard_stats/dash_board_stats_event.dart';
import '../../../bloc/workspace/workspace_event.dart';
import '../../../bloc/workspace/workspace_state.dart';
import '../../../data/localStorage/hive.dart';
import '../../../data/model/workspace/workspace_model.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../routes/routes.dart';
import '../../../utils/widgets/checkbox_tile.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../dash_board/dashboard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class WorkSpaceDialog extends StatefulWidget {
  final List<WorkspaceModel> work;
  final bool? isDashboard;
  const WorkSpaceDialog({super.key, required this.work, this.isDashboard});

  @override
  State<WorkSpaceDialog> createState() => _WorkSpaceDialogState();
}

class _WorkSpaceDialogState extends State<WorkSpaceDialog> {

  int? userId;
  int? workId;
  String? workSpaceTitle;
  bool isLoading=true;
  String? _selectedTitle;
  Future<void> _handleCheckboxChanged(
      String title, bool value, int id, BuildContext context) async {
    setState(() {

      context
          .read<WorkspaceBloc>()
          .add(SelectedWokspce(id: id, title: title, isSelected: value));
      _selectedTitle = value ? title : null;

      debugPrint("$_selectedTitle");
      BlocProvider.of<WorkspaceBloc>(context).add(const WorkspaceList());
      BlocProvider.of<DashBoardStatsBloc>(context).add(StatsList());
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) =>
          const DashBoard(initialIndex: 0), // Navigate to index 1
        ),
      );
    });
  }

  _getWorkspace() async {

    var fetchedWorkId = await HiveStorage.getWorkspaceId();
    var fetchedWorkSpaceTitle = workSpaceTitle =await  HiveStorage.getWorkspaceTitle();

    // Update state only after data is fetched
    setState(() {
      workId = fetchedWorkId;
      workSpaceTitle = fetchedWorkSpaceTitle;
    });
    print("ferdjgflj $workId");


  }


  @override
  void initState() {
    _getUserID();
    super.initState();
    _getWorkspace();
  }

  Future<int?> _getUserID() async {
    userId = context.read<AuthBloc>().userId;
    return userId;
  }

  @override
  Widget build(BuildContext context) {

    return StatefulBuilder(builder:
        (BuildContext context, void Function(void Function()) setState) {
      return BlocConsumer<WorkspaceBloc, WorkspaceState>(
          listener: (context, state) {
            if (state is WorkspacePaginated) {

            }
          }, builder: (context, state) {
        if (state is WorkspacePaginated) {

          return Dialog(
            insetAnimationCurve: Curves.bounceInOut,
            insetPadding: EdgeInsets.only(
                left: widget.isDashboard == true ? 30.w : 65.w,
                top: widget.isDashboard == true ? 70.h : 0),
            alignment: Alignment.topLeft,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  bottomLeft: Radius.circular(50.0),
                  topRight:
                  Radius.circular(widget.isDashboard == true ? 50 : 0),
                  bottomRight:
                  Radius.circular(widget.isDashboard == true ? 50 : 0)),
            ),
            elevation: 10.0,
            backgroundColor: Theme.of(context).colorScheme.backGroundColor,
            child: Container(
              // height: 800.h,
              width: 300.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.backGroundColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: CustomText(
                        text: AppLocalizations.of(context)!.selectworkspace,
                        fontWeight: FontWeight.w800,
                        size: 20.sp,
                        color: Theme.of(context).colorScheme.whitepurpleChange,
                      ),
                    ),
                    Divider(
                        color: Theme.of(context).colorScheme.dividerClrChange),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight:650.h // Set the maximum height for the ListView
                      ),
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (scrollInfo) {
                          // Check if the user has scrolled to the end and load more Meeting if needed
                          if (!state.hasReachedMax && state.isLoading &&
                              scrollInfo.metrics.pixels ==
                                  scrollInfo.metrics.maxScrollExtent) {
                            context
                                .read<WorkspaceBloc>()
                                .add(LoadMoreWorkspace());
                          }
                          return false;
                        },
                        child: ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount:
                          state.workspace.length+1, // Show only the first 5 items
                          itemBuilder: (BuildContext context, int index) {
                            if (index < state.workspace.length) {
                              var workspace = state.workspace[ index];
                              print("sfhdjkfhn ${state.workspace.any((ws) => ws.id.toString() == workId)}");

                              bool isChecked = workspace.id == workId;
                              return  CustomCheckboxListTile(
                                title: workspace.title!,
                                isChecked: isChecked,
                                context: context,
                                id: workspace.id!,
                                onChanged: (String title, bool value, BuildContext ctx, int id) {
                                  _handleCheckboxChanged(title, value, id, ctx);
                                },
                              );

                            }
                            if(state.isLoading && !state.hasReachedMax ){
                              // Show a loading indicator when more Meeting are being loaded
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 0),
                                child: Center(
                                  child: state.hasReachedMax && state.isLoading
                                      ? const Text('')
                                      : const SpinKitFadingCircle(
                                    color: AppColors.primary,
                                    size: 40.0,
                                  ),
                                ),
                              );
                            }
                            return SizedBox();
                          },
                        ),
                      ),
                    ),
                    widget.isDashboard == true
                        ? SizedBox.shrink()
                        : Padding(
                      padding: EdgeInsets.only(left: 30.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 30.w),
                            child: const Divider(),
                          ),
                          SizedBox(height: 20.h),
                          InkWell(
                            highlightColor:
                            Colors.transparent, // No highlight on tap
                            splashColor: Colors.transparent,
                            onTap: () {
                              router.push("/workspaces");
                              Navigator.pop(context);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const HeroIcon(
                                  HeroIcons.chartPie,
                                  style: HeroIconStyle.outline,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 27.w),
                                Expanded( // This prevents overflow by making the text shrink if needed
                                  child: CustomText(
                                    text: AppLocalizations.of(context)!.manageworkspaces,
                                    color: Theme.of(context).colorScheme.textClrChange,
                                    overflow: TextOverflow.ellipsis, // Prevents overflow with "..."
                                  ),
                                ),
                                SizedBox(width: 15.w),
                                Container(
                                  height: 20,
                                  width: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red.shade300,
                                  ),
                                  child: Center(
                                    child: CustomText(
                                      size: 10,
                                      fontWeight: FontWeight.w600,
                                      text: "${context.read<WorkspaceBloc>().totalWorkspace ?? 0}",
                                      color: AppColors.pureWhiteColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          ),
                          SizedBox(height: 20.h),
                          InkWell(
                            highlightColor:
                            Colors.transparent, // No highlight on tap
                            splashColor: Colors.transparent,
                            onTap: () {
                              router.push("/workspaces");
                              Navigator.pop(context);
                              // BlocProvider.of<WorkspaceBloc>(context).add(AllWorkspaceList());
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const HeroIcon(
                                  HeroIcons.plus,
                                  style: HeroIconStyle.outline,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 27.w),
                                Expanded(
                                  child: CustomText(
                                    text: AppLocalizations.of(context)!
                                        .createworkspace,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                          InkWell(
                            highlightColor:
                            Colors.transparent, // No highlight on tap
                            splashColor: Colors.transparent,
                            onTap: () {
                              router.push("/workspaces");
                              Navigator.pop(context);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const HeroIcon(
                                  HeroIcons.documentCheck,
                                  style: HeroIconStyle.outline,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 27.w),
                                Expanded(child:  CustomText(
                                  text: AppLocalizations.of(context)!
                                      .editworkspace,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                ),)
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                          InkWell(
                            highlightColor:
                            Colors.transparent, // No highlight on tap
                            splashColor: Colors.transparent,
                            onTap: () {
                              BlocProvider.of<WorkspaceBloc>(context).add(
                                  RemoveUSerFromWorkspace(id: userId!));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const HeroIcon(
                                  HeroIcons.minusCircle,
                                  style: HeroIconStyle.outline,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 27.w),
                                Expanded(child:   CustomText(
                                  text: AppLocalizations.of(context)!
                                      .removemefromnworkspace,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                ),)
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Container();
      });
    });
  }
}