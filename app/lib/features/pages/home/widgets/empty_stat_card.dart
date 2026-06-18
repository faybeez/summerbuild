// lib/features/home/widgets/empty_stat_card.dart

import 'package:flutter/material.dart';
import '../../../../app_colors.dart';
import '../../../../functions.dart';

class EmptyStatCard extends StatelessWidget {
  final String message;

  const EmptyStatCard({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: cardDecoration(AppColors.appCard),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.appEspresso.withAlpha(100),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.appEspresso.withAlpha(130),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
