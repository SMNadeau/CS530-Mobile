import 'package:firebase_messaging/firebase_messaging.dart';

/// Class defines methods for subscribing to Firebase Cloud Message Topics
class FCM{

/// Final instance for FirebaseMessaging
final fcm = FirebaseMessaging.instance;
 
/// Depreciated Method for Subscribing To Multiple Topics
Future<void> subscribeTopics(List<String> topics) async {
  for(String topic in topics){    
    await fcm.subscribeToTopic(topic);
  }  
}
 
/// Method for Subscribe a single topic
Future<void> subscribeTopic(String topic) async {   
    await fcm.subscribeToTopic(topic);
}

/// Method for UnSubscribe a single topic
Future<void> unSubscribeTopic(String topic) async {   
    await fcm.unsubscribeFromTopic(topic);
}

}