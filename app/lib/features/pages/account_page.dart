import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app_colors.dart';
import '../../classes.dart';

import 'personalization_page.dart';
import 'change_password_page.dart';
import 'notifications_page.dart';
import 'style_preferences_page.dart';
import 'login_page.dart';
import 'settings_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _isSigningOut = false;
  UserProfile _profile = const UserProfile(
    displayName: 'Your Wardrobe',
    email: 'you@example.com',
    dateOfBirth: 'Not set',
  );

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Account',
      subtitle: 'Preferences and privacy',
      children: [
        ProfileCard(
          displayName: _profile.displayName,
          subtitle: _profile.email,
          onTap: () async {
            final updated = await Navigator.of(context).push<UserProfile>(
              MaterialPageRoute(
                builder: (_) => PersonalizationPage(profile: _profile),
              ),
            );
            if (updated != null && mounted) {
              setState(() => _profile = updated);
            }
          },
        ),
        SettingsTile(
          icon: Icons.lock_outline,
          title: 'Password',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
            );
          },
        ),
        SettingsTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            );
          },
        ),
        SettingsTile(
          icon: Icons.tune,
          title: 'Style preferences',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StylePreferencesPage()),
            );
          },
        ),
        SettingsTile(
          icon: Icons.settings_outlined,
          title: 'App settings',
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
          },
        ),
        const SizedBox(height: 24),
        SettingsTile(
          icon: Icons.logout,
          title: 'Log out',
          onTap: _isSigningOut ? null : _signOut,
        ),
      ],
    );
  }
}
