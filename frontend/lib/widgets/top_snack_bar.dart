
import 'package:flutter/material.dart';

void showTopRightSnackBar(BuildContext context, String message, {bool isError = false}) {
  late OverlayEntry overlayEntry;
  final overlay = Overlay.of(context);
  
  overlayEntry = OverlayEntry(
    builder: (context) => _TopSnackBarWidget(
      message: message,
      isError: isError,
      onDismiss: () {
        overlayEntry.remove();
      },
    ),
  );

  overlay.insert(overlayEntry);
}

class _TopSnackBarWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const _TopSnackBarWidget({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  State<_TopSnackBarWidget> createState() => _TopSnackBarWidgetState();
}

class _TopSnackBarWidgetState extends State<_TopSnackBarWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
      reverseCurve: Curves.linear,
    );

    _controller.forward();

    // Auto dismiss after duration
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      right: 20,
      child: Material(
        type: MaterialType.transparency,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              constraints: const BoxConstraints(maxWidth: 350),
              decoration: BoxDecoration(
                color: widget.isError ? const Color(0xFFFF6F00) : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      widget.isError ? Icons.priority_high : Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Flexible(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
