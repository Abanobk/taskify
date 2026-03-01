import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/bloc/Expense/Expense_bloc.dart';
import 'package:taskify/bloc/Expense/expense_event.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/data/model/finance/expense_model.dart';
import 'package:taskify/utils/widgets/custom_text.dart';
import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../config/constants.dart';
import '../../../utils/widgets/custom_dimissible.dart';
import '../../../../src/generated/i18n/app_localizations.dart';

class ExpenseCard extends StatefulWidget {
  final ExpenseModel expenseModel;
  final List<ExpenseModel> expenseList;
  final int index;

  const ExpenseCard({
    required this.expenseModel,
    required this.expenseList,
    required this.index,
    super.key,
  });

  @override
  State<ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard> {
  @override
  Widget build(BuildContext context) {
    final expenseDate = formatDateFromApi(widget.expenseModel.expenseDate!,context);
    return  BlocProvider<ExpenseBloc>(
        create: (context) => ExpenseBloc(),
    child: DismissibleCard(
      title: widget.expenseModel.id.toString(),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.endToStart  ) {
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
                  widget.expenseList.removeAt(widget.index);


                });
                context.read<ExpenseBloc>().add(DeleteExpenses(widget.expenseModel.id!));
              });
              // Return false to prevent the dismissible from animating
              return false;
            }

            return false; // Always return false since we handle deletion manually
          } catch (e) {
            print("Error in dialog: $e");
            return false;
          }// Return the result of the dialog
        }
        else if (direction == DismissDirection.startToEnd) {
          // router.push(
          //   '/createmeeting',
          //   extra: {
          //     'isCreate': false,
          //     "index": index,
          //     "meeting": meeting,
          //     "meetingModel": meeting
          //   },
          // );


          return false; // Prevent dismiss
        }

        return false;
      },
      dismissWidget: Card(
      color: Theme.of(context).colorScheme.containerDark
    ,
      margin:  EdgeInsets.symmetric(horizontal: 18.w,vertical: 10.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: ID and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:  [
                Text(
                  "#${widget.expenseModel.id.toString()}",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  expenseDate,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
             SizedBox(height: 12.h),
            // Title
            CustomText(
              text: widget.expenseModel.title??"",
              color: Theme.of(context).colorScheme.textClrChange,
              size: 18.sp,
              fontWeight: FontWeight.w700,
            ),
             SizedBox(height: 8.h),
            // Expense Type
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: CustomText(
                text: widget.expenseModel.expenseType??"",
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              )
            ),
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
                    backgroundImage: NetworkImage(widget.expenseModel.user!.photo!),
                                   ),
                 ),
                 SizedBox(width: 12.h),
                // User details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:  [
                    CustomText(
                      text: "${widget.expenseModel.user?.firstName ?? ""} ${widget.expenseModel.user?.lastName ?? ""}",
                      color: Theme.of(context).colorScheme.textClrChange,
                      size: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    CustomText(
                      text:widget.expenseModel.user!.email??"",
                      color: AppColors.greyColor,
                      size: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),


                  ],
                ),
                const Spacer(),
                // Amount
                 Text(
                  widget.expenseModel.amount??"",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
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
                  widget.expenseModel.createdBy??"",
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
            context.read<PermissionsBloc>().isdeleteProject == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {   setState(() {
            widget.expenseList.removeAt(widget.index);
          });
          context.read<ExpenseBloc>().add(DeleteExpenses(widget.expenseModel.id!));

        });
        } else if (direction == DismissDirection.startToEnd &&
            context.read<PermissionsBloc>().iseditProject == true) {
          // Perform edit action

        }
      },
    ));
    // return Card(
    //   color: Theme.of(context).colorScheme.containerDark
    // ,
    //   margin:  EdgeInsets.symmetric(horizontal: 18.w,vertical: 10.h),
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(16),
    //   ),
    //   elevation: 4,
    //   child: Padding(
    //     padding: const EdgeInsets.all(16),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         // Top Row: ID and Date
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children:  [
    //             Text(
    //               "#${expenseModel.id.toString()}",
    //               style: TextStyle(color: Colors.grey, fontSize: 14),
    //             ),
    //             Text(
    //               expenseDate??"",
    //               style: TextStyle(color: Colors.grey, fontSize: 14),
    //             ),
    //           ],
    //         ),
    //          SizedBox(height: 12.h),
    //         // Title
    //         CustomText(
    //           text: expenseModel.title??"",
    //           color: Theme.of(context).colorScheme.textClrChange,
    //           size: 18.sp,
    //           fontWeight: FontWeight.w700,
    //         ),
    //          SizedBox(height: 8.h),
    //         // Expense Type
    //         Container(
    //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    //           decoration: BoxDecoration(
    //             color: Colors.blue.shade200,
    //             borderRadius: BorderRadius.circular(20),
    //           ),
    //           child: CustomText(
    //             text: expenseModel.expenseType??"",
    //             color: Theme.of(context).colorScheme.textClrChange,
    //             size: 16,
    //             fontWeight: FontWeight.w700,
    //           )
    //         ),
    //          SizedBox(height: 16.h),
    //         // User & Amount
    //         Row(
    //           children: [
    //             // Avatar
    //              CircleAvatar(
    //                radius: 23.r,
    //                backgroundColor: AppColors.greyColor,
    //                child: CircleAvatar(
    //                 radius: 22.r,
    //                 backgroundColor: Colors.blue,
    //                 backgroundImage: NetworkImage(expenseModel.user!.photo!),
    //                                ),
    //              ),
    //              SizedBox(width: 12.h),
    //             // User details
    //             Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children:  [
    //                 CustomText(
    //                   text: "${expenseModel.user!.firstName} ${expenseModel.user!.lastName}" ??"",
    //                   color: Theme.of(context).colorScheme.textClrChange,
    //                   size: 16.sp,
    //                   fontWeight: FontWeight.w700,
    //                 ),
    //                 CustomText(
    //                   text:expenseModel.user!.email??"",
    //                   color: AppColors.greyColor,
    //                   size: 14.sp,
    //                   fontWeight: FontWeight.w700,
    //                 ),
    //
    //
    //               ],
    //             ),
    //             const Spacer(),
    //             // Amount
    //              Text(
    //               expenseModel.amount??"",
    //               style: TextStyle(
    //                 color: Colors.blue,
    //                 fontWeight: FontWeight.bold,
    //                 fontSize: 18,
    //               ),
    //             ),
    //           ],
    //         ),
    //         const SizedBox(height: 16),
    //         Row(
    //           children: [
    //             Text(
    //               AppLocalizations.of(context)!.createdby,
    //               style: TextStyle(
    //                 color: AppColors.greyColor,
    //                 fontWeight: FontWeight.bold,
    //                 fontSize: 12.sp,
    //               ),
    //             ),
    //             Text(
    //               expenseModel.createdBy??"",
    //               style: TextStyle(
    //                 color: AppColors.blueColor,
    //                 fontWeight: FontWeight.bold,
    //                 fontSize: 12.sp,
    //               ),
    //             ),
    //           ],
    //         )
    //         // Action Icons
    //
    //       ],
    //     ),
    //   ),
    // );
  }
}
