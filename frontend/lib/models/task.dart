import 'package:flutter/material.dart';

enum TaskPriority { high, critical, low, medium }
enum TaskStatus { inProgress, toDo, done }

class AssignedUser {
  final String name;
  final String initials;
  final Color color;

  AssignedUser({
    required this.name,
    required this.initials,
    required this.color,
  });
}

class Task {
  final String id;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final AssignedUser assignedTo;

  Task({
    required this.id,
    required this.description,
    required this.priority,
    required this.status,
    required this.assignedTo,
  });
}
