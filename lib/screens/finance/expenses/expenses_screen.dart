import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/permissions/permissions_event.dart';
import 'package:taskify/bloc/setting/settings_bloc.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/widgets/no_permission_screen.dart';
import 'package:taskify/utils/widgets/shake_widget.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';

import '../../../bloc/expense/expense_state.dart';
import '../../../bloc/expense/expense_event.dart';
import '../../../bloc/expense/expense_bloc.dart';
import '../../../bloc/expense_filter/expense_filter_bloc.dart';
import '../../../bloc/expense_filter/expense_filter_event.dart';
import '../../../bloc/expense_filter/expense_filter_state.dart';
import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/constants.dart';
import '../../../data/model/finance/expense_model.dart';
import '../../../routes/routes.dart';
import '../../../utils/widgets/custom_dimissible.dart';
import '../../../utils/widgets/custom_text.dart';
import 'package:heroicons/heroicons.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../../../config/internet_connectivity.dart';
import '../../../utils/widgets/circularprogress_indicator.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../../utils/widgets/search_pop_up.dart';
import '../../notes/widgets/notes_shimmer_widget.dart';
import '../../widgets/no_data.dart';

import '../../widgets/search_field.dart';
import '../../widgets/side_bar.dart';
import '../../widgets/speech_to_text.dart';
import 'expense_filter_bottomsheet.dart';
import '../../../../src/generated/i18n/app_localizations.dart';

class ExpensesScreen extends StatefulWidget {
  final bool? fromNoti;
  const ExpensesScreen({super.key, this.fromNoti});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  TextEditingController searchController = TextEditingController();
  String searchWord = "";

  bool shouldDisableEdit = true;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  bool isListening =
      false; // Flag to track if speech recognition is in progress
  bool dialogShown = false;

  double level = 0.0;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late SpeechToTextHelper speechHelper;
  final List<String> filter = ['Users', 'Type', 'Date'];
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  bool isLoadingMore = false;
  String currency = "";
  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  @override
  void initState() {
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() {
          _connectionStatus = results;
        });
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
        });
      }
    });
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;

          final filterState = context.read<ExpenseFilterCountBloc>().state;

          context.read<ExpenseBloc>().add(
                ExpenseLists(
                  filterState.selectedTypeIds,
                  filterState.selectedUserIds,
                  filterState.fromDate,
                  filterState.toDate,
                ),
              );
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseBloc>().add(ExpenseLists([], [], "", ""));
      context.read<PermissionsBloc>().add(GetPermissions());
      currency = context.read<SettingsBloc>().currencySymbol!;
    });
  }

  bool? isLoading = true;
  void onDeleteExpense(int Expense) {
    context.read<ExpenseBloc>().add(DeleteExpenses(Expense));
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    BlocProvider.of<ExpenseBloc>(context).add(ExpenseLists([], [], "", ""));

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;

    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          router.pop();
          context
              .read<ExpenseFilterCountBloc>()
              .add(ExpenseResetFilterCount());


        }
      },
      child: Scaffold(
              backgroundColor: Theme.of(context).colorScheme.backGroundColor,
              body: SideBar(
                context: context,
                controller: sideBarController,
                underWidget: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: BackArrow(
                        onTap: () {
                          context
                              .read<ExpenseFilterCountBloc>()
                              .add(ExpenseResetFilterCount());
                          router.pop();
                        },
                        iscreatePermission:
                            context.read<PermissionsBloc>().iscreateExpenses,
                        isFromNotification: widget.fromNoti,
                        fromNoti: "Expense",
                        iSBackArrow: true,
                        title: AppLocalizations.of(context)!.expenses,
                        isAdd: context.read<PermissionsBloc>().iscreateExpenses,
                        onPress: () {
                          UserExpenseModel userModel = UserExpenseModel(
                              id: 0,
                              email: "",
                              photo: "",
                              firstName: "",
                              lastName: "");
                          ExpenseModel model = ExpenseModel(
                              id: 0,
                              title: "",
                              expenseTypeId: 0,
                              expenseDate: "",
                              expenseType: "",
                              userId: 0,
                              user: userModel,
                              amount: "",
                              note: "");
                          router.push(
                            '/createupdateexpenses',
                            extra: {'isCreate': true, "expenseModel": model},
                          );

                          // createEditNotes(isLightTheme: isLightTheme, isCreate: true);
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),
                    CustomSearchField(
                      isLightTheme: isLightTheme,
                      controller: searchController,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (searchController.text.isNotEmpty)
                            SizedBox(
                              width: 20.w,
                              // color: AppColors.red,
                              child: IconButton(
                                highlightColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.clear,
                                  size: 20.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textFieldColor,
                                ),
                                onPressed: () {
                                  // Clear the search field
                                  setState(() {
                                    searchController.clear();
                                  });
                                  final filterState = context
                                      .read<ExpenseFilterCountBloc>()
                                      .state;

                                  context.read<ExpenseBloc>().add(
                                        SearchExpenses(
                                          "",
                                          filterState.selectedTypeIds,
                                          filterState.selectedUserIds,
                                          filterState.fromDate,
                                          filterState.toDate,
                                        ),
                                      );
                                  // Optionally trigger the search event with an empty string
                                },
                              ),
                            ),
                          IconButton(
                            icon: Icon(
                              !speechHelper.isListening
                                  ? Icons.mic_off
                                  : Icons.mic,
                              size: 20.sp,
                              color: Theme.of(context).colorScheme.textFieldColor,
                            ),
                            onPressed: () {
                              if (speechHelper.isListening) {
                                speechHelper.stopListening();
                              } else {
                                speechHelper.startListening(
                                    context, searchController, SearchPopUp());
                              }
                            },
                          ),
                          BlocConsumer<ExpenseFilterCountBloc,
                              ExpenseFilterCountState>(
                            listener: (context, state) {
                              print("fk hfh ${state.count}");
                            },
                            builder: (context, state) {
                              print("fk hfh e ${state}");
                              return SizedBox(
                                width: 35.w,
                                child: Stack(
                                  children: [
                                    IconButton(
                                      icon: HeroIcon(
                                        HeroIcons.adjustmentsHorizontal,
                                        style: HeroIconStyle.solid,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textFieldColor,
                                        size: 30.sp,
                                      ),
                                      onPressed: () {
                                        // BlocProvider.of<ClientBloc>(context)
                                        //     .add(ClientList());
                                        // BlocProvider.of<UserBloc>(context)
                                        //     .add(UserList());
                                        // BlocProvider.of<StatusMultiBloc>(context)
                                        //     .add(StatusMultiList());
                                        // BlocProvider.of<TagMultiBloc>(context)
                                        //     .add(TagMultiList());
                                        // BlocProvider.of<PriorityMultiBloc>(context)
                                        //     .add(PriorityMultiList());
                                        final expenseBloc =
                                            context.read<ExpenseBloc>();

                                        showModalBottomSheet(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .containerDark,
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) {
                                            return FilterDialog(
                                              isLightTheme: isLightTheme,
                                              filter: filter,
                                              expenseBloc:
                                                  expenseBloc, // Pass bloc directly
                                            );
                                          },
                                        );

                                        // Your existing filter dialog logic
                                      },
                                    ),
                                    if (state.count > 0)
                                      Positioned(
                                        right: 5.w,
                                        top: 7.h,
                                        child: Container(
                                          padding: EdgeInsets.zero,
                                          alignment: Alignment.center,
                                          height: 12.h,
                                          width: 10.w,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: CustomText(
                                            text: state.count.toString(),
                                            color: Colors.white,
                                            size: 6,
                                            textAlign: TextAlign.center,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          )
                        ],
                      ),
                      onChanged: (value) {
                        searchWord = value;
                        final filterState =
                            context.read<ExpenseFilterCountBloc>().state;

                        context.read<ExpenseBloc>().add(
                              SearchExpenses(
                                value,
                                filterState.selectedTypeIds,
                                filterState.selectedUserIds,
                                filterState.fromDate,
                                filterState.toDate,
                              ),
                            );
                      },
                    ),
                    SizedBox(height: 20.h),
                    Expanded(
                      child: RefreshIndicator(
                          color: AppColors.primary, // Spinner color
                          backgroundColor:
                              Theme.of(context).colorScheme.backGroundColor,
                          onRefresh: _onRefresh,
                          child: _ExpenseBloc(isLightTheme)),
                    ),
                  ],
                ),
              )),
        );
  }

  Widget _ExpenseBloc(isLightTheme) {
    return BlocListener<ExpenseBloc, ExpenseState>(
      listener: (context, state) {
        print("udhrghkd $state");

        if (state is ExpenseDeleteSuccess) {
          Navigator.pop(context);
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }

        if (state is ExpenseDeleteError) {
          flutterToastCustom(msg: state.errorMessage);
          context.read<ExpenseBloc>().add(const ExpenseLists([], [], "", ""));
        }

        if (state is ExpenseError) {
          flutterToastCustom(msg: state.errorMessage);
        }
      },
      child: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return NotesShimmer(
              height: 190.h,
              count: 4,
            );
          } else if (state is ExpensePaginated) {
            // Show Expense list with pagination
            return NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                // Check if the user has scrolled to the end and load more Expense if needed
                if (!state.hasReachedMax &&
                    scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  final filterState =
                      context.read<ExpenseFilterCountBloc>().state;

                  context.read<ExpenseBloc>().add(
                    LoadMoreExpenses(
                      searchWord,
                      filterState.selectedTypeIds,
                      filterState.selectedUserIds,
                      filterState.fromDate,
                      filterState.toDate,
                    ),
                  );
                }
                return false;
              },
              child: context.read<PermissionsBloc>().isManageExpenses == true
                  ? state.Expense.isNotEmpty
                  ? _ExpenseList(
                  isLightTheme, state.hasReachedMax, state.Expense)
                  : NoData(
                isImage: true,
              )
                  : NoPermission(),
            );
          }

          return const Text("");
        },
      ),
    );

  }

  Widget _ExpenseList(isLightTheme, hasReachedMax, ExpenseList) {
    return ListView.builder(
      padding: EdgeInsets.only(
          left: 18.w,
          right: 18.w,
          bottom: 70.h,
          top: 0),
      // shrinkWrap: true,
      itemCount: hasReachedMax
          ? ExpenseList.length // No extra item if all data is loaded
          : ExpenseList.length + 1, // Add 1 for the loading indicator
      itemBuilder: (context, index) {
        if (index < ExpenseList.length) {
          final Expense = ExpenseList[index];
          return index == 0
              ? ShakeWidget(
                  child: _expenseCard(
                      isLightTheme: isLightTheme,
                      expenseModel: Expense,
                      ExpenseList: ExpenseList,
                      index: index))
              : _expenseCard(
                  isLightTheme: isLightTheme,
                  expenseModel: Expense,
                  ExpenseList: ExpenseList,
                  index: index);
        } else {
          // Show a loading indicator when more Expense are being loaded
          return CircularProgressIndicatorCustom(
            hasReachedMax: hasReachedMax,
          );
        }
      },
    );
  }

  Widget _expenseCard(
      {isLightTheme,
      required ExpenseModel expenseModel,
      required List<ExpenseModel> ExpenseList,
      required int index}) {
    final expenseDate = formatDateFromApi(expenseModel.expenseDate!, context);

    return DismissibleCard(
      title: expenseModel.id.toString(),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.endToStart &&
            context.read<PermissionsBloc>().isdeleteExpenses == true) {

          try {
            final result = await showDialog<bool>(
              context: context,
              barrierDismissible:
              false, // Prevent dismissing by tapping outside
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  backgroundColor:
                  Theme.of(context).colorScheme.alertBoxBackGroundColor,
                  title: Text(
                    AppLocalizations.of(context)!.confirmDelete,
                  ),
                  content: Text(
                    AppLocalizations.of(context)!.areyousure,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        print(
                            "User confirmed deletion - about to pop with true");
                        Navigator.of(context).pop(true); // Confirm deletion
                      },
                      child: Text(
                        AppLocalizations.of(context)!.ok,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        print(
                            "User cancelled deletion - about to pop with false");
                        Navigator.of(context).pop(false); // Cancel deletion
                      },
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                      ),
                    ),
                  ],
                );
              },
            );

            print("Dialog result received: $result");
            print("About to return from confirmDismiss: ${result ?? false}");

            // If user confirmed deletion, handle it here instead of in onDismissed
            if (result == true) {
              print("Handling deletion directly in confirmDismiss");
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  ExpenseList.removeAt(index);

                });
                context.read<ExpenseBloc>().add(DeleteExpenses(expenseModel.id!));
              });
              // Return false to prevent the dismissible from animating
              return false;
            }

            return false; // Always return false since we handle deletion manually
          } catch (e) {
            print("Error in dialog: $e");
            return false;
          }// Return the result of the dialog
        } else if (direction == DismissDirection.startToEnd &&
            context.read<PermissionsBloc>().iseditExpenses == true) {
          router.push(
            '/createupdateexpenses',
            extra: {'isCreate': false, "expenseModel": expenseModel},
          );

          return false; // Prevent dismiss
        }

        return false;
      },
      dismissWidget: Padding(
        padding:  EdgeInsets.only(bottom: 20.h),
        child: Container(
          // height: 250.h,
          decoration: BoxDecoration(
              boxShadow: [
                isLightTheme
                    ? MyThemes.lightThemeShadow
                    : MyThemes.darkThemeShadow,
              ],
              // color: AppColors.red,
              color: Theme.of(context).colorScheme.containerDark,
              borderRadius: BorderRadius.circular(12)),
          width: double.infinity,
          // color: Colors.yellow,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w,vertical: 15.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: ID and Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "#${expenseModel.id.toString()}",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Text(
                      expenseDate != "" ?expenseDate : "",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // Title
                CustomText(
                  text: expenseModel.title ?? "",
                  color: Theme.of(context).colorScheme.textClrChange,
                  size: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
                SizedBox(height: 8.h),
                // Expense Type
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CustomText(
                      text: expenseModel.expenseType ?? "",
                      color: Theme.of(context).colorScheme.textClrChange,
                      size: 16,
                      fontWeight: FontWeight.w700,
                    )),
                SizedBox(height: 16.h),
                // User & Amount
                Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 23.r,
                      backgroundColor: AppColors.greyColor,
                      child: CircleAvatar(
                        radius: 22.r,
                        backgroundColor: Colors.blue,
                        backgroundImage:
                            NetworkImage(expenseModel.user!.photo!),
                      ),
                    ),
                    SizedBox(width: 12.h),
                    // User details
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text:
                          "${expenseModel.user?.firstName ?? ""} ${expenseModel.user?.lastName ?? ""}",

                          color: Theme.of(context).colorScheme.textClrChange,
                          size: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        CustomText(
                          text: expenseModel.user!.email ?? "",
                          color: AppColors.greyColor,
                          size: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Amount
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "$currency ${expenseModel.amount ?? ""}",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.createdby,
                      style: TextStyle(
                        color: AppColors.greyColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                    Text(
                      expenseModel.createdBy ?? "",
                      style: TextStyle(
                        color: AppColors.blueColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                )
                // Action Icons
              ],
            ),
          ),
        ),
      ),
      direction: context.read<PermissionsBloc>().isdeleteExpenses == true &&
              context.read<PermissionsBloc>().iseditExpenses == true
          ? DismissDirection.horizontal // Allow both directions
          : context.read<PermissionsBloc>().isdeleteExpenses == true
              ? DismissDirection.endToStart // Allow delete
              : context.read<PermissionsBloc>().iseditExpenses == true
                  ? DismissDirection.startToEnd // Allow edit
                  : DismissDirection.none,
      onDismissed: (DismissDirection direction) {
        if (direction == DismissDirection.endToStart &&
            context.read<PermissionsBloc>().isdeleteExpenses == true) {
    WidgetsBinding.instance.addPostFrameCallback((_) {  setState(() {
            ExpenseList.removeAt(index);
          });
          context.read<ExpenseBloc>().add(DeleteExpenses(expenseModel.id!));
    });
        } else if (direction == DismissDirection.startToEnd &&
            context.read<PermissionsBloc>().iseditProject == true) {
          // Perform edit action
        }
      },
    );
  }
}
