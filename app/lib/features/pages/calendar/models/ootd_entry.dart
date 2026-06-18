class OotdEntry {
  final int id;
  final String userId;
  final DateTime wornAt;
  final String? caption;
  final int? rating;
  final String imageType;
  final String? imageUrl;
  final int? linkedOutfitId;
  final String? linkedOutfitName;
  final int? linkedEventId;
  final String? linkedEventTitle;
  final int? occasionTagId;
  final int? weatherTagId;
  final DateTime createdAt;
  final DateTime editedAt;

  const OotdEntry({
    required this.id,
    required this.userId,
    required this.wornAt,
    this.caption,
    this.rating,
    required this.imageType,
    this.imageUrl,
    this.linkedOutfitId,
    this.linkedOutfitName,
    this.linkedEventId,
    this.linkedEventTitle,
    this.occasionTagId,
    this.weatherTagId,
    required this.createdAt,
    required this.editedAt,
  });

  factory OotdEntry.fromJson(Map<String, dynamic> json) {
    return OotdEntry(
      id: (json['id'] as num).toInt(),
      userId: json['user_id'] as String,
      wornAt: DateTime.parse(json['worn_at'] as String),
      caption: json['caption'] as String?,
      rating: (json['rating'] as num?)?.toInt(),
      imageType: json['image_type'] as String? ?? 'jpg',
      imageUrl: json['imageUrl'] as String?,
      linkedOutfitId: (json['outfit_id'] as num?)?.toInt(),
      linkedOutfitName: json['outfits'] != null
          ? (json['outfits'] as Map<String, dynamic>)['name'] as String?
          : null,
      linkedEventId: (json['event_id'] as num?)?.toInt(),
      linkedEventTitle: json['events'] != null
          ? (json['events'] as Map<String, dynamic>)['title'] as String?
          : null,
      occasionTagId: (json['occasion_tag_id'] as num?)?.toInt(),
      weatherTagId: (json['weather_tag_id'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      editedAt: DateTime.parse(json['edited_at'] as String),
    );
  }
}
