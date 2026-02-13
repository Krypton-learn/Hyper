import 'package:flutter/material.dart';

enum ToastType { success, error, info }

class CustomToast extends StatelessWidget {
  final String message;
  final ToastType type;
  final VoidCallback onClose;

  const CustomToast({
    super.key,
    required this.message,
    required this.type,
    required this.onClose,
  });

  Color _getBackgroundColor(bool isDark) {
    switch (type) {
      case ToastType.success:
        return isDark ? const Color(0xFF1B4D3E) : const Color(0xFFDEF7EC);
      case ToastType.error:
        return isDark ? const Color(0xFF4B1B1B) : const Color(0xFFFDE8E8);
      case ToastType.info:
      default:
        return isDark ? const Color(0xFF1C3A5E) : const Color(0xFFE1EFFE);
    }
  }

  Color _getBorderColor(bool isDark) {
    switch (type) {
      case ToastType.success:
        return isDark ? const Color(0xFF31C48D) : const Color(0xFF31C48D);
      case ToastType.error:
        return isDark ? const Color(0xFFF98080) : const Color(0xFFF98080);
      case ToastType.info:
      default:
        return isDark ? const Color(0xFF76A9FA) : const Color(0xFF76A9FA);
    }
  }
    Color _getTextColor(bool isDark) {
    switch (type) {
      case ToastType.success:
        return isDark ? const Color(0xFF31C48D) : const Color(0xFF03543F);
      case ToastType.error:
        return isDark ? const Color(0xFFF98080) : const Color(0xFF9B1C1C);
      case ToastType.info:
      default:
        return isDark ? const Color(0xFF76A9FA) : const Color(0xFF1E429F);
    }
  }


  IconData _getIcon() {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline_rounded;
      case ToastType.error:
        return Icons.error_outline_rounded;
      case ToastType.info:
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = _getBackgroundColor(isDark);
    final borderColor = _getBorderColor(isDark);
    final textColor = _getTextColor(isDark);

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF27272A) : Colors.white, // Surface color
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getIcon(), color: borderColor, size: 20),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                message,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onClose,
              child: Icon(Icons.close, color: isDark ? Colors.grey[400] : Colors.grey[500], size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
