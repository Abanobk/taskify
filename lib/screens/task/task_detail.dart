import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/screens/widgets/custom_container.dart';

import 'package:taskify/utils/widgets/back_arrow.dart';
import 'package:taskify/utils/widgets/status_priority_row.dart';


import '../../bloc/comments/comments_bloc.dart';


import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/task/task_state.dart';
import '../../bloc/task_id/taskid_bloc.dart';
import '../../bloc/task_id/taskid_event.dart';
import '../../bloc/task_id/taskid_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../config/constants.dart';
import '../../data/model/Project/all_project.dart';
import '../../data/model/create_task_model.dart';
import '../../data/model/task/task_model.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_text.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/toast_widget.dart';
import '../../utils/widgets/user_client_row_detail_page.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

import '../dash_board/dashboard.dart';
import '../notes/widgets/notes_shimmer_widget.dart';
import '../widgets/detail_page_menu.dart';
import '../widgets/html_widget.dart';
import '../widgets/side_bar.dart';
import '../widgets/user_client_box.dart';
import 'custom_fields_tasks/custom_field_task_page.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class TaskDetailScreen extends StatefulWidget {
  final bool? fromNoti;
  final String? from;
  final int? id;
  const TaskDetailScreen({
    super.key,
    this.fromNoti,
    this.from,
    this.id,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  DateTime selectedDateStarts = DateTime.now();
  DateTime selectedDateEnds = DateTime.now();

  String selectedCategory = '';
  final _key = GlobalKey<ExpandableFabState>();
  final GlobalKey<CustomFieldTaskPageState> _customFieldTaskPageKey = GlobalKey<CustomFieldTaskPageState>(); // Add GlobalKey

  List<Tasks> task = [];
  List<String> username = [];

  int? id;
  int? workspaceId;
  String? title;
  Tasks? taskModel;
  String? status;
  int? statusId;
  String? priority;
  int? priorityId;
  List<TaskUsers>? users;
  List<int>? userId;
  List<TaskClients>? clients;
  String? startDate;
  String? dueDate;
  String? project;
  int? projectId;
  int? canClientDiscuss;
  String? description;
  String? frequencyType;
  String? timeOfDay;
  int? isReminderEnabled;
  int? isRecurrenceTaskEnabled;
  int? dayOfWeek;
  int? dayOfMonth;
  String? recurenceFrequency;
  int? recDayOfWeek;
  int? recDayOfMonth;
  int? recMonthOfYear;
  String? recStartsFrom;
  int? recOcurrences;
  int? completedOcurrences;
  String? note;
  String? createdAt;
  String? updatedAt;
  String dateCreated = '';
  String dateUpdated = '';
  String dateStart = '';
  String dateEnd = '';
  Tasks? model;

  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);

  @override
  void initState() {
    BlocProvider.of<TaskidBloc>(context).add(TaskIdListId(widget.id));
    super.initState();
  }

  void _onDeleteTask(taskId) {
    final setting = context.read<TaskBloc>();
    BlocProvider.of<TaskBloc>(context).add(DeleteTask(taskId));
    setting.stream.listen((state) {
      if (state is TaskDeleteSuccess) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(
              builder: (context) => const DashBoard(initialIndex: 2),
            ),
            (route) {
              return route is! CupertinoPageRoute ||
                  route.settings.name != 'taskdetail';
            },
          );

          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is TaskDeleteError) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(
              builder: (context) => const DashBoard(initialIndex: 2),
            ),
                (route) {
              return route is! CupertinoPageRoute ||
                  route.settings.name != 'taskdetail';
            },
          );
          flutterToastCustom(msg: state.errorMessage);
        }
      }
      if (state is TaskError) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(
              builder: (context) => const DashBoard(initialIndex: 2),
            ),
                (route) {
              return route is! CupertinoPageRoute ||
                  route.settings.name != 'taskdetail';
            },
          );
          flutterToastCustom(msg: state.errorMessage);
        }
      }
    });
  }

  Future<void> _onRefresh() async {
    BlocProvider.of<TaskidBloc>(context).add(TaskIdListId(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        BlocProvider.of<TaskidBloc>(context).add(TaskIdListId(widget.id));
        if (!didPop) {
          router.pop();
        }
      },
      child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.backGroundColor,
          floatingActionButtonLocation: ExpandableFab.location,
          floatingActionButton:
              context.read<PermissionsBloc>().isdeleteTask == true ||
                      context.read<PermissionsBloc>().iseditTask == true
                  ? detailMenu(

                  onpressChat: () {
                    _key.currentState?.toggle();
                    router.push(
                      "/commentsection",
                      extra: { "id": widget.id,"title":title,"isProject":false},
                    );
                    context.read<CommentsBloc>().isProject = false;
                  },
                  isChat:  canClientDiscuss==1,


                  isDiscuss:canClientDiscuss==1,
                     isEdit:  context.read<PermissionsBloc>().iseditTask,
                     isDelete:  context.read<PermissionsBloc>().isdeleteTask,
                      key: _key,
                      context: context,
                      onpressEdit: () {
                      _key.currentState?.toggle();
                      List<String> username = [];
                      for (var names in users!) {
                        username.add(names.firstName!);
                      }
                      List<int>? ids = [];
                      for (var i in users!) {
                        ids.add(i.id!);
                      }
                      router.push(
                        '/createtask',
                        extra: {
                          "id": widget.id,
                          "isCreate": false,
                          "fromDetail": true,
                          "title": title,
                          "users": username,
                          "desc": description,
                          "start": startDate,
                          "end": dueDate,
                          // "user":task.users,
                          'priority': priority,
                          // or true, depending on your needs
                          'priorityId': priorityId,
                          "usersid": ids,
                          // or true, depending on your needs
                          'statusId': statusId,
                          // or true, depending on your needs
                          'note': note,
                          // or true, depending on your needs
                          'project': project,
                          "userList": users,
                          "tasksModel":Tasks.empty(),
                          // "users": username,
                          // or true, depending on your needs
                          'projectId': projectId,
                          // or true, depending on your needs
                          'status': status,
                          // or true, depending on your needs
                          'req': <CreateTaskModel>[],
                          // your list of LeaveRequests
                        },
                      );
                      // Navigator.pop(context);
                    },
                  onpressDelete:  () {
                      showDialog(
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
                            title: Text(
                              AppLocalizations.of(context)!.confirmDelete,
                            ),
                            content: Text(
                              AppLocalizations.of(context)!.areyousure,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  _onDeleteTask(widget.id);
                                },
                                child: const Text('Delete'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(false); // Cancel deletion
                                },
                                child: const Text('Cancel'),
                              ),
                            ],
                          );
                        },
                      );
                    },
              onpressdiscuss: (){
                _key.currentState?.toggle();
                router.push(
                  "/taskdiscussionTabs",
                  extra: {"isDetail": true, "id": widget.id},
                );
              })
                  : SizedBox.shrink(),
          body: SideBar(
              context: context,
              controller: sideBarController,
              underWidget: RefreshIndicator(
                  color: AppColors.primary, // Spinner color
                  backgroundColor:
                      Theme.of(context).colorScheme.backGroundColor,
                  onRefresh: _onRefresh,
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.w),
                      child: SingleChildScrollView(
                        physics:
                            const AlwaysScrollableScrollPhysics(), // Ensure always scrollable

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                              child: _appbar(isLightTheme),
                            ),
                            // SizedBox(height: 30.h),
                            const SizedBox(
                              height: 20,
                            ),
                            BlocConsumer<TaskidBloc, TaskidState>(
                                listener: (context, state) {
                              if (state is TaskidWithId) {
                                dateCreated = '';
                                dateUpdated = '';
                                dateStart = '';
                                dateEnd = '';
                                for (var item in state.task) {
                                   model = Tasks(
                                    title: item.title,
                                    status: item.status,
                                    statusId: item.statusId,
                                    priority: item.priority,
                                    priorityId: item.priorityId,
                                    description: item.description,
                                    note: item.note,
                                    startDate: item.startDate,
                                    dueDate: item.dueDate,
                                    createdAt: item.createdAt,
                                    updatedAt: item.updatedAt,
                                    users: item.users,
clientCanDiscuss: item.clientCanDiscuss,
                                    userId: item.userId,
                                    clients: item.clients,
                                    projectId: item.projectId,
                                    project: item.project,
                                     customFieldValues: item.customFieldValues,
                                     customFields: item.customFields
                                  );

                                  title = item.title;
                                  status = item.status;
                                  priority = item.priority;
                                  users = item.users;
                                  clients = item.clients;
                                  project = item.project;
                                  startDate = item.startDate;
                                  dueDate = item.dueDate;
                                  description = item.description;
                                  note = item.note;
                                  createdAt = item.createdAt;
                                  updatedAt = item.updatedAt;
                                   taskModel = item;
                                  priorityId = item.priorityId;
                                  userId = item.userId;
                                  users = item.users;
                                  statusId = item.statusId;
                                  projectId = item.projectId;

                                  if (createdAt != null) {
                                    dateCreated =
                                        formatDateFromApi(createdAt!, context);
                                  }
                                  if (createdAt != null) {
                                    dateUpdated =
                                        formatDateFromApi(createdAt!, context);
                                  }
                                  if (startDate != null) {
                                    dateStart =
                                        formatDateFromApi(startDate!, context);
                                  }
                                  if (dueDate != null) {
                                    dateEnd =
                                        formatDateFromApi(dueDate!, context);
                                  }

                                  // clientIds = item.c;
                                }
                              }
                            }, builder: (context, state) {
                              if (state is TaskidWithId) {
                                dateCreated = '';
                                dateUpdated = '';
                                dateStart = '';
                                dateEnd = '';
                                for (var item in state.task) {
                                  title = item.title;
                                  status = item.status;
                                  priority = item.priority;
                                  users = item.users;
                                  clients = item.clients;
                                  project = item.project;
                                  startDate = item.startDate;
                                  dueDate = item.dueDate;
                                  description = item.description;
                                  note = item.note;
                                  createdAt = item.createdAt;
                                  updatedAt = item.updatedAt;
                                  priorityId = item.priorityId;
                                  userId = item.userId;
                                  users = item.users;
                                  statusId = item.statusId;
                                  projectId = item.projectId;
                                  frequencyType = item.frequencyType;
                                  timeOfDay = item.timeOfDay;
                                  isReminderEnabled = item.enableReminder;
                                  isRecurrenceTaskEnabled = item.enableRecurringTask;
                                  dayOfWeek = item.dayOfWeek;
                                  dayOfMonth = item.dayOfMonth;
                                  canClientDiscuss=item.clientCanDiscuss;
                                  taskModel = item;
                                  recurenceFrequency=item.recurrenceFrequency;
                                  recDayOfWeek= item.recurrenceDayOfWeek;
                                  recDayOfMonth= item.recurrenceDayOfMonth;
                                  recMonthOfYear=item.recurrenceMonthOfYear;
                                  recStartsFrom=item.recurrenceStartsFrom;
                                  recOcurrences=item.recurrenceOccurrences;
                                  completedOcurrences=item.completedOccurrences;


                                  if (createdAt != null) {
                                    dateCreated =
                                        formatDateFromApi(createdAt!, context);
                                  }
                                  if (updatedAt != null) {
                                    dateUpdated =
                                        formatDateFromApi(createdAt!, context);
                                  }
                                  if (startDate != null) {
                                    dateStart =
                                        formatDateFromApi(startDate!, context);
                                  }
                                  if (dueDate != null) {
                                    dateEnd =
                                        formatDateFromApi(dueDate!, context);
                                  }

                                  // clientIds = item.c;
                                }

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18.w),
                                      child: _taskCard(),
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18.w),
                                      child: _dateCard(dateStart, dateEnd,
                                          dateCreated, dateUpdated),
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    isReminderEnabled == 1 ?  _reminderDetails(frequencyType,dayOfWeek,dayOfMonth,timeOfDay,dateCreated,dateUpdated,):SizedBox(),
                                    isReminderEnabled == 1 ? SizedBox(
                                      height: 20.h,
                                    ):SizedBox(),
                                    isRecurrenceTaskEnabled== 1 ?    _recurrenceDetails(
                                        recurenceFrequency,recDayOfWeek,recDayOfMonth,recMonthOfYear,recStartsFrom,createdAt,updatedAt,recOcurrences,completedOcurrences
                                    ):SizedBox(),
                                    isRecurrenceTaskEnabled== 1 ?  SizedBox(
                                      height: 20.h,
                                    ):SizedBox(),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18.w),
                                      child: _project(),
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    note != null
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 18.w),
                                            child: _noteCard(),
                                          )
                                        : SizedBox(),
                                    note != null
                                        ? SizedBox(
                                            height: 20.h,
                                          )
                                        : SizedBox(),
                                    users != null && users!.isNotEmpty
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 18.w),
                                            child: _usersCard(),
                                          )
                                        : SizedBox.shrink(),
                                    clients != null && clients!.isNotEmpty
                                        ? SizedBox(
                                      height: 20.h,
                                    )
                                        : SizedBox(),
                                    clients != null && clients!.isNotEmpty
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 18.w),
                                            child: _clientsCard(),
                                          )
                                        : SizedBox.shrink(),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    Divider(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .dividerClrChange),
                                    SizedBox(
                                      height: 15.h,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                                      child: CustomText(
                                        text: AppLocalizations.of(context)!.customfields,
                                        color: Theme.of(context).colorScheme.textClrChange,
                                        size: 18.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15.h,
                                    ),
                                    CustomFieldTaskPage(tasksModel:  model??Tasks.empty(), key: _customFieldTaskPageKey, isCreate:false,isDetails: true,),

                                    SizedBox(
                                      height: 60.h,
                                    ),
                                  ],
                                );
                              }
                              if (state is TaskLoading) {
                                return Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 18.w),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      shimmerDetails(
                                          isLightTheme, context, 150.h),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      shimmerDetails(
                                          isLightTheme, context, 150.h),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      shimmerDetails(
                                          isLightTheme, context, 50.h),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      shimmerDetails(
                                          isLightTheme, context, 120.h),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      shimmerDetails(
                                          isLightTheme, context, 120.h),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18.w),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    shimmerDetails(
                                        isLightTheme, context, 150.h),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    shimmerDetails(
                                        isLightTheme, context, 150.h),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    shimmerDetails(isLightTheme, context, 50.h),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    shimmerDetails(
                                        isLightTheme, context, 120.h),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    shimmerDetails(
                                        isLightTheme, context, 120.h),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ))))),
    );
  }

  Widget _appbar(isLightTheme) {
    return Container(
        decoration: BoxDecoration(boxShadow: [
          isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
        ]),
        // color: Colors.red,
        // width: 300.w,
        child: BackArrow(
          onTap: (){
            if(widget.from == "subtask") {
              BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask(id: widget.id));
              router.pop();
            }else if(widget.from == "dashboard"){
              BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask());
              router.pop();
            }else {router.pop();}
          },
          isAdd: false,
          isDetailPage: true,
          isEditFromDetail: context.read<PermissionsBloc>().iseditTask,
          isDeleteFromDetail: context.read<PermissionsBloc>().isdeleteTask,
          isEditCreate: true,
          fromNoti: "task",
          title: AppLocalizations.of(context)!.taskdetail,
        ));
  }

  Widget _taskCard() {
    return customContainer(
      width: double.infinity,
      context: context,
      addWidget: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomText(
              text: title ?? "",
              fontWeight: FontWeight.w700,
              size: 24,
              color: Theme.of(context).colorScheme.textClrChange,
            ),
            SizedBox(
              height: 10.h,
            ),
            ExpandableHtmlNoteWidget(
              text:description ?? "",
             context: context,
              width: 290.w,
            ),
            SizedBox(
              height: 10.h,
            ),
            SizedBox(
                // color: Colors.red,
                // width: 240.w,
                child: statusClientRow(status, priority, context, true)),
          ],
        ),
      ),
    );
  }

  Widget _dateCard(dateStart, dateEnd, dateCreated, dateUpdated) {
    return customContainer(
        width: double.infinity,
        context: context,
        addWidget: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
          child: Column(
            children: [
              startDate != null && startDate!.isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "${AppLocalizations.of(context)!.startdate} : ",
                          size: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                        CustomText(
                          text: dateStart,
                          size: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.textClrChange,
                        )
                      ],
                    )
                  : const SizedBox.shrink(),
              startDate != null && startDate!.isNotEmpty
                  ? SizedBox(
                      height: 10.h,
                    )
                  : SizedBox.shrink(),
              dueDate != null && dueDate!.isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "${AppLocalizations.of(context)!.duedate} :",
                          size: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                        CustomText(
                          text: " $dateEnd",
                          size: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.textClrChange,
                        )
                      ],
                    )
                  : const SizedBox.shrink(),
              dueDate != null && dueDate!.isNotEmpty
                  ? SizedBox(
                      height: 10.h,
                    )
                  : SizedBox(),
              createdAt != null && createdAt!.isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "${AppLocalizations.of(context)!.createdat} : ",
                          size: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                        CustomText(
                          text: dateCreated,
                          size: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.textClrChange,
                        )
                      ],
                    )
                  : const SizedBox.shrink(),
              SizedBox(
                height: 10.h,
              ),
              updatedAt != null && updatedAt!.isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "${AppLocalizations.of(context)!.updatedAt} :",
                          size: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                        CustomText(
                          text: " $dateUpdated",
                          size: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.textClrChange,
                        )
                      ],
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ));
  }

  Widget _reminderDetails(frequencyType,dayOfWeek,dayOfMonthtime,time,dateCreated,dateUpdated){
    String update =  formatDateFromApi(updatedAt!, context);
    String create =  formatDateFromApi(createdAt!, context);
    return   Padding(
      padding:  EdgeInsets.symmetric(horizontal:18.w),
      child: customContainer(
        width: 600.w,
        context: context,
        addWidget: Padding(
          padding: EdgeInsets
              .symmetric(
              horizontal:
              10.w,
              vertical:
              10.h),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment
                .start,
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [
              Row(
                children: [

                  CustomText(
                    text: AppLocalizations.of(
                        context)!
                        .remindersdetails,
                    // text: getTranslated(context, 'myweeklyTask'),
                    color: Theme.of(
                        context)
                        .colorScheme
                        .textClrChange,
                    size: 15,
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
              _buildFrequencyDetail(time,dayOfWeek,dayOfMonthtime,),
              SizedBox(
                height: 8.h,
              ),
              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,

                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _details(
                      color: AppColors.blueColor,
                      icon:  HeroIcons.calendar,
                      label: AppLocalizations.of(context)!
                          .lastupdated,
                      title: update ),
                  _details(
                      color: AppColors.blueColor,
                      icon:  HeroIcons.calendar,
                      label: AppLocalizations.of(context)!
                          .createdon,
                      title: create ),


                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildFrequencyDetail(time,dayOfWeekRecurring,dayOfMonthRecurring) {
    String name="";
    String month="";
    DateTime dateTime = DateFormat("HH:mm:ss").parse(time);
    String time12 = DateFormat("hh:mm a").format(dateTime);

   // Output: 02:11 PM
    switch (dayOfMonthRecurring) {
      case 0:
      case null:
      month = "Any Day"; // Default value
        break;
      case "any day":
        month = "Any Day";
        break;
      case 1:
        month = "January";
        break;
      case 2:
        month = "February";
        break;
      case 3:
        month = "March";
        break;
      case 4:
        month = "April";
        break;
      case 5:
        month = "May";
        break;
      case 6:
        month = "June";
        break;
      case 7:
        month = "July";
        break;
      case 8:
        month = "August";
        break;
      case 9:
        month = "September";
        break;
      case 10:
        month = "October";
        break;
      case 11:
        month = "November";
        break;
      case 12:
        month = "December";
        break;
      default:
        month = "Any Day"; // Fallback
        break;
    }

    switch (dayOfWeekRecurring) {

      case 0:
      case null:
      name = "Any Day"; // Default value
        break;
      case 1:
        name = "Any Day";
        break;
      case 2:
        name = "Monday";
        break;
      case 3:
        name = "Tuesday";
        break;
      case 4:
        name = "Wednesday";
        break;
      case 5:
        name = "Thursday";
        break;
      case 6:
        name = "Friday";
        break;
      case 7:
        name = "Saturday";
        break;
      case 8:
        name = "Sunday";
        break;
      default:
        name = "Any Day"; // Fallback
        break;
    }
    switch (frequencyType) {
      case "daily":
        return _details(
          iswidth : true,
          icon: HeroIcons.calendar,
          color: AppColors.greyColor,
          label: AppLocalizations.of(context)!.frequency,
          title: "DAILY at $time12",
        );
      case "weekly":
        return _details( iswidth : true,

          icon: HeroIcons.calendar,
          color: AppColors.greyColor,
          label: AppLocalizations.of(context)!.frequency,
          title: "WEEKLY on $name at $time12",
        );
      case "monthly":
        return _details(
          icon: HeroIcons.calendar,
          color: AppColors.greyColor,
          label: AppLocalizations.of(context)!.frequency,
          title: "MONTHLY on $month at $time12",
        );
      default:
        return const SizedBox.shrink(); // returns empty widget
    }
  }

  Widget _recurrenceDetails(recurenceFrequency,recDayOfWeek,recDayOfMonth,recMonthOfYear,
      recStartsFrom,created,updated,recOcurrences,completedOcurrences){
    String month="";
    String name="";
   if(recDayOfWeek != null){ recDayOfWeek = recDayOfWeek +1;}
  String createdOn =  formatDateFromApi(created!, context);
  String startsFrom =  formatDateFromApi(recStartsFrom!, context);
  String updatedOn =  formatDateFromApi(updated!, context);
    switch (recDayOfMonth) {
      case 0:
      case "":
        month = "Any Day"; // Default value
        break;
      case "any day":
        month = "Any Day";
        break;
      case 1:
        month = "January";
        break;
      case 2:
        month = "February";
        break;
      case 3:
        month = "March";
        break;
      case 4:
        month = "April";
        break;
      case 5:
        month = "May";
        break;
      case 6:
        month = "June";
        break;
      case 7:
        month = "July";
        break;
      case 8:
        month = "August";
        break;
      case 9:
        month = "September";
        break;
      case 10:
        month = "October";
        break;
      case 11:
        month = "November";
        break;
      case 12:
        month = "December";
        break;
      default:
        month = "Any Day"; // Fallback
        break;
    }
    switch (recDayOfWeek) {

      case 0:
      case null:
        name = "Any Day"; // Default value
        break;
      case 1:
        name = "Any Day";
        break;
      case 2:
        name = "Monday";
        break;
      case 3:
        name = "Tuesday";
        break;
      case 4:
        name = "Wednesday";
        break;
      case 5:
        name = "Thursday";
        break;
      case 6:
        name = "Friday";
        break;
      case 7:
        name = "Saturday";
        break;
      case 8:
        name = "Sunday";
        break;
      default:
        name = "Any Day"; // Fallback
        break;
    }
    print(month);
    return   Padding(
      padding:  EdgeInsets.symmetric(horizontal:18.w),
      child: customContainer(
        width: 600.w,
        context: context,
        addWidget: Padding(
          padding: EdgeInsets
              .symmetric(
              horizontal:
              10.w,
              vertical:
              10.h),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment
                .start,
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [
              Row(
                children: [

                  CustomText(
                    text: AppLocalizations.of(
                        context)!
                        .recurrencedetails,
                    // text: getTranslated(context, 'myweeklyTask'),
                    color: Theme.of(
                        context)
                        .colorScheme
                        .textClrChange,
                    size: 15,
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,

                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _details(
                    icon:  HeroIcons.calendar,
                      color: AppColors.greyColor,
                      label: AppLocalizations.of(context)!
                          .frequency,
                      title: " $recurenceFrequency on $name"
                          ""),
                  SizedBox(
                    width:
                    30.w,
                  ),
                  _details(
                      color: AppColors.red,
                      icon:  HeroIcons.calendarDateRange,
                      label: AppLocalizations.of(context)!
                          .createdon,
                      title:createdOn ),
                ],
              ),
              SizedBox(
                height: 8.h,
              ),
              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,

                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _details(
                      color: AppColors.blueColor,
                      icon:  HeroIcons.clock,
                      label: AppLocalizations.of(context)!
                          .startsfrom,
                      title: startsFrom),
                  _details(
                      color: AppColors.orangeYellowishColor,
                      icon:  HeroIcons.calendarDays,
                      label: AppLocalizations.of(context)!
                          .lastupdated,
                      title: updatedOn ),


                ],
              ),
              SizedBox(
                height: 8.h,
              ),
              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,

                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _details(
                      color: AppColors.greenColor,
                      icon:  HeroIcons.calendar,
                      label: AppLocalizations.of(context)!
                          .completedoccurrences,
                      title: completedOcurrences??
                          "0"),
                  _details(
                      color: AppColors.mileStoneBgColor,
                      icon:  HeroIcons.calendar,
                      label: AppLocalizations.of(context)!
                          .numberofoccurence,
                      title: (recOcurrences ?? 0).toString()),



                    ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _project() {
    return InkWell(
      onTap: () {
        router.push('/projectdetails', extra: {
          "id": projectId,
          "projectModel":ProjectModel.empty()
        });
      },
      child: customContainer(
          width: double.infinity,
          context: context,
          addWidget: Padding(
            padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                project != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: CustomText(
                              text:
                                  "${AppLocalizations.of(context)!.project}   ",
                              size: 18.sp,
                              fontWeight: FontWeight.w800,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                            ),
                          ),
                          // SizedBox(width: 50.w,),
                          Expanded(
                            flex: 7,
                            child: CustomText(
                              text: "$project",
                              size: 14.sp,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.w500,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                            ),
                          )
                        ],
                      )
                    : SizedBox.shrink(),
              ],
            ),
          )),
    );
  }

  Widget _noteCard() {
    return customContainer(
        width: double.infinity,
        context: context,
        addWidget: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: "${AppLocalizations.of(context)!.note}  ",
                size: 18.sp,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.textClrChange,
              ),
              SizedBox(
                height: 10.w,
              ),
              CustomText(
                text: "$note",
                size: 14.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.textClrChange,
              )
            ],
          ),
        ));
  }

  Widget _usersCard() {
    return InkWell(
      onTap: () {
        userClientDialog(
          from: 'user',
          context: context,
          title: AppLocalizations.of(context)!.allusers,
          list: users!.isEmpty ? [] : users,
        );
      },
      child: customContainer(
        width: double.infinity,
        context: context,
        addWidget: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
          child: UserClientRowDetailPage(
              list: users!, title: AppLocalizations.of(context)!.users),
        ),
      ),
    );
  }

  Widget _clientsCard() {
    return InkWell(
      onTap: () {
        userClientDialog(
          from: 'client',
          context: context,
          title: AppLocalizations.of(context)!.allclients,
          list: clients!.isEmpty ? [] : clients!,
        );
      },
      child: customContainer(
        width: double.infinity,
        context: context,
        addWidget: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
          child: UserClientRowDetailPage(
              list: clients!, title: AppLocalizations.of(context)!.clients),
        ),
      ),
    );
  }

  Widget _details({
    required String label,
    required String title,
    bool? iswidth,
    required HeroIcons icon,
    required Color color,
  }) {
    return SizedBox(
      width: iswidth == true ? 290 : 140.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the top
            children: [
              Expanded( // Allows the label text to wrap
                child: CustomText(
                  text: label,
                  color: Theme.of(context).colorScheme.textClrChange,
                  size: 14.sp,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 5.w),
              HeroIcon(
                icon,
                size: 15.sp,
                style: HeroIconStyle.outline,
                color: color,
              ),
              SizedBox(width: 5.w),
            ],
          ),
          CustomText(
            text: title,
            color: Theme.of(context).colorScheme.textClrChange,
            size: 12.sp,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }

}
