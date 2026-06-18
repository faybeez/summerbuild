import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/calendar_event.dart';
import '../models/calendar_day_summary.dart';
import '../models/ootd_entry.dart';

class CalendarRepository {
  CalendarRepository(this._supabase);

  final SupabaseClient _supabase;

  String get _userId {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) throw StateError('User not authenticated');
    return id;
  }

  // ─── Month Summary ──────────────────────────────────────────────────────────

  Future<List<CalendarDaySummary>> fetchMonthSummary({
    required DateTime month,
  }) async {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final startStr = _dateOnly(firstDay);
    final endStr = _dateOnly(lastDay);

    final eventsRes = await _supabase
        .from('events')
        .select('event_date')
        .eq('user_id', _userId)
        .gte('event_date', startStr)
        .lte('event_date', endStr);

    final ootdRes = await _supabase
        .from('ootd_entries')
        .select('id, worn_at')
        .eq('user_id', _userId)
        .gte('worn_at', startStr)
        .lte('worn_at', endStr);

    final eventRows = eventsRes as List;
    final ootdRows = ootdRes as List;

    final Map<String, int> eventCountByDate = {};
    for (final row in eventRows) {
      final d = row['event_date'] as String;
      eventCountByDate[d] = (eventCountByDate[d] ?? 0) + 1;
    }

    final Map<String, int> ootdIdByDate = {};
    for (final row in ootdRows) {
      final d = row['worn_at'] as String;
      if (!ootdIdByDate.containsKey(d)) {
        ootdIdByDate[d] = (row['id'] as num).toInt();
      }
    }

    final allDates = {
      ...eventCountByDate.keys,
      ...ootdIdByDate.keys,
    };

    return allDates.map((dateStr) {
      return CalendarDaySummary(
        date: DateTime.parse(dateStr),
        hasOotd: ootdIdByDate.containsKey(dateStr),
        hasEvents: (eventCountByDate[dateStr] ?? 0) > 0,
        eventCount: eventCountByDate[dateStr] ?? 0,
        ootdId: ootdIdByDate[dateStr],
      );
    }).toList();
  }

  // ─── Events ─────────────────────────────────────────────────────────────────

  Future<List<CalendarEvent>> fetchUpcomingEvents({int limit = 10}) async {
    final today = _dateOnly(DateTime.now());
    final res = await _supabase
        .from('events')
        .select('*, outfits(name)')
        .eq('user_id', _userId)
        .gte('event_date', today)
        .order('event_date')
        .order('start_time', nullsFirst: false)
        .limit(limit);

    return (res as List)
        .map((r) => CalendarEvent.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<CalendarEvent>> fetchEventsForDate({
    required DateTime date,
  }) async {
    final dateStr = _dateOnly(date);
    final res = await _supabase
        .from('events')
        .select('*, outfits(name)')
        .eq('user_id', _userId)
        .eq('event_date', dateStr)
        .order('start_time', nullsFirst: true);

    return (res as List)
        .map((r) => CalendarEvent.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<CalendarEvent?> fetchEventDetail({required int eventId}) async {
    final res = await _supabase
        .from('events')
        .select('*, outfits(name)')
        .eq('id', eventId)
        .eq('user_id', _userId)
        .limit(1);

    final rows = res as List;
    if (rows.isEmpty) return null;
    return CalendarEvent.fromJson(rows.first as Map<String, dynamic>);
  }

  Future<CalendarEvent> createEvent({
    required String title,
    String? description,
    required DateTime eventDate,
    String? startTime,
    String? endTime,
    String? location,
    int? linkedOutfitId,
  }) async {
    final payload = {
      'user_id': _userId,
      'title': title,
      if (description != null) 'description': description,
      'event_date': _dateOnly(eventDate),
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (location != null) 'location': location,
      'outfit_id': linkedOutfitId,
    };

    final res = await _supabase
        .from('events')
        .insert(payload)
        .select('*, outfits(name)')
        .single();

    return CalendarEvent.fromJson(res as Map<String, dynamic>);
  }

  Future<CalendarEvent> updateEvent({
    required int eventId,
    required String title,
    String? description,
    required DateTime eventDate,
    String? startTime,
    String? endTime,
    String? location,
    int? linkedOutfitId,
  }) async {
    final payload = {
      'title': title,
      'description': description,
      'event_date': _dateOnly(eventDate),
      'start_time': startTime,
      'end_time': endTime,
      'location': location,
      'outfit_id': linkedOutfitId,
      'edited_at': DateTime.now().toIso8601String(),
    };

    final res = await _supabase
        .from('events')
        .update(payload)
        .eq('id', eventId)
        .eq('user_id', _userId)
        .select('*, outfits(name)')
        .single();

    return CalendarEvent.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deleteEvent({required int eventId}) async {
    await _supabase
        .from('events')
        .delete()
        .eq('id', eventId)
        .eq('user_id', _userId);
  }

  // ─── OOTD ────────────────────────────────────────────────────────────────────

  Future<OotdEntry?> fetchOotdForDate({required DateTime date}) async {
    final dateStr = _dateOnly(date);
    final res = await _supabase
        .from('ootd_entries')
        .select('*, outfits(name), events(title)')
        .eq('user_id', _userId)
        .eq('worn_at', dateStr)
        .limit(1);

    final rows = res as List;
    if (rows.isEmpty) return null;

    final row = rows.first as Map<String, dynamic>;
    final imageUrl = await _buildOotdImageUrl(
      userId: _userId,
      ootdId: (row['id'] as num).toInt(),
      imageType: row['image_type'] as String? ?? 'jpg',
    );
    row['imageUrl'] = imageUrl;
    return OotdEntry.fromJson(row);
  }

  Future<OotdEntry?> fetchOotdDetail({required int ootdId}) async {
    final res = await _supabase
        .from('ootd_entries')
        .select('*, outfits(name), events(title)')
        .eq('id', ootdId)
        .eq('user_id', _userId)
        .limit(1);

    final rows = res as List;
    if (rows.isEmpty) return null;

    final row = rows.first as Map<String, dynamic>;
    final imageUrl = await _buildOotdImageUrl(
      userId: _userId,
      ootdId: ootdId,
      imageType: row['image_type'] as String? ?? 'jpg',
    );
    row['imageUrl'] = imageUrl;
    return OotdEntry.fromJson(row);
  }

  Future<OotdEntry> createOotd({
    required DateTime ootdDate,
    String? caption,
    int? rating,
    required dynamic photoFile,
    int? linkedOutfitId,
    int? linkedEventId,
    int? occasionTagId,
    int? weatherTagId,
  }) async {
    // 1. Insert row to get ID
    final payload = {
      'user_id': _userId,
      'worn_at': _dateOnly(ootdDate),
      if (caption != null) 'caption': caption,
      if (rating != null) 'rating': rating,
      'outfit_id': linkedOutfitId,
      'event_id': linkedEventId,
      'image_type': _inferImageType(photoFile),
      if (occasionTagId != null) 'occasion_tag_id': occasionTagId,
      if (weatherTagId != null) 'weather_tag_id': weatherTagId,
    };

    final row = await _supabase
        .from('ootd_entries')
        .insert(payload)
        .select()
        .single();

    final ootdId = (row['id'] as num).toInt();
    final imageType = row['image_type'] as String;

    // 2. Upload photo
    final path = '$_userId/$ootdId.$imageType';
    await _uploadOotdFile(photoFile: photoFile, path: path);

    // 3. Return with signed URL
    final imageUrl = await _buildOotdImageUrl(
      userId: _userId,
      ootdId: ootdId,
      imageType: imageType,
    );
    final fullRow = Map<String, dynamic>.from(row as Map<String, dynamic>);
    fullRow['imageUrl'] = imageUrl;
    return OotdEntry.fromJson(fullRow);
  }

  Future<OotdEntry> updateOotd({
    required int ootdId,
    required DateTime ootdDate,
    String? caption,
    int? rating,
    dynamic replacementPhotoFile,
    int? linkedOutfitId,
    int? linkedEventId,
    int? occasionTagId,
    int? weatherTagId,
  }) async {
    String? newImageType;

    if (replacementPhotoFile != null) {
      // Determine new image type
      newImageType = _inferImageType(replacementPhotoFile);

      // Delete old storage object
      final existing = await _supabase
          .from('ootd_entries')
          .select('image_type')
          .eq('id', ootdId)
          .eq('user_id', _userId)
          .limit(1);

      final existingRows = existing as List;
      if (existingRows.isNotEmpty) {
        final oldType = existingRows.first['image_type'] as String? ?? 'jpg';
        final oldPath = '$_userId/$ootdId.$oldType';
        try {
          await _supabase.storage.from('ootd_images').remove([oldPath]);
        } catch (e) {
          debugPrint('updateOotd: old storage delete failed (non-fatal): $e');
        }
      }

      // Upload new photo
      final newPath = '$_userId/$ootdId.$newImageType';
      await _uploadOotdFile(
          photoFile: replacementPhotoFile, path: newPath);
    }

    final updatePayload = {
      'worn_at': _dateOnly(ootdDate),
      'caption': caption,
      'rating': rating,
      'outfit_id': linkedOutfitId,
      'event_id': linkedEventId,
      'occasion_tag_id': occasionTagId,
      'weather_tag_id': weatherTagId,
      'edited_at': DateTime.now().toIso8601String(),
      if (newImageType != null) 'image_type': newImageType,
    };

    final row = await _supabase
        .from('ootd_entries')
        .update(updatePayload)
        .eq('id', ootdId)
        .eq('user_id', _userId)
        .select('*, outfits(name), events(title)')
        .single();

    final imageUrl = await _buildOotdImageUrl(
      userId: _userId,
      ootdId: ootdId,
      imageType: row['image_type'] as String? ?? 'jpg',
    );
    final fullRow = Map<String, dynamic>.from(row as Map<String, dynamic>);
    fullRow['imageUrl'] = imageUrl;
    return OotdEntry.fromJson(fullRow);
  }

  Future<void> deleteOotd({required int ootdId}) async {
    final existing = await _supabase
        .from('ootd_entries')
        .select('image_type')
        .eq('id', ootdId)
        .eq('user_id', _userId)
        .limit(1);

    final existingRows = existing as List;
    if (existingRows.isNotEmpty) {
      final imageType = existingRows.first['image_type'] as String? ?? 'jpg';
      final path = '$_userId/$ootdId.$imageType';
      try {
        await _supabase.storage.from('ootd_images').remove([path]);
      } catch (e) {
        debugPrint('deleteOotd: storage delete failed (non-fatal): $e');
      }
    }

    await _supabase
        .from('ootd_entries')
        .delete()
        .eq('id', ootdId)
        .eq('user_id', _userId);
  }

  // ─── Outfit helpers ─────────────────────────────────────────────────────────

  Future<int> createOutfitFromPieces({
    required String name,
    String? description,
    required List<int> clothesIds,
    List<int> tagIds = const [],
  }) async {
    // Insert outfit
    final outfitRow = await _supabase
        .from('outfits')
        .insert({
          'user_id': _userId,
          'name': name,
          if (description != null) 'description': description,
        })
        .select()
        .single();

    final outfitId = (outfitRow['id'] as num).toInt();

    // Link clothes
    if (clothesIds.isNotEmpty) {
      final clothesPayload = clothesIds.asMap().entries.map((e) => {
            'outfit_id': outfitId,
            'clothes_id': e.value,
            'slot': 'OUTFIT',
            'sort_order': e.key,
          }).toList();
      await _supabase.from('outfit_clothes').insert(clothesPayload);
    }

    // Link tags (deduplicated)
    if (tagIds.isNotEmpty) {
      final uniqueTagIds = tagIds.toSet().toList();
      final tagsPayload = uniqueTagIds
          .map((tid) => {'outfit_id': outfitId, 'tag_id': tid})
          .toList();
      await _supabase.from('outfits_tags').insert(tagsPayload);
    }

    return outfitId;
  }

  // ─── Private helpers ────────────────────────────────────────────────────────

  String _dateOnly(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  String _inferImageType(dynamic file) {
    if (file is File) {
      final ext = file.path.split('.').last.toLowerCase();
      return ext.isNotEmpty ? ext : 'jpg';
    }
    return 'jpg';
  }

  Future<void> _uploadOotdFile({
    required dynamic photoFile,
    required String path,
  }) async {
    if (photoFile is File) {
      final bytes = await photoFile.readAsBytes();
      await _supabase.storage.from('ootd_images').uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/${path.split('.').last}',
              upsert: true,
            ),
          );
    }
  }

  Future<String?> _buildOotdImageUrl({
    required String userId,
    required int ootdId,
    required String imageType,
  }) async {
    final path = '$userId/$ootdId.$imageType';
    try {
      final result = await _supabase.storage
          .from('ootd_images')
          .createSignedUrls([path], 3600);
      return result.where((s) => s.signedUrl != null).map((s) => s.signedUrl!).firstOrNull;
    } catch (e) {
      debugPrint('_buildOotdImageUrl failed (non-fatal): $e');
      return null;
    }
  }
}
