// lib/features/pages/wardrobe/wardrobe_detail_page.dart
//
// Replaces the old stub that used the (now-removed) WardrobeItem model.
// Accepts a clothesId from the GoRouter path parameter,
// loads via WardrobeRepository.fetchClothingDetail, and shows full detail
// with delete support.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app_colors.dart';
import '../../../functions.dart';
import '../../data/wardrobe_repository.dart';

class WardrobeDetailPage extends StatefulWidget {
  const WardrobeDetailPage({super.key, required this.clothesId});

  final int clothesId;

  @override
  State<WardrobeDetailPage> createState() => _WardrobeDetailPageState();
}

class _WardrobeDetailPageState extends State<WardrobeDetailPage> {
  late final WardrobeRepository _repo;

  WardrobeClothingItem? _item;
  bool _loading = true;
  String? _error;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _repo = WardrobeRepository(Supabase.instance.client);
    _loadItem();
  }

  Future<void> _loadItem() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final item = await _repo.fetchClothingDetail(widget.clothesId);
      if (mounted) setState(() => _item = item);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────
  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.appCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete item?',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.appEspresso,
          ),
        ),
        content: const Text(
          'This will permanently remove the clothing item and its image. This action cannot be undone.',
          style: TextStyle(color: AppColors.appOlive),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.appEspresso.withAlpha(160)),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    _deleteItem();
  }

  Future<void> _deleteItem() async {
    setState(() => _deleting = true);
    try {
      await _repo.deleteClothingItem(widget.clothesId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item deleted successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      context.pop(true); // signal WardrobePage to refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.appEspresso,
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Item Detail',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.appEspresso,
          ),
        ),
        actions: [
          if (!_loading && _item != null)
            _deleting
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.error,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: AppColors.error,
                    tooltip: 'Delete item',
                    onPressed: () => _confirmDelete(context),
                  ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const _DetailSkeleton();

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: AppColors.appTan,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load item',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.appEspresso,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.appOlive),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadItem,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.appEspresso,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_item == null) {
      return const Center(
        child: Text(
          'Item not found',
          style: TextStyle(color: AppColors.appOlive),
        ),
      );
    }

    return _DetailContent(item: _item!);
  }
}

// ─── Detail content ───────────────────────────────────────────────────────────

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.item});
  final WardrobeClothingItem item;

  @override
  Widget build(BuildContext context) {
    final colorTags = item.colorTags;
    final occasionTags = item.occasionTags;
    final weatherTags = item.weatherTags;
    final addedDate = _formatDate(item.createdAt);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero image ───────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: item.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => Container(
                        color: AppColors.appWarmCream,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.appTan,
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.appWarmCream,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.appTan,
                            size: 48,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.appWarmCream,
                      child: const Center(
                        child: Icon(
                          Icons.checkroom_outlined,
                          color: AppColors.appTan,
                          size: 64,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Category ─────────────────────────────────────────────────
          if (item.category != null) ...[
            _SectionLabel('Category'),
            const SizedBox(height: 8),
            _TagChip(label: item.category!.tagDisplayName),
            const SizedBox(height: 20),
          ],

          // ── Colors ───────────────────────────────────────────────────
          if (colorTags.isNotEmpty) ...[
            _SectionLabel('Colors'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: colorTags
                  .map((t) => _TagChip(label: t.tagDisplayName))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],

          // ── Occasion ─────────────────────────────────────────────────
          if (occasionTags.isNotEmpty) ...[
            _SectionLabel('Occasion'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: occasionTags
                  .map((t) => _TagChip(label: t.tagDisplayName))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],

          // ── Weather ──────────────────────────────────────────────────
          if (weatherTags.isNotEmpty) ...[
            _SectionLabel('Weather'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: weatherTags
                  .map((t) => _TagChip(label: t.tagDisplayName))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],

          // ── Stats row ─────────────────────────────────────────────────
          Row(
            children: [
              if (item.cost > 0)
                Expanded(
                  child: _StatCard(
                    icon: Icons.attach_money_rounded,
                    label: 'Cost',
                    value: '\$${item.cost.toStringAsFixed(2)}',
                  ),
                ),
              if (item.cost > 0) const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.repeat_rounded,
                  label: 'Times worn',
                  value: '${item.timesWorn}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Date ─────────────────────────────────────────────────────
          if (addedDate != null)
            Text(
              'Added $addedDate',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.appEspresso.withAlpha(100),
              ),
            ),
        ],
      ),
    );
  }

  String? _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return null;
    }
  }
}

// ─── Small reusable widgets ───────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.appEspresso.withAlpha(140),
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.appChipBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.appTan.withAlpha(100)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.appEspresso,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(AppColors.appCard),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.appWarmCream,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.appEspresso),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.appEspresso.withAlpha(140),
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.appEspresso,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Loading skeleton ─────────────────────────────────────────────────────────

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          Container(
            width: double.infinity,
            height: 320,
            decoration: BoxDecoration(
              color: AppColors.appWarmCream,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 20),
          // Label skeleton
          Container(
            width: 80,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.appWarmCream,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 10),
          // Chips skeleton
          Wrap(
            spacing: 8,
            children: List.generate(
              3,
              (_) => Container(
                width: 70,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.appWarmCream,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.appWarmCream,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.appWarmCream,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
