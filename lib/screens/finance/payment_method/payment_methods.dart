import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/payment_method/payment_method_bloc.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/model/finance/payment_method_model.dart';
import 'package:taskify/screens/widgets/custom_cancel_create_button.dart';
import 'package:taskify/screens/widgets/custom_textfields/custom_textfield.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import 'package:taskify/screens/widgets/search_field.dart';
import 'package:taskify/screens/widgets/side_bar.dart';
import 'package:taskify/screens/widgets/speech_to_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../bloc/payment_method/payment_method_event.dart';
import '../../../bloc/payment_method/payment_method_state.dart';
import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/permissions/permissions_event.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/constants.dart';
import '../../../config/internet_connectivity.dart';
import '../../../utils/widgets/back_arrow.dart';
import '../../../utils/widgets/custom_dimissible.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/notes_shimmer_widget.dart';
import '../../../utils/widgets/search_pop_up.dart';
import '../../../utils/widgets/shake_widget.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../../../src/generated/i18n/app_localizations.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  String searchWord = "";
  bool? isLoading = true;
  bool isLoadingMore = false;
  String? selectedColorName;
  final Connectivity _connectivity = Connectivity();
  TextEditingController searchController = TextEditingController();
  late SpeechToTextHelper speechHelper;
  TextEditingController titleController = TextEditingController();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final GlobalKey<FormState> _createEditPaymentMethdKey =
      GlobalKey<FormState>();
  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);

  @override
  void initState() {
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results != "ConnectivityResult.none") {
        setState(() {
          _connectionStatus = results;
        });
        _initializeApp();
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results != "ConnectivityResult.none") {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
          _initializeApp();
        });
      }
    });
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          // context.read<ActivityLogBloc>().add(SearchActivityLog(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    super.initState();
  }
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    // also clean up if SpeechToTextHelper uses any resources
    super.dispose();
  }
  void _initializeApp() {
    searchController.addListener(() {
      setState(() {});
    });
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          context.read<PaymentMethodBloc>().add(SearchPaymentMethd(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();

    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
  }

  void _onEditPaymentMethd(id,  ) async {
    if (titleController.text.isNotEmpty ) {
      context.read<PaymentMethodBloc>().add(UpdatePaymentMethd(
            id: id,
            title: titleController.text,
          ));
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
    // Navigator.pop(context);
  }

  void _onCreatePaymentMethd() {
    print("eiojf[esoif ${titleController.text}");
    if (titleController.text.isNotEmpty) {
      context.read<PaymentMethodBloc>().add(CreatePaymentMethd(
            title: titleController.text.toString(),
          ));
    } else {
      flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleasefilltherequiredfield);
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    BlocProvider.of<PaymentMethodBloc>(context).add(PaymentMethdLists());
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
                    _appBar(isLightTheme),
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
                                  context
                                      .read<PaymentMethodBloc>()
                                      .add(SearchPaymentMethd(""));
                                },
                              ),
                            ),
                          IconButton(
                            icon: Icon(
                              !speechHelper.isListening
                                  ? Icons.mic_off
                                  : Icons.mic,
                              size: 20.sp,
                              color:
                                  Theme.of(context).colorScheme.textFieldColor,
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
                        ],
                      ),
                      onChanged: (value) {
                        searchWord = value;
                        context
                            .read<PaymentMethodBloc>()
                            .add(SearchPaymentMethd(value));
                      },
                    ),
                    SizedBox(height: 20.h),
                    _body(isLightTheme)
                  ],
                ),
              ),
            ));
  }

  Widget _appBar(isLightTheme) {
    bool? isCreate =  context.read<PermissionsBloc>().iscreatePaymentMethod;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: BackArrow(
        iSBackArrow: true,
        iscreatePermission: isCreate ?? false,
        title: AppLocalizations.of(context)!.paymentmethods,
        isAdd: isCreate ?? false,
        onPress: () {
          _createEditPaymentMethd(isLightTheme: isLightTheme, isCreate: true);
        },
      ),
    );
  }

  Widget _body(isLightTheme) {
    return Expanded(
        child: RefreshIndicator(
            color: AppColors.primary, // Spinner color
            backgroundColor: Theme.of(context).colorScheme.backGroundColor,
            onRefresh: _onRefresh,
            child: BlocConsumer<PaymentMethodBloc, PaymentMethdState>(
                listener: (context, state) {
              if (state is PaymentMethdSuccess) {
                isLoadingMore = false;
                setState(() {});
              }
            }, builder: (context, state) {
              print("sefzgzghz $state");
              if (state is PaymentMethdLoading) {
                return const NotesShimmer();
              }

              if (state is PaymentMethdEditSuccess) {
                flutterToastCustom(
                    msg: AppLocalizations.of(context)!.updatedsuccessfully,
                    color: AppColors.primary);
                Navigator.pop(context);
                BlocProvider.of<PaymentMethodBloc>(context)
                    .add(PaymentMethdLists());
              }  if (state is PaymentMethdDeleteSuccess) {
                flutterToastCustom(
                    msg: AppLocalizations.of(context)!.deletedsuccessfully,
                    color: AppColors.primary);
                BlocProvider.of<PaymentMethodBloc>(context)
                    .add(PaymentMethdLists());
              }
              if (state is PaymentMethdCreateSuccess) {
                flutterToastCustom(
                    msg: AppLocalizations.of(context)!.createdsuccessfully,
                    color: AppColors.primary);
                Navigator.pop(context);
                BlocProvider.of<PaymentMethodBloc>(context)
                    .add(PaymentMethdLists());
              } if (state is PaymentMethdError) {
                flutterToastCustom(
                    msg: state.errorMessage,
                    color: AppColors.red);

                BlocProvider.of<PaymentMethodBloc>(context)
                    .add(PaymentMethdLists());
              }
              if (state is PaymentMethdSuccess) {
                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (!state.isLoadingMore &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent &&
                        isLoadingMore == false) {
                      isLoadingMore = true;
                      setState(() {});
                      context
                          .read<PaymentMethodBloc>()
                          .add(PaymentMethdLoadMore(searchWord));
                    }
                    return false;
                  },
                  child: state.PaymentMethd.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          child: _PaymentMethdLists(
                            isLightTheme,
                            state.isLoadingMore,
                            state.PaymentMethd,
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          child: NoData(
                            isImage: true,
                          ),
                        ),
                );
              }
              if (state is PaymentMethdError) {
                flutterToastCustom(
                    msg: state.errorMessage, color: AppColors.primary);
              }
              if (state is PaymentMethdEditError) {
                BlocProvider.of<PaymentMethodBloc>(context)
                    .add(PaymentMethdLists());
                flutterToastCustom(
                    msg: state.errorMessage, color: AppColors.primary);
              }
              if (state is PaymentMethdCreateError) {
                BlocProvider.of<PaymentMethodBloc>(context)
                    .add(PaymentMethdLists());
                flutterToastCustom(
                    msg: state.errorMessage, color: AppColors.primary);
              }
              return SizedBox.shrink();
            })));
  }

  Widget _PaymentMethdLists(isLightTheme, hasReachedMax, PaymentMethdList) {
    if (PaymentMethdList.isEmpty) {
      return NoData(isImage: true);
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: hasReachedMax
          ? PaymentMethdList.length
          : PaymentMethdList.length + 1,
      itemBuilder: (context, index) {
        if (index < PaymentMethdList.length) {
          final status = PaymentMethdList[index];
          DateTime createdDate = parseDateStringFromApi(status.createdAt!);
          String dateCreated = dateFormatConfirmed(createdDate, context);

          return _PaymentMethdListContainer(
            status,
            isLightTheme,
            PaymentMethdList,
            index,
            dateCreated,
          );
        } else {
          // Loader item at the end
          return Center(
            child: SpinKitFadingCircle(
              color: AppColors.primary,
              size: 40.0,
            ),
          );
        }
      },
    );
  }

  Widget _PaymentMethdListContainer(
    PaymentMethodModel PaymentMethd,
    bool isLightTheme,
    List<PaymentMethodModel> PaymentMethdModel,
    int index,
    dateCreated,
  ) {
    return index == 0
        ? ShakeWidget(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 0.w),
                child: DismissibleCard(
                  direction: context.read<PermissionsBloc>().isdeletePaymentMethod == true &&
                      context.read<PermissionsBloc>().iseditPaymentMethod == true
                      ? DismissDirection.horizontal // Allow both directions
                      : context.read<PermissionsBloc>().isdeletePaymentMethod == true
                      ? DismissDirection.endToStart // Allow delete
                      : context.read<PermissionsBloc>().iseditPaymentMethod == true
                      ? DismissDirection.startToEnd // Allow edit
                      : DismissDirection.none,
                  title: PaymentMethd.id!.toString(),
                  confirmDismiss: (DismissDirection direction) async {
                    if (direction == DismissDirection.endToStart) {
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
                              PaymentMethdModel.removeAt(index);

                            });
                            context
                                .read<PaymentMethodBloc>()
                                .add(DeletePaymentMethd(PaymentMethd.id!));                          });
                          // Return false to prevent the dismissible from animating
                          return false;
                        }

                        return false; // Always return false since we handle deletion manually
                      } catch (e) {
                        print("Error in dialog: $e");
                        return false;
                      } // Return the result of the dialog
                    }
                    else if (direction == DismissDirection.startToEnd) {
                      if (context.read<PermissionsBloc>().iseditPaymentMethod == true) {
                        _createEditPaymentMethd(
                          isLightTheme: isLightTheme,
                          isCreate: false,
                          id: PaymentMethd.id,
                          title: PaymentMethd.title,
                        );
                        // Prevent the widget from being dismissed
                        return false;
                      } else {
                        // No edit permission, prevent swipe
                        return false;
                      }
               // Prevent dismiss
                    }
                    // flutterToastCustom(
                    //     msg: AppLocalizations.of(context)!.isDemooperation);
                    return false; // Default case
                  },
                  dismissWidget: _PaymentMethdCard(isLightTheme, PaymentMethd),
                  onDismissed: (DismissDirection direction ) {
                    // This will not be called if `confirmDismiss` returned `false`
                    if (direction == DismissDirection.endToStart &&   context.read<PermissionsBloc>().isdeletePaymentMethod == true) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          PaymentMethdModel.removeAt(index);


                          // _onDeleteTodos(status);
                        });
                        context
                            .read<PaymentMethodBloc>()
                            .add(DeletePaymentMethd(PaymentMethd.id!));
                      });
                    }
                  },
                )),
          )
        : Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 0.w),
            child: DismissibleCard(
              title: PaymentMethd.id!.toString(),
              confirmDismiss: (DismissDirection direction) async {
                if (direction == DismissDirection.endToStart) {
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
                          PaymentMethdModel.removeAt(index);

                        });
                        context
                            .read<PaymentMethodBloc>()
                            .add(DeletePaymentMethd(PaymentMethd.id!));                      });
                      // Return false to prevent the dismissible from animating
                      return false;
                    }

                    return false; // Always return false since we handle deletion manually
                  } catch (e) {
                    print("Error in dialog: $e");
                    return false;
                  } // Return the result of the dialog
                } else if (direction == DismissDirection.startToEnd) {
                  _createEditPaymentMethd(
                    isLightTheme: isLightTheme,
                    isCreate: false,
                    id: PaymentMethd.id,
                    title: PaymentMethd.title,
                  );
                  return false; // Prevent dismiss
                }
                return false; // Default case
              },
              dismissWidget: _PaymentMethdCard(
                isLightTheme,
                PaymentMethd,
              ),
              onDismissed: (DismissDirection direction) {
                // This will not be called if `confirmDismiss` returned `false`
                if (direction == DismissDirection.endToStart) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    PaymentMethdModel.removeAt(index);


                    // _onDeleteTodos(status);
                  });
                  context
                      .read<PaymentMethodBloc>()
                      .add(DeletePaymentMethd(PaymentMethd.id!));
                  });
                }
              },
            ));
  }

  Widget _PaymentMethdCard(
    isLightTheme,
    status,
  ) {
    String dateCreated = formatDateFromApi(status.createdAt!, context);
    // String  dateUpdated = formatDateFromApi(status.updatedAt!, context);

    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
          ],
          color: Theme.of(context).colorScheme.containerDark,
          borderRadius: BorderRadius.circular(12)),
      // height: 100.h,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.h),
            child: SizedBox(
              width: double.infinity,
              // color: Colors.red,
              // height: 70.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "#${status.id.toString()}",
                    size: 14.sp,
                    color: Theme.of(context).colorScheme.textClrChange,
                    fontWeight: FontWeight.w700,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  CustomText(
                    text: status.title!,
                    size: 16.sp,
                    color: Theme.of(context).colorScheme.textClrChange,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.backGroundColor,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 5.h),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CustomText(
                          text:
                              "📅 ${AppLocalizations.of(context)!.createdat} : ",
                          size: 13.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w600,
                        ),
                        CustomText(
                          text: dateCreated,
                          size: 12.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _createEditPaymentMethd(
      {isLightTheme, isCreate, int? id, title}) {
    if (isCreate) {
      titleController.text = '';
    } else {
      titleController.text = title;
    }
    return showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(// This ensures the modal content updates
              builder: (context, setState) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 600.h,
              ),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: const [],
                  borderRadius: BorderRadius.circular(25),
                  color: Theme.of(context).colorScheme.backGroundColor,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Form(
                    key: _createEditPaymentMethdKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          child: BackArrow(
                            title: isCreate == false
                                ? AppLocalizations.of(context)!
                                    .editpaymentmethod
                                : AppLocalizations.of(context)!
                                    .createpaymentmethod,
                            iSBackArrow: false,
                            iscreatePermission: true,
                            onPress: () {
                              print("dgfkgv ");
                              _createEditPaymentMethd(
                                  isLightTheme: isLightTheme, isCreate: true);
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
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
                        SizedBox(
                          height: 25.h,
                        ),
                        BlocBuilder<PaymentMethodBloc, PaymentMethdState>(
                            builder: (context, state) {
                          if (state is PaymentMethdEditSuccessLoading) {
                            return CreateCancelButtom(
                              isLoading: true,
                              isCreate: isCreate,
                              onpressCreate: isCreate == true
                                  ? () async {}
                                  : () {
                                      _onEditPaymentMethd(id);
                                      // context.read<TodosBloc>().add(const TodosList());
                                      // Navigator.pop(context);
                                    },
                              onpressCancel: () {
                                Navigator.pop(context);
                              },
                            );
                          }
                          if (state is PaymentMethdCreateSuccessLoading) {
                            return CreateCancelButtom(
                              isLoading: true,
                              isCreate: isCreate,
                              onpressCreate: isCreate == true
                                  ? () async {
                                      _onCreatePaymentMethd();
                                    }
                                  : () {
                                      _onEditPaymentMethd(id);
                                      // context.read<TodosBloc>().add(const TodosList());
                                      // Navigator.pop(context);
                                    },
                              onpressCancel: () {
                                Navigator.pop(context);
                              },
                            );
                          }
                          return CreateCancelButtom(
                            isCreate: isCreate,
                            onpressCreate: isCreate == true
                                ? () async {
                                    _onCreatePaymentMethd();
                                  }
                                : () {
                                    _onEditPaymentMethd(id);
                                    // context.read<TodosBloc>().add(const TodosList());
                                    // Navigator.pop(context);
                                  },
                            onpressCancel: () {
                              Navigator.pop(context);
                            },
                          );
                        }),
                        SizedBox(
                          height: 15.h,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }
}
