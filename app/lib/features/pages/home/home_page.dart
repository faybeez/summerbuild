// lib/features/home/pages/home_page.dart
//
// CHANGED: Replaced the static "Recommended Outfits" section with a
// live "Wardrobe Statistics" dashboard.  Everything else (AppPage shell,
// ForecastCard, weather fetch) is preserved unchanged.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app_colors.dart';
import '../../../classes/classes.dart';
import '../../services/weather_service.dart';

// Statistics feature
import './data/wardrobe_statistics_repository.dart';
import './models/wardrobe_statistics.dart';
import './models/wardrobe_usage_stat.dart';
import './models/wardrobe_value_stat.dart';
import './widgets/clothing_usage_row.dart';
import './widgets/color_ratio_card.dart';
import './widgets/cost_per_wear_row.dart';
import './widgets/empty_stat_card.dart';
import './widgets/outfit_usage_row.dart';
import './widgets/wardrobe_stat_summary_card.dart';
import './widgets/wardrobe_statistics_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  // ── weather (unchanged) ────────────────────────────────────────────────────
  Map<String, dynamic>? _weather;

  // ── statistics ────────────────────────────────────────────────────────────
  late final WardrobeStatisticsRepository _statsRepo;
  WardrobeStatistics? _stats;
  bool _statsLoading = true;
  String? _statsError;

  @override
  bool get wantKeepAlive => false; // allow refresh when navigating back

  @override
  void initState() {
    super.initState();
    _statsRepo = WardrobeStatisticsRepository(Supabase.instance.client);
    _fetchWeather();
    _fetchStats();
  }

  // ── Fetch weather (unchanged) ─────────────────────────────────────────────
  Future<void> _fetchWeather() async {
    try {
      final result = await WeatherService().fetchWeather();
      if (mounted) setState(() => _weather = result);
    } catch (_) {
      if (mounted) setState(() => _weather = {'error': true});
    }
  }

  // ── Fetch statistics ──────────────────────────────────────────────────────
  Future<void> _fetchStats() async {
    if (!mounted) return;
    setState(() {
      _statsLoading = true;
      _statsError = null;
    });
    try {
      final stats = await _statsRepo.fetchWardrobeStatistics();
      if (mounted)
        setState(() {
          _stats = stats;
          _statsLoading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _statsError = e.toString();
          _statsLoading = false;
        });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AppPage(
      title: 'Today',
      subtitle: _weather?['area'] as String? ?? 'Loading area...',
      children: [
        // Weather card — unchanged
        ForecastCard(
          forecast: _weather?['forecast'] as String?,
          temperature: (_weather?['temperature'] as num?)?.toDouble(),
          humidity: (_weather?['humidity'] as num?)?.toDouble(),
        ),

        // ── Statistics Dashboard ──────────────────────────────────────────
        if (_statsLoading)
          const _StatsSkeleton()
        else if (_statsError != null)
          _StatsError(message: _statsError!, onRetry: _fetchStats)
        else if (_stats != null)
          _StatsDashboard(stats: _stats!, onRefresh: _fetchStats),
      ],
    );
  }
}

// ─── Loading skeleton ─────────────────────────────────────────────────────────

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary grid skeleton
        _SkeletonBox(height: 82),
        const SizedBox(height: 14),
        _SkeletonBox(height: 160),
        const SizedBox(height: 14),
        _SkeletonBox(height: 140),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  const _SkeletonBox({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.appCard,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// ─── Error state ──────────────────────────────────────────────────────────────

class _StatsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _StatsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.appCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.appTerracotta.withAlpha(180),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Could not load statistics.',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.appEspresso.withAlpha(130),
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ─── Main Dashboard ───────────────────────────────────────────────────────────

class _StatsDashboard extends StatelessWidget {
  final WardrobeStatistics stats;
  final VoidCallback onRefresh;

  const _StatsDashboard({required this.stats, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header with refresh ────────────────────────────────────
        SectionHeader(
          title: 'Wardrobe Stats',
          actionLabel: 'Refresh',
          onPressed: onRefresh,
        ),

        // ── Summary grid (2×2) ─────────────────────────────────────────────
        _SummaryGrid(stats: stats),
        const SizedBox(height: 14),

        // ── Secondary summary row (utilisation + favorites) ────────────────
        if (stats.totalItems > 0) ...[
          _SecondaryRow(stats: stats),
          const SizedBox(height: 14),
        ],

        // ── Color Ratio ────────────────────────────────────────────────────
        if (stats.colorRatio.isNotEmpty) ...[
          WardrobeStatisticsSection(
            title: 'Colour Palette',
            subtitle: '${stats.colorRatio.length} colours in your wardrobe',
            child: ColorRatioCard(colors: stats.colorRatio),
          ),
          const SizedBox(height: 14),
        ],

        // ── Most Used Outfits ──────────────────────────────────────────────
        WardrobeStatisticsSection(
          title: 'Most Worn Outfits',
          subtitle: 'Based on your OOTD entries',
          child: stats.mostUsedOutfits.isEmpty
              ? const EmptyStatCard(
                  message:
                      'Log your outfits in OOTD to see which ones you reach for most.',
                )
              : _OutfitUsageList(items: stats.mostUsedOutfits),
        ),
        const SizedBox(height: 14),

        // ── Most Used Clothes ──────────────────────────────────────────────
        WardrobeStatisticsSection(
          title: 'Most Worn Pieces',
          subtitle: 'Sorted by times worn',
          child:
              stats.mostUsedClothes.isEmpty ||
                  stats.mostUsedClothes.every((c) => c.timesWorn == 0)
              ? const EmptyStatCard(
                  message:
                      'Update the wear count on your clothes to see stats here.',
                )
              : _ClothingUsageList(items: stats.mostUsedClothes),
        ),
        const SizedBox(height: 14),

        // ── Best Value ─────────────────────────────────────────────────────
        if (stats.bestValueClothes.isNotEmpty) ...[
          WardrobeStatisticsSection(
            title: 'Best Value Pieces',
            subtitle: 'Lowest cost per wear',
            child: _CostPerWearList(items: stats.bestValueClothes),
          ),
          const SizedBox(height: 14),
        ],

        // ── Needs More Wear ────────────────────────────────────────────────
        if (stats.needsMoreWear.isNotEmpty) ...[
          WardrobeStatisticsSection(
            title: 'Needs More Wear',
            subtitle: 'Paid for but never worn',
            child: _CostPerWearList(items: stats.needsMoreWear),
          ),
          const SizedBox(height: 14),
        ],

        // ── High Cost Low Usage ────────────────────────────────────────────
        if (stats.highCostLowUsage.isNotEmpty) ...[
          WardrobeStatisticsSection(
            title: 'High Cost, Low Use',
            subtitle: 'Items to get more value from',
            child: _CostPerWearList(items: stats.highCostLowUsage),
          ),
          const SizedBox(height: 14),
        ],

        // ── Recently Added ─────────────────────────────────────────────────
        if (stats.recentlyAdded.isNotEmpty) ...[
          WardrobeStatisticsSection(
            title: 'Recently Added',
            child: _ClothingUsageList(items: stats.recentlyAdded),
          ),
          const SizedBox(height: 14),
        ],

        // ── Tag Insights row ───────────────────────────────────────────────
        _TagInsightsRow(stats: stats),
      ],
    );
  }
}

// ─── Summary 2×2 Grid ─────────────────────────────────────────────────────────

class _SummaryGrid extends StatelessWidget {
  final WardrobeStatistics stats;
  const _SummaryGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final avgLabel = stats.averageCostPerItem != null
        ? '\$${stats.averageCostPerItem!.toStringAsFixed(2)}'
        : '—';
    final totalCostLabel = stats.totalWardrobeCost > 0
        ? '\$${stats.totalWardrobeCost.toStringAsFixed(2)}'
        : '—';

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        WardrobeStatSummaryCard(
          label: 'Total Items',
          value: '${stats.totalItems}',
          icon: Icons.checkroom_outlined,
          accentColor: AppColors.appTerracotta,
        ),
        WardrobeStatSummaryCard(
          label: 'Total Outfits',
          value: '${stats.totalOutfits}',
          icon: Icons.style_outlined,
          accentColor: AppColors.appOlive,
        ),
        WardrobeStatSummaryCard(
          label: 'Wardrobe Value',
          value: totalCostLabel,
          icon: Icons.attach_money_outlined,
          accentColor: AppColors.appEspresso,
        ),
        WardrobeStatSummaryCard(
          label: 'Avg Cost / Item',
          value: avgLabel,
          icon: Icons.trending_down_outlined,
          accentColor: AppColors.appTan,
        ),
      ],
    );
  }
}

// ─── Secondary row (utilisation + favorites + unworn) ─────────────────────────

class _SecondaryRow extends StatelessWidget {
  final WardrobeStatistics stats;
  const _SecondaryRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final utilPct = stats.utilizationRate != null
        ? '${(stats.utilizationRate! * 100).toStringAsFixed(0)}%'
        : '—';

    return Row(
      children: [
        Expanded(
          child: _MiniStatTile(
            icon: Icons.pie_chart_outline,
            label: 'Utilisation',
            value: utilPct,
            accent: AppColors.appOlive,
            progress: stats.utilizationRate,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStatTile(
            icon: Icons.favorite_outline,
            label: 'Favourites',
            value: '${stats.favoriteCount}',
            accent: AppColors.appTerracotta,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStatTile(
            icon: Icons.do_not_disturb_alt_outlined,
            label: 'Unworn',
            value: '${stats.unwornCount}',
            accent: AppColors.appTan,
          ),
        ),
      ],
    );
  }
}

class _MiniStatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final double? progress;

  const _MiniStatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.appCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.appEspresso.withAlpha(130),
              fontSize: 10,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: AppColors.appEspresso.withAlpha(20),
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Tag Insights Row ─────────────────────────────────────────────────────────

class _TagInsightsRow extends StatelessWidget {
  final WardrobeStatistics stats;
  const _TagInsightsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = <Map<String, String?>>[
      {'label': 'Top Category', 'value': stats.mostCommonCategory},
      {'label': 'Top Occasion', 'value': stats.mostCommonOccasion},
      {'label': 'Top Weather', 'value': stats.mostCommonWeather},
    ].where((m) => m['value'] != null).toList();

    if (items.isEmpty) return const SizedBox.shrink();

    return Row(
      children: items.asMap().entries.map((entry) {
        final i = entry.key;
        final m = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.appCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m['label']!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.appEspresso.withAlpha(120),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    m['value']!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── List helpers ─────────────────────────────────────────────────────────────

class _ClothingUsageList extends StatelessWidget {
  final List<WardrobeUsageStat> items;
  const _ClothingUsageList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.appCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          return ClothingUsageRow(stat: e.value, rank: e.key + 1);
        }).toList(),
      ),
    );
  }
}

class _OutfitUsageList extends StatelessWidget {
  final List<OutfitUsageStat> items;
  const _OutfitUsageList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.appCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          return OutfitUsageRow(stat: e.value, rank: e.key + 1);
        }).toList(),
      ),
    );
  }
}

class _CostPerWearList extends StatelessWidget {
  final List<WardrobeValueStat> items;
  const _CostPerWearList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.appCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          return CostPerWearRow(stat: e.value, rank: e.key + 1);
        }).toList(),
      ),
    );
  }
}
