import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:taskify/config/colors.dart';
import '../../bloc/roles_multi/role_multi_bloc.dart';
import '../../bloc/roles_multi/role_multi_event.dart';
import '../../bloc/roles_multi/role_multi_state.dart';
import '../../utils/widgets/custom_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'custom_cancel_create_button.dart';
import 'package:heroicons/heroicons.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class RoleMultiField extends StatefulWidget {
  final bool fromProfile;
  final String? title;

  final bool isCreate;
  final List<String>? name;
  final List<int>? nameId;
  final bool? isEdit;
  final bool? isRequired;
  final bool? isProfile;
  // final List<RoleMultiModel> RoleMulti;
  final Function(List<String>?, List<int>?) onSelectedRoleMulti;
  const RoleMultiField(
      {super.key,
        required this.fromProfile,
        required this.isCreate,
        this.isEdit,
        this.nameId,
        this.title,
        this.isRequired,
        this.name,
        this.isProfile,
        // required this.RoleMulti,

        required this.onSelectedRoleMulti,
      });

  @override
  State<RoleMultiField> createState() => _RoleMultiFieldState();
}

class _RoleMultiFieldState extends State<RoleMultiField> {
  List<String?> RoleMultiname = [];
  List<int?> RoleMultiId = [];
  String searchWord = "";
  final TextEditingController _RoleMultiSearchController = TextEditingController();

  @override
  void initState() {

    // if (!widget.isCreate && RoleMultiId != null) {
    //   if (widget.isCreate == true) {
    //     RoleMultiId.add(userId!);
    //   }
    // }else{
    //   BlocProvider.of<UserBloc>(context).add(UserList());
    //
    // }

    if (!widget.isCreate) {
      if (widget.name != null ) {
        RoleMultiname.addAll(widget.name!);
        RoleMultiId.addAll(widget.nameId!);
        // Add all elements from widget.name
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocConsumer<RoleMultiBloc, RoleMultiState>(
          listener: (context, state) {
            if (state is RoleMultiSuccess) {
              print("Listener detected update - selectedRoleMultinames: ${state.selectedRoleMultinames}");
            }
          },
          builder: (context, state) {

            if (state is RoleMultiInitial) {
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.fromProfile == true
                        ? const SizedBox.shrink()
                        : Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                      ),
                      child: Row(
                        children: [
                          CustomText(
                            text: widget.title ??
                                AppLocalizations.of(context)!.role,
                            // text: getTranslated(context, 'myweeklyTask'),
                            color: Theme.of(context)
                                .colorScheme
                                .textClrChange,
                            size: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          widget.isRequired == true
                              ? const CustomText(
                            text: " *",
                            // text: getTranslated(context, 'myweeklyTask'),
                            color: AppColors.red,
                            size: 15,
                            fontWeight: FontWeight.w400,
                          )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                    widget.fromProfile == true
                        ? SizedBox(height: 2.h)
                        : SizedBox(height: 5.h),
                    InkWell(
                      highlightColor: Colors.transparent, // No highlight on tap
                      splashColor: Colors.transparent,
                      onTap: () {
                        // Fetch RoleMulties
                        widget.fromProfile == true
                            ? SizedBox.shrink()
                            : showDialog(
                          context: context,
                          builder: (ctx) =>
                              BlocBuilder<RoleMultiBloc, RoleMultiState>(
                                builder: (context, state) {
                                  if (state is RoleMultiSuccess) {
                                    return NotificationListener<
                                        ScrollNotification>(
                                        onNotification: (scrollInfo) {
                                          print(
                                              "rdiugfrdg ${state.hasReachedMax && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent}");
                                          print("sbcsjc ${state.hasReachedMax}");
                                          // Check if the user has scrolled to the end and load more notes if needed
                                          if (state.hasReachedMax &&
                                              scrollInfo.metrics.pixels ==
                                                  scrollInfo
                                                      .metrics.maxScrollExtent) {
                                            // isLoadingMore = true;

                                            context
                                                .read<RoleMultiBloc>()
                                                .add(RoleMultiLoadMore(search: searchWord));
                                          }
                                          // isLoadingMore = false;
                                          return false;
                                        }, child: StatefulBuilder(builder:
                                        (BuildContext context,
                                        void Function(void Function())
                                        setState) {
                                      return AlertDialog(
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
                                                    .selectrole,
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
                                                    _RoleMultiSearchController,
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
                                                          .read<RoleMultiBloc>()
                                                          .add(SearchRoleMulti(
                                                          value));
                                                    },
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5.h,
                                              ),
                                            ],
                                          ),
                                        ),
                                        content: Container(
                                          constraints: BoxConstraints(
                                              maxHeight: 900.h),
                                          width: 200.w,

                                          margin: EdgeInsets.symmetric(
                                              horizontal: 20.w),

                                          // constraints:
                                          // BoxConstraints(maxHeight: 900.h),
                                          // width: 200.w,
                                          child: ListView.builder(
                                              physics:
                                              const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount:
                                              state.RoleMulti.length + 1,
                                              itemBuilder:
                                                  (BuildContext context,
                                                  int index) {
                                                if (index <
                                                    state.RoleMulti.length) {
                                                  bool isSelected =
                                                  RoleMultiId.contains(state
                                                      .RoleMulti[index].id!);
                                                  ;
                                                  return Padding(
                                                    padding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 2.h,
                                                        horizontal: 0.w),
                                                    child: InkWell(
                                                      highlightColor:
                                                      Colors.transparent,
                                                      // No highlight on tap
                                                      splashColor:
                                                      Colors.transparent,
                                                      onTap: () {
                                                        setState(() {
                                                          if (isSelected) {
                                                            RoleMultiId.remove(
                                                                state
                                                                    .RoleMulti[
                                                                index]
                                                                    .id!);
                                                            RoleMultiname.remove(
                                                                state
                                                                    .RoleMulti[
                                                                index]
                                                                    .name!);
                                                          } else {
                                                            RoleMultiId.add(state
                                                                .RoleMulti[index]
                                                                .id!);
                                                            RoleMultiname.add(state
                                                                .RoleMulti[index]
                                                                .name!);
                                                          }
                                                          widget.onSelectedRoleMulti(
                                                            RoleMultiname
                                                                .whereType<
                                                                String>()
                                                                .toList(),
                                                            RoleMultiId
                                                                .whereType<
                                                                int>()
                                                                .toList(),
                                                          );
                                                          BlocProvider.of<
                                                              RoleMultiBloc>(
                                                              context)
                                                              .add(SelectedRoleMulti(
                                                              index,
                                                              state
                                                                  .RoleMulti[
                                                              index]
                                                                  .name!));
                                                          BlocProvider.of<
                                                              RoleMultiBloc>(
                                                              context)
                                                              .add(
                                                            ToggleRoleMultiSelection(
                                                              index,
                                                              state
                                                                  .RoleMulti[index]
                                                                  .name!,
                                                            ),
                                                          );
                                                        });
                                                      },
                                                      child: Container(
                                                        width:
                                                        double.infinity,
                                                        height: 35.h,
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
                                                        child: Center(
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                18.w),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                  150.w,
                                                                  // color: Colors.red,
                                                                  child:
                                                                  CustomText(
                                                                    text: state
                                                                        .RoleMulti[
                                                                    index]
                                                                        .name!,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                    size:
                                                                    18.sp,
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
                                                                    ? const HeroIcon(
                                                                    HeroIcons
                                                                        .checkCircle,
                                                                    style: HeroIconStyle
                                                                        .solid,
                                                                    color: AppColors
                                                                        .purple)
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
                                              }),
                                        ),
                                        actions: <Widget>[
                                          Padding(
                                            padding:
                                            EdgeInsets.only(top: 20.h),
                                            child: CreateCancelButtom(
                                              title: "OK",
                                              onpressCancel: () {
                                                Navigator.pop(context);
                                              },
                                              onpressCreate: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    }));
                                  }
                                  return const Center(
                                      child: Text('Loading...'));
                                },
                              ),
                        );
                      },
                      child: Container(
                        height: 40.h,
                        width: double.infinity,
                        margin: widget.fromProfile == true
                            ? const EdgeInsets.symmetric(horizontal: 10)
                            : const EdgeInsets.symmetric(horizontal: 20),
                        decoration: widget.fromProfile == true
                            ? BoxDecoration(
                          // color: Colors.red,
                          color:
                          Theme.of(context).colorScheme.containerDark,
                        )
                            : BoxDecoration(
                          // color: Colors.red,
                          border: Border.all(color: AppColors.greyColor),

                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  // color: Colors.red,
                                  child: CustomText(
                                    text: widget.isCreate
                                        ? (RoleMultiname.isNotEmpty
                                        ? RoleMultiname.join(", ")
                                        : AppLocalizations.of(context)!
                                        .selectusers)
                                        : (widget.name!.isNotEmpty
                                        ? widget.name!.join(", ")
                                        : AppLocalizations.of(context)!
                                        .selectusers),
                                    fontWeight: FontWeight.w500,
                                    size: 14.sp,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,

                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            } else if (state is RoleMultiLoading) {
              return const Text("");
            } else if (state is RoleMultiSuccess) {
              String displayText = AppLocalizations.of(context)!.selectusers;

              if (state.selectedRoleMultinames.isNotEmpty) {
                displayText = state.selectedRoleMultinames.join(", ");
              }
              print("Listener detected update - selectedRoleMultinames: ${state.selectedRoleMultinames}");
              print("Listener detected update - selectedRoleMultinamesfcsadae : ${displayText}");

              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.fromProfile == true
                        ? const SizedBox.shrink()
                        : Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                      ),
                      child: Row(
                        children: [
                          CustomText(
                            text: widget.title ??
                                AppLocalizations.of(context)!.role,
                            // text: getTranslated(context, 'myweeklyTask'),
                            color: Theme.of(context)
                                .colorScheme
                                .textClrChange,
                            size: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          widget.isRequired == true
                              ? const CustomText(
                            text: " *",
                            // text: getTranslated(context, 'myweeklyTask'),
                            color: AppColors.red,
                            size: 15,
                            fontWeight: FontWeight.w400,
                          )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                    widget.fromProfile == true
                        ? SizedBox(height: 2.h)
                        : SizedBox(height: 5.h),
                    InkWell(
                      highlightColor: Colors.transparent, // No highlight on tap
                      splashColor: Colors.transparent,
                      onTap: () {
                        // Fetch RoleMulties
                        widget.fromProfile == true
                            ? SizedBox.shrink()
                            : showDialog(
                            context: context,
                            builder: (ctx) =>
                                NotificationListener<
                                    ScrollNotification>(
                                    onNotification: (scrollInfo) {
                                      // Check if the user has scrolled to the end and load more notes if needed
                                      if (state.hasReachedMax &&
                                          scrollInfo.metrics.pixels ==
                                              scrollInfo
                                                  .metrics.maxScrollExtent) {
                                        // isLoadingMore = true;

                                        context
                                            .read<RoleMultiBloc>()
                                            .add(RoleMultiLoadMore(search: searchWord));
                                      }
                                      // isLoadingMore = false;
                                      return false;
                                    },
                                    child: StatefulBuilder(builder:
                                        (BuildContext context,
                                        void Function(void Function())
                                        setState) {
                                      return AlertDialog(
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
                                                    .selectrole,
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
                                                    _RoleMultiSearchController,
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
                                                          .read<RoleMultiBloc>()
                                                          .add(SearchRoleMulti(
                                                          value));
                                                    },
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5.h,
                                              ),
                                            ],
                                          ),
                                        ),
                                        content: Container(
                                          constraints: BoxConstraints(
                                              maxHeight: 900.h),
                                          width: 200.w,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 20.w),
                                          child: ListView.builder(
                                              physics:
                                              const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount:
                                              state.RoleMulti.length + 1,
                                              itemBuilder:
                                                  (BuildContext context,
                                                  int index) {
                                                if (index <
                                                    state.RoleMulti.length) {
                                                  bool isSelected =
                                                  RoleMultiId.contains(state
                                                      .RoleMulti[index].id);

                                                  return Padding(
                                                    padding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 2.h,
                                                        horizontal: 0.w),
                                                    child: InkWell(
                                                      highlightColor:
                                                      Colors.transparent,
                                                      // No highlight on tap
                                                      splashColor:
                                                      Colors.transparent,
                                                      onTap: () {
                                                        setState(() {
                                                          if (isSelected) {
                                                            RoleMultiId.remove(
                                                                state
                                                                    .RoleMulti[
                                                                index]
                                                                    .id!);
                                                            RoleMultiname.remove(
                                                                state
                                                                    .RoleMulti[
                                                                index]
                                                                    .name!);
                                                            print("klfd $RoleMultiname");
                                                          } else {
                                                            RoleMultiId.add(state
                                                                .RoleMulti[index]
                                                                .id!);
                                                            RoleMultiname.add(state
                                                                .RoleMulti[index]
                                                                .name!);
                                                            print("esrfsa $RoleMultiname");
                                                          }
                                                          widget.onSelectedRoleMulti(
                                                            RoleMultiname
                                                                .whereType<
                                                                String>()
                                                                .toList(),
                                                            RoleMultiId
                                                                .whereType<
                                                                int>()
                                                                .toList(),
                                                          );
                                                          print("fEMNFK ${RoleMultiname
                                                              .whereType<
                                                              String>()
                                                              .toList()}");
                                                          print("fEMNFK ${RoleMultiId
                                                              .whereType<
                                                              int>()
                                                              .toList()}");

                                                        });

                                                        BlocProvider.of<
                                                            RoleMultiBloc>(
                                                            context)
                                                            .add(SelectedRoleMulti(
                                                            index,
                                                            state
                                                                .RoleMulti[
                                                            index]
                                                                .name!));
                                                        context.read<RoleMultiBloc>().add(
                                                          ToggleRoleMultiSelection(index, state.RoleMulti[index].name!),
                                                          // BlocProvider.of<
                                                          //     RoleMultiBloc>(
                                                          //     context)
                                                          //     .add(
                                                          //   ToggleRoleMultiSelection(
                                                          //     index,
                                                          //     state
                                                          //         .RoleMulti[index]
                                                          //         .name!,
                                                          //   ),
                                                          // );

                                                        );},
                                                      child: Container(
                                                        width:
                                                        double.infinity,
                                                        height: 35.h,
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
                                                        child: Center(
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                18.w),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                  150.w,
                                                                  // color: Colors.red,
                                                                  child:
                                                                  CustomText(
                                                                    text: state
                                                                        .RoleMulti[
                                                                    index]
                                                                        .name!,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                    size:
                                                                    18.sp,
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
                                                                    ? const HeroIcon(
                                                                    HeroIcons
                                                                        .checkCircle,
                                                                    style: HeroIconStyle
                                                                        .solid,
                                                                    color: AppColors
                                                                        .purple)
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
                                              }),
                                        ),
                                        actions: <Widget>[
                                          Padding(
                                            padding:
                                            EdgeInsets.only(top: 20.h),
                                            child: CreateCancelButtom(
                                              title: "OK",
                                              onpressCancel: () {
                                                Navigator.pop(context);
                                              },
                                              onpressCreate: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    })));


                      },
                      child: Container(
                        height: 40.h,
                        width: double.infinity,
                        margin: widget.fromProfile == true
                            ? const EdgeInsets.symmetric(horizontal: 10)
                            : const EdgeInsets.symmetric(horizontal: 20),
                        decoration: widget.fromProfile == true
                            ? BoxDecoration(
                          // color: Colors.red,
                          color:
                          Theme.of(context).colorScheme.containerDark,
                        )
                            : BoxDecoration(
                          // color: Colors.red,
                          border: Border.all(color: AppColors.greyColor),

                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  //                   // color: Colors.red,
                                  child: CustomText(

                                    text: widget.isCreate
                                        ? (RoleMultiname.isNotEmpty
                                        ? RoleMultiname.join(", ")
                                        : AppLocalizations.of(context)!.selectusers)
                                        : (widget.name!.isNotEmpty
                                        ?RoleMultiname.join(", ")
                                        : AppLocalizations.of(context)!.selectusers),
                                    fontWeight: FontWeight.w500,
                                    size: 14.sp,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,

                              ),
                            ],
                          ),
                        ),

                      ),
                    )
                  ],
                ),
              );
            } else if (state is RoleMultiError) {
              return Text("ERROR ${state.errorMessage}");
            }
            return Container();
          },
        )
      ],
    );
  }
}
