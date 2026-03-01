import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskCreated extends TaskEvent {
  final String title;
  final int statusId;
  final int priorityId;
  final int canClientDiscuss;
  final String billingType;
  final int completionPercentage;
  final String enableReminder;
  final String enableRecurringTask;
  final String startDate;
  final String dueDate;
  final int parentId;
  final bool isSubtask;
  final String desc;
  final int project;
  final String note;
  final List<int> userId;
  final String? frequencyType;
  final String? recurringFrequencyType;

  // Recurrence Fields
  final int? dayOfWeek;
  final int? dayOfMonth;
  final String? timeOfDay;
  final int? recurrenceDayOfWeek;
  final int? recurrenceDayOfMonth;
  final int? recurrenceMonthOfYear;
  final String? recurrenceStartsFrom;
  final int? recurrenceOccurrences;
  final Map<String, dynamic> customFieldValues; // Declare the property


  TaskCreated({
    required this.title,
    required this.statusId,
    required this.canClientDiscuss,
    required this.enableRecurringTask,
    required this.enableReminder,
    required this.billingType,
    required this.completionPercentage,
    required this.priorityId,
    required this.startDate,
    required this.isSubtask,
    required this.parentId,
    required this.dueDate,
    required this.desc,
    required this.project,
    required this.userId,
    required this.customFieldValues,
    required this.note,

    // Recurrence Fields
     this.dayOfWeek,
     this.frequencyType,
     this.recurringFrequencyType,
     this.dayOfMonth,
     this.timeOfDay,
     this.recurrenceDayOfWeek,
     this.recurrenceDayOfMonth,
     this.recurrenceMonthOfYear,
     this.recurrenceStartsFrom,
     this.recurrenceOccurrences,

  });

  @override
  List<Object> get props => [
    title,
    statusId,
    priorityId,
    startDate,
    dueDate,
    completionPercentage,
    canClientDiscuss,
    parentId,
    isSubtask,
    customFieldValues,
    billingType,
    enableReminder,
    enableRecurringTask,
    desc,
    project,
    note,
    userId,
  ];
}


class TaskDashBoardFavList extends TaskEvent {
  final int? isFav;
  TaskDashBoardFavList({this.isFav});

  @override
  List<Object?> get props => [isFav];
}

class AllTaskListOnTask extends TaskEvent {
  final List<int>? userId;
  final List<int>? clientId;
  final List<int>? priorityId;
  final List<int>? statusId;
  final List<int>? projectId;
  final String? fromDate;
  final String? toDate;
  final int? id;
  final bool isSubtask;
  AllTaskListOnTask(
      {this.id,
      this.projectId,
      this.clientId,
      this.userId,
      this.statusId,
      this.priorityId,
      this.isSubtask = false,
      this.fromDate,
      this.toDate});

  @override
  List<Object?> get props =>
      [id, projectId, clientId, userId, statusId, priorityId, fromDate, toDate];
}

class AllTaskList extends TaskEvent {
  AllTaskList();

  @override
  List<Object> get props => [];
}

class TodaysTaskList extends TaskEvent {
  final String fromDate;
  final String toDate;
  TodaysTaskList(this.fromDate, this.toDate);

  @override
  List<Object> get props => [fromDate, toDate];
}

class UpdateTask extends TaskEvent {
  final int id;
  final String title;
  final int statusId;
  final int parentId;
  final bool isSubtask;
  final int priorityId;
  final String startDate;
  final String dueDate;
  final String desc;
  final String note;
  final List<int> userId;
  final int canClientDiscuss;
  final String billingType;
  final int completionPercentage;
  final String enableReminder;
  final String enableRecurringTask;

  // Recurrence Fields
  final int? dayOfWeek;
  final int? dayOfMonth;
  final String? timeOfDay;
  final int? recurrenceDayOfWeek;
  final int? recurrenceDayOfMonth;
  final int? recurrenceMonthOfYear;
  final String? recurrenceStartsFrom;
  final String? frequencyType;
  final String? recurringFrequencyType;
  final int? recurrenceOccurrences;
  final Map<String, dynamic> customFieldValues; // Declare the property


  UpdateTask({
    required this.id,
    required this.title,
    required this.statusId,
    required this.parentId,
    required this.isSubtask,
    required this.canClientDiscuss,
    required this.priorityId,
    required this.startDate,
    required this.enableRecurringTask,
    required this.enableReminder,
    required this.billingType,
    required this.completionPercentage,
    required this.customFieldValues,
    required this.dueDate,
    required this.desc,
    required this.userId,
    required this.note,
    this.dayOfWeek,
    this.recurringFrequencyType,
    this.frequencyType,
     this.dayOfMonth,
     this.timeOfDay,
     this.recurrenceDayOfWeek,
     this.recurrenceDayOfMonth,
     this.recurrenceMonthOfYear,
     this.recurrenceStartsFrom,
     this.recurrenceOccurrences,
  });

  @override
  List<Object> get props => [
    id,
    title,
    statusId,
    priorityId,
    isSubtask,
    parentId,
    startDate,
    customFieldValues,
    dueDate,
    desc,
    note,
    userId,
    completionPercentage,
    canClientDiscuss,
    billingType,
    enableReminder,
    enableRecurringTask,
  ];
}


class DeleteTask extends TaskEvent {
  final int taskId;

  DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class SearchTasks extends TaskEvent {
  final String searchQuery;
  final int? isFav;
  final bool? isSubtask;

  SearchTasks(this.searchQuery, {this.isFav, this.isSubtask});

  @override
  List<Object?> get props => [searchQuery, isFav];
}

class LoadMore extends TaskEvent {
  final List<int>? userId;
  final List<int>? clientId;
  final List<int>? priorityId;
  final List<int>? statusId;
  final List<int>? projectId;
  final String? fromDate;
  final String? toDate;
  final String? searchQuery;
  final int? id;
  final int? isFav;
  LoadMore(
      {this.id,
      this.projectId,
      this.clientId,
      this.userId,
      this.statusId,
      this.priorityId,
      this.fromDate,
      this.toDate,
      this.searchQuery,
      this.isFav});

  @override
  List<Object?> get props => [
        id,
        projectId,
        searchQuery,
        clientId,
        userId,
        statusId,
        priorityId,
        fromDate,
        toDate
      ];
}

class LoadMoreToday extends TaskEvent {
  final String fromDate;
  final String toDate;
  LoadMoreToday(this.toDate, this.fromDate);

  @override
  List<Object?> get props => [];
}
