import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app_colors.dart';
import 'wardrobe_add_state.dart';

class WardrobeUploadPage extends StatefulWidget {
  final WardrobeAddState state;
  final VoidCallback onContinue;
  final bool isLoading;

  const WardrobeUploadPage({
    super.key,
    required this.state,
    required this.onContinue,
    this.isLoading = false,
  });

  @override
  State<WardrobeUploadPage> createState() => _WardrobeUploadPageState();
}

class _WardrobeUploadPageState extends State<WardrobeUploadPage> {
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xFile != null && mounted) {
      setState(() {
        widget.state.image = File(xFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.state.image;
    final isLoading = widget.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Add Piece',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: AppColors.appEspresso,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Add a new clothing piece\nto your wardrobe',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.appOlive,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: GestureDetector(
                  onTap: isLoading ? null : _pickImage,
                  child: image != null
                      ? Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            image: DecorationImage(
                              image: FileImage(image),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF6F0),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: CustomPaint(
                            painter: DashedBorderPainter(
                              color: const Color(0xFFC4B8A9),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _UploadIcon(),
                                SizedBox(height: 24),
                                Text(
                                  'Upload a photo',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.appEspresso,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Tap to add an image here\nor tap to browse',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.appOlive,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (image != null && !isLoading)
                      ? widget.onContinue
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appEspresso,
                    disabledBackgroundColor: AppColors.appEspresso.withAlpha(
                      80,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadIcon extends StatelessWidget {
  const _UploadIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFF2E6D8),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.upload_rounded,
        size: 40,
        color: AppColors.appEspresso,
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;

  const DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 6.0;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(24),
    );

    final path = Path()..addRRect(rrect);
    final dashPath = Path();

    for (final pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
