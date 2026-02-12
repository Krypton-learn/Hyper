import 'package:flutter/material.dart';

class UserAgreementDialog extends StatelessWidget {
  const UserAgreementDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('User Usage Agreement'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '1. Internal Use Only',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'This tool is strictly for internal use by authorized members of Krypton. Access by unauthorized individuals is prohibited.',
            ),
            const SizedBox(height: 12),
            const Text(
              '2. Confidentiality',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'All content within HYPER, including but not limited to documents, files, images, videos, and audio, is the exclusive property of Krypton. You agree to maintain the confidentiality of all such information.',
            ),
            const SizedBox(height: 12),
            const Text(
              '3. No Distribution',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'You are strictly prohibited from distributing, sharing, or leaking any content from this tool to the public or any third party.',
            ),
            const SizedBox(height: 12),
            const Text(
              '4. Consequences of Breach',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Any breach of this agreement, including leakage or misuse of data, will result in strict legal action and immediate termination of access.',
            ),
            const SizedBox(height: 12),
            const Text(
              '5. Acceptance',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'By creating an account and using this tool, you explicitly accept these terms and conditions.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
