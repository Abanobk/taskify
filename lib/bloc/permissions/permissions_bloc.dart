import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/permissions/permissions_event.dart';
import 'package:taskify/data/repositories/permissions/permission_repo.dart';
import '../../api_helper/api.dart';
import 'permissions_state.dart';


class PermissionsBloc extends Bloc<PermissionsEvent, PermissionsState> {
  
   bool? iscreateProject;
   bool? isManageProject;
   bool? iseditProject;
   bool? isdeleteProject;

   bool? iscreatetask;
   bool? isManageTask;
   bool? iseditTask;
   bool? isdeleteTask;

   bool? iscreateClient;
   String? isGuard;
   bool? isLeaveEditor;
   String? roleIS;
   bool? hasAllAccess;
   bool? isManageClient;
   bool? iseditClient;
   bool? isdeleteClient;

   bool? iscreatePriority;
   bool? isManagePriority;
   bool? iseditPriority;
   bool? isdeletePriority;

   bool? iscreateMeeting;
   bool? isManageMeeting;
   bool? iseditMeeting;
   bool? isdeleteMeeting;

   bool? iscreateStatus;
   bool? isManageStatus;
   bool? iseditStatus;
   bool? isdeleteStatus;

   bool? iscreateTags;
   bool? isManageTags;
   bool? iseditTags;
   bool? isdeleteTags;
   int? userId;

   bool? iscreateUser;
   bool? isManageUser;
   bool? iseditUser;
   bool? isdeleteUser;

   bool? iscreateWorkspace;
   bool? iscreateExpenses;
   bool? isManageWorkspace;
   bool? isManageExpenses;
   bool? iseditWorkspace;
   bool? iseditExpenses;
   bool? isdeleteWorkspace;
   bool? isdeleteExpenses;

   bool? isManageActivityLog;

   bool? isdeleteActivityLog;
bool? isManageSystenNotification;
bool? isDeleteSystenNotification;
   bool? isManageSystemNotification;
   bool? isdeleteSystemNotification;

   bool? iscreateContract;
   bool? isManageContract;
   bool? iseditContract;
   bool? isdeleteContract;

   bool? iscreateContractType;
   bool? isManageContractType;
   bool? iseditContractType;
   bool? isdeleteContractType;

   bool? iscreateTimesheet;
   bool? isManageTimesheet;
   bool? isdeleteTimesheet;

   bool? iscreateMedia;
   bool? isManageMedia;
   bool? isdeleteMedia;

   bool? iscreatePayslip;
   bool? isManagePayslip;
   bool? iseditPayslip;
   bool? isdeletePayslip;

   bool? iscreateAllowance;
   bool? isManageAllowance;
   bool? iseditAllowance;
   bool? isdeleteAllowance;

   bool? iscreateDeduction;
   bool? isManageDeduction;
   bool? iseditDeduction;
   bool? isdeleteDeduction;

   bool? iscreatePaymentMethod;
   bool? isManagePaymentMethod;
   bool? iseditPaymentMethod;
   bool? isdeletePaymentMethod;

   bool? iscreateEstimateInvoice;
   bool? isManageEstimateInvoice;
   bool? iseditEstimateInvoice;
   bool? isdeleteEstimateInvoice;

   bool? iscreatePayment;
   bool? isManagePayment;
   bool? iseditPayment;
   bool? isdeletePayment;

   bool? iscreateTax;
   bool? isManageTax;
   bool? iseditTax;
   bool? isdeleteTax;

   bool? iscreateUnit;
   bool? isManageUnit;
   bool? iseditUnit;
   bool? isdeleteUnit;

   bool? iscreateItem;
   bool? isManageItem;
   bool? iseditItem;
   bool? isdeleteItem;

   bool? iscreateExpenseType;
   bool? isManageExpenseType;
   bool? iseditExpenseType;
   bool? isdeleteExpenseType;

   bool? iscreateMilestone;
   bool? isManageMilestone;
   bool? iseditMilestone;
   bool? isdeleteMilestone;
   bool? isCreateLeads;
   bool? isManageLeads;
   bool? isEditLeads;
   bool? isDeleteLeads;

   bool? isSendEmail;

   bool? isCreateEmailTemplate;
   bool? isManageEmailTemplate;
   bool? isDeleteEmailTemplate;

   bool? isCreateCandidate;
   bool? isManageCandidate;
   bool? isEditCandidate;
   bool? isDeleteCandidate;

   bool? isCreateCandidateStatus;
   bool? isManageCandidateStatus;
   bool? isEditCandidateStatus;
   bool? isDeleteCandidateStatus;

   bool? isCreateInterview;
   bool? isManageInterview;
   bool? isEditInterview;
   bool? isDeleteInterview;

   bool? isManageSystemNotifications;
   bool? isDeleteSystemNotifications;

   PermissionsBloc() : super(PermissionsInitial()) {

    on<GetPermissions>(_getPermissions);

  }

  Future<void> _getPermissions(GetPermissions event, Emitter<PermissionsState> emit) async {
    try {

      Map<String,dynamic> result = await PermissionRepo().getPermissions(token: true, );

      var permission= result['data']['permissions'];

      isManageProject = permission['manage_projects'];
      isManageActivityLog = permission['manage_activity_log'];
      isdeleteActivityLog = permission['delete_activity_log'];
      iscreateClient = permission['create_clients'];
      isManageClient = permission['manage_clients'];
      iseditClient = permission['edit_clients'];
      isdeleteClient = permission['delete_clients'];
      iscreateMeeting = permission['create_meetings'];
      isManageMeeting = permission['manage_meetings'];
      iseditMeeting = permission['edit_meetings'];
      isdeleteMeeting = permission['delete_meetings'];
      iscreatePriority = permission['create_priorities'];
      isManagePriority = permission['manage_priorities'];
      iseditPriority = permission['edit_priorities'];
      isdeletePriority = permission['delete_priorities'];
      iscreateProject = permission['create_projects'];
      iseditProject = permission['edit_projects'];
      isdeleteProject = permission['delete_projects'];
      iscreateStatus = permission['create_statuses'];
      isManageStatus= permission['manage_statuses'];
      iseditStatus = permission['edit_statuses'];
      isdeleteStatus = permission['delete_statuses'];
      isManageSystemNotification = permission['manage_system_notifications'];
      isdeleteSystemNotification = permission['delete_system_notifications'];
      iscreateTags = permission['create_tags'];
      isManageTags = permission['manage_tags'];
      iscreateTags = permission['create_tags'];
      iseditTags = permission['edit_tags'];
      isdeleteTags = permission['delete_tags'];
      iscreatetask= permission['create_tasks'];
      isManageTask = permission['manage_tasks'];
      iseditTask = permission['edit_tasks'];
      isdeleteTask = permission['delete_tasks'];
      iscreateUser = permission['create_users'];
      isManageUser = permission['manage_users'];
      iseditUser = permission['edit_users'];
      isdeleteUser = permission['delete_users'];
      iscreateWorkspace = permission['create_workspaces'];
      isManageWorkspace = permission['manage_workspaces'];
      iseditWorkspace = permission['edit_workspaces'];
      isdeleteWorkspace = permission['delete_workspaces'];
      iseditExpenses= permission['edit_expenses'];
      isManageExpenses = permission['manage_expenses'];
      iscreateExpenses = permission['create_expenses'];
      isdeleteExpenses = permission['delete_expenses'];

      iscreateContract = permission['create_contracts'];
      isManageContract = permission['manage_contracts'];
      iseditContract = permission['edit_contracts'];
      isdeleteContract = permission['delete_contracts'];

      iscreateContractType = permission['create_contract_types'];
      isManageContractType = permission['manage_contract_types'];
      iseditContractType = permission['edit_contract_types'];
      isdeleteContractType = permission['delete_contract_types'];

      iscreateTimesheet = permission['create_timesheet'];
      isManageTimesheet = permission['manage_timesheet'];
      isdeleteTimesheet = permission['delete_timesheet'];

      iscreateMedia = permission['create_media'];
      isManageMedia = permission['manage_media'];
      isdeleteMedia = permission['delete_media'];

      iscreatePayslip = permission['create_payslips'];
      isManagePayslip = permission['manage_payslips'];
      iseditPayslip = permission['edit_payslips'];
      isdeletePayslip = permission['delete_payslips'];

      iscreateAllowance = permission['create_allowances'];
      isManageAllowance = permission['manage_allowances'];
      iseditAllowance = permission['edit_allowances'];
      isdeleteAllowance = permission['delete_allowances'];

      iscreateDeduction = permission['create_deductions'];
      isManageDeduction = permission['manage_deductions'];
      iseditDeduction = permission['edit_deductions'];
      isdeleteDeduction = permission['delete_deductions'];

      iscreatePaymentMethod = permission['create_payment_methods'];
      isManagePaymentMethod = permission['manage_payment_methods'];
      iseditPaymentMethod = permission['edit_payment_methods'];
      isdeletePaymentMethod = permission['delete_payment_methods'];

      iscreateEstimateInvoice = permission['create_estimates_invoices'];
      isManageEstimateInvoice = permission['manage_estimates_invoices'];
      iseditEstimateInvoice = permission['edit_estimates_invoices'];
      isdeleteEstimateInvoice = permission['delete_estimates_invoices'];

      iscreatePayment = permission['create_payments'];
      isManagePayment = permission['manage_payments'];
      iseditPayment = permission['edit_payments'];
      isdeletePayment = permission['delete_payments'];

      iscreateTax = permission['create_taxes'];
      isManageTax = permission['manage_taxes'];
      iseditTax = permission['edit_taxes'];
      isdeleteTax = permission['delete_taxes'];

      iscreateUnit = permission['create_units'];
      isManageUnit = permission['manage_units'];
      iseditUnit = permission['edit_units'];
      isdeleteUnit = permission['delete_units'];

      iscreateItem = permission['create_items'];
      isManageItem = permission['manage_items'];
      iseditItem = permission['edit_items'];
      isdeleteItem = permission['delete_items'];

      iscreateExpenseType = permission['create_expense_types'];
      isManageExpenseType = permission['manage_expense_types'];
      iseditExpenseType = permission['edit_expense_types'];
      isdeleteExpenseType = permission['delete_expense_types'];

      iscreateMilestone = permission['create_milestones'];
      isManageMilestone = permission['manage_milestones'];
      iseditMilestone = permission['edit_milestones'];
      isdeleteMilestone = permission['delete_milestones'];

       isCreateLeads = permission['create_leads'] ?? false;
       isManageLeads = permission['manage_leads'] ?? false;
       isEditLeads = permission['edit_leads'] ?? false;
       isDeleteLeads = permission['delete_leads'] ?? false;

       isSendEmail = permission['send_email'] ?? false;

       isCreateEmailTemplate = permission['create_email_template'] ?? false;
       isManageEmailTemplate = permission['manage_email_template'] ?? false;
       isDeleteEmailTemplate = permission['delete_email_template'] ?? false;

       isCreateCandidate = permission['create_candidate'] ?? false;
       isManageCandidate = permission['manage_candidate'] ?? false;
       isEditCandidate = permission['edit_candidate'] ?? false;
       isDeleteCandidate = permission['delete_candidate'] ?? false;

       isCreateCandidateStatus = permission['create_candidate_status'] ?? false;
       isManageCandidateStatus = permission['manage_candidate_status'] ?? false;
       isEditCandidateStatus = permission['edit_candidate_status'] ?? false;
       isDeleteCandidateStatus = permission['delete_candidate_status'] ?? false;

       isCreateInterview = permission['create_interview'] ?? false;
       isManageInterview = permission['manage_interview'] ?? false;
       isEditInterview = permission['edit_interview'] ?? false;
       isDeleteInterview = permission['delete_interview'] ?? false;

       isManageSystemNotifications = permission['manage_system_notifications'] ?? false;
       isDeleteSystemNotifications = permission['delete_system_notifications'] ?? false;
print("tyghnj $isCreateLeads");


      emit(PermissionsSuccess());
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((PermissionsError("Error: ${e.errorMessage}")));
    }
  }

}
