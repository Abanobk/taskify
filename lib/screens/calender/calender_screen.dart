// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:syncfusion_flutter_calendar/calendar.dart';
// import 'package:intl/intl.dart';
//
// class GoogleCalendarScreen extends StatefulWidget {
//   const GoogleCalendarScreen({super.key});
//
//   @override
//   State<GoogleCalendarScreen> createState() => _GoogleCalendarScreenState();
// }
//
// class _GoogleCalendarScreenState extends State<GoogleCalendarScreen> {
//   List<Meeting> _meetings = [];
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchPublicCalendarEvents();
//   }
//
//   Future<void> _fetchPublicCalendarEvents() async {
//     // Replace with the public calendar ID
//     final String calendarId = 'f239f77fa4a7bd370e8ef92d595386f9833b16a38c34246220bb42d52e049174@group.calendar.google.com'; // US Holidays calendar as an example
//
//     // API Key from Google Cloud Console (restricted to Calendar API)
//     final String apiKey = 'AIzaSyBghdcnqjAh06roQ9vqh5u63mIhNC9sljg';
//
//     final Uri url = Uri.parse(
//         'https://www.googleapis.com/calendar/v3/calendars/$calendarId/events?key=$apiKey');
//
//     try {
//       final response = await http.get(url);
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         List<Meeting> meetings = [];
//
//         for (var item in data['items']) {
//           // Handle all-day events (date) and timed events (dateTime)
//           DateTime start;
//           DateTime end;
//           bool isAllDay = false;
//
//           if (item['start'].containsKey('date')) {
//             // All-day event
//             start = DateTime.parse(item['start']['date']);
//             end = DateTime.parse(item['end']['date']);
//             // End date is exclusive for all-day events
//             end = end.subtract(const Duration(days: 1));
//             isAllDay = true;
//           } else {
//             // Timed event
//             start = DateTime.parse(item['start']['dateTime']);
//             end = DateTime.parse(item['end']['dateTime']);
//           }
//
//           meetings.add(Meeting(
//             item['summary'] ?? 'Untitled Event',
//             start,
//             end,
//             Theme.of(context).colorScheme.primary,
//             isAllDay,
//             item['description'] ?? '',
//             item['location'] ?? '',
//           ));
//         }
//
//         setState(() {
//           _meetings = meetings;
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _isLoading = false;
//         });
//         print('Failed to load calendar: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       print('Error fetching calendar: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Public Calendar'),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SfCalendar(
//         view: CalendarView.month,
//         dataSource: MeetingDataSource(_meetings),
//         monthViewSettings: const MonthViewSettings(
//             appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
//         onTap: (CalendarTapDetails details) {
//           if (details.targetElement == CalendarElement.appointment) {
//             final Meeting meeting = details.appointments![0];
//             _showEventDetails(meeting);
//           }
//         },
//       ),
//     );
//   }
//
//   void _showEventDetails(Meeting meeting) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               meeting.eventName,
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               '${DateFormat('MMM dd, yyyy').format(meeting.from)} ${meeting.isAllDay ? '' : '- ${DateFormat('hh:mm a').format(meeting.from)}'}',
//             ),
//             if (!meeting.isAllDay && meeting.from.day == meeting.to.day)
//               Text('to ${DateFormat('hh:mm a').format(meeting.to)}'),
//             if (meeting.from.day != meeting.to.day)
//               Text('to ${DateFormat('MMM dd, yyyy').format(meeting.to)}'),
//             if (meeting.location.isNotEmpty) const SizedBox(height: 8),
//             if (meeting.location.isNotEmpty)
//               Row(
//                 children: [
//                   const Icon(Icons.location_on, size: 16),
//                   const SizedBox(width: 4),
//                   Expanded(child: Text(meeting.location)),
//                 ],
//               ),
//             if (meeting.description.isNotEmpty) const SizedBox(height: 8),
//             if (meeting.description.isNotEmpty)
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Text(meeting.description),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class Meeting {
//   final String eventName;
//   final DateTime from;
//   final DateTime to;
//   final Color background;
//   final bool isAllDay;
//   final String description;
//   final String location;
//
//   Meeting(
//       this.eventName,
//       this.from,
//       this.to,
//       this.background,
//       this.isAllDay,
//       this.description,
//       this.location,
//       );
// }
//
// class MeetingDataSource extends CalendarDataSource {
//   MeetingDataSource(List<Meeting> source) {
//     appointments = source;
//   }
//
//   @override
//   DateTime getStartTime(int index) {
//     return appointments![index].from;
//   }
//
//   @override
//   DateTime getEndTime(int index) {
//     return appointments![index].to;
//   }
//
//   @override
//   String getSubject(int index) {
//     return appointments![index].eventName;
//   }
//
//   @override
//   Color getColor(int index) {
//     return appointments![index].background;
//   }
//
//   @override
//   bool isAllDay(int index) {
//     return appointments![index].isAllDay;
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/config/constants.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import 'package:taskify/utils/widgets/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../api_helper/api_base_helper.dart';
import '../../src/generated/i18n/app_localizations.dart';
class GoogleCalendarScreen extends StatefulWidget {
  const GoogleCalendarScreen({super.key});

  @override
  State<GoogleCalendarScreen> createState() => _GoogleCalendarScreenState();
}

class _GoogleCalendarScreenState extends State<GoogleCalendarScreen> {
  List<CalendarEvent> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllCalendarData();
  }

  Future<void> _fetchAllCalendarData() async {
    try {
      // Start loading both data sources in parallel
      final googleEventsFuture = _fetchGoogleCalendarEvents();
      final leaveEventsFuture = _fetchLeaveRequests();

      // Wait for both to complete
      final List<List<CalendarEvent>> results = await Future.wait([
        googleEventsFuture,
        leaveEventsFuture,
      ]);

      // Combine the results
      final List<CalendarEvent> combinedEvents = [
        ...results[0], // Google events
        ...results[1], // Leave requests
      ];

      setState(() {
        _events = combinedEvents;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching calendar data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<CalendarEvent>> _fetchGoogleCalendarEvents() async {
    List<CalendarEvent> events = [];

    // Get date range for the calendar
    final DateTime now = DateTime.now();
    final DateTime startDate = DateTime(now.year, now.month - 1, 1);
    final DateTime endDate = DateTime(now.year, now.month + 2, 0);

    // Public Google Calendar ID (using US Holidays as an example)
    final String calendarId =
        'f239f77fa4a7bd370e8ef92d595386f9833b16a38c34246220bb42d52e049174@group.calendar.google.com'; // US Holidays calendar as an example

    // API Key from Google Cloud Console (restricted to Calendar API)
    final String apiKey = 'AIzaSyBghdcnqjAh06roQ9vqh5u63mIhNC9sljg';

    final Uri url = Uri.parse(
        'https://www.googleapis.com/calendar/v3/calendars/$calendarId/events'
        '?key=$apiKey'
        '&timeMin=${startDate.toUtc().toIso8601String()}'
        '&timeMax=${endDate.toUtc().toIso8601String()}'
        '&singleEvents=true'
        '&orderBy=startTime');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        for (var item in data['items']) {
          // Handle all-day events (date) and timed events (dateTime)
          DateTime start;
          DateTime end;
          bool isAllDay = false;

          if (item['start'].containsKey('date')) {
            // All-day event
            start = DateTime.parse(item['start']['date']);
            end = DateTime.parse(item['end']['date']);
            isAllDay = true;
          } else {
            // Timed event
            start = DateTime.parse(item['start']['dateTime']);
            end = DateTime.parse(item['end']['dateTime']);
          }

          events.add(CalendarEvent(
            id: item['id'],
            title: item['summary'] ?? 'Untitled Event',
            start: start,
            end: end,
            isAllDay: isAllDay,
            description: item['description'] ?? '',
            backgroundColor: Colors.blue,
            borderColor: Colors.blue.shade700,
            textColor: Colors.white,
            source: 'google',
            additionalData: {},
          ));
        }
      } else {
        print('Failed to load Google calendar: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching Google calendar: $e');
    }

    return events;
  }

  Future<List<CalendarEvent>> _fetchLeaveRequests() async {
    List<CalendarEvent> events = [];

    final String dateFrom = DateFormat('MM-dd-yyyy')
        .format(DateTime(DateTime.now().year, DateTime.now().month - 1, 1));
    final String dateTo = DateFormat('MM-dd-yyyy')
        .format(DateTime(DateTime.now().year, DateTime.now().month + 2, 0));

    final String url = "${baseUrl}leave-requests/get-calendar-data";

    try {
      final List<dynamic> data = await ApiBaseHelper.getGoogleApi(
        url: url,
        useAuthToken: true,
        params: {
          "date_from": dateFrom,
          "date_to": dateTo,
        },
      );

      for (var item in data) {
        DateTime start = DateTime.parse(item['start']);
        DateTime end = DateTime.parse(item['end']);

        if (item['from_time'] != null && item['from_time'].isNotEmpty) {
          List<String> timeParts = item['from_time'].split(':');
          start = DateTime(
            start.year,
            start.month,
            start.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
        }

        if (item['end_time'] != null && item['end_time'].isNotEmpty) {
          List<String> timeParts = item['end_time'].split(':');
          end = DateTime(
            end.year,
            end.month,
            end.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
        } else if (item['allDay'] == true) {
          end = end.add(const Duration(days: 1));
        }

        Color backgroundColor =
            _hexToColor(item['backgroundColor'] ?? '#4caf50');
        Color borderColor = _hexToColor(item['borderColor'] ?? '#4caf50');
        Color textColor = _hexToColor(item['textColor'] ?? '#ffffff');

        events.add(CalendarEvent(
          id: item['id'] ?? 0,
          title: item['title'] ?? 'Untitled',
          start: start,
          end: end,
          isAllDay: item['allDay'] ?? false,
          description: item['description'] ?? '',
          backgroundColor: backgroundColor,
          borderColor: borderColor,
          textColor: textColor,
          source: 'leave',
          additionalData: {
            'status': item['extendedProps']?['status'] ?? 'pending',
          },
        ));
      }
    } catch (e) {
      print('Error fetching leave requests: $e');
    }

    return events;
  }

  bool isGrid = true;

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 7) {
      buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
    } else {
      buffer.write(hexString.replaceFirst('#', ''));
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitFadingCircle(
                  color: AppColors.primary,
                  size: 70.0,
                ),
                CustomText(
                  text: "Loading ..... ",
                  fontWeight: FontWeight.w900,
                  size: 18.sp,
                  color: Theme.of(context).colorScheme.textClrChange,
                )
              ],
            )

      // Center(
      //   child: Container(
      //       height: 100.h,
      //       width: 100.w,
      //       decoration: BoxDecoration(
      //         color: Colors.red,
      //         image: DecorationImage(
      //             image: AssetImage(AppImages.calendarGif),
      //             fit: BoxFit.cover),
      //       )),
      // )
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: BackArrow(
                    title: AppLocalizations.of(context)!.holidaycalendar,
                    refresh: true,
                    format: true,
                    value: isGrid,
                    onReformat: () {
                      setState(() {
                        _isLoading = true;
                        isGrid = !isGrid;
                      });
                      _fetchAllCalendarData();
                    },
                    onRefresh: () {
                      setState(() {
                        _isLoading = true;
                      });
                      _fetchAllCalendarData();
                    },
                  ),
                ),
                // SizedBox(height: 20),
                Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                          // color: Colors.red,
                          height: 50.h,
                          width: double.infinity,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                eventTypeCard(title: AppLocalizations.of(context)!
                                    .publicholidays,color: AppColors.primary),
                                eventTypeCard(title: AppLocalizations.of(context)!
                                    .leaveaccepted,color:Colors.green ),
                                eventTypeCard(title: AppLocalizations.of(context)!
                                    .leavepending,color: AppColors.orangeYellowishColor),
                                eventTypeCard(title: AppLocalizations.of(context)!
                                    .leaverejected,color: AppColors.red),

                              ],
                            ),
                          )),
                    )),
                Expanded(
                  flex: 17,
                  child: SfCalendar(
                    view: isGrid ? CalendarView.schedule : CalendarView.month,

                    scheduleViewSettings: ScheduleViewSettings(
                        monthHeaderSettings: MonthHeaderSettings(
                            monthFormat: 'MMMM, yyyy',
                            height: 100,
                            textAlign: TextAlign.left,
                            backgroundColor: Color(0xff30b2c7),
                            monthTextStyle: TextStyle(
                                color: AppColors.pureWhiteColor,
                                fontSize: 25,
                                fontWeight: FontWeight.w400))),
                    dataSource: CalendarEventDataSource(_events),
                    initialDisplayDate: DateTime.now(),
                    monthViewSettings: MonthViewSettings(
                        appointmentDisplayMode:
                            MonthAppointmentDisplayMode.appointment,
                        showAgenda: true,
                        agendaItemHeight: 50,
                        agendaStyle: AgendaStyle(
                          backgroundColor:
                              Theme.of(context).colorScheme.containerDark,
                          appointmentTextStyle: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.normal,
                              color: AppColors.pureWhiteColor),
                          dateTextStyle: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: Theme.of(context).colorScheme.textClrChange,
                          ),
                          dayTextStyle: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.textClrChange,
                          ),
                        )),

                    // monthViewSettings: const MonthViewSettings(
                    //   appointmentDisplayMode:
                    //       MonthAppointmentDisplayMode.appointment,
                    //   showAgenda: true,
                    // ),
                    onTap: (CalendarTapDetails details) {
                      if (details.targetElement ==
                          CalendarElement.appointment) {
                        final CalendarEvent event = details.appointments![0];
                        _showEventDetails(event);
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }
  Widget eventTypeCard({required String title,required Color color}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(  color:color,
                  borderRadius: BorderRadius.circular(4)
              ),

            )

        ),
        SizedBox(
          width: 5.w,
        ),
        CustomText(
          text:title,
          fontWeight: FontWeight.w400,
          size: 12.sp,
          color: Theme.of(context)
              .colorScheme
              .textClrChange,
        )
      ],
    );
  }

  void _showEventDetails(CalendarEvent event) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Show badge for event source
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: event.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                event.source == 'leave'
                    ? event.additionalData['status']?.toUpperCase() ?? 'LEAVE'
                    : 'GOOGLE CALENDAR',
                style: TextStyle(color: event.textColor, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.date_range, size: 16),
                const SizedBox(width: 4),
                Text(
                  event.isAllDay
                      ? '${DateFormat('MMM dd, yyyy').format(event.start)} - ${DateFormat('MMM dd, yyyy').format(event.end.subtract(const Duration(days: 1)))}'
                      : '${DateFormat('MMM dd, yyyy HH:mm').format(event.start)} - ${DateFormat('MMM dd, yyyy HH:mm').format(event.end)}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (event.description.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.backGroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: HtmlDisplayWidget(htmlContent: event.description),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Simple widget to render HTML content
class HtmlDisplayWidget extends StatelessWidget {
  final String htmlContent;

  const HtmlDisplayWidget({Key? key, required this.htmlContent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This is a very basic HTML rendering - in a real app, you'd use flutter_html package
    String content = htmlContent
        .replaceAll('\r\n', '')
        .replaceAll('<strong>', '')
        .replaceAll('</strong>', '')
        .replaceAll('<br>', '\n')
        .trim();

    return CustomText(
      text: content,
      color: Theme.of(context).colorScheme.textClrChange,
      maxLines: 500,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class CalendarEvent {
  final dynamic id;
  final String title;
  final DateTime start;
  final DateTime end;
  final bool isAllDay;
  final String description;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final String source; // 'google' or 'leave'
  final Map<String, dynamic> additionalData;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.isAllDay,
    required this.description,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.source,
    required this.additionalData,
  });
}

class CalendarEventDataSource extends CalendarDataSource {
  CalendarEventDataSource(List<CalendarEvent> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].start;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].end;
  }

  @override
  String getSubject(int index) {
    return appointments![index].title;
  }

  @override
  Color getColor(int index) {
    return appointments![index].backgroundColor;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}
