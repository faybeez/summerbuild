// lib/features/home/widgets/wardrobe_statistics_section.dart
//
// The main widget that renders a single named section of the stats dashboard.
// Pass a title, optional subtitle, and the section body widget.

import 'package:flutter/material.dart';
import '../../../../app_colors.dart';
import '../../../../classes/classes.dart';

class WardrobeStatisticsSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  const WardrobeStatisticsSection({
    required this.title,
    required this.child,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.appEspresso.withAlpha(130),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}
