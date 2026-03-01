import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/colors.dart';
import '../../../bloc/Project/project_state.dart';
import '../../../bloc/single_select_project/single_select_project_bloc.dart';
import '../../../bloc/single_select_project/single_select_project_event.dart';
import '../../../bloc/single_select_project/single_select_project_state.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/no_data.dart';
import '../../widgets/custom_cancel_create_button.dart';

class ProjectField extends StatefulWidget {
  final bool isCreate;
  final bool openDropdown;
  final String? name;
  final int? project;
  final bool? isRequired;
  // final List<StatusModel> status;
  final int? index;
  final Function(String, int) onSelected;
  const ProjectField(
      {super.key,
      this.name,
      this.openDropdown=false,
      required this.isCreate,
      required this.project,
      this.isRequired,
      required this.index,
      required this.onSelected});

  @override
  State<ProjectField> createState() => _ProjectFieldState();
}

class _ProjectFieldState extends State<ProjectField> {
  String? projectsname;
  int? projectsId;
  bool isLoadingMore = false;
  String searchWord = "";

  String? name;
  final TextEditingController _projectSearchController =
      TextEditingController();
  @override
  void initState() {
    name = widget.name!;
    if (!widget.isCreate) {
      projectsId = widget.project;
      projectsname=widget.name;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),
          child: Row(
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.project,
                // text: getTranslated(context, 'myweeklyTask'),
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
              widget.isRequired == true
                  ? CustomText(
                      text: " *",
                      // text: getTranslated(context, 'myweeklyTask'),
                      color: AppColors.red,
                      size: 15,
                      fontWeight: FontWeight.w400,
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        BlocBuilder<SingleSelectProjectBloc, SingleSelectProjectState>(
          builder: (context, state) {
            print("fsdfr $state");
            if (state is SingleProjectInitial) {
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      highlightColor: Colors.transparent, // No highlight on tap
                      splashColor: Colors.transparent,
                      onTap: () {
                        _projectSearchController.clear();

                        // Fetch initial project list
                        widget.isCreate == false
                            ? SizedBox()
                            : context
                                .read<SingleSelectProjectBloc>()
                                .add(SingleProjectList());
                        widget.isCreate == false
                            ? SizedBox()
                            : showDialog(
                                context: context,
                                builder: (ctx) => BlocConsumer<
                                    SingleSelectProjectBloc,
                                    SingleSelectProjectState>(
                                  listener: (context, state) {
                                    if (state is SingleProjectSuccess) {
                                      isLoadingMore = false;
                                      setState(() {});
                                    }
                                  },
                                  builder: (context, state) {
                                    if (state is SingleProjectSuccess) {
                                      return NotificationListener<
                                              ScrollNotification>(
                                          onNotification: (scrollInfo) {
                                            // Check if the user has scrolled to the end and load more notes if needed
                                            if (!state.hasReachedMax &&
                                                scrollInfo.metrics.pixels ==
                                                    scrollInfo.metrics
                                                        .maxScrollExtent) {
                                              // isLoadingMore = true;
                                              setState(() {});
                                              context
                                                  .read<
                                                      SingleSelectProjectBloc>()
                                                  .add(SingleProjectLoadMore(
                                                      searchWord));
                                            }
                                            // isLoadingMore = false;
                                            return false;
                                          },
                                          child: AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  10.r), // Set the desired radius here
                                            ),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .alertBoxBackGroundColor,
                                            contentPadding: EdgeInsets.zero,
                                            title: Center(
                                              child: Column(
                                                children: [
                                                  CustomText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .selectprojects,
                                                    fontWeight: FontWeight.w800,
                                                    size: 20,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .whitepurpleChange,
                                                  ),
                                                  const Divider(),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 0.w),
                                                    child: SizedBox(
                                                      // color: Colors.red,
                                                      height: 35.h,
                                                      width: double.infinity,
                                                      child: TextField(
                                                        cursorColor: AppColors
                                                            .greyForgetColor,
                                                        cursorWidth: 1,
                                                        controller:
                                                            _projectSearchController,
                                                        decoration:
                                                            InputDecoration(
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                            vertical:
                                                                (35.h - 20.sp) /
                                                                    2,
                                                            horizontal: 10.w,
                                                          ),
                                                          hintText:
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .search,
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: AppColors
                                                                  .greyForgetColor, // Set your desired color here
                                                              width:
                                                                  1.0, // Set the border width if needed
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0), // Optional: adjust the border radius
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            borderSide:
                                                                BorderSide(
                                                              color: AppColors
                                                                  .purple, // Border color when TextField is focused
                                                              width: 1.0,
                                                            ),
                                                          ),
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            searchWord = value;
                                                          });
                                                          context
                                                              .read<
                                                                  SingleSelectProjectBloc>()
                                                              .add(
                                                                  SearchSingleProject(
                                                                      value));
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 20.h,
                                                  )
                                                ],
                                              ),
                                            ),
                                            content: Container(
                                              constraints: BoxConstraints(
                                                  maxHeight: 900.h),
                                              width: 200.w,
                                              child: state
                                                  .project.isEmpty?NoData(isImage: true,):ListView.builder(
                                                // physics: const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: state.hasReachedMax
                                                    ? state.project.length
                                                    : state.project.length + 1,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  if (index <
                                                      state.project.length) {
                                                    final isSelected =
                                                        projectsId != null &&
                                                            state.project[index]
                                                                    .id ==
                                                                projectsId;
                                                    return Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 2.h,
                                                              horizontal: 20.w),
                                                      child: InkWell(
                                                        highlightColor: Colors
                                                            .transparent, // No highlight on tap
                                                        splashColor:
                                                            Colors.transparent,
                                                        onTap: () {
                                                          setState(() {
                                                            if (widget
                                                                    .isCreate ==
                                                                true) {
                                                              projectsname =
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!;
                                                              projectsId = state
                                                                  .project[
                                                                      index]
                                                                  .id!;
                                                              widget.onSelected(
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!,
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .id!);
                                                            } else {
                                                              name = state
                                                                  .project[
                                                                      index]
                                                                  .title!;
                                                              projectsname =
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!;
                                                              projectsId = state
                                                                  .project[
                                                                      index]
                                                                  .id!;
                                                              widget.onSelected(
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!,
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .id!);
                                                            }
                                                          });

                                                          BlocProvider.of<
                                                                      SingleSelectProjectBloc>(
                                                                  context)
                                                              .add(SelectSingleProject(
                                                                  index,
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!));

                                                          BlocProvider.of<
                                                                      SingleSelectProjectBloc>(
                                                                  context)
                                                              .add(SelectSingleProject(
                                                                  index,
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!));
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color: isSelected
                                                                  ? AppColors
                                                                      .purpleShade
                                                                  : Colors
                                                                      .transparent,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  color: isSelected
                                                                      ? AppColors
                                                                          .primary
                                                                      : Colors
                                                                          .transparent)),
                                                          width:
                                                              double.infinity,
                                                          height: 40.h,
                                                          child: Center(
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          10.w),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    flex: 4,
                                                                    // width:200.w,
                                                                    child:
                                                                        CustomText(
                                                                      text: state
                                                                          .project[
                                                                              index]
                                                                          .title!,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      size: 18,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      color: isSelected
                                                                          ? AppColors
                                                                              .purple
                                                                          : Theme.of(context)
                                                                              .colorScheme
                                                                              .textClrChange,
                                                                    ),
                                                                  ),
                                                                  isSelected
                                                                      ? Expanded(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              const HeroIcon(
                                                                            HeroIcons.checkCircle,
                                                                            style:
                                                                                HeroIconStyle.solid,
                                                                            color:
                                                                                AppColors.purple,
                                                                          ),
                                                                        )
                                                                      : const SizedBox
                                                                          .shrink(),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    // Show a loading indicator when more notes are being loaded
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 0),
                                                      child: Center(
                                                        child: state
                                                                .hasReachedMax
                                                            ? const Text('')
                                                            : const SpinKitFadingCircle(
                                                                color: AppColors
                                                                    .primary,
                                                                size: 40.0,
                                                              ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            actions: <Widget>[
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 20.h),
                                                child: CreateCancelButtom(
                                                  title: "OK",
                                                  onpressCancel: () {
                                                    _projectSearchController
                                                        .clear();
                                                    Navigator.pop(context);
                                                  },
                                                  onpressCreate: () {
                                                    _projectSearchController
                                                        .clear();
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ));
                                    }
                                    return const Center(
                                        child: Text('Loading...'));
                                  },
                                ),
                              );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        height: 40.h,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: widget.isCreate == true
                              ? Colors.transparent
                              : Theme.of(context).colorScheme.textfieldDisabled,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.greyColor),
                        ),
                        // decoration: DesignConfiguration.shadow(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CustomText(
                                text: widget.isCreate
                                    ? (projectsname?.isEmpty ?? true
                                        ? "Select Project"
                                        : projectsname!)
                                    : (projectsname?.isEmpty ?? true
                                        ? widget.name!
                                        : projectsname!),
                                fontWeight: FontWeight.w500,
                                size: 14.sp,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                              ),
                            ),
                            widget.isCreate == false
                                ? SizedBox()
                                : Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
            else if (state is SingleProjectLoading) {
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      highlightColor: Colors.transparent, // No highlight on tap
                      splashColor: Colors.transparent,
                      onTap: () {
                        _projectSearchController.clear();

                        // Fetch initial project list
                        widget.isCreate == false
                            ? SizedBox()
                            : context
                                .read<SingleSelectProjectBloc>()
                                .add(SingleProjectList());
                        widget.isCreate == false
                            ? SizedBox()
                            : showDialog(
                                context: context,
                                builder: (ctx) => BlocConsumer<
                                    SingleSelectProjectBloc,
                                    SingleSelectProjectState>(
                                  listener: (context, state) {
                                    if (state is SingleProjectSuccess) {
                                      isLoadingMore = false;
                                      setState(() {});
                                    }
                                  },
                                  builder: (context, state) {
                                    if (state is SingleProjectSuccess) {
                                      return NotificationListener<
                                              ScrollNotification>(
                                          onNotification: (scrollInfo) {
                                            // Check if the user has scrolled to the end and load more notes if needed
                                            if (!state.hasReachedMax &&
                                                scrollInfo.metrics.pixels ==
                                                    scrollInfo.metrics
                                                        .maxScrollExtent) {
                                              // isLoadingMore = true;
                                              setState(() {});
                                              context
                                                  .read<
                                                      SingleSelectProjectBloc>()
                                                  .add(SingleProjectLoadMore(
                                                      searchWord));
                                            }
                                            // isLoadingMore = false;
                                            return false;
                                          },
                                          child: AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  10.r), // Set the desired radius here
                                            ),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .alertBoxBackGroundColor,
                                            contentPadding: EdgeInsets.zero,
                                            title: Center(
                                              child: Column(
                                                children: [
                                                  CustomText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .selectprojects,
                                                    fontWeight: FontWeight.w800,
                                                    size: 20,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .whitepurpleChange,
                                                  ),
                                                  const Divider(),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 0.w),
                                                    child: SizedBox(
                                                      // color: Colors.red,
                                                      height: 35.h,
                                                      width: double.infinity,
                                                      child: TextField(
                                                        cursorColor: AppColors
                                                            .greyForgetColor,
                                                        cursorWidth: 1,
                                                        controller:
                                                            _projectSearchController,
                                                        decoration:
                                                            InputDecoration(
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                            vertical:
                                                                (35.h - 20.sp) /
                                                                    2,
                                                            horizontal: 10.w,
                                                          ),
                                                          hintText:
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .search,
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: AppColors
                                                                  .greyForgetColor, // Set your desired color here
                                                              width:
                                                                  1.0, // Set the border width if needed
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0), // Optional: adjust the border radius
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            borderSide:
                                                                BorderSide(
                                                              color: AppColors
                                                                  .purple, // Border color when TextField is focused
                                                              width: 1.0,
                                                            ),
                                                          ),
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            searchWord = value;
                                                          });
                                                          context
                                                              .read<
                                                                  SingleSelectProjectBloc>()
                                                              .add(
                                                                  SearchSingleProject(
                                                                      value));
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 20.h,
                                                  )
                                                ],
                                              ),
                                            ),
                                            content: Container(
                                              constraints: BoxConstraints(
                                                  maxHeight: 900.h),
                                              width: 200.w,
                                              child:state
                                                  .project.isEmpty?NoData(isImage: true,): ListView.builder(
                                                // physics: const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: state.hasReachedMax
                                                    ? state.project.length
                                                    : state.project.length + 1,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  if (index <
                                                      state.project.length) {
                                                    final isSelected =
                                                        projectsId != null &&
                                                            state.project[index]
                                                                    .id ==
                                                                projectsId;
                                                    return Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 2.h,
                                                              horizontal: 20.w),
                                                      child: InkWell(
                                                        highlightColor: Colors
                                                            .transparent, // No highlight on tap
                                                        splashColor:
                                                            Colors.transparent,
                                                        onTap: () {
                                                          setState(() {
                                                            if (widget
                                                                    .isCreate ==
                                                                true) {
                                                              projectsname =
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!;
                                                              projectsId = state
                                                                  .project[
                                                                      index]
                                                                  .id!;
                                                              widget.onSelected(
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!,
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .id!);
                                                            } else {
                                                              name = state
                                                                  .project[
                                                                      index]
                                                                  .title!;
                                                              projectsname =
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!;
                                                              projectsId = state
                                                                  .project[
                                                                      index]
                                                                  .id!;
                                                              widget.onSelected(
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!,
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .id!);
                                                            }
                                                          });

                                                          BlocProvider.of<
                                                                      SingleSelectProjectBloc>(
                                                                  context)
                                                              .add(SelectSingleProject(
                                                                  index,
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!));

                                                          BlocProvider.of<
                                                                      SingleSelectProjectBloc>(
                                                                  context)
                                                              .add(SelectSingleProject(
                                                                  index,
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!));
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color: isSelected
                                                                  ? AppColors
                                                                      .purpleShade
                                                                  : Colors
                                                                      .transparent,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  color: isSelected
                                                                      ? AppColors
                                                                          .primary
                                                                      : Colors
                                                                          .transparent)),
                                                          width:
                                                              double.infinity,
                                                          height: 40.h,
                                                          child: Center(
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          10.w),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    flex: 4,
                                                                    // width:200.w,
                                                                    child:
                                                                        CustomText(
                                                                      text: state
                                                                          .project[
                                                                              index]
                                                                          .title!,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      size: 18,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      color: isSelected
                                                                          ? AppColors
                                                                              .purple
                                                                          : Theme.of(context)
                                                                              .colorScheme
                                                                              .textClrChange,
                                                                    ),
                                                                  ),
                                                                  isSelected
                                                                      ? Expanded(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              const HeroIcon(
                                                                            HeroIcons.checkCircle,
                                                                            style:
                                                                                HeroIconStyle.solid,
                                                                            color:
                                                                                AppColors.purple,
                                                                          ),
                                                                        )
                                                                      : const SizedBox
                                                                          .shrink(),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    // Show a loading indicator when more notes are being loaded
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 0),
                                                      child: Center(
                                                        child: state
                                                                .hasReachedMax
                                                            ? const Text('')
                                                            : const SpinKitFadingCircle(
                                                                color: AppColors
                                                                    .primary,
                                                                size: 40.0,
                                                              ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            actions: <Widget>[
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 20.h),
                                                child: CreateCancelButtom(
                                                  title: "OK",
                                                  onpressCancel: () {
                                                    _projectSearchController
                                                        .clear();
                                                    Navigator.pop(context);
                                                  },
                                                  onpressCreate: () {
                                                    _projectSearchController
                                                        .clear();
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ));
                                    }
                                    return const Center(
                                        child: Text('Loading...'));
                                  },
                                ),
                              );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        height: 40.h,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: widget.isCreate == true
                              ? Colors.transparent
                              : Theme.of(context).colorScheme.textfieldDisabled,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.greyColor),
                        ),
                        // decoration: DesignConfiguration.shadow(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CustomText(
                                text: widget.isCreate
                                    ? (projectsname?.isEmpty ?? true
                                        ? "Select Project"
                                        : projectsname!)
                                    : (projectsname?.isEmpty ?? true
                                        ? widget.name!
                                        : projectsname!),
                                fontWeight: FontWeight.w500,
                                size: 14.sp,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                              ),
                            ),
                            widget.isCreate == false
                                ? SizedBox()
                                : Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
            else if (state is SingleProjectSuccess) {
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      highlightColor: Colors.transparent, // No highlight on tap
                      splashColor: Colors.transparent,
                      onTap: () {
                        _projectSearchController.clear();

                        // Fetch initial project list
                        widget.isCreate == false && widget.openDropdown == false
                            ? SizedBox()
                            : context
                                .read<SingleSelectProjectBloc>()
                                .add(SingleProjectList());
                        widget.isCreate == false && widget.openDropdown == false
                            ? SizedBox()
                            : showDialog(
                                context: context,
                                builder: (ctx) => BlocConsumer<
                                    SingleSelectProjectBloc,
                                    SingleSelectProjectState>(
                                  listener: (context, state) {
                                    if (state is SingleProjectSuccess) {
                                      isLoadingMore = false;
                                      setState(() {});
                                    }
                                  },
                                  builder: (context, state) {
                                    if (state is SingleProjectSuccess) {
                                      print("uidhfggjh ${state.hasReachedMax}");
                                      return NotificationListener<
                                              ScrollNotification>(
                                          onNotification: (scrollInfo) {
                                            // Check if the user has scrolled to the end and load more notes if needed
                                            if (!state.hasReachedMax &&
                                                scrollInfo.metrics.pixels ==
                                                    scrollInfo.metrics
                                                        .maxScrollExtent) {
                                              // isLoadingMore = true;
                                              setState(() {});
                                              context
                                                  .read<
                                                      SingleSelectProjectBloc>()
                                                  .add(SingleProjectLoadMore(
                                                      searchWord));
                                            }
                                            // isLoadingMore = false;
                                            return false;
                                          },
                                          child: AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  10.r), // Set the desired radius here
                                            ),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .alertBoxBackGroundColor,
                                            contentPadding: EdgeInsets.zero,
                                            title: Center(
                                              child: Column(
                                                children: [
                                                  CustomText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .selectprojects,
                                                    fontWeight: FontWeight.w800,
                                                    size: 20,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .whitepurpleChange,
                                                  ),
                                                  const Divider(),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 0.w),
                                                    child: SizedBox(
                                                      // color: Colors.red,
                                                      height: 35.h,
                                                      width: double.infinity,
                                                      child: TextField(
                                                        cursorColor: AppColors
                                                            .greyForgetColor,
                                                        cursorWidth: 1,
                                                        controller:
                                                            _projectSearchController,
                                                        decoration:
                                                            InputDecoration(
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                            vertical:
                                                                (35.h - 20.sp) /
                                                                    2,
                                                            horizontal: 10.w,
                                                          ),
                                                          hintText:
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .search,
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: AppColors
                                                                  .greyForgetColor, // Set your desired color here
                                                              width:
                                                                  1.0, // Set the border width if needed
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0), // Optional: adjust the border radius
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            borderSide:
                                                                BorderSide(
                                                              color: AppColors
                                                                  .purple, // Border color when TextField is focused
                                                              width: 1.0,
                                                            ),
                                                          ),
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            searchWord = value;
                                                          });
                                                          context
                                                              .read<
                                                                  SingleSelectProjectBloc>()
                                                              .add(
                                                                  SearchSingleProject(
                                                                      value));
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 20.h,
                                                  )
                                                ],
                                              ),
                                            ),
                                            content: Container(
                                              constraints: BoxConstraints(
                                                  maxHeight: 900.h),
                                              width: 200.w,
                                              child:state
                                                  .project.isEmpty?NoData(isImage: true,): ListView.builder(
                                                // physics: const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: state.hasReachedMax
                                                    ? state.project.length
                                                    : state.project.length + 1,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  if (index <
                                                      state.project.length) {
                                                    final isSelected =
                                                        projectsId != null &&
                                                            state.project[index]
                                                                    .id ==
                                                                projectsId;
                                                    return Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 2.h,
                                                              horizontal: 20.w),
                                                      child: InkWell(
                                                        highlightColor: Colors
                                                            .transparent, // No highlight on tap
                                                        splashColor:
                                                            Colors.transparent,
                                                        onTap: () {
                                                          setState(() {
                                                            if (widget
                                                                    .isCreate ==
                                                                true) {
                                                              projectsname =
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!;
                                                              projectsId = state
                                                                  .project[
                                                                      index]
                                                                  .id!;
                                                              widget.onSelected(
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!,
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .id!);
                                                            } else {
                                                              name = state
                                                                  .project[
                                                                      index]
                                                                  .title!;
                                                              projectsname =
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!;
                                                              projectsId = state
                                                                  .project[
                                                                      index]
                                                                  .id!;
                                                              widget.onSelected(
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!,
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .id!);
                                                            }
                                                          });

                                                          BlocProvider.of<
                                                                      SingleSelectProjectBloc>(
                                                                  context)
                                                              .add(SelectSingleProject(
                                                                  index,
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!));

                                                          BlocProvider.of<
                                                                      SingleSelectProjectBloc>(
                                                                  context)
                                                              .add(SelectSingleProject(
                                                                  index,
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!));
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color: isSelected
                                                                  ? AppColors
                                                                      .purpleShade
                                                                  : Colors
                                                                      .transparent,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  color: isSelected
                                                                      ? AppColors
                                                                          .primary
                                                                      : Colors
                                                                          .transparent)),
                                                          width:
                                                              double.infinity,
                                                          height: 40.h,
                                                          child: Center(
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          10.w),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    flex: 4,
                                                                    // width:200.w,
                                                                    child:
                                                                        CustomText(
                                                                      text: state
                                                                          .project[
                                                                              index]
                                                                          .title!,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      size: 18,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      color: isSelected
                                                                          ? AppColors
                                                                              .purple
                                                                          : Theme.of(context)
                                                                              .colorScheme
                                                                              .textClrChange,
                                                                    ),
                                                                  ),
                                                                  isSelected
                                                                      ? Expanded(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              const HeroIcon(
                                                                            HeroIcons.checkCircle,
                                                                            style:
                                                                                HeroIconStyle.solid,
                                                                            color:
                                                                                AppColors.purple,
                                                                          ),
                                                                        )
                                                                      : const SizedBox
                                                                          .shrink(),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    // Show a loading indicator when more notes are being loaded
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 0),
                                                      child: Center(
                                                        child: state
                                                                .hasReachedMax
                                                            ? const Text('')
                                                            : const SpinKitFadingCircle(
                                                                color: AppColors
                                                                    .primary,
                                                                size: 40.0,
                                                              ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            actions: <Widget>[
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 20.h),
                                                child: CreateCancelButtom(
                                                  title: "OK",
                                                  onpressCancel: () {
                                                    _projectSearchController
                                                        .clear();
                                                    Navigator.pop(context);
                                                  },
                                                  onpressCreate: () {
                                                    _projectSearchController
                                                        .clear();
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ));
                                    }
                                    return const Center(
                                        child: Text('Loading...'));
                                  },
                                ),
                              );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        height: 40.h,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: widget.isCreate == true
                              ? Colors.transparent
                              :  widget.openDropdown == true?Colors.transparent:Theme.of(context).colorScheme.textfieldDisabled,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.greyColor),
                        ),
                        // decoration: DesignConfiguration.shadow(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CustomText(
                                text: widget.isCreate
                                    ? (projectsname?.isEmpty ?? true
                                        ? "Select Project"
                                        : projectsname!)
                                    : (projectsname?.isEmpty ?? true
                                        ? widget.name!
                                        : projectsname!),
                                fontWeight: FontWeight.w500,
                                size: 14.sp,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                              ),
                            ),
                            widget.isCreate == false && widget.openDropdown == false
                                ? SizedBox()
                                : Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            } else if (state is ProjectError) {
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      highlightColor: Colors.transparent, // No highlight on tap
                      splashColor: Colors.transparent,
                      onTap: () {
                        _projectSearchController.clear();

                        // Fetch initial project list
                        widget.isCreate == false
                            ? SizedBox()
                            : context
                                .read<SingleSelectProjectBloc>()
                                .add(SingleProjectList());
                        widget.isCreate == false
                            ? SizedBox()
                            : showDialog(
                                context: context,
                                builder: (ctx) => BlocConsumer<
                                    SingleSelectProjectBloc,
                                    SingleSelectProjectState>(
                                  listener: (context, state) {
                                    if (state is SingleProjectSuccess) {
                                      isLoadingMore = false;
                                      setState(() {});
                                    }
                                  },
                                  builder: (context, state) {
                                    if (state is SingleProjectSuccess) {
                                      return NotificationListener<
                                              ScrollNotification>(
                                          onNotification: (scrollInfo) {
                                            // Check if the user has scrolled to the end and load more notes if needed
                                            if (!state.hasReachedMax &&
                                                scrollInfo.metrics.pixels ==
                                                    scrollInfo.metrics
                                                        .maxScrollExtent) {
                                              // isLoadingMore = true;
                                              setState(() {});
                                              context
                                                  .read<
                                                      SingleSelectProjectBloc>()
                                                  .add(SingleProjectLoadMore(
                                                      searchWord));
                                            }
                                            // isLoadingMore = false;
                                            return false;
                                          },
                                          child: AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  10.r), // Set the desired radius here
                                            ),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .alertBoxBackGroundColor,
                                            contentPadding: EdgeInsets.zero,
                                            title: Center(
                                              child: Column(
                                                children: [
                                                  CustomText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .selectprojects,
                                                    fontWeight: FontWeight.w800,
                                                    size: 20,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .whitepurpleChange,
                                                  ),
                                                  const Divider(),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 0.w),
                                                    child: SizedBox(
                                                      // color: Colors.red,
                                                      height: 35.h,
                                                      width: double.infinity,
                                                      child: TextField(
                                                        cursorColor: AppColors
                                                            .greyForgetColor,
                                                        cursorWidth: 1,
                                                        controller:
                                                            _projectSearchController,
                                                        decoration:
                                                            InputDecoration(
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                            vertical:
                                                                (35.h - 20.sp) /
                                                                    2,
                                                            horizontal: 10.w,
                                                          ),
                                                          hintText:
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .search,
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: AppColors
                                                                  .greyForgetColor, // Set your desired color here
                                                              width:
                                                                  1.0, // Set the border width if needed
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0), // Optional: adjust the border radius
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            borderSide:
                                                                BorderSide(
                                                              color: AppColors
                                                                  .purple, // Border color when TextField is focused
                                                              width: 1.0,
                                                            ),
                                                          ),
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            searchWord = value;
                                                          });
                                                          context
                                                              .read<
                                                                  SingleSelectProjectBloc>()
                                                              .add(
                                                                  SearchSingleProject(
                                                                      value));
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 20.h,
                                                  )
                                                ],
                                              ),
                                            ),
                                            content: Container(
                                              constraints: BoxConstraints(
                                                  maxHeight: 900.h),
                                              width: 200.w,
                                              child:state
                                                  .project.isEmpty?NoData(isImage: true,): ListView.builder(
                                                // physics: const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: state.hasReachedMax
                                                    ? state.project.length
                                                    : state.project.length + 1,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  if (index <
                                                      state.project.length) {
                                                    final isSelected =
                                                        projectsId != null &&
                                                            state.project[index]
                                                                    .id ==
                                                                projectsId;
                                                    return Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 2.h,
                                                              horizontal: 20.w),
                                                      child: InkWell(
                                                        highlightColor: Colors
                                                            .transparent, // No highlight on tap
                                                        splashColor:
                                                            Colors.transparent,
                                                        onTap: () {
                                                          setState(() {
                                                            if (widget
                                                                    .isCreate ==
                                                                true) {
                                                              projectsname =
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!;
                                                              projectsId = state
                                                                  .project[
                                                                      index]
                                                                  .id!;
                                                              widget.onSelected(
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!,
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .id!);
                                                            } else {
                                                              name = state
                                                                  .project[
                                                                      index]
                                                                  .title!;
                                                              projectsname =
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!;
                                                              projectsId = state
                                                                  .project[
                                                                      index]
                                                                  .id!;
                                                              widget.onSelected(
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!,
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .id!);
                                                            }
                                                          });

                                                          BlocProvider.of<
                                                                      SingleSelectProjectBloc>(
                                                                  context)
                                                              .add(SelectSingleProject(
                                                                  index,
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!));

                                                          BlocProvider.of<
                                                                      SingleSelectProjectBloc>(
                                                                  context)
                                                              .add(SelectSingleProject(
                                                                  index,
                                                                  state
                                                                      .project[
                                                                          index]
                                                                      .title!));
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color: isSelected
                                                                  ? AppColors
                                                                      .purpleShade
                                                                  : Colors
                                                                      .transparent,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  color: isSelected
                                                                      ? AppColors
                                                                          .primary
                                                                      : Colors
                                                                          .transparent)),
                                                          width:
                                                              double.infinity,
                                                          height: 40.h,
                                                          child: Center(
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          10.w),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    flex: 4,
                                                                    // width:200.w,
                                                                    child:
                                                                        CustomText(
                                                                      text: state
                                                                          .project[
                                                                              index]
                                                                          .title!,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      size: 18,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      color: isSelected
                                                                          ? AppColors
                                                                              .purple
                                                                          : Theme.of(context)
                                                                              .colorScheme
                                                                              .textClrChange,
                                                                    ),
                                                                  ),
                                                                  isSelected
                                                                      ? Expanded(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              const HeroIcon(
                                                                            HeroIcons.checkCircle,
                                                                            style:
                                                                                HeroIconStyle.solid,
                                                                            color:
                                                                                AppColors.purple,
                                                                          ),
                                                                        )
                                                                      : const SizedBox
                                                                          .shrink(),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    // Show a loading indicator when more notes are being loaded
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 0),
                                                      child: Center(
                                                        child: state
                                                                .hasReachedMax
                                                            ? const Text('')
                                                            : const SpinKitFadingCircle(
                                                                color: AppColors
                                                                    .primary,
                                                                size: 40.0,
                                                              ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            actions: <Widget>[
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 20.h),
                                                child: CreateCancelButtom(
                                                  title: "OK",
                                                  onpressCancel: () {
                                                    _projectSearchController
                                                        .clear();
                                                    Navigator.pop(context);
                                                  },
                                                  onpressCreate: () {
                                                    _projectSearchController
                                                        .clear();
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ));
                                    }
                                    return const Center(
                                        child: Text('Loading...'));
                                  },
                                ),
                              );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        height: 40.h,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: widget.isCreate == true
                              ? Colors.transparent
                              : Theme.of(context).colorScheme.textfieldDisabled,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.greyColor),
                        ),
                        // decoration: DesignConfiguration.shadow(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CustomText(
                                text: widget.isCreate
                                    ? (projectsname?.isEmpty ?? true
                                        ? "Select Project"
                                        : projectsname!)
                                    : (projectsname?.isEmpty ?? true
                                        ? widget.name!
                                        : projectsname!),
                                fontWeight: FontWeight.w500,
                                size: 14.sp,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                              ),
                            ),
                            widget.isCreate == false
                                ? SizedBox()
                                : Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
            return AbsorbPointer(
              absorbing: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    highlightColor: Colors.transparent, // No highlight on tap
                    splashColor: Colors.transparent,
                    onTap: () {
                      _projectSearchController.clear();

                      // Fetch initial project list
                      widget.isCreate == false
                          ? SizedBox()
                          : context
                              .read<SingleSelectProjectBloc>()
                              .add(SingleProjectList());
                      widget.isCreate == false
                          ? SizedBox()
                          : showDialog(
                              context: context,
                              builder: (ctx) => BlocConsumer<
                                  SingleSelectProjectBloc,
                                  SingleSelectProjectState>(
                                listener: (context, state) {
                                  if (state is SingleProjectSuccess) {
                                    isLoadingMore = false;
                                    setState(() {});
                                  }
                                },
                                builder: (context, state) {
                                  if (state is SingleProjectSuccess) {
                                    print("dfxgfg ${state.hasReachedMax}");
                                    return NotificationListener<
                                            ScrollNotification>(
                                        onNotification: (scrollInfo) {
                                          // Check if the user has scrolled to the end and load more notes if needed
                                          if (!state.hasReachedMax &&
                                              scrollInfo.metrics.pixels ==
                                                  scrollInfo.metrics
                                                      .maxScrollExtent) {
                                            // isLoadingMore = true;
                                            setState(() {});
                                            context
                                                .read<SingleSelectProjectBloc>()
                                                .add(SingleProjectLoadMore(
                                                    searchWord));
                                          }
                                          // isLoadingMore = false;
                                          return false;
                                        },
                                        child: AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                10.r), // Set the desired radius here
                                          ),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .alertBoxBackGroundColor,
                                          contentPadding: EdgeInsets.zero,
                                          title: Center(
                                            child: Column(
                                              children: [
                                                CustomText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .selectprojects,
                                                  fontWeight: FontWeight.w800,
                                                  size: 20,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .whitepurpleChange,
                                                ),
                                                const Divider(),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 0.w),
                                                  child: SizedBox(
                                                    // color: Colors.red,
                                                    height: 35.h,
                                                    width: double.infinity,
                                                    child: TextField(
                                                      cursorColor: AppColors
                                                          .greyForgetColor,
                                                      cursorWidth: 1,
                                                      controller:
                                                          _projectSearchController,
                                                      decoration:
                                                          InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                          vertical:
                                                              (35.h - 20.sp) /
                                                                  2,
                                                          horizontal: 10.w,
                                                        ),
                                                        hintText:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .search,
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: AppColors
                                                                .greyForgetColor, // Set your desired color here
                                                            width:
                                                                1.0, // Set the border width if needed
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  10.0), // Optional: adjust the border radius
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          borderSide:
                                                              BorderSide(
                                                            color: AppColors
                                                                .purple, // Border color when TextField is focused
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                      ),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          searchWord = value;
                                                        });
                                                        context
                                                            .read<
                                                                SingleSelectProjectBloc>()
                                                            .add(
                                                                SearchSingleProject(
                                                                    value));
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20.h,
                                                )
                                              ],
                                            ),
                                          ),
                                          content: Container(
                                            constraints: BoxConstraints(
                                                maxHeight: 900.h),
                                            width: 200.w,
                                            child: state
                                                .project.isEmpty?NoData(isImage: true,):ListView.builder(
                                              // physics: const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: state.hasReachedMax
                                                  ? state.project.length
                                                  : state.project.length + 1,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                if (index <
                                                    state.project.length) {
                                                  final isSelected =
                                                      projectsId != null &&
                                                          state.project[index]
                                                                  .id ==
                                                              projectsId;
                                                  return Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 2.h,
                                                            horizontal: 20.w),
                                                    child: InkWell(
                                                      highlightColor: Colors
                                                          .transparent, // No highlight on tap
                                                      splashColor:
                                                          Colors.transparent,
                                                      onTap: () {
                                                        setState(() {
                                                          if (widget.isCreate ==
                                                              true) {
                                                            projectsname = state
                                                                .project[index]
                                                                .title!;
                                                            projectsId = state
                                                                .project[index]
                                                                .id!;
                                                            widget.onSelected(
                                                                state
                                                                    .project[
                                                                        index]
                                                                    .title!,
                                                                state
                                                                    .project[
                                                                        index]
                                                                    .id!);
                                                          } else {
                                                            name = state
                                                                .project[index]
                                                                .title!;
                                                            projectsname = state
                                                                .project[index]
                                                                .title!;
                                                            projectsId = state
                                                                .project[index]
                                                                .id!;
                                                            widget.onSelected(
                                                                state
                                                                    .project[
                                                                        index]
                                                                    .title!,
                                                                state
                                                                    .project[
                                                                        index]
                                                                    .id!);
                                                          }
                                                        });

                                                        BlocProvider.of<
                                                                    SingleSelectProjectBloc>(
                                                                context)
                                                            .add(SelectSingleProject(
                                                                index,
                                                                state
                                                                    .project[
                                                                        index]
                                                                    .title!));

                                                        BlocProvider.of<
                                                                    SingleSelectProjectBloc>(
                                                                context)
                                                            .add(SelectSingleProject(
                                                                index,
                                                                state
                                                                    .project[
                                                                        index]
                                                                    .title!));
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            color: isSelected
                                                                ? AppColors
                                                                    .purpleShade
                                                                : Colors
                                                                    .transparent,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                                color: isSelected
                                                                    ? AppColors
                                                                        .primary
                                                                    : Colors
                                                                        .transparent)),
                                                        width: double.infinity,
                                                        height: 40.h,
                                                        child: Center(
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10.w),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  flex: 4,
                                                                  // width:200.w,
                                                                  child:
                                                                      CustomText(
                                                                    text: state
                                                                        .project[
                                                                            index]
                                                                        .title!,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    size: 18,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    color: isSelected
                                                                        ? AppColors
                                                                            .purple
                                                                        : Theme.of(context)
                                                                            .colorScheme
                                                                            .textClrChange,
                                                                  ),
                                                                ),
                                                                isSelected
                                                                    ? Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            const HeroIcon(
                                                                          HeroIcons
                                                                              .checkCircle,
                                                                          style:
                                                                              HeroIconStyle.solid,
                                                                          color:
                                                                              AppColors.purple,
                                                                        ),
                                                                      )
                                                                    : const SizedBox
                                                                        .shrink(),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  // Show a loading indicator when more notes are being loaded
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 0),
                                                    child: Center(
                                                      child:! state.hasReachedMax
                                                          ? const Text('')
                                                          : const SpinKitFadingCircle(
                                                              color: AppColors
                                                                  .primary,
                                                              size: 40.0,
                                                            ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                          actions: <Widget>[
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 20.h),
                                              child: CreateCancelButtom(
                                                title: "OK",
                                                onpressCancel: () {
                                                  _projectSearchController
                                                      .clear();
                                                  Navigator.pop(context);
                                                },
                                                onpressCreate: () {
                                                  _projectSearchController
                                                      .clear();
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ),
                                          ],
                                        ));
                                  }
                                  return const Center(
                                      child: Text('Loading...'));
                                },
                              ),
                            );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      height: 40.h,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: widget.isCreate == true
                            ? Colors.transparent
                            : Theme.of(context).colorScheme.textfieldDisabled,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.greyColor),
                      ),
                      // decoration: DesignConfiguration.shadow(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomText(
                              text: widget.isCreate
                                  ? (projectsname?.isEmpty ?? true
                                      ? "Select Project"
                                      : projectsname!)
                                  : (projectsname?.isEmpty ?? true
                                      ? widget.name!
                                      : projectsname!),
                              fontWeight: FontWeight.w500,
                              size: 14.sp,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                            ),
                          ),
                          widget.isCreate == false
                              ? SizedBox()
                              : Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        )
      ],
    );
  }
}
