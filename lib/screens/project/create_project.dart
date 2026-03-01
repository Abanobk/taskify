import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/bloc/setting/settings_bloc.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/config/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/data/model/Project/all_project.dart';
import 'package:taskify/screens/project/widgets/custom_fields/custom_field_page.dart';
import '../../../utils/widgets/notes_shimmer_widget.dart';
import 'package:taskify/screens/widgets/tag_field.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../bloc/project/project_bloc.dart';
import '../../bloc/project/project_event.dart';
import '../../bloc/project/project_state.dart';
import '../../bloc/project_id/projectid_bloc.dart';
import '../../bloc/project_id/projectid_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_switch.dart';
import '../../utils/widgets/custom_text.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/toast_widget.dart';
import '../dash_board/dashboard.dart';
import '../style/design_config.dart';
import '../task/Widget/priority_all_field.dart';
import '../task/Widget/users_field.dart';
import '../task/Widget/status_field.dart';
import '../widgets/custom_date.dart';
import '../widgets/custom_cancel_create_button.dart';
import '../../../src/generated/i18n/app_localizations.dart';

import '../widgets/accessibility_field.dart';
import '../widgets/clients_field.dart';
import '../widgets/custom_textfields/custom_textfield.dart';

class CreateProject extends StatefulWidget {
  final bool? isCreate;
  final bool? fromDetail;
  final String? title;
  final String? user;
  final String? status;
  final String? priority;
  final String? budget;
  final int? priorityId;
  final int? statusId;
  final int? id;
  final int? canClientDiscuss;
  final int? enable;
  final String? desc;
  final String? note;
  final String? start;
  final String? end;
  final String? access;
  final int? index;
  final List<int>? userId;
  final List<int>? clientId;
  final List<int>? tagId;
  final List<String>? userNames;
  final List<String>? clientNames;
  final List<String>? tagNames;
  final ProjectModel? customFieldsModel;

  CreateProject(
      {super.key,
      this.isCreate,
      this.fromDetail,
      this.title,
      this.priority,
      this.priorityId,
      this.budget,
      this.enable,
      this.id,
      this.statusId,
      this.user,
      this.status,
      this.desc,
      this.note,
      this.access,
      this.canClientDiscuss,
      this.start,
      this.end,
      this.index,
      this.userId,
      this.clientId,
      this.tagId,
      this.userNames,
      this.clientNames,
      this.tagNames,
      this.customFieldsModel});

  @override
  State<CreateProject> createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController budgetController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController startsController = TextEditingController();
  TextEditingController endController = TextEditingController();
  DateTime selectedDateStarts = DateTime.now();
  DateTime? selectedDateEnds = DateTime.now();
  String? fromDate;
  String? toDate;
  bool canClientDiscussWith = false;
  bool taskTimeEntries = false;
  String? selectedCategory;
  String? selectedStatus;
  String? selectedaccess;
  int? selectedStatusId;
  int? selectedPriorityId;
  String? selectedPriority;
  List<int>? selectedTagId;
  List<String>? selectedTag;
  List<int>? selectedClientId;
  List<String>? selectedClient;
  int? selectedID;
  String? selectedCategoryy;

  String selectedProject = '';

  String selectedUser = '';
  List<String>? usersName;
  List<int>? selectedusersNameId;
  // String selectedStatus = '';

  String? formattedStartDate;
  String? formattedEndDate;
  int? idStatus;
  int? idPriority;
  String? currency;
  String? currencyPosition;
  ProjectModel? customFieldReInitialized; // Moved to State class
  String selectedOption = "Option 1";
  late CustomFieldPage _customFieldPage;
  final GlobalKey<CustomFieldPageState> _customFieldPageKey = GlobalKey<CustomFieldPageState>(); // Add GlobalKey
  bool isCheckBox = false;
  String? selectedFromSelect;
  List<String> fieldTypes = [
    'number',
    'password',
    'textarea',
    'radio',
    'date',
    'checkbox',
    'select'
  ];

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  FocusNode? titleFocus,
      budgetFocus,
      descFocus,
      startsFocus,
      endFocus = FocusNode();

  @override
  void initState() {
    currency = context.read<SettingsBloc>().currencySymbol;
    currencyPosition = context.read<SettingsBloc>().currencyPosition;
    customFieldReInitialized =widget.customFieldsModel;
    if (widget.isCreate == false) {
      String formattedend = "";
      String formattedstart = "";

      if (widget.start != null &&
          widget.start!.isNotEmpty &&
          widget.start != "") {
        DateTime parsedDate = parseDateStringFromApi(widget.start!);
        formattedstart = dateFormatConfirmed(parsedDate, context);
        selectedDateStarts = parseDateStringFromApi(widget.start!);
      }
      if (widget.end != null && widget.end!.isNotEmpty && widget.end != "") {
        DateTime parsedDateEnd = parseDateStringFromApi(widget.end!);
        formattedend = dateFormatConfirmed(parsedDateEnd, context);
        selectedDateEnds = parsedDateEnd;
      }
      titleController = TextEditingController(text: widget.title);
      budgetController = TextEditingController(text: widget.budget);
      usersName = widget.userNames!;
      if (widget.canClientDiscuss == 1) {
        canClientDiscussWith = true;
      } else {
        canClientDiscussWith = false;
      }
      if (widget.enable == 1) {
        taskTimeEntries = true;
      } else {
        taskTimeEntries = false;
      }
      selectedClient = widget.clientNames!;
      selectedTag = widget.tagNames!;
      selectedStatus = widget.status;
      selectedaccess = widget.access;
      selectedPriority = widget.priority;
      startsController =
          TextEditingController(text: "$formattedstart - $formattedend");
      endController = TextEditingController(text: formattedend);
      descController =
          TextEditingController(text: removeHtmlTags(widget.desc!));
      noteController = TextEditingController(text: widget.note);
      _customFieldPage = CustomFieldPage(
        projectModel: customFieldReInitialized??ProjectModel.empty(),
        isCreate: widget.isCreate!,
        key: _customFieldPageKey,
      );
    } else {}
    super.initState();
  }

  void _handlePrioritySelected(String category, int catId) {
    setState(() {
      selectedPriority = category;
      selectedPriorityId = catId;
    });
  }

  void _handleTagsSelected(List<String> category, List<int> catId) {
    setState(() {
      selectedTag = category;
      selectedTagId = catId;
    });
  }

  void _handleClientSelected(List<String> category, List<int> catId) {
    setState(() {
      selectedClient = category;
      selectedClientId = catId;
    });
  }

  void _handleUsersSelected(List<String> category, List<int> catId) {
    setState(() {
      usersName = category;
      selectedusersNameId = catId;
    });
  }

  void canClientdiscussHandle(bool status) {
    setState(() {
      canClientDiscussWith = status;
    });
  }

  void canTaskLimitEntriesHandle(bool status) {
    setState(() {
      taskTimeEntries = status;
    });
  }

  void _handleStatusSelected(String category, int catId) {
    setState(() {
      selectedStatus = category;
      selectedStatusId = catId;
    });
  }

  void _handleAccessSelected(String category) {
    setState(() {
      selectedaccess = category;
    });
  }
  void _onCreate() {
    if (selectedaccess == "Project Users" || selectedaccess == "Assigned User") {
      selectedaccess = "project_users";
    }

    List<String> missingFields = [];

    // Check standard fields
    if (titleController.text.isEmpty) {
      missingFields.add(AppLocalizations.of(context)!.title);
    }
    if (selectedStatusId == null) {
      missingFields.add(AppLocalizations.of(context)!.status);
    }
    if (selectedaccess == null) {
      missingFields.add(AppLocalizations.of(context)!.taskaccessibility);
    }

    // Log custom fields for debugging
    // Log custom fields for debugging
    print("Custom Fields in ProjectModel: ${customFieldReInitialized?.customFields}");
    final customFieldValues = _customFieldPageKey.currentState?.getFieldValues();
    print("Current Custom Field Values: $customFieldValues");

    // Check custom fields validation
    bool customFieldsValid = _customFieldPageKey.currentState?.validateFields() ?? true;
    if (!customFieldsValid) {
      missingFields.add("Custom field(s)");
      print("Custom fields validation failed. Check CustomFieldPage for missing required fields.");
    }

    if (missingFields.isEmpty) {
      print("All validations passed. Submitting project...");
      context.read<ProjectBloc>().add(ProjectCreated(
        enable: taskTimeEntries ? 1 : 0,
        clientCanDiscuss: canClientDiscussWith ? 1 : 0,
        title: titleController.text,
        statusId: selectedStatusId!,
        priorityId: selectedPriorityId ?? 0,
        startDate: fromDate ?? "",
        endDate: toDate ?? "",
        desc: descController.text,
        userId: selectedusersNameId ?? [],
        taskAccess: selectedaccess!,
        note: noteController.text,
        budget: budgetController.text,
        clientId: selectedClientId ?? [],
        tagId: selectedTagId ?? [],
        customFieldValues: customFieldValues ?? {},
      ));

      context.read<ProjectBloc>().stream.listen((state) {
        if (state is ProjectCreateSuccess) {
          if (mounted) {
            flutterToastCustom(
              msg: AppLocalizations.of(context)!.createdsuccessfully,
              color: AppColors.primary,
            );
            if (widget.fromDetail == true) {
              BlocProvider.of<ProjectidBloc>(context)
                  .add(ProjectIdListId(widget.id));
              router.pop(context);
            } else {
              context.read<ProjectBloc>().add(ProjectDashBoardList());
              Navigator.of(context).pushReplacement(
                CupertinoPageRoute(
                  builder: (context) => const DashBoard(initialIndex: 1),
                ),
              );
            }
          }
        } else if (state is ProjectCreateLoading) {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(child: CircularProgressIndicator()),
            );
          }
        } else if (state is ProjectCreateError) {
          if (mounted) {
            Navigator.of(context).pop();
            flutterToastCustom(msg: state.errorMessage);
          }
        }
      });
    } else {
      print("Validation failed. Missing required fields: $missingFields");
      String errorMessage = "${AppLocalizations.of(context)!.pleasefilltherequiredfield}: ${missingFields.join(', ')}";
      flutterToastCustom(msg: errorMessage);
    }
  }

  void _onUpdateProject() {
    if (selectedaccess == "Project Users") {
      selectedaccess = "project_users";
    } else if (selectedaccess == "Assigned User") {
      selectedaccess = "project_users";
    }
    if (titleController.text.isNotEmpty) {
      final customFieldValues = _customFieldPage.getFieldValues();
      context.read<ProjectBloc>().add(UpdateProject(
            id: widget.id!,
            enable: taskTimeEntries ? 1 : 0,
            clientCanDiscuss: canClientDiscussWith ? 1 : 0,
            title: titleController.text,
            statusId:
                selectedStatusId == null ? widget.statusId! : selectedStatusId!,
            priorityId: selectedPriorityId == null
                ? widget.priorityId!
                : selectedPriorityId!,
            startDate: fromDate ?? widget.start!,
            endDate: toDate ?? widget.end!,
            desc: descController.text,
            userId: selectedusersNameId == null
                ? widget.userId!
                : selectedusersNameId!,
            taskAccess:
                selectedaccess == null ? widget.access! : selectedaccess!,
            note: noteController.text,
            budget: budgetController.text,
            clientId:
                selectedClientId == null ? widget.clientId! : selectedClientId!,
            tagId: selectedTagId == null ? widget.tagId! : selectedTagId!,
         customFieldValues: customFieldValues, // Add this
          ));
      context.read<ProjectBloc>().stream.listen((event) {
        if (event is ProjectEditSuccess) {
          if (mounted) {
            // isLoading = false;
            if (widget.fromDetail == true) {
              BlocProvider.of<ProjectidBloc>(context)
                  .add(ProjectIdListId(widget.id));
               router.pop(context);
            } else {
              BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) =>
                      const DashBoard(initialIndex: 1), // Navigate to index 1
                ),
              );
            }

            flutterToastCustom(
                msg: AppLocalizations.of(context)!.updatedsuccessfully,
                color: AppColors.primary);
          }


        }
        if (event is ProjectEditError) {
          flutterToastCustom(msg: event.errorMessage);
        }
      });
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    final isLightTheme = currentTheme is LightThemeState;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          if (widget.fromDetail == true && widget.isCreate == false) {
            BlocProvider.of<ProjectidBloc>(context)
                .add(ProjectIdListId(widget.id));
            router.pop(context);
          } else {
            router.pop(context);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _appBar(isLightTheme),
              SizedBox(height: 30.h),
              _body(isLightTheme, ),
              SizedBox(height: 50.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(isLightTheme, ) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child:
            BlocBuilder<ProjectBloc, ProjectState>(builder: (context, state) {

            if (state is ProjectLoading) {
              return SizedBox(
                height: MediaQuery.of(context).size.height, // Ensure defined height
                width: MediaQuery.of(context).size.width,  // Ensure defined width
                child: const NotesShimmer(),
              );

          }
          if (state is ProjectCreateLoading) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextFields(
                  title: AppLocalizations.of(context)!.title,
                  hinttext: AppLocalizations.of(context)!.pleaseentertitle,
                  controller: titleController,
                  onSaved: (value) {},
                  onFieldSubmitted: (value) {
                    _fieldFocusChange(
                      context,
                      titleFocus!,
                      budgetFocus,
                    );
                  },
                  isLightTheme: isLightTheme,
                  isRequired: true,
                ),
                SizedBox(
                  height: 15.h,
                ),
                CustomTextFields(
                    currency: true,
                    title: AppLocalizations.of(context)!.budget,
                    hinttext: AppLocalizations.of(context)!.pleaseenterbudget,
                    controller: budgetController,
                    onSaved: (value) {},
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (value) {
                      _fieldFocusChange(
                        context,
                        budgetFocus!,
                        descFocus,
                      );
                    },
                    isLightTheme: isLightTheme,
                    isRequired: false),
                SizedBox(
                  height: 15.h,
                ),
                UsersField(
                    isRequired: false,
                    isCreate: widget.isCreate!,
                    usersname: usersName ?? [],
                    usersid: widget.userId!,
                    project: const [],
                    onSelected: _handleUsersSelected),
                SizedBox(
                  height: 15.h,
                ),
                ClientField(
                    isCreate: widget.isCreate!,
                    usersname: selectedClient ?? [],
                    project: const [],
                    clientsid: widget.clientId!,
                    onSelected: _handleClientSelected),
                SizedBox(
                  height: 15.h,
                ),
                TagsField(
                    tagsid: widget.tagId ?? [],
                    isRequired: false,
                    isCreate: widget.isCreate!,
                    usersname: selectedTag ?? [],
                    project: const [],
                    index: widget.index,
                    onSelected: _handleTagsSelected),
                SizedBox(
                  height: 15.h,
                ),
                AccessibiltyField(
                  access: widget.access,
                  isRequired: true,
                  isCreate: widget.isCreate!,
                  name: selectedaccess ?? "",
                  index: widget.index!,
                  onSelected: _handleAccessSelected,
                ),
                SizedBox(
                  height: 15.h,
                ),
                StatusField(
                  status: widget.statusId,
                  isRequired: true,
                  isCreate: widget.isCreate!,
                  name: selectedStatus ?? "",
                  index: widget.index!,
                  onSelected: _handleStatusSelected,
                ),
                SizedBox(
                  height: 15.h,
                ),
                PriorityAllField(
                  priority: widget.priorityId,
                  isRequired: true,
                  isCreate: widget.isCreate!,
                  name: selectedPriority ?? "",
                  index: widget.index!,
                  onSelected: _handlePrioritySelected,
                ),
                SizedBox(
                  height: 15.h,
                ),
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
                    hinttext:
                        AppLocalizations.of(context)!.pleaseenterdescription,
                    controller: descController,
                    onSaved: (value) {},
                    onFieldSubmitted: (value) {
                      _fieldFocusChange(
                        context,
                        descFocus!,
                        startsFocus,
                      );
                    },
                    isLightTheme: isLightTheme,
                    isRequired: false),
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
                    onFieldSubmitted: (value) {
                      _fieldFocusChange(
                        context,
                        descFocus!,
                        startsFocus,
                      );
                    },
                    isLightTheme: isLightTheme,
                    isRequired: false),
                SizedBox(
                  height: 15.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: DateRangePickerWidget(
                    dateController: startsController,
                    title: AppLocalizations.of(context)!.starts,
                    titlestartend: AppLocalizations.of(context)!.selectstartenddate,
                    selectedDateEnds: selectedDateEnds,
                    selectedDateStarts: selectedDateStarts,
                    isLightTheme: isLightTheme,
                    onTap: (start, end) {
                      setState(() {
                        selectedDateEnds = end;
                        selectedDateStarts = start!;

                        // Update the startsController to show BOTH dates
                        startsController.text =
                        "${dateFormatConfirmed(selectedDateStarts, context)} - ${dateFormatConfirmed(selectedDateEnds!, context)}";

                        // Keep fromDate and toDate separately for API submission
                        fromDate = dateFormatConfirmedToApi(start);
                        toDate = dateFormatConfirmedToApi(end!);
                      });
                    },
                  ),
                ),


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
                CustomFieldPage(projectModel: customFieldReInitialized ?? ProjectModel(
                  id: 0,
                  title: "",
                  status: "",
                  statusId: 0,
                  priority: "",
                  taskCount: 0,
                  priorityId: 0,
                  users: [],
                  userId: [],
                  clients: [],
                  clientId: [],
                  tags: [],
                  tagIds: [],
                  startDate: "",
                  endDate: "",
                  budget: "",
                  taskAccessibility: "",
                  description: "",
                  note: "",
                  favorite: 0,
                  pinned: 0,
                  createdAt: "",
                  clientCanDiscuss: 0,
                  enable: 1,
                  updatedAt: "",
                  customFields: [],
                  customFieldValues: null,
                ), key: _customFieldPageKey, isCreate: widget.isCreate!,),

                CreateCancelButtom(
                  isLoading: true,
                  isCreate: widget.isCreate,
                  onpressCancel: () {
                    Navigator.pop(context);
                  },
                  onpressCreate: widget.isCreate == true
                      ? () async {
                          _onCreate();
                        }
                      : () {
                          _onUpdateProject();
                        },
                ),
                // CreateCancelButtom(),
              ],
            );
          }
          if (state is ProjectEditLoading) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextFields(
                  title: AppLocalizations.of(context)!.title,
                  hinttext: AppLocalizations.of(context)!.pleaseentertitle,
                  controller: titleController,
                  onSaved: (value) {},
                  onFieldSubmitted: (value) {
                    _fieldFocusChange(
                      context,
                      titleFocus!,
                      budgetFocus,
                    );
                  },
                  isLightTheme: isLightTheme,
                  isRequired: true,
                ),

                SizedBox(
                  height: 15.h,
                ),
                CustomTextFields(
                    currency: true,
                    title: AppLocalizations.of(context)!.budget,
                    hinttext: AppLocalizations.of(context)!.pleaseenterbudget,
                    controller: budgetController,
                    onSaved: (value) {},
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (value) {
                      _fieldFocusChange(
                        context,
                        budgetFocus!,
                        descFocus,
                      );
                    },
                    isLightTheme: isLightTheme,
                    isRequired: false),
                SizedBox(
                  height: 15.h,
                ),
                UsersField(
                    isRequired: false,
                    isCreate: widget.isCreate!,
                    usersname: usersName ?? [],
                    usersid: widget.userId!,
                    project: const [],
                    onSelected: _handleUsersSelected),
                SizedBox(
                  height: 15.h,
                ),
                ClientField(
                    isCreate: widget.isCreate!,
                    usersname: selectedClient ?? [],
                    project: const [],
                    clientsid: widget.clientId!,
                    onSelected: _handleClientSelected),
                SizedBox(
                  height: 15.h,
                ),
                TagsField(
                    tagsid: widget.tagId ?? [],
                    isRequired: false,
                    isCreate: widget.isCreate!,
                    usersname: selectedTag ?? [],
                    project: const [],
                    index: widget.index,
                    onSelected: _handleTagsSelected),
                SizedBox(
                  height: 15.h,
                ),
                AccessibiltyField(
                  access: widget.access,
                  isRequired: true,
                  isCreate: widget.isCreate!,
                  name: selectedaccess ?? "",
                  index: widget.index!,
                  onSelected: _handleAccessSelected,
                ),
                SizedBox(
                  height: 15.h,
                ),
                StatusField(
                  status: widget.statusId,
                  isRequired: true,
                  isCreate: widget.isCreate!,
                  name: selectedStatus ?? "",
                  index: widget.index!,
                  onSelected: _handleStatusSelected,
                ),
                SizedBox(
                  height: 15.h,
                ),
                PriorityAllField(
                  priority: widget.priorityId,
                  isRequired: true,
                  isCreate: widget.isCreate!,
                  name: selectedPriority ?? "",
                  index: widget.index!,
                  onSelected: _handlePrioritySelected,
                ),
                SizedBox(
                  height: 15.h,
                ),
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Row(
                    children: [
                      IsCustomSwitch(
                          isCreate: widget.isCreate,
                          status: taskTimeEntries,
                          onStatus: canTaskLimitEntriesHandle),
                      SizedBox(
                        width: 20.w,
                      ),
                      CustomText(
                        text: AppLocalizations.of(context)!.enable,
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
                    hinttext:
                        AppLocalizations.of(context)!.pleaseenterdescription,
                    controller: descController,
                    onSaved: (value) {},
                    onFieldSubmitted: (value) {
                      _fieldFocusChange(
                        context,
                        descFocus!,
                        startsFocus,
                      );
                    },
                    isLightTheme: isLightTheme,
                    isRequired: false),
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
                    onFieldSubmitted: (value) {
                      _fieldFocusChange(
                        context,
                        descFocus!,
                        startsFocus,
                      );
                    },
                    isLightTheme: isLightTheme,
                    isRequired: false),
                SizedBox(
                  height: 15.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: DateRangePickerWidget(
                    dateController: startsController,
                    title: AppLocalizations.of(context)!.starts,
                    titlestartend:
                        AppLocalizations.of(context)!.selectstartenddate,
                    selectedDateEnds: selectedDateEnds,
                    selectedDateStarts: selectedDateStarts,
                    isLightTheme: isLightTheme,
                    onTap: (start, end) {
                      if (start != null && end != null) {
                        setState(() {
                          selectedDateStarts = start;
                          selectedDateEnds = end;

                          // ✅ Convert for API
                          fromDate = dateFormatConfirmedToApi(start);
                          toDate = dateFormatConfirmedToApi(end);
                          print("fromDate: $fromDate");
                          print("toDate: $toDate");
                        });
                      }
                    },
                  ),
                ),

                // startsField(isLightTheme),

                // tagsField(isLightTheme),
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
                CustomFieldPage(projectModel: customFieldReInitialized ?? ProjectModel(
                  id: 0,
                  title: "",
                  status: "",
                  statusId: 0,
                  priority: "",
                  taskCount: 0,
                  priorityId: 0,
                  users: [],
                  userId: [],
                  clients: [],
                  clientId: [],
                  tags: [],
                  tagIds: [],
                  startDate: "",
                  endDate: "",
                  budget: "",
                  taskAccessibility: "",
                  description: "",
                  note: "",
                  favorite: 0,
                  pinned: 0,
                  createdAt: "",
                  clientCanDiscuss: 0,
                  enable: 1,
                  updatedAt: "",
                  customFields: [],
                  customFieldValues: null,
                ), key: _customFieldPageKey, isCreate: widget.isCreate!,),

                CreateCancelButtom(
                  isLoading: true,
                  isCreate: widget.isCreate,
                  onpressCancel: () {
                    Navigator.pop(context);
                  },
                  onpressCreate: widget.isCreate == true
                      ? () async {
                          _onCreate();
                        }
                      : () {
                          _onUpdateProject();
                        },
                ),
                // CreateCancelButtom(),
              ],
            );
          }
          if (state is ProjectSuccess) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextFields(
                  isPassword: false,
                  title: AppLocalizations.of(context)!.title,
                  hinttext: AppLocalizations.of(context)!.pleaseentertitle,
                  controller: titleController,
                  onSaved: (value) {},
                  onFieldSubmitted: (value) {},
                  isLightTheme: isLightTheme,
                ),
                SizedBox(
                  height: 15.h,
                ),
                CustomTextFields(
                    title: AppLocalizations.of(context)!.budget,
                    hinttext: AppLocalizations.of(context)!.pleaseenterbudget,
                    controller: budgetController,
                    onSaved: (value) {},
                    onFieldSubmitted: (value) {
                      _fieldFocusChange(
                        context,
                        budgetFocus!,
                        descFocus,
                      );
                    },
                    isLightTheme: isLightTheme,
                    isRequired: false),
                SizedBox(
                  height: 15.h,
                ),
                UsersField(
                    isRequired: false,
                    isCreate: widget.isCreate!,
                    usersname: usersName ?? [],
                    usersid: const [],
                    project: const [],
                    onSelected: _handleUsersSelected),
                SizedBox(
                  height: 15.h,
                ),

                ClientField(
                  isCreate: widget.isCreate!,
                  usersname: selectedClient ?? [],
                  project: const [],
                  clientsid: const [],
                  onSelected: _handleClientSelected,
                  isRequired: false,
                ),
                SizedBox(
                  height: 15.h,
                ),
                TagsField(
                    tagsid: widget.tagId ?? [],
                    isCreate: widget.isCreate!,
                    usersname: selectedTag ?? [],
                    project: const [],
                    index: widget.index,
                    onSelected: _handleTagsSelected),
                SizedBox(
                  height: 15.h,
                ),
                AccessibiltyField(
                  access: widget.access,
                  isRequired: true,
                  isCreate: widget.isCreate!,
                  name: selectedaccess ?? "",
                  index: widget.index!,
                  onSelected: _handleAccessSelected,
                ),
                SizedBox(
                  height: 15.h,
                ),
                StatusField(
                  status: widget.statusId,
                  isCreate: widget.isCreate!,
                  name: selectedStatus ?? "",
                  index: widget.index!,
                  onSelected: _handleStatusSelected,
                ),
                SizedBox(
                  height: 15.h,
                ),
                PriorityAllField(
                  isRequired: false,
                  priority: widget.priorityId,
                  isCreate: widget.isCreate!,
                  name: selectedPriority ?? "",
                  index: widget.index!,
                  onSelected: _handlePrioritySelected,
                ),
                SizedBox(
                  height: 15.h,
                ),
                CustomTextFields(
                    height: 112.h,
                    keyboardType: TextInputType.multiline,
                    title: AppLocalizations.of(context)!.description,
                    hinttext:
                        AppLocalizations.of(context)!.pleaseenterdescription,
                    controller: descController,
                    onSaved: (value) {},
                    onFieldSubmitted: (value) {
                      _fieldFocusChange(
                        context,
                        descFocus!,
                        startsFocus,
                      );
                    },
                    isLightTheme: isLightTheme,
                    isRequired: false),
                SizedBox(
                  height: 15.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: DateRangePickerWidget(
                    dateController: startsController,
                    title: AppLocalizations.of(context)!.starts,
                     titlestartend: AppLocalizations.of(context)!.selectstartenddate,
                    selectedDateEnds: selectedDateEnds,
                    selectedDateStarts: selectedDateStarts,
                    isLightTheme: isLightTheme,
                    onTap: (start, end) {
                      setState(() {
                        selectedDateEnds = end;
                        selectedDateStarts = start!;

                        // Update the startsController to show BOTH dates
                        startsController.text =
                        "${dateFormatConfirmed(selectedDateStarts, context)} - ${dateFormatConfirmed(selectedDateEnds!, context)}";

                        // Keep fromDate and toDate separately for API submission
                        fromDate = dateFormatConfirmedToApi(start);
                        toDate = dateFormatConfirmedToApi(end!);
                      });
                    },
                  ),
                ),

                // startsField(isLightTheme),

                // tagsField(isLightTheme),
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
                CustomFieldPage(projectModel: customFieldReInitialized ?? ProjectModel(
                  id: 0,
                  title: "",
                  status: "",
                  statusId: 0,
                  priority: "",
                  taskCount: 0,
                  priorityId: 0,
                  users: [],
                  userId: [],
                  clients: [],
                  clientId: [],
                  tags: [],
                  tagIds: [],
                  startDate: "",
                  endDate: "",
                  budget: "",
                  taskAccessibility: "",
                  description: "",
                  note: "",
                  favorite: 0,
                  pinned: 0,
                  createdAt: "",
                  clientCanDiscuss: 0,
                  enable: 1,
                  updatedAt: "",
                  customFields: [],
                  customFieldValues: null,
                ), key: _customFieldPageKey, isCreate: widget.isCreate!,),

                CreateCancelButtom(
                  isCreate: widget.isCreate,
                  onpressCancel: () {
                    Navigator.pop(context);
                  },
                  onpressCreate: widget.isCreate == true ? () async {} : () {},
                ),
              ],
            );
          } else if (state is ProjectPaginated) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextFields(
                  title: AppLocalizations.of(context)!.title,
                  hinttext: AppLocalizations.of(context)!.pleaseentertitle,
                  controller: titleController,
                  onSaved: (value) {},
                  onFieldSubmitted: (value) {
                    _fieldFocusChange(
                      context,
                      titleFocus!,
                      budgetFocus,
                    );
                  },
                  isLightTheme: isLightTheme,
                  isRequired: true,
                ),
                SizedBox(
                  height: 15.h,
                ),
                CustomTextFields(
                    currency: true,
                    title: AppLocalizations.of(context)!.budget,
                    hinttext: AppLocalizations.of(context)!.pleaseenterbudget,
                    controller: budgetController,
                    onSaved: (value) {},
                    keyboardType:
                        TextInputType.number, // Allow only numeric input
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly, // Only allow digits (0-9)
                    ],
                    onFieldSubmitted: (value) {
                      _fieldFocusChange(
                        context,
                        budgetFocus!,
                        descFocus,
                      );
                    },
                    isLightTheme: isLightTheme,
                    isRequired: false),
                SizedBox(
                  height: 15.h,
                ),
                UsersField(
                    isRequired: false,
                    isCreate: widget.isCreate!,
                    usersname: usersName ?? [],
                    usersid: widget.userId!,
                    project: const [],
                    onSelected: _handleUsersSelected),
                SizedBox(
                  height: 15.h,
                ),
                ClientField(
                    isCreate: widget.isCreate!,
                    usersname: selectedClient ?? [],
                    project: const [],
                    clientsid: widget.clientId!,
                    onSelected: _handleClientSelected),
                SizedBox(
                  height: 15.h,
                ),
                TagsField(
                    tagsid: widget.tagId ?? [],
                    isRequired: false,
                    isCreate: widget.isCreate!,
                    usersname: selectedTag ?? [],
                    project: const [],
                    index: widget.index,
                    onSelected: _handleTagsSelected),
                SizedBox(
                  height: 15.h,
                ),
                AccessibiltyField(
                  access: widget.access,
                  isRequired: true,
                  isCreate: widget.isCreate!,
                  name: selectedaccess ?? "",
                  index: widget.index!,
                  onSelected: _handleAccessSelected,
                ),
                SizedBox(
                  height: 15.h,
                ),
                StatusField(
                  status: widget.statusId,
                  isRequired: true,
                  isCreate: widget.isCreate!,
                  name: selectedStatus ?? "",
                  index: widget.index!,
                  onSelected: _handleStatusSelected,
                ),
                SizedBox(
                  height: 15.h,
                ),
                PriorityAllField(
                  priority: widget.priorityId,
                  isRequired: false,
                  isCreate: widget.isCreate!,
                  name: selectedPriority ?? "",
                  index: widget.index!,
                  onSelected: _handlePrioritySelected,
                ),
                SizedBox(
                  height: 15.h,
                ),
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: CustomText(
                    text: AppLocalizations.of(context)!.tasktimeentries,
                    color: Theme.of(context).colorScheme.textClrChange,
                    size: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Row(
                    children: [
                      IsCustomSwitch(
                          isCreate: widget.isCreate,
                          status: taskTimeEntries,
                          onStatus: canTaskLimitEntriesHandle),
                      SizedBox(
                        width: 20.w,
                      ),
                      CustomText(
                        text: AppLocalizations.of(context)!.enable,
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
                    hinttext:
                        AppLocalizations.of(context)!.pleaseenterdescription,
                    controller: descController,
                    onSaved: (value) {},
                    onFieldSubmitted: (value) {
                      _fieldFocusChange(
                        context,
                        descFocus!,
                        startsFocus,
                      );
                    },
                    isLightTheme: isLightTheme,
                    isRequired: false),
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
                    onFieldSubmitted: (value) {
                      _fieldFocusChange(
                        context,
                        descFocus!,
                        startsFocus,
                      );
                    },
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

                        // Update the startsController to show BOTH dates
                        startsController.text =
                        "${dateFormatConfirmed(selectedDateStarts, context)} - ${dateFormatConfirmed(selectedDateEnds!, context)}";

                        // Keep fromDate and toDate separately for API submission
                        fromDate = dateFormatConfirmedToApi(start);
                        toDate = dateFormatConfirmedToApi(end!);
                      });
                    },
                  ),
                ),
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
                CustomFieldPage(projectModel: customFieldReInitialized ?? ProjectModel(
                  id: 0,
                  title: "",
                  status: "",
                  statusId: 0,
                  priority: "",
                  taskCount: 0,
                  priorityId: 0,
                  users: [],
                  userId: [],
                  clients: [],
                  clientId: [],
                  tags: [],
                  tagIds: [],
                  startDate: "",
                  endDate: "",
                  budget: "",
                  taskAccessibility: "",
                  description: "",
                  note: "",
                  favorite: 0,
                  pinned: 0,
                  createdAt: "",
                  clientCanDiscuss: 0,
                  enable: 1,
                  updatedAt: "",
                  customFields: [],
                  customFieldValues: null,
                ), key: _customFieldPageKey, isCreate: widget.isCreate!,),

                SizedBox(
                  height: 15.h,
                ),
                CreateCancelButtom(
                  isCreate: widget.isCreate,
                  onpressCancel: () {
                    Navigator.pop(context);
                  },
                  onpressCreate: widget.isCreate == true
                      ? () async {
                          _onCreate();
                        }
                      : () {
                          _onUpdateProject();
                        },
                ),
                // CreateCancelButtom(),
              ],
            );
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFields(
                title: AppLocalizations.of(context)!.title,
                hinttext: AppLocalizations.of(context)!.pleaseentertitle,
                controller: titleController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {
                  _fieldFocusChange(
                    context,
                    titleFocus!,
                    budgetFocus,
                  );
                },
                isLightTheme: isLightTheme,
                isRequired: true,
              ),
              SizedBox(
                height: 15.h,
              ),
              CustomTextFields(
                  currency: true,
                  title: AppLocalizations.of(context)!.budget,
                  hinttext: AppLocalizations.of(context)!.pleaseenterbudget,
                  controller: budgetController,
                  onSaved: (value) {},
                  keyboardType:
                      TextInputType.number, // Allow only numeric input
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly, // Only allow digits (0-9)
                  ],
                  onFieldSubmitted: (value) {
                    _fieldFocusChange(
                      context,
                      budgetFocus!,
                      descFocus,
                    );
                  },
                  isLightTheme: isLightTheme,
                  isRequired: false),
              SizedBox(
                height: 15.h,
              ),
              UsersField(
                  isRequired: false,
                  isCreate: widget.isCreate!,
                  usersname: usersName ?? [],
                  usersid: widget.userId!,
                  project: const [],
                  onSelected: _handleUsersSelected),
              SizedBox(
                height: 15.h,
              ),
              ClientField(
                  isCreate: widget.isCreate!,
                  usersname: selectedClient ?? [],
                  project: const [],
                  clientsid: widget.clientId!,
                  onSelected: _handleClientSelected),
              SizedBox(
                height: 15.h,
              ),
              TagsField(
                  tagsid: widget.tagId ?? [],
                  isRequired: false,
                  isCreate: widget.isCreate!,
                  usersname: selectedTag ?? [],
                  project: const [],
                  index: widget.index,
                  onSelected: _handleTagsSelected),
              SizedBox(
                height: 15.h,
              ),
              AccessibiltyField(
                access: widget.access,
                isRequired: true,
                isCreate: widget.isCreate!,
                name: selectedaccess ?? "",
                index: widget.index!,
                onSelected: _handleAccessSelected,
              ),
              SizedBox(
                height: 15.h,
              ),
              StatusField(
                status: widget.statusId,
                isRequired: true,
                isCreate: widget.isCreate!,
                name: selectedStatus ?? "",
                index: widget.index!,
                onSelected: _handleStatusSelected,
              ),
              SizedBox(
                height: 15.h,
              ),
              PriorityAllField(
                priority: widget.priorityId,
                isRequired: false,
                isCreate: widget.isCreate!,
                name: selectedPriority ?? "",
                index: widget.index!,
                onSelected: _handlePrioritySelected,
              ),
              SizedBox(
                height: 15.h,
              ),
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Row(
                  children: [
                    IsCustomSwitch(
                        isCreate: widget.isCreate,
                        status: taskTimeEntries,
                        onStatus: canTaskLimitEntriesHandle),
                    SizedBox(
                      width: 20.w,
                    ),
                    CustomText(
                      text: AppLocalizations.of(context)!.enable,
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
                  hinttext:
                      AppLocalizations.of(context)!.pleaseenterdescription,
                  controller: descController,
                  onSaved: (value) {},
                  onFieldSubmitted: (value) {
                    _fieldFocusChange(
                      context,
                      descFocus!,
                      startsFocus,
                    );
                  },
                  isLightTheme: isLightTheme,
                  isRequired: false),
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
                  onFieldSubmitted: (value) {
                    _fieldFocusChange(
                      context,
                      descFocus!,
                      startsFocus,
                    );
                  },
                  isLightTheme: isLightTheme,
                  isRequired: false),
              SizedBox(
                height: 15.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: DateRangePickerWidget(
                  dateController: startsController, // Show both dates here
                  title: AppLocalizations.of(context)!.starts,

             titlestartend: AppLocalizations.of(context)!.selectstartenddate,
                    selectedDateEnds: selectedDateEnds,
                    selectedDateStarts: selectedDateStarts,
                    isLightTheme: isLightTheme,
                    onTap: (start, end) {
                      setState(() {
                        selectedDateEnds = end;
                        selectedDateStarts = start!;

                        // Update the startsController to show BOTH dates
                        startsController.text =
                        "${dateFormatConfirmed(selectedDateStarts, context)} - ${dateFormatConfirmed(selectedDateEnds!, context)}";

                        // Keep fromDate and toDate separately for API submission
                        fromDate = dateFormatConfirmedToApi(start);
                        toDate = dateFormatConfirmedToApi(end!);
                      });
                    },
                ),
              ),

              // startsField(isLightTheme),
              SizedBox(
                height: 15.h,
              ),
              // Padding(
              //   padding:  EdgeInsets.symmetric(horizontal: 18.w),
              //   child: DatePickerWidget(
              //     dateController: endController,
              //     title: AppLocalizations.of(context)!.ends,
              //     isLightTheme: isLightTheme,
              //   ),
              // ),
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
                CustomFieldPage(projectModel: customFieldReInitialized ?? ProjectModel(
                id: 0,
                title: "",
                status: "",
                statusId: 0,
                priority: "",
                taskCount: 0,
                priorityId: 0,
                users: [],
                userId: [],
                clients: [],
                clientId: [],
                tags: [],
                tagIds: [],
                startDate: "",
                endDate: "",
                budget: "",
                taskAccessibility: "",
                description: "",
                note: "",
                favorite: 0,
                pinned: 0,
                createdAt: "",
                clientCanDiscuss: 0,
                enable: 1,
                updatedAt: "",
                customFields: [],
                customFieldValues:null,
              ), key: _customFieldPageKey, isCreate: widget.isCreate!,),


              // tagsField(isLightTheme),
              SizedBox(
                height: 15.h,
              ),
              CreateCancelButtom(
                isCreate: widget.isCreate,
                onpressCancel: () {
                  Navigator.pop(context);
                },
                onpressCreate: widget.isCreate == true
                    ? () async {
                        _onCreate();
                      }
                    : () {
                        _onUpdateProject();
                      },
              ),
              // CreateCancelButtom(),
            ],
          );
        }),
      ),
    );
  }

  Widget _appBar(isLightTheme) {
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
                          BlocProvider.of<ProjectidBloc>(context)
                              .add(ProjectIdListId(widget.id));
                          router.pop(context);
                        } else {
                          router.pop(context);
                        }
                      },
                      child: BackArrow(
                        title: widget.isCreate == false
                            ? AppLocalizations.of(context)!.editproject
                            : AppLocalizations.of(context)!.createproject,
                      ),
                    )),
              ],
            ))
      ],
    );
  }
}
