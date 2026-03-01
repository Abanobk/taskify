import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:taskify/config/colors.dart';
import '../../../utils/widgets/notes_shimmer_widget.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import 'package:taskify/utils/widgets/custom_dimissible.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';

import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/units/unit_bloc.dart';
import '../../../bloc/units/unit_event.dart';
import '../../../bloc/units/unit_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/internet_connectivity.dart';
import '../../../data/model/finance/unitd_model.dart';
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

import '../../../../src/generated/i18n/app_localizations.dart';

class UnitsScreen extends StatefulWidget {
  const UnitsScreen({super.key});

  @override
  State<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  DateTime now = DateTime.now();
  final GlobalKey<FormState> _createUnitsKey = GlobalKey<FormState>();
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
          context.read<UnitBloc>().add(SearchUnits(result));
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
    descController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _onCreateUnits() {

    if (titleController.text.isNotEmpty) {

      final newUnit = UnitModel(
        title: titleController.text.toString(),
        description: descController.text.toString() ,
      );

      context.read<UnitBloc>().add(AddUnits(newUnit));
      print("kdhnzfvxm dwasd  ");
      final todosBloc = BlocProvider.of<UnitBloc>(context);
      todosBloc.stream.listen((state) {
        if (state is UnitsCreateSuccess) {
          todosBloc.add(const UnitsList());
          if (mounted) {
            Navigator.pop(context);
            // router.go('/Units');
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.createdsuccessfully,
                color: AppColors.primary);
          }
        }
        if (state is UnitsCreateError) {
          flutterToastCustom(msg: state.errorMessage);
        }
      });
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  void _onEditUnits(id, title, desc) async {
    if (titleController.text.isNotEmpty) {
      final updatedNote = UnitModel(
          id: id,
          title: titleController.text,
          description: descController.text,

      );

      context.read<UnitBloc>().add(UpdateUnits(updatedNote));
      final todosBloc = BlocProvider.of<UnitBloc>(context);
      todosBloc.stream.listen((state) {
        if (state is UnitsEditSuccess) {
          if (mounted) {
            context.read<UnitBloc>().add(const UnitsList());
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.updatedsuccessfully,
                color: AppColors.primary);
          }
        }
        if (state is UnitsEditError) {
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

  void _onDeleteUnits(Units) {
    context.read<UnitBloc>().add(DeleteUnits(Units));
    final setting = context.read<UnitBloc>();
    setting.stream.listen((state) {
      if (state is UnitsDeleteSuccess) {
        if (mounted) {
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is UnitsDeleteError) {
        flutterToastCustom(msg: state.errorMessage);
      }
    });
    context.read<UnitBloc>().add(const UnitsList());
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    BlocProvider.of<UnitBloc>(context).add(UnitsList());
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
                                  .read<UnitBloc>()
                                  .add(SearchUnits(''));
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
                    context.read<UnitBloc>().add(SearchUnits(value));
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
        child: BlocConsumer<UnitBloc, UnitsState>(
          listener: (context, state) {
            if (state is UnitsPaginated) {
              isLoadingMore = false;
              setState(() {});
            }
          },
          builder: (context, state) {
            print("fj bdjzc nx $state");
            if (state is UnitsLoading) {
              // Show loading indicator when there's no Units
              return const NotesShimmer();
            } else if (state is UnitsPaginated) {
              // Show Units list with pagination
              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (!state.hasReachedMax &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    context.read<UnitBloc>().add(LoadMoreUnits(searchWord));
                  }
                  return false;
                },
                child: state.Units.isNotEmpty
                    ? ListView.builder(
                  padding: EdgeInsets.only(bottom: 30.h),
                  shrinkWrap: true,
                  itemCount: state.hasReachedMax
                      ? state.Units.length
                      : state.Units.length + 1,
                  itemBuilder: (context, index) {
                    if (index < state.Units.length) {
                      final Units = state.Units[index];
                      return _UnitsListContainer(
                        Units,
                        isLightTheme,
                        state.Units[index],
                        state.Units,
                        index,
                      );
                    } else {
                      // Show a loading indicator when more Units are being loaded
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
            } else if (state is UnitsError) {
              // Show error message
              return Center(
                child: Text(
                  state.errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (state is UnitsSuccess) {
              // Show initial list of Units
              return ListView.builder(
                padding: EdgeInsets.only(bottom: 30.h),
                shrinkWrap: true,
                itemCount:
                state.Units.length + 1, // Add 1 for the loading indicator
                itemBuilder: (context, index) {
                  if (index < state.Units.length) {
                    final Units = state.Units[index];
                    return _UnitsListContainer(
                      Units,
                      isLightTheme,
                      state.Units[index],
                      state.Units,
                      index,
                    );
                  } else {
                    // Show a loading indicator when more Units are being loaded
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
        title: AppLocalizations.of(context)!.units,
        isAdd: true,
        onPress: () {
          _createEditUnits(isLightTheme: isLightTheme, isCreate: true);
        },
      ),
    );
  }

  Future<void> _createEditUnits(
      {isLightTheme, isCreate, Units, UnitsModel,
        int? id, title, desc,}) {
    return showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {

          // if (!isCreate) {
            titleController.text = title ?? "";
            titleController.text = title ?? "";
            descController.text = desc ?? "";




          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: const [],
                borderRadius: BorderRadius.circular(25),
                color: Theme.of(context).colorScheme.backGroundColor,
              ),
              height: 350.h,
              child: Center(
                child: Form(
                  key: _createUnitsKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: BackArrow(
                          isBottomSheet: true,
                          iscreatePermission: context.read<PermissionsBloc>().isdeleteUnit == true,
                          title: isCreate == false
                              ? AppLocalizations.of(context)!.edituser
                              : AppLocalizations.of(context)!.createunits,
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
                      CustomTextFields(
                        height: 112.h,
                        keyboardType: TextInputType.multiline,
                        title: AppLocalizations.of(context)!.description,
                        hinttext: AppLocalizations.of(context)!
                            .pleaseenterdescription,
                        controller: descController,
                        onSaved: (value) {},
                        onFieldSubmitted: (value) {
                          _fieldFocusChange(
                            context,
                            descFocus!,
                            startsFocus,
                          );
                        },
                        isLightTheme: isLightTheme,
                        isRequired: false,
                      ),
                      SizedBox(height: 15.h),
                      BlocBuilder<UnitBloc, UnitsState>(
                          builder: (context, state) {
                            if (state is UnitsEditSuccessLoading) {
                              return CreateCancelButtom(
                                isLoading: true,
                                isCreate: isCreate,
                                onpressCreate: isCreate == true
                                    ? () async {
                                  _onCreateUnits();
                                }
                                    : () {
                                  _onEditUnits(id, title, desc);
                                  setState(() {
                                    context
                                        .read<UnitBloc>()
                                        .add(const UnitsList());
                                  });
                                  Navigator.pop(context);
                                },
                                onpressCancel: () {
                                  Navigator.pop(context);
                                },
                              );
                            }
                            if (state is UnitsCreateSuccessLoading) {
                              return CreateCancelButtom(
                                isLoading: true,
                                isCreate: isCreate,
                                onpressCreate: isCreate == true
                                    ? () async {
                                  _onCreateUnits();
                                }
                                    : () {
                                  _onEditUnits(id, title, desc);
                                  setState(() {
                                    context
                                        .read<UnitBloc>()
                                        .add(const UnitsList());
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
                                _onCreateUnits();
                              }
                                  : () {
                                _onEditUnits(id, title, desc);
                                setState(() {
                                  context
                                      .read<UnitBloc>()
                                      .add(const UnitsList());
                                });
                                Navigator.pop(context);
                              },
                              onpressCancel: () {
                                Navigator.pop(context);
                              },
                            );
                          }),
                      SizedBox(height: 15.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).whenComplete(() {
      titleController.text = '';
      descController.text = '';
      priceController.text = '';
    });
  }

  Widget _UnitsListContainer(
      UnitModel Units,
      bool isLightTheme,
      UnitModel UnitsModel,
      List <UnitModel> UnitsList,
      int index,
      ) {


    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
        child: DismissibleCard(
          direction: context.read<PermissionsBloc>().isdeleteUnit == true &&
              context.read<PermissionsBloc>().iseditUnit == true
              ? DismissDirection.horizontal // Allow both directions
              : context.read<PermissionsBloc>().isdeleteUnit == true
              ? DismissDirection.endToStart // Allow delete
              : context.read<PermissionsBloc>().iseditUnit == true
              ? DismissDirection.startToEnd // Allow edit
              : DismissDirection.none,
          title: Units.id!.toString(),
          confirmDismiss: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart&& context.read<PermissionsBloc>().isdeleteUnit== true)
            {
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
                      UnitsList.removeAt(index);

                    });
                    _onDeleteUnits(Units.id);                  });
                  // Return false to prevent the dismissible from animating
                  return false;
                }

                return false; // Always return false since we handle deletion manually
              } catch (e) {
                print("Error in dialog: $e");
                return false;
              }// Return the result of the dialog
            } else if (direction == DismissDirection.startToEnd && context.read<PermissionsBloc>().iseditTax == true) {

              _createEditUnits(
                  isLightTheme: isLightTheme,
                  isCreate: false,
                  Units: Units,
                  UnitsModel: UnitsModel,
                  id: Units.id,
                  title: Units.title,
                  desc: Units.description,

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
                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.h, ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: "#${Units.id.toString()}",
                        size: 14.sp,
                        color:AppColors.greyColor,
                        fontWeight: FontWeight.w700,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      CustomText(
                        text: Units.title!,
                        size: 16.sp,
                        color: Theme.of(context).colorScheme.textClrChange,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Units.description != "" && Units.description != null ?   Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 12.w,vertical: 5.h),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.backGroundColor,
                            borderRadius: BorderRadius.circular(5)),
                        child: htmlWidget(Units.description!, context,
                            width: 290.w, height: 36.h),
                      ):SizedBox(),

                    ],
                  ),
                ),

              ],
            ),
          ),
          onDismissed: (DismissDirection direction) {
            // This will not be called if `confirmDismiss` returned `false`
            if (direction == DismissDirection.endToStart && context.read<PermissionsBloc>().isdeleteUnit== true) {
    WidgetsBinding.instance.addPostFrameCallback((_) {   setState(() {
                UnitsList.removeAt(index);

              });
    _onDeleteUnits(Units.id);
              });
            }
          },
        ));
  }
}
