import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app_colors.dart';
import '../../../../classes/classes.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _nameController = TextEditingController();
  final _picker = ImagePicker();
  String _selectedCategory = 'Tops';
  String? _selectedSubColor;
  String? _imagePath;

  static const _categories = [
    'Tops',
    'Bottoms',
    'Outerwear',
    'Shoes',
    'Dresses',
    'Accessories',
  ];

  static const _iconMap = {
    'Tops': Icons.dry_cleaning,
    'Bottoms': Icons.style,
    'Outerwear': Icons.layers,
    'Shoes': Icons.ice_skating,
    'Dresses': Icons.woman,
    'Accessories': Icons.work_outline,
  };

  static const _colorMap = {
    'Tops': AppColors.appPeach,
    'Bottoms': AppColors.appOlive,
    'Outerwear': AppColors.appWarmCream,
    'Shoes': AppColors.appEspresso,
    'Dresses': AppColors.appTerracotta,
    'Accessories': AppColors.appTan,
  };

  static const _subColors = {
    'None': null,
    'White': Color(0xFFFFFFFF),
    'Cream': Color(0xFFFFF8ED),
    'Beige': Color(0xFFF5DEB3),
    'Tan': Color(0xFFD9B88F),
    'Olive': Color(0xFF8C7E5B),
    'Navy': Color(0xFF1A2F4C),
    'Gray': Color(0xFF9E9E9E),
    'Burgundy': Color(0xFF6B1C32),
    'Denim': Color(0xFF597A9E),
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xFile != null && mounted) {
      setState(() => _imagePath = xFile.path);
    }
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final item = WardrobeItem(
      name,
      _selectedCategory,
      _colorMap[_selectedCategory]!,
      _iconMap[_selectedCategory]!,
      imagePath: _imagePath,
      subColor: _subColors[_selectedSubColor],
    );
    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add item'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.appWarmCream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF1DFC8), width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: _imagePath != null
                    ? Image.file(
                        File(_imagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 44,
                            color: AppColors.appEspresso.withAlpha(80),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to add photo',
                            style: TextStyle(
                              color: AppColors.appEspresso.withAlpha(120),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Black jeans',
                prefixIcon: Icon(Icons.edit_outlined),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _categories.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _selectedSubColor,
              decoration: const InputDecoration(
                labelText: 'Sub colour',
                prefixIcon: Icon(Icons.color_lens_outlined),
              ),
              items: _subColors.entries.map((entry) {
                final color = entry.value;
                return DropdownMenuItem(
                  value: entry.key,
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: color ?? Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD9B88F)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(entry.key),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedSubColor = value);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
