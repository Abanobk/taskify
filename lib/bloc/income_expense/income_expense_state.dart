import 'package:equatable/equatable.dart';

import '../../data/model/income_expense/income_expense_model.dart';

abstract class ChartState extends Equatable {
  @override
  List<Object> get props => [];
}

class ChartInitial extends ChartState {}

class ChartLoading extends ChartState {}

class ChartLoaded extends ChartState {
  final ChartDataModel chartData;
  ChartLoaded(this.chartData);

  @override
  List<Object> get props => [chartData];
}

class ChartError extends ChartState {
  final String message;
  ChartError(this.message);

  @override
  List<Object> get props => [message];
}