import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/document_item.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/hoverable_image_card.dart';
import '../widgets/skeleton.dart';

import 'package:flutter/gestures.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> with SingleTickerProviderStateMixin {
  final ScrollController _galleryScrollController = ScrollController();
  AnimationController? _bumpController;
  Animation<double>? _bumpAnimation;
  double _bumpDirection = 0;
  
  bool _isLoading = true;
  List<DocumentItem> _images = [];
  List<DocumentItem> _documents = [];

  @override
  void initState() {
    super.initState();
    // Initialize controller (also handled in build for hot reload safety)
    _initBumpController();
    
    // Fetch data after the first frame to access UserProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMedia();
    });
  }

  void _initBumpController() {
    if (_bumpController == null) {
      _bumpController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 150),
      );
      _bumpAnimation = Tween<double>(begin: 0, end: 20).animate(
        CurvedAnimation(parent: _bumpController!, curve: Curves.easeOutQuad),
      );
    }
  }

  @override
  void dispose() {
    _galleryScrollController.dispose();
    _bumpController?.dispose();
    super.dispose();
  }

  void _triggerBump(double direction) {
    if (_bumpController == null) return;
    if (_bumpController!.isAnimating) return;
    setState(() {
      _bumpDirection = direction;
    });
    _bumpController!.forward().then((_) => _bumpController!.reverse());
  }

  Future<void> _fetchMedia() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    ApiService apiService;
    try {
      apiService = Provider.of<ApiService>(context, listen: false);
    } catch (_) {
      apiService = ApiService(userProvider.accessToken);
    }

    try {
      final mediaUrls = await apiService.getMedia();
      
      final List<DocumentItem> images = [];
      final List<DocumentItem> docs = [];

      for (int i = 0; i < mediaUrls.length; i++) {
        final url = mediaUrls[i];
        final name = url.split('/').last.split('?').first;
        final extension = name.contains('.') ? name.split('.').last.toLowerCase() : '';
        // Check extension AND path clues (e.g. Supabase 'images_media' bucket)
        final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension) || 
                        url.contains('images_media') || 
                        extension.isEmpty; // Assume unknown files without extension are images for now as per user request

        final docItem = DocumentItem(
          id: i,
          title: name,
          type: isImage ? 'image' : 'file', 
          size: '0kb',
          uploadedBy: 'Unknown',
          fileUrl: url,
        );
        
        if (isImage) {
          images.add(docItem);
        } else {
          docs.add(docItem);
        }
      }

      if (mounted) {
        setState(() {
          _images = images;
          _documents = docs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load media: $e')),
        );
      }
    }
  }

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9), // Dark background for focus
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero, // Full screen
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer( // Alow zooming
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ensure animation controller is initialized (handles hot reload case)
    _initBumpController();

    // Determine if we are in dark mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Define colors based on theme
    final cardColor = isDark ? const Color(0xFF27272A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF3F3F46) : Colors.grey[300]!;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          const Sidebar(currentRoute: '/documents'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Section: Image Gallery
                  SizedBox(
                    height: 150,
                    child: _isLoading 
                      ? ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5, // Show 5 skeleton items
                          separatorBuilder: (context, index) => const SizedBox(width: 16),
                          itemBuilder: (context, index) => const Skeleton(
                            width: 200,
                            height: 150,
                            radius: 16,
                          ),
                        )
                      : _images.isEmpty 
                        ? Center(child: Text("No images found", style: TextStyle(color: secondaryTextColor)))
                        : Listener(
                            onPointerSignal: (event) {
                              if (event is PointerScrollEvent) {
                                final newOffset = _galleryScrollController.offset + event.scrollDelta.dy;
                                if (newOffset < _galleryScrollController.position.minScrollExtent) {
                                  // Hit left wall -> Bounce Right
                                  _triggerBump(1);
                                  _galleryScrollController.jumpTo(_galleryScrollController.position.minScrollExtent);
                                } else if (newOffset > _galleryScrollController.position.maxScrollExtent) {
                                  // Hit right wall -> Bounce Left
                                  _triggerBump(-1);
                                  _galleryScrollController.jumpTo(_galleryScrollController.position.maxScrollExtent);
                                } else {
                                  _galleryScrollController.jumpTo(newOffset);
                                }
                              }
                            },
                            child: AnimatedBuilder(
                              animation: _bumpController!,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset((_bumpAnimation?.value ?? 0) * _bumpDirection, 0),
                                  child: child,
                                );
                              },
                              child: ListView.separated(
                                controller: _galleryScrollController,
                                scrollDirection: Axis.horizontal,
                                itemCount: _images.length,
                                separatorBuilder: (context, index) => const SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                  final image = _images[index];
                                  final imageUrl = image.fileUrl.startsWith('http') 
                                          ? image.fileUrl 
                                          : '${ApiService.baseUrl.replaceAll('/api/v1', '')}${image.fileUrl}';

                                  return StaggeredFadeIn(
                                    index: index,
                                    child: HoverableImageCard(
                                      imageUrl: imageUrl,
                                      title: image.title,
                                      onFullscreen: () => _showFullScreenImage(imageUrl),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 32),

                  // Middle Section: Search and Filter
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 48,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.grey),
                              const SizedBox(width: 12),
                              Text(
                                'Search . . . . . . . . . .',
                                style: TextStyle(color: secondaryTextColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                        ),
                        child: const Icon(Icons.filter_list, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderColor),
                        ),
                        child: const Text(
                          'filter by',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Bottom Section: Document List
                  Expanded(
                    child: _isLoading 
                      ? ListView.separated(
                          itemCount: 5, // Show 5 skeleton items
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) => const Skeleton(
                            width: double.infinity,
                            height: 100,
                            radius: 16,
                          ),
                        )
                      : _documents.isEmpty
                        ? Center(child: Text("No documents found", style: TextStyle(color: secondaryTextColor)))
                        : ListView.separated(
                            itemCount: _documents.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final doc = _documents[index];
                              return Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doc.title,
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              _buildPill(doc.type),
                                              const SizedBox(width: 8),
                                              _buildPill(doc.size), // Size might be 0kb or unknown, but displaying as is
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: Colors.grey[600]!),
                                                ),
                                                child: Text(
                                                  'uploaded by : ${doc.uploadedBy}',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(color: Colors.grey[500]!),
                                      ),
                                      child: Text(
                                        'download',
                                        style: TextStyle(color: textColor),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text.toLowerCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}

class StaggeredFadeIn extends StatefulWidget {
  final int index;
  final Widget child;

  const StaggeredFadeIn({
    Key? key,
    required this.index,
    required this.child,
  }) : super(key: key);

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.index * 150), () {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _isVisible ? Offset.zero : const Offset(0.2, 0), // Slight slide from right (or left if negative) - user said "fade in FROM left to right", usually means sequence. 
        // Slide from left? Offset(-0.2, 0) -> 0. But often "fade in from left" means appearing.
        // Let's just do Opacity + slight scale or just opacity.
        // Actually, user said "fade in from left to right" which refers to the ORDER.
        // But individual animation? "fade in". I'll add a subtle slide up or just opacity to be safe.
        // Let's stick to Opacity as requested, maybe with a tiny slide from bottom for polish.
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
