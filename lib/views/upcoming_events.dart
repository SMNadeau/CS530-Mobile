import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cs530_mobile/controllers/api.dart';
import 'package:cs530_mobile/controllers/custom_page_route.dart';
import 'package:cs530_mobile/controllers/utils.dart';
import 'package:cs530_mobile/models/calendar_item.dart';
import 'package:cs530_mobile/views/event_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// Class defines a view for Calendar
class Calendar extends StatefulWidget {
  final String subscribedCategories;

  const Calendar({Key? key, required this.subscribedCategories})
      : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

/// Private Class for Calendar State
class _CalendarState extends State<Calendar> {
  bool _downloadCalendarItemsDataCheck = true;
  List<CalendarItem> _calendarItemsList = [];
  List<dynamic> _mutedEventsList = [];
  bool isMuted = false;

  /// Private async method to get all calendar items
  Future<void> _getCalendarItems() async {
    return API.getCalendarItems(widget.subscribedCategories).then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        _calendarItemsList =
            list.map((model) => CalendarItem.fromJson(model)).toList();
      });
    });
  }

  // initState
  @override
  void initState() {
    super.initState();
    _getMutedEvents();
    _getCalendarItems().then((value) => {
          setState(() {
            _downloadCalendarItemsDataCheck = false;
          })
        });
  }

  /// Private async method to call to get all muted events from local file
  _getMutedEvents() async {
    readContent("mutedevents").then((String? value) {
      setState(() {
        if (value != null) {
          _mutedEventsList = jsonDecode(value);
        }
      });
    });
  }

  // build method
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _downloadCalendarItemsDataCheck,
      progressIndicator: Center(
        child: Lottie.asset(
          'assets/loading.json',
          repeat: true,
          reverse: false,
          animate: true,
          height: 150,
          width: MediaQuery.of(context).size.width - 10,
        ),
      ),
      child: Scaffold(
        appBar: CupertinoNavigationBar(
          backgroundColor: Colors.deepPurple,
          leading: Material(
            color: Colors.deepPurple,
            child: IconButton(
              color: Colors.white,
              icon: const Icon(Icons.navigate_before_outlined),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          middle: const Text(
            'EVENTS CALENDAR',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: const [
              0.1,
              0.4,
              0.6,
              0.9,
            ],
            colors: [
              Colors.white.withOpacity(.01),
              Colors.indigo.shade300.withOpacity(.3),
              Colors.deepPurple.shade300.withOpacity(.3),
              Colors.indigo.withOpacity(.01),
            ],
          )),
          child: Stack(children: [
            const Hero(
              tag: 'HeroOne',
              child: Center(
                child: SizedBox(
                  height: 50,
                ),
              ),
            ),
            // SyncFusion Calendar
            SfCalendar(
              headerStyle: const CalendarHeaderStyle(
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    letterSpacing: 1.5,
                  ),
                  backgroundColor: Colors.transparent),
              backgroundColor: Colors.transparent,
              dataSource: _getCalendarDataSource(_calendarItemsList),
              onTap: _calendarTapped,
              view: CalendarView.schedule,
              monthViewSettings: const MonthViewSettings(showAgenda: true),
              scheduleViewMonthHeaderBuilder: (BuildContext buildContext,
                  ScheduleViewMonthHeaderDetails details) {
                final String monthName = _getMonthDate(details.date.month);
                return Stack(
                  children: [
                    Image(
                      image: ExactAssetImage(
                          'assets/monthImages/' + monthName + '.png'),
                      fit: BoxFit.cover,
                      width: details.bounds.width,
                      height: details.bounds.height,
                      color: Colors.black87.withAlpha(130),
                      colorBlendMode: BlendMode.dstATop,
                    ),
                    Center(
                      child: AnimatedTextKit(
                        animatedTexts: [
                          WavyAnimatedText(
                            monthName.toUpperCase() +
                                ' ' +
                                details.date.year.toString(),
                            textStyle: GoogleFonts.robotoCondensed(
                              color: Colors.white70,
                              fontSize: 24,
                              letterSpacing: 1.5,
                              wordSpacing: 2.0,
                              fontWeight: FontWeight.w900,
                              decoration: TextDecoration.none,
                            ),
                            speed: const Duration(milliseconds: 200),
                          ),
                        ],
                        totalRepeatCount: 1,
                        pause: const Duration(milliseconds: 1000),
                        displayFullTextOnTap: true,
                        stopPauseOnTap: true,
                      ),
                    )
                  ],
                );
              },
              showDatePickerButton: true,
              allowViewNavigation: true,
              allowedViews: const [
                CalendarView.month,
                CalendarView.week,
                CalendarView.day,
                CalendarView.schedule,
              ],
            ),
          ]),
        ),
      ),
    );
  }

  /// Private method to get month names to print in view
  /// Takes argumnet [m] as month name
  String _getMonthDate(int m) {
    switch (m) {
      case 1:
        {
          return "January";
        }
      case 2:
        {
          return "February";
        }
      case 3:
        {
          return "March";
        }
      case 4:
        {
          return "April";
        }
      case 5:
        {
          return "May";
        }
      case 6:
        {
          return "June";
        }
      case 7:
        {
          return "July";
        }
      case 8:
        {
          return "August";
        }
      case 9:
        {
          return "September";
        }
      case 10:
        {
          return "October";
        }
      case 11:
        {
          return "November";
        }
      case 12:
        {
          return "December";
        }
      default:
        {
          return "January";
        }
    }
  }

  String? _apptID = '',
      _apptTitle = '',
      _apptDescription = '',
      _startTimeText = '',
      _endTimeText = '',
      _dateText = '',
      _timeDetails = '';
  CalendarItem cli = CalendarItem();

  /// Private method to define what happens what event is tapped
  void _calendarTapped(CalendarTapDetails details) {

    // Set data struct
    if (details.targetElement == CalendarElement.appointment ||
        details.targetElement == CalendarElement.agenda) {
      final Appointment appointmentDetails = details.appointments![0];

      _apptID = appointmentDetails.id.toString();
      cli.id = appointmentDetails.id.toString();

      setState(() {
        if (_mutedEventsList != null) {
          _mutedEventsList.contains(_apptID) ? isMuted = true : isMuted = false;
        } else {
          isMuted = false;
        }
      });

      _apptTitle = appointmentDetails.subject;
      cli.title = appointmentDetails.subject;

      _apptDescription = appointmentDetails.notes ?? '';
      cli.description = appointmentDetails.notes ?? '';
      cli.eventCategories =
          appointmentDetails.resourceIds as List<String>? ?? ['Uncat'];
      cli.startTime = appointmentDetails.startTime;
      cli.endTime = appointmentDetails.endTime;
      cli.title = appointmentDetails.subject;
      cli.isAllDay = appointmentDetails.isAllDay;

      _dateText = DateFormat('MMMM dd, yyyy')
          .format(appointmentDetails.startTime)
          .toString();
      _startTimeText =
          DateFormat('hh:mm a').format(appointmentDetails.startTime).toString();
      _endTimeText =
          DateFormat('hh:mm a').format(appointmentDetails.endTime).toString();
      if (appointmentDetails.isAllDay) {
        _timeDetails = 'All day';
      } else {
        _timeDetails = '$_startTimeText - $_endTimeText';
      }

      // Show Pop-Up with event detail also selection to open or mute
      showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width - 140,
                child: Text(
                  '$_apptTitle',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                      fontSize: 22,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              isMuted
                  ? Image.asset(
                      'assets/notification_off.png',
                      height: 25,
                      width: 25,
                    )
                  : Image.asset('assets/notification_on.png',
                      height: 25, width: 25),
            ],
          ),
          message: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$_apptDescription",
                textAlign: TextAlign.left,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 5.0),
              Text(
                "$_dateText",
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w800),
              ),
              Text(
                _timeDetails!,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                'Categories: ' +
                    cli.eventCategories
                        .toString()
                        .replaceAll('[', '')
                        .replaceAll(']', ''),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          actions: <CupertinoActionSheetAction>[
            CupertinoActionSheetAction(
              child: const Text('Open'),
              onPressed: () {
                Navigator.pop(context);
                // Navigator.of(context).push(
                Navigator.push(
                    context,
                    // MaterialPageRoute(builder: (context) => EventDetail(cli,isMuted)));
                    CustomPageRoute(EventDetail(cli, isMuted), "curved"));
              },
            ),
            CupertinoActionSheetAction(
              child: isMuted
                  ? const Text(
                      'Unmute Event',
                      style: TextStyle(color: Colors.blue),
                    )
                  : const Text(
                      'Mute Event',
                      style: TextStyle(color: Colors.red),
                    ),
              onPressed: () async {
                isMuted
                    ? setState(() {
                        isMuted = false;
                        if (_mutedEventsList != null) {
                          _mutedEventsList.remove(_apptID);
                        }
                      })
                    : setState(() {
                        isMuted = true;
                        if (_apptID != null) {
                          _mutedEventsList.add(_apptID!);
                          // print("MUTING $_apptID");
                        }
                      });

                await writeContent("mutedevents", _mutedEventsList);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
  }
}

// SyncFusion Datasource settings for calendar item
class DataSource extends CalendarDataSource {
  DataSource(List<Appointment> source) {
    appointments = source;
  }
}

DataSource _getCalendarDataSource(List<CalendarItem> _calendarItemsList) {
  List<Appointment> appointments = <Appointment>[];
  for (var cli in _calendarItemsList) {
    appointments.add(Appointment(
        id: cli.id,
        startTime: _getLocalTime(cli.startTime ?? DateTime.now()),
        endTime: _getLocalTime(
            cli.endTime ?? DateTime.now().add(const Duration(minutes: 1))),
        isAllDay: cli.isAllDay ?? false,
        subject: cli.summary ?? '',
        notes: cli.description ?? '',
        resourceIds: cli.eventCategories ?? ['Uncat'],
        color: cli.category != null
            ? Colors.indigo.withAlpha(90)
            : Colors.teal.withAlpha(90),
        startTimeZone: '',
        endTimeZone: ''));
  }

  return DataSource(appointments);
}

/// Private method to get local time from UTC
/// Takes argument [dt] as UTC time returned from web app
DateTime _getLocalTime(DateTime dt) {
  var dateUtc = dt;
  var strToDateTime = DateTime.parse(dateUtc.toString());
  final convertLocal = strToDateTime.toLocal();
  return convertLocal;
}
