import 'package:equatable/equatable.dart';
import '../../data/model/Birthday/birthday_model.dart';

abstract class BirthdayState with EquatableMixin {
  const BirthdayState();

  @override
  List<Object?> get props => [];
}

class BirthdayInitial extends BirthdayState {
  @override
  List<Object?> get props => [];
}

class TodaysBirthdayLoading extends BirthdayState {
  @override
  List<Object?> get props => [];
}

class TodayBirthdaySuccess extends BirthdayState {
  final List<BirthdayModel> birthday;
  final bool hasReachedMax;
  final List<String> userSelectedname;
  final List<int> userSelectedId;
  final List<String> clientSelectedname;
  final List<int> clientSelectedId;

  TodayBirthdaySuccess({
    required this.birthday,
    required this.hasReachedMax,
    required this.userSelectedname,
    required this.userSelectedId,
    required this.clientSelectedname,
    required this.clientSelectedId,
  });

  @override
  List<Object?> get props => [
    birthday,
    hasReachedMax,
    userSelectedname,
    userSelectedId,
    clientSelectedname,
    clientSelectedId,
  ];

  TodayBirthdaySuccess copyWith({
    List<BirthdayModel>? birthday,
    bool? hasReachedMax,
    List<String>? userSelectedname,
    List<int>? userSelectedId,
    List<String>? clientSelectedname,
    List<int>? clientSelectedId,
  }) {
    return TodayBirthdaySuccess(
      birthday: birthday ?? this.birthday,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      userSelectedname: userSelectedname ?? this.userSelectedname,
      userSelectedId: userSelectedId ?? this.userSelectedId,
      clientSelectedname: clientSelectedname ?? this.clientSelectedname,
      clientSelectedId: clientSelectedId ?? this.clientSelectedId,
    );
  }
}

class BirthdayError extends BirthdayState {
  final String message;

  const BirthdayError(this.message);

  @override
  List<Object?> get props => [message];
}