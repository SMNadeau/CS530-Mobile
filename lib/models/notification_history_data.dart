/// Data Class NotificationHistoryData for Notification History data returned from web app
class NotificationHistoryData{
  String? eventId;
  String time;
  String title;
  String message;

  NotificationHistoryData(this.eventId, this.time, this.title, this.message,);

  NotificationHistoryData.fromJson(Map json)
      : eventId = json['eventId'],
        time = json['time'],
        title = json['title'],
        message = json['message'];

  Map toJson() {
    return {'eventId': eventId, 'time': time, 'title': title, 'message': message};
  }

  Object? toList() {}

}