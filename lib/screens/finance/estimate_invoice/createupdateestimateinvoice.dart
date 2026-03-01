import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/screens/finance/estimate_invoice/widgets/address.dart';
import 'package:taskify/screens/finance/estimate_invoice/widgets/client_single_select.dart';
import 'package:taskify/screens/finance/estimate_invoice/widgets/estimate_invoice_type.dart';
import 'package:taskify/screens/finance/estimate_invoice/widgets/invoice_item.dart';
import 'package:taskify/screens/finance/estimate_invoice/widgets/item_list.dart';
import 'package:taskify/screens/finance/estimate_invoice/widgets/status_of_estimate_invoice_field.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../../../bloc/clients/client_bloc.dart';
import '../../../bloc/clients/client_event.dart';
import '../../../bloc/estimate_invoice/estimateInvoice_bloc.dart';
import '../../../bloc/estimate_invoice/estimateInvoice_event.dart';
import '../../../bloc/estimate_invoice/estimateInvoice_state.dart';

import '../../../bloc/estimate_invoice_item_list/estimateInvoice_list_bloc.dart';
import '../../../bloc/estimate_invoice_item_list/estimateInvoice_list_event.dart';
import '../../../bloc/estimate_invoice_item_list/estimateInvoice_list_state.dart';
import '../../../bloc/items/item_bloc.dart';
import '../../../bloc/items/item_event.dart';
import '../../../bloc/setting/settings_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../config/constants.dart';
import '../../../config/internet_connectivity.dart';
import '../../../data/GlobalVariable/globalvariable.dart';
import '../../../data/model/finance/address.dart';
import '../../../data/model/finance/estimate_invoices_model.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../routes/routes.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/custom_textfields/custom_textfield.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/no_internet_screen.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../widgets/custom_date.dart';

class CreateUpdateEstimateInvoiceScreen extends StatefulWidget {
  final bool? isCreate;
  final EstimateInvoicesModel? estimateInvoicesModel;
  final List<InvoicesItems>? itemListWidget;
  final List<EstimateInvoicesUnit>? unitWidget;

  CreateUpdateEstimateInvoiceScreen({
    super.key,
    this.isCreate,
    this.estimateInvoicesModel,
    this.itemListWidget,
    this.unitWidget,
  });

  @override
  State<CreateUpdateEstimateInvoiceScreen> createState() => _CreateUpdateEstimateInvoiceScreenState();
}

class _CreateUpdateEstimateInvoiceScreenState extends State<CreateUpdateEstimateInvoiceScreen> {
  Map<int, double> taxes = {};
  Map<int, TextEditingController> rateControllers = {};
  Map<int, TextEditingController> amountControllers = {};

  TextEditingController startsController = TextEditingController();
  TextEditingController endController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController personalNoteController = TextEditingController();
  TextEditingController totalController = TextEditingController(text: "0");
  TextEditingController taxAmountController = TextEditingController(text: "0");
  TextEditingController finalTotalController = TextEditingController(text: "0");
  DateTime selectedDateStarts = DateTime.now();
  DateTime? selectedDateEnds = DateTime.now();

  String selectedUser = '';
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  int? selectedClientId;
  String? selectedClient;
  List<String>? usersName;
  List<int>? selectedusersNameId;
  String? fromDate;
  String? toDate;
  String? strtTime;
  String? endTime;
  String? formattedTimeStart;
  String? formattedTimeEnd;
  List<double> totalTaxList = [];

  String? addressName;
  String? addressContact;
  String? addressAddr;
  String? addressCity;
  String? addressState;
  String? addressCountry;
  String? addressZipcode;

  int? selectedSingleusersNameId;
  String? selectedEstimateInvoiceType;
  int? selectedEstimateInvoiceTypeId;
  List<int> selectedItemId = [];
  String? estimateInvoiceName;
  String? estimateInvoiceStatusName;
  String searchword = "";
  List<String>? selectedUnitName = [];
  List<String>? selectedTaxName = [];
  List<String>? selectedItemName = [];
  List<int> clientSelectedIdS = [];
  List<int> selectedUnitIdS = [];
  List<int> selectedTaxIdS = [];
  List<InvoicesItems> allItems = [];
  List<InvoicesItems> itemsList = [];

  List<int> quantityList = [];

  String? amount;
  String? amountCal;
  String? percentage;
  String? type;
  InvoicesItems? itemModel;
  List<String> clientSelectedname = [];

  String selectedCategory = '';
  String currency = '';

  List<int>? listOfuserId = [];
  List<int>? listOfclientId = [];
  List<int> itemsId = [];
  List<int> itemUnit = [];
  List<double> itemQuantity = [];
  List<int> itemPrice = [];
  String? formattedstart;
  String? formattedend;
  List<int> itemTax = [];
  List<int> itemAmount = [];

  List<double> subtotals = [];
  List<double> finalTotals = [];
  AddressModel? widgetStateModel;
  double totalTax = 0;
  Timer? _debounce;

  void _onChangedDebounced(String value, Function updateFunction) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      updateFunction(value);
    });
  }

  void _updateFieldsFromSubtotal(String value) {
    if (value.isEmpty) return;
    double subtotal = double.tryParse(value) ?? 0.0;
    double tax = double.tryParse(taxAmountController.text) ?? 0.0;
    double finalTotal = subtotal + tax;
    finalTotalController.value = TextEditingValue(
      text: finalTotal.toStringAsFixed(2),
      selection: TextSelection.collapsed(offset: finalTotal.toStringAsFixed(2).length),
    );
  }

  void _updateFieldsFromTax(String value) {
    if (value.isEmpty) return;
    double tax = double.tryParse(value) ?? 0.0;
    double subtotal = double.tryParse(totalController.text) ?? 0.0;
    double finalTotal = subtotal + tax;
    finalTotalController.value = TextEditingValue(
      text: finalTotal.toStringAsFixed(2),
      selection: TextSelection.collapsed(offset: finalTotal.toStringAsFixed(2).length),
    );
  }

  void _updateFieldsFromFinalTotal(String value) {
    if (value.isEmpty) return;
    double finalTotal = double.tryParse(value) ?? 0.0;
    double subtotal = double.tryParse(totalController.text) ?? 0.0;
    double tax = finalTotal - subtotal;
    taxAmountController.value = TextEditingValue(
      text: tax.toStringAsFixed(2),
      selection: TextSelection.collapsed(offset: tax.toStringAsFixed(2).length),
    );
  }

  void calculateGrandTotal() {
    subtotals.clear();
    taxes.clear();
    finalTotals.clear();

    double subtotal = itemsList.fold(0, (sum, item) {
      double rate = double.tryParse(item.price ?? '0') ?? 0;
      double quantity = double.tryParse(item.quantity ?? '1') ?? 1;
      return sum + (rate * quantity);
    });

    double tax = context.read<EstinateInvoiceBloc>().grandTotalTax;
    double finalTotal = subtotal + tax;

    subtotals.add(subtotal);
    totalController.text = subtotal.toStringAsFixed(2);
    context.read<EstinateInvoiceBloc>().setSubTotal(subtotal);
    finalTotalController.text = finalTotal.toStringAsFixed(2);
  }

  void handleItemSelected(List<String> names, List<int> ids, InvoicesItems selectedItem) {
    setState(() {
      if (!itemsList.any((item) => item.id == selectedItem.id)) {
        itemsList.insert(0, selectedItem);
        if (!selectedItemName!.contains(selectedItem.title)) {
          selectedItemName!.insert(0, selectedItem.title ?? '');
        }
        if (!selectedItemId.contains(selectedItem.id)) {
          selectedItemId.insert(0, selectedItem.id ?? 0);
        }
        final newItem = InvoicesItems(
          id: selectedItem.id,
          title: selectedItem.title,
          description: selectedItem.description,
          quantity: selectedItem.quantity ?? "1",
          unit: selectedItem.unit,
          rate: selectedItem.price!,
          tax: selectedItem.tax,
          amount: selectedItem.amount,
        );
        context.read<ItemInvoiceBloc>().add(AddItemEvent(
            newItem: newItem,
            estimateInvoiceId: widget.estimateInvoicesModel?.id ?? 0,
            itemListWidget: widget.itemListWidget));
        calculateGrandTotal();
      }
    });
  }

  void handleItemDeselected(int itemId) {
    setState(() {
      final index = itemsList.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        final removedItem = itemsList.removeAt(index);
        selectedItemId.remove(itemId);
        selectedItemName?.remove(removedItem.title ?? '');
        if (itemsList.isEmpty) {
          totalController.clear();
          taxAmountController.clear();
          finalTotalController.clear();
          selectedItemId.clear();
          selectedItemName = [];
        }
        calculateGrandTotal();
      }
    });
  }

  void _handleClientSelected(String? category, int? catId) {
    setState(() {
      selectedClient = category;
      selectedClientId = catId;
    });
  }

  void _handleAddressSelected(String? name, String? contact, String? address,
      String? city, String? state, String? country, String? zipcode) {
    setState(() {
      addressName = name;
      addressContact = contact;
      addressAddr = address;
      addressCity = city;
      addressState = state;
      addressCountry = country;
      addressZipcode = zipcode;
      AddressModel model = AddressModel(
          name: addressName ?? "",
          contact: addressContact ?? "",
          address: addressAddr ?? "",
          city: addressCity ?? "",
          state: addressState ?? "",
          country: addressCountry ?? "",
          zip: addressZipcode ?? "");
      widgetStateModel = model;
    });
  }

  void _handleEditItemPopUpSelected(
      int? invoiceId,
      double? quantity,
      String? unitName,
      int? unitId,
      double? rate,
      int? taxId,
      String? taxName,
      String? amount,
      InvoicesItems invoicesItems,
      String itemsAmount,
      String per,
      String type,
      ) {
    setState(() {
      double parsedPer = 0.0;
      if (per.isNotEmpty) {
        parsedPer = double.tryParse(per) ?? 0.0;
        if (parsedPer < 1.0) {
          parsedPer *= 100;
        }
      }

      if (parsedPer > 0.0) {
        if (taxes.containsKey(invoicesItems.id)) {
          taxes[invoicesItems.id!] = taxes[invoicesItems.id]! + parsedPer;
        } else {
          taxes[invoicesItems.id!] = parsedPer;
        }
      }

      totalTaxList.add(parsedPer);
      double totalTaxPercentage = totalTaxList.fold(0.0, (sum, value) => sum + value);
      context.read<EstinateInvoiceBloc>().setTaxTotal(totalTaxPercentage);
      taxAmountController.text = totalTaxPercentage.toStringAsFixed(2);
      context.read<EstinateInvoiceBloc>().grandTotalTax = totalTaxPercentage;

      final index = itemsList.indexWhere((item) => item.id == invoicesItems.id);
      if (index != -1) {
        itemsList[index] = invoicesItems;
      }
      calculateGrandTotal();
    });
  }

  void onCreateEstimateInvoice(BuildContext context) {
    if (estimateInvoiceName != null &&
        selectedClientId != null &&
        fromDate != null &&
        fromDate!.isNotEmpty) {
      if (itemsList.isNotEmpty) {
        final Map<String, List<dynamic>> mappedItems = {
          "item_ids": [],
          "item": [],
          "quantity": [],
          "unit": [],
          "rate": [],
          "tax": [],
          "amount": [],
        };

        for (final item in itemsList) {
          mappedItems["item_ids"]!.add(item.id);
          mappedItems["item"]!.add(item.id);
          mappedItems["quantity"]!.add(item.quantity ?? "0");
          mappedItems["unit"]!.add(item.unit?.id ?? "0");
          mappedItems["rate"]!.add(item.price ?? "0");
          mappedItems["tax"]!.add(item.tax ?? "0");
          mappedItems["amount"]!.add(
            (double.tryParse(item.amount ?? '0.00') ?? 0.0).toStringAsFixed(2),
          );
        }

        final estimateInvoice = BlocProvider.of<EstinateInvoiceBloc>(context);

        estimateInvoice.add(AddEstinateInvoices(
          EstimateInvoicesModel(
            type: estimateInvoiceName!,
            status: estimateInvoiceStatusName?.replaceAll(' ', '_') ?? "",
            clientId: selectedClientId,
            name: widgetStateModel?.name ?? "",
            address: widgetStateModel?.address ?? "",
            city: addressCity,
            state: addressState,
            country: addressCountry,
            zipCode: addressZipcode,
            phone: addressContact,
            note: noteController.text,
            personalNote: personalNoteController.text,
            fromDate: fromDate,
            toDate: toDate,
            total: totalController.text,
            taxAmount: taxAmountController.text,
            finalTotal: finalTotalController.text,
            items: itemsList,
          ),
          itemIds: mappedItems["item_ids"]!.map((e) => e.toString()).toList(),
          item: mappedItems["item"]!.map((e) => e.toString()).toList(),
          quantity: mappedItems["quantity"]!
              .map((e) => double.tryParse(e.toString()) ?? 0.0)
              .toList(),
          unit: mappedItems["unit"]!.map((e) => e.toString()).toList(),
          rate: mappedItems["rate"]!.map((e) => e.toString()).toList(),
          tax: mappedItems["tax"]!.map((e) => e.toString()).toList(),
          amount: mappedItems["amount"]!.map((e) => e.toString()).toList(),
        ));
      } else {
        flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleaseaddatleastoneitem,
        );
      }
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  void onUpdateEstimateInvoice(BuildContext context, int id) {
    final estimateInvoiceBloc = BlocProvider.of<EstinateInvoiceBloc>(context);

    final Map<String, List<dynamic>> mappedItems = {
      "item_ids": [],
      "item": [],
      "quantity": [],
      "unit": [],
      "rate": [],
      "tax": [],
      "amount": [],
    };

    for (final item in itemsList) {
      mappedItems["item_ids"]!.add(item.id);
      mappedItems["item"]!.add(item.id);
      mappedItems["quantity"]!.add(item.quantity ?? "0");
      mappedItems["unit"]!.add(item.unit?.id ?? "0");
      mappedItems["rate"]!.add(item.price ?? "0");
      mappedItems["tax"]!.add(item.tax ?? "0");
      mappedItems["amount"]!.add(
        (double.tryParse(item.amount ?? '0.00') ?? 0.0).toStringAsFixed(2),
      );
    }

    final dateFormatter = DateFormat('yyyy-MM-dd');
    String formattedDate = fromDate ?? dateFormatter.format(selectedDateStarts);
    String formattedDateTo = toDate ?? dateFormatter.format(selectedDateEnds ?? selectedDateStarts);

    estimateInvoiceBloc.add(EstinateInvoiceUpdateds(
      EstimateInvoicesModel(
        id: id,
        type: estimateInvoiceName != null
            ? estimateInvoiceName!.replaceAll(' ', '_')
            : widget.estimateInvoicesModel!.type,
        status: estimateInvoiceStatusName ?? widget.estimateInvoicesModel!.status,
        clientId: selectedClientId ?? widget.estimateInvoicesModel!.clientId,
        name: titleController.text.isNotEmpty
            ? titleController.text
            : widget.estimateInvoicesModel!.name,
        address: addressController.text.isNotEmpty
            ? addressController.text
            : widget.estimateInvoicesModel!.address,
        city: addressCity ?? widget.estimateInvoicesModel!.city,
        state: addressState ?? widget.estimateInvoicesModel!.state,
        country: addressCountry ?? widget.estimateInvoicesModel!.country,
        zipCode: addressZipcode ?? widget.estimateInvoicesModel!.zipCode,
        phone: addressContact ?? widget.estimateInvoicesModel!.phone,
        note: noteController.text.isNotEmpty
            ? noteController.text
            : widget.estimateInvoicesModel!.note,
        personalNote: personalNoteController.text.isNotEmpty
            ? personalNoteController.text
            : widget.estimateInvoicesModel!.personalNote,
        fromDate: formattedDate,
        toDate: formattedDateTo,
        total: totalController.text,
        taxAmount: taxAmountController.text,
        finalTotal: finalTotalController.text,
        items: itemsList,
      ),
      itemIds: List<int>.from(mappedItems["item_ids"]!),
      item: List<String>.from(mappedItems["item"]!.map((e) => e.toString())),
      quantity: List<String>.from(mappedItems["quantity"]!.map((e) => e.toString())),
      unit: List<String>.from(mappedItems["unit"]!.map((e) => e.toString())),
      rate: List<String>.from(mappedItems["rate"]!.map((e) => e.toString())),
      tax: mappedItems["tax"]!.map((e) => e.toString()).toList(),
      amount: List<String>.from(mappedItems["amount"]!),
    ));
  }

  @override
  void initState() {
    super.initState();
    selectedItemName = [];
    currency = context.read<SettingsBloc>().currencySymbol ?? "";
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() {
          _connectionStatus = results;
        });
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
        });
      }
    });
    BlocProvider.of<ItemsBloc>(context).add(ItemsList());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientBloc>().add(ClientList());
      currency = context.read<SettingsBloc>().currencySymbol!;
    });

    if (widget.isCreate == false && widget.estimateInvoicesModel != null) {
      AddressModel model = AddressModel(
        name: widget.estimateInvoicesModel!.name ?? "",
        contact: widget.estimateInvoicesModel!.phone ?? "",
        address: widget.estimateInvoicesModel!.address ?? "",
        city: widget.estimateInvoicesModel!.city ?? "",
        state: widget.estimateInvoicesModel!.state ?? '',
        country: widget.estimateInvoicesModel!.country ?? '',
        zip: widget.estimateInvoicesModel!.zipCode ?? '',
      );

      widgetStateModel = model;
      estimateInvoiceName = widget.estimateInvoicesModel!.type;
      estimateInvoiceStatusName = widget.estimateInvoicesModel?.status?.toLowerCase();
      List<InvoicesItems> updatedList = List.from(itemsList);

      widget.itemListWidget?.forEach((newItem) {
        final existingIndex = updatedList.indexWhere((item) => item.id == newItem.id);
        if (existingIndex != -1) {
          updatedList[existingIndex] = newItem;
        } else {
          updatedList.add(newItem);
          selectedItemName!.add(newItem.title ?? '');
          selectedItemId.add(newItem.id ?? 0);
        }
      });

      itemsList = updatedList;
      selectedClient = widget.estimateInvoicesModel!.client?.firstName ?? "";
      selectedClientId = widget.estimateInvoicesModel!.clientId;
      if (widget.estimateInvoicesModel!.fromDate != null &&
          widget.estimateInvoicesModel!.fromDate!.isNotEmpty) {
        DateTime parsedDate = parseDateStringFromApi(widget.estimateInvoicesModel!.fromDate!);
        formattedstart = dateFormatConfirmed(parsedDate, context);
        selectedDateStarts = parsedDate;
      }
      if (widget.estimateInvoicesModel!.toDate != null &&
          widget.estimateInvoicesModel!.toDate!.isNotEmpty) {
        DateTime parsedDateEnd = parseDateStringFromApi(widget.estimateInvoicesModel!.toDate!);
        formattedend = dateFormatConfirmed(parsedDateEnd, context);
        selectedDateEnds = parsedDateEnd;
      }
      startsController = TextEditingController(text: "$formattedstart <-> $formattedend");
      noteController.text = widget.estimateInvoicesModel!.note ?? "";
      totalController.text = widget.estimateInvoicesModel!.total?.toString() ?? "0";
      taxAmountController.text = widget.estimateInvoicesModel!.taxAmount?.toString() ?? "0";
      finalTotalController.text = widget.estimateInvoicesModel!.finalTotal?.toString() ?? "0";
    }
  }

  @override
  void dispose() {
    rateControllers.values.forEach((controller) => controller.dispose());
    amountControllers.values.forEach((controller) => controller.dispose());
    startsController.dispose();
    endController.dispose();
    amountController.dispose();
    titleController.dispose();
    noteController.dispose();
    rateController.dispose();
    addressController.dispose();
    personalNoteController.dispose();
    totalController.dispose();
    taxAmountController.dispose();
    finalTotalController.dispose();
    _connectivitySubscription.cancel();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    bool isLightTheme = currentTheme is LightThemeState;

    return _connectionStatus.contains(connectivityCheck)
        ? const NoInternetScreen()
        : Scaffold(
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            appbar(isLightTheme),
            SizedBox(height: 30.h),
            body(isLightTheme),
          ],
        ),
      ),
    );
  }

  Widget appbar(bool isLightTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 0.h),
          child: Container(
            decoration: BoxDecoration(boxShadow: [
              isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
            ]),
            child: BackArrow(
              iSBackArrow: true,
              onTap: () {
                context.read<EstinateInvoiceBloc>().add(const EstinateInvoiceLists([], [], [], [], "", ""));
                router.pop(context);
              },
              title: widget.isCreate == true
                  ? AppLocalizations.of(context)!.createestimateinvoice
                  : AppLocalizations.of(context)!.editestimateinvoice,
            ),
          ),
        ),
      ],
    );
  }

  Widget body(bool isLightTheme) {
    return BlocListener<EstinateInvoiceBloc, EstinateInvoiceState>(
      listener: (context, state) {
        if (state is EstinateInvoiceCreateSuccess) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          BlocProvider.of<ItemsBloc>(context).add(ItemsList());
          BlocProvider.of<EstinateInvoiceBloc>(context).add(
            const EstinateInvoiceLists([], [], [], [], "", ""),
          );
          flutterToastCustom(
            msg: AppLocalizations.of(navigatorKey.currentContext!)!.createdsuccessfully,
            color: AppColors.primary,
          );
        } else if (state is EstinateInvoiceError) {
          flutterToastCustom(msg: state.errorMessage);
        }

        if (state is AmountCalculatedState) {
          setState(() {
            int itemId = state.Itemd;
            if (amountControllers.containsKey(itemId)) {
              amountControllers[itemId]!.text = state.calculatedAmount;
            }
            amountController.text = state.calculatedAmount;
            amountCal = context.read<EstinateInvoiceBloc>().getCalculatedAmountForItem(itemId);
          });
        }
        if (state is EstinateInvoiceEditSuccess) {
          BlocProvider.of<EstinateInvoiceBloc>(context).add(const EstinateInvoiceLists([], [], [], [], "", ""));
          router.pop(context);
          flutterToastCustom(
            msg: AppLocalizations.of(context)!.updatedsuccessfully,
            color: AppColors.primary,
          );
        }
        if (state is EstinateInvoiceEditError) {
          flutterToastCustom(msg: state.errorMessage);
          BlocProvider.of<EstinateInvoiceBloc>(context).add(const EstinateInvoiceLists([], [], [], [], "", ""));
        }
      },
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EstimateInvoiceField(
              access: estimateInvoiceName,
              isRequired: true,
              isCreate: widget.isCreate!,
              from: "type",
              onSelected: (value) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    estimateInvoiceName = value.toLowerCase();
                  });
                });
              },
            ),
            SizedBox(height: 15.h),
            SingleClientField(
              isRequired: true,
              isCreate: widget.isCreate!,
              username: selectedClient ?? "",
              project: const [],
              clientId: selectedClientId,
              onSelected: _handleClientSelected,
            ),
            SizedBox(height: 15.h),
            if ((widget.isCreate == false &&
                widget.estimateInvoicesModel?.type != null &&
                widget.estimateInvoicesModel!.type!.isNotEmpty) ||
                (widget.isCreate == true && estimateInvoiceName != null && estimateInvoiceName!.isNotEmpty))
              EstimateInvoiceStatusField(
                type: widget.isCreate == false ? estimateInvoiceName : estimateInvoiceName!,
                access: estimateInvoiceStatusName ?? "",
                isRequired: false,
                isCreate: widget.isCreate!,
                from: "status",
                onSelected: (value) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      estimateInvoiceStatusName = value.toLowerCase();
                    });
                  });
                },
              ),
            SizedBox(height: 15.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomText(
                        text: AppLocalizations.of(context)!.address,
                        color: Theme.of(context).colorScheme.textClrChange,
                        size: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      const CustomText(
                        text: " *",
                        color: AppColors.red,
                        size: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                  InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      final addressToEdit = widgetStateModel ??
                          AddressModel(name: '', contact: '', address: '', city: '', state: '', country: '', zip: '');
                      showDialog(
                        context: context,
                        builder: (context) => AddressFormDialog(
                          isCreate: widget.isCreate,
                          model: addressToEdit,
                          onSelected: _handleAddressSelected,
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(end: 10.w),
                      child: Icon(
                        widget.isCreate == true ? Icons.add_box : Icons.edit_note,
                        color: Theme.of(context).colorScheme.fontColor,
                        size: 22.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5.h),
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                final addressToEdit = widgetStateModel ??
                    AddressModel(name: '', contact: '', address: '', city: '', state: '', country: '', zip: '');
                showDialog(
                  context: context,
                  builder: (context) => AddressFormDialog(
                    isCreate: widget.isCreate,
                    model: addressToEdit,
                    onSelected: _handleAddressSelected,
                  ),
                );
              },
              child: address(addressName, addressContact, addressAddr, addressCity, addressState, addressCountry, addressZipcode),
            ),
            SizedBox(height: 15.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: DateRangePickerWidget(
                selectedDateEnds: selectedDateEnds,
                selectedDateStarts: selectedDateStarts,
                star: true,
                dateController: startsController,
                title: AppLocalizations.of(context)!.date,
                titlestartend: AppLocalizations.of(context)!.selectstartenddate,
                onTap: (start, end) {
                  setState(() {
                    start = DateTime(start!.year, start!.month, start!.day);
                    end = DateTime(end!.year, end!.month, end!.day);
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    if (start!.isBefore(today)) {
                      start = today;
                    }
                    if (end!.isBefore(start!) || selectedDateEnds == null) {
                      end = start;
                    }
                    selectedDateStarts = start!;
                    selectedDateEnds = end;
                    String startAndEndText =
                        '${dateFormatConfirmed(selectedDateStarts, context)} - ${dateFormatConfirmed(selectedDateEnds!, context)}';
                    startsController.text = startAndEndText;
                    fromDate = dateFormatConfirmedToApi(start!);
                    toDate = dateFormatConfirmedToApi(end!);
                  });

                },
                isLightTheme: isLightTheme,
              ),
            ),
            SizedBox(height: 15.h),
            CustomTextFields(
              height: 112.h,
              keyboardType: TextInputType.multiline,
              title: AppLocalizations.of(context)!.personalnote,
              hinttext: AppLocalizations.of(context)!.enterpersonalnote,
              controller: personalNoteController,
              onSaved: (value) {},
              onFieldSubmitted: (value) {},
              isLightTheme: isLightTheme,
              isRequired: false,
            ),
            SizedBox(height: 15.h),
            CustomTextFields(
              height: 112.h,
              keyboardType: TextInputType.multiline,
              title: AppLocalizations.of(context)!.note,
              hinttext: AppLocalizations.of(context)!.pleaseenternotes,
              controller: noteController,
              onSaved: (value) {},
              onFieldSubmitted: (value) {},
              isLightTheme: isLightTheme,
              isRequired: false,
            ),
            SizedBox(height: 15.h),
            ItemsListField(
              ids: selectedItemId,
              isRequired: true,
              isCreate: widget.isCreate ?? false,
              name: selectedItemName,
              onSelected: handleItemSelected,
              onDeselected: handleItemDeselected,
              fromProfile: false,
            ),
            SizedBox(height: 15.h),
            BlocBuilder<ItemInvoiceBloc, ItemState>(
              builder: (context, state) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: itemsList.map((item) {
                      return Padding(
                        padding: EdgeInsets.only(top: 20.h),
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 20.h),
                              child: customContainer(
                                context: context,
                                addWidget: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                        child: CustomText(
                                          text: "# ${item.id.toString()}",
                                          color: Theme.of(context).colorScheme.textClrChange,
                                          size: 16.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CustomText(
                                              text: item.title ?? "Title",
                                              color: Theme.of(context).colorScheme.textClrChange,
                                              size: 16.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            SizedBox(height: 5.h),
                                            item.description !=null?  CustomText(
                                              text: item.description ?? "",
                                              color: Theme.of(context).colorScheme.textClrChange,
                                              size: 16.sp,
                                              fontWeight: FontWeight.w700,
                                            ):SizedBox.shrink(),
                                            SizedBox(height: 5.h),
                                            Tooltip(
                                              verticalOffset: -10,
                                              message: "Item Quantity",
                                              child: CustomText(
                                                text: "🔢 ${item.quantity != null ? item.quantity.toString() : "1"}",
                                                color: Theme.of(context).colorScheme.textClrChange,
                                                size: 16.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(height: 5.h),
                                            Tooltip(
                                              verticalOffset: -10,
                                              message: "Item Unit Name",
                                              child: CustomText(
                                                text: "📦 ${item.unitName ?? "-"}",
                                                color: Theme.of(context).colorScheme.textClrChange,
                                                size: 16.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(height: 5.h),
                                            selectedTaxName!.isNotEmpty
                                                ? CustomText(
                                              text: selectedTaxName!.join(','),
                                              color: Theme.of(context).colorScheme.textClrChange,
                                              size: 16.sp,
                                              fontWeight: FontWeight.w700,
                                            )
                                                : const SizedBox(),
                                            SizedBox(height: 5.h),
                                            item.price != null
                                                ? Tooltip(
                                              verticalOffset: -10,
                                              message: "Item Price",
                                              child:CustomText(
                                                                                                text: "💰${item.price ?? "-"}",
                                                                                                color: Theme.of(context).colorScheme.textClrChange,
                                                                                                size: 16.sp,
                                                                                                fontWeight: FontWeight.w700,
                                                                                              ),
                                                )
                                                : const SizedBox(),
                                            SizedBox(height: 5.h),
                                            item.amount != null
                                                ? CustomText(
                                              text: item.amount.toString(),
                                              color: Theme.of(context).colorScheme.textClrChange,
                                              size: 16.sp,
                                              fontWeight: FontWeight.w700,
                                            )
                                                : const SizedBox(),
                                            SizedBox(height: 5.h),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 20,
                              child: Container(
                                height: 30.h,
                                width: 30.w,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.red),
                                  boxShadow: [
                                    isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
                                  ],
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: itemsList.any((element) => element.id == item.id)
                                      ? GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        final index = itemsList.indexWhere((element) => element.id == item.id);
                                        if (index != -1) {
                                          final removedItem = itemsList.removeAt(index);
                                          selectedItemId.remove(removedItem.id);
                                          selectedItemName?.remove(removedItem.title ?? '');
                                        }
                                        if (itemsList.isEmpty) {
                                          totalController.clear();
                                          taxAmountController.clear();
                                          finalTotalController.clear();
                                          selectedItemId.clear();
                                          selectedItemName = [];
                                        }
                                        calculateGrandTotal();
                                      });
                                    },
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 60,
                              child: Container(
                                height: 30.h,
                                width: 30.w,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue),
                                  boxShadow: [
                                    isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
                                  ],
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: itemsList.any((element) => element.id == item.id)
                                      ? GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => ItemEditDialog(
                                          invoiceId: widget.estimateInvoicesModel?.id ?? 0,
                                          isCreate: widget.isCreate,
                                          model: item,
                                          onSelected: _handleEditItemPopUpSelected,
                                        ),
                                      );
                                    },
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                  )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            SizedBox(height: 20.h),
            CustomTextFields(
              keyboardType: TextInputType.number,
              currency: true,
              title: AppLocalizations.of(context)!.subtotal,
              hinttext: "",
              controller: totalController,
              onSaved: (value) {},
              onchange: (value) {
                _onChangedDebounced(value!, _updateFieldsFromSubtotal);
              },
              onFieldSubmitted: (value) {},
              isLightTheme: isLightTheme,
              isRequired: false,
            ),
            SizedBox(height: 15.h),
            CustomTextFields(
              currency: true,
              keyboardType: TextInputType.number,
              title: AppLocalizations.of(context)!.tax,
              hinttext: "",
              controller: taxAmountController,
              onSaved: (value) {},
              onchange: (value) {
                _onChangedDebounced(value!, _updateFieldsFromTax);
              },
              onFieldSubmitted: (value) {},
              isLightTheme: isLightTheme,
              isRequired: false,
            ),
            SizedBox(height: 15.h),
            CustomTextFields(
              currency: true,
              keyboardType: TextInputType.number,
              title: AppLocalizations.of(context)!.finaltotal,
              hinttext: "",
              onchange: (value) {
                _onChangedDebounced(value!, _updateFieldsFromFinalTotal);
              },
              controller: finalTotalController,
              onSaved: (value) {},
              onFieldSubmitted: (value) {},
              isLightTheme: isLightTheme,
              isRequired: false,
            ),
            SizedBox(height: 25.h),
            BlocBuilder<EstinateInvoiceBloc, EstinateInvoiceState>(
              builder: (context, state) {
                if (state is EstinateInvoiceEditSuccessLoading || state is EstinateInvoiceCreateSuccessLoading) {
                  return CreateCancelButtom(
                    isLoading: true,
                    isCreate: widget.isCreate,
                    onpressCreate: widget.isCreate == true
                        ? () => onCreateEstimateInvoice(context)
                        : () => onUpdateEstimateInvoice(context, widget.estimateInvoicesModel!.id!),
                    onpressCancel: () {
                      Navigator.pop(context);
                      context.read<EstinateInvoiceBloc>().add(const EstinateInvoiceLists([], [], [], [], "", ""));
                    },
                  );
                }
                return CreateCancelButtom(
                  isCreate: widget.isCreate,
                  onpressCreate: widget.isCreate == true
                      ? () => onCreateEstimateInvoice(context)
                      : () => onUpdateEstimateInvoice(context, widget.estimateInvoicesModel!.id!),
                  onpressCancel: () {
                    Navigator.pop(context);
                    context.read<EstinateInvoiceBloc>().add(const EstinateInvoiceLists([], [], [], [], "", ""));
                  },
                );
              },
            ),
            SizedBox(height: 35.h),
          ],
        ),
      ),
    );
  }

  Widget address(String? name, String? contact, String? addr, String? city,
      String? state, String? country, String? zipcode) {
    String _fallback(String? value, String fallback) {
      return (value != null && value.trim().isNotEmpty) ? value : fallback;
    }
    final displayName = _fallback(name ?? widget.estimateInvoicesModel?.name, "Name");
    final displayAddr = _fallback(addr ?? widget.estimateInvoicesModel?.address, "Address");
    final displayCity = _fallback(city ?? widget.estimateInvoicesModel?.city, "City");
    final displayState = _fallback(state ?? widget.estimateInvoicesModel?.state, "State");
    final displayCountry = _fallback(country ?? widget.estimateInvoicesModel?.country, "Country");
    final displayZipcode = _fallback(zipcode ?? widget.estimateInvoicesModel?.zipCode, "Zipcode");
    final displayContact = _fallback(contact ?? widget.estimateInvoicesModel?.phone, "Contact");

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.backGroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.person, size: 18.sp, color: Theme.of(context).iconTheme.color),
              SizedBox(width: 8.w),
              CustomText(
                text: displayName,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.home, size: 18.sp, color: Theme.of(context).iconTheme.color),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomText(
                  text: displayAddr,
                  color: Theme.of(context).colorScheme.textClrChange,
                  size: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.location_city, size: 18.sp, color: Theme.of(context).iconTheme.color),
              SizedBox(width: 8.w),
              CustomText(
                text: "$displayCity, $displayState",
                color: Theme.of(context).colorScheme.textClrChange,
                size: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.public, size: 18.sp, color: Theme.of(context).iconTheme.color),
              SizedBox(width: 8.w),
              CustomText(
                text: "$displayCountry, $displayZipcode",
                color: Theme.of(context).colorScheme.textClrChange,
                size: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.phone, size: 18.sp, color: Theme.of(context).iconTheme.color),
              SizedBox(width: 8.w),
              CustomText(
                text: displayContact,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ],
      ),
    );
  }
}