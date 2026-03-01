import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:taskify/bloc/permissions/permissions_bloc.dart';
import 'dart:async';
import 'package:taskify/config/colors.dart';
import '../../../utils/widgets/notes_shimmer_widget.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import 'package:taskify/utils/widgets/custom_dimissible.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';

import '../../../bloc/items/item_bloc.dart';
import '../../../bloc/items/item_event.dart';
import '../../../bloc/items/item_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/internet_connectivity.dart';
import '../../../data/model/finance/estimate_invoices_model.dart';
import '../../../utils/widgets/circularprogress_indicator.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/search_pop_up.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../widgets/custom_textfields/custom_textfield.dart';
import '../../widgets/html_widget.dart';
import '../../widgets/search_field.dart';
import '../../widgets/side_bar.dart';
import '../../widgets/speech_to_text.dart';
import '../estimate_invoice/widgets/unit_list.dart';
import '../../../../src/generated/i18n/app_localizations.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  DateTime now = DateTime.now();
  final GlobalKey<FormState> _createItemsKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  FocusNode? titleFocus, descFocus, startsFocus, endFocus = FocusNode();

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  bool isRtl = false;
  bool? isLoading = true;
  late SpeechToTextHelper speechHelper;
  bool isLoadingMore = false;
  String searchWord = "";
  List<int> selectedUnitIdS = [];
  List<int> selectedUnitIdSFilter = [];

  List<String> selectedUnitName = [];
  List<String> selectedUnitNameFilter = [];
  final ValueNotifier<String> noteType = ValueNotifier<String>("text");
  final ValueNotifier<bool> filter = ValueNotifier<bool>(false);

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
    filter.value = false;
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          context.read<ItemsBloc>().add(SearchItems(
              result,
              selectedUnitIdSFilter.isNotEmpty
                  ? selectedUnitIdSFilter[0].toString()
                  : ''));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    BlocProvider.of<ItemsBloc>(context).add(ItemsList());

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void handleUnitSelected(List<String> category, List<int> catId, int itemID) {
    print("Selected unit for item $itemID: $catId $category");
    setState(() {
      selectedUnitName = category;
      selectedUnitIdS = catId;
      print(
          "Selected unit for item selectedUnitIdS $selectedUnitName: $selectedUnitIdS $category");
    });
  }

  void handleUnitSelectedFilter(
      List<String> category, List<int> catId, int itemID) {
    print("Selected unit for itemhf $itemID: $catId  $category");
    setState(() {
      selectedUnitNameFilter = category;
      selectedUnitIdSFilter = catId;
      filter.value = true;
    });
    print("f sef.hk dhf d ${selectedUnitNameFilter}");
    print("f sef.hk dhf d ${selectedUnitIdSFilter[0]}");
  }

  void _onCreateItems() {
    print("tyuio ${priceController.text}");
    if (titleController.text.isNotEmpty && priceController.text.isNotEmpty) {
      final newItem = InvoicesItems(
        title: titleController.text.toString(),
        description: descController.text.toString(),
        price: priceController.text,
        unitId: selectedUnitIdS[0].toString(),
      );

      context.read<ItemsBloc>().add(AddItems(newItem));
      print("kdhnzfvxm dwasd  ");
      final todosBloc = BlocProvider.of<ItemsBloc>(context);
      todosBloc.stream.listen((state) {
        if (state is ItemsCreateSuccess) {
          todosBloc.add(const ItemsList());
          if (mounted) {
            Navigator.pop(context);
            // router.go('/Items');
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.createdsuccessfully,
                color: AppColors.primary);
          }
        }
        if (state is ItemsCreateError) {
          flutterToastCustom(msg: state.errorMessage);
        }
      });
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  void _onEditItems(id, title, desc) async {
    if (titleController.text.isNotEmpty && priceController.text.isNotEmpty) {
      print("hkrteas ${selectedUnitIdS}");
      final updatedNote = InvoicesItems(
          id: id,
          title: titleController.text,
          price: priceController.text,
          description: descController.text,
          unitId: selectedUnitIdS[0].toString());

      context.read<ItemsBloc>().add(UpdateItems(updatedNote));
      final todosBloc = BlocProvider.of<ItemsBloc>(context);
      todosBloc.stream.listen((state) {
        if (state is ItemsEditSuccess) {
          if (mounted) {
            context.read<ItemsBloc>().add(const ItemsList());
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.updatedsuccessfully,
                color: AppColors.primary);
          }
        }
        if (state is ItemsEditError) {
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

  void _onDeleteItems(Items) {
    context.read<ItemsBloc>().add(DeleteItems(Items));
    final setting = context.read<ItemsBloc>();
    setting.stream.listen((state) {
      if (state is ItemsDeleteSuccess) {
        if (mounted) {
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is ItemsDeleteError) {
        flutterToastCustom(msg: state.errorMessage);
      }
    });
    context.read<ItemsBloc>().add(const ItemsList());
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    BlocProvider.of<ItemsBloc>(context).add(ItemsList());
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
                                  context.read<ItemsBloc>().add(SearchItems(
                                      '',
                                      selectedUnitIdSFilter.isNotEmpty
                                          ? selectedUnitIdSFilter[0].toString()
                                          : ''));
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
                            if (filter.value == true)
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
                          ]),
                        ],
                      ),
                      onChanged: (value) {
                        searchWord = value;
                        context.read<ItemsBloc>().add(SearchItems(
                            value,
                            selectedUnitIdSFilter.isNotEmpty
                                ? selectedUnitIdSFilter[0].toString()
                                : ''));
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
        child: BlocConsumer<ItemsBloc, ItemsState>(
          listener: (context, state) {
            if (state is ItemsPaginated) {
              isLoadingMore = false;
              setState(() {});
            }
          },
          builder: (context, state) {
            print("fj bdjzc nx $state");
            if (state is ItemsLoading) {
              // Show loading indicator when there's no Items
              return const NotesShimmer();
            } else if (state is ItemsPaginated) {
              // Show Items list with pagination
              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (!state.hasReachedMax &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    context.read<ItemsBloc>().add(LoadMoreItems(searchWord));
                  }
                  return false;
                },
                child: state.Items.isNotEmpty
                    ? ListView.builder(
                        padding: EdgeInsets.only(bottom: 30.h),
                        shrinkWrap: true,
                        itemCount: state.hasReachedMax
                            ? state.Items.length
                            : state.Items.length + 1,
                        itemBuilder: (context, index) {
                          if (index < state.Items.length) {
                            final Items = state.Items[index];
                            return _ItemsListContainer(
                              Items,
                              isLightTheme,
                              state.Items[index],
                              state.Items,
                              index,
                            );
                          } else {
                            // Show a loading indicator when more Items are being loaded
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
            } else if (state is ItemsError) {
              // Show error message
              return Center(
                child: Text(
                  state.errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (state is ItemsSuccess) {
              // Show initial list of Items
              return ListView.builder(
                padding: EdgeInsets.only(bottom: 30.h),
                shrinkWrap: true,
                itemCount:
                    state.Items.length + 1, // Add 1 for the loading indicator
                itemBuilder: (context, index) {
                  if (index < state.Items.length) {
                    final Items = state.Items[index];
                    return _ItemsListContainer(
                      Items,
                      isLightTheme,
                      state.Items[index],
                      state.Items,
                      index,
                    );
                  } else {
                    // Show a loading indicator when more Items are being loaded
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
        iscreatePermission: context.read<PermissionsBloc>().iscreateItem,
        title: AppLocalizations.of(context)!.items,
        isAdd: context.read<PermissionsBloc>().iscreateItem,
        onPress: () {
          _createEditItems(isLightTheme: isLightTheme, isCreate: true);
        },
      ),
    );
  }

  Future<void> _createEditItems({
    required bool isLightTheme,
    bool? isCreate,
    InvoicesItems? Items,
    InvoicesItems? ItemsModel,
    int? id,
    String? title,
    String? desc,
    String? unitId,
  }) {
    // Initialize controllers and lists
    titleController.text = title ?? '';
    descController.text = desc ?? '';
    priceController.text = ItemsModel?.price ?? '';

    // Initialize selected unit data
    if (!isCreate! && ItemsModel != null) {
      if (ItemsModel.unitName != null && ItemsModel.unitName!.isNotEmpty) {
        selectedUnitName = [ItemsModel.unitName!];
      } else {
        selectedUnitName = ['Select Unit'];
      }
      if (ItemsModel.unit != null && ItemsModel.unit!.id != null) {
        selectedUnitIdS = [ItemsModel.unit!.id!];
      } else {
        selectedUnitIdS = [0];
      }
    } else {
      selectedUnitName = ['Select Unit'];
      selectedUnitIdS = [0];
    }

    return showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // Local handler for unit selection
            void handleUnitSelectedLocal(
                List<String> category, List<int> catId, int itemID) {
              // Update parent state
              setState(() {
                selectedUnitName = category;
                selectedUnitIdS = catId;
              });
              // Update modal state to rebuild UnitListField
              setModalState(() {
                // This ensures the modal rebuilds with new unit data
              });
              print("Selected unit: $selectedUnitName, IDs: $selectedUnitIdS");
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: const [],
                  borderRadius: BorderRadius.circular(25),
                  color: Theme.of(context).colorScheme.backGroundColor,
                ),
                height: 520.h,
                child: Center(
                  child: Form(
                    key: _createItemsKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          child: BackArrow(
                            isBottomSheet: true,
                            iscreatePermission: true,
                            title: isCreate == true
                                ? AppLocalizations.of(context)!.createItems
                                : AppLocalizations.of(context)!.editItems,
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
                        UnitListField(
                          fromProfile: false,
                          ids: selectedUnitIdS.isNotEmpty
                              ? selectedUnitIdS
                              : [0],
                          isRequired: false,
                          itemId: selectedUnitIdS.isNotEmpty
                              ? selectedUnitIdS[0]
                              : 0,
                          isCreate: isCreate,
                          name: [
                            selectedUnitName.isNotEmpty &&
                                    selectedUnitName[0] != ''
                                ? selectedUnitName[0]
                                : 'Select Unit',
                          ],
                          onSelected:
                              handleUnitSelectedLocal, // Use local handler
                        ),
                        SizedBox(height: 15.h),
                        CustomTextFields(
                          title: AppLocalizations.of(context)!.price,
                          keyboardType: TextInputType.number,
                          hinttext:
                              AppLocalizations.of(context)!.pleaseenterprice,
                          controller: priceController,
                          onSaved: (value) {},
                          onFieldSubmitted: (value) {},
                          isLightTheme: isLightTheme,
                          isRequired: true,
                        ),
                        SizedBox(height: 15.h),
                        CustomTextFields(
                          height: 112.h,
                          keyboardType: TextInputType.multiline,
                          title: AppLocalizations.of(context)!.description,
                          hinttext: AppLocalizations.of(context)!
                              .pleaseenterdescription,
                          controller: descController,
                          onSaved: (value) {},
                          onFieldSubmitted: (value) {
                            _fieldFocusChange(context, descFocus!, startsFocus);
                          },
                          isLightTheme: isLightTheme,
                          isRequired: false,
                        ),
                        SizedBox(height: 15.h),
                        BlocBuilder<ItemsBloc, ItemsState>(
                          builder: (context, state) {
                            return CreateCancelButtom(
                              isLoading: state is ItemsEditSuccessLoading ||
                                  state is ItemsCreateSuccessLoading,
                              isCreate: isCreate,
                              onpressCreate: isCreate == true
                                  ? () async {
                                      _onCreateItems();
                                    }
                                  : () {
                                      _onEditItems(id, title, desc);
                                      setState(() {
                                        context
                                            .read<ItemsBloc>()
                                            .add(const ItemsList());
                                      });
                                      Navigator.pop(context);
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
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      titleController.clear();
      descController.clear();
      priceController.clear();
      selectedUnitName = ['Select Unit'];
      selectedUnitIdS = [0];
    });
  }


  Widget _ItemsListContainer(
    InvoicesItems Items,
    bool isLightTheme,
    InvoicesItems ItemsModel,
    List<InvoicesItems> ItemsList,
    int index,
  ) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
        child: DismissibleCard(
          direction: context.read<PermissionsBloc>().isdeleteItem == true &&
                  context.read<PermissionsBloc>().iseditItem == true
              ? DismissDirection.horizontal // Allow both directions
              : context.read<PermissionsBloc>().isdeleteItem == true
                  ? DismissDirection.endToStart // Allow delete
                  : context.read<PermissionsBloc>().iseditItem == true
                      ? DismissDirection.startToEnd // Allow edit
                      : DismissDirection.none,
          title: Items.id!.toString(),
          confirmDismiss: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart &&
                context.read<PermissionsBloc>().isdeleteItem == true) {
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
                      ItemsList.removeAt(index);
                    });
                    _onDeleteItems(Items.id);
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
                context.read<PermissionsBloc>().iseditItem == true) {
              _createEditItems(
                  isLightTheme: isLightTheme,
                  isCreate: false,
                  Items: Items,
                  ItemsModel: ItemsModel,
                  id: Items.id,
                  title: Items.title,
                  desc: Items.description,
                  unitId: Items.unitId);
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
                        text: Items.title!,
                        size: 16.sp,
                        color: Theme.of(context).colorScheme.textClrChange,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      htmlWidget(Items.description ?? "", context,
                          width: 290.w, height: 36.h),
                      SizedBox(
                        height: 5.h,
                      ),
                      //
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (Items.unitName != null &&
                              Items.unitName!.isNotEmpty)
                            CustomText(
                              text: "📦 ${Items.unitName}",
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                              size: 15.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          CustomText(
                            text: "💰 ${Items.price ?? ""}",
                            color: Theme.of(context).colorScheme.textClrChange,
                            size: 15.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          onDismissed: (DismissDirection direction) {
            // This will not be called if `confirmDismiss` returned `false`
            if (direction == DismissDirection.endToStart &&
                context.read<PermissionsBloc>().isdeleteItem == true) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  ItemsList.removeAt(index);
                });
                _onDeleteItems(Items.id);
              });
            }
          },
        ));
  }

  void _filterDialog(BuildContext context, isLightTheme) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.containerDark,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // Create a modified unit selection handler within the StatefulBuilder scope
            void handleUnitSelectedFilterLocal(
                List<String> category, List<int> catId, int itemID) {
              // Update both states - the parent's and the modal's
              setState(() {
                selectedUnitNameFilter = category;
                selectedUnitIdSFilter = catId;
                filter.value = true;
              });

              // Also update the modal's state to trigger a rebuild
              setModalState(() {
                // This empty setState will force the modal to rebuild with the new values
              });

              print("Selected unit: ${selectedUnitNameFilter}");
              print("Selected unit ID: ${selectedUnitIdSFilter[0]}");
            }

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
                  UnitListField(
                    fromProfile: false,
                    ids: selectedUnitIdSFilter.isEmpty
                        ? [0]
                        : selectedUnitIdSFilter,
                    isRequired: false,
                    itemId: selectedUnitIdSFilter.isNotEmpty
                        ? selectedUnitIdSFilter[0]
                        : 0,
                    isCreate: false,
                    name: [
                      selectedUnitNameFilter.isNotEmpty
                          ? selectedUnitNameFilter[0]
                          : "Select Unit",
                    ],
                    // Use the local handler that updates both states
                    onSelected: handleUnitSelectedFilterLocal,
                  ),
                  // Rest of your code remains the same
                  SizedBox(height: 20),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            context.read<ItemsBloc>().add(SearchItems(
                                searchWord,
                                selectedUnitIdSFilter.isNotEmpty
                                    ? selectedUnitIdSFilter[0].toString()
                                    : ''));
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
                        InkWell(
                          onTap: () {
                            setState(() {
                              selectedUnitIdSFilter = [];
                              selectedUnitNameFilter = [];
                              filter.value = false;
                            });
                            // Also update modal state
                            setModalState(() {});
                            Navigator.of(context).pop();
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
                ],
              ),
            );
          },
        );
      },
    );
  }
}
