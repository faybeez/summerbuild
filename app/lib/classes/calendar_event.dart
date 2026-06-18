class CalendarEvent {
  final int id;
  final String userId;
  final String title;
  final String? description;
  final DateTime eventDate;
  final String? startTime;
  final String? endTime;
  final String? location;
  final int? linkedOutfitId;
  final String? linkedOutfitName;
  final DateTime createdAt;
  final DateTime editedAt;

  const CalendarEvent({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.eventDate,
    this.startTime,
    this.endTime,
    this.location,
    this.linkedOutfitId,
    this.linkedOutfitName,
    required this.createdAt,
    required this.editedAt,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: (json['id'] as num).toInt(),
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      eventDate: DateTime.parse(json['event_date'] as String),
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      location: json['location'] as String?,
      linkedOutfitId: (json['outfit_id'] as num?)?.toInt(),
      linkedOutfitName: json['outfits'] != null
          ? (json['outfits'] as Map<String, dynamic>)['name'] as String?
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      editedAt: DateTime.parse(json['edited_at'] as String),
    );
  }

  CalendarEvent copyWith({
    String? title,
    String? description,
    DateTime? eventDate,
    String? startTime,
    String? endTime,
    String? location,
    int? linkedOutfitId,
    String? linkedOutfitName,
  }) {
    return CalendarEvent(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      linkedOutfitId: linkedOutfitId ?? this.linkedOutfitId,
      linkedOutfitName: linkedOutfitName ?? this.linkedOutfitName,
      createdAt: createdAt,
      editedAt: editedAt,
    );
  }
}
