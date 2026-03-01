import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import '../../../bloc/priority/priority_event.dart';
import '../../../bloc/priority/priority_state.dart';
import '../../../bloc/priority/priority_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../widgets/custom_cancel_create_button.dart';

class PriorityAllField extends StatefulWidget {
  final bool isCreate;
  final String? name;
  final int? priority;
  final bool? isRequired;
  // final List<StatusModel> status;
  final int? index;
  final Function(String, int) onSelected;
  const PriorityAllField(
      {super.key,
      this.name,
      required this.isCreate,
      required this.priority,
      this.isRequired,
      required this.index,
      required this.onSelected});

  @override
  State<PriorityAllField> createState() => _PriorityAllFieldState();
}

class _PriorityAllFieldState extends State<PriorityAllField> {
  String? projectsname;
  String? name;
  int? projectsId;
  bool isLoadingMore = false;
  String searchWord = "";
  final TextEditingController _prioritySearchController =
      TextEditingController();
  @override
  void initState() {
    name = widget.name!;
    if (!widget.isCreate) {
      projectsId = widget.priority;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//     if (!widget.isCreate) {
//       print("njnjkl;fdfg ${widget.priority}");
//       print("njnjkl;fdfg ${widget.name}");
//       projectsId = widget.priority;
// projectsname=widget.name;
//
//     }

    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
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
                text: AppLocalizations.of(context)!.priority,
                // text: getTranslated(context, 'myweeklyTask'),
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
              widget.isRequired == true
                  ? CustomText(
                      text: "*",
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
        BlocBuilder<PriorityBloc, PriorityState>(
          builder: (context, state) {
            print("gvbhdfnd $state");
            if (state is PrioritySuccess) {
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
                        // Pass the selected state when opening the dialog
                        showDialog(
                          context: context,
                          builder: (ctx) =>
                              NotificationListener<ScrollNotification>(
                            onNotification: (scrollInfo) {
                              // Handle scroll for pagination if required
                              return false;
                            },
                            child: AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .alertBoxBackGroundColor,
                              title: Center(
                                child: Column(
                                  children: [
                                    CustomText(
                                      text: AppLocalizations.of(context)!
                                          .selectpriority,
                                      fontWeight: FontWeight.w800,
                                      size: 20,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .whitepurpleChange,
                                    ),
                                    const Divider(),
                                    // Your search bar and other widgets here...
                                  ],
                                ),
                              ),
                              content: StatefulBuilder(builder:
                                  (BuildContext context, StateSetter setState) {
                                return Container(
                                  constraints: BoxConstraints(maxHeight: 900.h),
                                  width: MediaQuery.of(context).size.width,
                                  child: state
                                      .priority.isEmpty?NoData(isImage: true,):ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: state.priority.length +
                                        (state.isLoadingMore ? 1 : 0),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (index >= state.priority.length) {
                                        return Container(); // Return empty container for invalid index.
                                      }
                                      final isSelected =
                                          state.priority[index].id ==
                                              projectsId;

                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 2.h, horizontal: 20.w),
                                        child: InkWell(
                                          highlightColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          onTap: () {
                                            setState(() {
                                              projectsname =
                                                  state.priority[index].title!;
                                              projectsId =
                                                  state.priority[index].id!;
                                            });

                                            widget.onSelected(
                                                state.priority[index].title!,
                                                state.priority[index].id!);
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 250),
                                            curve: Curves.easeInOut,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.purpleShade
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: isSelected
                                                      ? AppColors.primary
                                                      : Colors.transparent),
                                            ),
                                            width: double.infinity,
                                            height: 40.h,
                                            child: Center(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.w),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    CustomText(
                                                      text: state
                                                          .priority[index]
                                                          .title!,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      size: 18,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      color: isSelected
                                                          ? AppColors.purple
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .textClrChange,
                                                    ),
                                                    if (isSelected)
                                                      const HeroIcon(
                                                        HeroIcons.checkCircle,
                                                        style:
                                                            HeroIconStyle.solid,
                                                        color: AppColors.purple,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }),
                              actions: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(top: 20.h),
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
                            ),
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
                              CustomText(
                                text: (projectsname?.isEmpty ?? true)
                                    ? "Select Priority"
                                    : projectsname!,
                                fontWeight: FontWeight.w500,
                                size: 14.sp,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ]),
                      ),
                    )
                  ],
                ),
              );
            } else if (state is PriorityInitial) {
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
                        // Fetch Priorityes
                        showDialog(
                          context: context,
                          builder: (ctx) =>
                              BlocConsumer<PriorityBloc, PriorityState>(
                            listener: (context, state) {
                              if (state is PrioritySuccess) {
                                isLoadingMore = false;
                                setState(() {});
                              }
                            },
                            builder: (context, state) {
                              print("gvbhdfnd $state");
                              if (state is PrioritySuccess) {
                                return NotificationListener<ScrollNotification>(
                                    onNotification: (scrollInfo) {
                                      // Check if the user has scrolled to the end and load more notes if needed
                                      if (!state.isLoadingMore &&
                                          scrollInfo.metrics.pixels ==
                                              scrollInfo
                                                  .metrics.maxScrollExtent &&
                                          isLoadingMore == false) {
                                        isLoadingMore = true;
                                        setState(() {});
                                        context
                                            .read<PriorityBloc>()
                                            .add(PriorityLoadMore(searchWord));
                                      }
                                      isLoadingMore = false;
                                      return false;
                                    },
                                    child: AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10
                                            .r), // Set the desired radius here
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .alertBoxBackGroundColor,
                                      contentPadding: EdgeInsets.zero,
                                      title: Center(
                                        child: Column(
                                          children: [
                                            CustomText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .selectpriority,
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
                                                  cursorColor:
                                                      AppColors.greyForgetColor,
                                                  cursorWidth: 1,
                                                  controller:
                                                      _prioritySearchController,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                      vertical:
                                                          (35.h - 20.sp) / 2,
                                                      horizontal: 10.w,
                                                    ),
                                                    hintText:
                                                        AppLocalizations.of(
                                                                context)!
                                                            .search,
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
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
                                                          BorderRadius.circular(
                                                              10.0),
                                                      borderSide: BorderSide(
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
                                                        .read<PriorityBloc>()
                                                        .add(SearchPriority(
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
                                        constraints:
                                            BoxConstraints(maxHeight: 900.h),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: state.priority.isNotEmpty
                                            ? state
                                            .priority.isEmpty?NoData(isImage: true,):ListView.builder(
                                                // physics: const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount:
                                                    state.priority.length +
                                                        (state.isLoadingMore
                                                            ? 1
                                                            : 0),

                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  if (index < state.priority.length) {
                                                    final isSelected =
                                                        projectsId != null &&
                                                            state
                                                                    .priority[
                                                                        index]
                                                                    .id ==
                                                                projectsId;
                                                    print("erfghb $isSelected");
                                                    // final isSelected = projectsId != null &&
                                                    //     state.priority[index].id ==
                                                    //         projectsId;
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
                                                                      .priority[
                                                                          index]
                                                                      .title!;
                                                              projectsId = state
                                                                  .priority[
                                                                      index]
                                                                  .id!;
                                                              widget.onSelected(
                                                                  state
                                                                      .priority[
                                                                          index]
                                                                      .title!,
                                                                  state
                                                                      .priority[
                                                                          index]
                                                                      .id!);
                                                            } else {
                                                              name = state
                                                                  .priority[
                                                                      index]
                                                                  .title;
                                                              projectsname =
                                                                  state
                                                                      .priority[
                                                                          index]
                                                                      .title!;
                                                              projectsId = state
                                                                  .priority[
                                                                      index]
                                                                  .id!;

                                                              widget.onSelected(
                                                                  state
                                                                      .priority[
                                                                          index]
                                                                      .title!,
                                                                  state
                                                                      .priority[
                                                                          index]
                                                                      .id!);
                                                            }
                                                          });
                                                          print(
                                                              "erfghb $isSelected");
                                                          BlocProvider.of<
                                                                      PriorityBloc>(
                                                                  context)
                                                              .add(SelectedPriority(
                                                                  index,
                                                                  state
                                                                      .priority[
                                                                          index]
                                                                      .title!));

                                                          BlocProvider.of<
                                                                      PriorityBloc>(
                                                                  context)
                                                              .add(SelectedPriority(
                                                                  index,
                                                                  state
                                                                      .priority[
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
                                                                  CustomText(
                                                                    text: state
                                                                        .priority[
                                                                            index]
                                                                        .title!,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    size: 18,
                                                                    color: isSelected
                                                                        ? AppColors
                                                                            .purple
                                                                        : Theme.of(context)
                                                                            .colorScheme
                                                                            .textClrChange,
                                                                  ),
                                                                  isSelected
                                                                      ? const HeroIcon(
                                                                          HeroIcons
                                                                              .checkCircle,
                                                                          style:
                                                                              HeroIconStyle.solid,
                                                                          color:
                                                                              AppColors.purple,
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
                                              )
                                            : NoData(),
                                      ),
                                      actions: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(top: 20.h),
                                          child: CreateCancelButtom(
                                            title: "OK",
                                            onpressCancel: () {
                                              _prioritySearchController.clear();
                                              Navigator.pop(context);
                                            },
                                            onpressCreate: () {
                                              _prioritySearchController.clear();
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    ));
                              }
                              return const Center(child: Text('Loading...'));
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
                              CustomText(
                                text: widget.isCreate
                                    ? (projectsname?.isEmpty ?? true
                                        ? "Select Priority"
                                        : projectsname!)
                                    : (widget.name?.isEmpty ?? true
                                        ? "Select Priority"
                                        : widget.name!),
                                fontWeight: FontWeight.w500,
                                size: 14.sp,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ]),
                        // child: CustomDropdown(options: titleName,)
                        // DropdownButton<String>(
                        //   items:  titleName.map((Priority) {
                        //     return DropdownMenuItem<String>(
                        //       value: Priority,
                        //       child: Padding(
                        //         padding: const EdgeInsets.all(8.0),
                        //         child: Center(
                        //           child: Container(
                        //             height: 50,
                        //             width: 300,
                        //             decoration: BoxDecoration(
                        //                 boxShadow: [
                        //                   isLightTheme
                        //                       ? MyThemes.lightThemeShadow
                        //                       : MyThemes.darkThemeShadow,
                        //                 ],
                        //                 color:
                        //                     Theme.of(context).colorScheme.containerDark,
                        //                 border: Border.all(
                        //                     color: Theme.of(context)
                        //                         .colorScheme
                        //                         .bgColorChange),
                        //                 borderRadius: BorderRadius.circular(10)),
                        //             child: Center(
                        //               child: CustomText(
                        //                   text: Priority,
                        //                   fontWeight: FontWeight.w400,
                        //                   size: 12,
                        //                   color: colors.blackColor),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     );
                        //   }).toList(),
                        //   hint: selectedCategory.isEmpty
                        //       ? CustomText(
                        //           text: 'Priority',
                        //           fontWeight: FontWeight.w400,
                        //           size: 12,
                        //           color: colors.greyForgetColor)
                        //       : CustomText(
                        //           text: selectedCategory,
                        //           fontWeight: FontWeight.w400,
                        //           size: 12,
                        //           color: colors.greyForgetColor),
                        //   borderRadius: BorderRadius.circular(10),
                        //   underline: SizedBox(),
                        //   isExpanded: true,
                        //   onChanged: (value) {
                        //     if (value != null) {
                        //       setState(() {
                        //         selectedCategory = value;
                        //       });
                        //     }
                        //   },
                        // ),
                      ),
                    )
                  ],
                ),
              );
            } else if (state is PriorityLoading) {
            } else if (state is PriorityError) {
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
                        flutterToastCustom(msg: state.errorMessage);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        height: 40.h,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.greyColor),
                            color: Theme.of(context).colorScheme.containerDark,
                            boxShadow: [
                              isLightTheme
                                  ? MyThemes.lightThemeShadow
                                  : MyThemes.darkThemeShadow,
                            ]),
                        // decoration: DesignConfiguration.shadow(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: widget.isCreate
                                  ? (projectsname?.isEmpty ?? true
                                      ? "Select Priority"
                                      : projectsname!)
                                  : (projectsname?.isEmpty ?? true
                                      ? widget.name!
                                      : projectsname!),
                              // text:  Projectsname ,
                              fontWeight: FontWeight.w400,
                              size: 12,
                              color: AppColors.greyForgetColor,
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                        // child: CustomDropdown(options: titleName,)
                        // DropdownButton<String>(
                        //   items:  titleName.map((Priority) {
                        //     return DropdownMenuItem<String>(
                        //       value: Priority,
                        //       child: Padding(
                        //         padding: const EdgeInsets.all(8.0),
                        //         child: Center(
                        //           child: Container(
                        //             height: 50,
                        //             width: 300,
                        //             decoration: BoxDecoration(
                        //                 boxShadow: [
                        //                   isLightTheme
                        //                       ? MyThemes.lightThemeShadow
                        //                       : MyThemes.darkThemeShadow,
                        //                 ],
                        //                 color:
                        //                     Theme.of(context).colorScheme.containerDark,
                        //                 border: Border.all(
                        //                     color: Theme.of(context)
                        //                         .colorScheme
                        //                         .bgColorChange),
                        //                 borderRadius: BorderRadius.circular(10)),
                        //             child: Center(
                        //               child: CustomText(
                        //                   text: Priority,
                        //                   fontWeight: FontWeight.w400,
                        //                   size: 12,
                        //                   color: colors.blackColor),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     );
                        //   }).toList(),
                        //   hint: selectedCategory.isEmpty
                        //       ? CustomText(
                        //           text: 'Priority',
                        //           fontWeight: FontWeight.w400,
                        //           size: 12,
                        //           color: colors.greyForgetColor)
                        //       : CustomText(
                        //           text: selectedCategory,
                        //           fontWeight: FontWeight.w400,
                        //           size: 12,
                        //           color: colors.greyForgetColor),
                        //   borderRadius: BorderRadius.circular(10),
                        //   underline: SizedBox(),
                        //   isExpanded: true,
                        //   onChanged: (value) {
                        //     if (value != null) {
                        //       setState(() {
                        //         selectedCategory = value;
                        //       });
                        //     }
                        //   },
                        // ),
                      ),
                    )
                  ],
                ),
              );
            }
            return Container();
          },
        )
      ],
    );
  }
}
