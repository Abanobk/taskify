import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../bloc/expense/expense_bloc.dart';
import '../../../bloc/expense/expense_event.dart';
import '../../../bloc/expense_filter/expense_filter_bloc.dart';
import '../../../bloc/expense_filter/expense_filter_event.dart';
import '../../../bloc/expense_type/expense_type_bloc.dart';
import '../../../bloc/expense_type/expense_type_event.dart';
import '../../../bloc/expense_type/expense_type_state.dart';
import '../../../bloc/user/user_bloc.dart';
import '../../../bloc/user/user_event.dart';
import '../../../bloc/user/user_state.dart';
import '../../../config/constants.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/no_data.dart';
import '../../widgets/custom_date.dart';
import '../../../../src/generated/i18n/app_localizations.dart';


class FilterDialog extends StatefulWidget {
  final bool isLightTheme;
  final List<String> filter;
  final ExpenseBloc expenseBloc;

  const FilterDialog({
    Key? key,
    required this.isLightTheme,
    required this.filter,
    required this.expenseBloc,
  }) : super(key: key);

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  TextEditingController _userSearchController = TextEditingController();
  TextEditingController _typeSearchController = TextEditingController();
  String searchWord = "";
  String typesearchWord = "";
  List<int> userSelectedIdS = [];
  List<String> userSelectedname = [];
  bool? userDisSelected = false;
  bool? userSelected = false;
  List<int> typeSelectedIdS = [];
  List<String> typeSelectedname = [];
  bool? typeDisSelected = false;
  bool? typeSelected = false;
  int filterSelectedId = 0;
  String filterSelectedName = "";
  List<String> estinateInvoicesname = [];
  DateTime selectedDateStarts = DateTime.now();
  DateTime? selectedDateEnds = DateTime.now();
  TextEditingController startsController = TextEditingController();
  TextEditingController endController = TextEditingController();

  String? fromDate;
  String? toDate;
  List<String> type = ["Estimate", "Invoice"];

  final ValueNotifier<String> filterNameNotifier =
      ValueNotifier<String>('users'); // Initialize with default value

  String filterName = 'users';

  void _onFilterSelected(String selectedFilter) {
    setState(() {
      filterName = selectedFilter; // Update the filterName and rebuild UI
    });
  }
  @override
  void initState() {
    super.initState();

    final filterBlocState = context.read<ExpenseFilterCountBloc>().state;

    // Access selected user IDs from the state
    userSelectedIdS = List<int>.from(filterBlocState.selectedUserIds);

    // Access and set dates from state
    if (filterBlocState.fromDate.isNotEmpty) {
      fromDate = filterBlocState.fromDate;
      toDate = filterBlocState.toDate;

      try {
        selectedDateStarts = DateTime.parse(fromDate!);
        startsController.text = DateFormat('MMMM dd, yyyy').format(selectedDateStarts);

        if (toDate!="") {
          selectedDateEnds = DateTime.parse(toDate!);
          endController.text = DateFormat('MMMM dd, yyyy').format(selectedDateEnds!);
        }
      } catch (e) {
        print('Date parsing failed: $e');
      }
    }
  }


  Widget _getFilteredWidget(filterName, isLightTheme) {
    switch (filterName.toLowerCase()) {
      // Show ClientList if filterName is "client"
      case 'users':
        return userLists(); // Show UserList if filterName is "user"
      case 'type':
        return typeLists();
      case 'date':
        return dateList(isLightTheme); // Show TagsList if filterName is "tags"
      default:
        return userLists(); // Default view
    }
  }

  @override
  void dispose() {
    filterNameNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("hkdsgjkh ${  userSelectedIdS}");
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 10),
          CustomText(
            text: AppLocalizations.of(context)!.selectfilter,
            color: AppColors.primary,
            size: 30.sp,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 600.h,
                  child: ListView.builder(
                    itemCount: widget.filter.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            filterNameNotifier.value = widget.filter[index];
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          child: Container(
                            height: 50.h,
                            decoration: BoxDecoration(
                              boxShadow: [
                                widget.isLightTheme
                                    ? MyThemesFilter.lightThemeShadow
                                    : MyThemesFilter.darkThemeShadow,
                              ],
                              color:
                                  Theme.of(context).colorScheme.containerDark,
                            ),
                            child: Row(
                              children: [
                                ValueListenableBuilder<String>(
                                  valueListenable: filterNameNotifier,
                                  builder: (context, filterName, _) {
                                    return filterName == widget.filter[index]
                                        ? Expanded(
                                            flex: 1,
                                            child: Container(
                                              width: 2,
                                              color: AppColors.primary,
                                            ),
                                          )
                                        : SizedBox.shrink();
                                  },
                                ),
                                Expanded(
                                  flex: 35,
                                  child: Center(
                                    child: Text(
                                      widget.filter[index],
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textClrChange,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: ValueListenableBuilder<String>(
                  valueListenable: filterNameNotifier,
                  builder: (context, filterName, _) {
                    return _getFilteredWidget(filterName, widget.isLightTheme);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    if (userSelectedIdS.isNotEmpty) {
                      context.read<ExpenseFilterCountBloc>().add(
                            ExpenseUpdateFilterCount(
                                filterType: 'users', isSelected: true),
                          );
                    }
                    if (typeSelectedIdS.isNotEmpty) {
                      context.read<ExpenseFilterCountBloc>().add(
                            ExpenseUpdateFilterCount(
                                filterType: 'type', isSelected: true),
                          );
                    }
                    if (fromDate != null || toDate != null) {
                      context.read<ExpenseFilterCountBloc>().add(
                            ExpenseUpdateFilterCount(
                                filterType: 'date', isSelected: true),
                          );
                    }


                    print("riojfkjjr");

                    final filterState = context.read<ExpenseFilterCountBloc>().state;

                    widget.expenseBloc.add(
                      ExpenseLists(
                        filterState.selectedTypeIds,
                        filterState.selectedUserIds,
                        filterState.fromDate,
                        filterState.toDate,
                      ),
                    );
                    // Clear search controllers
                    _typeSearchController.clear();

                    _userSearchController.clear();

                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: 35.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15.w, vertical: 0.h),
                      child: Center(
                        child: CustomText(
                          text: AppLocalizations.of(context)!.apply,
                          size: 12.sp,
                          color: AppColors.pureWhiteColor,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 30.w),
                InkWell(
                  onTap: () {
                    setState(() {
                      context
                          .read<ExpenseFilterCountBloc>()
                          .add(ExpenseResetFilterCount());

                      // filterNameNotifier.value = 'users';
                      widget.expenseBloc.add(ExpenseLists([],
                          [],
                          "",""));


                      Navigator.of(context).pop();
                    });
                  },
                  child: Container(
                    height: 35.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child: Center(
                        child: CustomText(
                          text: AppLocalizations.of(context)!.clear,
                          size: 12.sp,
                          color: AppColors.pureWhiteColor,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget userLists() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 35.h,
            child: TextField(
              cursorColor: AppColors.greyForgetColor,
              cursorWidth: 1,
              controller: _userSearchController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: (35.h - 20.sp) / 2,
                  horizontal: 10.w,
                ),
                hintText: 'Search...',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors
                        .greyForgetColor, // Set your desired color here
                    width: 1.0, // Set the border width if needed
                  ),
                  borderRadius: BorderRadius.circular(
                      20.0), // Optional: adjust the border radius
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
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
                context.read<UserBloc>().add(SearchUsers(value));
              },
            ),
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        BlocBuilder<UserBloc, UserState>(builder: (context, state) {
          if (state is UserLoading || state is UserInitial) {
            return SpinKitFadingCircle(
              size: 40,
              color: AppColors.primary,
            );
          }
          if (state is UserPaginated) {
            ScrollController scrollController = ScrollController();
            scrollController.addListener(() {
              if (scrollController.position.atEdge) {
                if (scrollController.position.pixels != 0 &&
                    !state.hasReachedMax) {
                  // We're at the bottom
                  BlocProvider.of<UserBloc>(context)
                      .add(UserLoadMore(searchWord));
                }
              }
            });

            return StatefulBuilder(builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Container(
                constraints: BoxConstraints(maxHeight: 900.h),
                width: 200.w,
                height: 530,
                child: state.user.isNotEmpty
                    ? ListView.builder(
                        controller: scrollController,
                        shrinkWrap: true,
                        itemCount: state.user.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          final userSelectedIdS = context.watch<ExpenseFilterCountBloc>().state.selectedUserIds;
                          if (index < state.user.length) {
                            final isSelected =
                                userSelectedIdS.contains(state.user[index].id!);
                            // final isSelected = widget.userId?.contains(state.user[index].id);

                            return InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    userDisSelected = true;
                                    userSelectedIdS
                                        .remove(state.user[index].id!);
                                    userSelectedname
                                        .remove(state.user[index].firstName!);
                                    userSelected = false;
                                    print("ghjk isSelected ${userSelectedIdS}");
                                    context.read<ExpenseFilterCountBloc>().add(
                                        SetUserIds(userIds: userSelectedIdS));

                                    // If no users are selected anymore, update filter count
                                    if (userSelectedIdS.isEmpty) {
                                      context
                                          .read<ExpenseFilterCountBloc>()
                                          .add(
                                            ExpenseUpdateFilterCount(
                                              filterType: 'users',
                                              isSelected: false,
                                            ),
                                          );
                                    }
                                  } else {
                                    userDisSelected = false;
                                    if (!userSelectedIdS
                                        .contains(state.user[index].id!)) {
                                      userSelectedIdS
                                          .add(state.user[index].id!);
                                      userSelectedname
                                          .add(state.user[index].firstName!);

                                      // Update filter count when first user is selected
                                      if (userSelectedIdS.length == 1) {
                                        context
                                            .read<ExpenseFilterCountBloc>()
                                            .add(
                                              ExpenseUpdateFilterCount(
                                                filterType: 'users',
                                                isSelected: true,
                                              ),
                                            );
                                      }
                                      print("ghjk isNotSelected ${userSelectedIdS}");
                                      context.read<ExpenseFilterCountBloc>().add(
                                          SetUserIds(userIds: userSelectedIdS));
                                    }

                                    filterSelectedId = state.user[index].id!;
                                    filterSelectedName = "users";
                                  }

                                  _onFilterSelected('users');
                                });

                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.purpleShade
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.transparent)),
                                  width: double.infinity,
                                  height: 55.h,
                                  child: Center(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 0.w),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Column takes up maximum available space
                                            Expanded(
                                              child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 0.w),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 20,
                                                        backgroundImage:
                                                            NetworkImage(state
                                                                .user[index]
                                                                .profile!),
                                                      ),
                                                      SizedBox(
                                                        width: 5.w,
                                                      ), // Column takes up maximum available space
                                                      Expanded(
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      0.w),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Flexible(
                                                                    child:
                                                                        CustomText(
                                                                      text: state
                                                                          .user[
                                                                              index]
                                                                          .firstName!,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      size:
                                                                          18.sp,
                                                                      color: isSelected
                                                                          ? AppColors
                                                                              .primary
                                                                          : Theme.of(context)
                                                                              .colorScheme
                                                                              .textClrChange,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          5.w),
                                                                  Flexible(
                                                                    child:
                                                                        CustomText(
                                                                      text: state
                                                                          .user[
                                                                              index]
                                                                          .lastName!,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      size:
                                                                          18.sp,
                                                                      color: isSelected
                                                                          ? AppColors
                                                                              .primary
                                                                          : Theme.of(context)
                                                                              .colorScheme
                                                                              .textClrChange,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Flexible(
                                                                    child:
                                                                        CustomText(
                                                                      text: state
                                                                          .user[
                                                                              index]
                                                                          .email!,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      size:
                                                                          14.sp,
                                                                      color: isSelected
                                                                          ? AppColors
                                                                              .primary
                                                                          : Theme.of(context)
                                                                              .colorScheme
                                                                              .textClrChange,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      // Spacer to push the icon to the far right
                                                      // if (isSelected) ...[
                                                      //   SizedBox(
                                                      //       width: 8
                                                      //           .w), // Optional spacing between text and icon
                                                      //   HeroIcon(
                                                      //     HeroIcons.checkCircle,
                                                      //     style: HeroIconStyle.solid,
                                                      //     color: AppColors.purple,
                                                      //   ),
                                                      // ]
                                                    ],
                                                  )),
                                            ),
                                            // Spacer to push the icon to the far right
                                            if (isSelected) ...[
                                              SizedBox(
                                                  width: 8
                                                      .w), // Optional spacing between text and icon
                                              HeroIcon(
                                                HeroIcons.checkCircle,
                                                style: HeroIconStyle.solid,
                                                color: AppColors.purple,
                                              ),
                                            ]
                                          ],
                                        )),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // Show a loading indicator when more notes are being loaded
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: Center(
                                child: state.hasReachedMax
                                    ? const Text('')
                                    : const SpinKitFadingCircle(
                                        color: AppColors.primary,
                                        size: 40.0,
                                      ),
                              ),
                            );
                          }
                        },
                      )
                    : NoData(),
              );
            });
          }
          return SizedBox();
        }),
      ],
    );
  }

  Widget typeLists() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 35.h,
            child: TextField(
              cursorColor: AppColors.greyForgetColor,
              cursorWidth: 1,
              controller: _typeSearchController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: (35.h - 20.sp) / 2,
                  horizontal: 10.w,
                ),
                hintText: 'Search...',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors
                        .greyForgetColor, // Set your desired color here
                    width: 1.0, // Set the border width if needed
                  ),
                  borderRadius: BorderRadius.circular(
                      20.0), // Optional: adjust the border radius
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
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
                context.read<ExpenseTypeBloc>().add(SearchExpenseType(value));
              },
            ),
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        BlocBuilder<ExpenseTypeBloc, ExpenseTypeState>(
            builder: (context, state) {
          if (state is UserLoading || state is UserInitial) {
            return SpinKitFadingCircle(
              size: 40,
              color: AppColors.primary,
            );
          }
          if (state is ExpenseTypeSuccess) {
            ScrollController scrollController = ScrollController();
            scrollController.addListener(() {
              if (scrollController.position.atEdge) {
                if (scrollController.position.pixels != 0 &&
                    !state.isLoadingMore) {
                  // We're at the bottom
                  BlocProvider.of<ExpenseTypeBloc>(context)
                      .add(ExpenseTypeLoadMore(typesearchWord));
                }
              }
            });

            return StatefulBuilder(builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Container(
                constraints: BoxConstraints(maxHeight: 900.h),
                width: 200.w,
                height: 530,
                child: state.ExpenseType.isNotEmpty
                    ? ListView.builder(
                        controller: scrollController,
                        // physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.ExpenseType.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          final typeSelectedIdS = context.watch<ExpenseFilterCountBloc>().state.selectedTypeIds;

                          if (index < state.ExpenseType.length) {
                            final isSelected = typeSelectedIdS
                                .contains(state.ExpenseType[index].id!);
                            // final isSelected = widget.userId?.contains(state.user[index].id);

                            return InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    typeDisSelected = true;

                                    typeSelectedIdS
                                        .remove(state.ExpenseType[index].id!);
                                    typeSelectedname.remove(
                                        state.ExpenseType[index].title!);
                                    typeSelected = false;
                                    context.read<ExpenseFilterCountBloc>().add(
                                        SetTypeIds(typeIds: typeSelectedIdS));
                                    // If no users are selected anymore, update filter count
                                    if (typeSelectedIdS.isEmpty) {
                                      context
                                          .read<ExpenseFilterCountBloc>()
                                          .add(
                                            ExpenseUpdateFilterCount(
                                              filterType: 'users',
                                              isSelected: false,
                                            ),
                                          );
                                    }
                                  } else {
                                    typeDisSelected = false;
                                    if (!typeSelectedIdS.contains(
                                        state.ExpenseType[index].id!)) {
                                      typeSelectedIdS
                                          .add(state.ExpenseType[index].id!);
                                      typeSelectedname
                                          .add(state.ExpenseType[index].title!);
                                      context
                                          .read<ExpenseFilterCountBloc>()
                                          .add(SetTypeIds(
                                              typeIds: typeSelectedIdS));

                                      // Update filter count when first user is selected
                                      if (typeSelectedIdS.length == 1) {
                                        context
                                            .read<ExpenseFilterCountBloc>()
                                            .add(
                                              ExpenseUpdateFilterCount(
                                                filterType: 'type',
                                                isSelected: true,
                                              ),
                                            );
                                      }
                                    }
                                    filterSelectedId =
                                        state.ExpenseType[index].id!;
                                    filterSelectedName = "type";
                                  }

                                  _onFilterSelected('type');
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.purpleShade
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.transparent)),
                                  width: double.infinity,
                                  height: 40.h,
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18.w),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: 100.w,
                                            child: CustomText(
                                              text: state
                                                  .ExpenseType[index].title!,
                                              fontWeight: FontWeight.w500,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              size: 18.sp,
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .textClrChange,
                                            ),
                                          ),
                                          if (isSelected)
                                            Expanded(
                                              flex: 1,
                                              child: const HeroIcon(
                                                  HeroIcons.checkCircle,
                                                  style: HeroIconStyle.solid,
                                                  color: AppColors.purple),
                                            )
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
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: Center(
                                child: state.isLoadingMore
                                    ? const Text('')
                                    : const SpinKitFadingCircle(
                                        color: AppColors.primary,
                                        size: 40.0,
                                      ),
                              ),
                            );
                          }
                        },
                      )
                    : NoData(),
              );
            });
          }
          return SizedBox();
        }),
      ],
    );
  }

  Widget dateList(isLightTheme) {
     selectedDateStarts = parseDateStringFromApi(context.watch<ExpenseFilterCountBloc>().state.fromDate);
      selectedDateEnds = parseDateStringFromApi(context.watch<ExpenseFilterCountBloc>().state.toDate);


    return SizedBox(
      width: 200.w,
      height: 400.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: DateRangePickerWidget(
              dateController: startsController,
              title: AppLocalizations.of(context)!.starts,
                     selectedDateEnds: selectedDateEnds,
                    selectedDateStarts: selectedDateStarts,
                    isLightTheme: isLightTheme,
                    onTap: (start, end) {
                      setState(() {
                        // if (start.isBefore(DateTime.now())) {
                        //   start = DateTime
                        //       .now(); // Reset the start date to today if earlier
                        // }

                        // If the end date is not selected or is null, set it to the start date
                        if (end!.isBefore(start!) || selectedDateEnds == null) {
                          end =
                              start; // Set the end date to the start date if not selected
                        }
                        selectedDateEnds = end;
                        selectedDateStarts = start;
                        startsController.text = DateFormat('MMMM dd, yyyy')
                            .format(selectedDateStarts);
                        endController.text =
                            DateFormat('MMMM dd, yyyy').format(selectedDateEnds!);
                        fromDate = DateFormat('yyyy-MM-dd').format(start);
                        toDate = DateFormat('yyyy-MM-dd').format(end!);
                        context.read<ExpenseFilterCountBloc>().add(SetDate(
                            toDate: toDate ?? "", fromDate: fromDate ?? ""));
                      });
                    },
              // onTap: () {
              //   // showCustomDateRangePicker(
              //   //   context,
              //   //   dismissible: true,
              //   //   minimumDate: DateTime(1900, 1, 1), // Very early date
              //   //   maximumDate: DateTime(2100, 12, 31),
              //   //   endDate: selectedDateEnds,
              //   //   startDate: selectedDateStarts,
              //   //   backgroundColor: Theme.of(context).colorScheme.containerDark,
              //   //   primaryColor: AppColors.primary,
              //   //   onApplyClick: (start, end) {
              //   //     setState(() {
              //   //       // if (start.isBefore(DateTime.now())) {
              //   //       //   start = DateTime
              //   //       //       .now(); // Reset the start date to today if earlier
              //   //       // }
              //   //
              //   //       // If the end date is not selected or is null, set it to the start date
              //   //       if (end.isBefore(start) || selectedDateEnds == null) {
              //   //         end =
              //   //             start; // Set the end date to the start date if not selected
              //   //       }
              //   //       selectedDateEnds = end;
              //   //       selectedDateStarts = start;
              //   //       startsController.text = DateFormat('MMMM dd, yyyy')
              //   //           .format(selectedDateStarts);
              //   //       endController.text =
              //   //           DateFormat('MMMM dd, yyyy').format(selectedDateEnds!);
              //   //       fromDate = DateFormat('yyyy-MM-dd').format(start);
              //   //       toDate = DateFormat('yyyy-MM-dd').format(end);
              //   //       context.read<ExpenseFilterCountBloc>().add(SetDate(
              //   //           toDate: toDate ?? "", fromDate: fromDate ?? ""));
              //   //     });
              //   //   },
              //   //   onCancelClick: () {
              //   //     setState(() {
              //   //       // Handle cancellation if necessary
              //   //     });
              //   //   },
              //   // );
              // },
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: DateRangePickerWidget(
              dateController: endController,
              title: AppLocalizations.of(context)!.ends,
              isLightTheme: isLightTheme,
            ),
          ),
        ],
      ),
    );
  }
}
