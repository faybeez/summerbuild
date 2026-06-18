import 'dart:io';

import 'package:flutter/material.dart';

import '../../../classes/classes.dart';

class EditEventPage extends StatefulWidget {
  const EditEventPage({required this.event, super.key});

  final CalendarEvent event;

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  late final _dayController = TextEditingController(text: widget.event.day);
  late final _monthController = TextEditingController(text: widget.event.month);
  late final _titleController = TextEditingController(text: widget.event.title);
  late final _occasionController = TextEditingController(
    text: widget.event.occasion,
  );
  late IconData _icon = widget.event.icon;

  static const _iconChoices = {
    'Restaurant': Icons.restaurant_outlined,
    'Palette': Icons.palette_outlined,
    'Sunny': Icons.wb_sunny_outlined,
    'Work': Icons.work_outline,
    'Celebration': Icons.celebration_outlined,
    'Flight': Icons.flight_outlined,
    'Music': Icons.music_note_outlined,
    'Fitness': Icons.fitness_center_outlined,
    'Coffee': Icons.coffee_outlined,
    'Shopping': Icons.shopping_bag_outlined,
  };

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _titleController.dispose();
    _occasionController.dispose();
    super.dispose();
  }

  void _save() {
    final day = _dayController.text.trim();
    final month = _monthController.text.trim();
    final title = _titleController.text.trim();
    final occasion = _occasionController.text.trim();

    if (day.isEmpty || month.isEmpty || title.isEmpty) return;

    final updated = CalendarEvent(
      day: day,
      month: month,
      title: title,
      occasion: occasion,
      icon: _icon,
    );
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    String? selectedIconLabel;
    for (final entry in _iconChoices.entries) {
      if (entry.value == _icon) {
        selectedIconLabel = entry.key;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit event'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _save)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dayController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Day',
                      hintText: '29',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    controller: _monthController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      hintText: 'May',
                      prefixIcon: Icon(Icons.event),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Client lunch',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _occasionController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Occasion',
                hintText: 'e.g. Smart casual',
                prefixIcon: Icon(Icons.style),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: selectedIconLabel,
              decoration: const InputDecoration(
                labelText: 'Icon',
                prefixIcon: Icon(Icons.emoji_events_outlined),
              ),
              items: _iconChoices.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Row(
                    children: [
                      Icon(entry.value, size: 20),
                      const SizedBox(width: 10),
                      Text(entry.key),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _icon = _iconChoices[value]!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
