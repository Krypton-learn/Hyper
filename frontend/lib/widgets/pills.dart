import 'package:flutter/material.dart';
import '../models/task.dart';

class PriorityPill extends StatelessWidget {
  final TaskPriority priority;

  const PriorityPill({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (priority) {
      case TaskPriority.high:
        backgroundColor = const Color(0xFFD32F2F);
        textColor = Colors.white;
        label = 'High';
        break;
      case TaskPriority.critical:
        backgroundColor = const Color(0xFFD32F2F);
        textColor = Colors.white;
        label = 'Critical';
        break;
      case TaskPriority.low:
        backgroundColor = const Color(0xFFA5D6A7);
        textColor = const Color(0xFF2E7D32);
        label = 'Low';
        break;
      case TaskPriority.medium:
        backgroundColor = const Color(0xFFFFCC80);
        textColor = const Color(0xFFEF6C00);
        label = 'Medium';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final TaskStatus status;

  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case TaskStatus.inProgress:
        backgroundColor = const Color(0xFFBBDEFB);
        textColor = const Color(0xFF1976D2);
        label = 'In Progress';
        break;
      case TaskStatus.toDo:
        backgroundColor = const Color(0xFFFFF9C4);
        textColor = const Color(0xFFFBC02D);
        label = 'To Do';
        break;
      case TaskStatus.done:
        backgroundColor = const Color(0xFFC8E6C9);
        textColor = const Color(0xFF388E3C);
        label = 'Done';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
