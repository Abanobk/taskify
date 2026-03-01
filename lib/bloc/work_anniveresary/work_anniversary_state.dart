// import 'package:equatable/equatable.dart';
// import '../../data/model/work_anniversary/work_anni_model.dart';
//
// abstract class WorkAnniversaryState extends Equatable {
//   const WorkAnniversaryState();
//
//   @override
//   List<Object?> get props => [];
//
//   WorkAnniversaryState copyWith({
//     List<WorkAnniversaryModel>? workAnniversaries,
//     bool? hasReachedMax,
//     List<WorkAnniversaryModel>? clientAnniversaries,
//     List<int>? selectedUserIds,
//     List<String>? selectedUserNames,
//     List<int>? selectedClientIds,
//     List<String>? selectedClientNames,
//     int? daysValue,
//     bool? isLoading,
//     String? error,
//   });
// }
//
// class WorkAnniversaryInitial extends WorkAnniversaryState {
//   @override
//   WorkAnniversaryState copyWith({
//     List<WorkAnniversaryModel>? workAnniversaries,
//     bool? hasReachedMax,
//     List<WorkAnniversaryModel>? clientAnniversaries,
//     List<int>? selectedUserIds,
//     List<String>? selectedUserNames,
//     List<int>? selectedClientIds,
//     List<String>? selectedClientNames,
//     int? daysValue,
//     bool? isLoading,
//     String? error,
//   }) {
//     return this;
//   }
// }
//
// class WorkAnniversaryLoading extends WorkAnniversaryState {
//   @override
//   WorkAnniversaryState copyWith({
//     List<WorkAnniversaryModel>? workAnniversaries,
//     bool? hasReachedMax,
//     List<WorkAnniversaryModel>? clientAnniversaries,
//     List<int>? selectedUserIds,
//     List<String>? selectedUserNames,
//     List<int>? selectedClientIds,
//     List<String>? selectedClientNames,
//     int? daysValue,
//     bool? isLoading,
//     String? error,
//   }) {
//     return this;
//   }
// }
//
// class WorkAnniversaryError extends WorkAnniversaryState {
//   final String message;
//
//   const WorkAnniversaryError(this.message);
//
//   @override
//   List<Object> get props => [message];
//
//   @override
//   WorkAnniversaryState copyWith({
//     List<WorkAnniversaryModel>? workAnniversaries,
//     bool? hasReachedMax,
//     List<WorkAnniversaryModel>? clientAnniversaries,
//     List<int>? selectedUserIds,
//     List<String>? selectedUserNames,
//     List<int>? selectedClientIds,
//     List<String>? selectedClientNames,
//     int? daysValue,
//     bool? isLoading,
//     String? error,
//   }) {
//     return WorkAnniversaryError(error ?? message);
//   }
// }
//
// class WorkAnniversaryPaginated extends WorkAnniversaryState {
//   final List<WorkAnniversaryModel> workAnniversaries;
//   final bool hasReachedMax;
//   final List<WorkAnniversaryModel> clientAnniversaries;
//   final List<int> selectedUserIds;
//   final List<String> selectedUserNames;
//   final List<int> selectedClientIds;
//   final List<String> selectedClientNames;
//   final int daysValue;
//   final bool isLoading;
//   final String? error;
//
//   const WorkAnniversaryPaginated({
//     required this.workAnniversaries,
//     required this.hasReachedMax,
//     this.clientAnniversaries = const [],
//     this.selectedUserIds = const [],
//     this.selectedUserNames = const [],
//     this.selectedClientIds = const [],
//     this.selectedClientNames = const [],
//     this.daysValue = 30,
//     this.isLoading = false,
//     this.error,
//   });
//
//   @override
//   WorkAnniversaryState copyWith({
//     List<WorkAnniversaryModel>? workAnniversaries,
//     bool? hasReachedMax,
//     List<WorkAnniversaryModel>? clientAnniversaries,
//     List<int>? selectedUserIds,
//     List<String>? selectedUserNames,
//     List<int>? selectedClientIds,
//     List<String>? selectedClientNames,
//     int? daysValue,
//     bool? isLoading,
//     String? error,
//   }) {
//     return WorkAnniversaryPaginated(
//       workAnniversaries: workAnniversaries ?? this.workAnniversaries,
//       hasReachedMax: hasReachedMax ?? this.hasReachedMax,
//       clientAnniversaries: clientAnniversaries ?? this.clientAnniversaries,
//       selectedUserIds: selectedUserIds ?? this.selectedUserIds,
//       selectedUserNames: selectedUserNames ?? this.selectedUserNames,
//       selectedClientIds: selectedClientIds ?? this.selectedClientIds,
//       selectedClientNames: selectedClientNames ?? this.selectedClientNames,
//       daysValue: daysValue ?? this.daysValue,
//       isLoading: isLoading ?? this.isLoading,
//       error: error ?? this.error,
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//     workAnniversaries,
//     hasReachedMax,
//     clientAnniversaries,
//     selectedUserIds,
//     selectedUserNames,
//     selectedClientIds,
//     selectedClientNames,
//     daysValue,
//     isLoading,
//     error,
//   ];
// }
//
// class TodaysWorkAnniversaryLoading extends WorkAnniversaryState {
//   @override
//   WorkAnniversaryState copyWith({
//     List<WorkAnniversaryModel>? workAnniversaries,
//     bool? hasReachedMax,
//     List<WorkAnniversaryModel>? clientAnniversaries,
//     List<int>? selectedUserIds,
//     List<String>? selectedUserNames,
//     List<int>? selectedClientIds,
//     List<String>? selectedClientNames,
//     int? daysValue,
//     bool? isLoading,
//     String? error,
//   }) {
//     return TodaysWorkAnniversaryLoading();
//   }
// }
//
// class WorkAnniversarySuccess extends WorkAnniversaryState {
//   final List<WorkAnniversaryModel> workAnniversary;
//
//   const WorkAnniversarySuccess(this.workAnniversary);
//
//   @override
//   List<Object> get props => [workAnniversary];
//
//   @override
//   WorkAnniversaryState copyWith({
//     List<WorkAnniversaryModel>? workAnniversaries,
//     bool? hasReachedMax,
//     List<WorkAnniversaryModel>? clientAnniversaries,
//     List<int>? selectedUserIds,
//     List<String>? selectedUserNames,
//     List<int>? selectedClientIds,
//     List<String>? selectedClientNames,
//     int? daysValue,
//     bool? isLoading,
//     String? error,
//   }) {
//     return WorkAnniversarySuccess(
//       workAnniversaries ?? workAnniversary,
//     );
//   }
// }
//
// class AllWorkAnniversarySuccess extends WorkAnniversaryState {
//   final List<WorkAnniversaryModel> allWorkAnniversary;
//
//   const AllWorkAnniversarySuccess(this.allWorkAnniversary);
//
//   @override
//   List<Object> get props => [allWorkAnniversary];
//
//   @override
//   WorkAnniversaryState copyWith({
//     List<WorkAnniversaryModel>? workAnniversaries,
//     bool? hasReachedMax,
//     List<WorkAnniversaryModel>? clientAnniversaries,
//     List<int>? selectedUserIds,
//     List<String>? selectedUserNames,
//     List<int>? selectedClientIds,
//     List<String>? selectedClientNames,
//     int? daysValue,
//     bool? isLoading,
//     String? error,
//   }) {
//     return AllWorkAnniversarySuccess(
//       workAnniversaries ?? allWorkAnniversary,
//     );
//   }
// }
//
// class TodayWorkAnniversarySuccess extends WorkAnniversaryState {
//   final List<WorkAnniversaryModel> workAnniversary;
//   final bool hasReachedMax;
//
//   const TodayWorkAnniversarySuccess({
//     required this.workAnniversary,
//     required this.hasReachedMax,
//   });
//
//   @override
//   List<Object> get props => [workAnniversary, hasReachedMax];
//
//   @override
//   WorkAnniversaryState copyWith({
//     List<WorkAnniversaryModel>? workAnniversaries,
//     bool? hasReachedMax,
//     List<WorkAnniversaryModel>? clientAnniversaries,
//     List<int>? selectedUserIds,
//     List<String>? selectedUserNames,
//     List<int>? selectedClientIds,
//     List<String>? selectedClientNames,
//     int? daysValue,
//     bool? isLoading,
//     String? error,
//   }) {
//     return TodayWorkAnniversarySuccess(
//       workAnniversary: workAnniversaries ?? this.workAnniversary,
//       hasReachedMax: hasReachedMax ?? this.hasReachedMax,
//     );
//   }
// }
import 'package:equatable/equatable.dart';

import '../../data/model/work_anniversary/work_anni_model.dart';


abstract class WorkAnniversaryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WorkAnniversaryInitial extends WorkAnniversaryState {}

class WorkAnniversaryLoading extends WorkAnniversaryState {}
class TodaysWorkAnniversaryLoading extends WorkAnniversaryState {}

class WorkAnniversarySuccess extends WorkAnniversaryState {
  WorkAnniversarySuccess(this.workAnniversary,);

  final List<WorkAnniversaryModel> workAnniversary;

  @override
  List<Object> get props => [workAnniversary];
}
class AllWorkAnniversarySuccess extends WorkAnniversaryState {
  AllWorkAnniversarySuccess(this.allWorkAnniversary,);

  final List<WorkAnniversaryModel> allWorkAnniversary;

  @override
  List<Object> get props => [allWorkAnniversary];
}

class WorkAnniversaryError extends WorkAnniversaryState {
  final String errorMessage;

  WorkAnniversaryError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
class WorkAnniversaryPaginated extends WorkAnniversaryState {
  final List<WorkAnniversaryModel> workAnniversary;
  final bool hasReachedMax;
  final List<String> userSelectedname;
  final List<int> userSelectedId;
  final List<String> clientSelectedname;
  final List<int> clientSelectedId;

  WorkAnniversaryPaginated({
    required this.workAnniversary,
    required this.hasReachedMax,
    required this.userSelectedname,
    required this.userSelectedId,
    required this.clientSelectedname,
    required this.clientSelectedId,
  });

  @override
  List<Object> get props => [workAnniversary, hasReachedMax,   userSelectedname,
    userSelectedId,
    clientSelectedname,
    clientSelectedId,];
  WorkAnniversaryPaginated copyWith({
    List<WorkAnniversaryModel>? workAnniversary,
    bool? hasReachedMax,
    List<String>? userSelectedname,
    List<int>? userSelectedId,
    List<String>? clientSelectedname,
    List<int>? clientSelectedId,
  }) {
    return WorkAnniversaryPaginated(
      workAnniversary: workAnniversary ?? this.workAnniversary,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      userSelectedname: userSelectedname ?? this.userSelectedname,
      userSelectedId: userSelectedId ?? this.userSelectedId,
      clientSelectedname: clientSelectedname ?? this.clientSelectedname,
      clientSelectedId: clientSelectedId ?? this.clientSelectedId,
    );
  }
}
class TodayWorkAnniversarySuccess extends WorkAnniversaryState {
  final List<WorkAnniversaryModel> workAnniversary;
  final bool hasReachedMax;

  TodayWorkAnniversarySuccess({
    required this.workAnniversary,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [workAnniversary, hasReachedMax];
}