import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app_colors.dart';
import '../../../classes/classes.dart';

class PersonalizationPage extends StatefulWidget {
  const PersonalizationPage({required this.profile, super.key});

  final UserProfile profile;

  @override
  State<PersonalizationPage> createState() => _PersonalizationPageState();
}

class _PersonalizationPageState extends State<PersonalizationPage> {
  late final _displayNameController = TextEditingController(
    text: widget.profile.displayName,
  );
  late final _emailController = TextEditingController(
    text: widget.profile.email,
  );
  late final _dobController = TextEditingController(
    text: widget.profile.dateOfBirth,
  );

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _save() {
    final displayName = _displayNameController.text.trim();
    final email = _emailController.text.trim();
    final dob = _dobController.text.trim();

    if (displayName.isEmpty || email.isEmpty) return;

    Navigator.of(context).pop(
      UserProfile(
        displayName: displayName,
        email: email,
        dateOfBirth: dob.isEmpty ? 'Not set' : dob,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalisation'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _save)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _displayNameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Display name',
                hintText: 'e.g. Jane Smith',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _dobController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                labelText: 'Date of birth',
                hintText: 'YYYY-MM-DD',
                prefixIcon: Icon(Icons.cake_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
