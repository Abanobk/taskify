
import 'package:equatable/equatable.dart';

import '../../data/model/leads/leads_model.dart';

abstract class LeadEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LeadLists extends LeadEvent {

  // final int offset;
  // final int limit;

  LeadLists();
  @override
  List<Object> get props => [];
}
class LeadLoadMore extends LeadEvent {
  final String searchQuery;

  LeadLoadMore(this.searchQuery);
  @override
  List<Object> get props => [searchQuery];
}
class SelectedLead extends LeadEvent {
  final int selectedIndex;
  final String selectedTitle;

  SelectedLead(this.selectedIndex,this.selectedTitle);
  @override
  List<Object> get props => [selectedIndex,selectedTitle];
}
class SearchLead extends LeadEvent {
  final String searchQuery;


  SearchLead(this.searchQuery);
  @override
  List<Object> get props => [searchQuery];
}
class CreateLead extends LeadEvent {

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? countryCode;
  final String? countryIsoCode;
  final int? leadSourceId;
  final String? leadSource;
  final int? leadStageId;
  final String? leadStage;
  final int? assignedTo;
  final String? assignedUser;
  final String? jobTitle;
  final String? industry;
  final String? company;
  final String? website;
  final String? linkedin;
  final String? instagram;
  final String? facebook;
  final String? pinterest;
  final String? city;
  final String? state;
  final String? zip;
  final String? country;
  final String? createdAt;
  final String? updatedAt;


  CreateLead({

    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.countryCode,
    this.countryIsoCode,
    this.leadSourceId,
    this.leadSource,
    this.leadStageId,
    this.leadStage,
    this.assignedTo,
    this.assignedUser,
    this.jobTitle,
    this.industry,
    this.company,
    this.website,
    this.linkedin,
    this.instagram,
    this.facebook,
    this.pinterest,
    this.city,
    this.state,
    this.zip,
    this.country,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    phone,
    countryCode,
    countryIsoCode,
    leadSourceId,
    leadSource,
    leadStageId,
    leadStage,
    assignedTo,
    assignedUser,
    jobTitle,
    industry,
    company,
    website,
    linkedin,
    instagram,
    facebook,
    pinterest,
    city,
    state,
    zip,
    country,
    createdAt,
    updatedAt,
  ];
}
class CreateLeadFollow extends LeadEvent {

  final String? type;
  final String? status;
  final String? followupAt;
  final String? note;
  final int? assignedToId;
  final int? leadId;


  final AssignedUser? assignedTo;



  CreateLeadFollow({

    this.type,
    this.status,
    this.followupAt,
    this.note,

    this.assignedTo,
    this.leadId,
    this.assignedToId,

  });

  @override
  List<Object?> get props => [
 note,type,
    followupAt,
    status,
    assignedTo,
    assignedToId,
    leadId

  ];
}


class DeleteLead extends LeadEvent {
  final int LeadId;

  DeleteLead(this.LeadId );

  @override
  List<Object?> get props => [LeadId];
}
class DeleteLeadFollowUp extends LeadEvent {
  final int LeadId;

  DeleteLeadFollowUp(this.LeadId );

  @override
  List<Object?> get props => [LeadId];
}

class UpdateLead extends LeadEvent {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? countryCode;
  final String? countryIsoCode;
  final int? leadSourceId;
  final String? leadSource;
  final int? leadStageId;
  final String? leadStage;
  final int? assignedTo;
  final String? assignedUser;
  final String? jobTitle;
  final String? industry;
  final String? company;
  final String? website;
  final String? linkedin;
  final String? instagram;
  final String? facebook;
  final String? pinterest;
  final String? city;
  final String? state;
  final String? zip;
  final String? country;
  final String? createdAt;
  final String? updatedAt;

  UpdateLead({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.countryCode,
    this.countryIsoCode,
    this.leadSourceId,
    this.leadSource,
    this.leadStageId,
    this.leadStage,
    this.assignedTo,
    this.assignedUser,
    this.jobTitle,
    this.industry,
    this.company,
    this.website,
    this.linkedin,
    this.instagram,
    this.facebook,
    this.pinterest,
    this.city,
    this.state,
    this.zip,
    this.country,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,

    firstName,
    lastName,
    email,
    phone,
    countryCode,
    countryIsoCode,
    leadSourceId,
    leadSource,
    leadStageId,
    leadStage,
    assignedTo,
    assignedUser,
    jobTitle,
    industry,
    company,
    website,
    linkedin,
    instagram,
    facebook,
    pinterest,
    city,
    state,
    zip,
    country,
    createdAt,
    updatedAt,
  ];
}
class UpdateLeadFollowUp extends LeadEvent {
  final int id;
  final String? status;
  final String? followupAt;
  final String? type;
  final String? note;
  final AssignedUser? assignedTo;
  final int? assignedToId;


  UpdateLeadFollowUp({
    required this.id,
this.status,
    this.note,
    this.followupAt,
    this.type,
    this.assignedTo,
    this.assignedToId
  });

  @override
  List<Object?> get props => [
    id,
type,status,followupAt,note,assignedTo,assignedToId
  ];
}

