// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarItem _$CalendarItemFromJson(Map<String, dynamic> json) => CalendarItem(
      id: json['id'] as String?,
      summary: json['summary'] as String?,
      description: json['description'] as String?,
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      notifications: (json['notifications'] as List<dynamic>?)
          ?.map((e) => e as NotificationHistoryData)
          .toList(),
      eventCategories: (json['eventCategories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      calendarId: json['calendarId'] as String?,
      title: json['title'] as String?,
      category: json['category'] as String?,
      start: json['start'] as String?,
      end: json['end'] as String?,
      isAllDay: json['isAllDay'] as bool?,
    );

Map<String, dynamic> _$CalendarItemToJson(CalendarItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'summary': instance.summary,
      'description': instance.description,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'notifications': instance.notifications,
      'calendarId': instance.calendarId,
      'title': instance.title,
      'category': instance.category,
      'start': instance.start,
      'end': instance.end,
      'isAllDay': instance.isAllDay,
    };
