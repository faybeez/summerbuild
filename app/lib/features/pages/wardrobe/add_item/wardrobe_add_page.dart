import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app_colors.dart';
import '../../../../classes.dart';
import '../../../data/tags_repository.dart';

import 'wardrobe_add_state.dart';
import '1_upload.dart';
import '2_review.dart';

class WardrobeAddPage extends StatefulWidget {
  const WardrobeAddPage({super.key, required this.tagsRepository});

  final TagsRepository tagsRepository;

  @override
  State<WardrobeAddPage> createState() => _WardrobeAddPageState();
}

class _WardrobeAddPageState extends State<WardrobeAddPage> {
  final _pageController = PageController();
  final _state = WardrobeAddState();
  bool _isProcessing = false;

  late final Future<List<ClothingTag>> _categoryTagsFuture;
  late final Future<List<ClothingTag>> _colorTagsFuture;
  late final Future<List<ClothingTag>> _occasionTagsFuture;
  late final Future<List<ClothingTag>> _weatherTagsFuture;

  @override
  void initState() {
    super.initState();

    _categoryTagsFuture = widget.tagsRepository.getTags(type: 'CATEGORY');
    _colorTagsFuture = widget.tagsRepository.getTags(type: 'COLOR');
    _occasionTagsFuture = widget.tagsRepository.getTags(type: 'OCCASION');
    _weatherTagsFuture = widget.tagsRepository.getTags(type: 'WEATHER');
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _processAndContinue() async {
    if (_state.image == null) return;

    setState(() => _isProcessing = true);

    try {
      final imageFile = _state.image!;
      final imageBytes = await imageFile.readAsBytes();
      final fileName = imageFile.path.split('/').last;

      final multipartRequest = http.MultipartRequest('POST', Uri());
      multipartRequest.files.add(
        http.MultipartFile.fromBytes('image', imageBytes, filename: fileName),
      );
      final finalizedRequest = await multipartRequest.finalize().toBytes();
      final contentType =
          'multipart/form-data; boundary=${multipartRequest.headers['content-type']?.split('boundary=').last}';

      final response = await Supabase.instance.client.functions.invoke(
        'process-clothes',
        body: finalizedRequest,
        headers: {'Content-Type': contentType},
      );

      if (response.data != null) {
        debugPrint('Raw Edge Function Data: ${response.data['message']}');
        final json = response.data['message'] as Map<String, dynamic>;
        setState(() => _state.applyFromEdgeFunction(json));
        _nextPage();
      }
    } on FunctionException catch (e) {
      debugPrint('Edge Function Error: ${e}, Details: ${e.details}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process image: ${e.details}'),
            backgroundColor: AppColors.error,
          ),
        );
        _nextPage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveToSupabase() async {
    // TODO: save _state to Supabase
    if (mounted) context.go('/wardrobe');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            final page = _pageController.page?.round() ?? 0;
            if (page > 0) {
              _previousPage();
            } else {
              context.go('/wardrobe');
            }
          },
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          WardrobeUploadPage(state: _state, onContinue: _processAndContinue),
          WardrobeReviewPage(state: _state, onConfirm: _saveToSupabase),
        ],
      ),
    );
  }
}
