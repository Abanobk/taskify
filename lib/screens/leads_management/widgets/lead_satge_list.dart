import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:taskify/config/colors.dart';
import '../../../bloc/leads_stage/lead_stage_bloc.dart';
import '../../../bloc/leads_stage/lead_stage_event.dart';
import '../../../bloc/leads_stage/lead_stage_state.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/no_data.dart';
import '../../widgets/custom_cancel_create_button.dart';

class LeadStageList extends StatefulWidget {
  final bool isCreate;
  final String? name;
  final int? LeadStage;
  final bool? isRequired;

  final Function(String, int) onSelected;
  const LeadStageList(
      {super.key,
        this.name,
        required this.isCreate,
        required this.LeadStage,
        this.isRequired,

        required this.onSelected});

  @override
  State<LeadStageList> createState() => _LeadStageListState();
}

class _LeadStageListState extends State<LeadStageList> {
  String? LeadStageBlocsname;
  int? LeadStageBlocsId;
  bool isLoadingMore = false;
  String searchWord = "";

  String? name;
  final TextEditingController _LeadStageBlocSearchController =
  TextEditingController();
  @override
  void initState() {
    name = widget.name!;
    if (!widget.isCreate) {
      LeadStageBlocsId = widget.LeadStage;
      LeadStageBlocsname = widget.name;
    }
    print("fhdzif ${LeadStageBlocsname}");
    print("LeadStageBlocsId ${LeadStageBlocsId}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // if (!widget.isCreate) {
    //   LeadStageBlocsId = widget.LeadStageBloc;
    //   LeadStageBlocsname = widget.name;
    // }


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
                text: AppLocalizations.of(context)!.leadstages,
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
        BlocBuilder<LeadStageBloc, LeadStageState>(
          builder: (context, state) {
            print("fsdfr $state");
            if (state is LeadStageInitial) {
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
                        _LeadStageBlocSearchController.clear();

                        // Fetch initial LeadStageBloc list
                        context
                            .read<LeadStageBloc>()
                            .add(LeadStageLists());
                        showDialog(
                          context: context,
                          builder: (ctx) => BlocConsumer<
                              LeadStageBloc, LeadStageState>(
                            listener: (context, state) {
                              if (state is LeadStageSuccess) {
                                isLoadingMore = false;
                                setState(() {});
                              }
                            },
                            builder: (context, state) {
                              if (state is LeadStageSuccess) {
                                return NotificationListener<
                                    ScrollNotification>(
                                    onNotification: (scrollInfo) {
                                      // Check if the user has scrolled to the end and load more notes if needed
                                      if (!state.isLoadingMore &&
                                          scrollInfo.metrics.pixels ==
                                              scrollInfo.metrics
                                                  .maxScrollExtent) {
                                        // isLoadingMore = true;
                                        setState(() {});
                                        context
                                            .read<
                                            LeadStageBloc>()
                                            .add(LeadStageLoadMore(
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
                                                  .selectleadstage,
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
                                                  _LeadStageBlocSearchController,
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
                                                        LeadStageBloc>()
                                                        .add(
                                                        SearchLeadStage(
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
                                        child:state.LeadStage.isEmpty ?NoData(isImage: true): ListView.builder(
                                          // physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: state.isLoadingMore
                                              ? state.LeadStage.length
                                              : state.LeadStage.length + 1,
                                          itemBuilder:
                                              (BuildContext context,
                                              int index) {
                                            if (index <
                                                state.LeadStage.length) {
                                              final isSelected =
                                                  LeadStageBlocsId != null &&
                                                      state.LeadStage[index]
                                                          .id ==
                                                          LeadStageBlocsId;
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
                                                        LeadStageBlocsname =
                                                        state
                                                            .LeadStage[
                                                        index]
                                                            .name!;
                                                        LeadStageBlocsId = state
                                                            .LeadStage[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .LeadStage[
                                                            index]
                                                                .name!,
                                                            state
                                                                .LeadStage[
                                                            index]
                                                                .id!);
                                                      } else {
                                                        name = state
                                                            .LeadStage[
                                                        index]
                                                            .name!;
                                                        LeadStageBlocsname =
                                                        state
                                                            .LeadStage[
                                                        index]
                                                            .name!;
                                                        LeadStageBlocsId = state
                                                            .LeadStage[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .LeadStage[
                                                            index]
                                                                .name!,
                                                            state
                                                                .LeadStage[
                                                            index]
                                                                .id!);
                                                      }
                                                    });

                                                    BlocProvider.of<
                                                        LeadStageBloc>(
                                                        context)
                                                        .add(SelectedLeadStage(
                                                        index,
                                                        state
                                                            .LeadStage[
                                                        index]
                                                            .name!));

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
                                                                    .LeadStage[
                                                                index]
                                                                    .name!,
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
                                                      .isLoadingMore
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
                                              _LeadStageBlocSearchController
                                                  .clear();
                                              Navigator.pop(context);
                                            },
                                            onpressCreate: () {
                                              _LeadStageBlocSearchController
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
                          color:Colors.transparent,
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
                                    ? (LeadStageBlocsname?.isEmpty ?? true
                                    ? "Select Lead Stage"
                                    : LeadStageBlocsname!)
                                    : (LeadStageBlocsname?.isEmpty ?? true
                                    ? widget.name!
                                    : LeadStageBlocsname!),
                                fontWeight: FontWeight.w500,
                                size: 14.sp,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                color:
                                Theme.of(context).colorScheme.textClrChange,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
            else if (state is LeadStageLoading) {
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
                        _LeadStageBlocSearchController.clear();

                        // Fetch initial LeadStageBloc list
                        context
                            .read<LeadStageBloc>()
                            .add(LeadStageLists());
                        showDialog(
                          context: context,
                          builder: (ctx) => BlocConsumer<
                              LeadStageBloc, LeadStageState>(
                            listener: (context, state) {
                              if (state is LeadStageSuccess) {
                                isLoadingMore = false;
                                setState(() {});
                              }
                            },
                            builder: (context, state) {
                              if (state is LeadStageSuccess) {
                                return NotificationListener<
                                    ScrollNotification>(
                                    onNotification: (scrollInfo) {
                                      // Check if the user has scrolled to the end and load more notes if needed
                                      if (!state.isLoadingMore &&
                                          scrollInfo.metrics.pixels ==
                                              scrollInfo.metrics
                                                  .maxScrollExtent) {
                                        // isLoadingMore = true;
                                        setState(() {});
                                        context
                                            .read<
                                            LeadStageBloc>()
                                            .add(LeadStageLoadMore(
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
                                                  .selectleadstage,
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
                                                  _LeadStageBlocSearchController,
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
                                                        LeadStageBloc>()
                                                        .add(
                                                        SearchLeadStage(
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
                                        child:state.LeadStage.isEmpty ?NoData(isImage: true): ListView.builder(
                                          // physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: state.isLoadingMore
                                              ? state.LeadStage.length
                                              : state.LeadStage.length + 1,
                                          itemBuilder:
                                              (BuildContext context,
                                              int index) {
                                            if (index <
                                                state.LeadStage.length) {
                                              final isSelected =
                                                  LeadStageBlocsId != null &&
                                                      state.LeadStage[index]
                                                          .id ==
                                                          LeadStageBlocsId;
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
                                                        LeadStageBlocsname =
                                                        state
                                                            .LeadStage[
                                                        index]
                                                            .name!;
                                                        LeadStageBlocsId = state
                                                            .LeadStage[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .LeadStage[
                                                            index]
                                                                .name!,
                                                            state
                                                                .LeadStage[
                                                            index]
                                                                .id!);
                                                      } else {
                                                        name = state
                                                            .LeadStage[
                                                        index]
                                                            .name!;
                                                        LeadStageBlocsname =
                                                        state
                                                            .LeadStage[
                                                        index]
                                                            .name!;
                                                        LeadStageBlocsId = state
                                                            .LeadStage[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .LeadStage[
                                                            index]
                                                                .name!,
                                                            state
                                                                .LeadStage[
                                                            index]
                                                                .id!);
                                                      }
                                                    });

                                                    BlocProvider.of<
                                                        LeadStageBloc>(
                                                        context)
                                                        .add(SelectedLeadStage(
                                                        index,
                                                        state
                                                            .LeadStage[
                                                        index]
                                                            .name!));


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
                                                                    .LeadStage[
                                                                index]
                                                                    .name!,
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
                                                      .isLoadingMore
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
                                              _LeadStageBlocSearchController
                                                  .clear();
                                              Navigator.pop(context);
                                            },
                                            onpressCreate: () {
                                              _LeadStageBlocSearchController
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
                          color: Colors.transparent
                             ,
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
                                    ? (LeadStageBlocsname?.isEmpty ?? true
                                    ? "Select Lead Stage"
                                    : LeadStageBlocsname!)
                                    : (LeadStageBlocsname?.isEmpty ?? true
                                    ? widget.name!
                                    : LeadStageBlocsname!),
                                fontWeight: FontWeight.w500,
                                size: 14.sp,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                color:
                                Theme.of(context).colorScheme.textClrChange,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
            else if (state is LeadStageSuccess) {
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
                        _LeadStageBlocSearchController.clear();

                        // Fetch initial LeadStageBloc list
                        context
                            .read<LeadStageBloc>()
                            .add(LeadStageLists());
                        showDialog(
                          context: context,
                          builder: (ctx) => BlocConsumer<
                              LeadStageBloc, LeadStageState>(
                            listener: (context, state) {
                              if (state is LeadStageSuccess) {
                                isLoadingMore = false;
                                setState(() {});
                              }
                            },
                            builder: (context, state) {
                              if (state is LeadStageSuccess) {
                                return NotificationListener<
                                    ScrollNotification>(
                                    onNotification: (scrollInfo) {
                                      // Check if the user has scrolled to the end and load more notes if needed
                                      if (!state.isLoadingMore &&
                                          scrollInfo.metrics.pixels ==
                                              scrollInfo.metrics
                                                  .maxScrollExtent) {
                                        // isLoadingMore = true;
                                        setState(() {});
                                        context
                                            .read<
                                            LeadStageBloc>()
                                            .add(LeadStageLoadMore(
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
                                                  .selectleadstage,
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
                                                  _LeadStageBlocSearchController,
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
                                                        LeadStageBloc>()
                                                        .add(
                                                        SearchLeadStage(
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
                                        child: state.LeadStage.isEmpty ?NoData(isImage: true):ListView.builder(
                                          // physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: state.isLoadingMore
                                              ? state.LeadStage.length
                                              : state.LeadStage.length + 1,
                                          itemBuilder:
                                              (BuildContext context,
                                              int index) {
                                            if (index <
                                                state.LeadStage.length) {
                                              final isSelected =
                                                  LeadStageBlocsId != null &&
                                                      state.LeadStage[index]
                                                          .id ==
                                                          LeadStageBlocsId;
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
                                                        LeadStageBlocsname =
                                                        state
                                                            .LeadStage[
                                                        index]
                                                            .name!;
                                                        LeadStageBlocsId = state
                                                            .LeadStage[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .LeadStage[
                                                            index]
                                                                .name!,
                                                            state
                                                                .LeadStage[
                                                            index]
                                                                .id!);
                                                      } else {
                                                        name = state
                                                            .LeadStage[
                                                        index]
                                                            .name!;
                                                        LeadStageBlocsname =
                                                        state
                                                            .LeadStage[
                                                        index]
                                                            .name!;
                                                        LeadStageBlocsId = state
                                                            .LeadStage[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .LeadStage[
                                                            index]
                                                                .name!,
                                                            state
                                                                .LeadStage[
                                                            index]
                                                                .id!);
                                                      }
                                                    });

                                                    BlocProvider.of<
                                                        LeadStageBloc>(
                                                        context)
                                                        .add(SelectedLeadStage(
                                                        index,
                                                        state
                                                            .LeadStage[
                                                        index]
                                                            .name!));


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
                                                                    .LeadStage[
                                                                index]
                                                                    .name!,
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
                                                  child: !state
                                                      .isLoadingMore
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
                                              _LeadStageBlocSearchController
                                                  .clear();
                                              Navigator.pop(context);
                                            },
                                            onpressCreate: () {
                                              _LeadStageBlocSearchController
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
                                    ? (LeadStageBlocsname?.isEmpty ?? true
                                    ? "Select Lead Stage"
                                    : LeadStageBlocsname!)
                                    : (LeadStageBlocsname?.isEmpty ?? true
                                    ? widget.name!
                                    : LeadStageBlocsname!),
                                fontWeight: FontWeight.w500,
                                size: 14.sp,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                color:
                                Theme.of(context).colorScheme.textClrChange,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
            else if (state is LeadStageError) {
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
                        _LeadStageBlocSearchController.clear();

                        // Fetch initial LeadStageBloc list
                        context
                            .read<LeadStageBloc>()
                            .add(LeadStageLists());
                        showDialog(
                          context: context,
                          builder: (ctx) => BlocConsumer<
                              LeadStageBloc, LeadStageState>(
                            listener: (context, state) {
                              if (state is LeadStageSuccess) {
                                isLoadingMore = false;
                                setState(() {});
                              }
                            },
                            builder: (context, state) {
                              if (state is LeadStageSuccess) {
                                return NotificationListener<
                                    ScrollNotification>(
                                    onNotification: (scrollInfo) {
                                      // Check if the user has scrolled to the end and load more notes if needed
                                      if (!state.isLoadingMore &&
                                          scrollInfo.metrics.pixels ==
                                              scrollInfo.metrics
                                                  .maxScrollExtent) {
                                        // isLoadingMore = true;
                                        setState(() {});
                                        context
                                            .read<
                                            LeadStageBloc>()
                                            .add(LeadStageLoadMore(
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
                                                  .selectleadstage,
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
                                                  _LeadStageBlocSearchController,
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
                                                        LeadStageBloc>()
                                                        .add(
                                                        SearchLeadStage(
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
                                        child: state.LeadStage.isEmpty ?NoData(isImage: true):ListView.builder(
                                          // physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: state.isLoadingMore
                                              ? state.LeadStage.length
                                              : state.LeadStage.length + 1,
                                          itemBuilder:
                                              (BuildContext context,
                                              int index) {
                                            if (index <
                                                state.LeadStage.length) {
                                              final isSelected =
                                                  LeadStageBlocsId != null &&
                                                      state.LeadStage[index]
                                                          .id ==
                                                          LeadStageBlocsId;
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
                                                        LeadStageBlocsname =
                                                        state
                                                            .LeadStage[
                                                        index]
                                                            .name!;
                                                        LeadStageBlocsId = state
                                                            .LeadStage[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .LeadStage[
                                                            index]
                                                                .name!,
                                                            state
                                                                .LeadStage[
                                                            index]
                                                                .id!);
                                                      } else {
                                                        name = state
                                                            .LeadStage[
                                                        index]
                                                            .name!;
                                                        LeadStageBlocsname =
                                                        state
                                                            .LeadStage[
                                                        index]
                                                            .name!;
                                                        LeadStageBlocsId = state
                                                            .LeadStage[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .LeadStage[
                                                            index]
                                                                .name!,
                                                            state
                                                                .LeadStage[
                                                            index]
                                                                .id!);
                                                      }
                                                    });

                                                    BlocProvider.of<
                                                        LeadStageBloc>(
                                                        context)
                                                        .add(SelectedLeadStage(
                                                        index,
                                                        state
                                                            .LeadStage[
                                                        index]
                                                            .name!));


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
                                                                    .LeadStage[
                                                                index]
                                                                    .name!,
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
                                                      .isLoadingMore
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
                                              _LeadStageBlocSearchController
                                                  .clear();
                                              Navigator.pop(context);
                                            },
                                            onpressCreate: () {
                                              _LeadStageBlocSearchController
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
                          color: Colors.transparent,

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
                                    ? (LeadStageBlocsname?.isEmpty ?? true
                                    ? "Select Lead Stage"
                                    : LeadStageBlocsname!)
                                    : (LeadStageBlocsname?.isEmpty ?? true
                                    ? widget.name!
                                    : LeadStageBlocsname!),
                                fontWeight: FontWeight.w500,
                                size: 14.sp,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                color:
                                Theme.of(context).colorScheme.textClrChange,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down),
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
                      _LeadStageBlocSearchController.clear();

                      // Fetch initial LeadStageBloc list
                      context
                          .read<LeadStageBloc>()
                          .add(LeadStageLists());
                      showDialog(
                        context: context,
                        builder: (ctx) => BlocConsumer<
                            LeadStageBloc, LeadStageState>(
                          listener: (context, state) {
                            if (state is LeadStageSuccess) {
                              isLoadingMore = false;
                              setState(() {});
                            }
                          },
                          builder: (context, state) {
                            if (state is LeadStageSuccess) {
                              return NotificationListener<
                                  ScrollNotification>(
                                  onNotification: (scrollInfo) {
                                    // Check if the user has scrolled to the end and load more notes if needed
                                    if (!state.isLoadingMore &&
                                        scrollInfo.metrics.pixels ==
                                            scrollInfo.metrics
                                                .maxScrollExtent) {
                                      // isLoadingMore = true;
                                      setState(() {});
                                      context
                                          .read<
                                          LeadStageBloc>()
                                          .add(LeadStageLoadMore(
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
                                                .selectleadstage,
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
                                                _LeadStageBlocSearchController,
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
                                                      LeadStageBloc>()
                                                      .add(
                                                      SearchLeadStage(
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
                                      child: ListView.builder(
                                        // physics: const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: state.isLoadingMore
                                            ? state.LeadStage.length
                                            : state.LeadStage.length + 1,
                                        itemBuilder:
                                            (BuildContext context,
                                            int index) {
                                          if (index <
                                              state.LeadStage.length) {
                                            final isSelected =
                                                LeadStageBlocsId != null &&
                                                    state.LeadStage[index]
                                                        .id ==
                                                        LeadStageBlocsId;
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
                                                      LeadStageBlocsname =
                                                      state
                                                          .LeadStage[
                                                      index]
                                                          .name!;
                                                      LeadStageBlocsId = state
                                                          .LeadStage[
                                                      index]
                                                          .id!;
                                                      widget.onSelected(
                                                          state
                                                              .LeadStage[
                                                          index]
                                                              .name!,
                                                          state
                                                              .LeadStage[
                                                          index]
                                                              .id!);
                                                    } else {
                                                      name = state
                                                          .LeadStage[
                                                      index]
                                                          .name!;
                                                      LeadStageBlocsname =
                                                      state
                                                          .LeadStage[
                                                      index]
                                                          .name!;
                                                      LeadStageBlocsId = state
                                                          .LeadStage[
                                                      index]
                                                          .id!;
                                                      widget.onSelected(
                                                          state
                                                              .LeadStage[
                                                          index]
                                                              .name!,
                                                          state
                                                              .LeadStage[
                                                          index]
                                                              .id!);
                                                    }
                                                  });

                                                  BlocProvider.of<
                                                      LeadStageBloc>(
                                                      context)
                                                      .add(SelectedLeadStage(
                                                      index,
                                                      state
                                                          .LeadStage[
                                                      index]
                                                          .name!));


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
                                                                  .LeadStage[
                                                              index]
                                                                  .name!,
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
                                                    .isLoadingMore
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
                                            _LeadStageBlocSearchController
                                                .clear();
                                            Navigator.pop(context);
                                          },
                                          onpressCreate: () {
                                            _LeadStageBlocSearchController
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
                        color:  Colors.transparent,

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
                                  ? (LeadStageBlocsname?.isEmpty ?? true
                                  ? "Select Lead Stage"
                                  : LeadStageBlocsname!)
                                  : (LeadStageBlocsname?.isEmpty ?? true
                                  ? widget.name!
                                  : LeadStageBlocsname!),
                              fontWeight: FontWeight.w500,
                              size: 14.sp,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              color:
                              Theme.of(context).colorScheme.textClrChange,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down),
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
