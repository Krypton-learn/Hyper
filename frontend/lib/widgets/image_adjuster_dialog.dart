import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:io';

class ImageAdjusterDialog extends StatefulWidget {
  final File imageFile;

  const ImageAdjusterDialog({super.key, required this.imageFile});

  @override
  State<ImageAdjusterDialog> createState() => _ImageAdjusterDialogState();
}

class _ImageAdjusterDialogState extends State<ImageAdjusterDialog> {
  double _scale = 1.0;
  double _offsetX = 0.0;
  double _offsetY = 0.0;
  
  // Crop area size
  static const double cropSize = 200.0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Adjust Profile Picture',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Drag to position, scroll to zoom',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            
            // Image preview with crop area
            Stack(
              alignment: Alignment.center,
              children: [
                // Larger container for the full image
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _offsetX += details.delta.dx;
                          _offsetY += details.delta.dy;
                        });
                      },
                      child: Listener(
                        onPointerSignal: (event) {
                          // Handle mouse scroll for zoom
                          if (event is PointerScrollEvent) {
                            setState(() {
                              _scale = (_scale - event.scrollDelta.dy * 0.001)
                                  .clamp(0.3, 5.0);
                            });
                          }
                        },
                        child: Transform.translate(
                          offset: Offset(_offsetX, _offsetY),
                          child: Transform.scale(
                            scale: _scale,
                            child: Image.file(
                              widget.imageFile,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Circular crop overlay indicator
                IgnorePointer(
                  child: Container(
                    width: cropSize,
                    height: cropSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF5D5FEF),
                        width: 3,
                      ),
                    ),
                  ),
                ),
                // Corner indicators showing crop area
                IgnorePointer(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Zoom slider
            Row(
              children: [
                const Icon(Icons.zoom_out, color: Colors.grey, size: 20),
                Expanded(
                  child: Slider(
                    value: _scale,
                    min: 0.5,
                    max: 3.0,
                    activeColor: const Color(0xFF5D5FEF),
                    inactiveColor: Colors.grey.shade300,
                    onChanged: (value) {
                      setState(() {
                        _scale = value;
                      });
                    },
                  ),
                ),
                const Icon(Icons.zoom_in, color: Colors.grey, size: 20),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Reset button
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _scale = 1.0;
                  _offsetX = 0.0;
                  _offsetY = 0.0;
                });
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reset'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // Return the original file - the visual adjustments
                    // are just for preview. The server will handle cropping
                    // or you can implement actual cropping here later.
                    Navigator.pop(context, widget.imageFile);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D5FEF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Use this image',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
