import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:taskify/bloc/taxes/tax_event.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'package:heroicons/heroicons.dart';
import 'package:taskify/screens/widgets/no_data.dart';

import '../../../../bloc/taxes/tax_bloc.dart';
import '../../../../bloc/taxes/tax_state.dart';

import '../../../../utils/widgets/custom_text.dart';
import '../../../widgets/custom_cancel_create_button.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
class TaxesListField extends StatefulWidget {
  final bool fromProfile;
  final bool isCreate;
  final List<String>? name;
  final List<int>? ids;
  final bool? isEdit;
  final bool? isRequired;
  final bool? isProfile;
  final int? itemId;
  // final List<RoleModel> Role;

  final Function(List<String>, List<int>, String, String,String,int) onSelected;
  const TaxesListField(
      {super.key,
      required this.fromProfile,
      required this.isCreate,
      this.isEdit,
      this.isRequired,
      this.itemId,
      this.name,
      this.ids,
      this.isProfile,
      // required this.Role,

      required this.onSelected});

  @override
  State<TaxesListField> createState() => _TaxesListFieldState();
}

class _TaxesListFieldState extends State<TaxesListField> {
  List<String> taxsname = [];
  List<int> taxsId = [];
  String searchWord = "";
  int? selectedtaxId;
  final TextEditingController _RoleMultiSearchController =
      TextEditingController();
  @override
  void initState() {
    context.read<TaxBloc>().add(const TaxesList());

    // taxsname.addAll(widget.name!);
    // taxsId.addAll(widget.ids!);
    if (taxsId.isNotEmpty) {
      selectedtaxId = taxsId.first; // This assumes single selection mode
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<TaxBloc, TaxesState>(
          builder: (context, state) {
            print("opgfmgxv $state");
            if (state is TaxesInitial) {
              return SizedBox();
            } else if (state is TaxesLoading) {
              return const Text("");
            } else if (state is TaxesPaginated) {
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
                                  text: AppLocalizations.of(context)!.tax,
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
                        // Fetch Rolees
                        widget.fromProfile == true
                            ? SizedBox.shrink()
                            : showDialog(
                                context: context,
                                builder: (ctx) =>
                                    BlocBuilder<TaxBloc, TaxesState>(
                                  builder: (context, state) {
                                    if (state is TaxesPaginated) {
                                      ScrollController scrollController =
                                          ScrollController();
                                      scrollController.addListener(() {
                                        if (scrollController.position.atEdge) {
                                          if (scrollController
                                                  .position.pixels !=
                                              0) {
                                            // We're at the bottom
                                            BlocProvider.of<TaxBloc>(context)
                                                .add(LoadMoreTaxes(searchWord));
                                          }
                                        }
                                      });

                                      return AlertDialog(
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
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .selecttax,
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
                                                            BorderRadius
                                                                .circular(10.0),
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
                                                          .read<TaxBloc>()
                                                          .add(SearchTaxes(
                                                              value,""));
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
                                        content: StatefulBuilder(builder:
                                            (BuildContext context,
                                                StateSetter setState) {
                                          return Container(
                                            constraints: BoxConstraints(
                                                maxHeight: 900.h),
                                            width: 200.w,

                                            margin: EdgeInsets.symmetric(
                                                horizontal: 20.w),

                                            // constraints:
                                            // BoxConstraints(maxHeight: 900.h),
                                            // width: 200.w,
                                            child: state.Taxes.isNotEmpty ?ListView.builder(
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount:
                                                    state.Taxes.length + 1,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  if (index <
                                                      state.Taxes.length) {
                                                    final taxId =
                                                        state.Taxes[index].id;

                                                    // Check if the current tax is selected
                                                    final isSelected =
                                                        taxId == selectedtaxId;

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
                                                          print("f;i dhf ${state.Taxes[index].amount!}");
                                                          setState(() {
                                                            // Update the selected ID
                                                            selectedtaxId =
                                                                state
                                                                    .Taxes[
                                                                        index]
                                                                    .id!;

                                                            if (widget
                                                                    .isCreate ==
                                                                true) {
                                                              // Clear previous selections (for single selection)
                                                              taxsname.clear();
                                                              taxsId.clear();

                                                              // Add the new selection
                                                              taxsname.add(state
                                                                  .Taxes[index]
                                                                  .title!);
                                                              taxsId.add(state
                                                                  .Taxes[index]
                                                                  .id!);

                                                              // Notify parent
                                                              widget.onSelected(
                                                                  [
                                                                    state
                                                                        .Taxes[
                                                                            index]
                                                                        .title!
                                                                  ],
                                                                  [
                                                                    state
                                                                        .Taxes[
                                                                            index]
                                                                        .id!
                                                                  ],
                                                                  state
                                                                      .Taxes[
                                                                          index]
                                                                      .amount!,
                                                                  state.Taxes[index].percentage?.toString() ?? '0'
                                                                  ,
                                                                  state
                                                                  .Taxes[
                                                              index].type!,widget.itemId!);
                                                              print("igdrg;di ${   state
                                                                  .Taxes[
                                                              index].type!}");
                                                            } else {
                                                              // Same for edit mode
                                                              taxsname.clear();
                                                              taxsId.clear();
                                                              taxsname.add(state
                                                                  .Taxes[index]
                                                                  .title!);
                                                              taxsId.add(state
                                                                  .Taxes[index]
                                                                  .id!);
                                                              widget.onSelected([state.Taxes[index].title!],
                                                                  [state.Taxes[index].id!],
                                                                  state.Taxes[index].amount!,
                                                                  (state.Taxes[index].percentage ?? "").toString(),

                                                                  state
                                                                  .Taxes[
                                                                  index].type!,widget.itemId!);
                                                            }
                                                          });

                                                          // Close the dialog after selection if you want
                                                          // Navigator.of(context).pop();
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
                                                                          .Taxes[
                                                                              index]
                                                                          .title!,
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
                                                }):NoData(),
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
                                      );
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
                        // padding: EdgeInsets.symmetric(horizontal: 10.w),
                        // height: 40.h,
                        // width: double.infinity,
                        // margin: EdgeInsets.symmetric(horizontal: 20),
                        // decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(12),
                        //     border: Border.all(color: colors.greyColor),
                        //      color: Theme.of(context).colorScheme.containerDark,
                        //     boxShadow: [
                        //       isLightTheme
                        //           ? MyThemes.lightThemeShadow
                        //           : MyThemes.darkThemeShadow,
                        //     ]),
                        // decoration: DesignConfiguration.shadow(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              widget.fromProfile == true
                                  ? CustomText(
                                      text: widget.isCreate
                                          ? (taxsname.isNotEmpty
                                              ? taxsname.join(", ")
                                              : AppLocalizations.of(context)!
                                                  .selecttax)
                                          : (widget.name!.isNotEmpty
                                              ? widget.name!.join(", ")
                                              : AppLocalizations.of(context)!
                                                  .selecttax),
                                      fontWeight: FontWeight.w500,
                                      size: 16.sp,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textClrChange,
                                    )
                                  : CustomText(
                                text: widget.isCreate
                                    ? (taxsname.isNotEmpty
                                    ? taxsname.join(", ")
                                    : AppLocalizations.of(context)!.selecttax)
                                    : (widget.name != null && widget.name!.isNotEmpty
                                    ? widget.name!.join(", ")
                                    : (taxsname.isNotEmpty
                                    ? taxsname.join(", ")
                                    : AppLocalizations.of(context)!.selecttax)),
                                fontWeight: FontWeight.w400,
                                size: 14.sp,
                                color: Theme.of(context).colorScheme.textClrChange,
                                maxLines: 1,
                              ),

                              (widget.fromProfile == true &&
                                      widget.isCreate == false)
                                  ? Container()
                                  : Icon(
                                      Icons.arrow_drop_down,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textClrChange,
                                    ),
                            ],
                          ),
                        ),
                        // child: CustomDropdown(options: titleName,)
                        // DropdownButton<String>(
                        //   taxs:  titleName.map((Role) {
                        //     return DropdownMenutax<String>(
                        //       value: Role,
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
                        //                   text: Role,
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
                        //           text: 'Role',
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
            } else if (state is TaxesError) {
              return Text("ERROR ${state.errorMessage}");
            }
            return Container();
          },
        )
      ],
    );
  }
}
