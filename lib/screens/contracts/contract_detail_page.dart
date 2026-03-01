import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:taskify/bloc/contracts/contracts_event.dart';
import 'package:taskify/data/localStorage/hive.dart';

import 'package:taskify/data/model/contract/contract_model.dart';
import 'package:taskify/screens/widgets/html_widget.dart';

import 'package:taskify/utils/widgets/custom_text.dart';
import '../../bloc/contracts/contracts_bloc.dart';
import '../../bloc/contracts/contracts_state.dart';

import '../../bloc/setting/settings_bloc.dart';

import '../../config/colors.dart';
import '../../config/constants.dart';

import '../../routes/routes.dart';
import '../../utils/widgets/back_arrow.dart';

import '../../utils/widgets/toast_widget.dart';
import '../widgets/side_bar.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class ContractDetails extends StatefulWidget {
  final ContractModel? model;

  const ContractDetails({super.key, this.model});

  @override
  State<ContractDetails> createState() => _ContractDetailsState();
}

class _ContractDetailsState extends State<ContractDetails> {
  // List of items in our dropdown menu

  String? currency;
  String? currencyPosition;
  int? userId;
  String? userRole;
  String? base64Signature;

  final GlobalKey<SfSignaturePadState> _signaturePadKey =
      GlobalKey<SfSignaturePadState>();

  @override
  void initState() {
    currency = context.read<SettingsBloc>().currencySymbol;
    currencyPosition = context.read<SettingsBloc>().currencyPosition;
    _getUserID();
    _getUserRole();
    super.initState();
  }

  Future<void> _getUserID() async {
    final id = await HiveStorage.getUserId();
    setState(() {
      userId = id;
    });
  }

  Future<void> _getUserRole() async {
    final role = await HiveStorage.getRole();
    setState(() {
      userRole = role;
    });
  }

  Future<void> _onRefresh() async {
    // BlocProvider.of<ProjectidBloc>(context).add(ProjectIdListId(widget.id));
  }
  void _onSignContract(base64WithHeader) async {
    final contractBloc = BlocProvider.of<ContractBloc>(context);

    contractBloc.add(
        SignContract(id: widget.model!.id!, contractImage: base64WithHeader));
    contractBloc.stream.listen((state) {
      if (state is ContractSignCreateSuccess) {
        if (mounted) {
          context.read<ContractBloc>().add(const ContractList());
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.createdsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is ContractSignCreateError) {
        flutterToastCustom(msg: state.errorMessage);
      }
    });
  }

  void _onDeleteSignContract({String? title}) async {
    final contractBloc = BlocProvider.of<ContractBloc>(context);

    contractBloc.add(DeleteContractSign(widget.model!.id!));

    contractBloc.stream.listen((state) {
      if (state is ContractSignDeleteSuccess) {
        if (mounted) {
          // ✅ Clear the signature data
          setState(() {
            base64Signature = null;
            title == "promisor"
                ? widget.model!.signatures!.promisor!.url = null
                : widget.model!.signatures!.promisee!.url = null;
          });

          context.read<ContractBloc>().add(const ContractList());
          flutterToastCustom(
            msg: AppLocalizations.of(context)!.deletedsuccessfully,
            color: AppColors.primary,
          );
        }
      }

      if (state is ContractSignDeleteError) {
        flutterToastCustom(msg: state.errorMessage);
      }
    });
  }

  final SlidableBarController controller =
      SlidableBarController(initialStatus: false);

  @override
  Widget build(BuildContext context) {
    _getUserID();
    _getUserRole();
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (!didPop) {
            router.pop();
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.backGroundColor,
          body: Container(
              color: Theme.of(context).colorScheme.backGroundColor,
              child: SideBar(
                context: context,
                controller: controller,
                underWidget: RefreshIndicator(
                  color: AppColors.primary, // Spinner color
                  backgroundColor:
                      Theme.of(context).colorScheme.backGroundColor,
                  onRefresh: _onRefresh,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0.w),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18.w),
                            child: BackArrow(
                              onTap: () {
                                router.pop();
                              },
                              title:
                                  AppLocalizations.of(context)!.contractdetail,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18.w),
                                child: _contractDetailCard(context),
                              ),
                              SizedBox(
                                height: 50.h,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        ));
  }

  Widget _contractDetailCard(context) {
    String? startDate;
    String? endDate;
    if (widget.model!.startDate != null) {
      startDate = formatDateFromApi(widget.model!.startDate!, context);
      endDate = formatDateFromApi(widget.model!.endDate!, context);
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 10.h,
          ),
          Container(
            height: 50.h,
            width: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/png/splashlogo.png"))),
          ),
          SizedBox(
            height: 10.h,
          ),
          RowDesign(AppLocalizations.of(context)!.title,
              "${widget.model!.title}", false, false),
          RowDesign(AppLocalizations.of(context)!.id,
              "CTR-${widget.model!.id.toString()}", false, false),
          RowDesign(AppLocalizations.of(context)!.project,
              "${widget.model!.project!.title}", true, false),
          RowDesign(AppLocalizations.of(context)!.client,
              "${widget.model!.client!.name}", true, false),
          RowDesign(AppLocalizations.of(context)!.value,
              "${widget.model!.value}", false, false),
          RowDesign(AppLocalizations.of(context)!.createdby,
              "${widget.model!.createdBy!.name}", true, false),
          RowDesign(AppLocalizations.of(context)!.type,
              "${widget.model!.createdBy!.type}", true, false),
          RowDesign(AppLocalizations.of(context)!.status,
              "${widget.model!.status!.replaceAll("_", " ")}", true, true),
          RowDesign(AppLocalizations.of(context)!.startdate, "${startDate}",
              false, false),
          RowDesign(AppLocalizations.of(context)!.enddate, "${endDate}", false,
              false),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomText(
                text: "${AppLocalizations.of(context)!.description} :",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                size: 14.sp,
                color: AppColors.greyColor,
                fontWeight: FontWeight.w600,
              ),
              htmlWidget(widget.model!.description ?? "", context),
            ],
          ),
          SizedBox(
            height: 20.h,
          ),
          CustomText(
            text: AppLocalizations.of(context)!.promisorsign,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            size: 16.sp,
            color: Theme.of(context).colorScheme.textChange,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(
            height: 10.h,
          ),
          widget.model!.signatures!.promisor!.url != null
              ? Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: base64Signature != null
                      ? Image.memory(
                          base64Decode(base64Signature!),
                          fit: BoxFit.contain,
                        )
                      : (widget.model?.signatures?.promisor?.url != null
                          ? Image.network(
                              widget.model!.signatures!.promisor!.url!,
                              fit: BoxFit.contain,
                            )
                          : Center(
                              child: Text(
                                "No Signature",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )),
                )
              : CustomText(
                  text: AppLocalizations.of(context)!.notsigned,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  size: 14.sp,
                  color: AppColors.greyColor,
                  fontWeight: FontWeight.w600,
                ),
          SizedBox(
            height: 10.h,
          ),
          (userRole != "Client" && userRole != "client") &&
                  widget.model!.createdBy!.id == userId &&
                  widget.model!.signatures!.promisor!.url != null
              ? InkWell(
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10.r), // Set the desired radius here
                          ),
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .alertBoxBackGroundColor,
                          title:
                              Text(AppLocalizations.of(context)!.confirmDelete),
                          content:
                              Text(AppLocalizations.of(context)!.areyousure),
                          actions: [
                            TextButton(
                              onPressed: () {
                                _onDeleteSignContract(title: "promisor");
                                Navigator.of(context)
                                    .pop(true); // Confirm deletion
                              },
                              child: Text(AppLocalizations.of(context)!.delete),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(false); // Cancel deletion
                              },
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                          ],
                        );
                      },
                    );
                    // _onDeleteSignContract();
                  },
                  child: Container(
                    padding: EdgeInsets.all(8), // Optional padding for tap area
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: HeroIcon(
                      HeroIcons.trash,
                      style: HeroIconStyle.solid,
                      color: AppColors.whiteColor,
                      size: 20,
                    ),
                  ),
                )
              : widget.model!.createdBy!.id == userId
                  ? InkWell(
                      onTap: () {
                        signatureDialog(context);
                      },
                      child: Container(
                        padding:
                            EdgeInsets.all(8), // Optional padding for tap area
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: HeroIcon(
                          HeroIcons.plus,
                          style: HeroIconStyle.solid,
                          color: AppColors.whiteColor,
                          size: 20,
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
          SizedBox(
            height: 10.h,
          ),
          CustomText(
            text: AppLocalizations.of(context)!.promiseesign,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            size: 16.sp,
            color: Theme.of(context).colorScheme.textChange,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 10.h),
          widget.model!.signatures!.promisee!.url != null
              ? Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: base64Signature != null
                      ? Image.memory(
                          base64Decode(base64Signature!),
                          fit: BoxFit.contain,
                        )
                      : (widget.model?.signatures?.promisee?.url != null
                          ? Image.network(
                              widget.model!.signatures!.promisee!.url!,
                              fit: BoxFit.contain,
                            )
                          : Center(
                              child: Text(
                                "No Signature",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )),
                )
              : CustomText(
                  text: AppLocalizations.of(context)!.notsigned,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  size: 14.sp,
                  color: AppColors.greyColor,
                  fontWeight: FontWeight.w600,
                ),
          SizedBox(height: 10.h),
          (userRole == "Client" || userRole == "client") &&
                  widget.model!.client!.id == userId &&
                  widget.model!.signatures!.promisee!.url != null
              ? InkWell(
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .alertBoxBackGroundColor,
                          title:
                              Text(AppLocalizations.of(context)!.confirmDelete),
                          content:
                              Text(AppLocalizations.of(context)!.areyousure),
                          actions: [
                            TextButton(
                              onPressed: () {
                                _onDeleteSignContract(title: "promisee");
                                Navigator.of(context).pop(true);
                              },
                              child: Text(AppLocalizations.of(context)!.delete),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: HeroIcon(
                      HeroIcons.trash,
                      style: HeroIconStyle.solid,
                      color: AppColors.whiteColor,
                      size: 20,
                    ),
                  ),
                )
              : (userRole == "Client" || userRole == "client") &&
                      widget.model!.client!.id == userId
                  ? InkWell(
                      onTap: () {
                        signatureDialog(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: HeroIcon(
                          HeroIcons.plus,
                          style: HeroIconStyle.solid,
                          color: AppColors.whiteColor,
                          size: 20,
                        ),
                      ),
                    )
                  : SizedBox.shrink(),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _printContract();
                },
                icon: Icon(Icons.print),
                label: Text("Print Contract"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }


  void _printContract() async {
    final pdf = pw.Document();

    // Helper function to load image from network URL
    Future<pw.ImageProvider?> loadNetworkImage(String? url) async {
      if (url == null || url.isEmpty) return null;
      try {
        final dio = Dio();
        final response = await dio.get(
          url,
          options: Options(responseType: ResponseType.bytes),
        );
        if (response.statusCode == 200) {
          return pw.MemoryImage(response.data);
        }
      } catch (e) {
        log('Error loading image from URL: $e');
      }
      return null;
    }

    // Helper function to load image from base64
    pw.ImageProvider? loadBase64Image(String? base64String) {
      if (base64String == null || base64String.isEmpty) return null;
      try {
        final bytes = base64Decode(base64String);
        return pw.MemoryImage(bytes);
      } catch (e) {
        log('Error loading base64 image: $e');
        return null;
      }
    }

    // Load signature images
    pw.ImageProvider? promisorSignature;
    pw.ImageProvider? promiseeSignature;

    // Load promisor signature
    if (widget.model!.signatures!.promisor!.url != null) {
      if (base64Signature != null) {
        // Use local base64 signature if available
        promisorSignature = loadBase64Image(base64Signature);
      } else {
        // Load from network URL
        promisorSignature = await loadNetworkImage(widget.model!.signatures!.promisor!.url);
      }
    }

    // Load promisee signature
    if (widget.model!.signatures!.promisee!.url != null) {
      if (base64Signature != null) {
        // Use local base64 signature if available
        promiseeSignature = loadBase64Image(base64Signature);
      } else {
        // Load from network URL
        promiseeSignature = await loadNetworkImage(widget.model!.signatures!.promisee!.url);
      }
    }

    // Format dates
    String? startDate;
    String? endDate;
    if (widget.model!.startDate != null) {
      startDate = formatDateFromApi(widget.model!.startDate!, context);
      endDate = formatDateFromApi(widget.model!.endDate!, context);
    }

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  "Contract Details",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),

              // Contract Information
              pw.Text("Contract ID: CTR-${widget.model?.id ?? ''}",
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),

              pw.Text("Title: ${widget.model?.title ?? ''}",
                  style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 8),

              pw.Text("Client: ${widget.model?.client?.name ?? ''}",
                  style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 8),

              pw.Text("Project: ${widget.model?.project?.title ?? ''}",
                  style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 8),

              pw.Text("Status: ${widget.model?.status?.replaceAll("_", " ") ?? ''}",
                  style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 8),

              pw.Text("Created By: ${widget.model?.createdBy?.name ?? ''}",
                  style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 8),

              pw.Text("Type: ${widget.model?.createdBy?.type ?? ''}",
                  style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 8),

              pw.Text("Value: ${widget.model?.value ?? ''}",
                  style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 8),

              if (startDate != null)
                pw.Text("Start Date: $startDate",
                    style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 8),

              if (endDate != null)
                pw.Text("End Date: $endDate",
                    style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 20),

              // Description
              pw.Text("Description:",
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text(widget.model?.description ?? '',
                  style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 30),

              // Signatures Section
              pw.Text("Signatures:",
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),

              // Promisor Signature
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Promisor Signature:",
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 10),
                        if (promisorSignature != null)
                          pw.Container(
                            height: 100,
                            width: 200,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.black, width: 1),
                            ),
                            child: pw.Image(promisorSignature, fit: pw.BoxFit.contain),
                          )
                        else
                          pw.Container(
                            height: 100,
                            width: 200,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.black, width: 1),
                            ),
                            child: pw.Center(
                              child: pw.Text("Not Signed",
                                  style: pw.TextStyle(color: PdfColors.grey)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),

                  // Promisee Signature
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Promisee Signature:",
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 10),
                        if (promiseeSignature != null)
                          pw.Container(
                            height: 100,
                            width: 200,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.black, width: 1),
                            ),
                            child: pw.Image(promiseeSignature, fit: pw.BoxFit.contain),
                          )
                        else
                          pw.Container(
                            height: 100,
                            width: 200,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.black, width: 1),
                            ),
                            child: pw.Center(
                              child: pw.Text("Not Signed",
                                  style: pw.TextStyle(color: PdfColors.grey)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

              // Footer
              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  "Generated on ${DateTime.now().toString().split(' ')[0]}",
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );

    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      log('Error generating PDF: $e');
      flutterToastCustom(
        msg: "Error generating PDF: ${e.toString()}",
        color: AppColors.red,
      );
    }
  }

  Widget RowDesign(label, value, isColored, isBox) {
    String cleaned = widget.model!.status!.replaceAll('_', ' ');
    String capitalized = cleaned.length > 0
        ? cleaned[0].toUpperCase() + cleaned.substring(1)
        : cleaned;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          CustomText(
            text: "$label : ",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            size: 14.sp,
            color: AppColors.greyColor,
            fontWeight: FontWeight.w600,
          ),
          if (isBox == true)
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: double.infinity),
              child: IntrinsicWidth(
                child: Container(
                  alignment: Alignment.center,
                  height: 25.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue.shade800,
                  ),
                  child: CustomText(
                    text: capitalized,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    color: AppColors.whiteColor,
                    size: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            CustomText(
              text: value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              size: 14.sp,
              color: isColored ? AppColors.primary : AppColors.greyColor,
              fontWeight: FontWeight.w400,
            ),
        ],
      ),
    );
  }

  Future<void> signatureDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Center(
            child: Container(
              height: 200,
              width: 300,
              child: SfSignaturePad(
                key: _signaturePadKey,
                minimumStrokeWidth: 1,
                maximumStrokeWidth: 3,
                strokeColor: Colors.black,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Capture the signature as an image
                final renderedImage = await _signaturePadKey.currentState!
                    .toImage(pixelRatio: 1.0);
                final byteData =
                    await renderedImage.toByteData(format: ImageByteFormat.png);
                final pngBytes = byteData!.buffer.asUint8List();

                // Encode PNG to base64 with proper header
                final base64Image = base64.encode(pngBytes);
                final base64WithHeader = 'data:image/png;base64,$base64Image';
                setState(() {
                  base64Signature =
                      base64Image; // ⚠️ Store only the raw base64 data without header for Image.memory
                });

                log('Base64 Image with header: $base64WithHeader'); // This is what you want to send to API
                _onSignContract(base64WithHeader);

                // TODO: Send base64WithHeader to your API here

                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
