import 'package:flutter/material.dart';

enum TaskPriority { high, critical, low, medium }
enum TaskStatus { 
  inProgress, 
  toDo, 
  done;

  String get toApiString {
    switch (this) {
      case TaskStatus.inProgress:
        return 'inprogress';
      case TaskStatus.toDo:
        return 'todo';
      case TaskStatus.done:
        return 'done';
    }
  }
}

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
  final String? assignedUserId;
  final DateTime? addedAt;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.priority,
    required this.status,
    this.assignedTo,
    this.assignedUserId,
    this.addedAt,
    this.completedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['task_id']?.toString() ?? json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(), 
      name: json['task_name'] ?? json['name'] ?? 'Untitled Task',
      description: json['task_description'] ?? json['description'] ?? '',
      priority: _parsePriority(json['task_priority'] ?? json['priority']),
      status: _parseStatus(json['task_status'] ?? json['status'], json['task_completed']),
      assignedTo: json['task_assigned_to'] != null 
          ? AssignedUser.fromJson(json['task_assigned_to']) 
          : (json['assigned_to'] != null ? AssignedUser.fromJson(json['assigned_to']) : null),
      assignedUserId: json['task_assigned_user_id']?.toString(),
      addedAt: json['task_added_at'] != null 
          ? DateTime.tryParse(json['task_added_at']) 
          : (json['task_added'] != null ? DateTime.tryParse(json['task_added']) : null),
      completedAt: json['task_completed'] != null ? DateTime.tryParse(json['task_completed']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_name': name,
      'task_description': description,
      'task_priority': priority.toString().split('.').last,
      'task_status': status.toApiString,
      'task_assigned_to': assignedTo?.toJson(),
      'task_added_at': addedAt?.toIso8601String(),
      'task_completed': completedAt?.toIso8601String(),
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

  static TaskStatus _parseStatus(String? status, dynamic completedAt) {
    if (completedAt == null) {
        return TaskStatus.inProgress;
    }
    switch (status?.toLowerCase()) {
      case 'inprogress':
        return TaskStatus.inProgress;
      case 'todo':
        return TaskStatus.toDo;
      case 'done':
        return TaskStatus.done;
      default:
        // If completedAt is not null but status is unknown/missing, we might assume done or toDo?
        // But the requirement says "if it is null show in progress".
        // If it is NOT null, it implies it's completed or has a specific status. 
        // Let's fallback to the status if present, otherwise if completedAt is set, it's likely done.
        return TaskStatus.done; 
    }
  }
}
