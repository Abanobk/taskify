import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:taskify/config/colors.dart';

import '../../../bloc/estimate_invoice/estimateInvoice_bloc.dart';
import '../../../bloc/estimate_invoice/estimateInvoice_event.dart';
import '../../../bloc/estimate_invoice/estimateInvoice_state.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/no_data.dart';
import '../../widgets/custom_cancel_create_button.dart';

class InvoiceList extends StatefulWidget {
  final bool isCreate;
  final String? name;
  final int? invoice;
  final bool? isRequired;
  // final List<StatusModel> status;

  final Function(String, int) onSelected;
  const InvoiceList(
      {super.key,
      this.name,
      required this.isCreate,
      required this.invoice,
      this.isRequired,
      required this.onSelected});

  @override
  State<InvoiceList> createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
  String? invoicesname;
  int? invoicesId;
  bool isLoadingMore = false;
  String searchWord = "";

  String? name;
  final TextEditingController _invoiceSearchController =
      TextEditingController();

  @override
  void initState() {

    name = "INV- ${widget.invoice}";
    if (!widget.isCreate) {
      invoicesId = widget.invoice;
    }
    print("fhdzif $invoicesId");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // if (!widget.isCreate) {
    //   invoicesId = widget.invoice;
    //   invoicesname = widget.name;
    // }

    return BlocProvider(
        create: (context) => EstinateInvoiceBloc()..add(EstinateInvoiceLists([],[],[],[],"","")),
        child: Column(
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
                    text: AppLocalizations.of(context)!.invoice,
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
            listEstinateInvoice()
          ],
        ));
  }

  Widget listEstinateInvoice() {
    return BlocConsumer<EstinateInvoiceBloc, EstinateInvoiceState>(
        listener: (context, state) {
      if (state is EstinateInvoiceSuccess) {
        isLoadingMore = false;
        setState(() {});
      }
    }, builder: (context, state) {
      if (state is EstinateInvoicePaginated) {
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
                  _invoiceSearchController.clear();

                  showDialog(
                      context: context,
                      builder: (ctx) => NotificationListener<
                              ScrollNotification>(
                          onNotification: (scrollInfo) {
                            // Check if the user has scrolled to the end and load more notes if needed
                            if (!state.hasReachedMax &&
                                scrollInfo.metrics.pixels ==
                                    scrollInfo.metrics.maxScrollExtent) {
                              // isLoadingMore = true;
                              setState(() {});
                              context
                                  .read<EstinateInvoiceBloc>()
                                  .add(LoadMoreEstinateInvoices(searchWord,[],[],
                                  [],[],"",""));
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
                                    text: AppLocalizations.of(context)!
                                        .selectinvoice,
                                    fontWeight: FontWeight.w800,
                                    size: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .whitepurpleChange,
                                  ),
                                  const Divider(),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 0.w),
                                    child: SizedBox(
                                      // color: Colors.red,
                                      height: 35.h,
                                      width: double.infinity,
                                      child: TextField(
                                        cursorColor: AppColors.greyForgetColor,
                                        cursorWidth: 1,
                                        controller: _invoiceSearchController,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: (35.h - 20.sp) / 2,
                                            horizontal: 10.w,
                                          ),
                                          hintText:
                                              AppLocalizations.of(context)!
                                                  .search,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: AppColors.greyForgetColor,
                                              // Set your desired color here
                                              width:
                                                  1.0, // Set the border width if needed
                                            ),
                                            borderRadius: BorderRadius.circular(
                                                10.0), // Optional: adjust the border radius
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: BorderSide(
                                              color: AppColors.purple,
                                              // Border color when TextField is focused
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            searchWord = value;
                                          });
                                          context
                                              .read<EstinateInvoiceBloc>()
                                              .add(SearchEstimateInvoices(
                                                  value,[],[],
                                              [],[],"",""));
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
                            content: StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              return Container(
                                constraints: BoxConstraints(maxHeight: 900.h),
                                width: 200.w,
                                child:state.EstinateInvoice.isEmpty?NoData(isImage: true,): ListView.builder(
                                  // physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: state.hasReachedMax
                                      ? state.EstinateInvoice.where(
                                              (item) => item.type != 'estimate')
                                          .length
                                      : state.EstinateInvoice.where((item) =>
                                              item.type != 'estimate').length +
                                          1,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final filteredInvoices =
                                        state.EstinateInvoice.where((item) =>
                                            item.type != 'estimate').toList();

                                    if (index < filteredInvoices.length) {
                                      final invoice = filteredInvoices[index];
                                      final isSelected = invoicesId != null && invoice.id == invoicesId;
                                      final prefix = invoice.type == 'invoice' ? 'INV-' : 'EST-';
                                      final displayText = "$prefix${invoice.id}";

                                      return Padding(
                                        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 20.w),
                                        child: InkWell(
                                          highlightColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          onTap: () {
                                            setState(() {
                                              invoicesname = displayText;
                                              invoicesId = invoice.id!;
                                              widget.onSelected(displayText, invoice.id!);
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isSelected ? AppColors.purpleShade : Colors.transparent,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: isSelected ? AppColors.primary : Colors.transparent),
                                            ),
                                            width: double.infinity,
                                            height: 40.h,
                                            child: Center(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: CustomText(
                                                        text: displayText,
                                                        fontWeight: FontWeight.w500,
                                                        size: 18,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        color: isSelected
                                                            ? AppColors.purple
                                                            : Theme.of(context).colorScheme.textClrChange,
                                                      ),
                                                    ),
                                                    isSelected
                                                        ? const Expanded(
                                                      flex: 1,
                                                      child: HeroIcon(
                                                        HeroIcons.checkCircle,
                                                        style: HeroIconStyle.solid,
                                                        color: AppColors.purple,
                                                      ),
                                                    )
                                                        : const SizedBox.shrink(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    else {
                                      // Show a loading indicator when more notes are being loaded
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 0),
                                        child: Center(
                                          child: state.hasReachedMax
                                              ? const Text('')
                                              : const SpinKitFadingCircle(
                                                  color: AppColors.primary,
                                                  size: 40.0,
                                                ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            }),
                            actions: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 20.h),
                                child: CreateCancelButtom(
                                  title: "OK",
                                  onpressCancel: () {
                                    _invoiceSearchController.clear();
                                    Navigator.pop(context);
                                  },
                                  onpressCreate: () {
                                    _invoiceSearchController.clear();
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          )));
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
                              ? (invoicesname?.isEmpty ?? true
                                  ? "Select invoice"
                                  : invoicesname!)
                              : (invoicesname?.isEmpty ?? true
                                  ? name!
                                  : invoicesname!),
                          fontWeight: FontWeight.w500,
                          size: 14.sp,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                      ),
                      widget.isCreate == false
                          ? SizedBox()
                          : Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      }

        return Container();


    });
  }
}
