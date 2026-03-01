import 'package:flutter/material.dart';
import 'package:taskify/bloc/allowance_single/single_allowance_event.dart';
import 'package:taskify/config/colors.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import '../../../bloc/allowance_single/single_allowance_bloc.dart';
import '../../../bloc/allowance_single/single_allowance_state.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widgets/custom_cancel_create_button.dart';

class AllowanceField extends StatefulWidget {
  final bool isCreate;
  final String? name;
  final bool? from;
  final String? title;
  final bool? isRequired;
  final int? index;
  final bool? isEditLeaveReq;
  final List<int>? allowanceId;
  final Function(String, int,String) onSelected;
  const AllowanceField(
      {super.key,
        required this.isCreate,
        this.name,
        this.title,
        this.from,
        this.isRequired = false,
        this.allowanceId,
        this.isEditLeaveReq,
        required this.index,
        required this.onSelected});

  @override
  State<AllowanceField> createState() => _AllowanceFieldState();
}

class _AllowanceFieldState extends State<AllowanceField> {
  String? allowancesname;
  int? allowancesId;
  String? allowancesAmount;
  List<int> allowanceSelectedId = [];

  @override
  void initState() {

    if (!widget.isCreate && widget.index != null) {
      allowancesname = widget.name;
      if(widget.from == true) {
        allowancesId = widget.index;
        allowanceSelectedId.addAll(widget.allowanceId!);
      }
      // Fetch allowance list on init
      BlocProvider.of<SingleAllowanceBloc>(context).add(SingleAllowanceList());
    }
    super.initState();
  }

  // Only fetch allowance list when needed
  void _fetchAllowanceList() {
    BlocProvider.of<SingleAllowanceBloc>(context).add(SingleAllowanceList());
  }

  // void _showallowanceSelectionDialog() {
  //   // Make sure we have the latest allowance list before showing dialog
  //   _fetchallowanceList();
  //
  //   // Set fixed dimensions for the dialog - using these values outside the builder
  //   // ensures consistency before the dialog is fully built
  //   final double dialogHeight = 600.h;
  //
  //   showDialog(
  //       context: context,
  //       builder: (ctx) => LayoutBuilder(
  //           builder: (context, constraints) {
  //             final dialogWidth = MediaQuery.of(context).size.width * 0.9;
  //
  //             return  AlertDialog(
  //               shape: RoundedRectangleBorder(
  //                 borderRadius:
  //                 BorderRadius.circular(10.r),
  //               ),
  //               backgroundColor: Theme.of(context)
  //                   .colorScheme
  //                   .alertBoxBackGroundColor,
  //               contentPadding: EdgeInsets.zero,
  //               title: Container(
  //                 color:  Theme.of(context)
  //                     .colorScheme
  //                     .alertBoxBackGroundColor,
  //                 width: dialogWidth,
  //                 height: dialogHeight,
  //                 child: BlocBuilder<SingleAllowanceBloc, SingleAllowanceState>(
  //                   builder: (context, state) {
  //                     print("k gkndfm $state ");
  //
  //                     // Common header that's the same for all states
  //                     Widget header = Container(
  //
  //                       color:  Theme.of(context)
  //                           .colorScheme
  //                           .alertBoxBackGroundColor,
  //                       child: Column(
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: [
  //                           CustomText(
  //                             text: widget.title != null? widget.title!:AppLocalizations.of(context)!.allowances,
  //                             fontWeight: FontWeight.w800,
  //                             size: 20,
  //                             color: Theme.of(context).colorScheme.whitepurpleChange,
  //                           ),
  //                           const Divider(),
  //                         ],
  //                       ),
  //                     );
  //
  //                     // Common footer/buttons that's the same for all states
  //                     Widget footer = Padding(
  //                       padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
  //                       child: CreateCancelButtom(
  //                         title: "OK",
  //                         onpressCancel: () {
  //                           Navigator.pop(context);
  //                         },
  //                         onpressCreate: () {
  //                           // Only update the parent widget's state on dialog close
  //                           setState(() {
  //                             // Our local state is already updated, no need to update it again
  //                           });
  //
  //                           // Optionally dispatch bloc event after dialog closes
  //                           if (allowancesId != null) {
  //                             BlocProvider.of<SingleAllowanceBloc>(context).add(
  //                               SelectSingleAllowance(-1, allowancesname!),
  //                             );
  //                           }
  //
  //                           Navigator.pop(context);
  //                         },
  //                       ),
  //                     );
  //
  //                     // Container to hold the content with fixed layout
  //                     return Container(
  //                       color:  Theme.of(context)
  //                           .colorScheme
  //                           .alertBoxBackGroundColor,
  //                       child: Column(
  //                         mainAxisSize: MainAxisSize.max,
  //                         children: [
  //                           header,
  //                           Expanded(
  //                             child: state is SingleAllowanceSuccess
  //                                 ? _buildallowanceList(context, state)
  //                                 : const Center(child: CircularProgressIndicator()),
  //                           ),
  //                           footer,
  //                         ],
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               ),
  //             );
  //           })
  //   );
  // }
  void _showallowanceSelectionDialog() {
    // Fetch the latest allowance list before showing dialog
    _fetchAllowanceList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,
            contentPadding: EdgeInsets.zero,
            title: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  children: [
                    CustomText(
                      text: widget.title != null
                          ? widget.title!
                          : AppLocalizations.of(context)!.allowances,
                      fontWeight: FontWeight.w800,
                      size: 20,
                      color: Theme.of(context).colorScheme.whitepurpleChange,
                    ),
                    const Divider(),
                    // Search Field
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.w),
                      child: SizedBox(
                        height: 35.h,
                        width: double.infinity,
                        child: TextField(
                          cursorColor: AppColors.greyForgetColor,
                          cursorWidth: 1,
                          // controller: _allowanceSearchController, // Add this controller
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: (35.h - 20.sp) / 2,
                              horizontal: 10.w,
                            ),
                            hintText: AppLocalizations.of(context)!.search,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.greyForgetColor,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: AppColors.purple,
                                width: 1.0,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              // allowanceSearchWord = value; // Add this variable
                            });
                            // Add search functionality for allowances
                            // context.read<SingleAllowanceBloc>().add(SearchAllowances(value));
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                  ],
                ),
              ),
            ),
            content: Container(
              constraints: BoxConstraints(maxHeight: 900.h),
              width: MediaQuery.of(context).size.width,
              child: BlocBuilder<SingleAllowanceBloc, SingleAllowanceState>(
                builder: (context, state) {
                  if (state is SingleAllowanceSuccess) {
                    return _buildAllowanceList(context, state, setState);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: CreateCancelButtom(
                  title: "OK",
                  onpressCancel: () {
                    Navigator.pop(context);
                  },
                  onpressCreate: () {
                    // Optionally dispatch bloc event after dialog closes
                    if (allowancesId != null) {
                      BlocProvider.of<SingleAllowanceBloc>(context).add(
                        SelectSingleAllowance(-1, allowancesname!),
                      );
                    }
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

// Extracted allowance list building to a separate method for clarity
  Widget _buildAllowanceList(BuildContext context, SingleAllowanceSuccess state,StateSetter) {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0 && state.isLoadingMore) {
          // We're at the bottom
          BlocProvider.of<SingleAllowanceBloc>(context)
              .add(SingleAllowanceLoadMore());
        }
      }
    });

    return StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) setDialogState) {
          return state.Allowance.isEmpty?NoData(isImage: true,): ListView.builder(
            controller: scrollController,
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: state.isLoadingMore
                ? state.Allowance.length
                : state.Allowance.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index < state.Allowance.length) {
                final isSelected = allowanceSelectedId.contains(state.Allowance[index].id!);

                return InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    // Update dialog state first (without triggering bloc)
                    setDialogState(() {
                      allowanceSelectedId.clear();
                      allowancesname = state.Allowance[index].title!;
                      allowancesId = state.Allowance[index].id!;
                      allowancesAmount = state.Allowance[index].amount!;
                      allowanceSelectedId.add(allowancesId!);
                    });

                    // Notify parent about selection
                    widget.onSelected(allowancesname!, allowancesId!,allowancesAmount!);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 4.h),
                    child: Container(
                      decoration: BoxDecoration(
                          color: isSelected ? AppColors.purpleShade : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: isSelected ? AppColors.purple : Colors.transparent
                          )
                      ),
                      width: double.infinity,
                      height: 38.h,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 7,
                                child: SizedBox(
                                  width: 200.w,
                                  child: Row(
                                    children: [

                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: CustomText(
                                                      text: state.Allowance[index].title!,
                                                      fontWeight: FontWeight.w500,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      size: 18.sp,
                                                      color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                    ),
                                                  ),
                                                  SizedBox(width: 5.w),

                                                ],
                                              ),

                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              isSelected
                                  ? Expanded(
                                flex: 1,
                                child: const HeroIcon(
                                    HeroIcons.checkCircle,
                                    style: HeroIconStyle.solid,
                                    color: AppColors.purple
                                ),
                              )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return state.isLoadingMore
                    ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: const Center(child: CircularProgressIndicator()),
                )
                    : const SizedBox.shrink();
              }
            },
          );
        }
    );
  }

// This class prevents the dialog from resizing during animations


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
                text:( widget.title != null && widget.title!="") ? widget.title! :AppLocalizations.of(context)!.allowances,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16.sp,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w700,
              ),
              widget.isRequired == true ? const CustomText(
                text: " *",
                color: AppColors.red,
                size: 15,
                fontWeight: FontWeight.w400,
              ) : SizedBox(),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        BlocBuilder<SingleAllowanceBloc, SingleAllowanceState>(
          builder: (context, state) {
            return AbsorbPointer(
              absorbing: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      if (widget.from == true || widget.isCreate) {
                        _showallowanceSelectionDialog();
                      }
                    },
                    child: widget.from == true
                        ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      height: 40.h,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.greyColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: widget.isCreate
                                ? (allowancesname?.isEmpty ?? true
                                ? AppLocalizations.of(context)!.selectallownances
                                : allowancesname!)
                                : (allowancesname!=""
                                ? widget.name??AppLocalizations.of(context)!.selectallownances
                                : allowancesname!),
                            fontWeight: FontWeight.w400,
                            size: 14.sp,
                            color: Theme.of(context).colorScheme.textClrChange,
                          ),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    )
                        : Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      height: 40.h,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: widget.isCreate == true ? Colors.transparent : Theme.of(context).colorScheme.textfieldDisabled,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.greyColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: widget.isCreate
                                ? (allowancesname?.isEmpty ?? true
                                ? AppLocalizations.of(context)!.allowances
                                : allowancesname!)
                                : (allowancesname?.isEmpty ?? true
                                ? widget.name!
                                : allowancesname!),
                            fontWeight: FontWeight.w400,
                            size: 14.sp,
                            color: Theme.of(context).colorScheme.textClrChange,
                          ),
                          widget.isCreate == false ? SizedBox() : Icon(Icons.arrow_drop_down),
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