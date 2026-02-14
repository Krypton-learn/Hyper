import 'package:flutter/material.dart';

class HoverableImageCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final double width;
  final double height;
  final VoidCallback? onFullscreen;

  const HoverableImageCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    this.width = 200,
    this.height = 150,
    this.onFullscreen,
  }) : super(key: key);

  @override
  State<HoverableImageCard> createState() => _HoverableImageCardState();
}

class _HoverableImageCardState extends State<HoverableImageCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Determine if we are in dark mode for base styling, 
    // though the overlay specifically needs to be translucent black/white as per request.
    // The user requested "transparent or transulant" for the text and option.
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onFullscreen,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // Border and color will be handled by the image or parent, 
            // but we can add a subtle border here if needed.
            // For now keeping it clean.
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image with Zoom Effect
                AnimatedScale(
                  scale: _isHovered ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),

                // Hover Overlay with Fade Effect
                AnimatedOpacity(
                  opacity: _isHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Align( // Use Align or Positioned, keeping Positioned logic but wrapped
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: const BoxDecoration(
                        color: Colors.black54, // Translucent black background
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: widget.onFullscreen,
                            child: const Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
