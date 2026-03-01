import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';
import 'package:heroicons/heroicons.dart';
import '../../../bloc/deduction_single/single_deduction_bloc.dart';
import '../../../bloc/deduction_single/single_deduction_event.dart';
import '../../../bloc/deduction_single/single_deduction_state.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widgets/custom_cancel_create_button.dart';

class DeductionField extends StatefulWidget {
  final bool isCreate;
  final String? name;
  final bool? from;
  final String? title;
  final bool? isRequired;
  final int? index;
  final bool? isEditLeaveReq;
  final List<int>? deductionId;
  final Function(String, int,String) onSelected;
  const DeductionField(
      {super.key,
        required this.isCreate,
        this.name,
        this.title,
        this.from,
        this.isRequired = false,
        this.deductionId,
        this.isEditLeaveReq,
        required this.index,
        required this.onSelected});

  @override
  State<DeductionField> createState() => _DeductionFieldState();
}

class _DeductionFieldState extends State<DeductionField> {
  String? Deductionsname;
  int? DeductionsId;
  String? DeductionsAmout;
  List<int> DeductionSelectedId = [];

  @override
  void initState() {

    if (!widget.isCreate && widget.index != null) {
      Deductionsname = widget.name;
      if(widget.from == true) {
        DeductionsId = widget.index;
        DeductionSelectedId.addAll(widget.deductionId!);
      }
      // Fetch Deduction list on init
      BlocProvider.of<SingleDeductionBloc>(context).add(SingleDeductionList());
    }
    super.initState();
  }

  // Only fetch Deduction list when needed
  void _fetchDeductionList() {
    BlocProvider.of<SingleDeductionBloc>(context).add(SingleDeductionList());
  }

  void _showDeductionSelectionDialog() {
    // Make sure we have the latest Deduction list before showing dialog
    _fetchDeductionList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            backgroundColor: Theme.of(context)
                .colorScheme
                .alertBoxBackGroundColor,
            contentPadding: EdgeInsets.zero,
            title: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  children: [
                    CustomText(
                      text: widget.title != null
                          ? widget.title!
                          : AppLocalizations.of(context)!.deductions,
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
                          // controller: _deductionSearchController, // You'll need to add this controller
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
                              // deductionSearchWord = value; // You'll need to add this variable
                            });
                            // Add search functionality for deductions
                            // context.read<SingleDeductionBloc>().add(SearchDeductions(value));
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
              child: BlocBuilder<SingleDeductionBloc, SingleDeductionState>(
                builder: (context, state) {
                  if (state is SingleDeductionSuccess) {
                    return _buildDeductionList(context, state, setState);
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
                    // Only update the parent widget's state on dialog close
                    setState(() {
                      // Our local state is already updated, no need to update it again
                    });

                    // Optionally dispatch bloc event after dialog closes
                    if (DeductionsId != null) {
                      BlocProvider.of<SingleDeductionBloc>(context).add(
                        SelectSingleDeduction(-1, Deductionsname!),
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

// Extracted Deduction list building to a separate method for clarity
  Widget _buildDeductionList(BuildContext context, SingleDeductionSuccess state,StateSetter) {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0 && state.isLoadingMore) {
          // We're at the bottom
          BlocProvider.of<SingleDeductionBloc>(context)
              .add(SingleDeductionLoadMore());
        }
      }
    });

    return StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) setDialogState) {
          return ListView.builder(
            controller: scrollController,
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: state.isLoadingMore
                ? state.Deduction.length
                : state.Deduction.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index < state.Deduction.length) {
                final isSelected = DeductionSelectedId.contains(state.Deduction[index].id!);

                return InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    // Update dialog state first (without triggering bloc)
                    setDialogState(() {
                      DeductionSelectedId.clear();
                      Deductionsname = state.Deduction[index].title!;
                      DeductionsId = state.Deduction[index].id!;
                      DeductionsAmout = state.Deduction[index].amount!;
                      DeductionSelectedId.add(DeductionsId!);
                    });

                    // Notify parent about selection
                    widget.onSelected(Deductionsname!, DeductionsId!,DeductionsAmout!);
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
                                                      text: state.Deduction[index].title!,
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
                text:( widget.title != null && widget.title!="") ? widget.title! :AppLocalizations.of(context)!.deductions,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
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
        BlocBuilder<SingleDeductionBloc, SingleDeductionState>(
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
                        _showDeductionSelectionDialog();
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
                                ? (Deductionsname?.isEmpty ?? true
                                ? AppLocalizations.of(context)!.selectdeduction
                                : Deductionsname!)
                                : (Deductionsname?.isEmpty ?? true
                                ? widget.name??AppLocalizations.of(context)!.selectdeduction
                                : Deductionsname!),
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
                                ? (Deductionsname?.isEmpty ?? true
                                ? AppLocalizations.of(context)!.deductions
                                : Deductionsname!)
                                : (Deductionsname?.isEmpty ?? true
                                ? widget.name!
                                : Deductionsname!),
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