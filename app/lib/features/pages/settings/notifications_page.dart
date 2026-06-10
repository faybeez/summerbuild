import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app_colors.dart';
import '../../../functions.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _newsletters = true;
  bool _weather = false;
  bool _outfitReminders = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _buildToggle(
            icon: Icons.email_outlined,
            title: 'Newsletters',
            subtitle: 'Trend reports, guides, and style tips',
            value: _newsletters,
            onChanged: (v) => setState(() => _newsletters = v),
          ),
          _buildToggle(
            icon: Icons.cloud_outlined,
            title: 'Weather changes',
            subtitle: 'Outfit suggestions when the forecast shifts',
            value: _weather,
            onChanged: (v) => setState(() => _weather = v),
          ),
          _buildToggle(
            icon: Icons.access_time_outlined,
            title: 'Outfit reminders',
            subtitle: 'Daily nudge to check your planned outfits',
            value: _outfitReminders,
            onChanged: (v) => setState(() => _outfitReminders = v),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            child: Icon(icon, color: AppColors.appEspresso.withAlpha(180)),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.appTerracotta,
          ),
        ],
      ),
    );
  }
}
