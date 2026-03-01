import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import '../../../../bloc/theme/theme_bloc.dart';
import '../../../../bloc/theme/theme_state.dart';
import '../../../../utils/widgets/custom_text.dart';
import '../../../../utils/widgets/my_theme.dart';
import '../../../bloc/candidate_status/candidates_status_bloc.dart';
import '../../../bloc/candidate_status/candidates_status_event.dart';
import '../../../bloc/candidate_status/candidates_status_state.dart';
import '../../../data/model/candidate_status/candidate_status_model.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../widgets/custom_cancel_create_button.dart';

class SingleCandidateStatusField extends StatefulWidget {
  final bool isCreate;
  final bool isRequired;
  final String? username; // Changed from List to single String
  final int? candidatesStatusId; // Changed from List to single int
  final List<CandidateStatusModel> status;
  final Function(String?, int?) onSelected; // Modified callback function

  const SingleCandidateStatusField({
    super.key,
    this.isRequired = false,
    required this.isCreate,
    this.username, // Optional now
    required this.status,
    this.candidatesStatusId, // Optional now
    required this.onSelected,
  });

  @override
  State<SingleCandidateStatusField> createState() => _SingleCandidateStatusFieldState();
}

class _SingleCandidateStatusFieldState extends State<SingleCandidateStatusField> {
  String? selectedCandidatesStatusName;
  int? selectedCandidatesStatusId;
  String searchWord = "";

  final TextEditingController _CandidatesStatusSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with provided CandidatesStatus if any
    if (widget.isCreate == false) {
      selectedCandidatesStatusId = widget.candidatesStatusId;
      selectedCandidatesStatusName = widget.username;
    }
    BlocProvider.of<CandidatesStatusBloc>(context).add(CandidatesStatusList());
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
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.status,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
              widget.isRequired == true
                  ? const CustomText(
                text: " *",
                color: AppColors.red,
                size: 15,
                fontWeight: FontWeight.w400,
              )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
        BlocBuilder<CandidatesStatusBloc, CandidatesStatusState>(
          builder: (context, state) {
            if (state is CandidatesStatusInitial) {
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),
                    InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        height: 40.h,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.greyColor),
                          color: Theme.of(context).colorScheme.containerDark,
                          boxShadow: [
                            isLightTheme
                                ? MyThemes.lightThemeShadow
                                : MyThemes.darkThemeShadow,
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CustomText(
                                text: widget.isCreate
                                    ? (selectedCandidatesStatusName ??
                                    AppLocalizations.of(context)!
                                        .status)
                                    : (widget.username ??
                                    AppLocalizations.of(context)!
                                        .status),
                                fontWeight: FontWeight.w400,
                                size: 12,
                                color: AppColors.greyForgetColor,
                                maxLines: 1,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is CandidatesStatusPaginated || state is CandidatesStatusError) {
              // Handler for both successful load and error states
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) =>
                              BlocBuilder<CandidatesStatusBloc, CandidatesStatusState>(
                                builder: (context, state) {
                                  if (state is CandidatesStatusPaginated) {
                                    ScrollController scrollController =
                                    ScrollController();
                                    scrollController.addListener(() {
                                      if (scrollController.position.atEdge) {
                                        if (scrollController.position.pixels != 0) {
                                          BlocProvider.of<CandidatesStatusBloc>(context)
                                              .add(LoadMoreCandidatesStatus(searchWord));
                                        }
                                      }
                                    });

                                    return StatefulBuilder(
                                      builder: (BuildContext context,
                                          void Function(void Function()) setState) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(10.r),
                                          ),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .alertBoxBackGroundColor,
                                          contentPadding: EdgeInsets.zero,
                                          title: Center(
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                                  0.9,
                                              child: Column(
                                                children: [
                                                  CustomText(
                                                    text: AppLocalizations.of(
                                                        context)!
                                                        .status,
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
                                                      height: 35.h,
                                                      width: double.infinity,
                                                      child: TextField(
                                                        cursorColor: AppColors
                                                            .greyForgetColor,
                                                        cursorWidth: 1,
                                                        controller:
                                                        _CandidatesStatusSearchController,
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
                                                                  .greyForgetColor,
                                                              width: 1.0,
                                                            ),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                          ),
                                                          focusedBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                            borderSide: BorderSide(
                                                              color:
                                                              AppColors.purple,
                                                              width: 1.0,
                                                            ),
                                                          ),
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            searchWord = value;
                                                          });
                                                          context
                                                              .read<CandidatesStatusBloc>()
                                                              .add(SearchCandidatesStatus(
                                                              value));
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
                                            constraints:
                                            BoxConstraints(maxHeight: 900.h),
                                            width:
                                            MediaQuery.of(context).size.width,
                                            child: state.CandidatesStatus.isNotEmpty ?
                                            ListView.builder(
                                              controller: scrollController,
                                              shrinkWrap: true,
                                              itemCount: state.CandidatesStatus.length,
                                              itemBuilder: (BuildContext context,
                                                  int index) {
                                                final isSelected =
                                                    selectedCandidatesStatusId ==
                                                        state.CandidatesStatus[index].id;

                                                return Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20.h),
                                                  child: InkWell(
                                                    splashColor: Colors.transparent,
                                                    onTap: () {
                                                      setState(() {
                                                        // Single selection logic
                                                        selectedCandidatesStatusId =
                                                            state.CandidatesStatus[index].id;
                                                        selectedCandidatesStatusName = state
                                                            .CandidatesStatus[index]
                                                            .name;

                                                        // Update parent through callback
                                                        widget.onSelected(
                                                            selectedCandidatesStatusName,
                                                            selectedCandidatesStatusId);
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding: EdgeInsets.symmetric(
                                                          vertical: 2.h),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: isSelected
                                                              ? AppColors
                                                              .purpleShade
                                                              : Colors.transparent,
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                          border: Border.all(
                                                              color: isSelected
                                                                  ? AppColors.purple
                                                                  : Colors
                                                                  .transparent),
                                                        ),
                                                        width: double.infinity,
                                                        child: Center(
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                10.w,vertical: 10.h),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  flex: 4,
                                                                  child: SizedBox(
                                                                    width: 200.w,
                                                                    child:  CustomText(
                                                                      text: state.CandidatesStatus[index].name!,
                                                                      fontWeight: FontWeight.w500,
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                      size: 18.sp,
                                                                      color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                                    ),
                                                                  ),
                                                                ),
                                                                isSelected
                                                                    ? Expanded(
                                                                  flex: 1,
                                                                  child: const HeroIcon(
                                                                      HeroIcons
                                                                          .checkCircle,
                                                                      style: HeroIconStyle
                                                                          .solid,
                                                                      color: AppColors
                                                                          .purple),
                                                                )
                                                                    : const SizedBox
                                                                    .shrink(),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ):NoData(isImage: true,),
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
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                  return Container();
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SizedBox(
                                child: CustomText(
                                  text: widget.isCreate
                                      ? (selectedCandidatesStatusName ??
                                      AppLocalizations.of(context)!
                                          .status)
                                      : (widget.username ??
                                      AppLocalizations.of(context)!
                                          .status),
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
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return AbsorbPointer(
              absorbing: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5.h),
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      height: 40.h,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.greyColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SizedBox(
                              child: CustomText(
                                text:
                                AppLocalizations.of(context)!.selectcandidatestatus,
                                fontWeight: FontWeight.w500,
                                size: 14.sp,
                                color:
                                Theme.of(context).colorScheme.textClrChange,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
