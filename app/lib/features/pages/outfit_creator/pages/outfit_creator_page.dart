// lib/features/outfit_creator/pages/outfit_creator_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_colors.dart';
import '../../../data/tags_repository.dart';
import '../../../data/wardrobe_repository.dart';
import '../data/outfit_generator_service.dart';
import '../state/outfit_creator_controller.dart';
import '../widgets/outfit_filter_sheet.dart';
import 'outfit_results_page.dart';

class OutfitCreatorPage extends StatefulWidget {
  const OutfitCreatorPage({
    super.key,
    required this.wardrobeRepository,
    required this.tagsRepository,
  });

  final WardrobeRepository wardrobeRepository;
  final TagsRepository tagsRepository;

  @override
  State<OutfitCreatorPage> createState() => _OutfitCreatorPageState();
}

class _OutfitCreatorPageState extends State<OutfitCreatorPage> {
  late final OutfitCreatorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OutfitCreatorController(
      generatorService: OutfitGeneratorService(
        wardrobeRepository: widget.wardrobeRepository,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OutfitFilterSheet(
        initialOccasion: _controller.occasion,
        initialWeather: _controller.weather,
        initialColorPreference: _controller.colorPreference,
        initialVibe: _controller.vibe,
        initialMustInclude: _controller.mustIncludeItem,
        allWardrobeItems: const [],
        onApply:
            ({
              required occasion,
              required weather,
              colorPreference,
              vibe,
              mustInclude,
            }) {
              _controller.setOccasion(occasion);
              _controller.setWeather(weather);
              _controller.setColorPreference(colorPreference);
              _controller.setVibe(vibe);
              _controller.setMustIncludeItem(mustInclude);
              _generateAndNavigate();
            },
      ),
    );
  }

  Future<void> _generateAndNavigate() async {
    await _controller.generate();

    if (!mounted) return;

    if (_controller.status == OutfitCreatorStatus.success) {
      context.push('/studio/ai/results', extra: _controller);
    } else if (_controller.status == OutfitCreatorStatus.insufficientWardrobe) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your wardrobe doesn\'t have enough items to build a complete outfit. '
            'Try adding more clothes first!',
          ),
          backgroundColor: AppColors.appTerracotta,
        ),
      );
    } else if (_controller.status == OutfitCreatorStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage ?? 'Something went wrong.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.textMain,
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'AI Outfit Creator',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.appEspresso,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return _controller.status == OutfitCreatorStatus.loading
                ? const _LoadingView()
                : _IdleView(onGenerate: _openFilterSheet);
          },
        ),
      ),
    );
  }
}

// ── Idle / entry view ────────────────────────────────────────────────────────
class _IdleView extends StatelessWidget {
  const _IdleView({required this.onGenerate});
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          // Illustration area
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.appWarmCream,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: 48, color: AppColors.appOlive),
                const SizedBox(height: 12),
                const Text(
                  'Let AI style you',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.appEspresso,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Get 3 outfit ideas from your wardrobe',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'How it works',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.appEspresso,
            ),
          ),
          const SizedBox(height: 16),
          const _StepTile(
            icon: Icons.tune_outlined,
            title: 'Set your preferences',
            subtitle: 'Choose occasion, weather, vibe, and optional color.',
          ),
          const SizedBox(height: 12),
          const _StepTile(
            icon: Icons.checkroom_outlined,
            title: 'We scan your wardrobe',
            subtitle:
                'Your existing clothes are matched against smart templates.',
          ),
          const SizedBox(height: 12),
          const _StepTile(
            icon: Icons.star_outline_rounded,
            title: 'Get 3 scored suggestions',
            subtitle: 'Each outfit comes with a reason and a styling tip.',
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: onGenerate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.appEspresso,
                  borderRadius: BorderRadius.circular(99),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 18,
                      color: AppColors.appCream,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Get AI Outfit Suggestions',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.appCream,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.appChipBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.appOlive),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Loading view ─────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.appOlive,
          ),
          const SizedBox(height: 20),
          const Text(
            'Styling your wardrobe…',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This only takes a moment',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
