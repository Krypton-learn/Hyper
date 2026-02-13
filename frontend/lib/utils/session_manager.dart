import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'globals.dart';
import '../providers/user_provider.dart';
import '../screens/login_screen.dart';
import '../widgets/session_expired_dialog.dart';

class SessionManager {
  static bool _isDialogShowing = false;

  static void handleSessionExpired() async {
    if (_isDialogShowing) return;

    final context = navigatorKey.currentContext;
    if (context == null) return;

    _isDialogShowing = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SessionExpiredDialog(),
    );

    _isDialogShowing = false;

    // After dialog closes (which happens automatically after 3 seconds), log out
    if (context.mounted) {
      Provider.of<UserProvider>(context, listen: false).clearUser();
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
