// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:heroicons/heroicons.dart';
// import 'package:taskify/config/colors.dart';
// import 'package:taskify/data/model/work_anniversary/work_anni_model.dart';
//
// import '../../../bloc/birthday/birthday_bloc.dart';
// import '../../../bloc/birthday/birthday_event.dart';
// import '../../../bloc/client/client_bloc.dart';
// import '../../../bloc/client/client_event.dart';
// import '../../../bloc/client/client_state.dart';
// import '../../../bloc/clients/client_bloc.dart';
// import '../../../bloc/clients/client_state.dart';
// import '../../../bloc/theme/theme_bloc.dart';
// import '../../../bloc/theme/theme_state.dart';
// import '../../../bloc/user/user_bloc.dart';
// import '../../../bloc/user/user_event.dart';
// import '../../../bloc/user/user_state.dart';
// import '../../../bloc/work_anniveresary/work_anniversary_bloc.dart';
// import '../../../bloc/work_anniveresary/work_anniversary_event.dart';
// import '../../../bloc/work_anniveresary/work_anniversary_state.dart';
// import '../../../config/constants.dart';
// import '../../../routes/routes.dart';
// import '../../../utils/custom_text.dart';
// import '../../../utils/widgets/custom_text.dart';
// import '../../../utils/widgets/my_theme.dart';
// import '../../../utils/widgets/no_data.dart';
// import '../../../utils/widgets/notes_shimmer_widget.dart';
// import '../../widgets/custom_cancel_create_button.dart';
// import '../widgets/custom_number_picker_dialog.dart';
// import '../widgets/list_of_user.dart';
//
//
// class UpcomingWorkAnniversary extends StatefulWidget {
//   const UpcomingWorkAnniversary({super.key});
//
//   @override
//   State<UpcomingWorkAnniversary> createState() => _UpcomingWorkAnniversaryState();
// }
//
// class _UpcomingWorkAnniversaryState extends State<UpcomingWorkAnniversary> {
//   final TextEditingController _userSearchController = TextEditingController();
//   final TextEditingController _clientSearchController = TextEditingController();
//   final TextEditingController dayController = TextEditingController();
//   String searchWord = "";
//   String searchWordClient = "";
//   final ValueNotifier<int> _currentValue = ValueNotifier<int>(7);
//   List<String> selectedUserNames = [];
//   List<String> selectedClientNames = [];
//   List<int> selectedUserIds = [];
//   List<int> selectedClientIds = [];
//
//   @override
//   void initState() {
//     super.initState();
//     dayController.text = _currentValue.value.toString();
//     dayController.addListener(() {
//       int? newValue = int.tryParse(dayController.text);
//       if (newValue != null && newValue >= 1 && newValue <= 366) {
//         _currentValue.value = newValue;
//       }
//     });
//     BlocProvider.of<UserBloc>(context).add(UserList());
//     BlocProvider.of<ClientBloc>(context).add(ClientList());
//     BlocProvider.of<WorkAnniversaryBloc>(context).add(WeekWorkAnniversaryList([],[],7));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final themeBloc = context.read<ThemeBloc>();
//     final currentTheme = themeBloc.currentThemeState;
//     bool isLightTheme = currentTheme is LightThemeState;
//
//     return BlocBuilder<WorkAnniversaryBloc, WorkAnniversaryState>(
//       builder: (context, state) {
//         if (state is WorkAnniversaryPaginated) {
//           selectedUserIds = state.selectedUserIds;
//           selectedUserNames = state.selectedUserNames;
//           selectedClientIds = state.selectedClientIds;
//           selectedClientNames = state.selectedClientNames;
//         }
//
//         return Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding:  EdgeInsets.symmetric(horizontal: 18.w),
//                   child: titleTask(
//                     context,
//                     AppLocalizations.of(context)!.upcomingWorkAnni,
//                   ),
//                 ),
//               ],
//             ),
//             _workAnniFilter(dayController, selectedUserIds, selectedClientIds),
//             _workAnniBloc(isLightTheme, selectedUserIds, selectedClientIds)
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _workAnniFilter(TextEditingController dayController, List<int> selectedUserIds, List<int> selectedClientIds) {
//     return Padding(
//       padding: EdgeInsets.only(left: 18.w, right: 18.w, top: 20.h),
//       child: SizedBox(
//         height: 50.h,
//         width: double.infinity,  // Ensures it has a width
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: IntrinsicWidth(  // ✅ Constrains Row inside SingleChildScrollView
//             child: Row(
//               children: [
//                 _selectMembers(selectedUserIds),
//                 SizedBox(width: 10.w),
//                 _selectClient(selectedClientIds),
//                 SizedBox(width: 10.w),
//                 _selectDays(dayController),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _selectMembers(List<int> selectedUserIds) {
//     return Expanded(
//       flex: 1,
//       child: InkWell(
//         onTap: () async {
//           showDialog(
//             context: context,
//             builder: (ctx) => BlocBuilder<UserBloc, UserState>(
//               builder: (context, state) {
//                 if (state is UserPaginated) {
//                   ScrollController scrollController = ScrollController();
//                   scrollController.addListener(() {
//                     if (scrollController.position.atEdge) {
//                       if (scrollController.position.pixels != 0) {
//                         BlocProvider.of<UserBloc>(context)
//                             .add(UserLoadMore(searchWord));
//                       }
//                     }
//                   });
//
//                   return StatefulBuilder(builder: (BuildContext context,
//                       void Function(void Function()) setState) {
//                     return AlertDialog(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                             10.r), // Set the desired radius here
//                       ),
//                       backgroundColor:
//                       Theme.of(context).colorScheme.alertBoxBackGroundColor,
//                       contentPadding: EdgeInsets.zero,
//                       title: Center(
//                         child: Column(
//                           children: [
//                             CustomText(
//                               text: AppLocalizations.of(context)!.selectusers,
//                               fontWeight: FontWeight.w800,
//                               size: 20,
//                               color: Theme.of(context)
//                                   .colorScheme
//                                   .whitepurpleChange,
//                             ),
//                             const Divider(),
//                             Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 0.w),
//                               child: SizedBox(
//                                 height: 35.h,
//                                 width: double.infinity,
//                                 child: TextField(
//                                   cursorColor: AppColors.greyForgetColor,
//                                   cursorWidth: 1,
//                                   controller: _userSearchController,
//                                   decoration: InputDecoration(
//                                     contentPadding: EdgeInsets.symmetric(
//                                       vertical: (35.h - 20.sp) / 2,
//                                       horizontal: 10.w,
//                                     ),
//                                     hintText:
//                                     AppLocalizations.of(context)!.search,
//                                     enabledBorder: OutlineInputBorder(
//                                       borderSide: BorderSide(
//                                         color: AppColors
//                                             .greyForgetColor, // Set your desired color here
//                                         width:
//                                         1.0, // Set the border width if needed
//                                       ),
//                                       borderRadius: BorderRadius.circular(
//                                           10.0), // Optional: adjust the border radius
//                                     ),
//                                     focusedBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(10.0),
//                                       borderSide: BorderSide(
//                                         color: AppColors
//                                             .purple, // Border color when TextField is focused
//                                         width: 1.0,
//                                       ),
//                                     ),
//                                   ),
//                                   onChanged: (value) {
//                                     setState(() {
//                                       searchWord = value;
//                                     });
//
//                                     context
//                                         .read<UserBloc>()
//                                         .add(SearchUsers(value));
//                                   },
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 10.h,
//                             )
//                           ],
//                         ),
//                       ),
//                       content: Container(
//                         constraints: BoxConstraints(maxHeight: 900.h),
//                         width: MediaQuery.of(context).size.width,
//                         child: BlocBuilder<UserBloc, UserState>(
//                             builder: (context, state) {
//                               if (state is UserPaginated) {
//                                 ScrollController scrollController =
//                                 ScrollController();
//                                 scrollController.addListener(() {
//                                   if (scrollController.position.atEdge) {
//                                     if (scrollController.position.pixels != 0) {
//                                       BlocProvider.of<UserBloc>(context)
//                                           .add(UserLoadMore(searchWord));
//                                     }
//                                   }
//                                 });
//                                 return ListView.builder(
//                                     controller: scrollController,
//                                     shrinkWrap: true,
//                                     itemCount: state.hasReachedMax
//                                         ? state.user.length
//                                         : state.user.length + 1,
//                                     itemBuilder: (BuildContext context, int index) {
//                                       if (index < state.user.length) {
//                                         final isSelected = selectedUserIds
//                                             .contains(state.user[index].id!);
//
//                                         return Padding(
//                                           padding: EdgeInsets.symmetric(
//                                               horizontal: 20.h, vertical: 5.h),
//                                           child: InkWell(
//                                               splashColor: Colors.transparent,
//                                               onTap: () {
//                                                 setState(() {
//                                                   final isSelected =
//                                                   selectedUserIds.contains(
//                                                       state.user[index].id!);
//
//                                                   if (isSelected) {
//                                                     // Remove the selected ID and corresponding username
//                                                     final removeIndex =
//                                                     selectedUserIds.indexOf(
//                                                         state.user[index].id!);
//                                                     selectedUserIds.removeAt(
//                                                         removeIndex); // Sync with widget.usersid
//                                                     selectedUserNames.removeAt(
//                                                         removeIndex); // Remove corresponding username
//                                                   } else {
//                                                     // Add the selected ID and corresponding username
//                                                     selectedUserIds
//                                                         .add(state.user[index].id!);
//                                                     // Sync with widget.usersid
//                                                     selectedUserNames.add(state
//                                                         .user[index]
//                                                         .firstName!); // Add corresponding username
//                                                   }
//
//                                                   // Trigger any necessary UI or Bloc updates
//                                                   BlocProvider.of<
//                                                       WorkAnniversaryBloc>(
//                                                       context)
//                                                       .add(WeekWorkAnniversaryList(
//                                                       selectedUserIds,
//                                                       selectedClientIds,
//                                                       _currentValue.value));
//
//                                                   _handleUserSelection(
//                                                       selectedUserNames,
//                                                       selectedUserIds,
//                                                       selectedClientIds);
//                                                   BlocProvider.of<UserBloc>(context)
//                                                       .add(SelectedUser(
//                                                       index,
//                                                       state.user[index]
//                                                           .firstName!));
//                                                   BlocProvider.of<UserBloc>(context)
//                                                       .add(ToggleUserSelection(
//                                                       index,
//                                                       state.user[index]
//                                                           .firstName!));
//                                                 });
//                                               },
//                                               child: ListOfUser(
//                                                 isSelected: isSelected,
//                                                 user: state.user[index],
//                                               )),
//                                         );
//                                       } else {
//                                         return Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               vertical: 0),
//                                           child: Center(
//                                             child: state.hasReachedMax
//                                                 ? const Text('')
//                                                 : const SpinKitFadingCircle(
//                                               color: AppColors.primary,
//                                               size: 40.0,
//                                             ),
//                                           ),
//                                         );
//                                       }
//                                     });
//                               }
//                               return Container();
//                             }),
//                       ),
//                       actions: <Widget>[
//                         Padding(
//                           padding: EdgeInsets.only(top: 20.h),
//                           child: CreateCancelButtom(
//                             title: AppLocalizations.of(context)!.ok,
//                             onpressCancel: () {
//                               _userSearchController.clear();
//                               selectedUserIds=[];
//                               selectedUserNames=[];
//                               _handleUserSelection([], [], []);
//                               Navigator.pop(context);
//                             },
//                             onpressCreate: () {
//                               _userSearchController.clear();
//                               Navigator.pop(context);
//                             },
//                           ),
//                         ),
//                       ],
//                     );
//                   });
//                 }
//                 return Container();
//               },
//             ),
//           );
//         },
//         child: Container(
//           alignment: Alignment.center,
//           height: 40.h,
//           decoration: BoxDecoration(
//               border: Border.all(color: AppColors.greyColor, width: 0.5),
//               color: Theme.of(context).colorScheme.containerDark,
//               borderRadius:
//               BorderRadius.circular(12)), // Set the height of the dropdown
//           child: Center(
//             child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 10.w),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: CustomText(
//                         text: selectedUserNames.isNotEmpty
//                             ? selectedUserNames.join(", ")
//                             : AppLocalizations.of(context)!.selectmembers,
//                         color: Theme.of(context).colorScheme.textClrChange,
//                         size: 14.sp,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 )),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _selectClient(List<int> selectedClientIds) {
//     return Expanded(
//       flex: 1,
//       child: InkWell(
//         onTap: () async {
//           showDialog(
//             context: context,
//             builder: (ctx) => BlocBuilder<ClientBloc, ClientState>(
//               builder: (context, state) {
//                 print("gfnv m, $state");
//                 if (state is ClientLoading) {
//                   return const SpinKitFadingCircle(
//                     color: AppColors.primary,
//                     size: 40.0,
//                   );
//                 }
//                 if (state is ClientSuccess) {
//                   ScrollController scrollController = ScrollController();
//                   scrollController.addListener(() {
//                     if (scrollController.position.atEdge) {
//                       if (scrollController.position.pixels != 0) {
//                         BlocProvider.of<ClientBloc>(context)
//                             .add(ClientLoadMore(searchWordClient));
//                       }
//                     }
//                   });
//
//                   return StatefulBuilder(builder: (BuildContext context,
//                       void Function(void Function()) setState) {
//                     return AlertDialog(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                             10.r), // Set the desired radius here
//                       ),
//                       backgroundColor:
//                       Theme.of(context).colorScheme.alertBoxBackGroundColor,
//                       contentPadding: EdgeInsets.zero,
//                       title: Center(
//                         child: SizedBox(
//                           width: MediaQuery.of(context).size.width * 0.9,
//                           child: Column(
//                             children: [
//                               CustomText(
//                                 text: AppLocalizations.of(context)!.selectuser,
//                                 fontWeight: FontWeight.w800,
//                                 size: 20,
//                                 color: Theme.of(context)
//                                     .colorScheme
//                                     .whitepurpleChange,
//                               ),
//                               const Divider(),
//                               Padding(
//                                 padding: EdgeInsets.symmetric(horizontal: 0.w),
//                                 child: SizedBox(
//                                   height: 35.h,
//                                   width: double.infinity,
//                                   child: TextField(
//                                     cursorColor: AppColors.greyForgetColor,
//                                     cursorWidth: 1,
//                                     controller: _clientSearchController,
//                                     decoration: InputDecoration(
//                                       contentPadding: EdgeInsets.symmetric(
//                                         vertical: (35.h - 20.sp) / 2,
//                                         horizontal: 10.w,
//                                       ),
//                                       hintText:
//                                       AppLocalizations.of(context)!.search,
//                                       enabledBorder: OutlineInputBorder(
//                                         borderSide: BorderSide(
//                                           color: AppColors
//                                               .greyForgetColor, // Set your desired color here
//                                           width:
//                                           1.0, // Set the border width if needed
//                                         ),
//                                         borderRadius: BorderRadius.circular(
//                                             10.0), // Optional: adjust the border radius
//                                       ),
//                                       focusedBorder: OutlineInputBorder(
//                                         borderRadius:
//                                         BorderRadius.circular(10.0),
//                                         borderSide: BorderSide(
//                                           color: AppColors
//                                               .purple, // Border color when TextField is focused
//                                           width: 1.0,
//                                         ),
//                                       ),
//                                     ),
//                                     onChanged: (value) {
//                                       setState(() {
//                                         searchWordClient = value;
//                                       });
//
//                                       context
//                                           .read<ClientBloc>()
//                                           .add(SearchClients(value));
//                                     },
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 5.h,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       content: Container(
//                         constraints: BoxConstraints(maxHeight: 900.h),
//                         width: MediaQuery.of(context).size.width,
//                         child: ListView.builder(
//                             controller: scrollController,
//                             shrinkWrap: true,
//                             itemCount: state.clients.length,
//                             itemBuilder: (BuildContext context, int index) {
//                               final isSelected = selectedClientIds
//                                   .contains(state.clients[index].id!);
//                               return Padding(
//                                 padding: EdgeInsets.symmetric(vertical: 5.h),
//                                 child: InkWell(
//                                   splashColor: Colors.transparent,
//                                   onTap: () {
//                                     setState(() {
//                                       if (isSelected) {
//                                         selectedClientIds
//                                             .remove(state.clients[index].id!);
//                                         selectedClientNames.remove(
//                                             state.clients[index].firstName!);
//                                       } else {
//                                         selectedClientIds
//                                             .add(state.clients[index].id!);
//                                         selectedClientNames
//                                             .add(state.clients[index].firstName!);
//                                       }
//
//                                       BlocProvider.of<ClientBloc>(context).add(
//                                           SelectedClient(index,
//                                               state.clients[index].firstName!));
//                                       BlocProvider.of<ClientBloc>(context).add(
//                                         ToggleClientSelection(
//                                           index,
//                                           state.clients[index].firstName!,
//                                         ),
//                                       );
//                                     });
//                                   },
//                                   child: Padding(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: 20.w,
//                                     ),
//                                     child: Container(
//                                       width: double.infinity,
//                                       height: 35.h,
//                                       decoration: BoxDecoration(
//                                         color: isSelected
//                                             ? AppColors.primary
//                                             : Colors.transparent,
//                                       ),
//                                       child: Center(
//                                         child: CustomText(
//                                           text: state.clients[index].firstName!,
//                                           fontWeight: FontWeight.w400,
//                                           size: 18,
//                                           color: AppColors.whiteColor,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }),
//                       ),
//                       actions: <Widget>[
//                         Padding(
//                           padding: EdgeInsets.only(top: 20.h),
//                           child: CreateCancelButtom(
//                             title: AppLocalizations.of(context)!.ok,
//                             onpressCancel: () {
//                               Navigator.pop(context);
//                             },
//                             onpressCreate: () {
//                               Navigator.pop(context);
//                             },
//                           ),
//                         ),
//                       ],
//                     );
//                   });
//                 }
//                 if (state is ClientPaginated) {
//                   ScrollController scrollController = ScrollController();
//                   scrollController.addListener(() {
//                     if (scrollController.position.atEdge) {
//                       if (scrollController.position.pixels != 0) {
//                         BlocProvider.of<ClientBloc>(context)
//                             .add(ClientLoadMore(searchWord));
//                       }
//                     }
//                   });
//
//                   return StatefulBuilder(builder: (BuildContext context,
//                       void Function(void Function()) setState) {
//                     return AlertDialog(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                             10.r), // Set the desired radius here
//                       ),
//                       backgroundColor:
//                       Theme.of(context).colorScheme.alertBoxBackGroundColor,
//                       contentPadding: EdgeInsets.zero,
//                       title: Center(
//                         child: Column(
//                           children: [
//                             CustomText(
//                               text: AppLocalizations.of(context)!.selectclient,
//                               fontWeight: FontWeight.w800,
//                               size: 20,
//                               color: Theme.of(context)
//                                   .colorScheme
//                                   .whitepurpleChange,
//                             ),
//                             const Divider(),
//                             SizedBox(
//                               height: 35.h,
//                               width: double.infinity,
//                               child: TextField(
//                                 cursorColor: AppColors.greyForgetColor,
//                                 cursorWidth: 1,
//                                 controller: _clientSearchController,
//                                 decoration: InputDecoration(
//                                   contentPadding: EdgeInsets.symmetric(
//                                     vertical: (35.h - 20.sp) / 2,
//                                     horizontal: 10.w,
//                                   ),
//                                   hintText:
//                                   AppLocalizations.of(context)!.search,
//                                   enabledBorder: OutlineInputBorder(
//                                     borderSide: BorderSide(
//                                       color: AppColors
//                                           .greyForgetColor, // Set your desired color here
//                                       width:
//                                       1.0, // Set the border width if needed
//                                     ),
//                                     borderRadius: BorderRadius.circular(
//                                         10.0), // Optional: adjust the border radius
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10.0),
//                                     borderSide: BorderSide(
//                                       color: AppColors
//                                           .purple, // Border color when TextField is focused
//                                       width: 1.0,
//                                     ),
//                                   ),
//                                 ),
//                                 onChanged: (value) {
//                                   setState(() {
//                                     searchWord = value;
//                                   });
//                                   context
//                                       .read<ClientBloc>()
//                                       .add(SearchClients(value));
//                                 },
//                               ),
//                             ),
//                             SizedBox(
//                               height: 10.h,
//                             )
//                           ],
//                         ),
//                       ),
//                       content: Container(
//                           constraints: BoxConstraints(maxHeight: 900.h),
//                           width: MediaQuery.of(context).size.width,
//                           child:ListView.builder(
//                               controller: scrollController,
//                               shrinkWrap: true,
//                               itemCount: state.hasReachedMax
//                                   ? state.clients.length
//                                   : state.clients.length + 1,
//                               itemBuilder: (BuildContext context, int index) {
//                                 if (index < state.clients.length) {
//                                   final isSelected = selectedClientIds
//                                       .contains(state.clients[index].id!);
//
//                                   return Padding(
//                                     padding: EdgeInsets.symmetric(
//                                         horizontal: 20.h, vertical: 5.h),
//                                     child: InkWell(
//                                         splashColor: Colors.transparent,
//                                         onTap: () {
//                                           setState(() {
//                                             final isSelected =
//                                             selectedClientIds.contains(
//                                                 state.clients[index].id!);
//
//                                             if (isSelected) {
//                                               // Remove the selected ID and corresponding username
//                                               final removeIndex =
//                                               selectedClientIds.indexOf(
//                                                   state.clients[index].id!);
//                                               selectedClientIds.removeAt(
//                                                   removeIndex); // Sync with widget.usersid
//                                               selectedClientNames.removeAt(
//                                                   removeIndex); // Remove corresponding username
//                                             } else {
//                                               // Add the selected ID and corresponding username
//                                               selectedClientIds
//                                                   .add(state.clients[index].id!);
//                                               // Sync with widget.usersid
//                                               selectedClientNames.add(state
//                                                   .clients[index]
//                                                   .firstName!); // Add corresponding username
//                                             }
//
//                                             // Trigger any necessary UI or Bloc updates
//                                             BlocProvider.of<WorkAnniversaryBloc>(context)
//                                                 .add(WeekWorkAnniversaryList(
//                                                 selectedUserIds,
//                                                 selectedClientIds,
//                                                 _currentValue.value));
//                                             _handleClientSelection(
//                                                 selectedClientNames,
//                                                 selectedClientIds,
//                                                 selectedUserIds);
//                                           });
//                                         },
//                                         child: ListOfUser(
//                                           isUser: false,
//                                           isSelected: isSelected,
//                                           client: state.clients[index],
//                                         )),
//                                   );
//                                 } else {
//                                   return Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 0),
//                                     child: Center(
//                                       child: state.hasReachedMax
//                                           ? const Text('')
//                                           : const SpinKitFadingCircle(
//                                         color: AppColors.primary,
//                                         size: 40.0,
//                                       ),
//                                     ),
//                                   );
//                                 }
//                               })
//
//                       ),
//                       actions: <Widget>[
//                         Padding(
//                           padding: EdgeInsets.only(top: 20.h),
//                           child: CreateCancelButtom(
//                             title: AppLocalizations.of(context)!.ok,
//                             onpressCancel: () {
//                               _clientSearchController.clear();
//                               selectedClientIds=[];
//                               selectedClientNames=[];
//                               _handleClientSelection([], [], []);
//                               Navigator.pop(context);
//                             },
//                             onpressCreate: () {
//                               _clientSearchController.clear();
//                               Navigator.pop(context);
//                             },
//                           ),
//                         ),
//                       ],
//                     );
//                   });
//                 }
//                 return Container();
//               },
//             ),
//           );
//         },
//         child: Container(
//           alignment: Alignment.center,
//           height: 40.h,
//           decoration: BoxDecoration(
//               border: Border.all(color: AppColors.greyColor, width: 0.5),
//               color: Theme.of(context).colorScheme.containerDark,
//               borderRadius:
//               BorderRadius.circular(12)), // Set the height of the dropdown
//           child: Center(
//             child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 10.w),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: CustomText(
//                         text: selectedClientNames.isNotEmpty
//                             ?selectedClientNames.join(", ")
//                             : AppLocalizations.of(context)!.selectclient,
//                         color: Theme.of(context).colorScheme.textClrChange,
//                         size: 14.sp,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 )),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _selectDays(TextEditingController dayController) {
//     return Expanded(
//       flex: 1,
//       child: InkWell(
//         onTap: () async {},
//         child: ValueListenableBuilder<int>(
//           valueListenable: _currentValue,
//           builder: (context, value, child) {
//             return Container(
//               alignment: Alignment.center,
//               height: 40.h,
//               decoration: BoxDecoration(
//                 border: Border.all(color: AppColors.greyColor, width: 0.5),
//                 color: Theme.of(context).colorScheme.containerDark,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Center(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 10.w),
//                   child: InkWell(
//                     onTap: () {
//                       _showNumberPickerDialog(dayController);
//                     },
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Center(
//                           child: CustomText(
//                             text: value == 7
//                                 ? AppLocalizations.of(context)!.sevendays
//                                 : "$value ${AppLocalizations.of(context)!.days}",
//                             color: Theme.of(context).colorScheme.textClrChange,
//                             size: 14.sp,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         value == 7
//                             ? SizedBox.shrink()
//                             : InkWell(
//                           onTap: () {
//                             _currentValue.value = 7;
//                             dayController.text = "7";
//                             BlocProvider.of<BirthdayBloc>(context)
//                                 .add(WeekBirthdayList(7, [], []));
//                           },
//                           child: Container(
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: AppColors.greyColor,
//                             ),
//                             child: Padding(
//                               padding: EdgeInsets.all(5.h),
//                               child: HeroIcon(
//                                 HeroIcons.xMark,
//                                 style: HeroIconStyle.outline,
//                                 color: AppColors.pureWhiteColor,
//                                 size: 15.sp,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _workAnniList(bool isLightTheme, List<WorkAnniversaryModel> anniState, bool hasReachedMax) {
//     return Container(
//       alignment: Alignment.centerLeft,
//       height: 260.h,
//       child: ListView.builder(
//           padding: EdgeInsets.only(right: 18.w, top: 10.h, bottom: 15.h),
//           scrollDirection: Axis.horizontal,
//           shrinkWrap: true,
//           itemCount: hasReachedMax ? anniState.length : anniState.length + 1,
//           itemBuilder: (context, index) {
//             if (index < anniState.length) {
//               var workAnniversary = anniState[index];
//               String? doj = formatDateFromApi(workAnniversary.doj!, context);
//
//               return InkWell(
//                 highlightColor: Colors.transparent,
//                 splashColor: Colors.transparent,
//                 onTap: () {
//                   router.push('/userdetail', extra: {
//                     "id": workAnniversary.id,
//                   });
//                 },
//                 child: Padding(
//                     padding:
//                     EdgeInsets.only(top: 10.h, bottom: 10.h, left: 18.w),
//                     child: Container(
//                       height: 140.h,
//                       decoration: BoxDecoration(
//                           boxShadow: [
//                             isLightTheme
//                                 ? MyThemes.lightThemeShadow
//                                 : MyThemes.darkThemeShadow,
//                           ],
//                           color: Theme.of(context).colorScheme.containerDark,
//                           borderRadius: BorderRadius.circular(12)),
//                       width: 250.w,
//                       child: Padding(
//                         padding: EdgeInsets.symmetric(
//                             horizontal: 18.w, vertical: 12.h),
//                         child: SizedBox(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   SizedBox(
//                                     child: CircleAvatar(
//                                       radius: 40.w,
//                                       backgroundColor: Theme.of(context)
//                                           .colorScheme
//                                           .backGroundColor,
//                                       child: CircleAvatar(
//                                         radius:
//                                         40.w,
//                                         backgroundImage: NetworkImage(
//                                             workAnniversary.photo!),
//                                         backgroundColor: Colors.grey[
//                                         200],
//                                       ),
//                                     ),
//                                   ),
//                                  workAnniversary.anniversaryCount == 0?SizedBox():   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                     children: [
//                                       RichText(
//                                         text: TextSpan(
//                                           children: [
//                                             TextSpan(
//                                               text:
//                                               "${workAnniversary.anniversaryCount!}",
//                                               style: TextStyle(
//                                                 fontSize: 40
//                                                     .sp,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Theme.of(context)
//                                                     .colorScheme
//                                                     .textClrChange,
//                                               ),
//                                             ),
//                                             WidgetSpan(
//                                               child: Transform.translate(
//                                                 offset: Offset(0,
//                                                     -10),
//                                                 child: CustomText(
//                                                   text:
//                                                   "${getOrdinalSuffix(workAnniversary.anniversaryCount!)}",
//
//                                                   size: 18
//                                                       .sp,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Theme.of(context)
//                                                       .colorScheme
//                                                       .textClrChange,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       CustomText(
//                                         text:
//                                         "${AppLocalizations.of(context)!.anniToday}",
//                                         size: 12.sp,
//                                         color: AppColors.projDetailsSubText,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(
//                                 height: 10.w,
//                               ),
//                               CustomText(
//                                 text: workAnniversary.member
//                                 !,
//                                 size: 22.sp,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 fontWeight: FontWeight.bold,
//                                 color:
//                                 Theme.of(context).colorScheme.textClrChange,
//                               ),
//                               workAnniversary.daysLeft! == 0
//                                   ? CustomText(
//                                 text:
//                                 " ${AppLocalizations.of(context)!.today}",
//                                 size: 16.sp,
//                                 color: AppColors.projDetailsSubText,
//                                 fontWeight: FontWeight.w600,
//                               )
//                                   : CustomText(
//                                 text:
//                                 "${AppLocalizations.of(context)!.daysLeft} ${workAnniversary.daysLeft!.toString()}",
//                                 size: 14.sp,
//                                 color: AppColors.projDetailsSubText,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   workAnniversary.daysLeft!.toString() == "0"
//                                       ? SizedBox()
//                                       : CustomText(
//                                     text: AppLocalizations.of(context)!
//                                         .daysLeft,
//                                     color: Colors.grey[400]!,
//                                     size: 10.sp,
//                                   ),
//                                   workAnniversary.daysLeft!.toString() == "0"
//                                       ? SizedBox(
//                                     height: 20.h,
//                                   )
//                                       : SizedBox(),
//                                   Row(
//                                     mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.center,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           const HeroIcon(
//                                             HeroIcons.cake,
//                                             style: HeroIconStyle.outline,
//                                             color: AppColors.blueColor,
//                                           ),
//                                           SizedBox(
//                                             width: 10.w,
//                                           ),
//                                           CustomText(
//                                             text: doj,
//                                             color: AppColors.greyColor,
//                                             size: 14,
//                                             fontWeight: FontWeight.w500,
//                                           )
//                                         ],
//                                       ),
//                                       workAnniversary.daysLeft!.toString() ==
//                                           "0"
//                                           ? SizedBox()
//                                           : Container(
//                                         padding: EdgeInsets.all(8.w),
//                                         decoration: BoxDecoration(
//                                           color: Theme.of(context)
//                                               .colorScheme
//                                               .textClrChange,
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: Text(
//                                           "${workAnniversary.daysLeft!.toString()}",
//                                           style: TextStyle(
//                                             color: Theme.of(context)
//                                                 .colorScheme
//                                                 .lightWhite,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     )),
//               );
//             } else {
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 0),
//                 child: Center(
//                   child: hasReachedMax
//                       ? const Text('')
//                       : const SpinKitFadingCircle(
//                     color: AppColors.primary,
//                     size: 40.0,
//                   ),
//                 ),
//               );
//             }
//           }),
//     );
//   }
//
//   Widget _workAnniBloc(bool isLightTheme, List<int> selectedUserIds, List<int> selectedClientIds) {
//     return BlocBuilder<WorkAnniversaryBloc, WorkAnniversaryState>(
//       builder: (context, state) {
//         if (state is TodaysWorkAnniversaryLoading) {
//           return const Center(
//             child: SpinKitFadingCircle(
//               color: AppColors.primary,
//               size: 40.0,
//             ),
//           );
//         } else if (state is WorkAnniversaryPaginated) {
//           return NotificationListener<ScrollNotification>(
//             onNotification: (scrollInfo) {
//               if (!state.hasReachedMax &&
//                   scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
//                 context.read<WorkAnniversaryBloc>().add(
//                   LoadMoreWorkAnniversary(_currentValue.value, selectedUserIds)
//                 );
//               }
//               return false;
//             },
//             child: state.workAnniversaries.isNotEmpty
//                 ? _workAnniList(isLightTheme, state.workAnniversaries, state.hasReachedMax)
//                 : Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
//                     child: Container(
//                       padding: EdgeInsets.symmetric(vertical: 15.h),
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         boxShadow: [
//                           isLightTheme
//                               ? MyThemes.lightThemeShadow
//                               : MyThemes.darkThemeShadow,
//                         ],
//                         color: Theme.of(context).colorScheme.containerDark,
//                         borderRadius: BorderRadius.circular(12)
//                       ),
//                       child: NoData(isImage: false),
//                     ),
//                   )
//           );
//         } else if (state is WorkAnniversaryError) {
//           return Center(
//             child: Text(
//               state.message,
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.textClrChange,
//                 fontSize: 16.sp,
//               ),
//             ),
//           );
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }
//
//   void _handleUserSelection(List<String> userNames, List<int> userIds, List<int> selectedClientIds) {
//     context.read<WorkAnniversaryBloc>().add(UpdateSelectedUsers(userIds, userNames));
//     context.read<WorkAnniversaryBloc>().add(WeekWorkAnniversaryList(
//       userIds,
//       selectedClientIds,
//       _currentValue.value,
//     ));
//   }
//
//   void _handleClientSelection(List<String> clientNames, List<int> clientIds, List<int> selectedUserIds) {
//     context.read<WorkAnniversaryBloc>().add(UpdateSelectedClients(clientIds, clientNames));
//     context.read<WorkAnniversaryBloc>().add(WeekWorkAnniversaryList(
//       selectedUserIds,
//       clientIds,
//       _currentValue.value,
//     ));
//   }
//
//   void _showNumberPickerDialog(TextEditingController dayController) {
//     final themeBloc = context.read<ThemeBloc>();
//     final currentTheme = themeBloc.currentThemeState;
//     showDialog(
//       context: context,
//       builder: (context) => CustomNumberPickerDialog(
//         dayController: dayController,
//         currentValue: _currentValue,
//         isLightTheme: currentTheme is LightThemeState,
//         onSubmit: (value) {
//           BlocProvider.of<WorkAnniversaryBloc>(context).add(
//               WeekWorkAnniversaryList(selectedUserIds, selectedClientIds, _currentValue.value));
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/widgets/no_data.dart';

import '../../../bloc/clients/client_bloc.dart';
import '../../../bloc/clients/client_event.dart';
import '../../../bloc/clients/client_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/user/user_bloc.dart';
import '../../../bloc/user/user_event.dart';
import '../../../bloc/user/user_state.dart';
import '../../../bloc/work_anniveresary/work_anniversary_bloc.dart';
import '../../../bloc/work_anniveresary/work_anniversary_event.dart';
import '../../../bloc/work_anniveresary/work_anniversary_state.dart';
import '../../../config/constants.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../routes/routes.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../notes/widgets/notes_shimmer_widget.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../home_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/number_picker.dart';

class UpcomingWorkAnniversary extends StatefulWidget {
  final Function(List<String>, List<int>) onSelected;
  const UpcomingWorkAnniversary({super.key, required this.onSelected});

  @override
  State<UpcomingWorkAnniversary> createState() =>
      _UpcomingWorkAnniversaryState();
}

class _UpcomingWorkAnniversaryState extends State<UpcomingWorkAnniversary> {
  final TextEditingController _userSearchController = TextEditingController();
  final TextEditingController _clientSearchController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  String searchWord = "";
  String searchWordClient = "";
  List<int> userSelectedId = [];
  List<String> userSelectedname = [];
  List<int> clientSelectedId = [];
  List<String> clientSelectedname = [];
  final ValueNotifier<int> _currentValue =
  ValueNotifier<int>(7); // Using ValueNotifier
  @override
  void initState() {
    super.initState();
    dayController.text = _currentValue.value.toString(); // Sync initial text
    dayController.addListener(() {
      int? newValue = int.tryParse(dayController.text);
      if (newValue != null && newValue >= 1 && newValue <= 366) {
        _currentValue.value = newValue; // Notify listeners
      }
    });
    BlocProvider.of<UserBloc>(context).add(UserList());
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            titleTask(
              context,
              AppLocalizations.of(context)!.upcomingWorkAnni,
            ),
          ],
        ),
        _workAnniFilter(dayController),
        _workAnniBloc(isLightTheme)
      ],
    );
  }
  Widget _workAnniFilter(TextEditingController dayController) {
    return Padding(
      padding: EdgeInsets.only(left: 18.w, right: 18.w, top: 20.h),
      child: SizedBox(
        height: 50.h,
        width: double.infinity,  // Ensures it has a width
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicWidth(  // ✅ Constrains Row inside SingleChildScrollView
            child: Row(
              children: [
                _selectMembers(),
                SizedBox(width: 10.w),
                _selectClient(),
                SizedBox(width: 10.w),
                _selectDays(dayController),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // Widget _workAnniFilter(dayController) {
  //   return Padding(
  //     padding: EdgeInsets.only(left: 18.w, right: 18.w, top: 20.h),
  //     child: SizedBox(
  //       height: 50.h,
  //       child:  SingleChildScrollView(
  //       scrollDirection: Axis.horizontal,
  //   child:IntrinsicWidth(  // ✅ Constrains Row inside SingleChildScrollView
  //       child:Row(
  //          mainAxisAlignment: MainAxisAlignment.start,
  //         children: [
  //           _selectMembers(),
  //           SizedBox(
  //             width: 10.w,
  //           ),   _selectClient(),
  //           SizedBox(
  //             width: 10.w,
  //           ),
  //           _selectDays(dayController)
  //         ],
  //       ))),
  //     ),
  //   );
  // }
  Widget _selectClient() {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => BlocBuilder<ClientBloc, ClientState>(
              builder: (context, state) {
                if (state is ClientLoading) {
                  return const SpinKitFadingCircle(
                    color: AppColors.primary,
                    size: 40.0,
                  );
                }
                if (state is ClientSuccess || state is ClientPaginated) {
                  final clients = state is ClientSuccess
                      ? state.client
                      : (state as ClientPaginated).client;
                  final hasReachedMax =
                  state is ClientPaginated ? state.hasReachedMax : false;
                  ScrollController scrollController = ScrollController();
                  scrollController.addListener(() {
                    if (scrollController.position.atEdge &&
                        scrollController.position.pixels != 0) {
                      context
                          .read<ClientBloc>()
                          .add(ClientLoadMore(_clientSearchController.text));
                    }
                  });

                  return BlocBuilder<WorkAnniversaryBloc, WorkAnniversaryState>(
                    builder: (context, workAnniversaryState) {
                      List<String> clientSelectedname = [];
                      List<String> userSelectedname = [];
                      List<int> clientSelectedId = [];
                      List<int> userSelectedId = [];
                      if (workAnniversaryState is WorkAnniversaryPaginated) {
                        clientSelectedname = workAnniversaryState.clientSelectedname;
                        userSelectedname = workAnniversaryState.userSelectedname;
                        clientSelectedId = workAnniversaryState.clientSelectedId;
                        userSelectedId = workAnniversaryState.userSelectedId;
                        if (kDebugMode) {
                          print(
                              'SelectClient Dialog: clientSelectedname=$clientSelectedname');
                        }
                      }

                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                        backgroundColor:
                        Theme.of(context).colorScheme.alertBoxBackGroundColor,
                        contentPadding: EdgeInsets.zero,
                        title: Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Column(
                              children: [
                                CustomText(
                                  text: AppLocalizations.of(context)!.selectclient,
                                  fontWeight: FontWeight.w800,
                                  size: 20,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .whitepurpleChange,
                                ),
                                const Divider(),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 0.w),
                                  child: SizedBox(
                                    height: 35.h,
                                    width: double.infinity,
                                    child: TextField(
                                      cursorColor: AppColors.greyForgetColor,
                                      cursorWidth: 1,
                                      controller: _clientSearchController,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: (35.h - 20.sp) / 2,
                                          horizontal: 10.w,
                                        ),
                                        hintText:
                                        AppLocalizations.of(context)!.search,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: AppColors.greyForgetColor,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            color: AppColors.purple,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        context
                                            .read<ClientBloc>()
                                            .add(SearchClients(value));
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5.h),
                              ],
                            ),
                          ),
                        ),
                        content: Container(
                          constraints: BoxConstraints(maxHeight: 900.h),
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            controller: scrollController,
                            shrinkWrap: true,
                            itemCount:
                            hasReachedMax ? clients.length : clients.length + 1,
                            itemBuilder: (context, index) {
                              if (index < clients.length) {
                                final isSelected =
                                clientSelectedId.contains(clients[index].id!);
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.h),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      final updatedClientSelectedId =
                                      List<int>.from(clientSelectedId);
                                      final updatedClientSelectedname =
                                      List<String>.from(clientSelectedname);
                                      if (isSelected) {
                                        updatedClientSelectedId
                                            .remove(clients[index].id!);
                                        updatedClientSelectedname
                                            .remove(clients[index].firstName!);
                                      } else {
                                        updatedClientSelectedId
                                            .add(clients[index].id!);
                                        updatedClientSelectedname
                                            .add(clients[index].firstName!);
                                      }
                                      context.read<WorkAnniversaryBloc>().add(
                                        UpdateSelectedClientsWorkAnni(
                                          List<String>.from(
                                              updatedClientSelectedname),
                                          List<int>.from(
                                              updatedClientSelectedId),
                                        ),
                                      );
                                      context.read<ClientBloc>().add(
                                          SelectedClient(
                                              index, clients[index].firstName!));
                                      context.read<ClientBloc>().add(
                                          ToggleClientSelection(
                                              index, clients[index].firstName!));
                                    },
                                    child: Padding(
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 20.w),
                                      child:
                                      Center(
                                        child:
                                        Container(
                                          decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors
                                                  .purpleShade
                                                  : Colors
                                                  .transparent,
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  10),
                                              border: Border.all(
                                                  color: isSelected
                                                      ? AppColors
                                                      .purple
                                                      : Colors
                                                      .transparent)),
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                              10.w,vertical: 5.h),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              CustomText(
                                                text:clients[index].firstName!,
                                                fontWeight:
                                                FontWeight.w500,
                                                size:
                                                18,
                                                color: isSelected
                                                    ? AppColors.purple
                                                    : Theme.of(context).colorScheme.textClrChange,
                                              ),
                                              isSelected
                                                  ? const HeroIcon(
                                                HeroIcons.checkCircle,
                                                style: HeroIconStyle.solid,
                                                color: AppColors.purple,
                                              )
                                                  : const SizedBox.shrink(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return Padding(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                                  child: Center(
                                    child: hasReachedMax
                                        ? const SizedBox.shrink()
                                        : const SpinKitFadingCircle(
                                      color: AppColors.primary,
                                      size: 40.0,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        actions: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: CreateCancelButtom(
                              title: AppLocalizations.of(context)!.ok,
                              onpressCancel: () {
                                _clientSearchController.clear();
                                context
                                    .read<WorkAnniversaryBloc>()
                                    .add(UpdateSelectedClientsWorkAnni([], []));
                                context.read<WorkAnniversaryBloc>().add(
                                  WeekWorkAnniversaryList(

                                    userSelectedId,
                                    [],
                                    _currentValue.value,
                                    [],
                                    userSelectedname,
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              onpressCreate: () {
                                _clientSearchController.clear();
                                context.read<WorkAnniversaryBloc>().add(
                                  WeekWorkAnniversaryList(

                                    userSelectedId,
                                    clientSelectedId,
                                    _currentValue.value,
                                    clientSelectedname,
                                    userSelectedname,
                                  ),
                                );
                                Future.delayed(Duration(milliseconds: 100), () {
                                  Navigator.pop(context);
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
        child: BlocBuilder<WorkAnniversaryBloc, WorkAnniversaryState>(
          builder: (context, state) {
            List<String> clientSelectedname = [];
            if (state is WorkAnniversaryPaginated) {
              clientSelectedname = state.clientSelectedname;
              if (kDebugMode) {
                print('SelectClient UI: clientSelectedname=$clientSelectedname');
              }
            }
            return Container(
              alignment: Alignment.center,
              height: 40.h,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyColor, width: 0.5),
                color: Theme.of(context).colorScheme.containerDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CustomText(
                          text: clientSelectedname.isNotEmpty
                              ? clientSelectedname.join(", ")
                              : AppLocalizations.of(context)!.selectclient,
                          color: Theme.of(context).colorScheme.textClrChange,
                          size: 14.sp,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w600,
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
    );
  }
  Widget _selectMembers() {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                print("gvbhjnkm $state");
                if (state is UserLoading) {
                  return const SpinKitFadingCircle(
                    color: AppColors.primary,
                    size: 40,
                  );
                }

                if ( state is UserPaginated) {
                  final users = state is UserSuccess
                      ? state.user
                      : (state).user;
                  final hasReachedMax = state.hasReachedMax;

                  ScrollController scrollController = ScrollController();
                  scrollController.addListener(() {
                    if (scrollController.position.atEdge &&
                        scrollController.position.pixels != 0) {
                      context
                          .read<UserBloc>()
                          .add(UserLoadMore(_userSearchController.text));
                    }
                  });

                  return BlocBuilder<WorkAnniversaryBloc, WorkAnniversaryState>(
                    builder: (context, workAnniversaryState) {
                      List<String> userSelectedname = [];
                      List<String> clientSelectedname = [];
                      List<int> userSelectedId = [];
                      List<int> clientSelectedId = [];

                      if (workAnniversaryState is WorkAnniversaryPaginated) {
                        userSelectedname = workAnniversaryState.userSelectedname;
                        userSelectedId = workAnniversaryState.userSelectedId;
                        clientSelectedId = workAnniversaryState.clientSelectedId;
                        clientSelectedname = workAnniversaryState.clientSelectedname;
                        if (kDebugMode) {
                          print('SelectMembers Dialog: userSelectedname=$userSelectedname');
                        }
                      }

                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                        backgroundColor:
                        Theme.of(context).colorScheme.alertBoxBackGroundColor,
                        contentPadding: EdgeInsets.zero,
                        title: Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Column(
                              children: [
                                CustomText(
                                  text: AppLocalizations.of(context)!.selectuser,
                                  fontWeight: FontWeight.w800,
                                  size: 20,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .whitepurpleChange,
                                ),
                                const Divider(),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 0.w),
                                  child: SizedBox(
                                    height: 35.h,
                                    width: double.infinity,
                                    child: TextField(
                                      cursorColor: AppColors.greyForgetColor,
                                      cursorWidth: 1,
                                      controller: _userSearchController,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: (35.h - 20.sp) / 2,
                                          horizontal: 10.w,
                                        ),
                                        hintText:
                                        AppLocalizations.of(context)!.search,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: AppColors.greyForgetColor,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            color: AppColors.purple,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        context
                                            .read<UserBloc>()
                                            .add(SearchUsers(value));
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5.h),
                              ],
                            ),
                          ),
                        ),
                        content: Container(
                          constraints: BoxConstraints(maxHeight: 900.h),
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            controller: scrollController,
                            shrinkWrap: true,
                            itemCount:
                            hasReachedMax ? users.length : users.length + 1,
                            itemBuilder: (context, index) {
                              if (index < users.length) {
                                final isSelected =
                                userSelectedId.contains(users[index].id!);
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.h),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      final updatedUserSelectedId =
                                      List<int>.from(userSelectedId);
                                      final updatedUserSelectedname =
                                      List<String>.from(userSelectedname);
                                      if (isSelected) {
                                        updatedUserSelectedId
                                            .remove(users[index].id!);
                                        updatedUserSelectedname
                                            .remove(users[index].firstName!);
                                      } else {
                                        updatedUserSelectedId.add(users[index].id!);
                                        updatedUserSelectedname
                                            .add(users[index].firstName!);
                                      }
                                      context.read<WorkAnniversaryBloc>().add(
                                        UpdateSelectedUsersWorkAnni(
                                          List<String>.from(
                                              updatedUserSelectedname),
                                          List<int>.from(updatedUserSelectedId),
                                        ),
                                      );
                                      context.read<UserBloc>().add(
                                          ToggleUserSelection(
                                              index, users[index].firstName!));
                                    },
                                    child:
                                    Padding(
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 20.w),
                                      child:
                                      Center(
                                        child:
                                        Container(
                                          decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors
                                                  .purpleShade
                                                  : Colors
                                                  .transparent,
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  10),
                                              border: Border.all(
                                                  color: isSelected
                                                      ? AppColors
                                                      .purple
                                                      : Colors
                                                      .transparent)),
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                              10.w,vertical: 5.h),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              CustomText(
                                                text:users[index].firstName!,
                                                fontWeight:
                                                FontWeight.w500,
                                                size:
                                                18,
                                                color: isSelected
                                                    ? AppColors.purple
                                                    : Theme.of(context).colorScheme.textClrChange,
                                              ),
                                              isSelected
                                                  ? const HeroIcon(
                                                HeroIcons.checkCircle,
                                                style: HeroIconStyle.solid,
                                                color: AppColors.purple,
                                              )
                                                  : const SizedBox.shrink(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return Padding(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                                  child: Center(
                                    child: hasReachedMax
                                        ? const SizedBox.shrink()
                                        : const SpinKitFadingCircle(
                                      color: AppColors.primary,
                                      size: 40.0,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        actions: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: CreateCancelButtom(
                              title: AppLocalizations.of(context)!.ok,
                              onpressCancel: () {
                                _userSearchController.clear();
                                context
                                    .read<WorkAnniversaryBloc>()
                                    .add(UpdateSelectedUsersWorkAnni([], []));
                                context.read<WorkAnniversaryBloc>().add(
                                  WeekWorkAnniversaryList(

                                    [],
                                    clientSelectedId,
                                    _currentValue.value,
                                    clientSelectedname,
                                    [],
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              onpressCreate: () {
                                _userSearchController.clear();
                                context.read<WorkAnniversaryBloc>().add(
                                  WeekWorkAnniversaryList(

                                    userSelectedId,
                                    clientSelectedId,
                                    _currentValue.value,
                                    clientSelectedname,
                                    userSelectedname,
                                  ),
                                );
                                Future.delayed(Duration(milliseconds: 100), () {
                                  Navigator.pop(context);
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          );
        },
        child: BlocBuilder<WorkAnniversaryBloc, WorkAnniversaryState>(
          builder: (context, state) {
            List<String> userSelectedname = [];
            if (state is WorkAnniversaryPaginated) {
              userSelectedname = state.userSelectedname;
              if (kDebugMode) {
                print('SelectMembers UI: userSelectedname=$userSelectedname');
              }
            }
            return Container(
              alignment: Alignment.center,
              height: 40.h,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyColor, width: 0.5),
                color: Theme.of(context).colorScheme.containerDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CustomText(
                          text: userSelectedname.isNotEmpty
                              ? userSelectedname.join(", ")
                              : AppLocalizations.of(context)!.selectmembers,
                          color: Theme.of(context).colorScheme.textClrChange,
                          size: 14.sp,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w600,
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
    );
  }

  void _showNumberPickerDialog(dayController) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    showDialog(
      context: context,
      builder: (context) => CustomNumberPickerDialog(
        dayController: dayController,
        currentValue: _currentValue,
        isLightTheme: currentTheme is LightThemeState,
        onSubmit: (value) {
          _currentValue.value=value;
          BlocProvider.of<WorkAnniversaryBloc>(context).add(
              WeekWorkAnniversaryList(


                (context.read<WorkAnniversaryBloc>().state as WorkAnniversaryPaginated?)?.userSelectedId ?? [],
                (context.read<WorkAnniversaryBloc>().state as WorkAnniversaryPaginated?)?.clientSelectedId ?? [], _currentValue.value,

                (context.read<WorkAnniversaryBloc>().state as WorkAnniversaryPaginated?)?.clientSelectedname ?? [],
                (context.read<WorkAnniversaryBloc>().state as WorkAnniversaryPaginated?)?.userSelectedname ?? [],));
        },
      ),
    );
  }

  Widget _selectDays(dayController) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () async {},
        child: ValueListenableBuilder<int>(
          valueListenable: _currentValue,
          builder: (context, value, child) {
            return Container(
              alignment: Alignment.center,
              height: 40.h,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyColor, width: 0.5),
                color: Theme.of(context).colorScheme.containerDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: InkWell(
                    onTap: () {
                      _showNumberPickerDialog(dayController);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: CustomText(
                            text: value == 7
                                ? AppLocalizations.of(context)!.sevendays
                                : "$value ${AppLocalizations.of(context)!.days}",
                            color: Theme.of(context).colorScheme.textClrChange,
                            size: 14.sp,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        value == 7
                            ? SizedBox.shrink()
                            : InkWell(
                          onTap: () {
                            _currentValue.value = 7;
                            dayController.text = "7";
                            BlocProvider.of<WorkAnniversaryBloc>(
                                context)
                                .add(WeekWorkAnniversaryList(

                                (context.read<WorkAnniversaryBloc>().state as WorkAnniversaryPaginated?)?.userSelectedId ?? [],
                                (context.read<WorkAnniversaryBloc>().state as WorkAnniversaryPaginated?)?.clientSelectedId ?? [],
                                7, (context.read<WorkAnniversaryBloc>().state as WorkAnniversaryPaginated?)?.clientSelectedname ?? [] ,
                                (context.read<WorkAnniversaryBloc>().state as WorkAnniversaryPaginated?)?.userSelectedname ?? []
                            ));
                            // BlocProvider.of<BirthdayBloc>(context)
                            //     .add(WeekBirthdayList(7, userSelectedId,[]));
                          },
                          child: Padding(
                            padding:  EdgeInsets.only(left: 8.w),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.greyColor,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(5.h),
                                child: HeroIcon(
                                  HeroIcons.xMark,
                                  style: HeroIconStyle.outline,
                                  color: AppColors.pureWhiteColor,
                                  size: 15.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _workAnniList(hasReachedMax, anniState, isLightTheme) {
    return Container(
      alignment: Alignment.centerLeft,
      height: 267.h,
      child: ListView.builder(
          padding: EdgeInsets.only(right: 18.w, top: 10.h, bottom: 15.h),
          // physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: hasReachedMax ? anniState.length : anniState.length + 1,
          itemBuilder: (context, index) {
            if (index < anniState.length) {
              var workAnniversary = anniState[index];
              String? doj = formatDateFromApi(workAnniversary.doj!, context);

              return InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {

                  router.push('/userdetail', extra: {
                    "id": workAnniversary.id,
                  });
                },
                child: Padding(
                    padding:
                    EdgeInsets.only(top: 10.h, bottom: 10.h, left: 18.w),
                    child: Container(
                      height: 155.h,
                      decoration: BoxDecoration(
                          boxShadow: [
                            isLightTheme
                                ? MyThemes.lightThemeShadow
                                : MyThemes.darkThemeShadow,
                          ],
                          color: Theme.of(context).colorScheme.containerDark,
                          borderRadius: BorderRadius.circular(12)),
                      width: 250.w,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 18.w, vertical: 12.h),
                        child: SizedBox(
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.ce,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    child: CircleAvatar(
                                      radius: 40.w,
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .backGroundColor,
                                      child: CircleAvatar(
                                        radius:
                                        40.w, // Size of the profile image
                                        backgroundImage: NetworkImage(
                                            workAnniversary.photo!),
                                        backgroundColor: Colors.grey[
                                        200], // Replace with your image URL
                                      ),
                                    ),
                                  ),
                                  workAnniversary.anniversaryCount == 0?SizedBox():   Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                              "${workAnniversary.anniversaryCount!}",
                                              style: TextStyle(
                                                fontSize: 40
                                                    .sp, // Bigger size for "26"
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .textClrChange,
                                              ),
                                            ),
                                            WidgetSpan(
                                              child: Transform.translate(
                                                offset: Offset(0,
                                                    -10), // Moves "th" slightly up
                                                child: CustomText(
                                                  text:
                                                  "${getOrdinalSuffix(workAnniversary.anniversaryCount!)}",

                                                  size: 18
                                                      .sp, // Smaller size for "th"
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .textClrChange,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      CustomText(
                                        text:
                                        "${AppLocalizations.of(context)!.anniToday}",
                                        size: 12.sp,
                                        color: AppColors.projDetailsSubText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.w,
                              ),
                              CustomText(
                                text: workAnniversary.member!,
                                size: 22.sp,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.bold,
                                color:
                                Theme.of(context).colorScheme.textClrChange,
                              ),
                              workAnniversary.daysLeft! == 0
                                  ? CustomText(
                                text:
                                " ${AppLocalizations.of(context)!.today}",
                                size: 16.sp,
                                color: AppColors.projDetailsSubText,
                                fontWeight: FontWeight.w600,
                              )
                                  : CustomText(
                                text:
                                "${AppLocalizations.of(context)!.daysLeft} ${workAnniversary.daysLeft!.toString()}",
                                size: 14.sp,
                                color: AppColors.projDetailsSubText,
                                fontWeight: FontWeight.w600,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  workAnniversary.daysLeft!.toString() == "0"
                                      ? SizedBox()
                                      : CustomText(
                                    text: AppLocalizations.of(context)!
                                        .daysLeft,
                                    color: Colors.grey[400]!,
                                    size: 10.sp,
                                  ),
                                  workAnniversary.daysLeft!.toString() == "0"
                                      ? SizedBox(
                                    height: 20.h,
                                  )
                                      : SizedBox(),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          const HeroIcon(
                                            HeroIcons.cake,
                                            style: HeroIconStyle.outline,
                                            color: AppColors.blueColor,
                                          ),
                                          SizedBox(
                                            width: 10.w,
                                          ),
                                          CustomText(
                                            text: doj,
                                            color: AppColors.greyColor,
                                            size: 14,
                                            fontWeight: FontWeight.w500,
                                          )
                                        ],
                                      ),
                                      workAnniversary.daysLeft!.toString() ==
                                          "0"
                                          ? SizedBox()
                                          : Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .textClrChange,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          "${workAnniversary.daysLeft!.toString()}",
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .lightWhite,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    )),
              );
            } else {
              // Show a loading indicator when more notes are being loaded
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
          }),
    );
  }

  Widget _workAnniBloc(isLightTheme) {
    return BlocBuilder<WorkAnniversaryBloc, WorkAnniversaryState>(
      builder: (context, state) {
        print("fghjkl $state");
        if (state is TodaysWorkAnniversaryLoading) {
          return Container(
            // color: Colors.red,
              height: 225.h,child: const HomeUpcomingShimmer());
        } else if (state is WorkAnniversaryPaginated) {
          return NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                // Check if the user has scrolled to the end and load more notes if needed
                if (!state.hasReachedMax &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  context.read<WorkAnniversaryBloc>().add(
                      LoadMoreWorkAnniversary(
                          _currentValue.value, userSelectedId));
                }
                return false;
              },
              child: state.workAnniversary.isNotEmpty
                  ? _workAnniList(
                  state.hasReachedMax, state.workAnniversary, isLightTheme)
                  : Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 18.w, vertical: 12.h),
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        boxShadow: [
                          isLightTheme
                              ? MyThemes.lightThemeShadow
                              : MyThemes.darkThemeShadow,
                        ],
                        color:
                        Theme.of(context).colorScheme.containerDark,
                        borderRadius: BorderRadius.circular(12)),
                    child: NoData(
                      isImage: false,
                    )),
              )
            // : NoData(),
          );
        } else if (state is WorkAnniversaryError) {
          // Show error message
        }
        // Handle other states
        return const SizedBox.shrink();
      },
    );
  }
}