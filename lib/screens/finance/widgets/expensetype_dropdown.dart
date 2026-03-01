import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/bloc/expense_type/expense_type_bloc.dart';
import 'package:taskify/bloc/expense_type/expense_type_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/widgets/no_data.dart';

import '../../../bloc/expense_type/expense_type_event.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../../../src/generated/i18n/app_localizations.dart';

class ExpenseTypeField extends StatefulWidget {
  final bool isCreate;
  final String? name;
  final int? ExpenseType;
  final bool? isRequired;
  // final List<StatusModel> status;
  final int? index;
  final Function(String, int) onSelected;
  const ExpenseTypeField(
      {super.key,
        this.name,
        required this.isCreate,
        required this.ExpenseType,
        this.isRequired,
        required this.index,
        required this.onSelected});

  @override
  State<ExpenseTypeField> createState() => _ExpenseTypeFieldState();
}

class _ExpenseTypeFieldState extends State<ExpenseTypeField> {
  String? projectsname;
  String? name;
  int? projectsId;
  bool isLoadingMore = false;
  String searchWord = "";
  final TextEditingController _ExpenseTypeSearchController =
  TextEditingController();
  @override
  void initState() {

    name = widget.name!;
    if (!widget.isCreate) {
      projectsId = widget.ExpenseType;
      projectsname=widget.name;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


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
                text: AppLocalizations.of(context)!.expensetype,
                // text: getTranslated(context, 'myweeklyTask'),
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(width: 5.w,),
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
        BlocBuilder<ExpenseTypeBloc, ExpenseTypeState>(
          builder: (context, state) {
            print("gvbhdfnd $state");
            if (state is ExpenseTypeSuccess) {
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
                          builder: (ctx) => NotificationListener<ScrollNotification>(
                            onNotification: (scrollInfo) {
                              // Handle scroll for pagination if required
                              return false;
                            },
                            child: AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,
                              title: Center(
                                child: Column(
                                  children: [
                                    CustomText(
                                      text: AppLocalizations.of(context)!.selectExpenseType,
                                      fontWeight: FontWeight.w800,
                                      size: 20,
                                      color: Theme.of(context).colorScheme.whitepurpleChange,
                                    ),
                                    const Divider(),
                                    // Your search bar and other widgets here...
                                  ],
                                ),
                              ),
                              content: StatefulBuilder(
                                  builder: (BuildContext context, StateSetter setState) {
                                    return
                                      Container(
                                        constraints: BoxConstraints(maxHeight: 900.h),
                                        width: MediaQuery.of(context).size.width,
                                        child: state.ExpenseType.isNotEmpty ?ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: state.ExpenseType.length + (state.isLoadingMore ? 1 : 0),
                                          itemBuilder: (BuildContext context, int index) {
                                            if (index >= state.ExpenseType.length) {
                                              return Container();  // Return empty container for invalid index.
                                            }
                                            final isSelected = state.ExpenseType[index].id == projectsId;

                                            return Padding(
                                              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 20.w),
                                              child: InkWell(
                                                highlightColor: Colors.transparent,
                                                splashColor: Colors.transparent,
                                                onTap: () {
                                                  setState(() {
                                                    projectsname = state.ExpenseType[index].title!;
                                                    projectsId = state.ExpenseType[index].id!;
                                                  });

                                                  widget.onSelected(state.ExpenseType[index].title!, state.ExpenseType[index].id!);
                                                },
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 250),
                                                  curve: Curves.easeInOut,
                                                  decoration: BoxDecoration(
                                                    color: isSelected ? AppColors.purpleShade : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
                                                  ),
                                                  width: double.infinity,
                                                  height: 40.h,
                                                  child: Center(
                                                    child: Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          CustomText(
                                                            text: state.ExpenseType[index].title!,
                                                            fontWeight: FontWeight.w500,
                                                            size: 18,
                                                            color: isSelected ? AppColors.purple : Theme.of(context).colorScheme.textClrChange,
                                                          ),
                                                          if (isSelected)
                                                            const HeroIcon(
                                                              HeroIcons.checkCircle,
                                                              style: HeroIconStyle.solid,
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
                                        ):NoData(isImage: true,),
                                      );}),

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
                      }
                      ,
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
                                    ? AppLocalizations.of(context)!.selectExpenseType
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
            }
            else if (state is ExpenseTypeInitial) {
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
                        // Fetch ExpenseTypees
                        showDialog(
                          context: context,
                          builder: (ctx) =>
                              BlocConsumer<ExpenseTypeBloc, ExpenseTypeState>(
                                listener: (context, state) {
                                  if (state is ExpenseTypeSuccess) {
                                    isLoadingMore = false;
                                    setState(() {});
                                  }
                                },
                                builder: (context, state) {
                                  print("gvbhdfnd $state");
                                  if (state is ExpenseTypeSuccess) {
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
                                                .read<ExpenseTypeBloc>()
                                                .add(ExpenseTypeLoadMore(searchWord));
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
                                                      .selectExpenseType,
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
                                                      _ExpenseTypeSearchController,
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
                                                            .read<ExpenseTypeBloc>()
                                                            .add(SearchExpenseType(
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
                                            child: state.ExpenseType.isNotEmpty
                                                ? ListView.builder(
                                              // physics: const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount:
                                              state.ExpenseType.length +
                                                  (state.isLoadingMore
                                                      ? 1
                                                      : 0),

                                              itemBuilder:
                                                  (BuildContext context,
                                                  int index) {
                                                if (index <
                                                    state.ExpenseType.length) {
                                                  final isSelected =
                                                      projectsId != null &&
                                                          state
                                                              .ExpenseType[
                                                          index]
                                                              .id ==
                                                              projectsId;
                                                  print("erfghb $isSelected");
                                                  // final isSelected = projectsId != null &&
                                                  //     state.ExpenseType[index].id ==
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
                                                                .ExpenseType[
                                                            index]
                                                                .title!;
                                                            projectsId = state
                                                                .ExpenseType[
                                                            index]
                                                                .id!;
                                                            widget.onSelected(
                                                                state
                                                                    .ExpenseType[
                                                                index]
                                                                    .title!,
                                                                state
                                                                    .ExpenseType[
                                                                index]
                                                                    .id!);
                                                          } else {
                                                            name = state
                                                                .ExpenseType[
                                                            index]
                                                                .title;
                                                            projectsname =
                                                            state
                                                                .ExpenseType[
                                                            index]
                                                                .title!;
                                                            projectsId = state
                                                                .ExpenseType[
                                                            index]
                                                                .id!;

                                                            widget.onSelected(
                                                                state
                                                                    .ExpenseType[
                                                                index]
                                                                    .title!,
                                                                state
                                                                    .ExpenseType[
                                                                index]
                                                                    .id!);
                                                          }
                                                        });
                                                        print(
                                                            "erfghb $isSelected");
                                                        BlocProvider.of<
                                                            ExpenseTypeBloc>(
                                                            context)
                                                            .add(SelectedExpenseType(
                                                            index,
                                                            state
                                                                .ExpenseType[
                                                            index]
                                                                .title!));

                                                        BlocProvider.of<
                                                            ExpenseTypeBloc>(
                                                            context)
                                                            .add(SelectedExpenseType(
                                                            index,
                                                            state
                                                                .ExpenseType[
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
                                                                      .ExpenseType[
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
                                                  _ExpenseTypeSearchController.clear();
                                                  Navigator.pop(context);
                                                },
                                                onpressCreate: () {
                                                  _ExpenseTypeSearchController.clear();
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
                                    ? AppLocalizations.of(context)!.selectExpenseType
                                    : projectsname!)
                                    : (widget.name?.isEmpty ?? true
                                    ? AppLocalizations.of(context)!.selectExpenseType
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
                        //   items:  titleName.map((ExpenseType) {
                        //     return DropdownMenuItem<String>(
                        //       value: ExpenseType,
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
                        //                   text: ExpenseType,
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
                        //           text: 'ExpenseType',
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
            else if (state is ExpenseTypeLoading) {
            }
            else if (state is ExpenseTypeError) {
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
                                  ? AppLocalizations.of(context)!.selectExpenseType
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
                        //   items:  titleName.map((ExpenseType) {
                        //     return DropdownMenuItem<String>(
                        //       value: ExpenseType,
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
                        //                   text: ExpenseType,
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
                        //           text: 'ExpenseType',
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
