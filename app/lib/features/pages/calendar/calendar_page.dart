import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:elytsx/app_colors.dart';

import '../../data/calendar_repository.dart';
import 'state/calendar_controller.dart';
import 'widgets/calendar_month_view.dart';
import 'widgets/upcoming_event_card.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final CalendarController _controller;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController(
      CalendarRepository(Supabase.instance.client),
    );
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.loadMonth(DateTime.now());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: AppColors.textMain,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context
                .push('/calendar/ootd/new')
                .then((_) => _controller.refresh()),
            icon: const Icon(
              Icons.add_photo_alternate_outlined,
              size: 18,
              color: AppColors.appTerracotta,
            ),
            label: const Text(
              'OOTD',
              style: TextStyle(
                color: AppColors.appTerracotta,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => context
                .push('/calendar/event/new')
                .then((_) => _controller.refresh()),
            icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
            label: const Text(
              'Event',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _controller.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _controller.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.appCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.border.withOpacity(0.5),
                        ),
                      ),
                      child: CalendarMonthView(
                        focusedMonth: _controller.focusedMonth,
                        summaries: _controller.monthSummaries,
                        selectedDate: _selectedDate,
                        onDaySelected: (date) {
                          setState(() => _selectedDate = date);
                          context
                              .push('/calendar/day', extra: date)
                              .then((_) => _controller.refresh());
                        },
                        onPreviousMonth: () {
                          final prev = DateTime(
                            _controller.focusedMonth.year,
                            _controller.focusedMonth.month - 1,
                          );
                          _controller.goToMonth(prev);
                        },
                        onNextMonth: () {
                          final next = DateTime(
                            _controller.focusedMonth.year,
                            _controller.focusedMonth.month + 1,
                          );
                          _controller.goToMonth(next);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Upcoming Events',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMain,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context
                              .push('/calendar/event/new')
                              .then((_) => _controller.refresh()),
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
                    if (_controller.upcomingEvents.isEmpty)
                      _emptyState(
                        icon: Icons.event_outlined,
                        message: 'No upcoming events',
                        sub: 'Tap + Add Event to create one',
                      )
                    else
                      ...(_controller.upcomingEvents.map(
                        (e) => UpcomingEventCard(
                          event: e,
                          onTap: () => context
                              .push('/calendar/event/${e.id}/edit')
                              .then((_) => _controller.refresh()),
                        ),
                      )),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String message,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.appTan),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
