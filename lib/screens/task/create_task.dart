import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/bloc/task/task_bloc.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/screens/project/widgets/usersFieldProject.dart';
import 'package:taskify/screens/task/widget/const_list.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/task/task_state.dart';
import '../../bloc/task_id/taskid_bloc.dart';
import '../../bloc/task_id/taskid_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../config/constants.dart';
import '../../data/model/task/task_model.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_switch.dart';
import '../../utils/widgets/custom_text.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/toast_widget.dart';

import '../Project/widgets/project_field.dart';
import '../dash_board/dashboard.dart';
import '../style/design_config.dart';
import '../widgets/custom_date.dart';
import '../widgets/custom_cancel_create_button.dart';
import '../widgets/custom_textfields/custom_textfield.dart';
import 'Widget/priority_all_field.dart';
import 'Widget/status_field.dart';
import 'custom_fields_tasks/custom_field_task_page.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class CreateTask extends StatefulWidget {
  final bool? isCreate;
  final bool? fromDetail;
  final String? title;
  final String? project;
  final String? user;
  final String? status;
  final bool? isSubTask;
  final int? parentId;
  final String? priority;
  final int? priorityId;
  final int? statusId;
  final int? id;
  final int? canClientDiscuss;
  final int? projectID;
  final String? desc;
  final String? note;
  final String? start;
  final String? end;
  final List<Tasks>? taskcreate;
  final List<TaskUsers>? userList;
  final List<String>? users;
  final List<int>? usersid;
  final int? index;
  final Tasks? tasks;
  final String? billingType;
  final Tasks? tasksModel; // Remove `required` to allow null
  CreateTask(
      {super.key,
      this.isCreate,
      this.fromDetail,
      this.project,
      this.userList,
      this.tasks,
      this.title,
      this.usersid,
      this.parentId,
      this.isSubTask,
      this.priority,
      this.billingType,
      required this.tasksModel,
      this.priorityId,
      this.projectID,
      this.users,
      this.canClientDiscuss,
      this.id,
      this.statusId,
      this.user,
      this.status,
      this.desc,
      this.note,
      this.start,
      this.end,
      this.taskcreate,
      this.index});

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController numberOfOccurencesController = TextEditingController();
  TextEditingController projectController = TextEditingController();
  TextEditingController userController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController priorityController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController startsController = TextEditingController();
  TextEditingController startRecurrenceController = TextEditingController();
  TextEditingController endController = TextEditingController();
  TextEditingController startController = TextEditingController();

  DateTime selectedDateStarts = DateTime.now();
  DateTime selectedDateStartRecurrence = DateTime.now();
  DateTime? selectedDateEnds = DateTime.now();
  String? toPassStartDate = "";
  String? fromdate;
  String? billingType;
  String frequencyType = "daily";
  int? dayOftheMonth;
  int? dayOftheMonthRecurring;
  int? monthOftheYearRecurring;
  int? dayOftheWeekRecurring;
  int? dayOftheWeek;

  ValueNotifier<String?> recurrencyFrequency = ValueNotifier<String?>("daily");

  int? monthOfYear;

  String? todate;
  String? selectedCategory;
  bool canClientDiscussWith = false;

  ValueNotifier<bool> enableRecurringTask = ValueNotifier<bool>(false);

  ValueNotifier<bool> enableReminder = ValueNotifier<bool>(false);

  List<String>? usersName;
  List<int>? selectedusersNameId;
  String? selectedStatus;
  int? selectedStatusId;
  late CustomFieldTaskPage _customFieldPageTask;
  final GlobalKey<CustomFieldTaskPageState> _customFieldTaskPageKey =
      GlobalKey<CustomFieldTaskPageState>(); // Add GlobalKey

  bool? isLoading;
  int? selectedPriorityId;
  String? selectedPriority;
  int? selectedID;

  String selectedProject = '';

  String selectedUser = '';
  // String selectedStatus = '';

  String? formattedStartDate;
  String? formattedEndDate;
  int? idStatus;
  int? idPriority;
  double _value = 0;
  double valueInProgress = 0;
  TimeOfDay _timestart = const TimeOfDay(hour: 9, minute: 00);
  String? formattedTimeStart;
  void _handleAccessSelected(String type) {
    setState(() {
      billingType = type;
    });
  }

  void _handleFrequencyTypeSelected(String type) {
    setState(() {
      frequencyType = type;
    });
  }

  void _handleDayOfTheMonthSelected(int type) {
    setState(() {
      dayOftheMonth = type;
    });
  }

  void _handleDayOfTheMonthRecurringSelected(int type) {
    setState(() {
      dayOftheMonthRecurring = type;
    });
  }

  void _handleDayOfTheWeekSelected(int type) {
    setState(() {
      dayOftheWeek = type;
    });
  }

  void _handleDayOfTheWeekRecurringSelected(int type) {
    setState(() {
      dayOftheWeekRecurring = type;
    });
  }

  void _handleMonthOfYearSelected(int type) {
    setState(() {
      monthOfYear = type;
    });
  }

  void _handleRecurrencyFrequencySelected(String type) {
    setState(() {
      recurrencyFrequency.value = type;
    });
  }

  void _handleProjectSelected(String category, int catID) {
    setState(() {
      selectedCategory = category;
      selectedID = catID;
    });
  }

  void _selectstartTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _timestart,
    );

    if (newTime != null) {
      setState(() {
        _timestart = newTime;

        // Format as HH:MM:SS
        formattedTimeStart =
            '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void canClientdiscussHandle(bool status) {
    setState(() {
      canClientDiscussWith = status;
    });
  }

  void enableRecurringTaskHandle(bool status) {
    setState(() {
      enableRecurringTask.value = status;
    });
  }

  void enableReminderHandle(bool status) {
    setState(() {
      enableReminder.value = status;
    });
  }

  void _handlePrioritySelected(String category, int catId) {
    setState(() {
      selectedPriority = category;
      selectedPriorityId = catId;
    });
  }

  void _handleStatusSelected(String category, int catId) {
    setState(() {
      selectedStatus = category;
      selectedStatusId = catId;
    });
  }

  void _onCreate() {
    List<String> missingFields = [];

    // Check standard fields with detailed logging
    print("=== FIELD VALIDATION DEBUG ===");

    print(
        "Title: '${titleController.text}' (isEmpty: ${titleController.text.isEmpty})");
    if (titleController.text.isEmpty) {
      missingFields.add(AppLocalizations.of(context)!.title);
    }

    print(
        "Selected Status ID: $selectedStatusId (isNull: ${selectedStatusId == null})");
    if (selectedStatusId == null) {
      missingFields.add(AppLocalizations.of(context)!.status);
    }

    print("Selected Project ID: $selectedID (isNull: ${selectedID == null})");
    if (selectedID == null) {
      missingFields.add(AppLocalizations.of(context)!.project);
    }

    // Check reminder fields with detailed logging
    print("Enable Reminder: ${enableReminder.value}");
    if (enableReminder.value == true) {
      print(
          "Frequency Type: '$frequencyType' (isEmpty: ${frequencyType.isEmpty})");
      print(
          "From Date: '$fromdate' (isNull: ${fromdate == null}, isEmpty: ${fromdate?.trim().isEmpty})");

      if (frequencyType.isEmpty ||
          formattedTimeStart == null ||
          formattedTimeStart!.trim().isEmpty) {
        missingFields
            .add(AppLocalizations.of(context)!.pleasefillfrequencyandtime);
      }
    }

    // Check recurring task fields with detailed logging
    print("Enable Recurring Task: ${enableRecurringTask.value}");
    if (enableRecurringTask.value == true) {
      print("Recurrency Frequency: ${recurrencyFrequency.value}");
      print("Number of Occurrences: '${numberOfOccurencesController.text}'");
      print("Start Date: $toPassStartDate");

      if (recurrencyFrequency.value == null ||
          recurrencyFrequency.value!.isEmpty ||
          numberOfOccurencesController.text.trim().isEmpty ||
          toPassStartDate == null) {
        missingFields
            .add(AppLocalizations.of(context)!.pleasefillrecurringfields);
      }
    }

    // Custom fields validation with detailed logging
    print("Custom Fields in TaskModel: ${widget.tasksModel?.customFields}");
    final customFieldValues =
        _customFieldTaskPageKey.currentState?.getFieldValues();
    print("Current Custom Field Values: $customFieldValues");

    bool customFieldsValid =
        _customFieldTaskPageKey.currentState?.validateFields() ?? true;
    print("Custom Fields Valid: $customFieldsValid");
    if (!customFieldsValid) {
      missingFields.add("Custom field(s)");
    }

    print("=== MISSING FIELDS: $missingFields ===");

    if (missingFields.isEmpty) {
      String formattedTime = "";
      if (formattedTimeStart != null) {
        formattedTime = formattedTimeStart!.substring(0, 5);
      }
      // ✅ All fields validated, trigger the TaskCreated event
      context.read<TaskBloc>().add(TaskCreated(
            isSubtask: widget.isSubTask ?? false,
            parentId: widget.parentId ?? 0,
            canClientDiscuss: canClientDiscussWith ? 0 : 1,
            title: titleController.text,
            statusId: selectedStatusId ?? 0,
            priorityId: selectedPriorityId ?? 0,
            startDate: fromdate ?? "",
            dueDate: todate ?? "",
            desc: descController.text,
            project: selectedID ?? 0,
            userId: selectedusersNameId ?? [],
            frequencyType: frequencyType.toLowerCase(),
            recurringFrequencyType:
                recurrencyFrequency.value?.toLowerCase() ?? "",
            note: noteController.text,
            enableRecurringTask: enableRecurringTask.value ? "on" : "off",
            enableReminder: enableReminder.value ? "on" : "off",
            billingType: billingType?.toLowerCase() ?? "none",
            completionPercentage: valueInProgress.toInt(),
            dayOfWeek: dayOftheWeek,
            dayOfMonth: dayOftheWeek,
            timeOfDay: formattedTime,
            recurrenceDayOfWeek: dayOftheWeekRecurring,
            recurrenceDayOfMonth: dayOftheMonthRecurring,
            recurrenceMonthOfYear: monthOftheYearRecurring,
            recurrenceStartsFrom: toPassStartDate,
            recurrenceOccurrences:
                numberOfOccurencesController.text.trim().isNotEmpty
                    ? int.parse(numberOfOccurencesController.text.trim())
                    : 0,
            customFieldValues: customFieldValues!,
          ));
      isLoading = true;
      context.read<TaskBloc>().stream.listen((event) {
        if (event is TaskCreateSuccess) {
          if (mounted) {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) =>
                    const DashBoard(initialIndex: 2), // Navigate to index 1
              ),
            );
            isLoading = false;
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.createdsuccessfully,
                color: AppColors.primary);
            // Navigator.pop(context);
          }
        }
        if (event is TaskCreateError) {
          flutterToastCustom(msg: event.errorMessage);
        }
      });
    } else {
      // ❌ Show missing fields as toast
      print("Validation failed. Missing required fields: $missingFields");
      String errorMessage =
          "${AppLocalizations.of(context)!.pleasefilltherequiredfield}: ${missingFields.join(', ')}";
      flutterToastCustom(msg: errorMessage);
    }
  }

  void _onUpdateTask() {
    isLoading = true;

    if (enableReminder.value == true) {
      if (frequencyType == "" ||
          formattedTimeStart == null ||
          formattedTimeStart!.trim().isEmpty) {
        flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleasefillfrequencyandtime,
        );
        return;
      }
    }

    // Check for recurring task fields
    if (enableRecurringTask.value == true) {
      if (recurrencyFrequency.value == null ||
          recurrencyFrequency.value.toString().isEmpty ||
          numberOfOccurencesController.text.trim().isEmpty ||
          toPassStartDate == null) {
        flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleasefillrecurringfields,
        );
        return;
      }
    }
    final customFieldValues = _customFieldPageTask.getFieldValues();
    String? formattedTime;
    if (formattedTimeStart != null) {
      formattedTime = formattedTimeStart!.substring(0, 5);
    }
    context.read<TaskBloc>().add(UpdateTask(
          isSubtask: widget.isSubTask ?? false, parentId: widget.parentId ?? 0,
          enableRecurringTask:
              enableRecurringTask.value == false ? "off" : "on",
          frequencyType: frequencyType,
          recurringFrequencyType: recurrencyFrequency.value,
          enableReminder: enableReminder.value == false ? "off" : "on",
          billingType:
              billingType?.toLowerCase().replaceAll(' ', '-') ?? "none",

          completionPercentage: valueInProgress.toInt(),
          canClientDiscuss: canClientDiscussWith ? 0 : 1,
          id: widget.id!,
          title: titleController.text,
          statusId:
              selectedStatusId == null ? widget.statusId! : selectedStatusId!,
          priorityId: selectedPriorityId == null
              ? widget.priorityId!
              : selectedPriorityId!,
          startDate: fromdate ?? widget.start!,
          desc: descController.text,
          userId: selectedusersNameId!,
          note: noteController.text,
          dueDate: todate ?? widget.end!,
          dayOfWeek: dayOftheWeek,

          dayOfMonth: dayOftheWeek,
          timeOfDay: formattedTime,
          recurrenceDayOfWeek: dayOftheWeekRecurring,
          recurrenceDayOfMonth: dayOftheMonthRecurring,
          recurrenceMonthOfYear: monthOftheYearRecurring,
          recurrenceStartsFrom: toPassStartDate,
          customFieldValues: customFieldValues,
          // recurrenceOccurrences: numberOfOccurencesController.text.to,
        ));
    context.read<TaskBloc>().stream.listen((event) {
      print("fvgbhnjmk $event");
      if (event is TaskEditSuccess) {
        if (mounted) {
          isLoading = false;
          if (widget.fromDetail == true) {
            BlocProvider.of<TaskidBloc>(context).add(TaskIdListId(widget.id));
            router.pop(context);
          } else {
            context.read<TaskBloc>().add(AllTaskList());
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) =>
                    const DashBoard(initialIndex: 2), // Navigate to index 1
              ),
            );
          }

          flutterToastCustom(
              msg: AppLocalizations.of(context)!.updatedsuccessfully,
              color: AppColors.primary);
        }
      } else if (event is TaskEditError) {
        if (mounted) {
          flutterToastCustom(msg: event.errorMessage);
          context.read<TaskBloc>().add(AllTaskList());
        }
      }
    });

    //   return;
    // }
    // context.read<TaskBloc>().add(AllTaskList());
    // Navigator.pop(context);
    // CustomToast(message: "Fill all the fields");
  }

  FocusNode? titleFocus,
      budgetFocus,
      descFocus,
      startsFocus,
      endFocus = FocusNode();
  List tags = [
    "development",
    "E-Commerce",
    "Marketing",
    "Marketing",
    "Marketing"
  ];

  void _handleUsersSelected(List<String> category, List<int> catId) {
    setState(() {
      usersName = category;
      selectedusersNameId = catId;
    });
  }

  bool? token;
  @override
  void initState() {
    print("hjnkml,;. ${widget.parentId}");
    print("hjnkml,;. ${widget.isSubTask}");
    if (widget.isCreate == false) {
      String? formattedstart;
      String? formattedend;
      String? formattedRecurstart;

      enableReminder.value =
          widget.tasksModel!.enableReminder == 0 ? false : true;
      enableRecurringTask.value =
          widget.tasksModel!.enableRecurringTask == 0 ? false : true;
      frequencyType = widget.tasksModel!.frequencyType ?? "".toLowerCase();
      recurrencyFrequency.value =
          widget.tasksModel!.recurrenceFrequency ?? "".toLowerCase();
      if (widget.tasksModel!.recurrenceStartsFrom != null) {
        DateTime parsedDateEnd =
            parseDateStringFromApi(widget.tasksModel!.recurrenceStartsFrom!);
        formattedRecurstart = dateFormatConfirmed(parsedDateEnd, context);
        // fromdate = f
        selectedDateStartRecurrence = parsedDateEnd;
      }

      if (widget.tasksModel!.timeOfDay != null) {
        DateTime parsedDateEnd = parseDateStringFromApi(widget.end!);
        formattedend = dateFormatConfirmed(parsedDateEnd, context);
        _timestart = TimeOfDay.fromDateTime(parsedDateEnd);
        formattedTimeStart = widget.tasksModel!.timeOfDay;
      }
      formattedTimeStart = widget.tasksModel!.timeOfDay;
      recurrencyFrequency.value =
          widget.tasksModel!.recurrenceFrequency ?? "".toLowerCase();
      numberOfOccurencesController.text =
          widget.tasksModel!.recurrenceOccurrences.toString();
      selectedusersNameId = widget.usersid;

      if (widget.start != null &&
          widget.start!.isNotEmpty &&
          widget.start != "") {
        DateTime parsedDate = parseDateStringFromApi(widget.start!);
        formattedstart = dateFormatConfirmed(parsedDate, context);
        selectedDateStarts = parseDateStringFromApi(widget.start!);
      }
      if (widget.end != null && widget.end!.isNotEmpty && widget.end != "") {
        DateTime parsedDate = parseDateStringFromApi(widget.end!);
        formattedend = dateFormatConfirmed(parsedDate, context);
        selectedDateEnds = parseDateStringFromApi(widget.end!);
      }
      if (widget.tasksModel!.recurrenceStartsFrom != null &&
          widget.tasksModel!.recurrenceStartsFrom!.isNotEmpty &&
          widget.tasksModel!.recurrenceStartsFrom != "") {
        DateTime parsedDate =
            parseDateStringFromApi(widget.tasksModel!.recurrenceStartsFrom!);
        formattedRecurstart = dateFormatConfirmed(parsedDate, context);
        selectedDateStartRecurrence =
            parseDateStringFromApi(widget.tasksModel!.recurrenceStartsFrom!);
      }
      if (widget.canClientDiscuss == 1) {
        canClientDiscussWith = true;
      } else {
        canClientDiscussWith = false;
      }
      // if(){}else{}

      titleController = TextEditingController(text: widget.title);
      projectController = TextEditingController(text: widget.project);
      selectedCategory = widget.project;
      selectedPriority = widget.priority;
      selectedStatus = widget.status;
      usersName = widget.users;
      startsController = TextEditingController(
        text: (formattedstart != null && formattedend != null)
            ? "$formattedstart - $formattedend"
            : '',
      );
      startRecurrenceController = TextEditingController(
          text: formattedRecurstart != null ? formattedRecurstart : "");

      descController =
          TextEditingController(text: removeHtmlTags(widget.desc!));
      noteController = TextEditingController(text: widget.note);
      _customFieldPageTask = CustomFieldTaskPage(
        tasksModel: widget.tasksModel!,
        isCreate: widget.isCreate!,
        key: _customFieldTaskPageKey,
      );
    } else {
      titleController = TextEditingController();
      selectedStatus = "";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("hjnkml,;. ere ${widget.parentId}");
    for (var i in widget.userList!) {
      selectedusersNameId!.add(i.id!);
    }
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (!didPop) {
            if (widget.fromDetail == true && widget.isCreate == false) {
              BlocProvider.of<TaskidBloc>(context).add(TaskIdListId(widget.id));
              router.pop();
            } else {
              router.pop();
            }
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.backGroundColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _createEditAppbar(isLightTheme),
                SizedBox(height: 30.h),
                _taskBody(isLightTheme)
              ],
            ),
          ),
        ));
  }

  Widget _taskBody(isLightTheme) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: BlocBuilder<TaskBloc, TaskState>(builder: (context, state) {
          print("SHOW THE STATE $state");
          if (state is TaskLoading) {
            return _form([], isLightTheme, false);
          }
          if (state is TaskCreateSuccessLoading) {
            return _form([], isLightTheme, false);
          }
          if (state is TaskEditSuccessLoading) {
            return _form([], isLightTheme, false);
          }
          if (state is TaskCreateError) {
            flutterToastCustom(
              msg: state.errorMessage,
            );
            context.read<TaskBloc>().add(AllTaskList());

            router.pop(context);
          }
          if (state is TaskError) {
            flutterToastCustom(
              msg: state.errorMessage,
            );
            context.read<TaskBloc>().add(AllTaskList());

            router.pop(context);
          }
          if (state is AllTaskSuccess) {
            return _form([], isLightTheme, false);
          } else if (state is TaskPaginated) {
            List<int> id = [];
            if (widget.isCreate == false) {
              for (var task in state.task) {
                for (var ids in task.users!) {
                  id.add(ids.id!);
                }
              }
            }

            return _form(state.task, isLightTheme, true);
          }
          return Container();
        }),
      ),
    );
  }

  Widget _createEditAppbar(isLightTheme) {
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
                    child: InkWell(
                      onTap: () {
                        if (widget.fromDetail == true &&
                            widget.isCreate == false) {
                          BlocProvider.of<TaskidBloc>(context)
                              .add(TaskIdListId(widget.id));
                          router.pop();
                        } else {
                          context.read<TaskBloc>().add(AllTaskList());
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => const DashBoard(
                                  initialIndex: 2), // Navigate to index 1
                            ),
                          );
                        }
                      },
                      child: BackArrow(
                        title: widget.isCreate == false
                            ? AppLocalizations.of(context)!.edittask
                            : AppLocalizations.of(context)!.createtask,
                      ),
                    )),
              ],
            ))
      ],
    );
  }

  Widget _form(tasks, isLightTheme, isPaginatedState) {
    print(" gbhfnk m $frequencyType");
    print(" gbhfnk m ${recurrencyFrequency.value}");
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextFields(
          title: AppLocalizations.of(context)!.title,
          hinttext: AppLocalizations.of(context)!.pleaseentertitle,
          controller: titleController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: true,
        ),

        SizedBox(
          height: 15.h,
        ),
        StatusField(
          isRequired: true,
          status: widget.statusId,
          isCreate: widget.isCreate!,
          name: selectedStatus ?? "",
          index: widget.index!,
          onSelected: _handleStatusSelected,
        ),
        // StatusField(isLightTheme, Statusname, idStatus),
        SizedBox(
          height: 15.h,
        ),
        PriorityAllField(
            priority: widget.priorityId,
            isCreate: widget.isCreate!,
            name: selectedPriority ?? "",
            index: widget.index,
            onSelected: _handlePrioritySelected),
        SizedBox(
          height: 15.h,
        ),
        ProjectField(
          isRequired: true,
          isCreate: widget.isCreate!,
          project: widget.projectID != null ? widget.projectID! : 0,
          name: selectedCategory ?? "",
          index: widget.index!,
          onSelected: _handleProjectSelected,
        ),
        SizedBox(
          height: 15.h,
        ),
        selectedID != null && selectedID != ""
            ? UsersFieldProject(
                projectId: widget.isCreate == true
                    ? selectedID!
                    : widget.tasksModel!.projectId!,
                isCreate: widget.isCreate!,
                usersname: usersName ?? [],
                project: const [],
                usersid: widget.usersid!,
                onSelected: _handleUsersSelected,
              )
            : SizedBox(),

        // PriorityField(isLightTheme, Priorityname,idPriority),
        selectedID != null && selectedID != ""
            ? SizedBox(
                height: 15.h,
              )
            : SizedBox(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Row(
            children: [
              IsCustomSwitch(
                  isCreate: widget.isCreate,
                  status: canClientDiscussWith,
                  onStatus: canClientdiscussHandle),
              SizedBox(
                width: 20.w,
              ),
              CustomText(
                text: AppLocalizations.of(context)!.canclientdiscuss,
                fontWeight: FontWeight.w400,
                size: 12.sp,
                color: Theme.of(context).colorScheme.textClrChange,
              )
            ],
          ),
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
            height: 112.h,
            keyboardType: TextInputType.multiline,
            title: AppLocalizations.of(context)!.description,
            hinttext: AppLocalizations.of(context)!.pleaseenterdescription,
            controller: descController,
            onSaved: (value) {},
            onFieldSubmitted: (value) {},
            isLightTheme: isLightTheme,
            isRequired: false),

        SizedBox(
          height: 15.h,
        ),
        BilingListField(
          access: widget.billingType,
          isRequired: false,
          isCreate: widget.isCreate!,
          name: billingType ?? "",
          from: "billing",
          onSelected: _handleAccessSelected,
        ),
        SizedBox(
          height: 15.h,
        ),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: CustomText(
                  text: AppLocalizations.of(context)!.completionpercentage,
                  color: Theme.of(context).colorScheme.textClrChange,
                  size: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _value,
                      min: 0,
                      max: 100,
                      divisions: 10, // This ensures increments of 10
                      onChanged: (v) {
                        setState(() {
                          _value = v;
                          valueInProgress = v; // Already in 10-step increments
                          print("Progress Value: $valueInProgress");
                        });
                      },
                      label:
                          "${_value.toInt()}%", // Display as integer percentage
                    ),
                  ),
                  CustomText(
                    text: "${(_value).toStringAsFixed(0)}%",
                    size: 15.sp,
                    color: Theme.of(context).colorScheme.textClrChange,
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
            keyboardType: TextInputType.multiline,
            height: 112.h,
            title: AppLocalizations.of(context)!.note,
            hinttext: AppLocalizations.of(context)!.pleaseenternotes,
            controller: noteController,
            onSaved: (value) {},
            onFieldSubmitted: (value) {},
            isLightTheme: isLightTheme,
            isRequired: false),
        SizedBox(
          height: 15.h,
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: DateRangePickerWidget(
            dateController: startsController, // Use only one controller
            title: AppLocalizations.of(context)!.date,
            titlestartend: AppLocalizations.of(context)!.selectstartenddate,
            selectedDateEnds: selectedDateEnds,
            selectedDateStarts: selectedDateStarts,
            isLightTheme: isLightTheme,
            onTap: (start, end) {
              setState(() {
                selectedDateEnds = end;
                selectedDateStarts = start!;
                String startAndEndText =
                    '${dateFormatConfirmed(selectedDateStarts, context)} - ${dateFormatConfirmed(selectedDateEnds!, context)}';
                startsController.text = startAndEndText;
               fromdate = dateFormatConfirmedToApi(start);
                todate = dateFormatConfirmedToApi(end!);

              });
            },

          ),
        ),

        SizedBox(
          height: 15.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.enablereminder,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(
                height: 5.h,
              ),
              Row(
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: enableReminder,
                    builder: (context, value, child) {
                      return IsCustomSwitch(
                        isCreate: widget.isCreate,
                        status: value,
                        onStatus: enableReminderHandle,
                        // onStatus: (newValue) {
                        //   enableReminder.value = newValue; // Update ValueNotifier
                        // },
                      );
                    },
                  ),
                  SizedBox(width: 20.w),
                  CustomText(
                    text: AppLocalizations.of(context)!.enabletaskreminder,
                    fontWeight: FontWeight.w400,
                    size: 12.sp,
                    color: Theme.of(context).colorScheme.textClrChange,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 15.h,
        ),

        enableReminder.value == true
            ? Container(
                child: Column(
                  children: [
                    BilingListField(
                      access: widget.tasksModel!.frequencyType ?? frequencyType,
                      isRequired: true,
                      isCreate: widget.isCreate!,
                      name: frequencyType,
                      from: "frequencytype",
                      onSelected: _handleFrequencyTypeSelected,
                    ),
                    SizedBox(
                      height: 15.h,
                    ),

                    // Conditionally show monthly or weekly field
                    if (frequencyType == "Monthly")
                      ConstListField(
                        access: widget.billingType,
                        isRequired: true,
                        isCreate: widget.isCreate!,
                        index: dayOftheMonth ?? 0,
                        from: "dayofmonth",
                        onSelected: _handleDayOfTheMonthSelected,
                      )

                    // Show only if Weekly
                    else if (frequencyType == "Weekly")
                      ConstListField(
                        access: widget.billingType,
                        isRequired: true,
                        isCreate: widget.isCreate!,
                        index: dayOftheWeek ?? 0,
                        from: "dayofWeek",
                        onSelected: _handleDayOfTheWeekSelected,
                      ),

                    SizedBox(
                      height: 15.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomText(
                                text: AppLocalizations.of(context)!.timeofday,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                                size: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              const CustomText(
                                text: " *",
                                // text: getTranslated(context, 'myweeklyTask'),
                                color: AppColors.red,
                                size: 15,
                                fontWeight: FontWeight.w400,
                              )
                            ],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Container(
                              // margin: EdgeInsets.symmetric(horizontal:  18.w),
                              // padding: EdgeInsets.symmetric(horizontal: 0.w),
                              height: 40.h,
                              // margin: EdgeInsets.only(left: 20, right: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.greyColor),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              // decoration: DesignConfiguration.shadow(),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    setState(() {
                                      _selectstartTime();
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      const HeroIcon(
                                        size: 20,
                                        HeroIcons.clock,
                                        style: HeroIconStyle.outline,
                                        color: AppColors.greyForgetColor,
                                      ),
                                      SizedBox(
                                        width: 10.w,
                                      ),
                                      CustomText(
                                        text: widget.isCreate == false &&
                                                widget.tasksModel!.timeOfDay !=
                                                    null
                                            ? widget.tasksModel!.timeOfDay!
                                            : _timestart.format(context),
                                        fontWeight: FontWeight.w400,
                                        size: 14.sp,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textClrChange,
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox(),

        SizedBox(
          height: 15.h,
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                CustomText(
                  text: AppLocalizations.of(context)!.enablerecurringtask,
                  color: Theme.of(context).colorScheme.textClrChange,
                  size: 16,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
            SizedBox(
              height: 5.h,
            ),
            ValueListenableBuilder<bool>(
                valueListenable: enableRecurringTask,
                builder: (context, value, child) {
                  return Row(
                    children: [
                      IsCustomSwitch(
                          isCreate: widget.isCreate,
                          status: value,
                          onStatus: enableRecurringTaskHandle),
                      SizedBox(
                        width: 20.w,
                      ),
                      CustomText(
                        text: AppLocalizations.of(context)!.enablerecurringtask,
                        fontWeight: FontWeight.w400,
                        size: 12.sp,
                        color: Theme.of(context).colorScheme.textClrChange,
                      )
                    ],
                  );
                }),
          ]),
        ),
        SizedBox(
          height: 15.h,
        ),
        enableRecurringTask.value == true
            ? Container(
                child: Column(
                  children: [
                    ValueListenableBuilder<String?>(
                      valueListenable: recurrencyFrequency,
                      builder: (context, value, child) {
                        print(
                            "recurrencyFrequency builder called with: $value");
                        return BilingListField(
                          access: widget.tasksModel!.recurrenceFrequency ??
                              recurrencyFrequency.value,
                          isRequired: true,
                          isCreate: widget.isCreate!,
                          name: value ?? "", // Use the value from ValueNotifier
                          from: "recurrencefrequencytype",
                          onSelected: _handleRecurrencyFrequencySelected,
                        );
                      },
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    recurrencyFrequency.value == "Weekly"
                        ? ConstListField(
                            access: widget.billingType,
                            isRequired: true,
                            isCreate: widget.isCreate!,
                            index: dayOftheWeekRecurring ?? 0,
                            from: "dayofWeek",
                            onSelected: _handleDayOfTheWeekRecurringSelected,
                          )
                        : SizedBox(),
                    recurrencyFrequency.value == "Weekly"
                        ? SizedBox(
                            height: 15.h,
                          )
                        : SizedBox(),
                    recurrencyFrequency.value == "Monthly" ||
                            recurrencyFrequency.value == "Yearly"
                        ? ConstListField(
                            access: widget.billingType,
                            isRequired: true,
                            isCreate: widget.isCreate!,
                            index: dayOftheMonthRecurring ?? 0,
                            from: "dayofmonth",
                            onSelected: _handleDayOfTheMonthRecurringSelected,
                          )
                        : SizedBox(),
                    recurrencyFrequency.value == "Monthly" ||
                            recurrencyFrequency.value == "Yearly"
                        ? SizedBox(
                            height: 15.h,
                          )
                        : SizedBox(),
                    recurrencyFrequency.value == "Yearly"
                        ? ConstListField(
                            access: widget.billingType,
                            isRequired: true,
                            isCreate: widget.isCreate!,
                            index: monthOftheYearRecurring ?? 0,
                            from: "monthofyear",
                            onSelected: _handleMonthOfYearSelected,
                          )
                        : SizedBox(),
                    recurrencyFrequency.value == "Yearly"
                        ? SizedBox(
                            height: 15.h,
                          )
                        : SizedBox(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: DatePickerWidget(
                              star: true,
                              size: 12.sp,
                              dateController: startRecurrenceController,
                              title: AppLocalizations.of(context)!.starts,
                              onTap: () async {
                                // Call the date picker here when tapped
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDateStartRecurrence,
                                  firstDate: DateTime.now().subtract(
                                      Duration(days: 3)), // Minimum date
                                  lastDate: DateTime(2199),
                                  builder: (context, child) {
                                    return child!;
                                  },
                                );

                                if (pickedDate != null) {
                                  setState(() {
                                    selectedDateStartRecurrence = pickedDate;
                                    selectedDateEnds =
                                        pickedDate; // Same date since it's single selection

                                    startRecurrenceController.text =
                                        dateFormatConfirmed(
                                            selectedDateStartRecurrence,
                                            context);

                                    toPassStartDate = dateFormatConfirmedToApi(
                                        selectedDateStartRecurrence);
                                    // Since it's a single-day selection
                                  });
                                }
                              },
                              isLightTheme: isLightTheme,
                            ),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    CustomTextFields(
                      title: AppLocalizations.of(context)!.numberofoccurence,
                      hinttext: "",
                      controller: numberOfOccurencesController,
                      onSaved: (value) {},
                      onFieldSubmitted: (value) {},
                      isLightTheme: isLightTheme,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              )
            : SizedBox(),
        SizedBox(
          height: 15.h,
        ),
        Divider(),
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
        CustomFieldTaskPage(
          tasksModel: widget.tasksModel ?? Tasks.empty(),
          key: _customFieldTaskPageKey,
          isCreate: widget.isCreate!,
        ),

        SizedBox(
          height: 15.h,
        ),
        CreateCancelButtom(
          isLoading: false,
          isCreate: widget.isCreate,
          onpressCancel: () {
            Navigator.pop(context);
          },
          onpressCreate: widget.isCreate == true
              ? () async {
                  isPaginatedState == true ? _onCreate() : null;
                  // Navigator.pop(context);
                }
              : () {
                  isPaginatedState == true ? _onUpdateTask() : null;
                },
        ),
        SizedBox(
          height: 25.h,
        )
      ],
    );
  }
}
