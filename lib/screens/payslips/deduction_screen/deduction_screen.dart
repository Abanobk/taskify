//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:heroicons/heroicons.dart';
// import 'package:slidable_bar/slidable_bar.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:taskify/bloc/permissions/permissions_bloc.dart';
//
// import 'dart:async';
// import 'package:taskify/config/colors.dart';
//
// import '../../../bloc/payslip/deductions/deduction_bloc.dart';
// import '../../../bloc/payslip/deductions/deduction_event.dart';
// import '../../../bloc/payslip/deductions/deduction_state.dart';
// import '../../../data/model/payslip/deduction-model.dart';
// import '../../../utils/widgets/notes_shimmer_widget.dart';
// import 'package:taskify/screens/widgets/no_data.dart';
// import 'package:taskify/utils/widgets/custom_dimissible.dart';
// import 'package:taskify/utils/widgets/back_arrow.dart';
// //
// import '../../../bloc/setting/settings_bloc.dart';
// import '../../../bloc/theme/theme_bloc.dart';
// import '../../../bloc/theme/theme_state.dart';
// import '../../../config/internet_connectivity.dart';
//
// import '../../../utils/widgets/circularprogress_indicator.dart';
// import '../../../utils/widgets/custom_text.dart';
// import '../../../utils/widgets/my_theme.dart';
// import '../../../utils/widgets/search_pop_up.dart';
// import '../../../utils/widgets/toast_widget.dart';
// import '../../finance/tax/taxtype.dart';
// import '../../widgets/custom_cancel_create_button.dart';
// import '../../widgets/custom_textfields/custom_textfield.dart';
// import '../../widgets/search_field.dart';
// import '../../widgets/side_bar.dart';
// import '../../widgets/speech_to_text.dart';
//
// class DeductionScreen extends StatefulWidget {
//   const DeductionScreen({super.key});
//
//   @override
//   State<DeductionScreen> createState() => _DeductionScreenState();
// }
//
// class _DeductionScreenState extends State<DeductionScreen> {
//   DateTime now = DateTime.now();
//   final GlobalKey<FormState> _createDeductionsKey = GlobalKey<FormState>();
//   TextEditingController titleController = TextEditingController();
//   TextEditingController amountController = TextEditingController();
//   TextEditingController perController = TextEditingController();
//   TextEditingController searchController = TextEditingController();
//
//   bool? isLoading = true;
//   late SpeechToTextHelper speechHelper;
//   bool isLoadingMore = false;
//   String searchWord = "";
//
//   late ValueNotifier<String> DeductionType = ValueNotifier<String>("");
//   late ValueNotifier<String> DeductionTypeFilter = ValueNotifier<String>("");
//
//   final ValueNotifier<String> noteType = ValueNotifier<String>("text");
//   final ValueNotifier<bool> filterType = ValueNotifier<bool>(false);
//
//   bool dialogShown = false;
//   double valueInProgress = 0;
//   String? drawing;
//   String? currency;
//   String? currencyPosition;
//
//   List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
//   final Connectivity _connectivity = Connectivity();
//   late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
//
//   ConnectivityResult connectivityCheck = ConnectivityResult.none;
//   final SlidableBarController sideBarController =
//   SlidableBarController(initialStatus: false);
//
//   @override
//   void initState() {
//     super.initState();
//     CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
//       if (results.isNotEmpty) {
//         setState(() {
//           _connectionStatus = results;
//         });
//       }
//     });
//
//     _connectivitySubscription = _connectivity.onConnectivityChanged
//         .listen((List<ConnectivityResult> results) {
//       if (results.isNotEmpty) {
//         CheckInternet.updateConnectionStatus(results).then((value) {
//           setState(() {
//             _connectionStatus = value;
//           });
//         });
//       }
//     });
//     context.read<DeductionBloc>().add(const DeductionsList());
//     DeductionType = ValueNotifier<String>(DeductionType.value.toLowerCase());
//
//     currency = context.read<SettingsBloc>().currencySymbol;
//     currencyPosition = context.read<SettingsBloc>().currencyPosition;
//     filterType.value = false;
//     speechHelper = SpeechToTextHelper(
//       onSpeechResultCallback: (result) {
//         setState(() {
//           searchController.text = result;
//           context
//               .read<DeductionBloc>()
//               .add(SearchDeductions(result, DeductionTypeFilter.value));
//         });
//         Navigator.pop(context);
//       },
//     );
//     speechHelper.initSpeech();
//
//     setState(() {
//       isLoading = false;
//     });
//   }
//
//   @override
//   void dispose() {
//     titleController.dispose();
//     DeductionType.dispose();
//     _connectivitySubscription.cancel();
//     super.dispose();
//   }
//
//   void _onCreateDeductions() {
//     if (_createDeductionsKey.currentState!.validate()) {
//       final newDeduction = DeductionModel(
//         title: titleController.text.trim(),
//         type: DeductionType.value,
//         amount: amountController.text.trim(),
//         percentage: valueInProgress.toInt(),
//       );
//       // Navigator.pop(context);
//       context.read<DeductionBloc>().add(AddDeductions(newDeduction));
//     } else {
//       flutterToastCustom(
//         msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
//       );
//     }
//   }
//
//   void _onEditDeductions(id, title, desc) async {
//     if (_createDeductionsKey.currentState!.validate()) {
//       final updatedNote = DeductionModel(
//           id: id,
//           title: titleController.text,
//           type: DeductionType.value,
//           amount: amountController.text.isNotEmpty ? amountController.text : "",
//           percentage: valueInProgress.toInt());
//
//       context.read<DeductionBloc>().add(UpdateDeductions(updatedNote));
//       final todosBloc = BlocProvider.of<DeductionBloc>(context);
//       todosBloc.stream.listen((state) {
//         if (state is DeductionsEditSuccess) {
//           if (mounted) {
//             context.read<DeductionBloc>().add(const DeductionsList());
//             flutterToastCustom(
//                 msg: AppLocalizations.of(context)!.updatedsuccessfully,
//                 color: AppColors.primary);
//             Navigator.pop(context);
//
//           }
//         }
//         if (state is DeductionsEditError) {
//           flutterToastCustom(msg: state.errorMessage);
//         }
//       });
//     } else {
//       flutterToastCustom(
//         msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
//       );
//     }
//   }
//
//   void _onDeleteDeductions(Deductions) {
//     context.read<DeductionBloc>().add(DeleteDeductions(Deductions));
//     final setting = context.read<DeductionBloc>();
//     setting.stream.listen((state) {
//       if (state is DeductionsDeleteSuccess) {
//         if (mounted) {
//           flutterToastCustom(
//               msg: AppLocalizations.of(context)!.deletedsuccessfully,
//               color: AppColors.primary);
//         }
//       }
//       if (state is DeductionsDeleteError) {
//         flutterToastCustom(msg: state.errorMessage);
//       }
//     });
//     context.read<DeductionBloc>().add(const DeductionsList());
//   }
//
//   Future<void> _onRefresh() async {
//     setState(() {
//       isLoading = true;
//     });
//
//     BlocProvider.of<DeductionBloc>(context).add(DeductionsList());
//     setState(() {
//       isLoading = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final themeBloc = context.read<ThemeBloc>();
//     final currentTheme = themeBloc.currentThemeState;
//
//     bool isLightTheme = currentTheme is LightThemeState;
//     return _connectionStatus.contains(connectivityCheck)
//         ? NoInternetScreen()
//         : Scaffold(
//         backgroundColor: Theme.of(context).colorScheme.backGroundColor,
//         body: SideBar(
//           context: context,
//           controller: sideBarController,
//           underWidget: SizedBox(
//             width: double.infinity,
//             child: Column(
//               children: [
//                 _appbar(isLightTheme),
//                 SizedBox(height: 20.h),
//                 CustomSearchField(
//                   isLightTheme: isLightTheme,
//                   controller: searchController,
//                   suffixIcon: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       if (searchController.text.isNotEmpty)
//                         SizedBox(
//                           width: 20.w,
//                           child: IconButton(
//                             highlightColor: Colors.transparent,
//                             padding: EdgeInsets.zero,
//                             icon: Icon(
//                               Icons.clear,
//                               size: 20.sp,
//                               color: Theme.of(context)
//                                   .colorScheme
//                                   .textFieldColor,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 searchController.clear();
//                               });
//                               context.read<DeductionBloc>().add(
//                                   SearchDeductions(
//                                       '', ""));
//                             },
//                           ),
//                         ),
//                       SizedBox(
//                         width: 30.w,
//                         child: IconButton(
//                           icon: Icon(
//                             !speechHelper.isListening
//                                 ? Icons.mic_off
//                                 : Icons.mic,
//                             size: 20.sp,
//                             color: Theme.of(context)
//                                 .colorScheme
//                                 .textFieldColor,
//                           ),
//                           onPressed: () {
//                             if (speechHelper.isListening) {
//                               speechHelper.stopListening();
//                             } else {
//                               speechHelper.startListening(
//                                   context, searchController, SearchPopUp());
//                             }
//                           },
//                         ),
//                       ),
//                       Stack(children: [
//                         IconButton(
//                           icon: HeroIcon(
//                             HeroIcons.adjustmentsHorizontal,
//                             style: HeroIconStyle.solid,
//                             color: Theme.of(context)
//                                 .colorScheme
//                                 .textFieldColor,
//                             size: 30.sp,
//                           ),
//                           onPressed: () {
//                             _filterDialog(context, isLightTheme);
//                           },
//                         ),
//                         if (filterType.value == true)
//                           Positioned(
//                             right: 5.w,
//                             top: 7.h,
//                             child: Container(
//                               padding: EdgeInsets.zero,
//                               alignment: Alignment.center,
//                               height: 12.h,
//                               width: 10.w,
//                               decoration: BoxDecoration(
//                                 color: AppColors.primary,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: CustomText(
//                                 text: "1",
//                                 color: Colors.white,
//                                 size: 6,
//                                 textAlign: TextAlign.center,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                       ])
//                     ],
//                   ),
//                   onChanged: (value) {
//                     searchWord = value;
//                     context.read<DeductionBloc>().add(
//                         SearchDeductions(value, DeductionTypeFilter.value));
//                   },
//                 ),
//                 SizedBox(height: 20.h),
//                 body(isLightTheme)
//               ],
//             ),
//           ),
//         ));
//   }
//
//   Widget body(isLightTheme) {
//     return Expanded(
//       child: RefreshIndicator(
//         color: AppColors.primary,
//         backgroundColor: Theme.of(context).colorScheme.backGroundColor,
//         onRefresh: _onRefresh,
//         child: BlocConsumer<DeductionBloc, DeductionsState>(
//           listener: (context, state) {
//             if (state is DeductionsPaginated) {
//               isLoadingMore = false;
//               setState(() {});
//             }
//             if (state is DeductionsCreateSuccess) {
//               context.read<DeductionBloc>().add(const DeductionsList());
//               if (Navigator.canPop(context)) {
//                 Navigator.pop(context);
//               }
//               flutterToastCustom(
//                 msg: AppLocalizations.of(context)!.createdsuccessfully,
//                 color: AppColors.primary,
//               );
//             }else if (state is DeductionsDeleteSuccess) {
//               context.read<DeductionBloc>().add(const DeductionsList());
//
//               flutterToastCustom(
//                 msg: AppLocalizations.of(context)!.deletedsuccessfully,
//                 color: AppColors.red,
//               );
//             } else if (state is DeductionsCreateError) {
//               context.read<DeductionBloc>().add(const DeductionsList());
//               flutterToastCustom(msg: state.errorMessage);
//             }
//           },
//           builder: (context, state) {
//             print("Deduction State $state");
//             if (state is DeductionsLoading) {
//               return const NotesShimmer();
//             } else if (state is DeductionsPaginated) {
//               return NotificationListener<ScrollNotification>(
//                 onNotification: (scrollInfo) {
//                   if (!state.hasReachedMax &&
//                       scrollInfo.metrics.pixels ==
//                           scrollInfo.metrics.maxScrollExtent) {
//                     context
//                         .read<DeductionBloc>()
//                         .add(LoadMoreDeductions(searchWord));
//                   }
//                   return false;
//                 },
//                 child: state.Deductions.isNotEmpty
//                     ? ListView.builder(
//                   padding: EdgeInsets.only(bottom: 30.h),
//                   shrinkWrap: true,
//                   itemCount: state.hasReachedMax
//                       ? state.Deductions.length
//                       : state.Deductions.length + 1,
//                   itemBuilder: (context, index) {
//                     if (index < state.Deductions.length) {
//                       final Deductions = state.Deductions[index];
//                       return _DeductionsListContainer(
//                         Deductions,
//                         isLightTheme,
//                         state.Deductions[index],
//                         state.Deductions,
//                         index,
//                       );
//                     } else {
//                       return CircularProgressIndicatorCustom(
//                         hasReachedMax: state.hasReachedMax,
//                       );
//                     }
//                   },
//                 )
//                     : NoData(
//                   isImage: true,
//                 ),
//               );
//             }
//             else if (state is DeductionsError) {
//               return Center(
//                 child: Text(
//                   state.errorMessage,
//                   style: const TextStyle(color: Colors.red),
//                 ),
//               );
//             } else if (state is DeductionsSuccess) {
//               return ListView.builder(
//                 padding: EdgeInsets.only(bottom: 30.h),
//                 shrinkWrap: true,
//                 itemCount: state.Deductions.length + 1,
//                 itemBuilder: (context, index) {
//                   if (index < state.Deductions.length) {
//                     final Deductions = state.Deductions[index];
//                     return _DeductionsListContainer(
//                       Deductions,
//                       isLightTheme,
//                       state.Deductions[index],
//                       state.Deductions,
//                       index,
//                     );
//                   } else {
//                     return CircularProgressIndicatorCustom(
//                       hasReachedMax: true,
//                     );
//                   }
//                 },
//               );
//             }
//             return const Text("");
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _appbar(isLightTheme) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 18.w),
//       child: BackArrow(
//         iSBackArrow: true,
//         iscreatePermission: context.read<PermissionsBloc>().iscreateDeduction,
//         title: AppLocalizations.of(context)!.deductions,
//         isAdd: context.read<PermissionsBloc>().iscreateDeduction,
//         onPress: () {
//           _createEditDeductions(isLightTheme: isLightTheme, isCreate: true);
//         },
//       ),
//     );
//   }
//
//   Future<void> _createEditDeductions({
//     required bool isLightTheme,
//     required bool isCreate,
//     DeductionModel? Deductions,
//     DeductionModel? DeductionsModel,
//     int? id,
//     String? title,
//     String? desc,
//   }) {
//     // Initialize controllers and values for editing
//     if (!isCreate && DeductionsModel != null) {
//       titleController.text = DeductionsModel.title ?? "";
//       DeductionType.value = DeductionsModel.type?.toLowerCase() ?? "";
//       amountController.text = DeductionsModel.amount ?? "";
//       valueInProgress = DeductionsModel.percentage?.toDouble() ?? 0;
//     } else {
//       // Clear controllers for create mode
//       titleController.clear();
//       amountController.clear();
//       DeductionType.value = "";
//       valueInProgress = 0;
//     }
//
//     return showModalBottomSheet<void>(
//       isScrollControlled: true,
//       context: context,
//       builder: (BuildContext context) {
//         double _localSliderValue = valueInProgress;
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setModalState) {
//             return Padding(
//               padding: EdgeInsets.only(
//                   bottom: MediaQuery.of(context).viewInsets.bottom),
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(25),
//                   color: Theme.of(context).colorScheme.backGroundColor,
//                 ),
//                 height: 390.h,
//                 child: Form(
//                   key: _createDeductionsKey,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       SizedBox(height: 20.h,),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 18.w),
//                         child: BackArrow(
//                           isBottomSheet: true,
//                           iscreatePermission:
//                           context.read<PermissionsBloc>().iscreateDeduction,
//                           title: isCreate
//                               ? AppLocalizations.of(context)!.creatededuction
//                               : AppLocalizations.of(context)!.editdeduction,
//                           iSBackArrow: false,
//                         ),
//                       ),
//                       SizedBox(height: 15.h),
//                       CustomTextFields(
//                         title: AppLocalizations.of(context)!.title,
//                         hinttext:
//                         AppLocalizations.of(context)!.pleaseentertitle,
//                         controller: titleController,
//                         onSaved: (value) {},
//                         onFieldSubmitted: (value) {},
//                         isLightTheme: isLightTheme,
//                         isRequired: true,
//                         // validator: (value) {
//                         //   if (value == null || value.isEmpty) {
//                         //     return AppLocalizations.of(context)!
//                         //         .pleaseentertitle;
//                         //   }
//                         //   return null;
//                         // },
//                       ),
//                       SizedBox(height: 15.h),
//                       TaxTypeField(
//                         access: DeductionType.value,
//                         isRequired: true,
//                         isCreate: isCreate,
//                         from: "type",
//                         onSelected: (value) {
//                           setModalState(() {
//                             DeductionType.value = value.toLowerCase();
//                             if (value.toLowerCase() == "amount") {
//                               valueInProgress = 0; // Reset percentage
//                             } else if (value.toLowerCase() == "percentage") {
//                               amountController.clear(); // Reset amount
//                             }
//                           });
//                         },
//                       ),
//                       SizedBox(height: 15.h),
//                       ValueListenableBuilder<String>(
//                         valueListenable: DeductionType,
//                         builder: (context, value, _) {
//                           if (value == "amount") {
//                             return CustomTextFields(
//                               keyboardType: TextInputType.number,
//                               title: AppLocalizations.of(context)!.amount,
//                               subtitle: currency,
//                               hinttext: AppLocalizations.of(context)!
//                                   .pleaseenteramount,
//                               controller: amountController,
//                               isDetails: false,
//                               onSaved: (val) {},
//                               onFieldSubmitted: (val) {},
//                               isLightTheme: isLightTheme,
//                               isRequired: true,
//                               // validator: (value) {
//                               //   if (value == null || value.isEmpty) {
//                               //     return AppLocalizations.of(context)!
//                               //         .pleaseenteramount;
//                               //   }
//                               //   return null;
//                               // },
//                             );
//                           } else if (value == "percentage") {
//                             return Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Padding(
//                                   padding:
//                                   EdgeInsets.symmetric(horizontal: 20.w),
//                                   child: CustomText(
//                                     text:
//                                     AppLocalizations.of(context)!.percntage,
//                                     color: Theme.of(context)
//                                         .colorScheme
//                                         .textClrChange,
//                                     size: 16,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: Slider(
//                                         value: _localSliderValue,
//                                         min: 0,
//                                         max: 100,
//                                         divisions: 100,
//                                         onChanged: isCreate
//                                             ? (v) {
//                                           setModalState(() {
//                                             _localSliderValue = v;
//                                             valueInProgress = v;
//                                           });
//                                         }
//                                             : null, // Disable if isCreate is false/ Disable if isCreate is false
//                                         label: "${_localSliderValue.toInt()}%",
//                                       ),
//                                     ),
//                                     CustomText(
//                                       text: "${_localSliderValue.toInt()}%",
//                                       size: 15.sp,
//                                       color: Theme.of(context)
//                                           .colorScheme
//                                           .textClrChange,
//                                     ),
//                                     const SizedBox(width: 16),
//                                   ],
//                                 ),
//                               ],
//                             );
//                           } else {
//                             return const SizedBox.shrink();
//                           }
//                         },
//                       ),
//                       SizedBox(height: 15.h),
//                       BlocBuilder<DeductionBloc, DeductionsState>(
//                         builder: (context, state) {
//                           bool isLoading =
//                               state is DeductionsEditSuccessLoading ||
//                                   state is DeductionsCreateSuccessLoading;
//
//                           return CreateCancelButtom(
//                             isLoading: isLoading,
//                             isCreate: isCreate,
//                             onpressCreate: () {
//                               if (_createDeductionsKey.currentState!
//                                   .validate()) {
//                                 if (isCreate) {
//                                   _onCreateDeductions();
//                                 } else {
//                                   _onEditDeductions(id, title, desc);
//                                 }
//
//                               }
//                             },
//                             onpressCancel: () {
//                               Navigator.pop(context);
//                             },
//                           );
//                         },
//                       ),
//                       SizedBox(height: 15.h),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     ).whenComplete(() {
//       titleController.clear();
//       amountController.clear();
//       perController.clear();
//       DeductionType.value = "";
//       valueInProgress = 0;
//     });
//   }
//
//   Widget _DeductionsListContainer(
//       DeductionModel Deductions,
//       bool isLightTheme,
//       DeductionModel DeductionsModel,
//       List<DeductionModel> DeductionsList,
//       int index,
//       ) {
//     return Padding(
//         padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
//         child: DismissibleCard(
//           direction:
//           context.read<PermissionsBloc>().isdeleteDeduction == true &&
//               context.read<PermissionsBloc>().iseditDeduction == true
//               ? DismissDirection.horizontal
//               : context.read<PermissionsBloc>().isdeleteDeduction == true
//               ? DismissDirection.endToStart
//               : context.read<PermissionsBloc>().iseditDeduction == true
//               ? DismissDirection.startToEnd
//               : DismissDirection.none,
//           title: Deductions.id!.toString(),
//           confirmDismiss: (DismissDirection direction) async {
//             if (direction == DismissDirection.endToStart &&
//                 context.read<PermissionsBloc>().isdeleteDeduction == true) {
//               final result = await showDialog(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.r),
//                     ),
//                     backgroundColor:
//                     Theme.of(context).colorScheme.alertBoxBackGroundColor,
//                     title: Text(
//                       AppLocalizations.of(context)!.confirmDelete,
//                     ),
//                     content: Text(
//                       AppLocalizations.of(context)!.areyousure,
//                     ),
//                     actions: [
//                       TextButton(
//                         onPressed: () {
//                           Navigator.of(context).pop(true);
//                         },
//                         child: Text(
//                           AppLocalizations.of(context)!.ok,
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.of(context).pop(false);
//                         },
//                         child: Text(
//                           AppLocalizations.of(context)!.cancel,
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               );
//               return result;
//             } else if (direction == DismissDirection.startToEnd &&
//                 context.read<PermissionsBloc>().iseditDeduction == true) {
//               _createEditDeductions(
//                 isLightTheme: isLightTheme,
//                 isCreate: false,
//                 Deductions: Deductions,
//                 DeductionsModel: DeductionsModel,
//                 id: Deductions.id,
//                 title: Deductions.title,
//                 desc: Deductions.amount,
//               );
//               return false;
//             }
//             return false;
//           },
//           dismissWidget: Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//                 boxShadow: [
//                   isLightTheme
//                       ? MyThemes.lightThemeShadow
//                       : MyThemes.darkThemeShadow,
//                 ],
//                 color: Theme.of(context).colorScheme.containerDark,
//                 borderRadius: BorderRadius.circular(12)),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: EdgeInsets.symmetric(
//                     vertical: 10.h,
//                     horizontal: 20.h,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       CustomText(
//                         text: "#${Deductions.id.toString()}",
//                         size: 14.sp,
//                         color: AppColors.greyColor,
//                         fontWeight: FontWeight.w700,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       CustomText(
//                         text: Deductions.title!,
//                         size: 16.sp,
//                         color: Theme.of(context).colorScheme.textClrChange,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       SizedBox(
//                         height: 5.h,
//                       ),
//                       if (Deductions.amount?.toString().isNotEmpty ?? false)
//                         currencyPosition == "before"
//                             ? CustomText(
//                           text: "$currency ${Deductions.amount!}",
//                           size: 16.sp,
//                           color:
//                           Theme.of(context).colorScheme.textClrChange,
//                           fontWeight: FontWeight.w600,
//                         )
//                             : CustomText(
//                           text: "${Deductions.amount!} $currency ",
//                           size: 16.sp,
//                           color:
//                           Theme.of(context).colorScheme.textClrChange,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       if ((Deductions.percentage?.toString().isNotEmpty ??
//                           false))
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 0),
//                           child: Container(
//                             padding: EdgeInsets.symmetric(horizontal: 0),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: SliderTheme(
//                                     data: SliderTheme.of(context).copyWith(
//                                         trackHeight: 4,
//                                         overlayShape:
//                                         SliderComponentShape.noOverlay,
//                                         trackShape:
//                                         const RoundedRectSliderTrackShape(),
//                                         thumbShape: const RoundSliderThumbShape(
//                                             enabledThumbRadius: 6),
//                                         thumbColor: AppColors.primary),
//                                     child: Slider(
//                                       value: Deductions.percentage!.toDouble(),
//                                       min: 0,
//                                       max: 100,
//                                       divisions: 100,
//                                       onChanged: (v) {},
//                                       label:
//                                       "${Deductions.percentage!.toInt()}%",
//                                     ),
//                                   ),
//                                 ),
//                                 CustomText(
//                                   text: "${Deductions.percentage!.toInt()}%",
//                                   size: 15.sp,
//                                   color: Theme.of(context)
//                                       .colorScheme
//                                       .textClrChange,
//                                 ),
//                                 const SizedBox(width: 8),
//                               ],
//                             ),
//                           ),
//                         )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           onDismissed: (DismissDirection direction) {
//             if (direction == DismissDirection.endToStart &&
//                 context.read<PermissionsBloc>().isdeleteDeduction == true) {
//               setState(() {
//                 DeductionsList.removeAt(index);
//                 _onDeleteDeductions(Deductions.id);
//               });
//             }
//           },
//         ));
//   }
//
//   void _filterDialog(BuildContext context, isLightTheme) {
//     showModalBottomSheet(
//         backgroundColor: Theme.of(context).colorScheme.containerDark,
//         context: context,
//         isScrollControlled: true,
//         builder: (BuildContext context) {
//           return Container(
//               padding: EdgeInsets.all(16.w),
//               child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: <Widget>[
//                     SizedBox(height: 10),
//                     CustomText(
//                       text: AppLocalizations.of(context)!.selectfilter,
//                       color: AppColors.primary,
//                       size: 30.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     SizedBox(height: 20),
//                     TaxTypeField(
//                       access: DeductionTypeFilter.value,
//                       isRequired: true,
//                       isCreate: false,
//                       isFilter: true,
//                       from: "type",
//                       onSelected: (value) {
//                         filterType.value = true;
//                         DeductionTypeFilter.value = value.toLowerCase();
//                       },
//                     ),
//                     SizedBox(height: 20),
//                     Padding(
//                       padding: EdgeInsets.symmetric(
//                           horizontal: 18.w, vertical: 10.h),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           InkWell(
//                             onTap: () {
//                               context.read<DeductionBloc>().add(
//                                   SearchDeductions(
//                                       searchWord, DeductionTypeFilter.value));
//                               Navigator.of(context).pop();
//                             },
//                             child: Container(
//                               height: 35.h,
//                               decoration: BoxDecoration(
//                                 color: AppColors.primary,
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Padding(
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: 15.w, vertical: 0.h),
//                                 child: Center(
//                                   child: CustomText(
//                                     text: AppLocalizations.of(context)!.apply,
//                                     size: 12.sp,
//                                     color: AppColors.pureWhiteColor,
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 30.w),
//                           InkWell(
//                             onTap: () {
//                               setState(() {
//                                 Navigator.of(context).pop();
//                                 DeductionTypeFilter.value = "";
//                                 filterType.value = false;
//                               });
//                             },
//                             child: Container(
//                               height: 35.h,
//                               decoration: BoxDecoration(
//                                 color: AppColors.primary,
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Padding(
//                                 padding: EdgeInsets.symmetric(horizontal: 15.w),
//                                 child: Center(
//                                   child: CustomText(
//                                     text: AppLocalizations.of(context)!.clear,
//                                     size: 12.sp,
//                                     color: AppColors.pureWhiteColor,
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                   ]));
//         });
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:taskify/bloc/permissions/permissions_bloc.dart';

import 'dart:async';
import 'package:taskify/config/colors.dart';

import '../../../bloc/payslip/deductions/deduction_bloc.dart';
import '../../../bloc/payslip/deductions/deduction_event.dart';
import '../../../bloc/payslip/deductions/deduction_state.dart';
import '../../../data/model/payslip/deduction-model.dart';
import '../../../src/generated/i18n/app_localizations.dart';
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
import '../../finance/tax/taxtype.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../widgets/custom_textfields/custom_textfield.dart';
import '../../widgets/search_field.dart';
import '../../widgets/side_bar.dart';
import '../../widgets/speech_to_text.dart';

class DeductionScreen extends StatefulWidget {
  const DeductionScreen({super.key});

  @override
  State<DeductionScreen> createState() => _DeductionScreenState();
}

class _DeductionScreenState extends State<DeductionScreen> {
  final GlobalKey<FormState> _createDeductionsKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController perController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  bool? isLoading = true;
  late SpeechToTextHelper speechHelper;
  bool isLoadingMore = false;
  String searchWord = "";

  late ValueNotifier<String> DeductionType = ValueNotifier<String>("");
  late ValueNotifier<String> DeductionTypeFilter = ValueNotifier<String>("");

  final ValueNotifier<String> noteType = ValueNotifier<String>("text");
  final ValueNotifier<bool> filterType = ValueNotifier<bool>(false);

  double valueInProgress = 0;
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
    context.read<DeductionBloc>().add(const DeductionsList());
    DeductionType = ValueNotifier<String>("");

    currency = context.read<SettingsBloc>().currencySymbol;
    currencyPosition = context.read<SettingsBloc>().currencyPosition;
    filterType.value = false;
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          context
              .read<DeductionBloc>()
              .add(SearchDeductions(result,""));
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
    amountController.dispose();
    perController.dispose();
    searchController.dispose();
    DeductionType.dispose();
    DeductionTypeFilter.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _onCreateDeductions() {
    if (_createDeductionsKey.currentState!.validate()) {
      final newDeduction = DeductionModel(
        title: titleController.text.trim(),
        type: DeductionType.value,
        amount: DeductionType.value == "amount" ? amountController.text.trim() : "",
        percentage: DeductionType.value == "percentage" ? valueInProgress.toInt() : 0,
      );
      context.read<DeductionBloc>().add(AddDeductions(newDeduction));
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  void _onEditDeductions(id, title, desc) async {
    if (_createDeductionsKey.currentState!.validate()) {
      final updatedNote = DeductionModel(
          id: id,
          title: titleController.text,
          type: DeductionType.value,
          amount: DeductionType.value == "amount" ? amountController.text : "",
          percentage: DeductionType.value == "percentage" ? valueInProgress.toInt() : 0);

      context.read<DeductionBloc>().add(UpdateDeductions(updatedNote));
      final todosBloc = BlocProvider.of<DeductionBloc>(context);
      todosBloc.stream.listen((state) {
        if (state is DeductionsEditSuccess) {
          if (mounted) {
            context.read<DeductionBloc>().add(const DeductionsList());
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.updatedsuccessfully,
                color: AppColors.primary);
            Navigator.pop(context);
          }
        }
        if (state is DeductionsEditError) {
          flutterToastCustom(msg: state.errorMessage);
          context.read<DeductionBloc>().add(const DeductionsList());

        }
      });
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  void _onDeleteDeductions(Deductions) {
    context.read<DeductionBloc>().add(DeleteDeductions(Deductions));
    final setting = context.read<DeductionBloc>();
    setting.stream.listen((state) {
      if (state is DeductionsDeleteSuccess) {
        if (mounted) {
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is DeductionsDeleteError) {
        flutterToastCustom(msg: state.errorMessage);
      }
    });
    context.read<DeductionBloc>().add(const DeductionsList());
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });

    BlocProvider.of<DeductionBloc>(context).add(DeductionsList());
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
                              context.read<DeductionBloc>().add(
                                  SearchDeductions('', ""));
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
                          },
                        ),
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
                    ],
                  ),
                  onChanged: (value) {
                    searchWord = value;
                    context.read<DeductionBloc>().add(
                        SearchDeductions(value, DeductionTypeFilter.value));
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
        child: BlocConsumer<DeductionBloc, DeductionsState>(
          listener: (context, state) {
            if (state is DeductionsPaginated) {
              isLoadingMore = false;
              setState(() {});
            }
            if (state is DeductionsCreateSuccess) {
              context.read<DeductionBloc>().add(const DeductionsList());
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              flutterToastCustom(
                msg: AppLocalizations.of(context)!.createdsuccessfully,
                color: AppColors.primary,
              );
            } else if (state is DeductionsDeleteSuccess) {
              context.read<DeductionBloc>().add(const DeductionsList());

              flutterToastCustom(
                msg: AppLocalizations.of(context)!.deletedsuccessfully,
                color: AppColors.red,
              );
            } else if (state is DeductionsCreateError) {
              context.read<DeductionBloc>().add(const DeductionsList());
              flutterToastCustom(msg: state.errorMessage);
            }
          },
          builder: (context, state) {
            print("Deduction State $state");
            if (state is DeductionsLoading) {
              return const NotesShimmer();
            } else if (state is DeductionsPaginated) {
              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (!state.hasReachedMax &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    context
                        .read<DeductionBloc>()
                        .add(LoadMoreDeductions(searchWord));
                  }
                  return false;
                },
                child: state.Deductions.isNotEmpty
                    ? ListView.builder(
                  padding: EdgeInsets.only(bottom: 30.h),
                  shrinkWrap: true,
                  itemCount: state.hasReachedMax
                      ? state.Deductions.length
                      : state.Deductions.length + 1,
                  itemBuilder: (context, index) {
                    if (index < state.Deductions.length) {
                      final Deductions = state.Deductions[index];
                      return _DeductionsListContainer(
                        Deductions,
                        isLightTheme,
                        state.Deductions[index],
                        state.Deductions,
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
            } else if (state is DeductionsError) {
              return Center(
                child: Text(
                  state.errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (state is DeductionsSuccess) {
              return ListView.builder(
                padding: EdgeInsets.only(bottom: 30.h),
                shrinkWrap: true,
                itemCount: state.Deductions.length + 1,
                itemBuilder: (context, index) {
                  if (index < state.Deductions.length) {
                    final Deductions = state.Deductions[index];
                    return _DeductionsListContainer(
                      Deductions,
                      isLightTheme,
                      state.Deductions[index],
                      state.Deductions,
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
        iscreatePermission: context.read<PermissionsBloc>().iscreateDeduction,
        title: AppLocalizations.of(context)!.deductions,
        isAdd: context.read<PermissionsBloc>().iscreateDeduction,
        onPress: () {
          _createEditDeductions(isLightTheme: isLightTheme, isCreate: true);
        },
      ),
    );
  }

  Future<void> _createEditDeductions({
    required bool isLightTheme,
    required bool isCreate,
    DeductionModel? Deductions,
    DeductionModel? DeductionsModel,
    int? id,
    String? title,
    String? desc,
  }) {
    // Store original values to restore when switching types
    String? originalAmount;
    double originalPercentage = 0;

    // Initialize controllers and values for editing or creating
    if (!isCreate && DeductionsModel != null) {
      titleController.text = DeductionsModel.title ?? "";
      DeductionType.value = DeductionsModel.type?.toLowerCase() ?? "";
      originalAmount = DeductionsModel.amount ?? "";
      amountController.text = originalAmount;
      originalPercentage = DeductionsModel.percentage?.toDouble() ?? 0;
      valueInProgress = originalPercentage;
    } else {
      titleController.clear();
      amountController.clear();
      DeductionType.value = "";
      valueInProgress = 0;
    }

    return showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        double _localSliderValue = valueInProgress;
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
                height: 390.h,
                child: Form(
                  key: _createDeductionsKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 20.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: BackArrow(
                          isBottomSheet: true,
                          iscreatePermission:
                          context.read<PermissionsBloc>().iscreateDeduction,
                          title: isCreate
                              ? AppLocalizations.of(context)!.creatededuction
                              : AppLocalizations.of(context)!.editdeduction,
                          iSBackArrow: false,
                        ),
                      ),
                      SizedBox(height: 15.h),
                      CustomTextFields(
                        title: AppLocalizations.of(context)!.title,
                        hinttext: AppLocalizations.of(context)!.pleaseentertitle,
                        controller: titleController,
                        onSaved: (value) {},
                        onFieldSubmitted: (value) {},
                        isLightTheme: isLightTheme,
                        isRequired: true,

                      ),
                      SizedBox(height: 15.h),
                      TaxTypeField(
                        access: DeductionType.value,
                        isRequired: true,
                        isCreate: true,
                        from: "type",
                        onSelected: (value) {
                          setModalState(() {
                            DeductionType.value = value.toLowerCase();
                            if (value.toLowerCase() == "amount") {
                              valueInProgress = 0;
                              _localSliderValue = 0;
                              amountController.text = originalAmount ?? "";
                            } else if (value.toLowerCase() == "percentage") {
                              amountController.clear();
                              valueInProgress = originalPercentage;
                              _localSliderValue = originalPercentage;
                            }
                          });
                        },
                      ),
                      SizedBox(height: 15.h),
                      ValueListenableBuilder<String>(
                        valueListenable: DeductionType,
                        builder: (context, value, _) {
                          if (value == "amount") {
                            return CustomTextFields(
                              keyboardType: TextInputType.number,
                              title: AppLocalizations.of(context)!.amount,
                              subtitle: currency,
                              hinttext:
                              AppLocalizations.of(context)!.pleaseenteramount,
                              controller: amountController,
                              isDetails: false,
                              onSaved: (val) {},
                              onFieldSubmitted: (val) {},
                              onchange: (val) {
                                _validateInput(val, context);
                              },

                              isLightTheme: isLightTheme,
                              isRequired: true,

                            );
                          } else if (value == "percentage") {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                  EdgeInsets.symmetric(horizontal: 20.w),
                                  child: CustomText(
                                    text: AppLocalizations.of(context)!.percntage,
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
                                        onChanged: (v) {
                                          setModalState(() {
                                            _localSliderValue = v;
                                            valueInProgress = v;
                                          });
                                        },
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
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                      SizedBox(height: 15.h),
                      BlocBuilder<DeductionBloc, DeductionsState>(
                        builder: (context, state) {
                          bool isLoading =
                              state is DeductionsEditSuccessLoading ||
                                  state is DeductionsCreateSuccessLoading;

                          return CreateCancelButtom(
                            isLoading: isLoading,
                            isCreate: isCreate,
                            onpressCreate: () {
                              if (_createDeductionsKey.currentState!.validate()) {
                                if (isCreate) {
                                  _onCreateDeductions();
                                } else {
                                  _onEditDeductions(id, title, desc);
                                }
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
      DeductionType.value = "";
      valueInProgress = 0;
    });
  }

  Widget _DeductionsListContainer(
      DeductionModel Deductions,
      bool isLightTheme,
      DeductionModel DeductionsModel,
      List<DeductionModel> DeductionsList,
      int index) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
        child: DismissibleCard(
          direction: context.read<PermissionsBloc>().isdeleteDeduction == true &&
              context.read<PermissionsBloc>().iseditDeduction == true
              ? DismissDirection.horizontal
              : context.read<PermissionsBloc>().isdeleteDeduction == true
              ? DismissDirection.endToStart
              : context.read<PermissionsBloc>().iseditDeduction == true
              ? DismissDirection.startToEnd
              : DismissDirection.none,
          title: Deductions.id!.toString(),
          confirmDismiss: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart &&
                context.read<PermissionsBloc>().isdeleteDeduction == true) {
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
                      DeductionsList.removeAt(index);

                    });
                    _onDeleteDeductions(Deductions.id);                  });
                  // Return false to prevent the dismissible from animating
                  return false;
                }

                return false; // Always return false since we handle deletion manually
              } catch (e) {
                print("Error in dialog: $e");
                return false;
              }
            } else if (direction == DismissDirection.startToEnd &&
                context.read<PermissionsBloc>().iseditDeduction == true) {
              _createEditDeductions(
                isLightTheme: isLightTheme,
                isCreate: false,
                Deductions: Deductions,
                DeductionsModel: DeductionsModel,
                id: Deductions.id,
                title: Deductions.title,
                desc: Deductions.amount,
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
                        text: "#${Deductions.id.toString()}",
                        size: 14.sp,
                        color: AppColors.greyColor,
                        fontWeight: FontWeight.w700,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      CustomText(
                        text: Deductions.title!,
                        size: 16.sp,
                        color: Theme.of(context).colorScheme.textClrChange,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      if (Deductions.amount?.toString().isNotEmpty ?? false)
                        currencyPosition == "before"
                            ? CustomText(
                          text: "$currency ${Deductions.amount!}",
                          size: 16.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w600,
                        )
                            : CustomText(
                          text: "${Deductions.amount!} $currency ",
                          size: 16.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w600,
                        ),
                      if ((Deductions.percentage?.toString().isNotEmpty ?? false))
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 0),
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
                                      value: Deductions.percentage!.toDouble(),
                                      min: 0,
                                      max: 100,
                                      divisions: 100,
                                      onChanged: (v) {},
                                      label: "${Deductions.percentage!.toInt()}%",
                                    ),
                                  ),
                                ),
                                CustomText(
                                  text: "${Deductions.percentage!.toInt()}%",
                                  size: 15.sp,
                                  color: Theme.of(context).colorScheme.textClrChange,
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
          onDismissed: (DismissDirection direction) {
            if (direction == DismissDirection.endToStart &&
                context.read<PermissionsBloc>().isdeleteDeduction == true) {
              WidgetsBinding.instance.addPostFrameCallback((_) {   setState(() {
                DeductionsList.removeAt(index);
              });
              _onDeleteDeductions(Deductions.id);

              });
            }
          },
        ));
  }
  void _validateInput(String? value, BuildContext context) {
    if (value != null && value.isNotEmpty) {
      try {
        final doubleValue = double.parse(value);
        if (doubleValue < 0) {
          flutterToastCustom(
            msg: AppLocalizations.of(context)!.negativeValueNotAllowed,
            color: AppColors.red, // Use red for errors
          );
        }
      } catch (e) {
        flutterToastCustom(
          msg: AppLocalizations.of(context)!.invalidNumberFormat,
          color: AppColors.red, // Use red for errors
        );
      }
    }
  }
  void _filterDialog(BuildContext context, isLightTheme) {
    showModalBottomSheet(
        backgroundColor: Theme.of(context).colorScheme.containerDark,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
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
                    TaxTypeField(
                      access: DeductionTypeFilter.value,
                      isRequired: true,
                      isCreate: false,
                      isFilter: true,
                      from: "type",
                      onSelected: (value) {
                        filterType.value = true;
                        DeductionTypeFilter.value = value.toLowerCase();
                      },
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 18.w, vertical: 10.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              context.read<DeductionBloc>().add(
                                  SearchDeductions(
                                      searchWord, DeductionTypeFilter.value));
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
                                Navigator.of(context).pop();

                                DeductionTypeFilter.value = "";
                                filterType.value = false;
                                context.read<DeductionBloc>().add(
                                    SearchDeductions(
                                        searchWord, ""));
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