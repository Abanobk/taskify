import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/bloc/leads_source/lead_source_bloc.dart';

import 'package:taskify/config/colors.dart';


import '../../../bloc/leads_source/lead_source_event.dart';
import '../../../bloc/leads_source/lead_source_state.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/no_data.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class LeadSourceList extends StatefulWidget {
  final bool isCreate;
  final String? name;
  final int? leadSource;
  final bool? isRequired;
  // final List<StatusModel> status;

  final Function(String, int) onSelected;
  const LeadSourceList(
      {super.key,
        this.name,
        required this.isCreate,
        required this.leadSource,
        this.isRequired,

        required this.onSelected});

  @override
  State<LeadSourceList> createState() => _LeadSourceListState();
}

class _LeadSourceListState extends State<LeadSourceList> {
  String? LeadSourceBlocsname;
  int? LeadSourceBlocsId;
  bool isLoadingMore = false;
  String searchWord = "";

  String? name;
  final TextEditingController _LeadSourceBlocSearchController =
  TextEditingController();
  @override
  void initState() {
    name = widget.name!;
    if (!widget.isCreate) {
      LeadSourceBlocsId = widget.leadSource;
      LeadSourceBlocsname = widget.name;
    }
    print("fhdzif ${LeadSourceBlocsname}");
    print("LeadSourceBlocsId ${LeadSourceBlocsId}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // if (!widget.isCreate) {
    //   LeadSourceBlocsId = widget.LeadSourceBloc;
    //   LeadSourceBlocsname = widget.name;
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
                text: AppLocalizations.of(context)!.leadsource,
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
        BlocBuilder<LeadSourceBloc, LeadSourceState>(
          builder: (context, state) {
            print("fsdfr $state");
            if (state is LeadSourceInitial) {
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
                        _LeadSourceBlocSearchController.clear();

                        // Fetch initial LeadSourceBloc list
                        context
                            .read<LeadSourceBloc>()
                            .add(LeadSourceLists());
                         showDialog(
                          context: context,
                          builder: (ctx) => BlocConsumer<
                              LeadSourceBloc, LeadSourceState>(
                            listener: (context, state) {
                              if (state is LeadSourceSuccess) {
                                isLoadingMore = false;
                                setState(() {});
                              }
                            },
                            builder: (context, state) {
                              if (state is LeadSourceSuccess) {
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
                                            LeadSourceBloc>()
                                            .add(SearchLeadSource(
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
                                                  .selectleadource,
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
                                                  _LeadSourceBlocSearchController,
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
                                                        LeadSourceBloc>()
                                                        .add(
                                                        SearchLeadSource(
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
                                        child:state.LeadSource.isEmpty ?NoData(isImage: true): ListView.builder(
                                          // physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: state.isLoadingMore
                                              ? state.LeadSource.length
                                              : state.LeadSource.length + 1,
                                          itemBuilder:
                                              (BuildContext context,
                                              int index) {
                                            if (index <
                                                state.LeadSource.length) {
                                              final isSelected =
                                                  LeadSourceBlocsId != null &&
                                                      state.LeadSource[index]
                                                          .id ==
                                                          LeadSourceBlocsId;
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
                                                        LeadSourceBlocsname =
                                                        state
                                                            .LeadSource[
                                                        index]
                                                            .name!;
                                                        LeadSourceBlocsId = state
                                                            .LeadSource[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .LeadSource[
                                                            index]
                                                                .name!,
                                                            state
                                                                .LeadSource[
                                                            index]
                                                                .id!);
                                                      } else {
                                                        name = state
                                                            .LeadSource[
                                                        index]
                                                            .name!;
                                                        LeadSourceBlocsname =
                                                        state
                                                            .LeadSource[
                                                        index]
                                                            .name!;
                                                        LeadSourceBlocsId = state
                                                            .LeadSource[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .LeadSource[
                                                            index]
                                                                .name!,
                                                            state
                                                                .LeadSource[
                                                            index]
                                                                .id!);
                                                      }
                                                    });

                                                    BlocProvider.of<
                                                        LeadSourceBloc>(
                                                        context)
                                                        .add(SelectedLeadSource(
                                                        index,
                                                        state
                                                            .LeadSource[
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
                                                                    .LeadSource[
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
                                              _LeadSourceBlocSearchController
                                                  .clear();
                                              Navigator.pop(context);
                                            },
                                            onpressCreate: () {
                                              _LeadSourceBlocSearchController
                                                  .clear();
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    ));
                              }
                              return const SizedBox();
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
                                    ? (LeadSourceBlocsname?.isEmpty ?? true
                                    ? "Select Lead Source"
                                    : LeadSourceBlocsname!)
                                    : (LeadSourceBlocsname?.isEmpty ?? true
                                    ? widget.name!
                                    : LeadSourceBlocsname!),
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
            else if (state is LeadSourceLoading) {
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
                        _LeadSourceBlocSearchController.clear();

                        // Fetch initial LeadSourceBloc list
                        context
                            .read<LeadSourceBloc>()
                            .add(LeadSourceLists());
                         showDialog(
                          context: context,
                          builder: (ctx) => BlocConsumer<
                              LeadSourceBloc, LeadSourceState>(
                            listener: (context, state) {
                              if (state is LeadSourceSuccess) {
                                isLoadingMore = false;
                                setState(() {});
                              }
                            },
                            builder: (context, state) {
                              if (state is LeadSourceSuccess) {
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
                                            LeadSourceBloc>()
                                            .add(SearchLeadSource(
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
                                                  .selectleadource,
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
                                                  _LeadSourceBlocSearchController,
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
                                                        LeadSourceBloc>()
                                                        .add(
                                                        SearchLeadSource(
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
                                        child:state.LeadSource.isEmpty ?NoData(isImage: true): ListView.builder(
                                          // physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: state.isLoadingMore
                                              ? state.LeadSource.length
                                              : state.LeadSource.length + 1,
                                          itemBuilder:
                                              (BuildContext context,
                                              int index) {
                                            if (index <
                                                state.LeadSource.length) {
                                              final isSelected =
                                                  LeadSourceBlocsId != null &&
                                                      state.LeadSource[index]
                                                          .id ==
                                                          LeadSourceBlocsId;
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
                                                        LeadSourceBlocsname =
                                                        state
                                                            .LeadSource[
                                                        index]
                                                            .name!;
                                                        LeadSourceBlocsId = state
                                                            .LeadSource[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .LeadSource[
                                                            index]
                                                                .name!,
                                                            state
                                                                .LeadSource[
                                                            index]
                                                                .id!);
                                                      } else {
                                                        name = state
                                                            .LeadSource[
                                                        index]
                                                            .name!;
                                                        LeadSourceBlocsname =
                                                        state
                                                            .LeadSource[
                                                        index]
                                                            .name!;
                                                        LeadSourceBlocsId = state
                                                            .LeadSource[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .LeadSource[
                                                            index]
                                                                .name!,
                                                            state
                                                                .LeadSource[
                                                            index]
                                                                .id!);
                                                      }
                                                    });

                                                    BlocProvider.of<
                                                        LeadSourceBloc>(
                                                        context)
                                                        .add(SelectedLeadSource(
                                                        index,
                                                        state
                                                            .LeadSource[
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
                                                                    .LeadSource[
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
                                              _LeadSourceBlocSearchController
                                                  .clear();
                                              Navigator.pop(context);
                                            },
                                            onpressCreate: () {
                                              _LeadSourceBlocSearchController
                                                  .clear();
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    ));
                              }
                              return const SizedBox();
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
                                    ? (LeadSourceBlocsname?.isEmpty ?? true
                                    ? "Select Lead Source"
                                    : LeadSourceBlocsname!)
                                    : (LeadSourceBlocsname?.isEmpty ?? true
                                    ? widget.name!
                                    : LeadSourceBlocsname!),
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
            else if (state is LeadSourceSuccess) {
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
                        _LeadSourceBlocSearchController.clear();

                        // Fetch initial LeadSourceBloc list
                      context
                            .read<LeadSourceBloc>()
                            .add(LeadSourceLists());
                        showDialog(
                          context: context,
                          builder: (ctx) => BlocConsumer<
                              LeadSourceBloc, LeadSourceState>(
                            listener: (context, state) {
                              if (state is LeadSourceSuccess) {
                                isLoadingMore = false;
                                setState(() {});
                              }
                            },
                            builder: (context, state) {
                              if (state is LeadSourceSuccess) {
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
                                            LeadSourceBloc>()
                                            .add(SearchLeadSource(
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
                                                  .selectleadource,
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
                                                  _LeadSourceBlocSearchController,
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
                                                        LeadSourceBloc>()
                                                        .add(
                                                        SearchLeadSource(
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
                                        child:state.LeadSource.isEmpty ?NoData(isImage: true): ListView.builder(
                                          // physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: state.isLoadingMore
                                              ? state.LeadSource.length
                                              : state.LeadSource.length + 1,
                                          itemBuilder:
                                              (BuildContext context,
                                              int index) {
                                            if (index <
                                                state.LeadSource.length) {
                                              final isSelected =
                                                  LeadSourceBlocsId != null &&
                                                      state.LeadSource[index]
                                                          .id ==
                                                          LeadSourceBlocsId;
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
                                                        LeadSourceBlocsname =
                                                        state
                                                            .LeadSource[
                                                        index]
                                                            .name!;
                                                        LeadSourceBlocsId = state
                                                            .LeadSource[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .LeadSource[
                                                            index]
                                                                .name!,
                                                            state
                                                                .LeadSource[
                                                            index]
                                                                .id!);
                                                      } else {
                                                        name = state
                                                            .LeadSource[
                                                        index]
                                                            .name!;
                                                        LeadSourceBlocsname =
                                                        state
                                                            .LeadSource[
                                                        index]
                                                            .name!;
                                                        LeadSourceBlocsId = state
                                                            .LeadSource[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .LeadSource[
                                                            index]
                                                                .name!,
                                                            state
                                                                .LeadSource[
                                                            index]
                                                                .id!);
                                                      }
                                                    });

                                                    BlocProvider.of<
                                                        LeadSourceBloc>(
                                                        context)
                                                        .add(SelectedLeadSource(
                                                        index,
                                                        state
                                                            .LeadSource[
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
                                                                    .LeadSource[
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
                                              _LeadSourceBlocSearchController
                                                  .clear();
                                              Navigator.pop(context);
                                            },
                                            onpressCreate: () {
                                              _LeadSourceBlocSearchController
                                                  .clear();
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    ));
                              }
                              return const SizedBox();
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
                                    ? (LeadSourceBlocsname?.isEmpty ?? true
                                    ? "Select Lead Source"
                                    : LeadSourceBlocsname!)
                                    : (LeadSourceBlocsname?.isEmpty ?? true
                                    ? widget.name!
                                    : LeadSourceBlocsname!),
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
            else if (state is LeadSourceError) {
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
                        _LeadSourceBlocSearchController.clear();

                        // Fetch initial LeadSourceBloc list
                      context
                            .read<LeadSourceBloc>()
                            .add(LeadSourceLists());
                    showDialog(
                          context: context,
                          builder: (ctx) => BlocConsumer<
                              LeadSourceBloc, LeadSourceState>(
                            listener: (context, state) {
                              if (state is LeadSourceSuccess) {
                                isLoadingMore = false;
                                setState(() {});
                              }
                            },
                            builder: (context, state) {
                              if (state is LeadSourceSuccess) {
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
                                            LeadSourceBloc>()
                                            .add(LeadSourceLoadMore(
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
                                                  .selectleadource,
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
                                                  _LeadSourceBlocSearchController,
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
                                                        LeadSourceBloc>()
                                                        .add(
                                                        SearchLeadSource(
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
                                        child:state.LeadSource.isEmpty ?NoData(isImage: true): ListView.builder(
                                          // physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: state.isLoadingMore
                                              ? state.LeadSource.length
                                              : state.LeadSource.length + 1,
                                          itemBuilder:
                                              (BuildContext context,
                                              int index) {
                                            if (index <
                                                state.LeadSource.length) {
                                              final isSelected =
                                                  LeadSourceBlocsId != null &&
                                                      state.LeadSource[index]
                                                          .id ==
                                                          LeadSourceBlocsId;
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
                                                        LeadSourceBlocsname =
                                                        state
                                                            .LeadSource[
                                                        index]
                                                            .name!;
                                                        LeadSourceBlocsId = state
                                                            .LeadSource[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .LeadSource[
                                                            index]
                                                                .name!,
                                                            state
                                                                .LeadSource[
                                                            index]
                                                                .id!);
                                                      } else {
                                                        name = state
                                                            .LeadSource[
                                                        index]
                                                            .name!;
                                                        LeadSourceBlocsname =
                                                        state
                                                            .LeadSource[
                                                        index]
                                                            .name!;
                                                        LeadSourceBlocsId = state
                                                            .LeadSource[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .LeadSource[
                                                            index]
                                                                .name!,
                                                            state
                                                                .LeadSource[
                                                            index]
                                                                .id!);
                                                      }
                                                    });

                                                    BlocProvider.of<
                                                        LeadSourceBloc>(
                                                        context)
                                                        .add(SelectedLeadSource(
                                                        index,
                                                        state
                                                            .LeadSource[
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
                                                                    .LeadSource[
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
                                              _LeadSourceBlocSearchController
                                                  .clear();
                                              Navigator.pop(context);
                                            },
                                            onpressCreate: () {
                                              _LeadSourceBlocSearchController
                                                  .clear();
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    ));
                              }
                              return const SizedBox();
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
                                    ? (LeadSourceBlocsname?.isEmpty ?? true
                                    ? "Select LeadSourceBloc"
                                    : LeadSourceBlocsname!)
                                    : (LeadSourceBlocsname?.isEmpty ?? true
                                    ? widget.name!
                                    : LeadSourceBlocsname!),
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
                      _LeadSourceBlocSearchController.clear();

                      // Fetch initial LeadSourceBloc list
                      context
                          .read<LeadSourceBloc>()
                          .add(LeadSourceLists());
                       showDialog(
                        context: context,
                        builder: (ctx) => BlocConsumer<
                            LeadSourceBloc, LeadSourceState>(
                          listener: (context, state) {
                            if (state is LeadSourceSuccess) {
                              isLoadingMore = false;
                              setState(() {});
                            }
                          },
                          builder: (context, state) {
                            if (state is LeadSourceSuccess) {
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
                                          LeadSourceBloc>()
                                          .add(LeadSourceLoadMore(
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
                                                .selectleadource,
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
                                                _LeadSourceBlocSearchController,
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
                                                      LeadSourceBloc>()
                                                      .add(
                                                      SearchLeadSource(
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
                                      child:state.LeadSource.isEmpty ?NoData(isImage: true): ListView.builder(
                                        // physics: const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: state.isLoadingMore
                                            ? state.LeadSource.length
                                            : state.LeadSource.length + 1,
                                        itemBuilder:
                                            (BuildContext context,
                                            int index) {
                                          if (index <
                                              state.LeadSource.length) {
                                            final isSelected =
                                                LeadSourceBlocsId != null &&
                                                    state.LeadSource[index]
                                                        .id ==
                                                        LeadSourceBlocsId;
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
                                                      LeadSourceBlocsname =
                                                      state
                                                          .LeadSource[
                                                      index]
                                                          .name!;
                                                      LeadSourceBlocsId = state
                                                          .LeadSource[
                                                      index]
                                                          .id!;
                                                      widget.onSelected(
                                                          state
                                                              .LeadSource[
                                                          index]
                                                              .name!,
                                                          state
                                                              .LeadSource[
                                                          index]
                                                              .id!);
                                                    } else {
                                                      name = state
                                                          .LeadSource[
                                                      index]
                                                          .name!;
                                                      LeadSourceBlocsname =
                                                      state
                                                          .LeadSource[
                                                      index]
                                                          .name!;
                                                      LeadSourceBlocsId = state
                                                          .LeadSource[
                                                      index]
                                                          .id!;
                                                      widget.onSelected(
                                                          state
                                                              .LeadSource[
                                                          index]
                                                              .name!,
                                                          state
                                                              .LeadSource[
                                                          index]
                                                              .id!);
                                                    }
                                                  });

                                                  BlocProvider.of<
                                                      LeadSourceBloc>(
                                                      context)
                                                      .add(SelectedLeadSource(
                                                      index,
                                                      state
                                                          .LeadSource[
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
                                                                  .LeadSource[
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
                                            _LeadSourceBlocSearchController
                                                .clear();
                                            Navigator.pop(context);
                                          },
                                          onpressCreate: () {
                                            _LeadSourceBlocSearchController
                                                .clear();
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    ],
                                  ));
                            }
                            return const SizedBox();
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
                                  ? (LeadSourceBlocsname?.isEmpty ?? true
                                  ? "Select Lead Source"
                                  : LeadSourceBlocsname!)
                                  : (LeadSourceBlocsname?.isEmpty ?? true
                                  ? widget.name!
                                  : LeadSourceBlocsname!),
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
