import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app_colors.dart';
import '../../../classes/classes.dart';

import 'edit_event_page.dart';
import 'add_event_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final _events = <CalendarEvent>[
    const CalendarEvent(
      day: '29',
      month: 'May',
      title: 'Client lunch',
      occasion: 'Smart casual',
      icon: Icons.restaurant_outlined,
    ),
    const CalendarEvent(
      day: '31',
      month: 'May',
      title: 'Gallery opening',
      occasion: 'Creative evening',
      icon: Icons.palette_outlined,
    ),
    const CalendarEvent(
      day: '03',
      month: 'Jun',
      title: 'Outdoor brunch',
      occasion: 'Relaxed daytime',
      icon: Icons.wb_sunny_outlined,
    ),
  ];

  Future<void> _editEvent(int index) async {
    final updated = await Navigator.of(context).push<CalendarEvent>(
      MaterialPageRoute(builder: (_) => EditEventPage(event: _events[index])),
    );
    if (updated != null && mounted) {
      setState(() => _events[index] = updated);
    }
  }

  Future<void> _addEvent() async {
    final event = await Navigator.of(context).push<CalendarEvent>(
      MaterialPageRoute(builder: (_) => const AddEventPage()),
    );
    if (event != null && mounted) {
      setState(() => _events.add(event));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Calendar',
      subtitle: 'Plan outfits around your week',
      trailing: IconButton.filledTonal(
        onPressed: _addEvent,
        icon: const Icon(Icons.add),
      ),
      children: _events.asMap().entries.map((entry) {
        final index = entry.key;
        final event = entry.value;
        return EventCard(
          day: event.day,
          month: event.month,
          title: event.title,
          occasion: event.occasion,
          icon: event.icon,
          onTap: () => _editEvent(index),
        );
      }).toList(),
    );
  }
}
