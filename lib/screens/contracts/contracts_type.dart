import 'dart:developer';
import '../../../src/generated/i18n/app_localizations.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/contracts/contracts_bloc.dart';
import 'package:taskify/bloc/contracts_type/contracts_type_event.dart';
import 'package:taskify/bloc/notes/notes_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/model/contract/contract_type_model.dart';
import 'package:taskify/screens/notes/widgets/notes_shimmer_widget.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import 'package:taskify/utils/widgets/custom_dimissible.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../bloc/contracts/contracts_event.dart';
import '../../bloc/contracts/contracts_state.dart';
import '../../bloc/contracts_type/contracts_type_bloc.dart';
import '../../bloc/contracts_type/contracts_type_state.dart';
import '../../bloc/languages/language_switcher_bloc.dart';
import '../../bloc/notes/notes_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../config/constants.dart';
import '../../data/localStorage/hive.dart';
import '../../utils/widgets/custom_text.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/circularprogress_indicator.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/search_pop_up.dart';
import '../../utils/widgets/toast_widget.dart';
import '../widgets/custom_cancel_create_button.dart';
import '../widgets/custom_textfields/custom_textfield.dart';
import '../widgets/search_field.dart';
import '../widgets/side_bar.dart';
import '../widgets/speech_to_text.dart';

class ContractTypeScreen extends StatefulWidget {
  const ContractTypeScreen({super.key});

  @override
  State<ContractTypeScreen> createState() => _ContractTypeScreenState();
}

class _ContractTypeScreenState extends State<ContractTypeScreen> {
  DateTime now = DateTime.now();
  final GlobalKey<FormState> _createNotesKey = GlobalKey<FormState>();
  TextEditingController typeController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  FocusNode? titleFocus, descFocus, startsFocus, endFocus = FocusNode();
  Future<void> _checkRtlLanguage() async {
    final languageCode = await HiveStorage().getLanguage();
    setState(() {
      isRtl =
          LanguageBloc.instance.isRtlLanguage(languageCode ?? defaultLanguage);
    });
  }

  bool isRtl = false;
  bool? isLoading = true;
  late SpeechToTextHelper speechHelper;
  bool isLoadingMore = false;
  String searchWord = "";
  final ValueNotifier<String> noteType = ValueNotifier<String>("text");

  bool dialogShown = false;
  String? drawing;

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);

  @override
  void initState() {
    super.initState();
    context.read<ContractBloc>().add(ContractList());

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
    _checkRtlLanguage();
    listenForPermissions();
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          context.read<ContractBloc>().add(SearchContract(result));
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
    typeController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _onCreateContracts() {
    if (typeController.text.isNotEmpty) {
      context
          .read<ContractTypeBloc>()
          .add(CreateContractType(type: typeController.text));

      final contractBloc = BlocProvider.of<ContractTypeBloc>(context);
      contractBloc.stream.listen((state) {
        if (state is ContractTypeCreateSuccess) {
          if (mounted) {
            FocusScope.of(context).unfocus();
            context.read<ContractBloc>().add(const ContractList());
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.createdsuccessfully,
                color: AppColors.primary);
          }
        }
        if (state is ContractTypeCreateError) {
          flutterToastCustom(msg: state.errorMessage);
        }
      });
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  void _onEditContract(id) async {
    if (typeController.text.isNotEmpty) {
      context
          .read<ContractTypeBloc>()
          .add(UpdateContractType(typeController.text, id));
      final contractBloc = BlocProvider.of<ContractBloc>(context);
      contractBloc.stream.listen((state) {
        if (state is ContractTypeEditSuccess) {
          if (mounted) {
            FocusScope.of(context).unfocus();
            context.read<ContractTypeBloc>().add(const ContractTypeList());
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.updatedsuccessfully,
                color: AppColors.primary);
          }
        }
        if (state is ContractTypeEditError) {
          // flutterToastCustom(msg: state.errorMessage);
        }
      });
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }
  // Navigator.pop(context);

  void _onDeleteContract(id) {
    context.read<ContractTypeBloc>().add(DeleteContractType(id));
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    BlocProvider.of<ContractBloc>(context).add(ContractList());
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
                                  context
                                      .read<ContractBloc>()
                                      .add(SearchContract(''));
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
                        context.read<ContractBloc>().add(SearchContract(value));
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
        child: BlocConsumer<ContractTypeBloc, ContractTypeState>(
          listener: (context, state) {
            if (state is ContractPaginated) {
              isLoadingMore = false;
              setState(() {});
            }
            if (state is ContractTypeCreateSuccess) {
              context.read<ContractTypeBloc>().add(const ContractTypeList());
              if (mounted) {
                Navigator.pop(context);
                // router.go('/notes');
                flutterToastCustom(
                    msg: AppLocalizations.of(context)!.createdsuccessfully,
                    color: AppColors.primary);
              }
            }
            if (state is ContractTypeCreateError) {
              flutterToastCustom(msg: state.errorMessage);
            }
          },
          builder: (context, state) {
            print("fj bdjzc nx $state");

            if (state is ContractTypeLoading) {
              // Show loading indicator when there's no notes
              return const NotesShimmer();
            } else if (state is ContractTypePaginated) {
              // Show notes list with pagination
              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (!state.hasReachedMax &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    context.read<NotesBloc>().add(LoadMoreNotes(searchWord));
                  }
                  return false;
                },
                child: state.ContractType.isNotEmpty
                    ? ListView.builder(
                        padding: EdgeInsets.only(bottom: 30.h),
                        shrinkWrap: true,
                        itemCount: state.hasReachedMax
                            ? state.ContractType.length
                            : state.ContractType.length + 1,
                        itemBuilder: (context, index) {
                          if (index < state.ContractType.length) {
                            final contract = state.ContractType[index];
                            return _contractListContainer(
                              contract,
                              isLightTheme,
                              state.ContractType[index],
                              state.ContractType,
                              index,
                            );
                          } else {
                            // Show a loading indicator when more notes are being loaded
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
            } else if (state is ContractTypeError) {
              // Show error message
              return Center(
                child: Text(
                  state.errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (state is ContractTypeDeleteSuccess) {
              // Show error message
              context.read<ContractTypeBloc>().add(const ContractTypeList());
              flutterToastCustom(
                  msg: AppLocalizations.of(context)!.deletedsuccessfully,
                  color: AppColors.primary);
            } else if (state is ContractTypeDeleteError) {
              // Show error message
              context.read<ContractTypeBloc>().add(const ContractTypeList());
              flutterToastCustom(msg: state.errorMessage, color: AppColors.red);
            } else if (state is ContractTypeSuccess) {
              // Show initial list of notes
              return ListView.builder(
                padding: EdgeInsets.only(bottom: 30.h),
                shrinkWrap: true,
                itemCount: state.ContractType.length +
                    1, // Add 1 for the loading indicator
                itemBuilder: (context, index) {
                  if (index < state.ContractType.length) {
                    final contract = state.ContractType[index];
                    return _contractListContainer(
                      contract,
                      isLightTheme,
                      state.ContractType[index],
                      state.ContractType,
                      index,
                    );
                  } else {
                    // Show a loading indicator when more notes are being loaded
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
        iscreatePermission: true,
        title: AppLocalizations.of(context)!.contracttype,
        isAdd: true,
        onPress: () {
          _createEditContract(isLightTheme: isLightTheme, isCreate: true);
        },
      ),
    );
  }

  Future<void> _createEditContract({
    isLightTheme,
    isCreate,
    contract,
    contractModel,
    int? id,
    title,
  }) {
    return showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          if (!isCreate) {
            typeController.text = title ?? "";
          }

          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: const [],
                borderRadius: BorderRadius.circular(25),
                color: Theme.of(context).colorScheme.backGroundColor,
              ),
              height: 240.h,
              child: Center(
                child: Form(
                  key: _createNotesKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: BackArrow(
                          iscreatePermission: true,
                          isBottomSheet: true,
                          title: isCreate == false
                              ? AppLocalizations.of(context)!.editcontract
                              : AppLocalizations.of(context)!.createcontract,
                          iSBackArrow: false,
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      CustomTextFields(
                        title: AppLocalizations.of(context)!.type,
                        hinttext: AppLocalizations.of(context)!.type,
                        controller: typeController,
                        onSaved: (value) {},
                        onFieldSubmitted: (value) {},
                        isLightTheme: isLightTheme,
                        isRequired: true,
                      ),
                      SizedBox(height: 15.h),
                      BlocBuilder<ContractTypeBloc, ContractTypeState>(
                          builder: (context, state) {
                        print("hnjkm $state");
                        if (state is ContractTypeEditSuccessLoading) {
                          return CreateCancelButtom(
                            isLoading: true,
                            isCreate: isCreate,
                            onpressCreate: isCreate == true
                                ? () async {
                                    _onCreateContracts();
                                  }
                                : () {
                                    FocusScope.of(context).unfocus();
                                    _onEditContract(
                                      id,
                                    );
                                    setState(() {
                                      context
                                          .read<ContractBloc>()
                                          .add(const ContractList());
                                    });
                                    Navigator.pop(context);
                                  },
                            onpressCancel: () {
                              Navigator.pop(context);
                            },
                          );
                        }
                        if (state is ContractTypeCreateSuccessLoading) {
                          return CreateCancelButtom(
                            isLoading: true,
                            isCreate: isCreate,
                            onpressCreate: isCreate == true
                                ? () async {
                                    _onCreateContracts();
                                  }
                                : () {
                                    _onEditContract(
                                      id,
                                    );
                                    setState(() {
                                      context
                                          .read<ContractBloc>()
                                          .add(const ContractList());
                                    });
                                    Navigator.pop(context);
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
                                  _onCreateContracts();
                                }
                              : () {
                                  _onEditContract(
                                    id,
                                  );
                                  setState(() {
                                    context
                                        .read<ContractTypeBloc>()
                                        .add(const ContractTypeList());
                                  });
                                  Navigator.pop(context);
                                },
                          onpressCancel: () {
                            Navigator.pop(context);
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).whenComplete(() {
      typeController.text = '';
    });
  }

  Widget _contractListContainer(
    ContractTypeModel contract,
    bool isLightTheme,
    ContractTypeModel contractModel,
    List<ContractTypeModel> contractList,
    int index,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
      child: DismissibleCard(
        title: contract.id!.toString(),
        confirmDismiss: (DismissDirection direction) async {
          print("confirmDismiss called with direction: $direction");

          if (direction == DismissDirection.endToStart) {
            // Right to left swipe (Delete action)
            print("Showing delete dialog for contract: ${contract.id}");

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
                    contractList.removeAt(index);
                  });
                  _onDeleteContract(contract.id);
                });
                // Return false to prevent the dismissible from animating
                return false;
              }

              return false; // Always return false since we handle deletion manually
            } catch (e) {
              print("Error in dialog: $e");
              return false;
            }
          } else if (direction == DismissDirection.startToEnd) {
            print("Edit action triggered for contract: ${contract.id}");
            print("hjgfbxv m ${contract.type}");

            _createEditContract(
              isLightTheme: isLightTheme,
              isCreate: false,
              contract: contract,
              contractModel: contractList,
              id: contract.id,
              title: contract.type,
            );

            return false; // Prevent dismiss for edit action
          }

          return false;
        },
        onDismissed: (DismissDirection direction) {
          log("onDismissed called with direction: $direction");
          log("rtfghyjk ${contract.id}");

          // This will only be called if `confirmDismiss` returned `true`
          if (direction == DismissDirection.endToStart) {
            log("Actually deleting contract: ${contract.id}");

            // Use post-frame callback to ensure the dismissible animation completes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                contractList.removeAt(index);
              });
              _onDeleteContract(contract.id);
            });
          }
        },
        dismissWidget: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: [
              isLightTheme
                  ? MyThemes.lightThemeShadow
                  : MyThemes.darkThemeShadow,
            ],
            border: Border.all(
              color: AppColors.colorDark[index % AppColors.colorDark.length],
              width: 0.5,
            ),
            color: isLightTheme
                ? AppColors.colorLight[index % AppColors.colorLight.length]
                : AppColors.darkContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: "#${contract.id.toString()}",
                  size: 14.sp,
                  color: AppColors.greyColor,
                  fontWeight: FontWeight.w700,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                CustomText(
                  text: contract.type!,
                  size: 18.sp,
                  color: Theme.of(context).colorScheme.textClrChange,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
