import 'package:flutter/material.dart';

enum TaskPriority { high, critical, low, medium }
enum TaskStatus { inProgress, toDo, done }

class AssignedUser {
  final String name;
  final String initials;
  final Color color;
  final String? image;

  AssignedUser({
    required this.name,
    required this.initials,
    required this.color,
    this.image,
  });

  factory AssignedUser.fromJson(Map<String, dynamic> json) {
    String name = json['user_name'] ?? json['name'] ?? 'Unknown';
    String initials = json['initials'] ?? _getInitials(name);
    return AssignedUser(
      name: name,
      initials: initials,
      color: Colors.blue, // Placeholder, real impl might need a color parser
      image: json['user_image'],
    );
  }

  static String _getInitials(String name) {
    if (name.isEmpty) return '';
    List<String> parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'initials': initials,
      'user_image': image,
    };
  }
}

class Task {
  final String id;
  final String name;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final AssignedUser? assignedTo;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.priority,
    required this.status,
    this.assignedTo,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      // API doesn't return ID yet, so we use a hash or random string for now, or fallback to name
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(), 
      name: json['task_name'] ?? json['name'] ?? 'Untitled Task',
      description: json['task_description'] ?? json['description'] ?? '',
      priority: _parsePriority(json['task_priority'] ?? json['priority']),
      status: _parseStatus(json['task_status'] ?? json['status']),
      assignedTo: json['task_assigned_to'] != null 
          ? AssignedUser.fromJson(json['task_assigned_to']) 
          : (json['assigned_to'] != null ? AssignedUser.fromJson(json['assigned_to']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_name': name,
      'task_description': description,
      'task_priority': priority.toString().split('.').last,
      'task_status': status.toString().split('.').last,
      'task_assigned_to': assignedTo?.toJson(),
    };
  }

  static TaskPriority _parsePriority(dynamic priority) {
    final p = priority.toString().toLowerCase();
    if (p == 'high' || p == '100') return TaskPriority.high;
    if (p == 'critical') return TaskPriority.critical;
    if (p == 'low') return TaskPriority.low;
    if (p == 'medium') return TaskPriority.medium;
    return TaskPriority.medium;
  }

  static TaskStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'inprogress':
        return TaskStatus.inProgress;
      case 'todo':
        return TaskStatus.toDo;
      case 'done':
        return TaskStatus.done;
      default:
        // Handle weird placeholder statuses by defaulting to toDo or verify if they map to something else
        return TaskStatus.toDo;
    }
  }
}
