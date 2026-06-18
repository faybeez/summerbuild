import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:elytsx/app_colors.dart';
import 'package:intl/intl.dart';

import '../../data/calendar_repository.dart';
import '../../../classes/calendar_event.dart';
import '../../../classes/ootd_entry.dart';
import 'widgets/ootd_card.dart';

class CalendarDayRecapPage extends StatefulWidget {
  const CalendarDayRecapPage({super.key, required this.date});

  final DateTime date;

  @override
  State<CalendarDayRecapPage> createState() => _CalendarDayRecapPageState();
}

class _CalendarDayRecapPageState extends State<CalendarDayRecapPage> {
  late final CalendarRepository _repo;
  OotdEntry? _ootd;
  List<CalendarEvent> _events = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = CalendarRepository(Supabase.instance.client);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _repo.fetchOotdForDate(date: widget.date),
        _repo.fetchEventsForDate(date: widget.date),
      ]);
      if (mounted) {
        setState(() {
          _ootd = results[0] as OotdEntry?;
          _events = results[1] as List<CalendarEvent>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEEE, MMMM d, y').format(widget.date);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
          onPressed: () => context.pop(),
        ),
        title: Text(
          dateLabel,
          style: const TextStyle(
            color: AppColors.textMain,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
          ? Center(
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.error),
              ),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ootdSection(),
                    const SizedBox(height: 24),
                    _eventsSection(),
                    if (_ootd == null && _events.isEmpty) _emptyState(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _ootdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Outfit of the Day',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            if (_ootd == null)
              TextButton(
                onPressed: _navigateToAddOotd,
                child: const Text(
                  '+ Add OOTD',
                  style: TextStyle(
                    color: AppColors.appTerracotta,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_ootd != null)
          OotdCard(
            ootd: _ootd!,
            onEdit: () => context
                .push('/calendar/ootd/${_ootd!.id}/edit')
                .then((_) => _load()),
          )
        else
          _placeholder(
            icon: Icons.add_photo_alternate_outlined,
            message: 'No OOTD yet for this day',
          ),
      ],
    );
  }

  Widget _eventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Events',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            TextButton(
              onPressed: _navigateToAddEvent,
              child: const Text(
                '+ Add Event',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_events.isEmpty)
          _placeholder(
            icon: Icons.event_outlined,
            message: 'No events for this day',
          )
        else
          ..._events.map((event) => _eventCard(event)),
      ],
    );
  }

  Widget _eventCard(CalendarEvent event) {
    return GestureDetector(
      onTap: () =>
          context.push('/calendar/event/${event.id}/edit').then((_) => _load()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.appCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                  if (event.startTime != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.endTime != null
                          ? '${event.startTime} – ${event.endTime}'
                          : event.startTime!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                  if (event.location != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (event.linkedOutfitName != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.checkroom,
                          size: 12,
                          color: AppColors.appTerracotta,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.linkedOutfitName!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.appTerracotta,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 44,
              color: AppColors.appTan,
            ),
            const SizedBox(height: 12),
            const Text(
              'Nothing here yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add an event or OOTD for this day',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder({required IconData icon, required String message}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.appCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: AppColors.appTan),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _navigateToAddOotd,
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                label: const Text('Add OOTD'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.appTerracotta,
                  side: const BorderSide(color: AppColors.appTerracotta),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: _navigateToAddEvent,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Event'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddEvent() {
    context
        .push('/calendar/event/new', extra: widget.date)
        .then((_) => _load());
  }

  void _navigateToAddOotd() {
    context.push('/calendar/ootd/new', extra: widget.date).then((_) => _load());
  }
}
