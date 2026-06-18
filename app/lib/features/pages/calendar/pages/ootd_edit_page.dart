import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:elytsx/app_colors.dart';
import 'package:elytsx/features/data/outfit_repository.dart';
import 'package:elytsx/features/data/wardrobe_repository.dart';
import 'package:elytsx/classes/clothing_tag.dart';
import 'package:intl/intl.dart';

import '../data/calendar_repository.dart';
import '../models/ootd_entry.dart';
import '../models/calendar_event.dart';
import '../widgets/outfit_picker.dart';
import '../widgets/wardrobe_piece_picker.dart';

class OotdEditPage extends StatefulWidget {
  const OotdEditPage({super.key, this.ootdId, this.prefillDate});

  final int? ootdId;
  final DateTime? prefillDate;

  @override
  State<OotdEditPage> createState() => _OotdEditPageState();
}

class _OotdEditPageState extends State<OotdEditPage> {
  late final CalendarRepository _repo;
  late final OutfitRepository _outfitRepo;
  late final WardrobeRepository _wardrobeRepo;

  final _captionCtrl = TextEditingController();

  DateTime _ootdDate = DateTime.now();
  File? _photoFile;
  String? _existingPhotoUrl;

  int? _linkedOutfitId;
  String? _linkedOutfitName;
  int? _linkedEventId;
  String? _linkedEventTitle;

  List<WardrobeClothingItem> _selectedPieces = [];
  List<CalendarEvent> _eventsOnDate = [];

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isNew = true;

  OotdEntry? _existing;

  // Tab state: 'outfit' | 'pieces' | 'none'
  String _linkMode = 'none';

  @override
  void initState() {
    super.initState();
    _repo = CalendarRepository(Supabase.instance.client);
    _outfitRepo = OutfitRepository(Supabase.instance.client);
    _wardrobeRepo = WardrobeRepository(Supabase.instance.client);
    if (widget.prefillDate != null) _ootdDate = widget.prefillDate!;
    if (widget.ootdId != null) {
      _isNew = false;
      _loadExisting();
    }
    _loadEventsOnDate();
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    setState(() => _isLoading = true);
    try {
      final ootd = await _repo.fetchOotdDetail(ootdId: widget.ootdId!);
      if (ootd != null && mounted) {
        _existing = ootd;
        _captionCtrl.text = ootd.caption ?? '';
        _ootdDate = ootd.wornAt;
        _existingPhotoUrl = ootd.imageUrl;
        _linkedOutfitId = ootd.linkedOutfitId;
        _linkedOutfitName = ootd.linkedOutfitName;
        _linkedEventId = ootd.linkedEventId;
        _linkedEventTitle = ootd.linkedEventTitle;
        if (_linkedOutfitId != null) _linkMode = 'outfit';
      }
    } catch (e) {
      _showError('Failed to load OOTD: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadEventsOnDate() async {
    try {
      final events = await _repo.fetchEventsForDate(date: _ootdDate);
      if (mounted) setState(() => _eventsOnDate = events);
    } catch (_) {}
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _photoFile = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (_isNew && _photoFile == null) {
      _showError('Please select a photo');
      return;
    }

    // If pieces selected, ask whether to create outfit
    if (_linkMode == 'pieces' && _selectedPieces.isNotEmpty) {
      final createOutfit = await _showCreateOutfitDialog();
      if (createOutfit == null) return; // cancelled
      if (createOutfit) {
        await _saveWithNewOutfit();
      } else {
        await _saveWithPiecesOnly();
      }
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (_isNew) {
        await _repo.createOotd(
          ootdDate: _ootdDate,
          caption: _captionCtrl.text.trim().isEmpty
              ? null
              : _captionCtrl.text.trim(),
          photoFile: _photoFile!,
          linkedOutfitId: _linkMode == 'outfit' ? _linkedOutfitId : null,
          linkedEventId: _linkedEventId,
        );
      } else {
        await _repo.updateOotd(
          ootdId: widget.ootdId!,
          ootdDate: _ootdDate,
          caption: _captionCtrl.text.trim().isEmpty
              ? null
              : _captionCtrl.text.trim(),
          replacementPhotoFile: _photoFile,
          linkedOutfitId: _linkMode == 'outfit' ? _linkedOutfitId : null,
          linkedEventId: _linkedEventId,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isNew ? 'OOTD saved!' : 'OOTD updated!'),
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

  Future<void> _saveWithNewOutfit() async {
    setState(() => _isSaving = true);
    try {
      final outfitName = _captionCtrl.text.trim().isNotEmpty
          ? _captionCtrl.text.trim()
          : 'OOTD ${DateFormat('MMM d, y').format(_ootdDate)}';

      final tagIds = _selectedPieces
          .expand(
            (p) => p.tags
                .where(
                  (t) => [
                    'OCCASION',
                    'WEATHER',
                    'COLOR',
                    'VIBE',
                  ].contains(t.tagType.toUpperCase()),
                )
                .map((t) => t.id),
          )
          .toSet()
          .toList();

      final outfitId = await _repo.createOutfitFromPieces(
        name: outfitName,
        clothesIds: _selectedPieces.map((p) => p.id).toList(),
        tagIds: tagIds,
      );

      if (_isNew) {
        await _repo.createOotd(
          ootdDate: _ootdDate,
          caption: _captionCtrl.text.trim().isEmpty
              ? null
              : _captionCtrl.text.trim(),
          photoFile: _photoFile!,
          linkedOutfitId: outfitId,
          linkedEventId: _linkedEventId,
        );
      } else {
        await _repo.updateOotd(
          ootdId: widget.ootdId!,
          ootdDate: _ootdDate,
          caption: _captionCtrl.text.trim().isEmpty
              ? null
              : _captionCtrl.text.trim(),
          replacementPhotoFile: _photoFile,
          linkedOutfitId: outfitId,
          linkedEventId: _linkedEventId,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Outfit created & OOTD saved!'),
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

  Future<void> _saveWithPiecesOnly() async {
    setState(() => _isSaving = true);
    try {
      if (_isNew) {
        await _repo.createOotd(
          ootdDate: _ootdDate,
          caption: _captionCtrl.text.trim().isEmpty
              ? null
              : _captionCtrl.text.trim(),
          photoFile: _photoFile!,
          linkedOutfitId: null,
          linkedEventId: _linkedEventId,
        );
      } else {
        await _repo.updateOotd(
          ootdId: widget.ootdId!,
          ootdDate: _ootdDate,
          caption: _captionCtrl.text.trim().isEmpty
              ? null
              : _captionCtrl.text.trim(),
          replacementPhotoFile: _photoFile,
          linkedOutfitId: null,
          linkedEventId: _linkedEventId,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isNew ? 'OOTD saved!' : 'OOTD updated!'),
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

  Future<bool?> _showCreateOutfitDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.appCard,
        title: const Text(
          'Create Outfit?',
          style: TextStyle(color: AppColors.textMain),
        ),
        content: const Text(
          'Would you like to create a new saved outfit from the selected wardrobe pieces?',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text(
              'No, just save pieces',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          FilledButton(
            onPressed: () => ctx.pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Yes, create outfit'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.appCard,
        title: const Text(
          'Delete OOTD',
          style: TextStyle(color: AppColors.textMain),
        ),
        content: const Text(
          'Are you sure you want to delete this OOTD entry?',
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
      await _repo.deleteOotd(ootdId: widget.ootdId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OOTD deleted'),
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
          _isNew ? 'Add OOTD' : 'Edit OOTD',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _photoSection(),
                  const SizedBox(height: 20),
                  _sectionLabel('Date *'),
                  const SizedBox(height: 6),
                  _datePicker(),
                  const SizedBox(height: 16),
                  _sectionLabel('Caption'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _captionCtrl,
                    decoration: _inputDecoration('e.g. "Casual Monday vibes"'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel('Link to Event (optional)'),
                  const SizedBox(height: 8),
                  _eventSelector(),
                  const SizedBox(height: 20),
                  _sectionLabel('Link to Outfit (optional)'),
                  const SizedBox(height: 8),
                  _linkModeSelector(),
                  const SizedBox(height: 8),
                  if (_linkMode == 'outfit') ...[
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
                  ],
                  if (_linkMode == 'pieces') ...[
                    WardrobePiecePicker(
                      wardrobeRepository: _wardrobeRepo,
                      onSelectionChanged: (pieces) =>
                          setState(() => _selectedPieces = pieces),
                    ),
                  ],
                  const SizedBox(height: 32),
                  _saveButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _photoSection() {
    final hasNew = _photoFile != null;
    final hasExisting = _existingPhotoUrl != null;

    return GestureDetector(
      onTap: _pickPhoto,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.appCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: hasNew
            ? ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.file(_photoFile!, fit: BoxFit.cover),
              )
            : hasExisting
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.network(_existingPhotoUrl!, fit: BoxFit.cover),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, size: 13, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Replace',
                            style: TextStyle(fontSize: 11, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 36,
                    color: AppColors.appTan,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to add photo',
                    style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _datePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _ootdDate,
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
        if (picked != null) {
          setState(() => _ootdDate = picked);
          _loadEventsOnDate();
        }
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
              DateFormat('MMMM d, y').format(_ootdDate),
              style: const TextStyle(fontSize: 14, color: AppColors.textMain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eventSelector() {
    if (_eventsOnDate.isEmpty) {
      return const Text(
        'No events on this date',
        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _eventChip(id: null, title: 'None'),
        ..._eventsOnDate.map((e) => _eventChip(id: e.id, title: e.title)),
      ],
    );
  }

  Widget _eventChip({required int? id, required String title}) {
    final isSelected = _linkedEventId == id;
    return GestureDetector(
      onTap: () => setState(() {
        _linkedEventId = id;
        _linkedEventTitle = id == null ? null : title;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.appEspresso : AppColors.appChipBg,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isSelected
                ? AppColors.appEspresso
                : AppColors.border.withOpacity(0.5),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : AppColors.textMain,
          ),
        ),
      ),
    );
  }

  Widget _linkModeSelector() {
    final modes = [
      ('none', 'None'),
      ('outfit', 'Saved Outfit'),
      ('pieces', 'Wardrobe Pieces'),
    ];

    return Row(
      children: modes.map((m) {
        final isSelected = _linkMode == m.$1;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _linkMode = m.$1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.appEspresso : AppColors.appChipBg,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isSelected
                      ? AppColors.appEspresso
                      : AppColors.border.withOpacity(0.5),
                ),
              ),
              child: Text(
                m.$2,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textMain,
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
                _isNew ? 'Save OOTD' : 'Save Changes',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
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

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }
}
