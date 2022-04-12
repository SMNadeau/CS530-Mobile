import 'package:cs530_mobile/models/notification_history_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'calendar_item.g.dart';

/// Data Class CalendarItem for calendar event data returned from web app
@JsonSerializable()
class CalendarItem {
	String? id;
	String? summary;
	String? description;
	DateTime? startTime;
	DateTime? endTime;
	List<NotificationHistoryData>? notifications;
	List<String>? eventCategories;
	String? calendarId;
	String? title;
	String? category;
	String? start;
	String? end;
	bool? isAllDay;

	CalendarItem({
		this.id, 
		this.summary, 
    this.description,
		this.startTime, 
		this.endTime, 
		this.notifications, 
    this.eventCategories,
		this.calendarId, 
		this.title, 
		this.category, 
		this.start, 
		this.end, 
		this.isAllDay, 
	});

	factory CalendarItem.fromJson(Map<String, dynamic> json) {
		return _$CalendarItemFromJson(json);
	}

	Map<String, dynamic> toJson() => _$CalendarItemToJson(this);
}
