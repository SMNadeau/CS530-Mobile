import 'dart:async';
import 'package:http/http.dart' as http;

// To test with web app locally uncomment below
// const baseUrl = "http://localhost:5001";

/// Constant endpoint base url of web app
const baseUrl = "https://cs530-beclawski.web.app/";

/// API Class is used to define endpoints for web app
class API {
  /// Returns async json of all categories from web app
  static Future getCategories() {
    var url = baseUrl + "/categories";
    return http.get(Uri.parse(url));
  }

  /// Returns async json of all notifications from web app for passed categories
  /// Takes argument [categories] of type String like 'Volunteer,Community'
  static Future getNotificationHistory(String categories) {
    var url = baseUrl + "/notify/previousByCategory?categories=$categories";
    return http.get(Uri.parse(url));
  }

  /// Returns async json calendar items from web app for passed categories
  /// Takes argument [categories] of type String like 'Volunteer,Community'
  static Future getCalendarItems(String categories) {
    var url = baseUrl + "/api/events?categories=$categories";
    return http.get(Uri.parse(url));
  }

  /// Returns async json of all calendar events from web app
  static Future getAllCalendarItems() {
    var url = baseUrl + "/api/events";
    return http.get(Uri.parse(url));
  }
}