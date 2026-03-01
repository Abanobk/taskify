import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:taskify/bloc/permissions/permissions_bloc.dart';

import 'dart:async';
import 'package:taskify/config/colors.dart';
import '../../../bloc/payslip/allowances/allowance_bloc.dart';
import '../../../bloc/payslip/allowances/allowance_event.dart';
import '../../../bloc/payslip/allowances/allowance_state.dart';
import '../../../data/model/allowance.dart';
import '../../../utils/widgets/notes_shimmer_widget.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import 'package:taskify/utils/widgets/custom_dimissible.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';

import '../../../bloc/setting/settings_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/internet_connectivity.dart';

import '../../../utils/widgets/circularprogress_indicator.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/search_pop_up.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../widgets/custom_textfields/custom_textfield.dart';
import '../../widgets/search_field.dart';
import '../../widgets/side_bar.dart';
import '../../widgets/speech_to_text.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class AllowanceScreen extends StatefulWidget {
  const AllowanceScreen({super.key});

  @override
  State<AllowanceScreen> createState() => _AllowanceScreenState();
}

class _AllowanceScreenState extends State<AllowanceScreen> {
  DateTime now = DateTime.now();
  final GlobalKey<FormState> _createAllowancesKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController perController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  bool? isLoading = true;
  late SpeechToTextHelper speechHelper;
  bool isLoadingMore = false;
  String searchWord = "";

  late ValueNotifier<String> AllowanceType = ValueNotifier<String>("");
  late ValueNotifier<String> AllowanceTypeFilter = ValueNotifier<String>("");

  final ValueNotifier<String> noteType = ValueNotifier<String>("text");
  final ValueNotifier<bool> filterType = ValueNotifier<bool>(false);

  bool dialogShown = false;
  double valueInProgress = 0;
  String? drawing;
  String? currency;
  String? currencyPosition;

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);

  @override
  void initState() {
    super.initState();
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
    context.read<AllowanceBloc>().add(const AllowancesList());
    AllowanceType = ValueNotifier<String>(AllowanceType.value.toLowerCase());

    currency = context.read<SettingsBloc>().currencySymbol;
    currencyPosition = context.read<SettingsBloc>().currencyPosition;
    filterType.value = false;
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          context.read<AllowanceBloc>().add(SearchAllowances(searchWord));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    AllowanceType.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _onCreateAllowances() {
    final amountText = amountController.text.trim();

    // Check for comma in amount
    if (amountText.contains(',')) {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!
            .commaNotAllowed, // Add this to your AppLocalizations
        color: AppColors.red,
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount < 0) {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.negativeValueNotAllowed,
        color: AppColors.red,
      );
      return;
    }
    if (_createAllowancesKey.currentState!.validate()) {
      final newAllowance = AllowanceModel(
        title: titleController.text.trim(),
        amount: amountText,
      );

      context.read<AllowanceBloc>().add(AddAllowances(newAllowance));
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  void _onEditAllowances(id, title, desc) async {
    final amountText = amountController.text.trim();

    // Check for comma in amount
    if (amountText.contains(',')) {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!
            .commaNotAllowed, // Add this to your AppLocalizations
        color: AppColors.red,
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount < 0) {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.negativeValueNotAllowed,
        color: AppColors.red,
      );
      return;
    }
    if (_createAllowancesKey.currentState!.validate()) {
      final updatedNote = AllowanceModel(
        id: id,
        title: titleController.text,
        amount: amountController.text.isNotEmpty ? amountController.text : "",
      );

      context.read<AllowanceBloc>().add(UpdateAllowances(updatedNote));
      final todosBloc = BlocProvider.of<AllowanceBloc>(context);
      todosBloc.stream.listen((state) {
        print("dfgbh $state");
        if (state is AllowancesEditSuccess) {
          if (mounted) {
            context.read<AllowanceBloc>().add(const AllowancesList());

            flutterToastCustom(
                msg: AppLocalizations.of(context)!.updatedsuccessfully,
                color: AppColors.primary);
            Navigator.pop(context);
          }
        }
        if (state is AllowancesEditError) {
          flutterToastCustom(msg: state.errorMessage);
          context.read<AllowanceBloc>().add(const AllowancesList());
        }
      });
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  void _onDeleteAllowances(Allowances) {
    context.read<AllowanceBloc>().add(DeleteAllowances(Allowances));
    final setting = context.read<AllowanceBloc>();
    setting.stream.listen((state) {
      if (state is AllowancesDeleteSuccess) {
        if (mounted) {
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is AllowancesDeleteError) {
        flutterToastCustom(msg: state.errorMessage);
      }
    });
    context.read<AllowanceBloc>().add(const AllowancesList());
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    BlocProvider.of<AllowanceBloc>(context).add(const AllowancesList());
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
        : Scaffold(
            backgroundColor: Theme.of(context).colorScheme.backGroundColor,
            body: SideBar(
              context: context,
              controller: sideBarController,
              underWidget: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    _appbar(isLightTheme),
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
                                  setState(() {
                                    searchController.clear();
                                  });
                                  context
                                      .read<AllowanceBloc>()
                                      .add(SearchAllowances(''));
                                },
                              ),
                            ),
                          SizedBox(
                            width: 30.w,
                            child: IconButton(
                              icon: Icon(
                                !speechHelper.isListening
                                    ? Icons.mic_off
                                    : Icons.mic,
                                size: 20.sp,
                                color: Theme.of(context)
                                    .colorScheme
                                    .textFieldColor,
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
                          ),
                        ],
                      ),
                      onChanged: (value) {
                        searchWord = value;
                        context
                            .read<AllowanceBloc>()
                            .add(SearchAllowances(value));
                      },
                    ),
                    SizedBox(height: 20.h),
                    body(isLightTheme)
                  ],
                ),
              ),
            ));
  }

  Widget body(isLightTheme) {
    return Expanded(
      child: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        onRefresh: _onRefresh,
        child: BlocConsumer<AllowanceBloc, AllowancesState>(
          listener: (context, state) {
            if (state is AllowancesPaginated) {
              isLoadingMore = false;
              setState(() {});
            }
          },
          builder: (context, state) {
            print("fvgbhnjm $state");
            if (state is AllowancesLoading) {
              return const NotesShimmer();
            } else if (state is AllowancesEditSuccess) {
              context.read<AllowanceBloc>().add(const AllowancesList());

              flutterToastCustom(
                msg: AppLocalizations.of(context)!.updatedsuccessfully,
                color: AppColors.primary,
              );
            } else if (state is AllowancesCreateSuccess) {
              context.read<AllowanceBloc>().add(const AllowancesList());

              flutterToastCustom(
                msg: AppLocalizations.of(context)!.createdsuccessfully,
                color: AppColors.primary,
              );
            } else if (state is AllowancesCreateError) {
              context.read<AllowanceBloc>().add(const AllowancesList());
              flutterToastCustom(msg: state.errorMessage);
            } else if (state is AllowancesDeleteSuccess) {
              context.read<AllowanceBloc>().add(const AllowancesList());
              flutterToastCustom(
                  msg: AppLocalizations.of(context)!.deletedsuccessfully,
                  color: AppColors.primary);
            } else if (state is AllowancesPaginated) {
              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (!state.hasReachedMax &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    context
                        .read<AllowanceBloc>()
                        .add(LoadMoreAllowances(searchWord));
                  }
                  return false;
                },
                child: state.Allowances.isNotEmpty
                    ? ListView.builder(
                        padding: EdgeInsets.only(bottom: 30.h),
                        shrinkWrap: true,
                        itemCount: state.hasReachedMax
                            ? state.Allowances.length
                            : state.Allowances.length + 1,
                        itemBuilder: (context, index) {
                          if (index < state.Allowances.length) {
                            final Allowances = state.Allowances[index];
                            return _AllowancesListContainer(
                              Allowances,
                              isLightTheme,
                              state.Allowances[index],
                              state.Allowances,
                              index,
                            );
                          } else {
                            return CircularProgressIndicatorCustom(
                              hasReachedMax: state.hasReachedMax,
                            );
                          }
                        },
                      )
                    : NoData(
                        isImage: true,
                      ),
              );
            } else if (state is AllowancesError) {
              context.read<AllowanceBloc>().add(const AllowancesList());
              flutterToastCustom(
                  msg:state.errorMessage,
                  color: AppColors.red);
            } else if (state is AllowancesSuccess) {
              return ListView.builder(
                padding: EdgeInsets.only(bottom: 30.h),
                shrinkWrap: true,
                itemCount: state.Allowances.length + 1,
                itemBuilder: (context, index) {
                  if (index < state.Allowances.length) {
                    final Allowances = state.Allowances[index];
                    return _AllowancesListContainer(
                      Allowances,
                      isLightTheme,
                      state.Allowances[index],
                      state.Allowances,
                      index,
                    );
                  } else {
                    return CircularProgressIndicatorCustom(
                      hasReachedMax: true,
                    );
                  }
                },
              );
            }
            return const Text("");
          },
        ),
      ),
    );
  }

  Widget _appbar(isLightTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: BackArrow(
        iSBackArrow: true,
        iscreatePermission: context.read<PermissionsBloc>().iscreateAllowance,
        title: AppLocalizations.of(context)!.allowances,
        isAdd: context.read<PermissionsBloc>().iscreateAllowance,
        onPress: () {
          _createEditAllowances(isLightTheme: isLightTheme, isCreate: true);
        },
      ),
    );
  }

  Future<void> _createEditAllowances({
    required bool isLightTheme,
    required bool isCreate,
    AllowanceModel? Allowances,
    AllowanceModel? AllowancesModel,
    int? id,
    String? title,
    String? desc,
  }) {
    // Initialize controllers for editing
    if (!isCreate && AllowancesModel != null) {
      titleController.text = AllowancesModel.title ?? "";
      amountController.text = AllowancesModel.amount
              ?.replaceAll(RegExp(r'[,.]'), '')
              .split('.')[0] ??
          "";
    } else {
      // Clear controllers for create mode
      titleController.clear();
      amountController.clear();
    }

    return showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Theme.of(context).colorScheme.backGroundColor,
                ),
                height: 360.h,
                child: Form(
                  key: _createAllowancesKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: BackArrow(
                          isBottomSheet: true,
                          iSBackArrow: false,
                          iscreatePermission:
                              context.read<PermissionsBloc>().iscreateAllowance,
                          title: isCreate
                              ? AppLocalizations.of(context)!.createallowances
                              : AppLocalizations.of(context)!.editallowances,
                        ),
                      ),
                      SizedBox(height: 15.h),
                      CustomTextFields(
                        title: AppLocalizations.of(context)!.title,
                        hinttext:
                            AppLocalizations.of(context)!.pleaseentertitle,
                        controller: titleController,
                        onSaved: (value) {},
                        onFieldSubmitted: (value) {},
                        isLightTheme: isLightTheme,
                        isRequired: true,
                      ),
                      SizedBox(height: 15.h),
                      CustomTextFields(
                        keyboardType: TextInputType.number,
                        title: AppLocalizations.of(context)!.amount,
                        hinttext:
                            AppLocalizations.of(context)!.pleaseenteramount,
                        controller: amountController,
                        currency: true,
                        onSaved: (value) {},
                        onFieldSubmitted: (value) {},
                        isLightTheme: isLightTheme,
                        isRequired: true,
                      ),
                      SizedBox(height: 15.h),
                      BlocBuilder<AllowanceBloc, AllowancesState>(
                        builder: (context, state) {
                          bool isLoading =
                              state is AllowancesEditSuccessLoading ||
                                  state is AllowancesCreateSuccessLoading;

                          return CreateCancelButtom(
                            isLoading: isLoading,
                            isCreate: isCreate,
                            onpressCreate: () {
                              if (_createAllowancesKey.currentState!
                                  .validate()) {
                                if (isCreate) {
                                  _onCreateAllowances();
                                } else {
                                  _onEditAllowances(id, title, desc);
                                }
                                // Navigator.pop(context);
                              }
                            },
                            onpressCancel: () {
                              Navigator.pop(context);
                              context
                                  .read<AllowanceBloc>()
                                  .add(const AllowancesList());
                            },
                          );
                        },
                      ),
                      // SizedBox(height: 15.h),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      titleController.clear();
      amountController.clear();
      perController.clear();
    });
  }

  Widget _AllowancesListContainer(
    AllowanceModel Allowances,
    bool isLightTheme,
    AllowanceModel AllowancesModel,
    List<AllowanceModel> AllowancesList,
    int index,
  ) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
        child: DismissibleCard(
          direction:
              context.read<PermissionsBloc>().isdeleteAllowance == true &&
                      context.read<PermissionsBloc>().iseditAllowance == true
                  ? DismissDirection.horizontal
                  : context.read<PermissionsBloc>().isdeleteAllowance == true
                      ? DismissDirection.endToStart
                      : context.read<PermissionsBloc>().iseditAllowance == true
                          ? DismissDirection.startToEnd
                          : DismissDirection.none,
          title: Allowances.id!.toString(),
          confirmDismiss: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart &&
                context.read<PermissionsBloc>().isdeleteAllowance == true) {
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
                print(
                    "About to return from confirmDismiss: ${result ?? false}");

                // If user confirmed deletion, handle it here instead of in onDismissed
                if (result == true) {
                  print("Handling deletion directly in confirmDismiss");
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      AllowancesList.removeAt(index);
                    });
                    _onDeleteAllowances(Allowances.id);
                  });
                  // Return false to prevent the dismissible from animating
                  return false;
                }

                return false; // Always return false since we handle deletion manually
              } catch (e) {
                print("Error in dialog: $e");
                return false;
              }
            } else if (direction == DismissDirection.startToEnd &&
                context.read<PermissionsBloc>().iseditAllowance == true) {
              _createEditAllowances(
                isLightTheme: isLightTheme,
                isCreate: false,
                Allowances: Allowances,
                AllowancesModel: AllowancesModel,
                id: Allowances.id,
                title: Allowances.title,
                desc: Allowances.amount,
              );
              return false;
            }
            return false;
          },
          dismissWidget: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                boxShadow: [
                  isLightTheme
                      ? MyThemes.lightThemeShadow
                      : MyThemes.darkThemeShadow,
                ],
                color: Theme.of(context).colorScheme.containerDark,
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 10.h,
                    horizontal: 20.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: "#${Allowances.id.toString()}",
                        size: 14.sp,
                        color: AppColors.greyColor,
                        fontWeight: FontWeight.w700,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      CustomText(
                        text: Allowances.title!,
                        size: 16.sp,
                        color: Theme.of(context).colorScheme.textClrChange,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      if (Allowances.amount?.toString().isNotEmpty ?? false)
                        currencyPosition == "before"
                            ? CustomText(
                                text: "$currency ${Allowances.amount!}",
                                size: 16.sp,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                                fontWeight: FontWeight.w600,
                              )
                            : CustomText(
                                text: "${Allowances.amount!} $currency ",
                                size: 16.sp,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                                fontWeight: FontWeight.w600,
                              ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          onDismissed: (DismissDirection direction) {
            if (direction == DismissDirection.endToStart &&
                context.read<PermissionsBloc>().isdeleteAllowance == true) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  AllowancesList.removeAt(index);
                });
                _onDeleteAllowances(Allowances.id);
              });
            }
          },
        ));
  }
}
