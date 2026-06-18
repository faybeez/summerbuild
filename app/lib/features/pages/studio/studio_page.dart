import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../app_colors.dart';
import '../../../classes/classes.dart';
import '../../../classes/clothing_tag.dart';
import '../../data/outfit_repository.dart';

class StudioPage extends StatefulWidget {
  const StudioPage({super.key, required this.outfitRepository});

  final OutfitRepository outfitRepository;

  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> {
  List<OutfitItem>? _outfits;
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadOutfits();
  }

  Future<void> _loadOutfits() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final result = await widget.outfitRepository.fetchPage();
      setState(() {
        _outfits = result.items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Studio',
      subtitle: 'Your outfit creations',
      children: [
        _BuildOptionsRow(
          onAIBuilder: () {
            context.push('/studio/add/ai');
          },
          onManualBuild: () {
            context.push('/studio/add/manual');
          },
        ),
        SectionHeader(
          title: 'Saved Outfits',
          actionLabel: 'View all',
          onPressed: () {},
        ),
        Transform.translate(
          offset: const Offset(0, -30),
          child: _loading
              ? const _OutfitsSkeletonGrid()
              : _hasError
              ? _OutfitsErrorState(onRetry: _loadOutfits)
              : (_outfits == null || _outfits!.isEmpty)
              ? const _OutfitsEmptyState()
              : _OutfitsGrid(outfits: _outfits!, onOutfitTap: (outfit) {}),
        ),
      ],
    );
  }
}

class _BuildOptionsRow extends StatelessWidget {
  final VoidCallback onAIBuilder;
  final VoidCallback onManualBuild;

  const _BuildOptionsRow({
    required this.onAIBuilder,
    required this.onManualBuild,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BuildCard(
            title: 'AI Builder',
            icon: Icons.auto_awesome_rounded,
            onTap: onAIBuilder,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BuildCard(
            title: 'Manual Build',
            icon: Icons.grid_view_rounded,
            onTap: onManualBuild,
          ),
        ),
      ],
    );
  }
}

class _BuildCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _BuildCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_BuildCard> createState() => _BuildCardState();
}

class _BuildCardState extends State<_BuildCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withOpacity(0.35)),
            boxShadow: [
              BoxShadow(
                color: AppColors.appEspresso.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.appChipBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, size: 22, color: AppColors.textMuted),
              ),
              const SizedBox(height: 14),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutfitsGrid extends StatelessWidget {
  final List<OutfitItem> outfits;
  final void Function(OutfitItem) onOutfitTap;

  const _OutfitsGrid({required this.outfits, required this.onOutfitTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.52,
      ),
      itemCount: outfits.length,
      itemBuilder: (context, index) => _OutfitCard(
        outfit: outfits[index],
        onTap: () => onOutfitTap(outfits[index]),
      ),
    );
  }
}

class _OutfitCard extends StatefulWidget {
  final OutfitItem outfit;
  final VoidCallback onTap;

  const _OutfitCard({required this.outfit, required this.onTap});

  @override
  State<_OutfitCard> createState() => _OutfitCardState();
}

class _OutfitCardState extends State<_OutfitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outfit = widget.outfit;
    final firstTag = outfit.tags
        .where((t) => t.tagType.toUpperCase() == 'OCCASION')
        .firstOrNull;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.appEspresso.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _OutfitCollage(photoUrls: outfit.imageUrls)),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ColorTagDots(tags: outfit.tags),
                    const SizedBox(height: 4),
                    Text(
                      outfit.name ?? '',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMain,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (firstTag != null) ...[
                      const SizedBox(height: 5),
                      _TagChip(label: firstTag.tagDisplayName),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutfitCollage extends StatelessWidget {
  final List<String?> photoUrls;

  const _OutfitCollage({required this.photoUrls});

  @override
  Widget build(BuildContext context) {
    final filtered = photoUrls.where((u) => u != null).toList();
    final count = filtered.isEmpty ? 0 : filtered.length;
    final rowCount = count == 0 ? 2 : (count / 2).ceil();

    return Column(
      children: List.generate(rowCount, (row) {
        final leftIndex = row * 2;
        final rightIndex = leftIndex + 1;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: _collageCell(
                  leftIndex < count ? filtered[leftIndex] : null,
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: _collageCell(
                  rightIndex < count ? filtered[rightIndex] : null,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _collageCell(String? url) {
    if (url == null) {
      return Container(color: AppColors.appWarmCream);
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => Container(color: AppColors.appWarmCream),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.appWarmCream,
        child: const Icon(
          Icons.image_not_supported_outlined,
          size: 16,
          color: AppColors.appTan,
        ),
      ),
    );
  }
}

class _ColorTagDots extends StatelessWidget {
  final List<ClothingTag> tags;
  const _ColorTagDots({required this.tags});

  @override
  Widget build(BuildContext context) {
    final colorTags = tags
        .where((t) => t.tagType.toUpperCase().contains('COLOR'))
        .take(5)
        .toList();

    if (colorTags.isEmpty) return const SizedBox(height: 9);

    return Row(
      children: colorTags
          .map(
            (t) => Padding(
              padding: const EdgeInsets.only(right: 3),
              child: t.tagWidget(size: 14, haveBorderColor: false),
            ),
          )
          .toList(),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: AppColors.appChipBg,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
          height: 1.5,
        ),
      ),
    );
  }
}

class _OutfitsSkeletonGrid extends StatelessWidget {
  const _OutfitsSkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.52,
      ),
      itemCount: 3,
      itemBuilder: (_, __) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: List.generate(
                2,
                (_) => Expanded(
                  child: Row(
                    children: [
                      Expanded(child: Container(color: AppColors.appWarmCream)),
                      const SizedBox(width: 1),
                      Expanded(child: Container(color: AppColors.appWarmCream)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    3,
                    (_) => Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: AppColors.appTan.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.appTan.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 48,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.appTan.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(99),
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

class _OutfitsErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _OutfitsErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 36,
              color: AppColors.appTan,
            ),
            const SizedBox(height: 12),
            const Text(
              'Couldn\'t load outfits',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Check your connection and try again.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.appEspresso,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.appCream,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutfitsEmptyState extends StatelessWidget {
  const _OutfitsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: const [
            Icon(Icons.style_outlined, size: 36, color: AppColors.appTan),
            SizedBox(height: 12),
            Text(
              'No outfits yet',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Build your first outfit to see it here.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
