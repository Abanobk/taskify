import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/bloc/payment_method/payment_method_bloc.dart';
import 'package:taskify/bloc/payment_method/payment_method_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import '../../../bloc/payment_method/payment_method_event.dart';

import '../../../utils/widgets/custom_text.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../../../src/generated/i18n/app_localizations.dart';


class PaymentMethodList extends StatefulWidget {
  final bool isCreate;
  final String? name;
  final int? payment;
  final bool? isRequired;
  // final List<StatusModel> status;

  final Function(String, int) onSelected;
  const PaymentMethodList(
      {super.key,
        this.name,
        required this.isCreate,
        required this.payment,
        this.isRequired,

        required this.onSelected});

  @override
  State<PaymentMethodList> createState() => _PaymentMethodListState();
}

class _PaymentMethodListState extends State<PaymentMethodList> {
  String? paymentsname;
  int? paymentsId;
  bool isLoadingMore = false;
  String searchWord = "";

  String? name;
  final TextEditingController _paymentSearchController =
  TextEditingController();
  @override
  void initState() {
    super.initState();
    paymentsname = widget.name ?? "";
    paymentsId = widget.payment;
    print("fhdzif $paymentsname");
    print("paymentsId $paymentsId");
  }

  @override
  Widget build(BuildContext context) {
    // if (!widget.isCreate) {
    //   paymentsId = widget.payment;
    //   paymentsname = widget.name;
    // }


    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),
          child: Row(
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.paymentmethods,
                // text: getTranslated(context, 'myweeklyTask'),
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16.sp,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w700,
              ),
              widget.isRequired == true
                  ? CustomText(
                text: " *",
                // text: getTranslated(context, 'myweeklyTask'),
                color: AppColors.red,
                size: 15,
                fontWeight: FontWeight.w400,
              )
                  : SizedBox.shrink(),
            ],
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        BlocBuilder<PaymentMethodBloc, PaymentMethdState>(
          builder: (context, state) {
            print("fsdfr $state");
            if (state is PaymentMethdInitial) {
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      highlightColor: Colors.transparent, // No highlight on tap
                      splashColor: Colors.transparent,
                      onTap: () {
                        _paymentSearchController.clear();

                        // Fetch initial payment list
                        widget.isCreate == false
                            ? SizedBox()
                            : context
                            .read<PaymentMethodBloc>()
                            .add(PaymentMethdLists());
                        widget.isCreate == false
                            ? SizedBox()
                            : showDialog(
                          context: context,
                          builder: (ctx) => BlocConsumer<
                              PaymentMethodBloc, PaymentMethdState>(
                            listener: (context, state) {
                              if (state is PaymentMethdSuccess) {
                                isLoadingMore = false;
                                setState(() {});
                              }
                            },
                            builder: (context, state) {
                              if (state is PaymentMethdSuccess) {
                                return NotificationListener<
                                    ScrollNotification>(
                                    onNotification: (scrollInfo) {
                                      // Check if the user has scrolled to the end and load more notes if needed
                                      if (!state.isLoadingMore &&
                                          scrollInfo.metrics.pixels ==
                                              scrollInfo.metrics
                                                  .maxScrollExtent) {
                                        // isLoadingMore = true;
                                        setState(() {});
                                        context
                                            .read<
                                            PaymentMethodBloc>()
                                            .add(PaymentMethdLoadMore(
                                            searchWord));
                                      }
                                      // isLoadingMore = false;
                                      return false;
                                    },
                                    child: AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10.r), // Set the desired radius here
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .alertBoxBackGroundColor,
                                      contentPadding: EdgeInsets.zero,
                                      title: Center(
                                        child: Column(
                                          children: [
                                            CustomText(
                                              text: AppLocalizations.of(
                                                  context)!
                                                  .selectpayments,
                                              fontWeight: FontWeight.w800,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .whitepurpleChange,
                                            ),
                                            const Divider(),
                                            Padding(
                                              padding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 0.w),
                                              child: SizedBox(
                                                // color: Colors.red,
                                                height: 35.h,
                                                width: double.infinity,
                                                child: TextField(
                                                  cursorColor: AppColors
                                                      .greyForgetColor,
                                                  cursorWidth: 1,
                                                  controller:
                                                  _paymentSearchController,
                                                  decoration:
                                                  InputDecoration(
                                                    contentPadding:
                                                    EdgeInsets
                                                        .symmetric(
                                                      vertical:
                                                      (35.h - 20.sp) /
                                                          2,
                                                      horizontal: 10.w,
                                                    ),
                                                    hintText:
                                                    AppLocalizations.of(
                                                        context)!
                                                        .search,
                                                    enabledBorder:
                                                    OutlineInputBorder(
                                                      borderSide:
                                                      BorderSide(
                                                        color: AppColors
                                                            .greyForgetColor, // Set your desired color here
                                                        width:
                                                        1.0, // Set the border width if needed
                                                      ),
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          10.0), // Optional: adjust the border radius
                                                    ),
                                                    focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          10.0),
                                                      borderSide:
                                                      BorderSide(
                                                        color: AppColors
                                                            .purple, // Border color when TextField is focused
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                  ),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      searchWord = value;
                                                    });
                                                    context
                                                        .read<
                                                        PaymentMethodBloc>()
                                                        .add(
                                                        SearchPaymentMethd(
                                                            value));
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20.h,
                                            )
                                          ],
                                        ),
                                      ),
                                      content: Container(
                                        constraints: BoxConstraints(
                                            maxHeight: 900.h),
                                        width: 200.w,
                                        child: state.PaymentMethd.isEmpty?NoData(isImage: true,):ListView.builder(
                                          // physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: state.isLoadingMore
                                              ? state.PaymentMethd.length
                                              : state.PaymentMethd.length + 1,
                                          itemBuilder:
                                              (BuildContext context,
                                              int index) {
                                            if (index <
                                                state.PaymentMethd.length) {
                                              final isSelected =
                                                  paymentsId != null &&
                                                      state.PaymentMethd[index]
                                                          .id ==
                                                          paymentsId;
                                              return Padding(
                                                padding:
                                                EdgeInsets.symmetric(
                                                    vertical: 2.h,
                                                    horizontal: 20.w),
                                                child: InkWell(
                                                  highlightColor: Colors
                                                      .transparent, // No highlight on tap
                                                  splashColor:
                                                  Colors.transparent,
                                                  onTap: () {
                                                    setState(() {
                                                      if (widget
                                                          .isCreate ==
                                                          true) {
                                                        paymentsname =
                                                        state
                                                            .PaymentMethd[
                                                        index]
                                                            .title!;
                                                        paymentsId = state
                                                            .PaymentMethd[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .PaymentMethd[
                                                            index]
                                                                .title!,
                                                            state
                                                                .PaymentMethd[
                                                            index]
                                                                .id!);
                                                      } else {
                                                        name = state
                                                            .PaymentMethd[
                                                        index]
                                                            .title!;
                                                        paymentsname =
                                                        state
                                                            .PaymentMethd[
                                                        index]
                                                            .title!;
                                                        paymentsId = state
                                                            .PaymentMethd[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .PaymentMethd[
                                                            index]
                                                                .title!,
                                                            state
                                                                .PaymentMethd[
                                                            index]
                                                                .id!);
                                                      }
                                                    });

                                                    BlocProvider.of<
                                                        PaymentMethodBloc>(
                                                        context)
                                                        .add(SelectedPaymentMethd(
                                                        index,
                                                        state
                                                            .PaymentMethd[
                                                        index]
                                                            .title!));
                                                    
                                                  },
                                                  child: Container(
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
                                                                .primary
                                                                : Colors
                                                                .transparent)),
                                                    width:
                                                    double.infinity,
                                                    height: 40.h,
                                                    child: Center(
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                            horizontal:
                                                            10.w),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              flex: 4,
                                                              // width:200.w,
                                                              child:
                                                              CustomText(
                                                                text: state
                                                                    .PaymentMethd[
                                                                index]
                                                                    .title!,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w500,
                                                                size: 18,
                                                                maxLines:
                                                                1,
                                                                overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                                color: isSelected
                                                                    ? AppColors
                                                                    .purple
                                                                    : Theme.of(context)
                                                                    .colorScheme
                                                                    .textClrChange,
                                                              ),
                                                            ),
                                                            isSelected
                                                                ? Expanded(
                                                              flex:
                                                              1,
                                                              child:
                                                              const HeroIcon(
                                                                HeroIcons.checkCircle,
                                                                style:
                                                                HeroIconStyle.solid,
                                                                color:
                                                                AppColors.purple,
                                                              ),
                                                            )
                                                                : const SizedBox
                                                                .shrink(),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              // Show a loading indicator when more notes are being loaded
                                              return Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    vertical: 0),
                                                child: Center(
                                                  child: state
                                                      .isLoadingMore
                                                      ? const Text('')
                                                      : const SpinKitFadingCircle(
                                                    color: AppColors
                                                        .primary,
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
                                          padding:
                                          EdgeInsets.only(top: 20.h),
                                          child: CreateCancelButtom(
                                            title: "OK",
                                            onpressCancel: () {
                                              _paymentSearchController
                                                  .clear();
                                              Navigator.pop(context);
                                            },
                                            onpressCreate: () {
                                              _paymentSearchController
                                                  .clear();
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    ));
                              }
                              return const Center(
                                  child: Text('Loading...'));
                            },
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        height: 40.h,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: widget.isCreate == true
                              ? Colors.transparent
                              : Theme.of(context).colorScheme.textfieldDisabled,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.greyColor),
                        ),
                        // decoration: DesignConfiguration.shadow(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CustomText(
                                text: widget.isCreate
                                    ? (paymentsname!=""
                                    ? "Select payment"
                                    : paymentsname!)
                                    : (paymentsname!=""
                                    ? widget.name!
                                    : paymentsname!),
                                fontWeight: FontWeight.w500,
                                size: 14.sp,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                color:
                                Theme.of(context).colorScheme.textClrChange,
                              ),
                            ),
                             Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
            else if (state is PaymentMethdLoading) {
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      highlightColor: Colors.transparent, // No highlight on tap
                      splashColor: Colors.transparent,
                      onTap: () {
                        _paymentSearchController.clear();

                        // Fetch initial payment list
                        widget.isCreate == false
                            ? SizedBox()
                            : context
                            .read<PaymentMethodBloc>()
                            .add(PaymentMethdLists());
                        widget.isCreate == false
                            ? SizedBox()
                            : showDialog(
                          context: context,
                          builder: (ctx) => BlocConsumer<
                              PaymentMethodBloc, PaymentMethdState>(
                            listener: (context, state) {
                              if (state is PaymentMethdSuccess) {
                                isLoadingMore = false;
                                setState(() {});
                              }
                            },
                            builder: (context, state) {
                              if (state is PaymentMethdSuccess) {
                                return NotificationListener<
                                    ScrollNotification>(
                                    onNotification: (scrollInfo) {
                                      // Check if the user has scrolled to the end and load more notes if needed
                                      if (!state.isLoadingMore &&
                                          scrollInfo.metrics.pixels ==
                                              scrollInfo.metrics
                                                  .maxScrollExtent) {
                                        // isLoadingMore = true;
                                        setState(() {});
                                        context
                                            .read<
                                            PaymentMethodBloc>()
                                            .add(PaymentMethdLoadMore(
                                            searchWord));
                                      }
                                      // isLoadingMore = false;
                                      return false;
                                    },
                                    child: AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10.r), // Set the desired radius here
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .alertBoxBackGroundColor,
                                      contentPadding: EdgeInsets.zero,
                                      title: Center(
                                        child: Column(
                                          children: [
                                            CustomText(
                                              text: AppLocalizations.of(
                                                  context)!
                                                  .selectpayments,
                                              fontWeight: FontWeight.w800,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .whitepurpleChange,
                                            ),
                                            const Divider(),
                                            Padding(
                                              padding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 0.w),
                                              child: SizedBox(
                                                // color: Colors.red,
                                                height: 35.h,
                                                width: double.infinity,
                                                child: TextField(
                                                  cursorColor: AppColors
                                                      .greyForgetColor,
                                                  cursorWidth: 1,
                                                  controller:
                                                  _paymentSearchController,
                                                  decoration:
                                                  InputDecoration(
                                                    contentPadding:
                                                    EdgeInsets
                                                        .symmetric(
                                                      vertical:
                                                      (35.h - 20.sp) /
                                                          2,
                                                      horizontal: 10.w,
                                                    ),
                                                    hintText:
                                                    AppLocalizations.of(
                                                        context)!
                                                        .search,
                                                    enabledBorder:
                                                    OutlineInputBorder(
                                                      borderSide:
                                                      BorderSide(
                                                        color: AppColors
                                                            .greyForgetColor, // Set your desired color here
                                                        width:
                                                        1.0, // Set the border width if needed
                                                      ),
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          10.0), // Optional: adjust the border radius
                                                    ),
                                                    focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          10.0),
                                                      borderSide:
                                                      BorderSide(
                                                        color: AppColors
                                                            .purple, // Border color when TextField is focused
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                  ),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      searchWord = value;
                                                    });
                                                    context
                                                        .read<
                                                        PaymentMethodBloc>()
                                                        .add(
                                                        SearchPaymentMethd(
                                                            value));
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20.h,
                                            )
                                          ],
                                        ),
                                      ),
                                      content: Container(
                                        constraints: BoxConstraints(
                                            maxHeight: 900.h),
                                        width: 200.w,
                                        child: state.PaymentMethd.isEmpty?NoData(isImage: true,):ListView.builder(
                                          // physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: state.isLoadingMore
                                              ? state.PaymentMethd.length
                                              : state.PaymentMethd.length + 1,
                                          itemBuilder:
                                              (BuildContext context,
                                              int index) {
                                            if (index <
                                                state.PaymentMethd.length) {
                                              final isSelected =
                                                  paymentsId != null &&
                                                      state.PaymentMethd[index]
                                                          .id ==
                                                          paymentsId;
                                              return Padding(
                                                padding:
                                                EdgeInsets.symmetric(
                                                    vertical: 2.h,
                                                    horizontal: 20.w),
                                                child: InkWell(
                                                  highlightColor: Colors
                                                      .transparent, // No highlight on tap
                                                  splashColor:
                                                  Colors.transparent,
                                                  onTap: () {
                                                    setState(() {
                                                      if (widget
                                                          .isCreate ==
                                                          true) {
                                                        paymentsname =
                                                        state
                                                            .PaymentMethd[
                                                        index]
                                                            .title!;
                                                        paymentsId = state
                                                            .PaymentMethd[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .PaymentMethd[
                                                            index]
                                                                .title!,
                                                            state
                                                                .PaymentMethd[
                                                            index]
                                                                .id!);
                                                      } else {
                                                        name = state
                                                            .PaymentMethd[
                                                        index]
                                                            .title!;
                                                        paymentsname =
                                                        state
                                                            .PaymentMethd[
                                                        index]
                                                            .title!;
                                                        paymentsId = state
                                                            .PaymentMethd[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .PaymentMethd[
                                                            index]
                                                                .title!,
                                                            state
                                                                .PaymentMethd[
                                                            index]
                                                                .id!);
                                                      }
                                                    });

                                                    BlocProvider.of<
                                                        PaymentMethodBloc>(
                                                        context)
                                                        .add(SelectedPaymentMethd(
                                                        index,
                                                        state
                                                            .PaymentMethd[
                                                        index]
                                                            .title!));


                                                  },
                                                  child: Container(
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
                                                                .primary
                                                                : Colors
                                                                .transparent)),
                                                    width:
                                                    double.infinity,
                                                    height: 40.h,
                                                    child: Center(
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                            horizontal:
                                                            10.w),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              flex: 4,
                                                              // width:200.w,
                                                              child:
                                                              CustomText(
                                                                text: state
                                                                    .PaymentMethd[
                                                                index]
                                                                    .title!,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w500,
                                                                size: 18,
                                                                maxLines:
                                                                1,
                                                                overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                                color: isSelected
                                                                    ? AppColors
                                                                    .purple
                                                                    : Theme.of(context)
                                                                    .colorScheme
                                                                    .textClrChange,
                                                              ),
                                                            ),
                                                            isSelected
                                                                ? Expanded(
                                                              flex:
                                                              1,
                                                              child:
                                                              const HeroIcon(
                                                                HeroIcons.checkCircle,
                                                                style:
                                                                HeroIconStyle.solid,
                                                                color:
                                                                AppColors.purple,
                                                              ),
                                                            )
                                                                : const SizedBox
                                                                .shrink(),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              // Show a loading indicator when more notes are being loaded
                                              return Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    vertical: 0),
                                                child: Center(
                                                  child: state
                                                      .isLoadingMore
                                                      ? const Text('')
                                                      : const SpinKitFadingCircle(
                                                    color: AppColors
                                                        .primary,
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
                                          padding:
                                          EdgeInsets.only(top: 20.h),
                                          child: CreateCancelButtom(
                                            title: "OK",
                                            onpressCancel: () {
                                              _paymentSearchController
                                                  .clear();
                                              Navigator.pop(context);
                                            },
                                            onpressCreate: () {
                                              _paymentSearchController
                                                  .clear();
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    ));
                              }
                              return const Center(
                                  child: Text('Loading...'));
                            },
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        height: 40.h,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: widget.isCreate == true
                              ? Colors.transparent
                              : Theme.of(context).colorScheme.textfieldDisabled,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.greyColor),
                        ),
                        // decoration: DesignConfiguration.shadow(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CustomText(
                                text: widget.isCreate
                                    ? (paymentsname!=""
                                    ? "Select payment"
                                    : paymentsname!)
                                    : (paymentsname!=""
                                    ? widget.name!
                                    : paymentsname!),
                                fontWeight: FontWeight.w500,
                                size: 14.sp,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                color:
                                Theme.of(context).colorScheme.textClrChange,
                              ),
                            ),
                           Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
            else if (state is PaymentMethdSuccess) {
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      highlightColor: Colors.transparent, // No highlight on tap
                      splashColor: Colors.transparent,
                      onTap: () {
                        _paymentSearchController.clear();

                        // Fetch initial payment list
                        widget.isCreate == false
                            ? SizedBox()
                            : context
                            .read<PaymentMethodBloc>()
                            .add(PaymentMethdLists());
                        showDialog(
                          context: context,
                          builder: (ctx) => BlocConsumer<
                              PaymentMethodBloc, PaymentMethdState>(
                            listener: (context, state) {
                              if (state is PaymentMethdSuccess) {
                                isLoadingMore = false;
                                setState(() {});
                              }
                            },
                            builder: (context, state) {
                              if (state is PaymentMethdSuccess) {
                                return NotificationListener<
                                    ScrollNotification>(
                                    onNotification: (scrollInfo) {
                                      // Check if the user has scrolled to the end and load more notes if needed
                                      if (!state.isLoadingMore &&
                                          scrollInfo.metrics.pixels ==
                                              scrollInfo.metrics
                                                  .maxScrollExtent) {
                                        // isLoadingMore = true;
                                        setState(() {});
                                        context
                                            .read<
                                            PaymentMethodBloc>()
                                            .add(PaymentMethdLoadMore(
                                            searchWord));
                                      }
                                      // isLoadingMore = false;
                                      return false;
                                    },
                                    child: AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10.r), // Set the desired radius here
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .alertBoxBackGroundColor,
                                      contentPadding: EdgeInsets.zero,
                                      title: Center(
                                        child: Column(
                                          children: [
                                            CustomText(
                                              text: AppLocalizations.of(
                                                  context)!
                                                  .selectpayments,
                                              fontWeight: FontWeight.w800,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .whitepurpleChange,
                                            ),
                                            const Divider(),
                                            Padding(
                                              padding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 0.w),
                                              child: SizedBox(
                                                // color: Colors.red,
                                                height: 35.h,
                                                width: double.infinity,
                                                child: TextField(
                                                  cursorColor: AppColors
                                                      .greyForgetColor,
                                                  cursorWidth: 1,
                                                  controller:
                                                  _paymentSearchController,
                                                  decoration:
                                                  InputDecoration(
                                                    contentPadding:
                                                    EdgeInsets
                                                        .symmetric(
                                                      vertical:
                                                      (35.h - 20.sp) /
                                                          2,
                                                      horizontal: 10.w,
                                                    ),
                                                    hintText:
                                                    AppLocalizations.of(
                                                        context)!
                                                        .search,
                                                    enabledBorder:
                                                    OutlineInputBorder(
                                                      borderSide:
                                                      BorderSide(
                                                        color: AppColors
                                                            .greyForgetColor, // Set your desired color here
                                                        width:
                                                        1.0, // Set the border width if needed
                                                      ),
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          10.0), // Optional: adjust the border radius
                                                    ),
                                                    focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          10.0),
                                                      borderSide:
                                                      BorderSide(
                                                        color: AppColors
                                                            .purple, // Border color when TextField is focused
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                  ),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      searchWord = value;
                                                    });
                                                    context
                                                        .read<
                                                        PaymentMethodBloc>()
                                                        .add(
                                                        SearchPaymentMethd(
                                                            value));
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20.h,
                                            )
                                          ],
                                        ),
                                      ),
                                      content: Container(
                                        constraints: BoxConstraints(
                                            maxHeight: 900.h),
                                        width: 200.w,
                                        child:state.PaymentMethd.isEmpty?NoData(isImage: true,): ListView.builder(
                                          // physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: state.isLoadingMore
                                              ? state.PaymentMethd.length
                                              : state.PaymentMethd.length + 1,
                                          itemBuilder:
                                              (BuildContext context,
                                              int index) {
                                            if (index <
                                                state.PaymentMethd.length) {
                                              final isSelected =
                                                  paymentsId != null &&
                                                      state.PaymentMethd[index]
                                                          .id ==
                                                          paymentsId;
                                              return Padding(
                                                padding:
                                                EdgeInsets.symmetric(
                                                    vertical: 2.h,
                                                    horizontal: 20.w),
                                                child: InkWell(
                                                  highlightColor: Colors
                                                      .transparent, // No highlight on tap
                                                  splashColor:
                                                  Colors.transparent,
                                                  onTap: () {
                                                    setState(() {
                                                      if (widget
                                                          .isCreate ==
                                                          true) {
                                                        paymentsname =
                                                        state
                                                            .PaymentMethd[
                                                        index]
                                                            .title!;
                                                        paymentsId = state
                                                            .PaymentMethd[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .PaymentMethd[
                                                            index]
                                                                .title!,
                                                            state
                                                                .PaymentMethd[
                                                            index]
                                                                .id!);
                                                      } else {
                                                        name = state
                                                            .PaymentMethd[
                                                        index]
                                                            .title!;
                                                        paymentsname =
                                                        state
                                                            .PaymentMethd[
                                                        index]
                                                            .title!;
                                                        paymentsId = state
                                                            .PaymentMethd[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .PaymentMethd[
                                                            index]
                                                                .title!,
                                                            state
                                                                .PaymentMethd[
                                                            index]
                                                                .id!);
                                                      }
                                                    });

                                                    BlocProvider.of<
                                                        PaymentMethodBloc>(
                                                        context)
                                                        .add(SelectedPaymentMethd(
                                                        index,
                                                        state
                                                            .PaymentMethd[
                                                        index]
                                                            .title!));


                                                  },
                                                  child: Container(
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
                                                                .primary
                                                                : Colors
                                                                .transparent)),
                                                    width:
                                                    double.infinity,
                                                    height: 40.h,
                                                    child: Center(
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                            horizontal:
                                                            10.w),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              flex: 4,
                                                              // width:200.w,
                                                              child:
                                                              CustomText(
                                                                text: state
                                                                    .PaymentMethd[
                                                                index]
                                                                    .title!,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w500,
                                                                size: 18,
                                                                maxLines:
                                                                1,
                                                                overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                                color: isSelected
                                                                    ? AppColors
                                                                    .purple
                                                                    : Theme.of(context)
                                                                    .colorScheme
                                                                    .textClrChange,
                                                              ),
                                                            ),
                                                            isSelected
                                                                ? Expanded(
                                                              flex:
                                                              1,
                                                              child:
                                                              const HeroIcon(
                                                                HeroIcons.checkCircle,
                                                                style:
                                                                HeroIconStyle.solid,
                                                                color:
                                                                AppColors.purple,
                                                              ),
                                                            )
                                                                : const SizedBox
                                                                .shrink(),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              // Show a loading indicator when more notes are being loaded
                                              return Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    vertical: 0),
                                                child: Center(
                                                  child: !state
                                                      .isLoadingMore
                                                      ? const Text('')
                                                      : const SpinKitFadingCircle(
                                                    color: AppColors
                                                        .primary,
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
                                          padding:
                                          EdgeInsets.only(top: 20.h),
                                          child: CreateCancelButtom(
                                            title: "OK",
                                            onpressCancel: () {
                                              _paymentSearchController
                                                  .clear();
                                              Navigator.pop(context);
                                            },
                                            onpressCreate: () {
                                              _paymentSearchController
                                                  .clear();
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    ));
                              }
                              return const Center(
                                  child: Text('Loading...'));
                            },
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        height: 40.h,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(

                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.greyColor),
                        ),
                        // decoration: DesignConfiguration.shadow(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CustomText(
                                text: widget.isCreate
                                    ? (paymentsname==""
                                    ? "Select payment"
                                    : paymentsname!)
                                    : (paymentsname!=""
                                    ? widget.name!
                                    : paymentsname!),
                                fontWeight: FontWeight.w500,
                                size: 14.sp,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                color:
                                Theme.of(context).colorScheme.textClrChange,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            } else if (state is PaymentMethdError) {
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      highlightColor: Colors.transparent, // No highlight on tap
                      splashColor: Colors.transparent,
                      onTap: () {
                        _paymentSearchController.clear();

                        // Fetch initial payment list
                        widget.isCreate == false
                            ? SizedBox()
                            : context
                            .read<PaymentMethodBloc>()
                            .add(PaymentMethdLists());
                        widget.isCreate == false
                            ? SizedBox()
                            : showDialog(
                          context: context,
                          builder: (ctx) => BlocConsumer<
                              PaymentMethodBloc, PaymentMethdState>(
                            listener: (context, state) {
                              if (state is PaymentMethdSuccess) {
                                isLoadingMore = false;
                                setState(() {});
                              }
                            },
                            builder: (context, state) {
                              if (state is PaymentMethdSuccess) {
                                return NotificationListener<
                                    ScrollNotification>(
                                    onNotification: (scrollInfo) {
                                      // Check if the user has scrolled to the end and load more notes if needed
                                      if (!state.isLoadingMore &&
                                          scrollInfo.metrics.pixels ==
                                              scrollInfo.metrics
                                                  .maxScrollExtent) {
                                        // isLoadingMore = true;
                                        setState(() {});
                                        context
                                            .read<
                                            PaymentMethodBloc>()
                                            .add(PaymentMethdLoadMore(
                                            searchWord));
                                      }
                                      // isLoadingMore = false;
                                      return false;
                                    },
                                    child: AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10.r), // Set the desired radius here
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .alertBoxBackGroundColor,
                                      contentPadding: EdgeInsets.zero,
                                      title: Center(
                                        child: Column(
                                          children: [
                                            CustomText(
                                              text: AppLocalizations.of(
                                                  context)!
                                                  .selectpayments,
                                              fontWeight: FontWeight.w800,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .whitepurpleChange,
                                            ),
                                            const Divider(),
                                            Padding(
                                              padding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 0.w),
                                              child: SizedBox(
                                                // color: Colors.red,
                                                height: 35.h,
                                                width: double.infinity,
                                                child: TextField(
                                                  cursorColor: AppColors
                                                      .greyForgetColor,
                                                  cursorWidth: 1,
                                                  controller:
                                                  _paymentSearchController,
                                                  decoration:
                                                  InputDecoration(
                                                    contentPadding:
                                                    EdgeInsets
                                                        .symmetric(
                                                      vertical:
                                                      (35.h - 20.sp) /
                                                          2,
                                                      horizontal: 10.w,
                                                    ),
                                                    hintText:
                                                    AppLocalizations.of(
                                                        context)!
                                                        .search,
                                                    enabledBorder:
                                                    OutlineInputBorder(
                                                      borderSide:
                                                      BorderSide(
                                                        color: AppColors
                                                            .greyForgetColor, // Set your desired color here
                                                        width:
                                                        1.0, // Set the border width if needed
                                                      ),
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          10.0), // Optional: adjust the border radius
                                                    ),
                                                    focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          10.0),
                                                      borderSide:
                                                      BorderSide(
                                                        color: AppColors
                                                            .purple, // Border color when TextField is focused
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                  ),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      searchWord = value;
                                                    });
                                                    context
                                                        .read<
                                                        PaymentMethodBloc>()
                                                        .add(
                                                        SearchPaymentMethd(
                                                            value));
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20.h,
                                            )
                                          ],
                                        ),
                                      ),
                                      content: Container(
                                        constraints: BoxConstraints(
                                            maxHeight: 900.h),
                                        width: 200.w,
                                        child:state.PaymentMethd.isEmpty?NoData(isImage: true,): ListView.builder(
                                          // physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: state.isLoadingMore
                                              ? state.PaymentMethd.length
                                              : state.PaymentMethd.length + 1,
                                          itemBuilder:
                                              (BuildContext context,
                                              int index) {
                                            if (index <
                                                state.PaymentMethd.length) {
                                              final isSelected =
                                                  paymentsId != null &&
                                                      state.PaymentMethd[index]
                                                          .id ==
                                                          paymentsId;
                                              return Padding(
                                                padding:
                                                EdgeInsets.symmetric(
                                                    vertical: 2.h,
                                                    horizontal: 20.w),
                                                child: InkWell(
                                                  highlightColor: Colors
                                                      .transparent, // No highlight on tap
                                                  splashColor:
                                                  Colors.transparent,
                                                  onTap: () {
                                                    setState(() {
                                                      if (widget
                                                          .isCreate ==
                                                          true) {
                                                        paymentsname =
                                                        state
                                                            .PaymentMethd[
                                                        index]
                                                            .title!;
                                                        paymentsId = state
                                                            .PaymentMethd[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .PaymentMethd[
                                                            index]
                                                                .title!,
                                                            state
                                                                .PaymentMethd[
                                                            index]
                                                                .id!);
                                                      } else {
                                                        name = state
                                                            .PaymentMethd[
                                                        index]
                                                            .title!;
                                                        paymentsname =
                                                        state
                                                            .PaymentMethd[
                                                        index]
                                                            .title!;
                                                        paymentsId = state
                                                            .PaymentMethd[
                                                        index]
                                                            .id!;
                                                        widget.onSelected(
                                                            state
                                                                .PaymentMethd[
                                                            index]
                                                                .title!,
                                                            state
                                                                .PaymentMethd[
                                                            index]
                                                                .id!);
                                                      }
                                                    });

                                                    BlocProvider.of<
                                                        PaymentMethodBloc>(
                                                        context)
                                                        .add(SelectedPaymentMethd(
                                                        index,
                                                        state
                                                            .PaymentMethd[
                                                        index]
                                                            .title!));


                                                  },
                                                  child: Container(
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
                                                                .primary
                                                                : Colors
                                                                .transparent)),
                                                    width:
                                                    double.infinity,
                                                    height: 40.h,
                                                    child: Center(
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                            horizontal:
                                                            10.w),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              flex: 4,
                                                              // width:200.w,
                                                              child:
                                                              CustomText(
                                                                text: state
                                                                    .PaymentMethd[
                                                                index]
                                                                    .title!,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w500,
                                                                size: 18,
                                                                maxLines:
                                                                1,
                                                                overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                                color: isSelected
                                                                    ? AppColors
                                                                    .purple
                                                                    : Theme.of(context)
                                                                    .colorScheme
                                                                    .textClrChange,
                                                              ),
                                                            ),
                                                            isSelected
                                                                ? Expanded(
                                                              flex:
                                                              1,
                                                              child:
                                                              const HeroIcon(
                                                                HeroIcons.checkCircle,
                                                                style:
                                                                HeroIconStyle.solid,
                                                                color:
                                                                AppColors.purple,
                                                              ),
                                                            )
                                                                : const SizedBox
                                                                .shrink(),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              // Show a loading indicator when more notes are being loaded
                                              return Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    vertical: 0),
                                                child: Center(
                                                  child: state
                                                      .isLoadingMore
                                                      ? const Text('')
                                                      : const SpinKitFadingCircle(
                                                    color: AppColors
                                                        .primary,
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
                                          padding:
                                          EdgeInsets.only(top: 20.h),
                                          child: CreateCancelButtom(
                                            title: "OK",
                                            onpressCancel: () {
                                              _paymentSearchController
                                                  .clear();
                                              Navigator.pop(context);
                                            },
                                            onpressCreate: () {
                                              _paymentSearchController
                                                  .clear();
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    ));
                              }
                              return const Center(
                                  child: Text('Loading...'));
                            },
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        height: 40.h,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: widget.isCreate == true
                              ? Colors.transparent
                              : Theme.of(context).colorScheme.textfieldDisabled,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.greyColor),
                        ),
                        // decoration: DesignConfiguration.shadow(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CustomText(
                                text: widget.isCreate
                                    ? (paymentsname!=""
                                    ? "Select payment"
                                    : paymentsname!)
                                    : (paymentsname!=""
                                    ? widget.name!
                                    : paymentsname!),
                                fontWeight: FontWeight.w500,
                                size: 14.sp,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                color:
                                Theme.of(context).colorScheme.textClrChange,
                              ),
                            ),
                           Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
            return AbsorbPointer(
              absorbing: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    highlightColor: Colors.transparent, // No highlight on tap
                    splashColor: Colors.transparent,
                    onTap: () {
                      _paymentSearchController.clear();

                      // Fetch initial payment list
                      widget.isCreate == false
                          ? SizedBox()
                          : context
                          .read<PaymentMethodBloc>()
                          .add(PaymentMethdLists());
                      widget.isCreate == false
                          ? SizedBox()
                          : showDialog(
                        context: context,
                        builder: (ctx) => BlocConsumer<
                            PaymentMethodBloc, PaymentMethdState>(
                          listener: (context, state) {
                            if (state is PaymentMethdSuccess) {
                              isLoadingMore = false;
                              setState(() {});
                            }
                          },
                          builder: (context, state) {
                            if (state is PaymentMethdSuccess) {
                              return NotificationListener<
                                  ScrollNotification>(
                                  onNotification: (scrollInfo) {
                                    // Check if the user has scrolled to the end and load more notes if needed
                                    if (!state.isLoadingMore &&
                                        scrollInfo.metrics.pixels ==
                                            scrollInfo.metrics
                                                .maxScrollExtent) {
                                      // isLoadingMore = true;
                                      setState(() {});
                                      context
                                          .read<
                                          PaymentMethodBloc>()
                                          .add(PaymentMethdLoadMore(
                                          searchWord));
                                    }
                                    // isLoadingMore = false;
                                    return false;
                                  },
                                  child: AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10.r), // Set the desired radius here
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .alertBoxBackGroundColor,
                                    contentPadding: EdgeInsets.zero,
                                    title: Center(
                                      child: Column(
                                        children: [
                                          CustomText(
                                            text: AppLocalizations.of(
                                                context)!
                                                .selectpayments,
                                            fontWeight: FontWeight.w800,
                                            size: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .whitepurpleChange,
                                          ),
                                          const Divider(),
                                          Padding(
                                            padding:
                                            EdgeInsets.symmetric(
                                                horizontal: 0.w),
                                            child: SizedBox(
                                              // color: Colors.red,
                                              height: 35.h,
                                              width: double.infinity,
                                              child: TextField(
                                                cursorColor: AppColors
                                                    .greyForgetColor,
                                                cursorWidth: 1,
                                                controller:
                                                _paymentSearchController,
                                                decoration:
                                                InputDecoration(
                                                  contentPadding:
                                                  EdgeInsets
                                                      .symmetric(
                                                    vertical:
                                                    (35.h - 20.sp) /
                                                        2,
                                                    horizontal: 10.w,
                                                  ),
                                                  hintText:
                                                  AppLocalizations.of(
                                                      context)!
                                                      .search,
                                                  enabledBorder:
                                                  OutlineInputBorder(
                                                    borderSide:
                                                    BorderSide(
                                                      color: AppColors
                                                          .greyForgetColor, // Set your desired color here
                                                      width:
                                                      1.0, // Set the border width if needed
                                                    ),
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        10.0), // Optional: adjust the border radius
                                                  ),
                                                  focusedBorder:
                                                  OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        10.0),
                                                    borderSide:
                                                    BorderSide(
                                                      color: AppColors
                                                          .purple, // Border color when TextField is focused
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    searchWord = value;
                                                  });
                                                  context
                                                      .read<
                                                      PaymentMethodBloc>()
                                                      .add(
                                                      SearchPaymentMethd(
                                                          value));
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20.h,
                                          )
                                        ],
                                      ),
                                    ),
                                    content: Container(
                                      constraints: BoxConstraints(
                                          maxHeight: 900.h),
                                      width: 200.w,
                                      child:state.PaymentMethd.isEmpty?NoData(isImage: true,): ListView.builder(
                                        // physics: const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: state.isLoadingMore
                                            ? state.PaymentMethd.length
                                            : state.PaymentMethd.length + 1,
                                        itemBuilder:
                                            (BuildContext context,
                                            int index) {
                                          if (index <
                                              state.PaymentMethd.length) {
                                            final isSelected =
                                                paymentsId != null &&
                                                    state.PaymentMethd[index]
                                                        .id ==
                                                        paymentsId;
                                            return Padding(
                                              padding:
                                              EdgeInsets.symmetric(
                                                  vertical: 2.h,
                                                  horizontal: 20.w),
                                              child: InkWell(
                                                highlightColor: Colors
                                                    .transparent, // No highlight on tap
                                                splashColor:
                                                Colors.transparent,
                                                onTap: () {
                                                  setState(() {
                                                    if (widget
                                                        .isCreate ==
                                                        true) {
                                                      paymentsname =
                                                      state
                                                          .PaymentMethd[
                                                      index]
                                                          .title!;
                                                      paymentsId = state
                                                          .PaymentMethd[
                                                      index]
                                                          .id!;
                                                      widget.onSelected(
                                                          state
                                                              .PaymentMethd[
                                                          index]
                                                              .title!,
                                                          state
                                                              .PaymentMethd[
                                                          index]
                                                              .id!);
                                                    } else {
                                                      name = state
                                                          .PaymentMethd[
                                                      index]
                                                          .title!;
                                                      paymentsname =
                                                      state
                                                          .PaymentMethd[
                                                      index]
                                                          .title!;
                                                      paymentsId = state
                                                          .PaymentMethd[
                                                      index]
                                                          .id!;
                                                      widget.onSelected(
                                                          state
                                                              .PaymentMethd[
                                                          index]
                                                              .title!,
                                                          state
                                                              .PaymentMethd[
                                                          index]
                                                              .id!);
                                                    }
                                                  });

                                                  BlocProvider.of<
                                                      PaymentMethodBloc>(
                                                      context)
                                                      .add(SelectedPaymentMethd(
                                                      index,
                                                      state
                                                          .PaymentMethd[
                                                      index]
                                                          .title!));


                                                },
                                                child: Container(
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
                                                              .primary
                                                              : Colors
                                                              .transparent)),
                                                  width:
                                                  double.infinity,
                                                  height: 40.h,
                                                  child: Center(
                                                    child: Container(
                                                      padding: EdgeInsets
                                                          .symmetric(
                                                          horizontal:
                                                          10.w),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            flex: 4,
                                                            // width:200.w,
                                                            child:
                                                            CustomText(
                                                              text: state
                                                                  .PaymentMethd[
                                                              index]
                                                                  .title!,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w500,
                                                              size: 18,
                                                              maxLines:
                                                              1,
                                                              overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                              color: isSelected
                                                                  ? AppColors
                                                                  .purple
                                                                  : Theme.of(context)
                                                                  .colorScheme
                                                                  .textClrChange,
                                                            ),
                                                          ),
                                                          isSelected
                                                              ? Expanded(
                                                            flex:
                                                            1,
                                                            child:
                                                            const HeroIcon(
                                                              HeroIcons.checkCircle,
                                                              style:
                                                              HeroIconStyle.solid,
                                                              color:
                                                              AppColors.purple,
                                                            ),
                                                          )
                                                              : const SizedBox
                                                              .shrink(),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            // Show a loading indicator when more notes are being loaded
                                            return Padding(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  vertical: 0),
                                              child: Center(
                                                child: state
                                                    .isLoadingMore
                                                    ? const Text('')
                                                    : const SpinKitFadingCircle(
                                                  color: AppColors
                                                      .primary,
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
                                        padding:
                                        EdgeInsets.only(top: 20.h),
                                        child: CreateCancelButtom(
                                          title: "OK",
                                          onpressCancel: () {
                                            _paymentSearchController
                                                .clear();
                                            Navigator.pop(context);
                                          },
                                          onpressCreate: () {
                                            _paymentSearchController
                                                .clear();
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    ],
                                  ));
                            }
                            return const Center(
                                child: Text('Loading...'));
                          },
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      height: 40.h,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: widget.isCreate == true
                            ? Colors.transparent
                            : Theme.of(context).colorScheme.textfieldDisabled,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.greyColor),
                      ),
                      // decoration: DesignConfiguration.shadow(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomText(
                              text: paymentsname?.isNotEmpty == true ? paymentsname! : "Select payment",
                              fontWeight: FontWeight.w500,
                              size: 14.sp,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              color: Theme.of(context).colorScheme.textClrChange,
                            ),
                          ),
                      Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        )
      ],
    );
  }
}
