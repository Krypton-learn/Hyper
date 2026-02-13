import 'package:flutter/material.dart';
import '../widgets/custom_toast.dart';

import '../utils/globals.dart';

class ToastService {
  static final List<OverlayEntry> _entries = [];

  static void show(BuildContext context, String message, ToastType type) {
    final overlay = Overlay.of(context);
    _show(overlay, message, type);
  }

  static void showGlobal(String message, ToastType type) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay != null) {
      _show(overlay, message, type);
    }
  }

  static void _show(OverlayState overlay, String message, ToastType type) {
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50 + (_entries.length * 70.0), // Stack them
        right: 0,
        child: _ToastAnimation(
          child: CustomToast(
            message: message,
            type: type,
            onClose: () {
              _removeEntry(entry);
            },
          ),
        ),
      ),
    );

    _entries.add(entry);
    overlay.insert(entry);

    // Auto dismiss
    Future.delayed(const Duration(seconds: 3), () {
      _removeEntry(entry);
    });
  }

  static void _removeEntry(OverlayEntry entry) {
    if (_entries.contains(entry)) {
      entry.remove();
      _entries.remove(entry);
      // Rebuild remaining entries to adjust positions (optional, simple removal for now leaves gaps or we can implement more complex logic later)
      // For simple MVP with short timeout, leaving gaps briefly or just letting them clear is okay.
      // To shift them up, we would need a stateful widget manager, but OverlayEntries are imperative.
      // A full toast manager is complex. Let's stick to simple "show and forget" for now, or just limit to 1?
      // Re-positioning imperative overlays is hard.
      // Let's just limit to clearing all or simple stacking.
      // Actually, if we want to shift them up, we need to rebuild them.
      // Simplest: Just clear it.
    }
  }
}

class _ToastAnimation extends StatefulWidget {
  final Widget child;

  const _ToastAnimation({required this.child});

  @override
  State<_ToastAnimation> createState() => _ToastAnimationState();
}

class _ToastAnimationState extends State<_ToastAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}
