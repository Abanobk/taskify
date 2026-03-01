import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../bloc/clients/client_bloc.dart';
import '../../../bloc/clients/client_event.dart';
import '../../../bloc/clients/client_state.dart';
import '../../../bloc/estimate_invoice/estimateInvoice_bloc.dart';
import '../../../bloc/estimate_invoice/estimateInvoice_event.dart';
import '../../../bloc/estimate_invoice_filter/estimate_invoice_filter_bloc.dart';
import '../../../bloc/estimate_invoice_filter/estimate_invoice_filter_event.dart';
import '../../../bloc/expense_filter/expense_filter_bloc.dart';
import '../../../bloc/expense_filter/expense_filter_event.dart';
import '../../../bloc/user/user_bloc.dart';
import '../../../bloc/user/user_event.dart';
import '../../../bloc/user/user_state.dart';
import '../../../config/constants.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/no_data.dart';
import '../../widgets/custom_date.dart';

class EstimateInvoiceFilterDialog extends StatefulWidget {
  final bool isLightTheme;
  final List<String> filter;
  final EstinateInvoiceBloc estinateInvoice;

   EstimateInvoiceFilterDialog({
    Key? key,
    required this.isLightTheme,
    required this.filter,
    required this.estinateInvoice
  }) : super(key: key);

  @override
  State<EstimateInvoiceFilterDialog> createState() => _EstimateInvoiceFilterDialogState();
}

class _EstimateInvoiceFilterDialogState extends State<EstimateInvoiceFilterDialog> {
  TextEditingController _clientSearchController = TextEditingController();
  TextEditingController _clientCreatorSearchController = TextEditingController();
  String searchWord = "";
  String searchWordUserCreator = "";
  String typesearchWord = "";
  List<int> userSelectedIdS = [];
  List<int> userCreatorSelectedIdS = [];
  List<String> userSelectedname = [];
  List<String> userCreatorSelectedname = [];
  bool? userDisSelected = false;
  bool? userSelected = false;
  bool? userCreatorDisSelected = false;
  bool? userCreatorSelected = false;
  bool? clientCreatorDisSelected = false;
  bool? clientCreatorSelected = false;
  List<int> typeSelectedIdS = [];
  List<String> typeSelectedname = [];
  List<int> clientSelectedIdS = [];
  List<int> clientCreatorSelectedIdS = [];
  List<String> clientCreatorSelectedname = [];
  List<String> clientSelectedname = [];
  bool? typeDisSelected = false;
  bool? typeSelected = false;
  int filterSelectedId = 0;
  String filterSelectedName = "";
  List<String> estinateInvoicesname = [];
  List<String> type = ["Estimate", "Invoice"];

  late ValueNotifier<String?> selectedTypeNotifier;
  DateTime selectedDateStarts = DateTime.now();
  DateTime? selectedDateEnds = DateTime.now();
  TextEditingController startsController = TextEditingController();
  TextEditingController endController = TextEditingController();
  TextEditingController _userCreatorSearchController = TextEditingController();


  String? fromDate;
  String? toDate;

  final ValueNotifier<String> filterNameNotifier =
  ValueNotifier<String>('Clients'); // Initialize with default value

  String filterName = 'Clients';
  @override
  void initState() {
    super.initState();

    final filterBlocState = context.read<EstimateInvoiceFilterCountBloc>().state;

    // Access selected user IDs from the state
    clientSelectedIdS = List<int>.from(filterBlocState.selectedClientIds);
    estinateInvoicesname = List<String>.from(filterBlocState.selectedTypeIds);
    userCreatorSelectedIdS = List<int>.from(filterBlocState.selectedUserCreatorIds);
    clientCreatorSelectedIdS = List<int>.from(filterBlocState.selectedClientCreatorIds);

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

  void _onFilterSelected(String selectedFilter) {
    setState(() {
      filterName = selectedFilter; // Update the filterName and rebuild UI
    });
  }
  Widget _getFilteredWidget(filterName, isLightTheme) {
    switch (filterName.toLowerCase()) {
      case 'clients':
        return clientLists(); // Show ClientList if filterName is "client"
      case 'type':
        return estimateInvoiceLists(); // Show UserList if filterName is "user"
      case 'usercreator':
        return userCreatorLists();
      case 'clientcreator':
        return clientCreatorLists();

      case 'date':
        return dateList(isLightTheme); // Show TagsList if filterName is "tags"
      default:
        return clientLists(); // Default view
    }
  }


  @override
  void dispose() {
    filterNameNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                              color: Theme.of(context).colorScheme.containerDark,
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

                    final filterState = context.read<EstimateInvoiceFilterCountBloc>().state;

                    widget.estinateInvoice.add(
                      EstinateInvoiceLists(
                        filterState.selectedTypeIds,
                        filterState.selectedUserCreatorIds,
                        filterState.selectedClientCreatorIds,
                        filterState.selectedClientIds,
                        filterState.fromDate,
                        filterState.toDate,
                      ),
                    );

                    // // Apply filters to project dashboard
                    // BlocProvider.of<ProjectBloc>(context).add(
                    // ProjectDashBoardList(
                    // tagId: tagsSelectedIdS,
                    // clientId: clientSelectedIdS,
                    // userId: userSelectedIdS,
                    // statusId: statusSelectedIdS,
                    // priorityId: prioritySelectedIdS,
                    // fromDate: fromDate,
                    // toDate: toDate,
                    // ),
                    // );

                    // Clear search controllers



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
                          .read<EstimateInvoiceFilterCountBloc>()
                          .add(EstimateInvoiceResetFilterCount());
                      BlocProvider.of<ClientBloc>(context).add(ClientList());
                      BlocProvider.of<UserBloc>(context).add(UserList());
                      widget.estinateInvoice.add(const EstinateInvoiceLists([],[],[],[],"",""));


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
  Widget userCreatorLists() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 35.h,
            child: TextField(
              cursorColor: AppColors.greyForgetColor,
              cursorWidth: 1,
              controller: _userCreatorSearchController,
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
                  searchWordUserCreator = value;
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
                  // physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: state.user.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index < state.user.length) {
                      final userCreatorSelectedIdS =
                          context.watch<EstimateInvoiceFilterCountBloc>().state.selectedUserCreatorIds;


                      final isSelected =
                      userCreatorSelectedIdS.contains(state.user[index].id!);
                      // final isSelected = widget.userId?.contains(state.user[index].id);

                      return InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              userCreatorDisSelected = true;
                              userCreatorSelectedIdS
                                  .remove(state.user[index].id!);
                              userCreatorSelectedname
                                  .remove(state.user[index].firstName!);
                              userCreatorSelected = false;

                              // If no users are selected anymore, update filter count
                              if (userCreatorSelectedIdS.isEmpty) {
                                context
                                    .read<EstimateInvoiceFilterCountBloc>()
                                    .add(
                                  EstimateInvoiceUpdateFilterCount(
                                    filterType: 'users',
                                    isSelected: false,
                                  ),
                                );
                              }
                            } else {
                              userCreatorDisSelected = false;
                              if (!userCreatorSelectedIdS
                                  .contains(state.user[index].id!)) {
                                userCreatorSelectedIdS
                                    .add(state.user[index].id!);
                                userCreatorSelectedname
                                    .add(state.user[index].firstName!);

                                // Update filter count when first user is selected
                                if (userCreatorSelectedIdS.length == 1) {
                                  context
                                      .read<EstimateInvoiceFilterCountBloc>()
                                      .add(
                                    EstimateInvoiceUpdateFilterCount(
                                      filterType: 'users',
                                      isSelected: true,
                                    ),
                                  );
                                }
                                context.read<EstimateInvoiceFilterCountBloc>().add(
                                    SetUserCreator(userCreatorIds: userCreatorSelectedIdS));
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
  Widget clientLists() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            padding: EdgeInsets.zero,
            height: 35.h,
            child: TextField(
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.greyForgetColor,
              cursorWidth: 1,
              controller: _clientSearchController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: (35.h - 30.sp) / 2,
                  horizontal: 10.w,
                ),
                hintText: AppLocalizations.of(context)!.search,
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
                context.read<ClientBloc>().add(SearchClients(value));
              },
              onSubmitted: (value) {
                context.read<ClientBloc>().add(SearchClients(value));
              },
            ),
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        BlocBuilder<ClientBloc, ClientState>(builder: (context, state) {
          if (state is ClientLoading || state is ClientInitial) {
            return SpinKitFadingCircle(
              size: 40,
              color: AppColors.primary,
            );
          }
          if (state is ClientPaginated) {
            ScrollController scrollController = ScrollController();
            scrollController.addListener(() {
              if (scrollController.position.atEdge) {
                if (scrollController.position.pixels != 0 &&
                    !state.hasReachedMax) {
                  // We're at the bottom
                  BlocProvider.of<ClientBloc>(context)
                      .add(ClientLoadMore(searchWord));
                }
              }
            });

            return StatefulBuilder(builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Container(
                  constraints: BoxConstraints(maxHeight: 900.h),
                  width: 200.w,
                  height: 530,
                  child: state.client.isNotEmpty
                      ? ListView.builder(
                    controller: scrollController,
                    // physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: state.client.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index < state.client.length) {
                        final clientSelectedIdS =
                            context.watch<EstimateInvoiceFilterCountBloc>().state.selectedClientIds;


                        final isSelected = clientSelectedIdS
                            .contains(state.client[index].id!);
                        // final isSelected = widget.userId?.contains(state.user[index].id);

                        return InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                clientSelectedIdS
                                    .remove(state.client[index].id!);
                                clientSelectedname.remove(
                                    state.client[index].firstName!);
                                // If no clients are selected anymore, update filter count
                                if (clientSelectedIdS.isEmpty) {
                                  context
                                      .read<
                                      EstimateInvoiceFilterCountBloc>()
                                      .add(
                                    EstimateInvoiceUpdateFilterCount(
                                      filterType: 'clients',
                                      isSelected: false,
                                    ),
                                  );
                                }
                              } else {
                                if (!clientSelectedIdS
                                    .contains(state.client[index].id!)) {
                                  clientSelectedIdS
                                      .add(state.client[index].id!);
                                  clientSelectedname.add(
                                      state.client[index].firstName!);
                                  // Update filter count when first client is selected
                                  if (clientSelectedIdS.length == 1) {
                                    context
                                        .read<
                                        EstimateInvoiceFilterCountBloc>()
                                        .add(
                                      EstimateInvoiceUpdateFilterCount(
                                        filterType: 'clients',
                                        isSelected: true,
                                      ),
                                    );
                                  }
                                  context.read<EstimateInvoiceFilterCountBloc>().add(
                                      SetClients(clientIds: clientSelectedIdS));
                                }
                              }
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
                                      horizontal: 0.w,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundImage: NetworkImage(
                                              state.client[index]
                                                  .profile!),
                                        ),
                                        SizedBox(
                                          width: 5.w,
                                        ), // Column takes up maximum available space
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 0.w),
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
                                                      child: CustomText(
                                                        text: state
                                                            .client[index]
                                                            .firstName!,
                                                        fontWeight:
                                                        FontWeight
                                                            .w500,
                                                        maxLines: 1,
                                                        overflow:
                                                        TextOverflow
                                                            .ellipsis,
                                                        size: 18.sp,
                                                        color: isSelected
                                                            ? AppColors
                                                            .primary
                                                            : Theme.of(
                                                            context)
                                                            .colorScheme
                                                            .textClrChange,
                                                      ),
                                                    ),
                                                    SizedBox(width: 5.w),
                                                    Flexible(
                                                      child: CustomText(
                                                        text: state
                                                            .client[index]
                                                            .lastName!,
                                                        fontWeight:
                                                        FontWeight
                                                            .w500,
                                                        maxLines: 1,
                                                        overflow:
                                                        TextOverflow
                                                            .ellipsis,
                                                        size: 18.sp,
                                                        color: isSelected
                                                            ? AppColors
                                                            .primary
                                                            : Theme.of(
                                                            context)
                                                            .colorScheme
                                                            .textClrChange,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: CustomText(
                                                        text: state
                                                            .client[index]
                                                            .email!,
                                                        fontWeight:
                                                        FontWeight
                                                            .w500,
                                                        maxLines: 1,
                                                        overflow:
                                                        TextOverflow
                                                            .ellipsis,
                                                        size: 14.sp,
                                                        color: isSelected
                                                            ? AppColors
                                                            .primary
                                                            : Theme.of(
                                                            context)
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
                          padding:
                          const EdgeInsets.symmetric(vertical: 0),
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
                      : NoData());
            });
          }
          return SizedBox();
        }),
      ],
    );
  }
  Widget clientCreatorLists() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            padding: EdgeInsets.zero,
            height: 35.h,
            child: TextField(
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.greyForgetColor,
              cursorWidth: 1,
              controller: _clientCreatorSearchController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: (35.h - 30.sp) / 2,
                  horizontal: 10.w,
                ),
                hintText: AppLocalizations.of(context)!.search,
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
                context.read<ClientBloc>().add(SearchClientsCreator(value));
              },
              onSubmitted: (value) {
                context.read<ClientBloc>().add(SearchClientsCreator(value));
              },
            ),
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        BlocBuilder<ClientBloc, ClientState>(builder: (context, state) {
          if (state is ClientLoading || state is ClientInitial) {
            return SpinKitFadingCircle(
              size: 40,
              color: AppColors.primary,
            );
          }
          if (state is ClientPaginated) {
            ScrollController scrollController = ScrollController();
            scrollController.addListener(() {
              if (scrollController.position.atEdge) {
                if (scrollController.position.pixels != 0 &&
                    !state.hasReachedMax) {
                  // We're at the bottom
                  BlocProvider.of<ClientBloc>(context)
                      .add(ClientLoadMore(searchWord));
                }
              }
            });

            return StatefulBuilder(builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Container(
                  constraints: BoxConstraints(maxHeight: 900.h),
                  width: 200.w,
                  height: 530,
                  child: state.client.isNotEmpty
                      ? ListView.builder(
                    controller: scrollController,
                    // physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: state.client.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index < state.client.length) {
                        final clientCreatorSelectedIdS =
                            context.watch<EstimateInvoiceFilterCountBloc>().state.selectedClientCreatorIds;

                        final isSelected = clientCreatorSelectedIdS
                            .contains(state.client[index].id!);
                        // final isSelected = widget.userId?.contains(state.user[index].id);

                        return InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                clientCreatorDisSelected = true;
                                clientCreatorSelectedIdS
                                    .remove(state.client[index].id!);
                                clientCreatorSelectedname
                                    .remove(state.client[index].firstName!);
                                clientCreatorSelected = false;

                                // If no users are selected anymore, update filter count
                                if (clientCreatorSelectedIdS.isEmpty) {
                                  context
                                      .read<EstimateInvoiceFilterCountBloc>()
                                      .add(
                                    EstimateInvoiceUpdateFilterCount(
                                      filterType: 'clientcreator',
                                      isSelected: false,
                                    ),
                                  );
                                }
                              } else {
                                clientCreatorDisSelected = false;
                                if (!clientCreatorSelectedIdS
                                    .contains(state.client[index].id!)) {
                                  clientCreatorSelectedIdS
                                      .add(state.client[index].id!);
                                  userCreatorSelectedname
                                      .add(state.client[index].firstName!);

                                  // Update filter count when first user is selected
                                  if (clientCreatorSelectedIdS.length == 1) {
                                    context
                                        .read<EstimateInvoiceFilterCountBloc>()
                                        .add(
                                      EstimateInvoiceUpdateFilterCount(
                                        filterType: 'clientcreator',
                                        isSelected: true,
                                      ),
                                    );
                                  }
                                  context.read<EstimateInvoiceFilterCountBloc>().add(
                                      SetClientCreator(clientCreatorIds: clientCreatorSelectedIdS));
                                }
                                filterSelectedId = state.client[index].id!;
                                filterSelectedName = "clientcreator";
                              }

                              _onFilterSelected('clientcreator');
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
                                      horizontal: 0.w,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundImage: NetworkImage(
                                              state.client[index]
                                                  .profile!),
                                        ),
                                        SizedBox(
                                          width: 5.w,
                                        ), // Column takes up maximum available space
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 0.w),
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
                                                      child: CustomText(
                                                        text: state
                                                            .client[index]
                                                            .firstName!,
                                                        fontWeight:
                                                        FontWeight
                                                            .w500,
                                                        maxLines: 1,
                                                        overflow:
                                                        TextOverflow
                                                            .ellipsis,
                                                        size: 18.sp,
                                                        color: isSelected
                                                            ? AppColors
                                                            .primary
                                                            : Theme.of(
                                                            context)
                                                            .colorScheme
                                                            .textClrChange,
                                                      ),
                                                    ),
                                                    SizedBox(width: 5.w),
                                                    Flexible(
                                                      child: CustomText(
                                                        text: state
                                                            .client[index]
                                                            .lastName!,
                                                        fontWeight:
                                                        FontWeight
                                                            .w500,
                                                        maxLines: 1,
                                                        overflow:
                                                        TextOverflow
                                                            .ellipsis,
                                                        size: 18.sp,
                                                        color: isSelected
                                                            ? AppColors
                                                            .primary
                                                            : Theme.of(
                                                            context)
                                                            .colorScheme
                                                            .textClrChange,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: CustomText(
                                                        text: state
                                                            .client[index]
                                                            .email!,
                                                        fontWeight:
                                                        FontWeight
                                                            .w500,
                                                        maxLines: 1,
                                                        overflow:
                                                        TextOverflow
                                                            .ellipsis,
                                                        size: 14.sp,
                                                        color: isSelected
                                                            ? AppColors
                                                            .primary
                                                            : Theme.of(
                                                            context)
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
                          padding:
                          const EdgeInsets.symmetric(vertical: 0),
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
                      : NoData());
            });
          }
          return SizedBox();
        }),
      ],
    );
  }

  Widget estimateInvoiceLists() {
    // int selectedIndex = -1;
    //
    // for (var name in estinateInvoicesname) {
    //   if (type.contains(name)) {
    //     selectedIndex = type.indexOf(name);
    //     break;
    //   }
    // }

    return Column(
      children: [

        StatefulBuilder(builder:
            (BuildContext context, void Function(void Function()) setState) {
          return Container(
              constraints: BoxConstraints(maxHeight: 900.h),
              width: 200.w,
              height: 530,
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 20.h),
                shrinkWrap: true,
                itemCount: type.length,
                itemBuilder: (BuildContext context, int index) {
                  final estinateInvoicesname =
                      context.watch<EstimateInvoiceFilterCountBloc>().state.selectedTypeIds;
                  final isSelected = estinateInvoicesname.contains(type[index]);


                  // final isSelected = selectedIndex == index;

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            typeDisSelected = true;
                            estinateInvoicesname.remove(type[index]);
                            typeSelected = false;

                            if (estinateInvoicesname.isEmpty) {
                              context.read<EstimateInvoiceFilterCountBloc>().add(
                                EstimateInvoiceUpdateFilterCount(
                                  filterType: 'type',
                                  isSelected: false,
                                ),
                              );
                            }
                          } else {
                            typeDisSelected = false;
                            if (!estinateInvoicesname.contains(type[index])) {
                              estinateInvoicesname.add(type[index]);

                              if (estinateInvoicesname.length == 1) {
                                context.read<EstimateInvoiceFilterCountBloc>().add(
                                  EstimateInvoiceUpdateFilterCount(
                                    filterType: 'type',
                                    isSelected: true,
                                  ),
                                );
                              }

                              context.read<EstimateInvoiceFilterCountBloc>().add(
                                SetTypes(typeIds: estinateInvoicesname),
                              );
                            }

                            filterSelectedName = "type";
                          }

                          _onFilterSelected('type');
                        });
                      },

                      child: Container(
                        width: double.infinity,
                        height: 35.h,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.purpleShade
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.purple
                                : Colors.transparent,
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 100.w,
                                  child: CustomText(
                                    text: type[index],
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
                                    child: const HeroIcon(HeroIcons.checkCircle,
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
                },
              ));
        })
      ],
    );
  }

  Widget dateList(isLightTheme) {
    selectedDateStarts = parseDateStringFromApi(context.watch<EstimateInvoiceFilterCountBloc>().state.fromDate);
    selectedDateEnds = parseDateStringFromApi(context.watch<EstimateInvoiceFilterCountBloc>().state.toDate);


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
                        context.read<EstimateInvoiceFilterCountBloc>().add(
                            SetDateEstimate(fromDate: fromDate!,toDate: toDate!));

                      });
                    },


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
