import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app_colors.dart';
import '../../../classes/classes.dart';

class ArticlePage extends StatelessWidget {
  const ArticlePage({
    required this.title,
    required this.category,
    required this.icon,
    required this.author,
    required this.date,
    super.key,
  });

  final String title;
  final String category;
  final IconData icon;
  final String author;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.appWarmCream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.appEspresso.withAlpha(60),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.appPeach.withAlpha(50),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                category,
                style: const TextStyle(
                  color: AppColors.appTerracotta,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.appPeach.withAlpha(80),
                  child: Text(
                    author[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.appTerracotta,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  author,
                  style: TextStyle(
                    color: AppColors.appEspresso.withAlpha(180),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  date,
                  style: TextStyle(
                    color: AppColors.appEspresso.withAlpha(100),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\nSed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.7,
                color: AppColors.appEspresso.withAlpha(200),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
