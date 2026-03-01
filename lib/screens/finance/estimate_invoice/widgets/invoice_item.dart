import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/model/finance/estimate_invoices_model.dart';
import 'package:taskify/screens/finance/estimate_invoice/widgets/quantity_field.dart';
import 'package:taskify/screens/finance/estimate_invoice/widgets/tax_list.dart';
import 'package:taskify/screens/finance/estimate_invoice/widgets/unit_list.dart';
import '../../../../bloc/estimate_invoice/estimateInvoice_bloc.dart';
import '../../../../bloc/estimate_invoice/estimateInvoice_event.dart';
import '../../../../bloc/estimate_invoice/estimateInvoice_state.dart';
import '../../../../bloc/theme/theme_bloc.dart';
import '../../../../bloc/theme/theme_state.dart';
import '../../../../utils/widgets/toast_widget.dart';
import '../../../widgets/custom_cancel_create_button.dart';
import '../../../widgets/custom_container.dart';
import '../../../widgets/custom_textfields/custom_textfield.dart';
import '../../../../utils/widgets/custom_text.dart';import '../../../../src/generated/i18n/app_localizations.dart';

class ItemEditDialog extends StatefulWidget {
  final bool? isCreate;
  final int invoiceId;
  final InvoicesItems? model;
  final Function(int, double?, String?, int?, double?, int?, String?, String?,
      InvoicesItems, String, String, String) onSelected;

  ItemEditDialog(
      {super.key,
      required this.invoiceId,
      this.isCreate,
      this.model,
      required this.onSelected});

  @override
  State<ItemEditDialog> createState() => _ItemEditDialogState();
}

class _ItemEditDialogState extends State<ItemEditDialog> {
  final TextEditingController priceController = TextEditingController();

  final TextEditingController titleController = TextEditingController();

  final TextEditingController descController = TextEditingController();

   TextEditingController amountController = TextEditingController();
  List<String>? selectedTaxName = [];
  List<int>? selectedTaxIds = [];
  List<String>? selectedItemName = [];
  List<int> selectedUnitIdS = [];

  List<String> selectedUnitName = [];
  String amount = "";
  String type = "";
  String percentage = "";

  double _quantity = 0.25;
  String? amountCal;
  void handleTaxSelected(List<String> category, List<int> catId, String amnt,
      String per, String itemType, int itemId) {
    setState(() {
      // Store tax info specific to this item
      selectedTaxIds = catId;
      selectedTaxName = category;
      amount = amnt;
      percentage = per;
      type = itemType;
      context.read<EstinateInvoiceBloc>().add(AmountCalculationEstinateInvoice(
            quantity: _quantity,
            rate: double.parse(priceController.text),
            tax: itemType == "amount" ? double.parse(amnt) : double.parse(per),
            type: type,
            itemId: itemId,
          ));
    });
  }

  void handleUnitSelected(List<String> category, List<int> catId, int itemID) {
    print("Selected unit for item $itemID: $catId");
    setState(() {
      selectedUnitName = category;
      selectedUnitIdS = catId;
    });
  }

  @override
  void initState() {

    titleController.text = widget.model!.name ?? "Title";
    descController.text = widget.model!.description ?? "";
    priceController.text = widget.model!.price ?? "--";

    selectedUnitName.add(widget.model!.unitName ?? "select unit");
    selectedUnitIdS.add(widget.model!.unit?.id ?? 0);
    selectedTaxName!.add(widget.model!.tax ?? "select tax");
    context.read<EstinateInvoiceBloc>().add(AmountCalculationEstinateInvoice(
          quantity: _quantity,
          rate: double.parse(widget.model!.price!),
          tax: 0,
          type: "",
          itemId: widget.invoiceId,
        ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return  AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10.r), // Set the desired radius here
        ),
        backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,
        title: CustomText(
          text: AppLocalizations.of(context)!.updateitem,
          color: Theme.of(context).colorScheme.textClrChange,
          size: 20.sp,
          fontWeight: FontWeight.w700,
          maxLines: null, // Allow unlimited lines
        ),
        content: BlocConsumer<EstinateInvoiceBloc, EstinateInvoiceState>(
            listener: (context, state) {
          if (state is AmountCalculatedState) {
            setState(() {
              amountController.text = context
                  .read<EstinateInvoiceBloc>()
                  .calculatedAmount
                  .toString();
              amountCal =
                  context.read<EstinateInvoiceBloc>().taxAmount.toString();
            });
          }
        }, builder: (context, state) {
          return SizedBox(
              width: 600.w, // custom width using screen util
              child: SingleChildScrollView(
                  child: Padding(
                padding: EdgeInsets.only(top: 20.w),
                child: Stack(children: [
                  Padding(
                      padding: EdgeInsets.only(top: 20.h),
                      child: customContainer(
                        context: context,
                        addWidget: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 10.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 18.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomText(
                                        text:
                                            AppLocalizations.of(context)!.title,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textClrChange,
                                        size: 16.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      SizedBox(
                                        height: 5.h,
                                      ),
                                      Container(
                                          height: 40.h,
                                          // Default to 40.h if height is not passed
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .textfieldDisabled,
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8.w),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                // Aligns left horizontally, center vertically
                                                child: CustomText(
                                                  text: widget.model!.name ??
                                                      "Title",
                                                  // Default text if title is null
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .textClrChange,
                                                  size: 16.sp,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ))),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      CustomText(
                                        text: AppLocalizations.of(context)!
                                            .description,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textClrChange,
                                        size: 16.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      SizedBox(
                                        height: 5.h,
                                      ),
                                      Container(
                                          height: 40.h,
                                          // Default to 40.h if height is not passed
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .textfieldDisabled,
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8.w),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                // Aligns left horizontally, center vertically
                                                child: CustomText(
                                                  text: widget
                                                          .model!.description ??
                                                      "",
                                                  // Default text if title is null
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .textClrChange,
                                                  size: 16.sp,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ))),
                                      SizedBox(
                                        height: 5.h,
                                      ),
                                      QuantityStepper(
                                          initialValue: _quantity,
                                          step: 0.25,
                                          onChanged: (value) {
                                            setState(() {
                                              _quantity =
                                                  value; // Use int key directly

                                              // Now use the item-specific quantity for calculations

                                              if (priceController
                                                  .text.isNotEmpty) {
                                                // Calculate with item-specific values
                                                context.read<EstinateInvoiceBloc>().add(
                                                  AmountCalculationEstinateInvoice(
                                                    quantity: _quantity,
                                                    rate: double.parse(priceController.text),
                                                    tax: type == "amount"
                                                        ? double.parse(amount )
                                                        : (double.tryParse(percentage) ?? 0.0),
                                                    type: type, // assuming it's non-nullable here
                                                    itemId: widget.invoiceId,
                                                  ),
                                                );

                                                amountCal = context
                                                    .read<EstinateInvoiceBloc>()
                                                    .taxAmount
                                                    .toString();
                                                ;
                                                amountController.text = context
                                                    .read<EstinateInvoiceBloc>()
                                                    .calculatedAmount
                                                    .toString();
                                              }
                                            });
                                          }),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                                UnitListField(
                                  fromProfile: false,
                                  ids: [0],
                                  isRequired: false,
                                  itemId: selectedUnitIdS.isNotEmpty
                                      ? selectedUnitIdS.first
                                      : 0,
                                  isCreate: widget.isCreate ?? false,
                                  name: [
                                    selectedUnitName.join(',')
                                  ],
                                  onSelected: handleUnitSelected,
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomTextFields(
                                      currency: true,
                                      title: AppLocalizations.of(context)!.rate,
                                      hinttext: AppLocalizations.of(context)!
                                          .pleaseenterrate,
                                      controller: priceController,
                                      keyboardType: TextInputType.number,
                                      onchange: (String? rate) {

                                          _validateInput(rate, context);

                                        context.read<EstinateInvoiceBloc>().add(
                                              AmountCalculationEstinateInvoice(
                                                quantity: _quantity,
                                                rate: double.parse(
                                                    priceController.text),
                                                tax: type == "amount"
                                                    ? double.parse(amount)
                                                    : double.tryParse(percentage ) ?? 0.0,
                                                type: type,
                                                itemId: widget.model!.id!,
                                              ),
                                            );
                                        // amountCal = context
                                        //     .read<EstinateInvoiceBloc>()
                                        //     .taxAmount
                                        //     .toString();
                                      },
                                      onSaved: (value) {},
                                      onFieldSubmitted: (value) {},
                                      isLightTheme: isLightTheme,
                                      isRequired: true,
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    TaxesListField(
                                      itemId: widget.invoiceId,
                                      fromProfile: false,
                                      ids: selectedTaxIds ?? [],
                                      isRequired: false,
                                      isCreate: widget.isCreate ?? false,
                                      name: selectedTaxName ?? [],
                                      onSelected: handleTaxSelected,
                                    ),
                                    if (context
                                            .read<EstinateInvoiceBloc>()
                                            .type ==
                                        "amount")
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 18.w),
                                        child: CustomText(
                                          text: amount ,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .textClrChange,
                                          size: 16.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    if (context
                                            .read<EstinateInvoiceBloc>()
                                            .type ==
                                        "percentage")
                                      context
                                                  .read<EstinateInvoiceBloc>()
                                                  .taxAmount !=
                                              ""
                                          ? Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 18.w),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    // color: Colors.red,
                                                    child: CustomText(
                                                      text: amountCal ?? "",
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .textClrChange,
                                                      size: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  Container(
                                                    // color: Colors.red,
                                                    child: CustomText(
                                                      text: " (${percentage}%)",
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .textClrChange,
                                                      size: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : SizedBox(),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    BlocListener<EstinateInvoiceBloc,
                                            EstinateInvoiceState>(
                                        listener: (context, state) {
                                          if (state is AmountCalculatedState &&
                                              state.Itemd == widget.model!.id) {
                                            // Update the text controller when amount is recalculated
                                            amountController.text =
                                                state.calculatedAmount;
                                          }
                                        },
                                        child: CustomTextFields(
                                          currency: true,
                                          title: AppLocalizations.of(context)!
                                              .amount,
                                          hinttext:
                                              AppLocalizations.of(context)!
                                                  .pleaseenteramount,
                                          controller: amountController,
                                          keyboardType: TextInputType.number,
                                          onSaved: (value) {

                                          },
                                          onFieldSubmitted: (value) {
                                          },
                                          onchange: (value) {
                                            _validateInput(value, context);
                                          },
                                          isLightTheme: isLightTheme,
                                          isRequired: true,
                                        ))
                                  ],
                                )
                              ],
                            )),
                        // Positioned(
                        //   top: 10,
                        //   right: 20,
                        //   child: Container(
                        //       height: 30.h,
                        //       width: 30.w,
                        //       decoration: BoxDecoration(
                        //         border: Border.all(color: AppColors.red),
                        //         boxShadow: [
                        //           isLightTheme
                        //               ? MyThemes.lightThemeShadow
                        //               : MyThemes.darkThemeShadow,
                        //         ],
                        //         color: Colors.red.shade100,
                        //         borderRadius: BorderRadius.circular(20),
                        //       ),
                        //       child: Center(
                        //         child: itemsList.any(
                        //                 (element) => element.id == item.id)
                        //             ? GestureDetector(
                        //           onTap: () {
                        //             setState(() {
                        //               itemsList.removeWhere(
                        //                       (element) =>
                        //                   element.id == item.id);
                        //             });
                        //           },
                        //           child: const Icon(
                        //             Icons.delete,
                        //             color: Colors.red,
                        //             size: 20,
                        //           ),
                        //         )
                        //             : const SizedBox
                        //             .shrink(), // Nothing is shown if not in the list
                        //       )),
                        // )
                      ))
                ]),
              )));
        }),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: 28.h),
            child: CreateCancelButtom(
              title: AppLocalizations.of(context)!.apply,
              onpressCancel: () {
                Navigator.pop(context);
              },
              onpressCreate: () {
                log("fldnm ${priceController.text}");
                log("fldnm ${amountController.text}");
                log("fldnmfesgdfgdg ${selectedTaxIds}");
                if (priceController.text.isNotEmpty &&
                    amountController.text.isNotEmpty &&
                    selectedTaxName!.isNotEmpty) {
                  var model = widget.model;
                  InvoicesItems invoice = InvoicesItems(
                    id: model!.id!,
                    name: model.title ?? "",
                    description: model.description ?? "",
                    quantity: _quantity.toString(),
                    price: priceController.text,
                    amount: amountController.text,
                    unitId: selectedUnitIdS[0].toString(),
                    tax: selectedTaxName![0],
                    unitName: selectedUnitName[0],
                  );
                  widget.onSelected(
                      widget.invoiceId,
                      _quantity,
                      selectedTaxName![0],
                      selectedUnitIdS[0],
                      double.parse(priceController.text),
                      0,
                      selectedTaxName![0],
                      amountController.text,
                      invoice,
                      amount,
                      amountCal!,
                      type);
                  Navigator.pop(context);
                } else {
                  flutterToastCustom(
                    msg: "yhdhghf",
                  );
                  flutterToastCustom(
                    msg: AppLocalizations.of(context)!
                        .pleasefilltherequiredfield,
                  );
                }
              },
            ),
          ),
        ],
      );

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
}
