import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:cs530_mobile/views/event_detail.dart';
import 'package:cs530_mobile/views/splash.dart';
import 'package:cs530_mobile/views/upcoming_events.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'controllers/api.dart';
import 'controllers/utils.dart';
import 'models/calendar_item.dart';

/// Main Class
void main() async {
  // Ensure initialization of Firbase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp()
      // .whenComplete(() {
      //   print("Completed intializing Firebase Core");
      // })
      ;

  // FCM
  // Request Permissions
  FirebaseMessaging.instance.requestPermission();

  // Update the iOS foreground notification presentation options to allow
  // heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  //  FCM onBackground Callback | Setting to defined private handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Creating Notification Channel for Android
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      // 'resource://drawable/ic_launcher.png',
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          importance: NotificationImportance.High,
          channelShowBadge: true,
          ledColor: Colors.white
        )
      ]);

  // Run MyApp
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

// FCM onBackground Handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // calling `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  // print("Handling a background message: ${message.messageId}");

  // calling customized message handler
  messageHandler(message);
}

// Customized Message Handler
messageHandler(RemoteMessage message) async {
    // Print Message
      // print("message received ${message.data}");

      // Read list of muted events stored in local file
      List<dynamic> _mutedEventsList = [];
      await readContent("mutedevents").then((String? value) {
        if (value != null) {
          _mutedEventsList = jsonDecode(value);
        }
      });

      // Initalize mute boolean
      bool muteNotification = false;
      // If muted events present check condition to change state of mute boolean
      if (_mutedEventsList.isNotEmpty) {
        _mutedEventsList.forEach((mci) => {
              if (message.data['eventId'] == (mci.toString()))
                {
                  // print('THIS MESSAGE SHOULD MUTE ITSELF'),
                  muteNotification = true
                }
            });
      }

      // READ SUBSCRIBED CATS
      List<dynamic> _subscribedCatsList = [];
      await readContent("categories").then((String? value) {
        if (value != null) {
          _subscribedCatsList = jsonDecode(value);
        }
      });

      // FIND SUBSCRIBED CATEGORY PRESENT
      bool _subscribedCatPresent = false;

      if (message.data['categories'] != null) {
        List<dynamic> _notificationCatList =
            jsonDecode(message.data['categories']);
        _notificationCatList.forEach((element) {
          if (_subscribedCatsList.contains(element)) {
            // print(_subscribedCatsList);
            // print(_subscribedCatPresent);
            _subscribedCatPresent = true;
          }
          if (element == "Uncat") {
            _subscribedCatPresent = true;
          }
        });
      }

      // SHOW NOTIFICATION IF NOT MUTED
      if (!muteNotification && _subscribedCatPresent) {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: DateTime.now().microsecond,
              channelKey: 'basic_channel',
              title: message.data['title'] ?? 'No Title',
              body: message.data['body'] ?? 'No Body',
              payload: {'eventId': message.data['eventId'] ?? 'null'}),
        );
      }
}

// MyApp
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  // Create State
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // State Intialization
  @override
  void initState() {
    super.initState();
    // Create a dialog if permissions are not provided for notifications
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // Show a dialog to allow notifications
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Allow Notifications'),
                  content: const Text(
                      'Volutary Spam App would like to spam you with notifications'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Don\'t Allow',
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        )),
                    // Allow Textbutton has onClick to Request for permissions
                    TextButton(
                      onPressed: () => AwesomeNotifications()
                          .requestPermissionToSendNotifications()
                          .then((value) => Navigator.pop(context)),
                      child: const Text(
                        'Allow',
                        style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ));
      }
    });

    // Set Action Stream for handling onClick notification
    AwesomeNotifications().actionStream.listen((event) async {
      List<CalendarItem> _calendarItemsList = [];
      // If notification is from our channel
      if (event.channelKey == 'basic_channel') {
        // Reduce the badge counter as user clicks to read
        AwesomeNotifications().getGlobalBadgeCounter().then(
            (value) => AwesomeNotifications().setGlobalBadgeCounter(value - 1));
      }

      // Request & Iterate through all calendar items to keep a check if a new event was created should open
      await API.getAllCalendarItems().then((response) {
        Iterable list = json.decode(response.body);
        _calendarItemsList =
            list.map((model) => CalendarItem.fromJson(model)).toList();
        // initialize event found to false
        bool eventLocated = false;
        // iterate to update the event found and handle opening event if found
        for (var element in _calendarItemsList) {
          if (element.id == event.payload!['eventId']) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EventDetail(element, false)));
            eventLocated = true;
          }
        }
        // if event not found then send to schedule view of calendar
        if (!eventLocated) {
          readContent("categories").then((String? value) {
            List<dynamic> readCategoryList = jsonDecode(value ?? '');
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Calendar(
                      subscribedCategories: getListAsCommaSepratedString(
                          readCategoryList, "Uncat"),
                    )));
          });
        }
      });
    });

    // FCM onForegorund Message Recieved
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      messageHandler(message);
    });
  }

  // To dispose the active stream of awesome notifications
  @override
  void dispose() {
    AwesomeNotifications().actionSink.close();
    super.dispose();
  }
  
  // build method returns splash screen
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VOLUNTARY SPAM APP',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        secondaryHeaderColor: Colors.black87,
      ),
      home: const SplashScreen(),
    );
  }
}
