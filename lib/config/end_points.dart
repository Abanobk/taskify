import 'constants.dart';
const String getUserFcmApi = '${baseUrl}user/fcm-token';


const String getUserLoginApi = '${baseUrl}users/login';
  const String getUserSignUpApi = '${baseUrl}users/signup';
const String getPasswordResetUpApi = '${baseUrl}password/reset-request';

const String getUser = '${baseUrl}users';
const String updateUserUrl ='${baseUrl}users/update';
const String createUserUrl ='${baseUrl}users/store';
const String deleteUserUrl ='${baseUrl}users/destroy';

const String createTaskUrl = '${baseUrl}tasks/store';
const String getAllTaskUrl = '${baseUrl}tasks';
const String updateTaskUrl = '${baseUrl}tasks/update';
const String deleteTask = '${baseUrl}tasks/destroy';


const String getDiscussionUrl ='${baseUrl}projects';
const String updateDiscussionUrl ='${baseUrl}projects/comments/update';
const String createDiscussionUrl ='${baseUrl}projects';
const String deleteDiscussionUrl ='${baseUrl}projects/comments/destroy';
const String deleteDiscussionAttachmentUrl ='${baseUrl}projects/comments/destroy-attachment';


const String getTaskDiscussionUrl ='${baseUrl}tasks';
const String updateTasksDiscussionUrl ='${baseUrl}tasks/comments/update';
const String createTasksDiscussionUrl ='${baseUrl}tasks';
const String deleteTasksDiscussionUrl ='${baseUrl}tasks/comments/destroy';
const String deleteTasksDiscussionAttachmentUrl ='${baseUrl}tasks/comments/destroy-attachment';



const String taskMediaUrl ='${baseUrl}tasks/get-media';
const String uploadTaskMediaUrl ='${baseUrl}tasks/upload-media';
const String deleteTaskMediaUrl ='${baseUrl}tasks/delete-media';

const String getStatus = '${baseUrl}statuses';
const String createStatusUrl ='${baseUrl}status/store';
const String deleteStatusUrl ='${baseUrl}status/destroy';
const String updateStatusUrl ='${baseUrl}status/update';


const String getPriorityUrl = '${baseUrl}priorities';
const String createPriorityUrl  = '${baseUrl}priority/store';
const String deletePriorityUrl  = '${baseUrl}priority/destroy';
const String updatePriorityUrl  = '${baseUrl}priority/update';

const String createNotesUrl = '${baseUrl}notes/store';
const String deleteNotesUrl = '${baseUrl}notes/destroy';
const String updateNotesUrl = '${baseUrl}notes/update';
const String listNotesUrl = '${baseUrl}notes';


const String listTododsUrl = '${baseUrl}todos';
const String createTododsUrl = '${baseUrl}todos/store';
const String deleteTododsUrl = '${baseUrl}todos/destroy';
const String updateTododsUrl = '${baseUrl}todos/update';

const String listLeaveRequestUrl ='${baseUrl}leave-requests';
const String createLeaveRequestUrl ='${baseUrl}leave-requests/store';
const String deleteLeaveRequestUrl ='${baseUrl}leave-requests/destroy';
const String updateLeaveRequestUrl ='${baseUrl}leave-requests/update';
const String memberOnLeaveRequestUrl ='${baseUrl}members-on-leave';

const String listMeetingUrl ='${baseUrl}meetings';
const String createMeetingUrl ='${baseUrl}meetings/store';
const String deleteMeetingUrl ='${baseUrl}meetings/destroy';
const String updateMeetingUrl ='${baseUrl}meetings/update';

const String projectUrl ='${baseUrl}projects';
const String updateProjectUrl ='${baseUrl}projects/update';
const String createProjectUrl ='${baseUrl}projects/store';
const String deleteProjectUrl ='${baseUrl}projects/destroy';
const String updatePinnedProjectUrl ='${baseUrl}projects';
const String projectMindMapUrl ='${baseUrl}';

const String projectMilestoneUrl ='${baseUrl}milestones';
const String updateProjectMilestoneUrl ='${baseUrl}milestones/update';
const String createProjectMilestoneUrl ='${baseUrl}milestones/store';
const String deleteProjectMilestoneUrl ='${baseUrl}milestones/destroy';


const String projectTimelineStatusUrl ='${baseUrl}projects/';
const String taskTimelineStatusUrl ='${baseUrl}tasks/';

const String projectMediaUrl ='${baseUrl}projects/get-media';
const String uploadProjectMediaUrl ='${baseUrl}projects/upload-media';
const String deleteProjectMediaUrl ='${baseUrl}projects/delete-media';

const String getWorkSpaceUrl ='${baseUrl}workspaces';
const String createWorkSpaceUrl ='${baseUrl}workspaces/store';
const String removeWorkSpaceUrl ='${baseUrl}workspaces/destroy';
const String updaetWorkSpaceUrl ='${baseUrl}workspaces/update';
const String removeMeWorkSpaceUrl ='${baseUrl}remove-participant';



const String getNotificationUrl ='${baseUrl}notifications';
const String deleteNotificationUrl ='${baseUrl}notifications/destroy';
const String incomeVsExpenseUrl ='${baseUrl}reports/income-vs-expense-report-data';

const String markAsReadNotificationUrl ='${baseUrl}notifications/mark-as-read';

const String getRoleUrl ='${baseUrl}roles';
const String getRoleUpdateUrl ='${baseUrl}roles/update';
const String getSpecificRolePermissionsUrl ='${baseUrl}roles/get';
const String getAllPermissionsListUrl ='${baseUrl}permissions-list';
const String getDeleteRoleUrl ='${baseUrl}roles/destroy';
const String createRoleUrl ='${baseUrl}roles/store';

const String getTagUrl ='${baseUrl}tags';
const String updateTagUrl ='${baseUrl}tags/update';
const String createTagUrl ='${baseUrl}tags/store';
const String deleteTagUrl ='${baseUrl}tags/destroy';

const String getCustomFieldUrl ='${baseUrl}custom-fields/list';
const String updateCustomFieldUrl ='${baseUrl}custom-fields/update';
const String createCustomFieldUrl ='${baseUrl}custom-fields';
const String deleteCustomFieldUrl ='${baseUrl}custom-fields/destroy';

const String getLeadUrl ='${baseUrl}leads/list';
const String updateLeadUrl ='${baseUrl}leads/update';
const String createLeadUrl ='${baseUrl}leads/store';
const String deleteLeadUrl ='${baseUrl}leads/destroy';
const String convertLeadToClientUrl ='${baseUrl}leads';

const String getLeadStageUrl ='${baseUrl}lead-stages/list';
const String updateLeadStageUrl ='${baseUrl}lead-stages/update';
const String createLeadStageUrl ='${baseUrl}lead-stages/store';
const String deleteLeadStageUrl ='${baseUrl}lead-stages/destroy';

const String createFollowUpLeadUrl ='${baseUrl}leads/follow-up/store';
const String deleteFollowUpLeadUrl ='${baseUrl}leads/follow-up/destroy';
const String updateFollowUpLeadUrl ='${baseUrl}leads/follow-up/update';



const String getLeadSourceUrl ='${baseUrl}lead-sources/list';
const String updateLeadSourceUrl ='${baseUrl}lead-sources/update';
const String createLeadSourceUrl ='${baseUrl}lead-sources/store';
const String deleteLeadSourceUrl ='${baseUrl}lead-sources/destroy';



const String getClientUrl ='${baseUrl}clients';
const String updateClientUrl ='${baseUrl}clients/update';
const String createClientUrl ='${baseUrl}clients/store';
const String deleteClientUrl ='${baseUrl}clients/destroy';

const String getCandidateUrl ='${baseUrl}candidate/list';
const String getAttachmentCandidateUrl ='${baseUrl}candidate/';
const String getCandidateInteviewUrl ='${baseUrl}candidate';
const String getInterviewCandidateUrl ='${baseUrl}candidate/';
const String updateCandidateUrl ='${baseUrl}candidate/update';
const String createCandidateUrl ='${baseUrl}candidate/store';
const String deleteCandidateUrl ='${baseUrl}candidate/destroy';
const String deleteCandidateAttachmentUrl ='${baseUrl}candidate/candidate-media/destroy';


const String getCandidateStatusUrl ='${baseUrl}candidate_status/list';
const String updateCandidateStatusUrl ='${baseUrl}candidate_status/update';
const String createCandidateStatusUrl ='${baseUrl}candidate_status/store';
const String deleteCandidateStatusUrl ='${baseUrl}candidate_status/destroy';


const String getInterviewsUrl ='${baseUrl}interviews/list';
const String updateInterviewsUrl ='${baseUrl}interviews/update';
const String createInterviewsUrl ='${baseUrl}interviews/store';
const String deleteInterviewsUrl ='${baseUrl}interviews/destroy';

const String getStatisticsUrl ='${baseUrl}dashboard/statistics';

const String getBirthdayUrl ='${baseUrl}upcoming-birthdays';
const String getWorkAnniUrl ='${baseUrl}upcoming-work-anniversaries';

const String listActivityUrl ='${baseUrl}activity-log';
const String deleteActivityUrl ='${baseUrl}activity-log/destroy';


const String updateProfileUrl ='${baseUrl}users';
const String getUserDetailUrl ='${baseUrl}user';
const String updateProfilDetailsUrl ='${baseUrl}users';


const String expenseUrl ='${baseUrl}expenses';
const String createExpenseUrl ='${baseUrl}expenses/store';
const String updateExpenseUrl ='${baseUrl}expenses/update';
const String deleteExpenseUrl ='${baseUrl}expenses/destroy';

const String allowanceUrl ='${baseUrl}allowances/list';
const String createAllowanceUrl ='${baseUrl}allowances/store';
const String updateAllowanceUrl ='${baseUrl}allowances/update';
const String deleteAllowanceUrl ='${baseUrl}allowances/destroy';

const String deductionUrl ='${baseUrl}deductions/list';
const String createDeductionUrl ='${baseUrl}deductions/store';
const String updateDeductionUrl ='${baseUrl}deductions/update';
const String deleteDeductionUrl ='${baseUrl}deductions/destroy';

const String payslipUrl ='${baseUrl}payslips/list';
const String createPayslipUrl ='${baseUrl}payslips/store';
const String updatePayslipUrl ='${baseUrl}payslips/update';
const String deletePayslipUrl ='${baseUrl}payslips/destroy';


const String expenseTypeListUrl ='${baseUrl}expenses/expense-types/list';
const String createExpenseTypeUrl ='${baseUrl}expenses/expense-types/store';
const String destroyExpenseTypeUrl ='${baseUrl}expenses/expense-types/destroy';
const String updateExpenseTypeUrl ='${baseUrl}expenses/expense-types/update';

const String EstimatesInvoicesUrl ='${baseUrl}estimates-invoices';
const String createEstimatesInvoicesUrl ='${baseUrl}estimates-invoices/store';
const String updateEstimatesInvoicesUrl ='${baseUrl}estimates-invoices/update';
const String deleteEstimatesInvoicesUrl ='${baseUrl}estimates-invoices/destroy';



const String itemsUrl ='${baseUrl}items';
const String createItemsUrl ='${baseUrl}items/store';
const String updateItemsUrl ='${baseUrl}items/update';
const String deleteItemsUrl ='${baseUrl}items/destroy';

const String unitUrl ='${baseUrl}units';
const String createUnitUrl ='${baseUrl}units/store';
const String updateUnitUrl ='${baseUrl}units/update';
const String deleteUnitUrl ='${baseUrl}units/destroy';

const String taxesUrl ='${baseUrl}taxes';
const String createTaxesUrl ='${baseUrl}taxes/store';
const String updateTaxesUrl ='${baseUrl}taxes/update';
const String deleteTaxesUrl ='${baseUrl}taxes/destroy';

const String paymentMethodsUrl ='${baseUrl}payment-methods';
const String createPaymentMethodsUrl ='${baseUrl}payment-methods/store';
const String updatePaymentMethodsUrl ='${baseUrl}payment-methods/update';
const String deletePaymentMethodsUrl ='${baseUrl}payment-methods/destroy';

const String paymentUrl ='${baseUrl}payments';
const String createPaymentUrl ='${baseUrl}payments/store';
const String updatePaymentUrl ='${baseUrl}payments/update';
const String deletePaymentUrl ='${baseUrl}payments/destroy';

const String contractTypeUrl ='${baseUrl}contracts/contract-types-list';
const String createContractTypeUrl ='${baseUrl}contracts/store-contract-type';
const String updateContractTypeUrl ='${baseUrl}contracts_type/update-contract-type';
const String deleteContractTypeUrl ='${baseUrl}contracts/delete-contract-type';


const String contractUrl ='${baseUrl}contracts/list';
const String createContractUrl ='${baseUrl}contracts/store';
const String updateContractUrl ='${baseUrl}contracts/update';
const String deleteContractUrl ='${baseUrl}contracts/destroy';
const String signContractUrl ='${baseUrl}contracts/create-sign?isApi=1';
const String deleteSignContractUrl ='${baseUrl}contracts/delete-sign';



const String assignedPermissionsurl ='${baseUrl}permissions';
const String settingsurl ='${baseUrl}settings/general_settings';
const String settingUpdateurl ='${baseUrl}settings/update';
const String companyInfourl ='${baseUrl}settings/company_information';
const String emailComapnyurl ='${baseUrl}settings/email_settings';
const String smsGatewayurl ='${baseUrl}settings/sms_gateway_settings';
const String whatsappurl ='${baseUrl}settings/whatsapp_settings';
const String slackappurl ='${baseUrl}settings/slack_settings';
const String mediaStorageUrl ='${baseUrl}settings/media_storage_settings';
const String privacyPolicyUrl ='${baseUrl}settings/privacy_policy';
const String aboutUsUrl ='${baseUrl}settings/about_us';
const String termsAndConditionUrl ='${baseUrl}settings/terms_conditions';
const String accountdeletionsurl ='${baseUrl}account/destroy';
const String forgetPasswordUrl = '${baseUrl}forgot-password';

