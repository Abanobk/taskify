import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:taskify/bloc/permissions/permissions_bloc.dart';
import 'package:taskify/bloc/taxes/tax_event.dart';
import 'package:taskify/bloc/taxes/tax_state.dart';
import 'dart:async';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/finance/tax/taxtype.dart';
import '../../../utils/widgets/notes_shimmer_widget.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import 'package:taskify/utils/widgets/custom_dimissible.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';

import '../../../bloc/setting/settings_bloc.dart';
import '../../../bloc/taxes/tax_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/internet_connectivity.dart';

import '../../../data/model/finance/tax_model.dart';
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
import '../../../../src/generated/i18n/app_localizations.dart';

class TaxScreen extends StatefulWidget {
  const TaxScreen({super.key});

  @override
  State<TaxScreen> createState() => _TaxScreenState();
}

class _TaxScreenState extends State<TaxScreen> {
  DateTime now = DateTime.now();
  final GlobalKey<FormState> _createTaxsKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController perController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  bool? isLoading = true;
  late SpeechToTextHelper speechHelper;
  bool isLoadingMore = false;
  String searchWord = "";

  late ValueNotifier<String> taxType = ValueNotifier<String>("");
  late ValueNotifier<String> taxTypeFilter = ValueNotifier<String>("");

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
    context.read<TaxBloc>().add(const TaxesList());
    taxType = ValueNotifier<String>(taxType.value.toLowerCase());

    currency = context.read<SettingsBloc>().currencySymbol;
    currencyPosition = context.read<SettingsBloc>().currencyPosition;
    filterType.value = false;
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          context.read<TaxBloc>().add(SearchTaxes(result, taxTypeFilter.value));
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
    taxType.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _onCreateTaxs() {
    if (titleController.text.isNotEmpty && taxType.value != "") {
      if (taxType.value == "amount" && amountController.text.trim().isEmpty) {
        flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
        );
        return;
      }
      if (taxType.value == "percentage" && valueInProgress == 0) {
        flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
        );
        return;
      }

      final newTax = TaxModel(
        title: titleController.text.trim(),
        type: taxType.value,
        amount: taxType.value == "amount" ? amountController.text.trim() : "",
        percentage: taxType.value == "percentage" ? valueInProgress.toInt() : 0,
      );

      context.read<TaxBloc>().add(AddTaxes(newTax));
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }


  void _onEditTaxs(id, title, desc) async {
    if (titleController.text.isNotEmpty) {
      final updatedNote = TaxModel(
          id: id,
          title: titleController.text,
          type: taxType.value ,
          amount: amountController.text.isNotEmpty ?amountController.text: "",
          percentage: valueInProgress.toInt() );

      context.read<TaxBloc>().add(UpdateTaxes(updatedNote));
      final todosBloc = BlocProvider.of<TaxBloc>(context);
      todosBloc.stream.listen((state) {
        if (state is TaxesEditSuccess) {
          if (mounted) {
            context.read<TaxBloc>().add(const TaxesList());
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.updatedsuccessfully,
                color: AppColors.primary);
          }
        }
        if (state is TaxesEditError) {
          flutterToastCustom(msg: state.errorMessage);
        }
      });
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  // Navigator.pop(context);

  void _onDeleteTaxs(Taxs) {
    context.read<TaxBloc>().add(DeleteTaxes(Taxs));
    final setting = context.read<TaxBloc>();
    setting.stream.listen((state) {
      if (state is TaxesDeleteSuccess) {
        if (mounted) {
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is TaxesDeleteError) {
        flutterToastCustom(msg: state.errorMessage);
      }
    });
    context.read<TaxBloc>().add(const TaxesList());
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    BlocProvider.of<TaxBloc>(context).add(TaxesList());
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
                                  // Optionally trigger the search event with an empty string
                                  context.read<TaxBloc>().add(
                                      SearchTaxes('', taxTypeFilter.value));
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
                          Stack(children: [
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
                                _filterDialog(context, isLightTheme);

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
                                //
                                // // Your existing filter dialog logic
                                // _filterDialog(context, isLightTheme);
                              },
                            ),

                            // BlocBuilder<FilterCountBloc, FilterCountState>(
                            //   builder: (context, state) {
                            //     return SizedBox(
                            //       width: 35.w,
                            //       child: Stack(
                            //         children: [
                            //           IconButton(
                            //             icon: HeroIcon(
                            //               HeroIcons.adjustmentsHorizontal,
                            //               style: HeroIconStyle.solid,
                            //               color: Theme.of(context)
                            //                   .colorScheme
                            //                   .textFieldColor,
                            //               size: 30.sp,
                            //             ),
                            //             onPressed: () {
                            //               BlocProvider.of<ClientBloc>(context)
                            //                   .add(ClientList());
                            //               BlocProvider.of<UserBloc>(context)
                            //                   .add(UserList());
                            //               BlocProvider.of<StatusMultiBloc>(context)
                            //                   .add(StatusMultiList());
                            //               BlocProvider.of<TagMultiBloc>(context)
                            //                   .add(TagMultiList());
                            //               BlocProvider.of<PriorityMultiBloc>(context)
                            //                   .add(PriorityMultiList());
                            //
                            //               // Your existing filter dialog logic
                            //               _filterDialog(context, isLightTheme);
                            //             },
                            //           ),
                            if (filterType.value == true)
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
                                    text: "1",
                                    color: Colors.white,
                                    size: 6,
                                    textAlign: TextAlign.center,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ])
                          //         ],
                          //       ),
                          //     );
                          //   },
                          // )
                        ],
                      ),
                      onChanged: (value) {
                        searchWord = value;
                        context
                            .read<TaxBloc>()
                            .add(SearchTaxes(value, taxTypeFilter.value));
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
        color: AppColors.primary, // Spinner color
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        onRefresh: _onRefresh,
        child: BlocConsumer<TaxBloc, TaxesState>(
          listener: (context, state) {
            if (state is TaxesPaginated) {
              isLoadingMore = false;
              setState(() {});
            }
            if (state is TaxesCreateSuccess) {
              context.read<TaxBloc>().add(const TaxesList());
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              flutterToastCustom(
                msg: AppLocalizations.of(context)!.createdsuccessfully,
                color: AppColors.primary,
              );
            } else if (state is TaxesCreateError) {
              context.read<TaxBloc>().add(const TaxesList());
              flutterToastCustom(msg: state.errorMessage);
            }
          },
          builder: (context, state) {
            if (state is TaxesLoading) {
              // Show loading indicator when there's no Taxs
              return const NotesShimmer();
            } else if (state is TaxesPaginated) {
              // Show Taxs list with pagination
              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (!state.hasReachedMax &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    context.read<TaxBloc>().add(LoadMoreTaxes(searchWord));
                  }
                  return false;
                },
                child: state.Taxes.isNotEmpty
                    ? ListView.builder(
                        padding: EdgeInsets.only(bottom: 30.h),
                        shrinkWrap: true,
                        itemCount: state.hasReachedMax
                            ? state.Taxes.length
                            : state.Taxes.length + 1,
                        itemBuilder: (context, index) {
                          if (index < state.Taxes.length) {
                            final Taxes = state.Taxes[index];
                            return _TaxsListContainer(
                              Taxes,
                              isLightTheme,
                              state.Taxes[index],
                              state.Taxes,
                              index,
                            );
                          } else {
                            // Show a loading indicator when more Taxs are being loaded
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
            } else if (state is TaxesError) {
              // Show error message
              return Center(
                child: Text(
                  state.errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (state is TaxesSuccess) {
              // Show initial list of Taxs
              return ListView.builder(
                padding: EdgeInsets.only(bottom: 30.h),
                shrinkWrap: true,
                itemCount:
                    state.Taxes.length + 1, // Add 1 for the loading indicator
                itemBuilder: (context, index) {
                  if (index < state.Taxes.length) {
                    final Taxes = state.Taxes[index];
                    return _TaxsListContainer(
                      Taxes,
                      isLightTheme,
                      state.Taxes[index],
                      state.Taxes,
                      index,
                    );
                  } else {
                    // Show a loading indicator when more Taxs are being loaded
                    return CircularProgressIndicatorCustom(
                      hasReachedMax: true,
                    );
                  }
                },
              );
            }
            // Handle other states
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
        iscreatePermission: context.read<PermissionsBloc>().iscreateTax,
        title: AppLocalizations.of(context)!.tax,
        isAdd: context.read<PermissionsBloc>().iscreateTax,
        onPress: () {
          _createEditTaxs(isLightTheme: isLightTheme, isCreate: true);
        },
      ),
    );
  }

  Future<void> _createEditTaxs({
    isLightTheme,
    isCreate,
    Taxs,
    TaxsModel,
    int? id,
    title,
    desc,
  }) {
    return showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        double _localSliderValue =
            valueInProgress; // 👈 use this for slider state inside modal
        if (!isCreate) {
          titleController.text = title ?? "";
          taxType.value = TaxsModel.type;
          amountController.text = TaxsModel.amount ?? "";
          if (TaxsModel.percentage != null) {
            _localSliderValue = TaxsModel.percentage.toDouble();
          }
        } else {}
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
                height: 385.h,
                child: Form(
                  key: _createTaxsKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 15.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: BackArrow(
                          isBottomSheet: true,
                          iscreatePermission:
                              context.read<PermissionsBloc>().iscreateTax,
                          title: isCreate == false
                              ? AppLocalizations.of(context)!.edittax
                              : AppLocalizations.of(context)!.createtax,
                          iSBackArrow: false,
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
                      TaxTypeField(
                        access: taxType.value,
                        isRequired: true,
                        isCreate: isCreate,
                        from: "type",
                        onSelected: (value) {
                          taxType.value = value.toLowerCase();
                        },
                      ),
                      SizedBox(height: 15.h),
                      ValueListenableBuilder<String>(
                        valueListenable: taxType,
                        builder: (context, value, _) {
                          if (value == "amount") {
                               return isCreate
                                ? CustomTextFields(
                              keyboardType: TextInputType.number,
                              title: AppLocalizations.of(context)!.amount,
                              subtitle: currency,
                              hinttext: AppLocalizations.of(context)!
                                  .pleaseenteramount,
                              controller: amountController,
                              readonly: isCreate == false ? true : false,
                              onSaved: (val) {},
                              onFieldSubmitted: (val) {},
                              isLightTheme: isLightTheme,
                              isRequired: true,
                            )
                                : Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.w),
                                  child: Row(
                                    children: [
                                      CustomText(
                                        text:
                                        AppLocalizations.of(context)!
                                            .amount,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textClrChange,
                                        size: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      Text(
                                        " *",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                                Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: (40.h) /
                                          4, // ✅ Ensures balanced padding
                                      horizontal: 10.w,
                                    ),
                                    height: 40.h,
                                    // Default to 40.h if height is not passed
                                    width: double.infinity,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: isCreate == true
                                          ? Colors.transparent
                                          : Theme.of(context)
                                          .colorScheme
                                          .textfieldDisabled,
                                      border:
                                      Border.all(color: Colors.grey),
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),
                                    child: CustomText(
                                      text: TaxsModel.amount ?? "",
                                      fontWeight: FontWeight.w400,
                                      size: 14.sp,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textClrChange,
                                    )),
                              ],
                            );

                          } else if (value == "percentage") {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.w),
                                  child: CustomText(
                                    text:
                                        AppLocalizations.of(context)!.percntage,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                    size: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Slider(
                                        value: _localSliderValue,
                                        min: 0,
                                        max: 100,
                                        divisions: 100,
                                        onChanged:isCreate
                                            ? (v) {
                                          setModalState(() {
                                            _localSliderValue = v;
                                            valueInProgress = v;
                                          });
                                        }
                                            : null,

                                        label: "${_localSliderValue.toInt()}%",
                                      ),
                                    ),
                                    CustomText(
                                      text: "${_localSliderValue.toInt()}%",
                                      size: 15.sp,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textClrChange,
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                ),
                              ],
                            );
                          } else {
                            return const SizedBox.shrink(); // fallback
                          }
                        },
                      ),
                      SizedBox(height: 15.h),
                      BlocBuilder<TaxBloc, TaxesState>(
                        builder: (context, state) {
                          bool isLoading = state is TaxesEditSuccessLoading ||
                              state is TaxesCreateSuccessLoading;

                          return CreateCancelButtom(
                            isLoading: isLoading,
                            isCreate: isCreate,
                            onpressCreate: () {
                              if (isCreate) {
                                _onCreateTaxs();
                              } else {
                                _onEditTaxs(id, title, desc);
                                context.read<TaxBloc>().add(const TaxesList());
                                Navigator.pop(context);
                              }
                            },
                            onpressCancel: () {
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                      SizedBox(height: 15.h),
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

  Widget _TaxsListContainer(
    TaxModel Taxs,
    bool isLightTheme,
    TaxModel TaxsModel,
    List<TaxModel> TaxsList,
    int index,
  ) {

    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
        child: DismissibleCard(
          direction: context.read<PermissionsBloc>().isdeleteTax == true &&
                  context.read<PermissionsBloc>().iseditTax == true
              ? DismissDirection.horizontal // Allow both directions
              : context.read<PermissionsBloc>().isdeleteTax == true
                  ? DismissDirection.endToStart // Allow delete
                  : context.read<PermissionsBloc>().iseditTax == true
                      ? DismissDirection.startToEnd // Allow edit
                      : DismissDirection.none,
          title: Taxs.id!.toString(),
          confirmDismiss: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart &&
                context.read<PermissionsBloc>().isdeleteTax == true) {
              // Right to left swipe (Delete action)
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
                      TaxsList.removeAt(index);

                    });
                    _onDeleteTaxs(Taxs.id);
                  });
                  // Return false to prevent the dismissible from animating
                  return false;
                }

                return false; // Always return false since we handle deletion manually
              } catch (e) {
                print("Error in dialog: $e");
                return false;
              } // Return the result of the dialog
            } else if (direction == DismissDirection.startToEnd &&
                context.read<PermissionsBloc>().iseditTax == true) {
              _createEditTaxs(
                isLightTheme: isLightTheme,
                isCreate: false,
                Taxs: Taxs,
                TaxsModel: TaxsModel,
                id: Taxs.id,
                title: Taxs.title,
                desc: Taxs.amount,
              );
              // Perform the edit action if needed
              return false; // Prevent dismiss
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
            // height: 140.h,
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
                        text: "#${Taxs.id.toString()}",
                        size: 14.sp,
                        color: AppColors.greyColor,
                        fontWeight: FontWeight.w700,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      CustomText(
                        text: Taxs.title!,
                        size: 16.sp,
                        color: Theme.of(context).colorScheme.textClrChange,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      if (Taxs.amount?.toString().isNotEmpty ?? false)
                        currencyPosition == "brfore"
                            ? CustomText(
                                text: "$currency ${Taxs.amount!}",
                                size: 16.sp,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                                fontWeight: FontWeight.w600,
                              )
                            : CustomText(
                                text: "${Taxs.amount!} $currency ",
                                size: 16.sp,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                                fontWeight: FontWeight.w600,
                              ),

                      // SizedBox(
                      //   height: 5.h,
                      // ),
                      if ((Taxs.percentage?.toString().isNotEmpty ?? false))
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  0), // Remove default horizontal padding
                          child: Container(
                            // color: AppColors.red,
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    0), // Also remove Container's padding
                            child: Row(
                              children: [
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                        trackHeight: 4,
                                        overlayShape:
                                            SliderComponentShape.noOverlay,
                                        trackShape:
                                            const RoundedRectSliderTrackShape(),
                                        thumbShape: const RoundSliderThumbShape(
                                            enabledThumbRadius: 6),
                                        thumbColor: AppColors.primary),
                                    child: Slider(
                                      value: Taxs.percentage!.toDouble(),
                                      min: 0,
                                      max: 100,
                                      divisions: 100,
                                      onChanged: (v) {},
                                      label: "${Taxs.percentage!.toInt()}%",
                                    ),
                                  ),
                                ),
                                CustomText(
                                  text: "${Taxs.percentage!.toInt()}%",
                                  size: 15.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        )

                      // Taxs.description != "" && Taxs.description != null ?   Container(
                      //   width: double.infinity,
                      //   padding: EdgeInsets.symmetric(horizontal: 12.w,vertical: 5.h),
                      //   decoration: BoxDecoration(
                      //       color: Theme.of(context).colorScheme.backGroundColor,
                      //       borderRadius: BorderRadius.circular(5)),
                      //   child: htmlWidget(Taxs.description!, context,
                      //       width: 290.w, height: 36.h),
                      // ):SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          onDismissed: (DismissDirection direction) {
            // This will not be called if `confirmDismiss` returned `false`
            if (direction == DismissDirection.endToStart &&
                context.read<PermissionsBloc>().isdeleteTax == true) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                TaxsList.removeAt(index);

              });
              _onDeleteTaxs(Taxs.id);
              });
            }
          },
        ));
  }

  void _filterDialog(BuildContext context, isLightTheme) {
    showModalBottomSheet(
        backgroundColor: Theme.of(context).colorScheme.containerDark,
        context: context,
        isScrollControlled:
            true, // Allows the bottom sheet to take the full height
        builder: (BuildContext context) {
          return Container(
              padding: EdgeInsets.all(16.w),
              child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Minimize the size of the bottom sheet
                  children: <Widget>[
                    SizedBox(height: 10),
                    CustomText(
                      text: AppLocalizations.of(context)!.selectfilter,
                      color: AppColors.primary,
                      size: 30.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 20),
                    TaxTypeField(
                      access: taxTypeFilter.value,
                      isRequired: true,
                      isCreate: false,
                      isFilter: true,
                      from: "type",
                      onSelected: (value) {
                        filterType.value = true;
                        taxTypeFilter.value = value.toLowerCase();
                      },
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 18.w, vertical: 10.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Apply Button
                          InkWell(
                            onTap: () {
                              context.read<TaxBloc>().add(
                                  SearchTaxes(searchWord, taxTypeFilter.value));
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 35.h,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15.w, vertical: 0.h),
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
                          // Clear Button
                          InkWell(
                            onTap: () {
                              setState(() {
                                Navigator.of(context).pop();
                                taxTypeFilter.value = "";
                                filterType.value = false;
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
                    ),
                    SizedBox(height: 20),
                  ]));
        });
  }
}
