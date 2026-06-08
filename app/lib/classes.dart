import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'functions.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    required this.title,
    required this.subtitle,
    required this.children,
    this.trailing,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.appEspresso.withAlpha(165),
                        ),
                      ),
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          sliver: SliverList.separated(
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
            separatorBuilder: (context, index) => const SizedBox(height: 14),
          ),
        ),
      ],
    );
  }
}

class ForecastCard extends StatelessWidget {
  const ForecastCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(AppColors.appWarmCream),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.appCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.cloud_queue,
              color: AppColors.appTerracotta,
              size: 38,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '31 C / Cloudy',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.appEspresso,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose breathable layers and shoes that can handle a quick shower.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.appEspresso.withAlpha(170),
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

class OutfitRecommendation extends StatelessWidget {
  const OutfitRecommendation({
    required this.title,
    required this.description,
    required this.icon,
    required this.colors,
    this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      onTap: onTap,
      leading: Icon(icon),
      title: title,
      subtitle: description,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: colors
            .map(
              (color) => Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.appEspresso.withAlpha(35),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  const EventCard({
    required this.day,
    required this.month,
    required this.title,
    required this.occasion,
    required this.icon,
    this.onTap,
    super.key,
  });

  final String day;
  final String month;
  final String title;
  final String occasion;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      onTap: onTap,
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 19,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            month,
            style: TextStyle(
              color: AppColors.appEspresso.withAlpha(150),
              fontSize: 12,
              height: 1,
            ),
          ),
        ],
      ),
      title: title,
      subtitle: occasion,
      trailing: Icon(icon),
    );
  }
}

class TrendCard extends StatelessWidget {
  const TrendCard({
    required this.title,
    required this.category,
    required this.icon,
    this.onTap,
    super.key,
  });

  final String title;
  final String category;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      onTap: onTap,
      leading: Icon(icon),
      title: title,
      subtitle: category,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    required this.displayName,
    required this.subtitle,
    this.onTap,
    super.key,
  });

  final String displayName;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: cardDecoration(AppColors.appCard),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.appWarmCream,
              child: Icon(
                Icons.person,
                color: AppColors.appTerracotta,
                size: 34,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.appTan),
          ],
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.icon,
    required this.title,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      leading: Icon(icon),
      title: title,
      subtitle: 'Manage $title',
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: cardDecoration(AppColors.appCard),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.appWarmCream,
                borderRadius: BorderRadius.circular(8),
              ),
              foregroundDecoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFF1DFC8)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: leading,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.appEspresso.withAlpha(150),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onPressed,
    super.key,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        TextButton(onPressed: onPressed, child: Text(actionLabel)),
      ],
    );
  }
}

class WardrobeItem {
  const WardrobeItem(
    this.name,
    this.category,
    this.color,
    this.icon, {
    this.imagePath,
    this.subColor,
  });

  final String name;
  final String category;
  final Color color;
  final IconData icon;
  final String? imagePath;
  final Color? subColor;
}

class CalendarEvent {
  const CalendarEvent({
    required this.day,
    required this.month,
    required this.title,
    required this.occasion,
    required this.icon,
  });

  final String day;
  final String month;
  final String title;
  final String occasion;
  final IconData icon;

  CalendarEvent copyWith({
    String? day,
    String? month,
    String? title,
    String? occasion,
    IconData? icon,
  }) {
    return CalendarEvent(
      day: day ?? this.day,
      month: month ?? this.month,
      title: title ?? this.title,
      occasion: occasion ?? this.occasion,
      icon: icon ?? this.icon,
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.email,
    required this.dateOfBirth,
  });

  final String displayName;
  final String email;
  final String dateOfBirth;
}

class OutfitPiece {
  const OutfitPiece(this.name, this.category, {this.color, this.icon});

  final String name;
  final String category;
  final Color? color;
  final IconData? icon;
}
