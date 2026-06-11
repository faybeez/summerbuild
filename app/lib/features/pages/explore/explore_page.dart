import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app_colors.dart';
import '../../../classes.dart';

import '../home/article_page.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Explore',
      subtitle: 'Newsletters and trend notes',
      children: [
        TrendCard(
          title: 'Light layers for humid weather',
          category: 'Trend report',
          icon: Icons.air,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ArticlePage(
                  title: 'Light layers for humid weather',
                  category: 'Trend report',
                  icon: Icons.air,
                  author: 'Mira Chen',
                  date: 'May 28, 2026',
                ),
              ),
            );
          },
        ),
        TrendCard(
          title: 'How stylists are wearing silver accents',
          category: 'Newsletter',
          icon: Icons.auto_awesome,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ArticlePage(
                  title: 'How stylists are wearing silver accents',
                  category: 'Newsletter',
                  icon: Icons.auto_awesome,
                  author: 'Jordan Park',
                  date: 'May 25, 2026',
                ),
              ),
            );
          },
        ),
        TrendCard(
          title: 'Capsule colors that still feel personal',
          category: 'Guide',
          icon: Icons.color_lens_outlined,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ArticlePage(
                  title: 'Capsule colors that still feel personal',
                  category: 'Guide',
                  icon: Icons.color_lens_outlined,
                  author: 'Reese Alvarado',
                  date: 'May 20, 2026',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
