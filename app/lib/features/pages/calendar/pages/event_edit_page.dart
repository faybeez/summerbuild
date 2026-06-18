import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:elytsx/app_colors.dart';
import 'package:elytsx/features/data/outfit_repository.dart';
import 'package:intl/intl.dart';

import '../data/calendar_repository.dart';
import '../models/calendar_event.dart';
import '../widgets/outfit_picker.dart';

class EventEditPage extends StatefulWidget {
  const EventEditPage({super.key, this.eventId, this.prefillDate});

  final int? eventId;
  final DateTime? prefillDate;

  @override
  State<EventEditPage> createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  late final CalendarRepository _repo;
  late final OutfitRepository _outfitRepo;

  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  DateTime _eventDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int? _linkedOutfitId;
  String? _linkedOutfitName;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isNew = true;
  CalendarEvent? _existing;

  @override
  void initState() {
    super.initState();
    _repo = CalendarRepository(Supabase.instance.client);
    _outfitRepo = OutfitRepository(Supabase.instance.client);
    if (widget.prefillDate != null) {
      _eventDate = widget.prefillDate!;
    }
    if (widget.eventId != null) {
      _isNew = false;
      _loadExisting();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    setState(() => _isLoading = true);
    try {
      final event = await _repo.fetchEventDetail(eventId: widget.eventId!);
      if (event != null && mounted) {
        _existing = event;
        _titleCtrl.text = event.title;
        _descCtrl.text = event.description ?? '';
        _locationCtrl.text = event.location ?? '';
        _eventDate = event.eventDate;
        _linkedOutfitId = event.linkedOutfitId;
        _linkedOutfitName = event.linkedOutfitName;
        if (event.startTime != null) {
          final parts = event.startTime!.split(':');
          if (parts.length >= 2) {
            _startTime = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? 0,
              minute: int.tryParse(parts[1]) ?? 0,
            );
          }
        }
        if (event.endTime != null) {
          final parts = event.endTime!.split(':');
          if (parts.length >= 2) {
            _endTime = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? 0,
              minute: int.tryParse(parts[1]) ?? 0,
            );
          }
        }
      }
    } catch (e) {
      _showError('Failed to load event: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    try {
      final startStr = _startTime != null
          ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
          : null;
      final endStr = _endTime != null
          ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
          : null;

      if (_isNew) {
        await _repo.createEvent(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          eventDate: _eventDate,
          startTime: startStr,
          endTime: endStr,
          location: _locationCtrl.text.trim().isEmpty
              ? null
              : _locationCtrl.text.trim(),
          linkedOutfitId: _linkedOutfitId,
        );
      } else {
        await _repo.updateEvent(
          eventId: widget.eventId!,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          eventDate: _eventDate,
          startTime: startStr,
          endTime: endStr,
          location: _locationCtrl.text.trim().isEmpty
              ? null
              : _locationCtrl.text.trim(),
          linkedOutfitId: _linkedOutfitId,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isNew ? 'Event created!' : 'Event updated!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      _showError('Save failed: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.appCard,
        title: const Text(
          'Delete Event',
          style: TextStyle(color: AppColors.textMain),
        ),
        content: const Text(
          'Are you sure you want to delete this event?',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          FilledButton(
            onPressed: () => ctx.pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() => _isSaving = true);
    try {
      await _repo.deleteEvent(eventId: widget.eventId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event deleted'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      _showError('Delete failed: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          _isNew ? 'New Event' : 'Edit Event',
          style: const TextStyle(
            color: AppColors.textMain,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (!_isNew)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _isSaving ? null : _delete,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Title *'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: _inputDecoration('Enter event title'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _sectionLabel('Description'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descCtrl,
                      decoration: _inputDecoration('Add a description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _sectionLabel('Date *'),
                    const SizedBox(height: 6),
                    _datePicker(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionLabel('Start time'),
                              const SizedBox(height: 6),
                              _timePicker(
                                time: _startTime,
                                hint: 'Pick time',
                                onPick: (t) => setState(() => _startTime = t),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionLabel('End time'),
                              const SizedBox(height: 6),
                              _timePicker(
                                time: _endTime,
                                hint: 'Pick time',
                                onPick: (t) => setState(() => _endTime = t),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionLabel('Location'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _locationCtrl,
                      decoration: _inputDecoration('Add a location'),
                    ),
                    const SizedBox(height: 20),
                    _sectionLabel('Linked Outfit (optional)'),
                    const SizedBox(height: 8),
                    OutfitPicker(
                      outfitRepository: _outfitRepo,
                      initialOutfitId: _linkedOutfitId,
                      onSelected: (outfit) {
                        setState(() {
                          _linkedOutfitId = outfit?.id;
                          _linkedOutfitName = outfit?.name;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    _saveButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textMuted,
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.appTan),
    filled: true,
    fillColor: AppColors.appCard,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );

  Widget _datePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _eventDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _eventDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.appCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 16,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('MMMM d, y').format(_eventDate),
              style: const TextStyle(fontSize: 14, color: AppColors.textMain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timePicker({
    required TimeOfDay? time,
    required String hint,
    required ValueChanged<TimeOfDay?> onPick,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          ),
        );
        onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.appCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.schedule, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              time != null ? time.format(context) : hint,
              style: TextStyle(
                fontSize: 13,
                color: time != null ? AppColors.textMain : AppColors.appTan,
              ),
            ),
            if (time != null) ...[
              const Spacer(),
              GestureDetector(
                onTap: () => onPick(null),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _isSaving ? null : _save,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                _isNew ? 'Create Event' : 'Save Changes',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }
}
