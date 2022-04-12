import 'dart:convert';

import 'package:cs530_mobile/controllers/api.dart';
import 'package:cs530_mobile/models/notification_history_data.dart';
import 'package:cs530_mobile/widgets/notification_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

/// Class defines a view for Notfication History
class NotificationHistory extends StatefulWidget {
  final String subscribedCategories;
  /// Constructor for Notification History
  /// Takes argument [subscribedCategories] as comma separated string
  const NotificationHistory({required this.subscribedCategories, Key? key})
      : super(key: key);

  @override
  _NotificationHistoryState createState() => _NotificationHistoryState();
}

/// Private Class for Notfication History State
class _NotificationHistoryState extends State<NotificationHistory> {
  bool _downloadNotificationDataCheck = true;
  List<NotificationHistoryData> _notificationHistoryList = [];

  /// Private method to get all notification history of subscribed categories
  Future<void> _getNotificationHistory() async {
    return API
        .getNotificationHistory(widget.subscribedCategories)
        .then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        _notificationHistoryList = list
            .map((model) => NotificationHistoryData.fromJson(model))
            .toList();
      });
    });
  }

  // initState
  @override
  void initState() {
    _getNotificationHistory().then((value) {
      setState(() {
        _downloadNotificationDataCheck = false;
      });
    });
    super.initState();
  }

  // build method for Notification History
  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    return ModalProgressHUD(
      inAsyncCall: _downloadNotificationDataCheck,
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
      child: RefreshIndicator(
        onRefresh: () => _getNotificationHistory(),
        child: Scaffold(
          appBar: CupertinoNavigationBar(
            backgroundColor: Colors.deepPurple,
            leading: IconButton(
              color: Colors.white,
              icon: const Icon(Icons.navigate_before_outlined),
              onPressed: () => Navigator.of(context).pop(),
            ),
            middle: const Text(
              'NOTIFICATION HISTORY',
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
                Colors.indigo.shade300.withOpacity(.10),
                Colors.deepPurple.shade300.withOpacity(.10),
                Colors.indigo.shade300.withOpacity(.8),
                Colors.deepPurple.shade300.withOpacity(.8),
              ],
            )),
            child: AnimationLimiter(
              child: Hero(
                tag: 'HeroOne',
                child: StickyGroupedListView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  reverse: true,
                  order: StickyGroupedListOrder.DESC,
                  elements: _notificationHistoryList,
                  itemBuilder: (_, NotificationHistoryData element) {
                    return Center(
                        child: NotificationTile(element,
                            _notificationHistoryList.indexOf(element)));
                  },
                  itemComparator: (NotificationHistoryData element1, NotificationHistoryData element2) =>
                                                                 element1.time.compareTo(element2.time),
                  groupBy: (NotificationHistoryData element) => DateTime(
                      DateTime.parse(element.time.toString()).toLocal().year,
                      DateTime.parse(element.time.toString()).toLocal().month,
                      DateTime.parse(element.time.toString()).toLocal().day),
                  groupSeparatorBuilder: (NotificationHistoryData element) =>
                      Container(
                    decoration:
                        BoxDecoration(color: Colors.transparent.withAlpha(20)),
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
            ),
          ),
        ),
      ),
    );
  }
}
