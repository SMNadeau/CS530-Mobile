import 'package:cs530_mobile/models/notification_history_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

/// Class defines Notification Card Tile Widget List for Notification History View
class NotificationTile extends StatelessWidget {
  final NotificationHistoryData ntData;
  final int n;

  const NotificationTile(this.ntData, this.n, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

  var dateUtc = ntData.time;
  var strToDateTime = DateTime.parse(dateUtc.toString());
  final convertLocal = strToDateTime.toLocal();
  var newFormat = DateFormat("hh:mm aaa");
  String dateLocal = newFormat.format(convertLocal);

    return AnimationConfiguration.staggeredList(
      position: n,
      delay: const Duration(milliseconds: 5),
      child: ScaleAnimation(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInCubic,
        child: SlideAnimation(
          duration: const Duration(milliseconds: 200),
          horizontalOffset: -300,
          verticalOffset: -250,
          curve: Curves.easeInCubic,
          child: Card(     
            color: Colors.black87.withAlpha(20),                           
            elevation: 4.0,
            margin: const EdgeInsets.all(10.0),
            shape: RoundedRectangleBorder(              
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, right: 10.0),
                  child: Text(
                   dateLocal.toString(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                ListTile(
                  title: Text(ntData.title,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                letterSpacing: 1.0,
              ),),
                  subtitle: Text(ntData.message,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
              ),),
                  isThreeLine: true,
                  leading: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Lottie.asset(
                        'assets/notification_bell.json',
                        repeat: true,
                        animate: true,
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ),
                  // trailing: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
