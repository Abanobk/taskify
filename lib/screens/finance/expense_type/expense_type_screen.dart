import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/expense_type/expense_type_event.dart';
import 'package:taskify/bloc/expense_type/expense_type_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/model/finance/expense_type_model.dart';
import 'package:taskify/screens/widgets/custom_cancel_create_button.dart';
import 'package:taskify/screens/widgets/custom_textfields/custom_textfield.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import 'package:taskify/screens/widgets/search_field.dart';
import 'package:taskify/screens/widgets/side_bar.dart';
import 'package:taskify/screens/widgets/speech_to_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../bloc/expense_type/expense_type_bloc.dart';
import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/permissions/permissions_event.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/constants.dart';
import '../../../config/internet_connectivity.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/back_arrow.dart';
import '../../../utils/widgets/custom_dimissible.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/notes_shimmer_widget.dart';
import '../../../utils/widgets/search_pop_up.dart';
import '../../../utils/widgets/shake_widget.dart';
import '../../../utils/widgets/toast_widget.dart';

class ExpenseTypeScreen extends StatefulWidget {
  const ExpenseTypeScreen({super.key});

  @override
  State<ExpenseTypeScreen> createState() => _ExpenseTypeScreenState();
}

class _ExpenseTypeScreenState extends State<ExpenseTypeScreen> {
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
  TextEditingController descController = TextEditingController();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final GlobalKey<FormState> _createEditexpenseTypeKey = GlobalKey<FormState>();
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
    BlocProvider.of<ExpenseTypeBloc>(context).add(ExpenseTypeLists());
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
          context.read<ExpenseTypeBloc>().add(SearchExpenseType(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();

    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
  }
  void _onEditexpenseType(id, title, desc) async {
    if (titleController.text.isNotEmpty) {
      print("tryui $title");
      context.read<ExpenseTypeBloc>().add(UpdateExpenseType(
        id: id, title: titleController.text.isEmpty?title:titleController.text, desc: descController.text.isEmpty?desc:descController.text,));
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
    // Navigator.pop(context);
  }
  void _onCreateexpenseType() {
    if (titleController.text.isNotEmpty) {
      context.read<ExpenseTypeBloc>().add(CreateExpenseType(
        title: titleController.text.toString(),
        desc: descController.text.isNotEmpty ? descController.text:"",
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

    BlocProvider.of<ExpenseTypeBloc>(context).add(ExpenseTypeLists());
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
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .backGroundColor,
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
                              color: Theme
                                  .of(context)
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
                                  .read<ExpenseTypeBloc>()
                                  .add(SearchExpenseType(""));
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
                          Theme
                              .of(context)
                              .colorScheme
                              .textFieldColor,
                        ),
                        onPressed: () {
                          if (speechHelper.isListening) {
                            speechHelper.stopListening();
                          } else {
                            speechHelper.startListening(context,
                                searchController, SearchPopUp());
                          }
                        },
                      ),
                    ],
                  ),
                  onChanged: (value) {
                    searchWord = value;
                    context
                        .read<ExpenseTypeBloc>()
                        .add(SearchExpenseType(value));
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: BackArrow(
        iSBackArrow: true,
        iscreatePermission: true,
        title: AppLocalizations.of(context)!.expensetype,
        isAdd: true,
        onPress: () {
          _createEditexpenseType(isLightTheme: isLightTheme, isCreate: true);

        },
      ),
    );
  }

  Widget _body(isLightTheme) {
    return Expanded(
        child: RefreshIndicator(
            color: AppColors.primary, // Spinner color
            backgroundColor: Theme
                .of(context)
                .colorScheme
                .backGroundColor,
            onRefresh: _onRefresh,
            child: BlocConsumer<ExpenseTypeBloc, ExpenseTypeState>(
                listener: (context, state) {
                  if (state is ExpenseTypeSuccess) {
                    isLoadingMore = false;
                    setState(() {});
                  }  if (state is ExpenseTypeDeleteSuccess) {

                    flutterToastCustom(
                        msg: AppLocalizations.of(context)!.deletedsuccessfully,
                        color: AppColors.red);
                    BlocProvider.of<ExpenseTypeBloc>(context).add(ExpenseTypeLists());
                  } if (state is ExpenseTypeDeleteError) {

                    flutterToastCustom(
                        msg: AppLocalizations.of(context)!.deletedsuccessfully,
                        color: AppColors.red);
                    BlocProvider.of<ExpenseTypeBloc>(context).add(ExpenseTypeLists());
                  }if (state is ExpenseTypeError) {

                    flutterToastCustom(
                        msg: AppLocalizations.of(context)!.deletedsuccessfully,
                        color: AppColors.red);
                    BlocProvider.of<ExpenseTypeBloc>(context).add(ExpenseTypeLists());
                  }
                },
                builder: (context, state) {
                  print("sefzgzghz $state");
                  if (state is ExpenseTypeLoading) {
                    return const NotesShimmer();
                  }if (state is ExpenseTypeEditSuccess) {
                    flutterToastCustom(
                        msg: AppLocalizations.of(context)!.updatedsuccessfully,
                        color: AppColors.primary);
                    Navigator.pop(context);
                    BlocProvider.of<ExpenseTypeBloc>(context).add(ExpenseTypeLists());

                  }
                  if (state is ExpenseTypeCreateSuccess) {
                    flutterToastCustom(
                        msg: AppLocalizations.of(context)!.createdsuccessfully,
                        color: AppColors.primary);
                    Navigator.pop(context);
                    BlocProvider.of<ExpenseTypeBloc>(context).add(ExpenseTypeLists());

                  }
                  if (state is ExpenseTypeSuccess) {
                    return NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        if (!state.isLoadingMore &&
                            scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent &&
                            isLoadingMore == false) {
                          isLoadingMore = true;
                          setState(() {});
                          context
                              .read<ExpenseTypeBloc>()
                              .add(ExpenseTypeLoadMore(searchWord));
                        }
                        return false;
                      },
                      child: state.ExpenseType.isNotEmpty
                          ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                            child: _expenseTypeLists(
                                                    isLightTheme,
                                                    state.isLoadingMore,
                                                    state.ExpenseType,
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
                  if(state is ExpenseTypeError){
                    flutterToastCustom(
                        msg: state.errorMessage,
                        color: AppColors.primary);
                  }
                  if(state is ExpenseTypeEditError){
                    BlocProvider.of<ExpenseTypeBloc>(context).add(ExpenseTypeLists());
                    flutterToastCustom(
                        msg: state.errorMessage,
                        color: AppColors.primary);
                  }   if(state is ExpenseTypeCreateError){
                    BlocProvider.of<ExpenseTypeBloc>(context).add(ExpenseTypeLists());
                    flutterToastCustom(
                        msg: state.errorMessage,
                        color: AppColors.primary);
                  }
                  return SizedBox.shrink();
                })));
  }
  Widget _expenseTypeLists(isLightTheme, hasReachedMax, expenseTypeList) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: hasReachedMax
          ? expenseTypeList.length // No extra item if all data is loaded
          : expenseTypeList.length + 1,
      itemBuilder: (context, index) {
        if (index < expenseTypeList.length) {
          final status = expenseTypeList[index];
          String? dateCreated;
          DateTime createdDate = parseDateStringFromApi(status.createdAt!);
          dateCreated = dateFormatConfirmed(createdDate, context);
          return expenseTypeList.isEmpty
              ? NoData(
            isImage: true,
          )
              : _expenseTypeListContainer(
              status, isLightTheme, expenseTypeList, index, dateCreated, status.description);
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Center(
              child: hasReachedMax
                  ? const Text('')
                  : const SpinKitFadingCircle(
                color: AppColors.primary,
                size: 40.0,
              ),
            ),
          );
        }
      },
    );
  }
  Widget _expenseTypeListContainer(ExpenseTypeModel expenseType, bool isLightTheme, List<ExpenseTypeModel> expenseTypeModel,
      int index, dateCreated, color) {
    print("fghbjkldndsfjd ");
    log("fghbjkldndsfjd ");
    return index == 0
        ? ShakeWidget(
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 0.w),
          child: DismissibleCard(
            // key: ValueKey(expenseType.id), // Ensure expenseType.id is unique
            title: expenseType.id!.toString(),
            confirmDismiss: (DismissDirection direction) async {
              log("confirmDismiss called with direction: $direction");

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
                        expenseTypeModel.removeAt(index);

                      });
                      context.read<ExpenseTypeBloc>().add(DeleteExpenseType(expenseType.id!));
                    });
                    // Return false to prevent the dismissible from animating
                    return false;
                  }

                  return false; // Always return false since we handle deletion manually
                } catch (e) {
                  print("Error in dialog: $e");
                  return false;
                }
              }
              else if (direction == DismissDirection.startToEnd) {
                log("Edit action - preventing dismiss");
                _createEditexpenseType(
                    isLightTheme: isLightTheme,
                    isCreate: false,
                    id: expenseType.id,
                    title: expenseType.title,
                    desc: expenseType.description);
                return false;
              }

              log("Default case - preventing dismiss");
              return false;
            },
            onDismissed: (DismissDirection direction) {
              log("fghuik - onDismissed called for ID: ${expenseType.id}!");
              log("Direction: $direction");

              if (direction == DismissDirection.endToStart) {
                setState(() {
                  expenseTypeModel.removeAt(index); // 🔴 You missed this line
                });
                context.read<ExpenseTypeBloc>().add(DeleteExpenseType(expenseType.id!));
              }
            },

            dismissWidget: _expenseTypeCard(
              isLightTheme,
              expenseType,
              color,
            ),
            // onDismissed: (DismissDirection direction) {
            //   log("fghuik ");
            //   // This will not be called if `confirmDismiss` returned `false`
            //   if (direction == DismissDirection.endToStart) {
            //     setState(() {
            //       expenseTypeModel.removeAt(index);
            //       context.read<ExpenseTypeBloc>().add(DeleteExpenseType(expenseType.id!));
            //
            //       // _onDeleteTodos(status);
            //     });
            //   }
            // },
          )),
    )
        : Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 0.w),
        child: DismissibleCard(
          title: expenseType.id!.toString(),
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
                      expenseTypeModel.removeAt(index);

                    });
                    context.read<ExpenseTypeBloc>().add(DeleteExpenseType(expenseType.id!));
                  });
                  // Return false to prevent the dismissible from animating
                  return false;
                }

                return false; // Always return false since we handle deletion manually
              } catch (e) {
                print("Error in dialog: $e");
                return false;
              }
            }
            else if (direction == DismissDirection.startToEnd) {
              _createEditexpenseType(
                  isLightTheme: isLightTheme,
                  isCreate: false,
                  id: expenseType.id,
                  title: expenseType.title,
                  desc: expenseType.description);
              return false; // Prevent dismiss
            }
            return false; // Default case
          },
          dismissWidget: _expenseTypeCard(
            isLightTheme,
            expenseType,
            color,
          ),
          onDismissed: (DismissDirection direction) {
            print("gbhjnkml, ");
            // This will not be called if `confirmDismiss` returned `false`
            if (direction == DismissDirection.endToStart) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  expenseTypeModel.removeAt(index);
                });
                context.read<ExpenseTypeBloc>().add(DeleteExpenseType(expenseType.id!));
              });
            
            }
          },
        ));
  }

  Widget _expenseTypeCard(
      isLightTheme,
      status,
      desc,
      ) {

    String  dateCreated = formatDateFromApi(status.createdAt!, context);
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
                    color:
                    Theme.of(context).colorScheme.textClrChange,
                    fontWeight: FontWeight.w700,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5.h,),
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
                color:  Theme
                    .of(context)
                    .colorScheme
                    .backGroundColor,
              ),
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 18.w,vertical: 5.h),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CustomText(
                          text:"📅 ${ AppLocalizations.of(context)!.createdat} : ",
                          size: 13.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w600,
                        ),  CustomText(
                          text:dateCreated,
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
  Future<void> _createEditexpenseType(
      {isLightTheme, isCreate, int? id, title, desc}) {
    if (isCreate) {
      titleController.text = '';
      descController.text = '';
    } else {
      titleController.text = title;
      descController.text = desc??"";
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
                      child:Form(
                        key: _createEditexpenseTypeKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                              child: BackArrow(
                                title: isCreate == false
                                    ? AppLocalizations.of(context)!.editexpense
                                    : AppLocalizations.of(context)!.createstatus,
                                iSBackArrow: false,
                                iscreatePermission: true,
                                onPress: (){
                                  print("dgfkgv ");
                                  _createEditexpenseType(isLightTheme: isLightTheme, isCreate: true);

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
                              height: 15.h,
                            ),
                            CustomTextFields(
                              height: 112.h,
                              keyboardType: TextInputType.multiline,
                              title: AppLocalizations.of(context)!.description,
                              hinttext: AppLocalizations.of(context)!
                                  .pleaseenterdescription,
                              controller: descController,
                              onSaved: (value) {},
                              onFieldSubmitted: (value) {

                              },
                              isLightTheme: isLightTheme,
                              isRequired: false,
                            ),
                            SizedBox(
                              height: 15.h,
                            ),

                            BlocBuilder<ExpenseTypeBloc, ExpenseTypeState>(
                                builder: (context, state) {
                                  if (state is ExpenseTypeEditSuccessLoading) {
                                    return CreateCancelButtom(
                                      isLoading: true,
                                      isCreate: isCreate,
                                      onpressCreate: isCreate == true
                                          ? () async {}
                                          : () {
                                        _onEditexpenseType(id, titleController.text, descController.text);
                                        // context.read<TodosBloc>().add(const TodosList());
                                        // Navigator.pop(context);
                                      },
                                      onpressCancel: () {
                                        Navigator.pop(context);
                                      },
                                    );
                                  }
                                  if (state is ExpenseTypeCreateSuccessLoading) {
                                    return CreateCancelButtom(
                                      isLoading: true,
                                      isCreate: isCreate,
                                      onpressCreate: isCreate == true
                                          ? () async {
                                        _onCreateexpenseType();
                                      }
                                          : () {
                                        _onEditexpenseType(id, titleController.text, descController.text);
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
                                      _onCreateexpenseType();
                                    }
                                        : () {
                                      _onEditexpenseType(id, titleController.text, descController.text);
                                      // context.read<TodosBloc>().add(const TodosList());
                                      // Navigator.pop(context);
                                    },
                                    onpressCancel: () {
                                      Navigator.pop(context);
                                    },
                                  );
                                }),
                            SizedBox(
                              height: 25.h,
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