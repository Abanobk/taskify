import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import '../../../bloc/single_user/single_user_bloc.dart';
import '../../../bloc/single_user/single_user_event.dart';
import '../../../bloc/single_user/single_user_state.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widgets/custom_cancel_create_button.dart';

class InterviewerListField extends StatefulWidget {
  final bool isCreate;
  final String? name;
  final bool? from;
  final bool? isRequired;
  final int? index;
  final bool? isEditLeaveReq;
  final List<int>? inteviewerId;
  final Function(String, int) onSelected;
  const InterviewerListField(
      {super.key,
        required this.isCreate,
        this.name,
        this.from,
        this.isRequired = false,
        this.inteviewerId,
        this.isEditLeaveReq,
        required this.index,
        required this.onSelected});

  @override
  State<InterviewerListField> createState() => _InterviewerListFieldState();
}

class _InterviewerListFieldState extends State<InterviewerListField> {
  String? usersname;
  int? usersId;
  List<int> userSelectedId = [];

  @override
  void initState() {
    if (!widget.isCreate && widget.index != null) {
      usersname = widget.name;
      if(widget.from == true) {
        usersId = widget.index;
        userSelectedId.addAll(widget.inteviewerId!);
      }
      // Fetch user list on init
      BlocProvider.of<SingleUserBloc>(context).add(SingleUserList());
    }
    super.initState();
  }

  // Only fetch user list when needed
  void _fetchUserList() {
    BlocProvider.of<SingleUserBloc>(context).add(SingleUserList());
  }

  void _showUserSelectionDialog() {
    // Make sure we have the latest user list before showing dialog
    _fetchUserList();

    // Set fixed dimensions for the dialog - using these values outside the builder
    // ensures consistency before the dialog is fully built
    final double dialogHeight = 350.h;

    showDialog(
        context: context,
        builder: (ctx) => LayoutBuilder(
            builder: (context, constraints) {
              final dialogWidth = MediaQuery.of(context).size.width * 0.9;

              return  AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(10.r),
                ),
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .alertBoxBackGroundColor,
                contentPadding: EdgeInsets.zero,
                title: Container(
                  color:  Theme.of(context)
                      .colorScheme
                      .alertBoxBackGroundColor,
                  width: dialogWidth,
                  height: dialogHeight,
                  child: BlocBuilder<SingleUserBloc, SingleUserState>(
                    builder: (context, state) {
                      print("k gkndfm $state ");

                      // Common header that's the same for all states
                      Widget header = Container(

                        color:  Theme.of(context)
                            .colorScheme
                            .alertBoxBackGroundColor,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomText(
                              text: AppLocalizations.of(context)!.selectuser,
                              fontWeight: FontWeight.w800,
                              size: 20,
                              color: Theme.of(context).colorScheme.whitepurpleChange,
                            ),
                            const Divider(),
                          ],
                        ),
                      );

                      // Common footer/buttons that's the same for all states
                      Widget footer = Padding(
                        padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
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
                            if (usersId != null) {
                              BlocProvider.of<SingleUserBloc>(context).add(
                                SelectSingleUser(-1, usersname!),
                              );
                            }

                            Navigator.pop(context);
                          },
                        ),
                      );

                      // Container to hold the content with fixed layout
                      return Container(
                        color:  Theme.of(context)
                            .colorScheme
                            .alertBoxBackGroundColor,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            header,
                            Expanded(
                              child: state is SingleUserSuccess
                                  ? _buildUserList(context, state)
                                  : const Center(child: CircularProgressIndicator()),
                            ),
                            footer,
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            })
    );
  }

// Extracted user list building to a separate method for clarity
  Widget _buildUserList(BuildContext context, SingleUserSuccess state) {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0 && state.isLoadingMore) {
          // We're at the bottom
          BlocProvider.of<SingleUserBloc>(context)
              .add(SingleUserLoadMore());
        }
      }
    });

    return StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) setDialogState) {
          return state.user.isEmpty?NoData(isImage: true,):ListView.builder(
            controller: scrollController,
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: state.isLoadingMore
                ? state.user.length
                : state.user.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index < state.user.length) {
                final isSelected = userSelectedId.contains(state.user[index].id!);

                return InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    // Update dialog state first (without triggering bloc)
                    setDialogState(() {
                      userSelectedId.clear();
                      usersname = state.user[index].firstName!;
                      usersId = state.user[index].id!;
                      userSelectedId.add(usersId!);
                    });

                    // Notify parent about selection
                    widget.onSelected(usersname!, usersId!);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 4.h),
                    child: Container(
                      decoration: BoxDecoration(
                          color: isSelected ? AppColors.purpleShade : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: isSelected ? AppColors.purple : Colors.transparent
                          )
                      ),
                      width: double.infinity,
                      height: 58.h,
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
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(state.user[index].profile!),
                                      ),
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
                                                      text: state.user[index].firstName!,
                                                      fontWeight: FontWeight.w500,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      size: 18.sp,
                                                      color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                    ),
                                                  ),
                                                  SizedBox(width: 5.w),
                                                  Flexible(
                                                    child: CustomText(
                                                      text: state.user[index].lastName!,
                                                      fontWeight: FontWeight.w500,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      size: 18.sp,
                                                      color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: CustomText(
                                                      text: state.user[index].email!,
                                                      fontWeight: FontWeight.w500,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      size: 14.sp,
                                                      color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                    ),
                                                  ),
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
                text: AppLocalizations.of(context)!.interviewer,
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
        BlocBuilder<SingleUserBloc, SingleUserState>(
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

                        _showUserSelectionDialog();

                    },
                    child:  Container(
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
                                ? (usersname?.isEmpty ?? true
                                ? AppLocalizations.of(context)!.selectuser
                                : usersname!)
                                : (usersname?.isEmpty ?? true
                                ? widget.name!
                                : usersname!),
                            fontWeight: FontWeight.w400,
                            size: 14.sp,
                            color: Theme.of(context).colorScheme.textClrChange,
                          ),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    )

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