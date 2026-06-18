class CalendarDaySummary {
  final DateTime date;
  final bool hasOotd;
  final bool hasEvents;
  final int eventCount;
  final int? ootdId;

  const CalendarDaySummary({
    required this.date,
    required this.hasOotd,
    required this.hasEvents,
    required this.eventCount,
    this.ootdId,
  });

  factory CalendarDaySummary.fromJson(Map<String, dynamic> json) {
    return CalendarDaySummary(
      date: DateTime.parse(json['date'] as String),
      hasOotd: (json['has_ootd'] as bool?) ?? false,
      hasEvents: (json['has_events'] as bool?) ?? false,
      eventCount: (json['event_count'] as num?)?.toInt() ?? 0,
      ootdId: (json['ootd_id'] as num?)?.toInt(),
    );
  }
}
