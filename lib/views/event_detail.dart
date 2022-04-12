import 'dart:convert';
import 'dart:ui';

import 'package:cs530_mobile/controllers/api.dart';
import 'package:cs530_mobile/controllers/utils.dart';
import 'package:cs530_mobile/models/calendar_item.dart';
import 'package:cs530_mobile/models/notification_history_data.dart';
import 'package:cs530_mobile/widgets/notification_tile.dart';
import 'package:flip_panel/flip_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

/// Class EventDetail defines a Detail View of Event
class EventDetail extends StatefulWidget {
  // Each event detail page must contain a calendar item and muted status
  final CalendarItem calendarItem;
  final bool isMuted;
  // constructor
  const EventDetail(this.calendarItem, this.isMuted, {Key? key})
      : super(key: key);
  // create state
  @override
  _EventDetailState createState() => _EventDetailState();
}

/// Private Class for Event Detail State
class _EventDetailState extends State<EventDetail> {
  // private bool to check download status
  bool _downloadNotificationDataCheck = true;
  // private List will contain all notification history data
  List<NotificationHistoryData> _notificationHistoryList = [];
  // private List will contain notification history data specific to single event
  List<NotificationHistoryData> _eventSpecificNotificationHistoryList = [];
  // private Comma Separated subscribed categories to pass
  String _subscribedCats = '';
  // private bool to figure out if event is onGoing
  late bool _onGoing;

  /// private method to do a async call to get notification history of event
  Future<void> _getNotificationHistory() async {
    // read the categories file to get subscribed categories
    await readContent("categories").then((String? value) {
      List<dynamic> readCategoryList = jsonDecode(value ?? '');
      _subscribedCats = getListAsCommaSepratedString(readCategoryList, "Uncat");
    });

    // Call to get notifiaction history from web app
    return API.getNotificationHistory(_subscribedCats).then((response) {
      // Update the state of vars
      setState(() {
        // Decode the json list returned from web app
        Iterable list = json.decode(response.body);
        // Map returned data to _notificationHistoryList
        _notificationHistoryList = list
            .map((model) => NotificationHistoryData.fromJson(model))
            .toList();
        // Update _eventSpecificNotificationHistoryList
        _eventSpecificNotificationHistoryList = [];
        for (var element in _notificationHistoryList) {
          // if event id matches the current calendar item id then add it to event specific list
          if (element.eventId == widget.calendarItem.id) {
            _eventSpecificNotificationHistoryList.add(element);
          }
        }
      });
    });
  }

  /// initState for event detail view
  @override
  void initState() {
    // initialize onGoing to false
    _onGoing = false;
    // call to initalize event specific notifiation history
    _getNotificationHistory().then((value) {
      setState(() {
        // once completed update download bool so we can preview
        _downloadNotificationDataCheck = false;
      });
    });
    super.initState();
  }

  /// build method for event detail view
  @override
  Widget build(BuildContext context) {
    // Durations
    Duration _startDuration =
        widget.calendarItem.startTime!.difference(DateTime.now());
    Duration _endDuration =
        widget.calendarItem.endTime!.difference(DateTime.now());

    // Count difference in days
    int _diffInDays(DateTime date1, DateTime date2) {
      return ((date1.difference(date2) -
                      Duration(hours: date1.hour) +
                      Duration(hours: date2.hour))
                  .inHours /
              24)
          .round();
    }

    // Update onGoing status
    (DateTime.now().isAfter(widget.calendarItem.startTime!) &&
                DateTime.now().isBefore(widget.calendarItem.endTime!)) ||
            ((_diffInDays(DateTime.now(), widget.calendarItem.startTime!) ==
                    0) &&
                widget.calendarItem.isAllDay! &&
                DateTime.now().isAfter(widget.calendarItem.startTime!))
        ? setState(() => {_onGoing = true})
        : setState(() => {_onGoing = false});

    // return event detail view
    return ModalProgressHUD(
      // progress dialog
      inAsyncCall: _downloadNotificationDataCheck,
      // progress indicator to lottie loading.json file
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
      // scaffold
      child: Scaffold(
          // appBar
          appBar: CupertinoNavigationBar(
            backgroundColor: Colors.deepPurple,
            leading: Material(
              color: Colors.deepPurple,
              // back button
              child: IconButton(
                color: Colors.white,
                icon: const Icon(Icons.navigate_before_outlined),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            // title
            middle: const Text(
              'EVENT DETAIL',
              style: TextStyle(color: Colors.white),
            ),
          ),
          // body
          body: SingleChildScrollView(
            child:
                // condition to check the time duration
                _startDuration.inMicroseconds.compareTo(DateTime.now()
                                .difference(DateTime.now())
                                .inMicroseconds) >
                            0 &&
                        _endDuration.inMicroseconds.compareTo(DateTime.now()
                                .difference(DateTime.now())
                                .inMicroseconds) >
                            0
                    ?
                    // if future event return column
                    Column(
                        children: [
                          // Hero Animation on container with event status
                          Hero(
                            tag: 'HeroOne',
                            child: Container(
                              height: 25,
                              decoration: BoxDecoration(
                                  color: Colors.indigo.withAlpha(150)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'UPCOMING EVENT',
                                    style: TextStyle(
                                      fontSize: 12,
                                      letterSpacing: 1.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          // Flip clock with reverse count down
                          SizedBox(
                            height: 64.0,
                            child: FlipClock.reverseCountdown(
                              duration: _startDuration,
                              digitColor: Colors.white,                              
                              backgroundColor: Colors.black87,
                              digitSize: 30.0,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(3.0)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _eventDetailView(context),
                        ],
                      )
                    :
                    // if not future event, check if it is onGoing 
                    _onGoing
                        ? 
                        // if onGoing event return onGoing Column container with hero animation
                        Column(
                            children: [
                              Hero(
                                tag: 'HeroOne',
                                child: Container(
                                  height: 25,
                                  decoration: BoxDecoration(
                                      color: Colors.green.withAlpha(150)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'ON-GOING EVENT',
                                        style: TextStyle(
                                          fontSize: 12,
                                          letterSpacing: 1.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _eventDetailView(context)
                            ],
                          )
                        : 
                        // if past event return past Column container with hero animation
                        Column(
                            children: [
                              Hero(
                                tag: 'HeroOne',
                                child: Container(
                                  height: 25,
                                  decoration: BoxDecoration(
                                      color: Colors.red.withAlpha(150)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'PAST EVENT',
                                        style: TextStyle(
                                          fontSize: 12,
                                          letterSpacing: 1.0,
                                          color: Colors.white.withOpacity(1.0),
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _eventDetailView(context)
                            ],
                          ),
          )),
    );
  }

  /// private method returns common container for past, ongoing and future events
  Container _eventDetailView(BuildContext context) {
    return Container(
      // take width and height of available screen
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
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  Text(
                    widget.calendarItem.title ?? 'TITLE',
                    style: const TextStyle(
                        fontSize: 22,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.bold),
                  ),
                  // IsMuted condition updates the image of muted or not
                  widget.isMuted
                      ? Image.asset(
                          'assets/notification_off.png',
                          height: 25,
                          width: 25,
                        )
                      : Image.asset('assets/notification_on.png',
                          height: 25, width: 25)
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // If Event is not all day print start and end date time else print all day
            widget.calendarItem.isAllDay!
                ? Padding(
                    padding: const EdgeInsets.only(
                        left: 5.0, right: 15.0, top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ALL DAY',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w800),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy')
                                  .format(widget.calendarItem.startTime!)
                                  .toString() +
                              DateFormat(' - MMM dd, yyyy')
                                  .format(widget.calendarItem.endTime!)
                                  .toString(),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 5.0, right: 15.0, top: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'STARTS:\t',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.w800),
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy hh:mm a')
                                  .format(widget.calendarItem.startTime!)
                                  .toString(),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 5.0, right: 15.0, top: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ENDS:\t',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.w800),
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy hh:mm a')
                                  .format(widget.calendarItem.endTime!)
                                  .toString(),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            const SizedBox(
              height: 15,
            ),
            // Categories
            Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 15.0, top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'CATEGORIES',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w800),
                  ),
                  Text(
                    widget.calendarItem.eventCategories != null
                        ? widget.calendarItem.eventCategories
                            .toString()
                            .replaceAll('[', '')
                            .replaceAll(']', '')
                        : 'Uncat',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            // Description
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DESCRIPTION:',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w800),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Center(
                      child: Text(
                        widget.calendarItem.description ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // Notification History
            const Center(
              child: Text(
                'NOTIFICATION HISTORY',
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            _eventSpecificNotificationHistoryList.isEmpty
                ? const SizedBox(
                    height: 0,
                  )
                : Expanded(
                    child: StickyGroupedListView(
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      reverse: false,
                      floatingHeader: false,
                      order: StickyGroupedListOrder.DESC,
                      elements: _eventSpecificNotificationHistoryList,
                      itemBuilder: (_, NotificationHistoryData element) {
                        return Center(
                            child: NotificationTile(
                                element,
                                _eventSpecificNotificationHistoryList
                                    .indexOf(element)));
                      },
                      itemComparator: (NotificationHistoryData element1,
                              NotificationHistoryData element2) =>
                          element1.time.compareTo(element2.time),
                      groupBy: (NotificationHistoryData element) => DateTime(
                          DateTime.parse(element.time.toString())
                              .toLocal()
                              .year,
                          DateTime.parse(element.time.toString())
                              .toLocal()
                              .month,
                          DateTime.parse(element.time.toString())
                              .toLocal()
                              .day),
                      groupSeparatorBuilder:
                          (NotificationHistoryData element) => Container(
                        decoration: BoxDecoration(
                            color: Colors.transparent.withAlpha(20)),
                        height: 50,
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 220,
                            decoration: BoxDecoration(
                              color: Colors.indigo.withAlpha(60),
                              border: Border.all(
                                color: Colors.black87.withAlpha(20),
                              ),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5.0)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                DateFormat("MMM dd, yyyy  EEEE").format(
                                    DateTime.parse(element.time.toString())
                                        .toLocal()),
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
