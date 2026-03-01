class CreateUpdateModel {
  int? id;
  String? reason;
  String? fromDate;
  String? toDate;
  String? fromTime;
  String? toTime;
  String? status;
  String? leaveVisibleToAll;
  List<int>? visibleToIds;
  String? partialLeave;

  CreateUpdateModel({
    this.id,
    this.reason,
    this.fromDate,
    this.toDate,
    this.fromTime,
    this.toTime,
    this.status,
    this.leaveVisibleToAll,
    this.visibleToIds,
    this.partialLeave,
  });

  CreateUpdateModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    reason = json['reason'];
    fromDate = json['from_date'];
    toDate = json['to_date'];
    fromTime = json['from_time'];
    toTime = json['to_time'];
    status = json['status'];
    leaveVisibleToAll = json['leaveVisibleToAll'];
    visibleToIds = json['visible_to_ids'].cast<int>();
    partialLeave = json['partialLeave'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['reason'] = reason;
    data['from_date'] = fromDate;
    data['to_date'] = toDate;
    data['from_time'] = fromTime;
    data['to_time'] = toTime;
    data['status'] = status;
    data['leaveVisibleToAll'] = leaveVisibleToAll;
    data['visible_to_ids'] = visibleToIds;
    data['partialLeave'] = partialLeave;
    return data;
  }

  CreateUpdateModel copyWith({
    int? id,
    String? reason,
    String? fromDate,
    String? toDate,
    String? fromTime,
    String? toTime,
    String? status,
    String? leaveVisibleToAll,
    List<int>? visibleToIds,
    String? partialLeave,
  }) {
    return CreateUpdateModel(
      id: id ?? this.id,
      reason: reason ?? this.reason,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      fromTime: fromTime ?? this.fromTime,
      toTime: toTime ?? this.toTime,
      status: status ?? this.status,
      leaveVisibleToAll: leaveVisibleToAll ?? this.leaveVisibleToAll,
      visibleToIds: visibleToIds ?? this.visibleToIds,
      partialLeave: partialLeave ?? this.partialLeave,
    );
  }
}
