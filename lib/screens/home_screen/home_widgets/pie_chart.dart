
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:taskify/bloc/dashboard_stats/dash_board_stats_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/data/model/dashboard_stats/dashboard_stats_model.dart';
import '../../../bloc/dashboard_stats/dash_board_stats_bloc.dart';
import '../../../bloc/dashboard_stats/dash_board_stats_event.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/constants.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';

class DoughnutChart extends StatefulWidget {
  final String title;
  final String? type;
  final bool isReverse;
  final Function(bool) onChangeForProject;
  final Function(bool) onChangeForTask;

  DoughnutChart(
      {super.key,
        required this.title,
        required this.isReverse,
        this.type,
        required this.onChangeForProject,
        required this.onChangeForTask});
  @override
  _DoughnutChartState createState() => _DoughnutChartState();
}

class _DoughnutChartState extends State<DoughnutChart> {
  final ScrollController _scrollProjectController = ScrollController();
  final ScrollController _scrollTaskController = ScrollController();
  ValueNotifier<bool> isBarChart = ValueNotifier<bool>(true);
  ValueNotifier<bool> isBarChartForProject = ValueNotifier<bool>(true);
  ValueNotifier<bool> isBarChartForTask = ValueNotifier<bool>(true);

  ValueNotifier<bool> get selectedNotifier {
    if (widget.title == "project") {
      return isBarChartForProject;
    } else if (widget.title == "task") {
      return isBarChartForTask;
    } else {
      return isBarChart;
    }
  }

  @override
  void initState() {
    context.read<DashBoardStatsBloc>().add(StatsList());

    super.initState();
  }

  String getResponsiveRadius(double percentage) {
    return '${percentage}%';
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return BlocConsumer<DashBoardStatsBloc, DashBoardStatsState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        if (state is DashBoardStatsSuccess) {
          List<StatusWiseProjects> todoStats = [
            StatusWiseProjects(
                title: "Completed Todos",
                totalProjects:
                context.read<DashBoardStatsBloc>().completedTodos),
            StatusWiseProjects(
                title: "Pending Todos",
                totalProjects: context.read<DashBoardStatsBloc>().pendingTodos),
          ];

          return ValueListenableBuilder<bool>(
              valueListenable: selectedNotifier,
              builder: (context, value, child) {
                // ✅ Added builder function
                return Stack(children: [
                  Padding(
                    padding:
                    EdgeInsets.symmetric(vertical: 10.h, horizontal: 9.w),
                    child: Container(
                        padding: EdgeInsets.only(top: 10.h),
                        height: !widget.isReverse
                            ? isBarChartForTask.value || isBarChartForProject.value
                            ? 460.h
                            : 490.h
                            : 260.h,
                        // height: !widget.isReverse ? 450.h : 260.h,
                        decoration: BoxDecoration(
                            boxShadow: [
                              isLightTheme
                                  ? MyThemes.lightThemeShadow
                                  : MyThemes.darkThemeShadow,
                            ],
                            color: Theme.of(context).colorScheme.containerDark,
                            // border: Border.all(),
                            borderRadius: BorderRadius.circular(12)),
                        child: !widget.isReverse
                            ? selectedNotifier.value
                            ? Padding(
                          padding:
                          EdgeInsets.symmetric(vertical: 10.h),
                          child: Column(
                            children: [
                              CustomText(
                                text: widget.title,
                                color: Theme.of(context)
                                    .colorScheme
                                    .textClrChange,
                                size: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              SizedBox(height: 10),
                              widget.type == "project"
                                  ? Column(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  SizedBox(
                                    height: 170.h,
                                    // width: 180.w, // Adjust chart size
                                    child: SfCircularChart(
                                      series: <CircularSeries>[
                                        DoughnutSeries<
                                            StatusWiseProjects,
                                            String>(
                                          dataSource: state
                                              .statusWiseProject,
                                          xValueMapper:
                                              (StatusWiseProjects
                                          data,
                                              _) =>
                                          data.title,
                                          yValueMapper:
                                              (StatusWiseProjects
                                          data,
                                              _) =>
                                          data.totalProjects,
                                          pointColorMapper:
                                              (StatusWiseProjects
                                          data,
                                              _) =>
                                              hexToColor(data
                                                  .chartcolor!),
                                          explode: true,
                                          explodeIndex: 2,
                                          dataLabelSettings:
                                          DataLabelSettings(
                                            labelIntersectAction:
                                            LabelIntersectAction
                                                .shift,
                                            isVisible: true,
                                            showZeroValue:
                                            false,
                                            labelPosition:
                                            ChartDataLabelPosition
                                                .outside,
                                            connectorLineSettings:
                                            ConnectorLineSettings(
                                              width: 2,
                                              type:
                                              ConnectorType
                                                  .curve,
                                            ),
                                          ),
                                          innerRadius:
                                          getResponsiveRadius(
                                              60),
                                          radius:
                                          getResponsiveRadius(
                                              60),
                                          animationDuration:
                                          1000,
                                        ),
                                      ],
                                    ),
                                  ),

                                  state.statusWiseProject.isNotEmpty?   ConstrainedBox(
                                    constraints: BoxConstraints(
                                      // 🟢 Max height to cap it
                                      maxHeight: 200.h,
                                    ),
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      trackVisibility: true,
                                      thickness: 5,
                                      controller: _scrollProjectController,
                                      child: ListView.builder(
                                        controller: _scrollProjectController,

                                        shrinkWrap: true, // 🟢 Important to allow height to adapt
                                        itemCount: state.statusWiseProject.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          final projectStats = state.statusWiseProject[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 12,
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(int.parse(projectStats.chartcolor!)),
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Expanded(
                                                  child: Text(
                                                    projectStats.title!,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(fontSize: 14),
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  "${projectStats.totalProjects}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: 15),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ):SizedBox.shrink(),


                                  SizedBox(height: 20.h),

                                  // Space between chart and legend
                                ],
                              )
                                  : Column(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  SizedBox(
                                    height: 170.h,
                                    // width: 180.w, // Adjust chart size
                                    child: SfCircularChart(
                                      title:
                                      ChartTitle(text: ""),
                                      series: <CircularSeries>[
                                        DoughnutSeries<
                                            StatusWiseTasks,
                                            String>(
                                          dataSource: state
                                              .statusWiseTask,
                                          xValueMapper:
                                              (StatusWiseTasks
                                          data,
                                              _) =>
                                          data.title,
                                          yValueMapper:
                                              (StatusWiseTasks
                                          data,
                                              _) =>
                                          data.totalTasks,
                                          pointColorMapper:
                                              (StatusWiseTasks
                                          data,
                                              _) =>
                                              hexToColor(data
                                                  .chart_color!),
                                          explode: true,
                                          explodeIndex: 2,
                                          dataLabelSettings:
                                          DataLabelSettings(
                                            labelIntersectAction:
                                            LabelIntersectAction
                                                .shift,
                                            isVisible: true,
                                            showZeroValue:
                                            false,
                                            labelPosition:
                                            ChartDataLabelPosition
                                                .outside,
                                            connectorLineSettings:
                                            ConnectorLineSettings(
                                              width: 2,
                                              type:
                                              ConnectorType
                                                  .curve,
                                            ),
                                          ),
                                          innerRadius:
                                          getResponsiveRadius(
                                              60),
                                          radius:
                                          getResponsiveRadius(
                                              60),
                                          animationDuration:
                                          1000,
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(
                                      height: 200.h,
                                      width: 150.w,
                                      child: SizedBox(
                                          height: 200.h,
                                          width: 150.w,
                                          child: Scrollbar(
                                            thumbVisibility:
                                            true,
                                            trackVisibility:
                                            true,
                                            thickness: 5,
                                            controller:
                                            _scrollTaskController,
                                            child: ListView
                                                .builder(
                                              itemCount: state
                                                  .statusWiseTask
                                                  .length,
                                              itemBuilder:
                                                  (BuildContext
                                              context,
                                                  int index) {
                                                StatusWiseTasks
                                                taskStats =
                                                state.statusWiseTask[
                                                index];

                                                return Row(
                                                  mainAxisSize:
                                                  MainAxisSize
                                                      .min,
                                                  children: [
                                                    Container(
                                                      width: 12,
                                                      height:
                                                      12,
                                                      decoration: BoxDecoration(
                                                          shape: BoxShape
                                                              .circle,
                                                          color:
                                                          Color(int.parse(taskStats.chart_color!))),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                        5),
                                                    Expanded(
                                                      child:
                                                      Text(
                                                        taskStats
                                                            .title!,
                                                        // Only the category will truncate
                                                        maxLines:
                                                        1,
                                                        overflow:
                                                        TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            fontSize:
                                                            14),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                        5), // Adds spacing
                                                    Text(
                                                      "${taskStats.totalTasks}",
                                                      // This will always be fully visible
                                                      style: TextStyle(
                                                          fontSize:
                                                          14,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                        15),
                                                  ],
                                                );
                                              },
                                            ),
                                          ))),
                                  SizedBox(height: 20.h),

                                  // Space between chart and legend
                                ],
                              ),
                            ],
                          ),
                        )
                            : Padding(
                          padding:
                          EdgeInsets.symmetric(vertical: 10.h),
                          child: Column(
                            children: [
                              CustomText(
                                text: widget.title,
                                color: Theme.of(context)
                                    .colorScheme
                                    .textClrChange,
                                size: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              SizedBox(height: 10),
                              widget.type == "project"
                                  ? Column(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  SizedBox(
                                    height: 180.h,
                                    child: SfCartesianChart(
                                      plotAreaBorderWidth: 0,
                                      primaryXAxis:
                                      CategoryAxis(
                                        majorGridLines:
                                        MajorGridLines(
                                            width: 0),
                                      ), // X-Axis for categories
                                      primaryYAxis: NumericAxis(
                                        majorGridLines:
                                        MajorGridLines(
                                            width: 0),
                                      ), // Y-Axis for values
                                      series: <CartesianSeries<
                                          dynamic, dynamic>>[
                                        // ✅ Use CartesianSeries instead of ChartSeries
                                        ColumnSeries<
                                            StatusWiseProjects,
                                            String>(
                                          dataSource: state
                                              .statusWiseProject,
                                          xValueMapper:
                                              (StatusWiseProjects
                                          data,
                                              _) =>
                                          data.title,
                                          yValueMapper:
                                              (StatusWiseProjects
                                          data,
                                              _) =>
                                          data.totalProjects,
                                          borderRadius:
                                          BorderRadius.only(
                                            topLeft:
                                            Radius.circular(
                                                18), // Rounded top-left corner
                                            topRight:
                                            Radius.circular(
                                                18), // Rounded top-right corner
                                            bottomLeft:
                                            Radius.circular(
                                                0), // Sharp bottom-left corner
                                            bottomRight:
                                            Radius.circular(
                                                0), // Sharp bottom-right corner
                                          ),
                                          pointColorMapper:
                                              (StatusWiseProjects
                                          data,
                                              _) =>
                                              hexToColor(data
                                                  .chartcolor!),
                                          dataLabelSettings:
                                          DataLabelSettings(
                                            isVisible: true,
                                            labelPosition:
                                            ChartDataLabelPosition
                                                .outside,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      height: 200.h,
                                      width: 150.w,
                                      child:
                                      _buildProjectLegend(
                                          state)),
                                  SizedBox(
                                      height: 20
                                          .h), // Space between chart and legend
                                ],
                              )
                                  : Column(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  SizedBox(
                                    height: 200.h,
                                    child: SfCartesianChart(
                                      plotAreaBorderWidth: 0,
                                      primaryXAxis:
                                      CategoryAxis(
                                        majorGridLines:
                                        MajorGridLines(
                                            width: 0),
                                      ),
                                      primaryYAxis: NumericAxis(
                                        majorGridLines:
                                        MajorGridLines(
                                            width: 0),
                                      ),
                                      series: <CartesianSeries<
                                          dynamic, dynamic>>[
                                        // ✅ Fix: Use CartesianSeries
                                        ColumnSeries<
                                            StatusWiseTasks,
                                            String>(
                                          dataSource: state
                                              .statusWiseTask,
                                          xValueMapper:
                                              (StatusWiseTasks
                                          data,
                                              _) =>
                                          data.title,
                                          yValueMapper:
                                              (StatusWiseTasks
                                          data,
                                              _) =>
                                          data.totalTasks,
                                          borderRadius:
                                          BorderRadius.only(
                                            topLeft:
                                            Radius.circular(
                                                18), // Rounded top-left corner
                                            topRight:
                                            Radius.circular(
                                                18), // Rounded top-right corner
                                            bottomLeft:
                                            Radius.circular(
                                                0), // Sharp bottom-left corner
                                            bottomRight:
                                            Radius.circular(
                                                0), // Sharp bottom-right corner
                                          ),
                                          pointColorMapper:
                                              (StatusWiseTasks
                                          data,
                                              _) =>
                                              hexToColor(data
                                                  .chart_color!),
                                          dataLabelSettings:
                                          DataLabelSettings(
                                            isVisible: true,
                                            labelPosition:
                                            ChartDataLabelPosition
                                                .outside,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      height: 190.h,
                                      width: 150.w,
                                      child: _buildTaskLegend(
                                          state)),
                                  SizedBox(height: 20.h),
                                ],
                              ),
                            ],
                          ),
                        )
                            : Padding(
                          padding: EdgeInsets.only(top: 10.h),
                          child: Column(
                            children: [
                              CustomText(
                                text: widget.title,
                                color: Theme.of(context)
                                    .colorScheme
                                    .textClrChange,
                                size: 20.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              // SizedBox(height: 10),
                              isBarChart.value
                                  ? Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    SizedBox(
                                      height: 150.h,
                                      width: 150
                                          .w, // Adjust chart size
                                      child: SfCircularChart(
                                        margin: EdgeInsets.zero,
                                        // borderColor: AppColors.red,
                                        series: <CircularSeries>[
                                          DoughnutSeries<
                                              StatusWiseProjects,
                                              String>(
                                            dataSource: todoStats,
                                            // Use the new list here
                                            xValueMapper:
                                                (StatusWiseProjects
                                            data,
                                                _) =>
                                            data.title,
                                            yValueMapper:
                                                (StatusWiseProjects
                                            data,
                                                _) =>
                                            data.totalProjects,
                                            pointColorMapper:
                                                (StatusWiseProjects
                                            data,
                                                _) =>
                                            data.title ==
                                                "Completed Todos"
                                                ? Colors
                                                .green
                                                : Colors
                                                .red,
                                            explode: true,
                                            explodeIndex: 1,
                                            dataLabelSettings:
                                            DataLabelSettings(
                                              labelIntersectAction:
                                              LabelIntersectAction
                                                  .shift,
                                              isVisible: true,
                                              showZeroValue: false,
                                              labelPosition:
                                              ChartDataLabelPosition
                                                  .outside,
                                              connectorLineSettings:
                                              ConnectorLineSettings(
                                                width: 2,
                                                type: ConnectorType
                                                    .curve,
                                              ),
                                            ),
                                            innerRadius:
                                            getResponsiveRadius(
                                                60),
                                            radius:
                                            getResponsiveRadius(
                                                60),
                                            animationDuration: 1000,
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(
                                      height: 150.h,
                                      width: 130.w,
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .center,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                  10.w),
                                              child: Container(
                                                // color: Colors.red,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                    children: [
                                                      Container(
                                                        width: 10,
                                                        height: 10,
                                                        decoration:
                                                        BoxDecoration(
                                                          shape: BoxShape
                                                              .circle,
                                                          color: AppColors
                                                              .greenColor,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width: 5),
                                                      Expanded(
                                                        child: Text(
                                                          AppLocalizations.of(
                                                              context)!
                                                              .done,
                                                          // Only the category will truncate
                                                          maxLines: 1,
                                                          overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontSize:
                                                              14),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width:
                                                          5), // Adds spacing
                                                      Text(
                                                        "${context.read<DashBoardStatsBloc>().completedTodos}",
                                                        // This will always be fully visible
                                                        style: TextStyle(
                                                            fontSize:
                                                            14,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold),
                                                      ),
                                                    ],
                                                  ))),
                                          Padding(
                                            padding: EdgeInsets
                                                .symmetric(
                                                horizontal:
                                                10.w),
                                            child: Container(
                                              // color: Colors.red,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration:
                                                    BoxDecoration(
                                                      shape: BoxShape
                                                          .circle,
                                                      color:
                                                      AppColors
                                                          .red,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: 5),
                                                  Expanded(
                                                    child: Text(
                                                      AppLocalizations.of(
                                                          context)!
                                                          .pending,
                                                      // Only the category will truncate
                                                      maxLines: 1,
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      style: TextStyle(
                                                          fontSize:
                                                          14),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                      5), // Adds spacing
                                                  Text(
                                                    "${context.read<DashBoardStatsBloc>().pendingTodos}",
                                                    // This will always be fully visible
                                                    style: TextStyle(
                                                        fontSize:
                                                        14,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // SizedBox(height: 20.h),

                                    // Space between chart and legend
                                  ],
                                ),
                              )
                                  : Column(children: [
                                SizedBox(
                                  height: 200.h,
                                  // width: 250,
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 18.0),
                                    child: SfCartesianChart(
                                      plotAreaBorderWidth: 0,
                                      margin: EdgeInsets.zero,
                                      primaryXAxis: CategoryAxis(
                                        majorGridLines:
                                        MajorGridLines(
                                            width: 0),
                                      ),
                                      primaryYAxis: NumericAxis(
                                        majorGridLines: MajorGridLines(
                                            width:
                                            0), // Removes horizontal grid lines

                                        minimum: 0,
                                        interval:
                                        5, // Adjust interval based on data
                                      ),
                                      series: <CartesianSeries<
                                          dynamic, dynamic>>[
                                        // ✅ Explicitly using CartesianSeries
                                        ColumnSeries<
                                            StatusWiseProjects,
                                            String>(
                                          dataSource: todoStats,
                                          xValueMapper:
                                              (StatusWiseProjects
                                          data,
                                              _) =>
                                          data.title,
                                          yValueMapper:
                                              (StatusWiseProjects
                                          data,
                                              _) =>
                                          data.totalProjects,
                                          pointColorMapper:
                                              (StatusWiseProjects
                                          data,
                                              _) =>
                                          data.title ==
                                              "Completed Todos"
                                              ? Colors.green
                                              : Colors.red,
                                          borderRadius:
                                          BorderRadius.only(
                                            topLeft: Radius.circular(
                                                18), // Rounded top-left corner
                                            topRight: Radius.circular(
                                                18), // Rounded top-right corner
                                            bottomLeft: Radius.circular(
                                                0), // Sharp bottom-left corner
                                            bottomRight:
                                            Radius.circular(
                                                0), // Sharp bottom-right corner
                                          ),
                                          dataLabelSettings:
                                          DataLabelSettings(
                                            isVisible: true,
                                            labelPosition:
                                            ChartDataLabelPosition
                                                .outside,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                            ],
                          ),
                        )),
                  ),
                  Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 40.w,
                        height: 30.h,
                        decoration: BoxDecoration(
                          boxShadow: [
                            isLightTheme
                                ? MyThemes.lightThemeShadow
                                : MyThemes.darkThemeShadow,
                          ],
                          color: Theme.of(context).colorScheme.backGroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          icon: HeroIcon(
                            value
                                ? HeroIcons.chartPie
                                : HeroIcons.chartBar, // ✅ Use `value`
                            style: HeroIconStyle.solid,
                            color: Theme.of(context).colorScheme.textFieldColor,
                            size: 15.sp,
                          ),
                          onPressed: () {
                            selectedNotifier.value = !selectedNotifier.value;
                            if (widget.title == "project") {
                              // isBarChartForProject = value;
                              widget.onChangeForProject(selectedNotifier.value);
                            } else if (widget.title == "task") {
                              widget.onChangeForTask(selectedNotifier.value);
                            }
                            print("gggjg $value");
                          },
                        ),
                      ))
                ]);
              });
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget _buildTaskLegend(state) {
    return Scrollbar(
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 5,
      controller: _scrollTaskController,
      child: ListView.builder(
        controller: _scrollTaskController,
        itemCount: state.statusWiseTask.length,
        itemBuilder: (BuildContext context, int index) {
          StatusWiseTasks taskStats = state.statusWiseTask[index];

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(int.parse(taskStats.chart_color!)),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  taskStats.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(width: 5),
              Text(
                "${taskStats.totalTasks}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 15),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProjectLegend(state) {
    return Scrollbar(
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 5,
      controller: _scrollProjectController,
      child: ListView.builder(
        controller: _scrollProjectController,
        itemCount: state.statusWiseProject.length,
        itemBuilder: (BuildContext context, int index) {
          StatusWiseProjects projectStats = state.statusWiseProject[index];

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(int.parse(projectStats.chartcolor!)),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  projectStats.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(width: 5),
              Text(
                "${projectStats.totalProjects}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 15),
            ],
          );
        },
      ),
    );
  }
}

class ChartData {
  ChartData(this.category, this.value, this.color);
  final String category;
  final double value;
  final Color color;
}
