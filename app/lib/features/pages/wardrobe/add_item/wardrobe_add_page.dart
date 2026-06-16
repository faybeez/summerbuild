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
  late final WardrobeAddState _state;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    _state = WardrobeAddState(tagsRepository: widget.tagsRepository);
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
        _state.applyFromEdgeFunction(response.data as Map<String, dynamic>);
        if (mounted) setState(() {});
        _nextPage();
      }
    } on FunctionException catch (e) {
      debugPrint('Edge Function Error: \$e, Details: \${e.details}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process image: \${e.details}'),
            backgroundColor: AppColors.error,
          ),
        );
        _nextPage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong: \$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveToSupabase() async {
    if (_state.image == null || _state.category == null) return;

    setState(() => _isProcessing = true);

    try {
      final imageFile = _state.image!;
      final imageBytes = await imageFile.readAsBytes();
      final fileName = imageFile.path.split('/').last;
      final type = fileName.split('.').last;

      final tagIds = [
        ..._state.mainColors.map((t) => t.id),
        ..._state.secondaryColors.map((t) => t.id),
        ..._state.occasion.map((t) => t.id),
        ..._state.weather.map((t) => t.id),
        if (_state.category != null) _state.category!.id,
      ];

      final multipartRequest = http.MultipartRequest('POST', Uri());
      multipartRequest.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: fileName,
          contentType: http.MediaType('image', type),
        ),
      );
      multipartRequest.fields['cost'] = _state.cost.toString();
      multipartRequest.fields['times_worn'] = _state.timesWorn.toString();
      multipartRequest.fields['tag_ids'] = '[${tagIds.join(',')}]';

      final finalizedRequest = await multipartRequest.finalize().toBytes();
      final contentType =
          'multipart/form-data; boundary=${multipartRequest.headers['content-type']?.split('boundary=').last}';

      final response = await Supabase.instance.client.functions.invoke(
        'insert-clothes',
        body: finalizedRequest,
        headers: {'Content-Type': contentType},
      );

      if (response.data != null) {
        if (mounted) context.go('/wardrobe');
      }
    } on FunctionException catch (e) {
      debugPrint('Edge Function Error: $e, Details: ${e.details}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.details}'),
            backgroundColor: AppColors.error,
          ),
        );
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
          WardrobeUploadPage(
            state: _state,
            onContinue: _processAndContinue,
            isLoading: _isProcessing,
          ),
          WardrobeReviewPage(
            state: _state,
            onConfirm: _saveToSupabase,
            isLoading: _isProcessing,
          ),
        ],
      ),
    );
  }
}
