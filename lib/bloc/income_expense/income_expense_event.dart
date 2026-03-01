// Events
import 'package:equatable/equatable.dart';

abstract class ChartEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchChartData extends ChartEvent {


  final String startDate;
  final String endDate;

  FetchChartData({required this.endDate, required this.startDate});
}