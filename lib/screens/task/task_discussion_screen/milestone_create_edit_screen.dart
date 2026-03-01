import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/model/project/milestone.dart';
import 'package:taskify/screens/project/discussion_screen/widgets/status.dart';

import '../../../bloc/project_discussion/project_milestone/project_milestone_bloc.dart';
import '../../../bloc/project_discussion/project_milestone/project_milestone_event.dart';
import '../../../bloc/project_discussion/project_milestone/project_milestone_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/constants.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../routes/routes.dart';
import '../../../utils/widgets/back_arrow.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/widgets/toast_widget.dart';
import '../../style/design_config.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../widgets/custom_date.dart';
import '../../widgets/custom_textfields/custom_textfield.dart';

class MilestoneCreateEditScreen extends StatefulWidget {
  final bool? isCreate;
  final Milestone milestoneModel;
  final int projectId;
  const MilestoneCreateEditScreen(
      {super.key,
      this.isCreate,
      required this.milestoneModel,
      required this.projectId});

  @override
  State<MilestoneCreateEditScreen> createState() =>
      _MilestoneCreateEditScreenState();
}

class _MilestoneCreateEditScreenState extends State<MilestoneCreateEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController budgetController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController startsController = TextEditingController();
  TextEditingController endController = TextEditingController();

  DateTime selectedDateStarts = DateTime.now();
  DateTime? selectedDateEnds = DateTime.now();
  String? fromDate;
  String? toDate;
  String? selectedStatus;
  double _value = 0;
  String? formattedend;
  String? formattedstart;

  @override
  void initState() {
    if (widget.isCreate == false) {
      if (widget.milestoneModel.startDate != null &&
          widget.milestoneModel.startDate!.isNotEmpty &&
          widget.milestoneModel.startDate != "") {
        DateTime parsedDateStart =
            parseDateStringFromApi(widget.milestoneModel.startDate!);
        formattedstart = dateFormatConfirmed(parsedDateStart, context);
        selectedDateStarts = parsedDateStart;
        "${dateFormatConfirmed(selectedDateStarts, context)}  ↔️  ${dateFormatConfirmed(selectedDateEnds!, context)}";
      }
      if (widget.milestoneModel.endDate != null &&
          widget.milestoneModel.endDate!.isNotEmpty &&
          widget.milestoneModel.endDate != "") {
        DateTime parsedDateEnd =
            parseDateStringFromApi(widget.milestoneModel.endDate!);
        formattedend = dateFormatConfirmed(parsedDateEnd, context);
        selectedDateEnds = parsedDateEnd;
        startsController.text =
            "${dateFormatConfirmed(selectedDateStarts, context)}  ↔️  ${dateFormatConfirmed(selectedDateEnds!, context)}";
      }
      titleController =
          TextEditingController(text: widget.milestoneModel.title);
      budgetController =
          TextEditingController(text: widget.milestoneModel.cost);
      descController = TextEditingController(
          text: removeHtmlTags(widget.milestoneModel.description!));
      selectedStatus = widget.milestoneModel.status;
      _value = widget.milestoneModel.progress!.toDouble() / 100;
    }

    super.initState();
  }

  void _handleStatusSelected(String category) {
    setState(() {
      selectedStatus = category;
    });
  }

  void _onUpdateProjectMileStone() {
    if (titleController.text.isNotEmpty &&
        budgetController.text.isNotEmpty &&
        selectedStatus != null) {
      context.read<ProjectMilestoneBloc>().add(UpdateMilestoneProject(
            projectId: widget.projectId,
            id: widget.milestoneModel.id!,
            title: titleController.text,
            progress: _value.toInt(),
            startDate: formattedstart ?? widget.milestoneModel.startDate!,
            endDate: formattedend ?? widget.milestoneModel.endDate!,
            desc: descController.text,
            status: selectedStatus ?? widget.milestoneModel.status!,
            cost: budgetController.text,
          ));
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  void _onAddProjectMileStone() {
    if (titleController.text.isNotEmpty &&
        budgetController.text.isNotEmpty &&
        selectedStatus != null) {
      context.read<ProjectMilestoneBloc>().add(ProjectMilestoneCreated(
            projId: widget.projectId,
            title: titleController.text,
            startDate: fromDate ?? "",
            endDate: toDate ?? "",
            desc: descController.text.isNotEmpty ? descController.text : "",
            status: selectedStatus ?? "",
            cost: budgetController.text.isNotEmpty ? budgetController.text : "",
          ));
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

    bool isLightTheme = currentTheme is LightThemeState;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          router.pop(context);
          router.replace('/project');
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _appBar(isLightTheme),
              SizedBox(height: 30.h),
              _body(isLightTheme),
              SizedBox(height: 50.h),
            ],
          ),
        ),
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
                        // if (widget.fromDetail == true && widget.isCreate == false) {
                        //
                        //   BlocProvider.of<ProjectidBloc>(context).add(ProjectIdListId(widget.id));
                        //   router.pop(context);
                        // } else {
                        //   router.pop(context);
                        // }
                      },
                      child: BackArrow(
                        title: widget.isCreate == false
                            ? AppLocalizations.of(context)!.editmilestone
                            : AppLocalizations.of(context)!.createmilestone,
                      ),
                    )),
              ],
            ))
      ],
    );
  }

  Widget _body(isLightTheme) {
    return SingleChildScrollView(
      child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFields(
                title: AppLocalizations.of(context)!.title,
                hinttext: AppLocalizations.of(context)!.pleaseentertitle,
                controller: titleController,
                onSaved: (value) {},
                isLightTheme: isLightTheme,
                isRequired: true,
              ),
              SizedBox(
                height: 15.h,
              ),
              CustomTextFields(
                  currency: true,
                  title: AppLocalizations.of(context)!.cost,
                  hinttext: AppLocalizations.of(context)!.pleaseentercost,
                  controller: budgetController,
                  onSaved: (value) {},
                  keyboardType: TextInputType.number,
                  isLightTheme: isLightTheme,
                  isRequired: true),
              SizedBox(
                height: 15.h,
              ),
              StatusOfMileStone(
                isRequired: true,
                isCreate: widget.isCreate!,
                statusName: selectedStatus ?? "",
                onSelected: _handleStatusSelected,
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
                  isLightTheme: isLightTheme,
                  isRequired: false),

              SizedBox(
                height: 15.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: DateRangePickerWidget(
                  dateController: startsController,
                  title: AppLocalizations.of(context)!.date,
                  titlestartend:
                      AppLocalizations.of(context)!.selectstartenddate,
                  selectedDateEnds: selectedDateEnds,
                  selectedDateStarts: selectedDateStarts,
                  isLightTheme: isLightTheme,
                  onTap: (start, end) {
                    if (start != null && end != null) {
                      setState(() {
                        // Ensure the start date is not before the current date

                        // If the end date is not selected or is null, set it to the start date
                        if (selectedDateEnds == null) {
                          end = start; // Set the end date to the start date if not selected
                        }
                        selectedDateEnds = end;
                        selectedDateStarts = start;
                        startsController.text =
                            "${dateFormatConfirmed(start, context)}  ↔️  ${dateFormatConfirmed(end!, context)}";
                        fromDate = dateFormatConfirmedToApi(start);
                        toDate = dateFormatConfirmedToApi(end!);
                      });
                    }
                  },
                  // onTap: () {
                  //   // showCustomDateRangePicker(
                  //   //   context,
                  //   //   dismissible: true,
                  //   //   // Prevent selecting before current date
                  //   //   minimumDate: DateTime(1900),
                  //   //   maximumDate: DateTime(9999),
                  //   //   endDate: selectedDateEnds,
                  //   //   startDate: selectedDateStarts,
                  //   //   backgroundColor:
                  //   //       Theme.of(context).colorScheme.containerDark,
                  //   //   primaryColor: AppColors.primary,
                  //   //   onApplyClick: (start, end) {
                  //   //     setState(() {
                  //   //       // Ensure the start date is not before the current date
                  //   //
                  //   //       // If the end date is not selected or is null, set it to the start date
                  //   //       if (selectedDateEnds == null) {
                  //   //         end =
                  //   //             start; // Set the end date to the start date if not selected
                  //   //       }
                  //   //       selectedDateEnds = end;
                  //   //       selectedDateStarts = start;
                  //   //       startsController.text =
                  //   //           "${dateFormatConfirmed(start, context)}  ↔️  ${dateFormatConfirmed(end, context)}";
                  //   //
                  //   //       // startsController.text =
                  //   //       //     dateFormatConfirmed(selectedDateStarts, context);
                  //   //       // endController.text =
                  //   //       //     dateFormatConfirmed(selectedDateEnds!, context);
                  //   //       fromDate = dateFormatConfirmed(start, context);
                  //   //       toDate = dateFormatConfirmed(end, context);
                  //   //     });
                  //   //   },
                  //   //   onCancelClick: () {
                  //   //     setState(() {
                  //   //       // Handle cancellation if necessary
                  //   //     });
                  //   //   },
                  //   // );
                  // },
                  // isLightTheme: isLightTheme,
                ),
              ),
              SizedBox(
                height: 15.h,
              ),
              widget.isCreate == false
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          child: CustomText(
                            text: AppLocalizations.of(context)!.progress,
                            size: 14.sp,
                            color: Theme.of(context).colorScheme.textClrChange,
                            fontWeight: FontWeight.w700,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _value,
                                onChanged: (v) => setState(() => _value = v),
                                label: _value.toStringAsFixed(2),
                              ),
                            ),
                            CustomText(
                              text: "${(_value * 100).toStringAsFixed(0)}%",
                              size: 15.sp,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
              SizedBox(
                height: 15.h,
              ),
              BlocBuilder<ProjectMilestoneBloc, ProjectMilestoneState>(
                builder: (context, state) {
                  if (state is ProjectMilestoneMileStonePaginated) {
                    return CreateCancelButtom(
                      isLoading: false,
                      isCreate: widget.isCreate,
                      onpressCancel: () {
                        Navigator.pop(context);
                      },
                      onpressCreate: widget.isCreate == true
                          ? () async {
                              // _onCreate();
                            }
                          : () {
                              _onUpdateProjectMileStone();
                            },
                    );
                  }
                  if (state is ProjectMilestoneCreateSuccess) {
                    Navigator.pop(context);
                    flutterToastCustom(
                        msg: AppLocalizations.of(context)!.createdsuccessfully,
                        color: AppColors.primary);
                    BlocProvider.of<ProjectMilestoneBloc>(context)
                        .add(MileStoneList());
                  }
                  if (state is ProjectMilestoneCreateError) {
                    flutterToastCustom(
                        msg: state.errorMessage, color: AppColors.primary);
                    BlocProvider.of<ProjectMilestoneBloc>(context)
                        .add(MileStoneList());
                  }
                  if (state is ProjectMilestoneEditSuccess) {
                    BlocProvider.of<ProjectMilestoneBloc>(context)
                        .add(MileStoneList());
                    router.pop(context);
                  }
                  return CreateCancelButtom(
                    isLoading: false,
                    isCreate: widget.isCreate,
                    onpressCancel: () {
                      Navigator.pop(context);
                    },
                    onpressCreate: widget.isCreate == true
                        ? () async {
                            _onAddProjectMileStone();
                          }
                        : () {
                            _onUpdateProjectMileStone();
                          },
                  );
                },
              ),
              // CreateCancelButtom(),
            ],
          )),
    );
  }
}
