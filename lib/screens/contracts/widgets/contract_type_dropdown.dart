import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/bloc/contracts_type/contracts_type_bloc.dart';
import 'package:taskify/bloc/contracts_type/contracts_type_event.dart';
import 'package:taskify/bloc/contracts_type/contracts_type_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class ContractTypeField extends StatefulWidget {
  final bool isCreate;
  final String? name;
  final int? contractType;
  final bool? isRequired;
  final Function(String, int) onSelected;

  const ContractTypeField({
    super.key,
    this.name,
    required this.isCreate,
    required this.contractType,
    this.isRequired,
    required this.onSelected,
  });

  @override
  State<ContractTypeField> createState() => _ContractTypeFieldState();
}

class _ContractTypeFieldState extends State<ContractTypeField> {
  String? contractTypesName;
  int? contractTypesId;
  final TextEditingController _contractTypeSearchController = TextEditingController();
  bool _isSelecting = false; // Prevent multiple taps

  @override
  void initState() {
    super.initState();
    contractTypesName = widget.name;
    contractTypesId = widget.contractType;
    context.read<ContractTypeBloc>().add(ContractTypeList());
  }

  @override
  void dispose() {
    _contractTypeSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Building ContractTypeField: name=${widget.name}, contractType=${widget.contractType}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.contractstypes,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
              if (widget.isRequired == true)
                CustomText(
                  text: " *",
                  color: AppColors.red,
                  size: 15,
                  fontWeight: FontWeight.w400,
                ),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        BlocBuilder<ContractTypeBloc, ContractTypeState>(
          builder: (context, state) {
            return _buildContractTypeField(context, state);
          },
        ),
      ],
    );
  }

  Widget _buildContractTypeField(BuildContext context, ContractTypeState state) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: widget.isCreate
          ? () {
        _contractTypeSearchController.clear();
        context.read<ContractTypeBloc>().add(ContractTypeList());
        _showContractTypeDialog(context);
      }
          : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        height: 40.h,
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: widget.isCreate
              ? Colors.transparent
              : Theme.of(context).colorScheme.textfieldDisabled,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.greyColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomText(
                text: contractTypesName?.isEmpty ?? true
                    ? (widget.isCreate ? "Select contractType" : widget.name ?? "Select contractType")
                    : contractTypesName!,
                fontWeight: FontWeight.w500,
                size: 14.sp,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                color: Theme.of(context).colorScheme.textClrChange,
              ),
            ),
            if (widget.isCreate) const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void _showContractTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => BlocConsumer<ContractTypeBloc, ContractTypeState>(
        listener: (context, state) {
          if (state is ContractTypePaginated) {
            setState(() {}); // Ensure dialog updates when new data is loaded
          }
        },
        builder: (context, state) {
          if (state is ContractTypePaginated) {
            return _buildDialogContent(context, state);
          } else if (state is ContractTypeLoading) {
            return const Center(child: SpinKitFadingCircle(color: AppColors.primary, size: 40.0));
          } else if (state is ContractTypeError) {
           flutterToastCustom(msg: state.errorMessage);
          }
          return const Center(child: Text('Loading...'));
        },
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context, ContractTypePaginated state) {
    print('Building dialog with contractTypes: ${state.ContractType.length}');
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,
      contentPadding: EdgeInsets.zero,
      title: Column(
        children: [
          CustomText(
            text: AppLocalizations.of(context)!.selectcontracttype,
            fontWeight: FontWeight.w800,
            size: 20,
            color: Theme.of(context).colorScheme.whitepurpleChange,
          ),
          const Divider(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: SizedBox(
              height: 35.h,
              width: double.infinity,
              child: TextField(
                cursorColor: AppColors.greyForgetColor,
                cursorWidth: 1,
                controller: _contractTypeSearchController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: (35.h - 20.sp) / 2,
                    horizontal: 10.w,
                  ),
                  hintText: AppLocalizations.of(context)!.search,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.greyForgetColor, width: 1.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: AppColors.purple, width: 1.0),
                  ),
                ),
                onChanged: (value) {
                  context.read<ContractTypeBloc>().add(SearchContractType(value));
                },
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
      content: Container(
        constraints: BoxConstraints(maxHeight: 900.h),
        width: 200.w,
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (!state.hasReachedMax &&
                scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
              context.read<ContractTypeBloc>().add(LoadMoreContractType(_contractTypeSearchController.text));
              return true;
            }
            return false;
          },
          child: state.ContractType.isEmpty?NoData(isImage: true,):ListView.builder(
            shrinkWrap: true,
            itemCount: state.hasReachedMax ? state.ContractType.length : state.ContractType.length + 1,
            itemBuilder: (context, index) {
              if (index < state.ContractType.length) {
                final contract = state.ContractType[index];
                final isSelected = contractTypesId != null && contract.id == contractTypesId;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 20.w),
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () async {
                      if (_isSelecting) return;
                      _isSelecting = true;
                      print('Selected in dialog: id=${contract.id}, type=${contract.type}');
                      setState(() {
                        contractTypesName = contract.type;
                        contractTypesId = contract.id;
                      });
                      widget.onSelected(contract.type ??"", contract.id??0);
                      _isSelecting = false;
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.purpleShade : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
                      ),
                      height: 40.h,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 4,
                                child: CustomText(
                                  text: contract.type??"",
                                  fontWeight: FontWeight.w500,
                                  size: 18,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  color: isSelected
                                      ? AppColors.purple
                                      : Theme.of(context).colorScheme.textClrChange,
                                ),
                              ),
                              if (isSelected)
                                const Expanded(
                                  flex: 1,
                                  child: HeroIcon(
                                    HeroIcons.checkCircle,
                                    style: HeroIconStyle.solid,
                                    color: AppColors.purple,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(child: SpinKitFadingCircle(color: AppColors.primary, size: 40.0)),
                );
              }
            },
          ),
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(top: 20.h),
          child: CreateCancelButtom(
            title: "OK",
            onpressCancel: () {
              _contractTypeSearchController.clear();
              Navigator.pop(context);
            },
            onpressCreate: () {
              _contractTypeSearchController.clear();
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}