import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:taskify/bloc/project/project_state.dart';
import 'package:taskify/bloc/task/task_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/utils/widgets/custom_text.dart';
import 'package:taskify/utils/widgets/no_data.dart';
import 'package:taskify/utils/widgets/no_permission_screen.dart';
import 'package:taskify/utils/widgets/notes_shimmer_widget.dart';
import 'package:taskify/utils/widgets/row_dashboard.dart';
import 'package:taskify/utils/widgets/status_priority_row.dart';
import 'package:taskify/utils/widgets/custom_dimissible.dart';
import 'package:taskify/data/model/task/task_model.dart';
import 'package:taskify/routes/routes.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/bloc/task/task_bloc.dart';
import 'package:taskify/bloc/task/task_event.dart';
import 'package:taskify/bloc/project/project_bloc.dart';
import 'package:taskify/bloc/project/project_event.dart';
import 'package:taskify/bloc/permissions/permissions_bloc.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/utils/widgets/my_theme.dart';
import 'package:taskify/data/model/create_task_model.dart';
import 'package:taskify/utils/widgets/user_client_box.dart';
import 'package:taskify/utils/date_format.dart';

import '../../../data/model/Project/all_project.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../widgets/html_widget.dart';

class ProjectTasksPage extends StatefulWidget {
  final int clientId;
  final String currency;
  final bool showTabs;
  final int initialTab;

  const ProjectTasksPage({
    Key? key,
    required this.clientId,
    required this.currency,
    this.showTabs = true,
    this.initialTab = 0,
  }) : super(key: key);

  @override
  State<ProjectTasksPage> createState() => _ProjectTasksPageState();
}

class _ProjectTasksPageState extends State<ProjectTasksPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    _tabController.addListener(() {
      setState(() {});
    });
    
    // Load initial data
    BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask(clientId: [widget.clientId]));
    BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList(clientId: [widget.clientId]));
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
                      AppLocalizations.of(context)!.tasks,
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
                      AppLocalizations.of(context)!.projectwithCounce,
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
    return (context.read<PermissionsBloc>().isManageTask == true)
        ? BlocConsumer<TaskBloc, TaskState>(
            listener: (context, state) {
              if (state is TaskPaginated) {
                isLoadingMore = false;
                setState(() {});
              }
            },
            builder: (context, state) {
              if (state is TaskLoading) {
                return const NotesShimmer();
              } else if (state is TaskPaginated) {
                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo is ScrollStartNotification) {
                      FocusScope.of(context).unfocus();
                    }
                    if (!state.hasReachedMax &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      context.read<TaskBloc>().add(LoadMore(
                            clientId: [widget.clientId],
                          ));
                    }
                    return false;
                  },
                  child: state.task.isNotEmpty
                      ? ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: state.hasReachedMax
                              ? state.task.length
                              : state.task.length + 1,
                          itemBuilder: (context, index) {
                            if (index < state.task.length) {
                              Tasks task = state.task[index];
                              String? date;
                              if (task.createdAt != null) {
                                var dateCreated =
                                    parseDateStringFromApi(task.createdAt!);
                                date =
                                    dateFormatConfirmed(dateCreated, context);
                              }
                              return _buildTaskItem(task, date, state.task, index);
                            } else {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Center(
                                  child: state.hasReachedMax
                                      ? const Text('')
                                      : const SpinKitFadingCircle(
                                          color: AppColors.primary,
                                          size: 40.0,
                                        ),
                                ),
                              );
                            }
                          })
                      : NoData(
                          isImage: true,
                        ),
                );
              }
              return const Text("");
            },
          )
        : NoPermission();
  }

  Widget _buildProjectsTab() {
    return context.read<PermissionsBloc>().isManageProject == true
        ? BlocConsumer<ProjectBloc, ProjectState>(
            listener: (context, state) {
              if (state is ProjectPaginated) {
                isLoadingMore = false;
                setState(() {});
              }
            },
            builder: (context, state) {
              if (state is ProjectLoading) {
                return const NotesShimmer();
              } else if (state is ProjectPaginated) {
                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo is ScrollStartNotification) {
                      FocusScope.of(context).unfocus();
                    }
                    if (!state.hasReachedMax &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent &&
                        isLoadingMore == false) {
                      isLoadingMore = true;
                      setState(() {});
                      context
                          .read<ProjectBloc>()
                          .add(ProjectLoadMore("", [widget.clientId], []));
                    }
                    return false;
                  },
                  child: state.project.isNotEmpty
                      ? ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: state.hasReachedMax
                              ? state.project.length
                              : state.project.length + 1,
                          itemBuilder: (context, index) {
                            if (index < state.project.length) {
                              var project = state.project[index];
                              String? date;
                              if (project.startDate != null) {
                                date = formatDateFromApi(
                                    project.startDate!, context);
                              }
                              return _buildProjectItem(project, date, state.project, index);
                            } else {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 0),
                                child: Center(
                                  child: state.hasReachedMax
                                      ? const Text('')
                                      : const SpinKitFadingCircle(
                                          color: AppColors.primary,
                                          size: 40.0,
                                        ),
                                ),
                              );
                            }
                          })
                      : NoData(
                          isImage: true,
                        ),
                );
              } else if (state is ProjectError) {
                return Center(
                  child: Text(
                    state.errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              return Container();
            },
          )
        : const NoPermission();
  }

  Widget _buildTaskItem(Tasks task, String? date, List<Tasks> tasks, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: DismissibleCard(
        direction: context.read<PermissionsBloc>().isdeleteTask == true &&
                context.read<PermissionsBloc>().iseditTask == true
            ? DismissDirection.horizontal
            : context.read<PermissionsBloc>().isdeleteTask == true
                ? DismissDirection.endToStart
                : context.read<PermissionsBloc>().iseditTask == true
                    ? DismissDirection.startToEnd
                    : DismissDirection.none,
        title: task.id.toString(),
        confirmDismiss: (DismissDirection direction) async {
          if (direction == DismissDirection.endToStart) {
            return await _showDeleteConfirmationDialog(context,index,tasks,task.users![index].id);
          } else if (direction == DismissDirection.startToEnd) {
            _navigateToEditTask(task, tasks[index]);
            return false;
          }
          return false;
        },
        dismissWidget: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () => _navigateToTaskDetail(task),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: _buildCustomContainer(
              context: context,
              child: Column(
                children: [
                  _buildTaskHeader(task),
                  _buildTaskDescription(task),
                  _buildTaskStatusRow(task),
                  _buildTaskUsersAndClients(task),
                  _buildTaskDate(date),
                ],
              ),
            ),
          ),
        ),
        onDismissed: (DismissDirection direction) {
          if (direction == DismissDirection.endToStart &&
              context.read<PermissionsBloc>().isdeleteTask == true) {
            setState(() {
              tasks.removeAt(index);
              onDeleteTask(task.users![index].id);
            });
          }
        },
      ),
    );
  }

  Widget _buildProjectItem(project, String? date, stateProject, index) {
    return DismissibleCard(
      direction: context.read<PermissionsBloc>().isdeleteProject == true &&
              context.read<PermissionsBloc>().iseditProject == true
          ? DismissDirection.horizontal
          : context.read<PermissionsBloc>().isdeleteProject == true
              ? DismissDirection.endToStart
              : context.read<PermissionsBloc>().iseditProject == true
                  ? DismissDirection.startToEnd
                  : DismissDirection.none,
      title: stateProject[index].id.toString(),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (context.read<PermissionsBloc>().iseditProject == true) {
            _navigateToEditProject(project);
            return false;
          }
          return false;
        }

        if (direction == DismissDirection.endToStart) {
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
                  stateProject.removeAt(index);

                });
                _onDeleteProject(id: stateProject[index].id);
              });
              // Return false to prevent the dismissible from animating
              return false;
            }

            return false; // Always return false since we handle deletion manually
          } catch (e) {
            print("Error in dialog: $e");
            return false;
          }
        }

        return false;
      },
      onDismissed: (DismissDirection direction) {
        if (direction == DismissDirection.endToStart &&
            context.read<PermissionsBloc>().isdeleteProject == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {   setState(() {
            stateProject.removeAt(index);
          });
          _onDeleteProject(id: stateProject[index].id);

          });
        }
      },
      dismissWidget: Padding(
        padding: EdgeInsets.symmetric( horizontal: 18.w),
        child: InkWell(
          onTap: () => _navigateToProjectDetail(stateProject[index].id),
          child: _buildCustomContainer(
            context: context,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProjectHeader(project),
                  _buildProjectTitleAndBudget(project),
                  _buildProjectDescription(project),
                  _buildProjectStatusRow(project),
                  _buildProjectUsersAndClients(project),
                  _buildProjectDate(date),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Task related widgets
  Widget _buildTaskHeader(Tasks task) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h, left: 20.h, right: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: "#${task.id.toString()}",
                size: 14.sp,
                color: Theme.of(context).colorScheme.textClrChange,
                fontWeight: FontWeight.w700,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                width: 280.w,
                child: CustomText(
                  text: task.title!,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  size: 24.sp,
                  color: Theme.of(context).colorScheme.textClrChange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDescription(Tasks task) {
    return Column(
      children: [
        if (task.description != null) SizedBox(height: 8.h),
        if (task.description != null)
          ExpandableHtmlNoteWidget(text: task.description!, context: context),
      ],
    );
  }

  Widget _buildTaskStatusRow(Tasks task) {
    return SizedBox(
      width: 300.w,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0.h),
        child: statusClientRow(task.status, task.priority, context, false),
      ),
    );
  }

  Widget _buildTaskUsersAndClients(Tasks task) {
    final users = task.users ?? [];
    final clients = task.clients ?? [];

    return task.users!.isEmpty && task.clients!.isEmpty
        ? SizedBox.shrink()
        : Padding(
            padding: EdgeInsets.only(top: 10.h, left: 18.w, right: 18.w),
            child: SizedBox(
              height: 60.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _showUserClientDialog(
                        context: context,
                        from: "user",
                        title: AppLocalizations.of(context)!.allusers,
                        list: users,
                      ),
                      child: RowDashboard(list: users, title: "user"),
                    ),
                  ),
                  if (users.isNotEmpty) SizedBox(width: 40.w),
                  if (clients.isNotEmpty)
                    Expanded(
                      child: InkWell(
                        onTap: () => _showUserClientDialog(
                          context: context,
                          from: 'client',
                          title: AppLocalizations.of(context)!.allclients,
                          list: clients,
                        ),
                        child: RowDashboard(list: clients, title: "client"),
                      ),
                    ),
                ],
              ),
            ),
          );
  }

  Widget _buildTaskDate(String? date) {
    return date != null
        ? Padding(
            padding: EdgeInsets.only(bottom: 10.h, left: 20.h, right: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const HeroIcon(
                      HeroIcons.calendar,
                      style: HeroIconStyle.solid,
                      color: AppColors.blueColor,
                    ),
                    SizedBox(width: 20.w),
                    CustomText(
                      text: date,
                      color: AppColors.greyColor,
                      size: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ],
            ),
          )
        : SizedBox.shrink();
  }

  // Project related widgets
  Widget _buildProjectHeader(project) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: "#${project.id.toString()}",
          size: 14.sp,
          color: Theme.of(context).colorScheme.textClrChange,
          fontWeight: FontWeight.w700,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Row(
          children: [
            HeroIcon(
              HeroIcons.clipboardDocumentList,
              style: HeroIconStyle.outline,
              color: AppColors.primary,
            ),
            project.taskCount > 1
                ? CustomText(
                    text: " ${project.taskCount.toString()} ${AppLocalizations.of(context)!.tasksFromDrawer}",
                    size: 14.sp,
                    color: Theme.of(context).colorScheme.textClrChange,
                    fontWeight: FontWeight.w700,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : CustomText(
                    text: " ${project.taskCount.toString()} ${AppLocalizations.of(context)!.task}",
                    size: 14.sp,
                    color: Theme.of(context).colorScheme.textClrChange,
                    fontWeight: FontWeight.w700,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ],
        ),
      ],
    );
  }

  Widget _buildProjectTitleAndBudget(project) {
    return Padding(
      padding: EdgeInsets.only(top: 0.h),
      child: SizedBox(
        width: 300.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              width: 200.w,
              height: 40.h,
              child: CustomText(
                text: project.title!,
                size: 24,
                color: Theme.of(context).colorScheme.textClrChange,
                fontWeight: FontWeight.w700,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            project.budget!.isNotEmpty
                ? Container(
                    alignment: Alignment.centerRight,
                    height: 40.h,
                    child: CustomText(
                      text: "${widget.currency != "" ? "${widget.currency}" : ""}${project.budget}",
                      size: 14,
                      color: Theme.of(context).colorScheme.textClrChange,
                      fontWeight: FontWeight.w700,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectDescription(project) {
    return Column(
      children: [
        if (project.description != null && project.description != "")
          SizedBox(height: 5.h),
        if (project.description != null && project.description != "")
          htmlWidget(project.description!, context, width: 290.w, height: 36.h)
        else
          Container(height: 0.h),
      ],
    );
  }

  Widget _buildProjectStatusRow(project) {
    return SizedBox(
      width: 300.w,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0.h),
        child: statusClientRow(project.status, project.priority, context, false),
      ),
    );
  }

  Widget _buildProjectUsersAndClients(project) {
    final users = project.users ?? [];
    final clients = project.clients ?? [];

    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: SizedBox(
        height: 60.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _showUserClientDialog(
                  context: context,
                  from: "user",
                  title: AppLocalizations.of(context)!.allusers,
                  list: users,
                ),
                child: RowDashboard(list: users, title: "user"),
              ),
            ),
            if (users.isNotEmpty) SizedBox(width: 40.w),
            Expanded(
              child: InkWell(
                onTap: () => _showUserClientDialog(
                  context: context,
                  from: "client",
                  title: AppLocalizations.of(context)!.allclients,
                  list: clients,
                ),
                child: RowDashboard(list: clients, title: "client"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectDate(String? date) {
    return date != null
        ? Padding(
            padding: EdgeInsets.only(top: 5.h),
            child: Row(
              children: [
                SizedBox(
                  width: 15.w,
                  child: const HeroIcon(
                    HeroIcons.calendar,
                    style: HeroIconStyle.outline,
                  ),
                ),
                SizedBox(width: 5.w),
                CustomText(
                  text: date,
                  size: 12.26,
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).colorScheme.textClrChange,
                ),
              ],
            ),
          )
        : SizedBox.shrink();
  }

  // Navigation and dialog methods
  void _navigateToEditTask(Tasks task, dynamic statetask) {
    List<String> username = [];
    for (var names in task.users!) {
      username.add(names.firstName!);
    }
    List<int>? ids = [];
    for (var i in task.users!) {
      ids.add(i.id!);
    }

    router.push(
      '/createtask',
      extra: {
        "id": task.id,
        "isCreate": false,
        "title": task.title,
        "users": username,
        "desc": task.description,
        "start": task.startDate,
        "end": task.dueDate,
        'priority': task.priority,
        'priorityId': task.priorityId,
        "usersid": ids,
        'statusId': task.statusId,
        'note': task.note,
        'project': task.project,
        "userList": task.users,
        "tasks": statetask,
        'projectId': task.projectId,
        'status': task.status,
        'tasksModel': Tasks.empty(),
        'req': <CreateTaskModel>[],
      },
    );
    BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask());
  }

  void _navigateToTaskDetail(Tasks task) {
    router.push(
      '/taskdetail',
      extra: {
        "id": task.id,
      },
    );
  }

  void _navigateToEditProject(project) {
    List<String>? userList = [];
    List<String>? clientList = [];
    List<String>? tagList = [];

    if (project.users != null) {
      for (var user in project.users!) {
        userList.add(user.firstName!);
      }
    }
    if (project.clients != null) {
      for (var client in project.clients!) {
        clientList.add(client.firstName!);
      }
    }

    if (project.tags != null) {
      for (var tag in project.tags!) {
        tagList.add(tag.title!);
      }
    }

    router.push(
      '/createproject',
      extra: {
        "id": project.id,
        "isCreate": false,
        "title": project.title,
        "desc": project.description,
        "start": project.startDate ?? "",
        "end": project.endDate ?? "",
        "budget": project.budget,
        'priority': project.priority,
        'priorityId': project.priorityId,
        'statusId': project.statusId,
        'note': project.note,
        "clientNames": clientList,
        "userNames": userList,
        "tagNames": tagList,
        "userId": project.userId,
        "tagId": project.tagIds,
        "clientId": project.clientId,
        "access": project.taskAccessibility,
        'status': project.status,
      },
    );
  }

  void _navigateToProjectDetail(int id) {
    router.push('/projectdetails', extra: {
      "id": id,
      "projectModel":ProjectModel.empty()

    });
  }

  void _showUserClientDialog({
    required BuildContext context,
    required String from,
    required String title,
    required List<dynamic> list,
  }) {
    userClientDialog(
      context: context,
      from: from,
      title: title,
      list: list,
    );
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

  void _onDeleteProject({required int id}) {
    final setting = context.read<ProjectBloc>();
    BlocProvider.of<ProjectBloc>(context).add(DeleteProject(id));
    setting.stream.listen((state) {
      if (state is ProjectDeleteSuccess) {
        if (mounted) {
          BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is ProjectDeleteError) {
        if (mounted) {
          BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
        }
      }
    });
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context,index,tasks,userList) async {
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
            tasks.removeAt(index);

          });
          onDeleteTask(userList);
        });
        // Return false to prevent the dismissible from animating
        return false;
      }

      return false; // Always return false since we handle deletion manually
    } catch (e) {
      print("Error in dialog: $e");
      return false;
    }
  }

  Widget _buildCustomContainer({
    required BuildContext context,
    required Widget child,
    double? width,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          Theme.of(context).brightness == Brightness.light
              ? MyThemes.lightThemeShadow
              : MyThemes.darkThemeShadow,
        ],
        color: Theme.of(context).colorScheme.containerDark,
        borderRadius: BorderRadius.circular(12),
      ),
      width: width ?? double.infinity,
      child: child,
    );
  }
} 