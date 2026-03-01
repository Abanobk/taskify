import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';
import '../../../routes/routes.dart';
import '../../../src/generated/i18n/app_localizations.dart';

import 'package:taskify/bloc/contracts/contracts_bloc.dart';
import 'package:taskify/bloc/interviews/interviews_bloc.dart';
import 'package:taskify/bloc/interviews/interviews_event.dart';
import 'package:taskify/bloc/interviews/interviews_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/data/model/contract/contract_model.dart';
import '../../../bloc/contracts/contracts_event.dart';
import '../../../bloc/contracts/contracts_state.dart';
import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/permissions/permissions_event.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/constants.dart';
import '../../../config/internet_connectivity.dart';
import '../../../utils/widgets/back_arrow.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/no_internet_screen.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../Project/widgets/project_field.dart';
import '../../widgets/clients_field.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/custom_date.dart';
import '../../widgets/custom_textfields/custom_textfield.dart';
import '../widgets/contract_type_dropdown.dart';

class CreateEditContract extends StatefulWidget {
  final bool? isCreate;
  final ContractModel? contractModel;
  const CreateEditContract({super.key, this.isCreate, this.contractModel});

  @override
  State<CreateEditContract> createState() => _CreateEditContractState();
}

class _CreateEditContractState extends State<CreateEditContract> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  String? selectedColorName;
  bool? isLoading;
  String storedDateStart = "";
  String storedDateEnd = "";
  final ValueNotifier<File?> selectedFileNotifier = ValueNotifier(null);
  final ValueNotifier<String?> fileName = ValueNotifier(null);

  TextEditingController titleController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();

  DateTime selectedDateStarts = DateTime.now();
  DateTime selectedDateEnds = DateTime.now();

  String? toPassStartDate = "";
  ContractModel? contract;
  String? dateStartPart;
  String? dateEndPart;
  String? timePart;
  List<int>? selectedClientId;
  List<String>? selectedClient;

  String? selectedCategory;
  int? selectedID;
  String? fromDate;
  String? toDate;
  String? selectedContractTypeCategory;
  int? selectedContractTypeID;
  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  void _handleClientSelected(List<String> category, List<int> catId) {
    setState(() {
      selectedClient = category;
      selectedClientId = catId;
    });
  }

  void _handleProjectSelected(String category, int catID) {
    setState(() {
      selectedCategory = category;
      selectedID = catID;
    });
  }

  void _handleContractTypeSelected(String category, int catID) {
    setState(() {
      selectedContractTypeCategory = category;
      selectedContractTypeID = catID;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
    _initializePermissions();
    _initializeCandidateData();
  }

  void _initializeConnectivity() {
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() => _connectionStatus = results);
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() => _connectionStatus = value);
        });
      }
    });
  }

  void _initializePermissions() {
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
  }

  void _initializeCandidateData() {
    print("fghjk ${widget.contractModel!.id}");
    if (widget.contractModel != null) {
      _initializeControllers();
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      selectedFileNotifier.value = File(result.files.single.path!);
      print("Selected File: ${selectedFileNotifier.value}");
      fileName.value = result.files.single.name;
      print("Selected File Name: $fileName");
    }
  }

  void _initializeControllers() {
    contract = widget.contractModel!;
    print("jeofm; ${contract!.client!.id}");
    print("contract!.project!.title; ${ widget.contractModel!.title}");
    // print("jeofm; ${contractInterview!.candidateName}");
    // print("jeofm; MODe ${contractInterview!.status}");
    // selectedCandidate = contractInterview!.candidateName;
    // selectedCandidateId = contractInterview!.candidateId;
    // selectedInterviewerId = contractInterview!.interviewerId;
    // selectedInterviewer = contractInterview!.interviewerName;
    titleController.text = contract!.title!;
    valueController.text = contract!.value!;
    valueController.text = contract!.value!;
    selectedClient = [contract!.client!.name!];
    selectedClientId = [contract!.client!.id!];
    selectedCategory = contract!.title;
    selectedID = contract!.project!.id;
    selectedContractTypeCategory = contract!.contractType!.name;
    selectedContractTypeID = contract!.contractType!.id;
    descController.text = contract!.description ?? "";
    if (contract!.startDate != "") {
      final rawDateTime = contract!.startDate!;
      final dateTime = DateTime.parse(rawDateTime);

      final formated =
          "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
      // final timePart =
      //     "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
      DateTime parsedDate = parseDateStringFromApi(formated);
      dateStartPart = dateFormatConfirmed(parsedDate, context);

      startController.text = '📅 $dateStartPart';
    }
    if (contract!.endDate != "") {
      final rawDateTime = contract!.endDate!;
      final dateTime = DateTime.parse(rawDateTime);

      final formated =
          "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

      DateTime parsedDate = parseDateStringFromApi(formated);
      dateEndPart = dateFormatConfirmed(parsedDate, context);

      endController.text = '📅 $dateEndPart';
    }
  }

  void _validateAndSubmitForm() {
    if (widget.isCreate == true) {
      _onCreateContract();
    } else {
      _onEditContract(contract!);
    }
  }

  void _onCreateContract() {
    print('titleController.text: ${titleController.text}');
    print('valueController.text: ${valueController.text}');
    print('selectedClientId: ${selectedClientId}');
    print('selectedClient: $selectedClient');
    print('selectedID: $selectedID');
    print('selectedID: ${selectedID}');
    print('selectedCategory: $selectedCategory');
    print('selectedContractTypeID: $selectedContractTypeID');
    print('selectedContractTypeCategory: $selectedContractTypeCategory');
    print('dateStartPart: $dateStartPart');
    print('dateEndPart: $dateEndPart');
    print('storedDateStart: $storedDateStart');
    print('storedDateEnd: $storedDateEnd');
    print('descController.text: ${descController.text}');
    // Remove 0 from selectedClientId if it exists
    if (selectedClientId != null && selectedClientId!.contains(0)) {
      selectedClientId = selectedClientId!.where((id) => id != 0).toList();
    }
    if (titleController.text.isNotEmpty &&
        valueController.text.isNotEmpty &&
        selectedClientId != null &&
        selectedID != null &&
        selectedContractTypeID != null &&
        storedDateStart != "" &&
        storedDateEnd != "") {
      Client clientModel = Client(id: selectedClientId![0], name: selectedClient![0]);
      Project projectModel =
          Project(id: selectedID, title: selectedCategory![0]);
      ContractType contractTypeModel = ContractType(
          id: selectedContractTypeID, name: selectedContractTypeCategory![0]);
      ContractModel model = ContractModel(
        title: titleController.text,
        value: valueController.text,
        startDate: storedDateStart,
        endDate: storedDateEnd,
        client: clientModel,
        project: projectModel,
        contractType: contractTypeModel,
        description: descController.text,
      );
      context.read<ContractBloc>().add(CreateContract(model: model));
      final contract = context.read<ContractBloc>();
      contract.stream.listen((state) {
        if (state is ContractCreateSuccess) {
          if (mounted) {

            isLoading = false;
            BlocProvider.of<ContractBloc>(context).add(ContractList());
            Navigator.pop(context);
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.createdsuccessfully,
                color: AppColors.primary);
          }
        }
        if (state is ContractCreateError ) {
          isLoading = false;
          BlocProvider.of<ContractBloc>(context).add(ContractList());
          flutterToastCustom(msg: state.errorMessage);
        } if ( state is ContractCreateSuccessLoading ) {
          isLoading = false;
          BlocProvider.of<ContractBloc>(context).add(ContractList());

        }
      });
      // CandidateBloc.add(CandidateList());
    } else {
      flutterToastCustom(
          msg: AppLocalizations.of(context)!.pleasefilltherequiredfield);
    }
  }
  void _onEditContract(candidate) async {
    print('titleController.text: ${titleController.text}');
    print('valueController.text: ${valueController.text}');
    print('selectedClientId: $selectedClientId');
    print('selectedClient: $selectedClient');
    print('selectedID: $selectedID');
    print('selectedCategory: $selectedCategory');
    print('selectedContractTypeID: $selectedContractTypeID');
    print('selectedContractTypeCategory: $selectedContractTypeCategory');
    print('dateStartPart: $dateStartPart');
    print('dateEndPart: $dateEndPart');
    print('descController.text: ${descController.text}');

    // ✅ Convert user input to DateTime using supported formats
    DateTime? parsedStart = formatDateFromApiAsDate(dateStartPart!, context);
    DateTime? parsedEnd = formatDateFromApiAsDate(dateEndPart!, context);

    // ❌ If parsing fails, show toast
    if (parsedStart == null || parsedEnd == null) {
      flutterToastCustom(msg: AppLocalizations.of(context)!.invalidNumberFormat,color: AppColors.red);
      return;
    }

    // ✅ Convert to required API format: yyyy-MM-dd
    String storedDateStart = dateFormatConfirmedToApi(parsedStart);
    String storedDateEnd = dateFormatConfirmedToApi(parsedEnd);

    // ✅ Clean and validate the value input
    String numericValue = valueController.text.replaceAll(RegExp(r'[^\d.-]'), '');
    try {
      double parsedValue = double.parse(numericValue);
      if (parsedValue < 0) {
        flutterToastCustom(
          msg: AppLocalizations.of(context)!.negativeValueNotAllowed,
          color: AppColors.red,
        );
        return;
      }
    } catch (e) {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.invalidNumberFormat,
        color: AppColors.red,
      );
      return;
    }

    if (titleController.text.isNotEmpty &&
        valueController.text.isNotEmpty &&
        selectedClientId != null &&
        selectedID != null &&
        selectedContractTypeID != null &&
        storedDateStart != "" &&
        storedDateEnd != "") {
      Client clientModel =
      Client(id: selectedClientId![0], name: selectedClient![0]);
      Project projectModel =
      Project(id: selectedID, title: selectedCategory![0]);
      ContractType contractTypeModel = ContractType(
          id: selectedContractTypeID, name: selectedContractTypeCategory![0]);

      ContractModel model = ContractModel(
        id: widget.contractModel!.id!,
        title: titleController.text,
        value: numericValue,
        startDate: storedDateStart,
        endDate: storedDateEnd,
        client: clientModel,
        project: projectModel,
        contractType: contractTypeModel,
        description: descController.text,
      );

      context.read<ContractBloc>().add(UpdateContract(model, selectedFileNotifier.value));

      final contract = context.read<ContractBloc>();
      contract.stream.listen((state) {
        if (state is ContractEditSuccess) {
          if (mounted) {
            isLoading = false;
            BlocProvider.of<ContractBloc>(context).add(ContractList());
            Navigator.pop(context);
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.updatedsuccessfully,
                color: AppColors.primary);
          }
        } else if (state is ContractCreateError) {
          isLoading = false;
          BlocProvider.of<ContractBloc>(context).add(ContractList());
          flutterToastCustom(msg: state.errorMessage);
        } else if (state is ContractEditSuccessLoading) {
          isLoading = false;
          BlocProvider.of<ContractBloc>(context).add(ContractList());
        }
      });
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  // void _onEditContract(candidate) async {
  //   print('titleController.text: ${titleController.text}');
  //   print('valueController.text: ${valueController.text}');
  //   print('selectedClientId: $selectedClientId');
  //   print('selectedClient: $selectedClient');
  //   print('selectedID: $selectedID');
  //   print('selectedCategory: $selectedCategory');
  //   print('selectedContractTypeID: $selectedContractTypeID');
  //   print('selectedContractTypeCategory: $selectedContractTypeCategory');
  //   print('dateStartPart: $dateStartPart');
  //   print('dateEndPart: $dateEndPart');
  //   print('storedDateStart: $storedDateStart');
  //   print('storedDateEnd: $storedDateEnd');
  //   print('descController.text: ${descController.text}');
  //   if (titleController.text.isNotEmpty &&
  //       valueController.text.isNotEmpty &&
  //       selectedClientId != null &&
  //       selectedID != null &&
  //       selectedContractTypeID != null &&
  //       storedDateStart != "" &&
  //       storedDateEnd != "") {
  //     String numericValue = valueController.text.replaceAll(RegExp(r'[^\d.,]'), '');
  //
  //     Client clientModel =
  //         Client(id: selectedClientId![0], name: selectedClient![0]);
  //     Project projectModel =
  //         Project(id: selectedID, title: selectedCategory![0]);
  //     ContractType contractTypeModel = ContractType(
  //         id: selectedContractTypeID, name: selectedContractTypeCategory![0]);
  //     ContractModel model = ContractModel(
  //       id: widget.contractModel!.id!,
  //       title: titleController.text,
  //       value: numericValue,
  //       startDate: storedDateStart,
  //       endDate: storedDateEnd ,
  //       client: clientModel,
  //       project: projectModel,
  //       contractType: contractTypeModel,
  //       description: descController.text,
  //     );
  //     context.read<ContractBloc>().add(UpdateContract(model, selectedFileNotifier.value));
  //     final contract = context.read<ContractBloc>();
  //     contract.stream.listen((state) {
  //       if (state is ContractEditSuccess) {
  //         if (mounted) {
  //
  //           isLoading = false;
  //           BlocProvider.of<ContractBloc>(context).add(ContractList());
  //           Navigator.pop(context);
  //           flutterToastCustom(
  //               msg: AppLocalizations.of(context)!.createdsuccessfully,
  //               color: AppColors.primary);
  //         }
  //       }
  //       if (state is ContractCreateError ) {
  //         isLoading = false;
  //         BlocProvider.of<ContractBloc>(context).add(ContractList());
  //         flutterToastCustom(msg: state.errorMessage);
  //       } if ( state is ContractEditSuccessLoading ) {
  //         isLoading = false;
  //         BlocProvider.of<ContractBloc>(context).add(ContractList());
  //
  //       }
  //     });
  //     // CandidateBloc.add(CandidateList());
  //   } else {
  //
  //     flutterToastCustom(
  //       msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
  //     );
  //   }
  //   // Navigator.pop(context);
  // }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    bool isLightTheme = currentTheme is LightThemeState;

    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, Object? result) async {
              if (!didPop) {
                router.pop(context);
              }
            },
            child: Scaffold(
              backgroundColor: Theme.of(context).colorScheme.backGroundColor,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(isLightTheme),
                    SizedBox(height: 30.h),
                    _buildForm(isLightTheme),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildHeader(bool isLightTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 0.h),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    isLightTheme
                        ? MyThemes.lightThemeShadow
                        : MyThemes.darkThemeShadow,
                  ],
                ),
                child: BackArrow(
                  onTap: () {
                    if (widget.isCreate == false) {
                      router.pop();

                    } else {
                      router.pop();
                    }
                    // router.pop();
                  },
                  title: widget.isCreate == true
                      ? AppLocalizations.of(context)!.createcontract
                      : AppLocalizations.of(context)!.updatecontract,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm(bool isLightTheme) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15.h),
            _buildFormFields(isLightTheme),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return BlocConsumer<InterviewsBloc, InterviewsState>(
      listener: (context, state) {
        if (state is InterviewsCreateError) {
          flutterToastCustom(msg: state.errorMessage);
          context.read<InterviewsBloc>().add(const InterviewsList());
        }
        if (state is InterviewsError) {
          flutterToastCustom(msg: state.errorMessage);
          context.read<InterviewsBloc>().add(const InterviewsList());
        }
        if (state is InterviewsEditError) {
          flutterToastCustom(msg: state.errorMessage);
          // context.read<CandidatesBloc>().add(const CandidatesList());
        }
        if (state is InterviewsCreateSuccess) {
          context.read<InterviewsBloc>().add(const InterviewsList());
          if (mounted) {
            Navigator.pop(context);
            // router.go('/notes');
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.createdsuccessfully,
                color: AppColors.primary);
          }
        }
        if (state is InterviewsEditSuccess) {
          context.read<InterviewsBloc>().add(const InterviewsList());
          if (mounted) {
            Navigator.pop(context);
            // router.go('/notes');
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.updatedsuccessfully,
                color: AppColors.primary);
          }
        }
      },
      builder: (context, state) {
        print("gbhnjmkl, $state");
        final isLoading =
            state is InterviewsLoading || state is InterviewsEditSuccessLoading;
        return Padding(
          padding: EdgeInsets.only(bottom: 58.h),
          child: CreateCancelButtom(
            isLoading: isLoading,
            isCreate: widget.isCreate,
            onpressCancel: () {
              Navigator.pop(context);
            BlocProvider.of<ContractBloc>(context)
                .add(SearchContract(""));

            },
            onpressCreate: () => _validateAndSubmitForm(),
          ),
        );
      },
    );
  }

  // Widget _buildActionButtons() {
  //   return BlocBuilder<InterviewsBloc, InterviewsState>(
  //     builder: (context, state) {
  //       if(state is InterviewsCreateSuccess){
  //
  //       }
  //       final isLoading = state is ClientLoadingCreate || state is ClientLoadingEdit;
  //   return CreateCancelButtom(
  //     isLoading: isLoading,
  //     isCreate: widget.isCreate,
  //     onpressCancel: () => Navigator.pop(context),
  //     onpressCreate: () => _validateAndSubmitForm(),
  //   );
  //     },
  //   );
  // }

  Widget _buildFormFields(isLightTheme) {
    print("cfgbhj ${selectedClient}");
    return Column(
      children: [
        CustomTextFields(
          title: AppLocalizations.of(context)!.title,
          hinttext: AppLocalizations.of(context)!.title,
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
          currency: true,
          title: AppLocalizations.of(context)!.value,
          hinttext: AppLocalizations.of(context)!.value,
          controller: valueController,
          keyboardType: TextInputType.number,
          onSaved: (value) {
            _validateInput(value, context);
          },
          onFieldSubmitted: (value) {
            _validateInput(value, context);
          },
          onchange: (value) {
            _validateInput(value, context);
          },
          isLightTheme: isLightTheme,
          isRequired: true,
        ),
        SizedBox(
          height: 15.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: DatePickerWidget(
            star: true,
            size: 12.sp,
            dateController: startController,
            title: AppLocalizations.of(context)!.startsat,
            onTap: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: selectedDateStarts ,
                firstDate: DateTime(1600),
                lastDate: DateTime.now().add(const Duration(days: 3652)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      dialogTheme: DialogThemeData(backgroundColor: Theme.of(context).scaffoldBackgroundColor),
                    ),
                    child: child!,
                  );
                },
              );

              if (selectedDate != null) {
                setState(() {
                  selectedDateStarts = selectedDate;

                  // ✅ Format for display
                  String formattedStart = dateFormatConfirmed(selectedDate, context);

                  // ✅ Format for API
                  storedDateStart = DateFormat('yyyy-MM-dd').format(selectedDate);

                  fromDate = formattedStart;
                  startController.text = '📅 $formattedStart';

                  print('Stored Start Date (API): $storedDateStart');
                });
              } else {
                // Optional: handle cancel
                print('Date selection cancelled');
              }
            },

            isLightTheme: isLightTheme,
          ),
        ),

        SizedBox(
          height: 15.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: DatePickerWidget(
            star: true,
            size: 12.sp,
            dateController: endController,
            title: AppLocalizations.of(context)!.endsat,
            onTap: () async{
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: selectedDateEnds,
                firstDate: DateTime(1600),
                lastDate: DateTime.now().add(const Duration(days: 3652)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      dialogTheme: DialogThemeData(backgroundColor: Theme
                          .of(context)
                          .scaffoldBackgroundColor),
                    ),
                    child: child!,
                  );
                },
              );

              if (selectedDate != null) {
                setState(() {
                  selectedDateEnds = selectedDate;
                  storedDateEnd = DateFormat('yyyy-MM-dd').format(selectedDate);
                  toDate = dateFormatConfirmed(selectedDate, context);
                  endController.text = '📅 $toDate';
                });
              }
            },

            isLightTheme: isLightTheme,),
        ),
        SizedBox(
          height: 15.h,
        ),
        ClientField(
            isRequired: true,
            isCreate: widget.isCreate!,
            usersname: selectedClient ?? [],
            project: const [],
            clientsid: [widget.contractModel!.client!.id!],
            onSelected: _handleClientSelected),
        SizedBox(
          height: 15.h,
        ),
        ProjectField(
          openDropdown: true,
          isRequired: true,
          isCreate: widget.isCreate!,
          project: widget.contractModel!.project != null
              ? widget.contractModel!.project!.id
              : 0,
          name: selectedCategory ?? "",
          index: widget.contractModel!.project!.id,
          onSelected: _handleProjectSelected,
        ),
        SizedBox(
          height: 15.h,
        ),
        ContractTypeField(
          isRequired: true,
          isCreate: widget.isCreate!,
          contractType: widget.contractModel!.contractType != null
              ? widget.contractModel!.contractType!.id
              : 0,
          name: selectedContractTypeCategory ?? "",
          onSelected: _handleContractTypeSelected,
        ),
        SizedBox(
          height: 15.h,
        ),
        CustomTextFields(
          height: 112.h,
          keyboardType: TextInputType.multiline,
          title: AppLocalizations.of(context)!.description,
          hinttext: AppLocalizations.of(context)!.pleaseenterdescription,
          controller: descController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: false,
        ),
        SizedBox(height: 15.h),
        ( widget.isCreate == false)  ?     _buildFilePickerContainer(isLightTheme):SizedBox.shrink()
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
  Widget _buildFilePickerButton(bool isLightTheme) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: _pickFile,
      child: CustomText(
        text: AppLocalizations.of(context)!.choosefile,
        fontWeight: FontWeight.w400,
        size: 14.sp,
        color: Theme.of(context).colorScheme.textClrChange,
      ),
    );
  }

  Widget _buildFilePickerContainer(bool isLightTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: customContainer(
          width: 600.w,
          context: context,
          addWidget: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomText(
                      text: AppLocalizations.of(context)!.contractpdf,
                      // text: getTranslated(context, 'myweeklyTask'),
                      color: Theme.of(context).colorScheme.textClrChange,
                      size: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    CustomText(
                      text:
                          AppLocalizations.of(context)!.leaveitblankifnochange,
                      // text: getTranslated(context, 'myweeklyTask'),
                      color: AppColors.greyColor,
                      size: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
          Container(
                  height: 40.h,
                  width: double.infinity,
                  // margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.greyColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        _buildFilePickerButton(isLightTheme),
                        SizedBox(width: 15.w),
                        Container(
                          color: AppColors.greyForgetColor,
                          height: 40.h,
                          width: 0.5.w,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                ValueListenableBuilder<File?>(
                  valueListenable: selectedFileNotifier,
                  builder: (context, file, _) {
                    if (file == null) return SizedBox(); // nothing selected

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.8),
                                Colors.red.shade200
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            //
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${(file.lengthSync() / 1024).toStringAsFixed(1)} KB',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.whiteColor),
                              ),
                              SizedBox(height: 4),
                              Text(fileName.value ?? "",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.whiteColor)),
                              SizedBox(height: 4),
                              GestureDetector(
                                onTap: () {
                                  selectedFileNotifier.value =
                                      null; // remove the file
                                },
                                child: Container(
                                  height: 20.h,
                                  width: 20.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(2.h),
                                    child: HeroIcon(
                                      HeroIcons.xMark,
                                      style: HeroIconStyle.solid,
                                      color: AppColors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                )
              ],
            ),
          )),
    );
  }


}
