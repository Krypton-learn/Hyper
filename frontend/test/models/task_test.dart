import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/task.dart';


void main() {
  group('Task Model Parsing', () {
    test('parses task from API response correctly', () {
      final json = {
        "task_id": "13aae716-3830-48b5-8f12-4d6a63d690a0",
        "task_name": "test_task",
        "task_priority": "100",
        "task_status": "done",
        "task_description": "asjdahlksdjh",
        "task_assigned_to": {
          "user_name": "shishir_kc",
          "user_image": "https://example.com/image.png",
          "owner": true
        },
        "task_added_at": "2023-10-27T10:00:00Z",
        "task_completed": "2023-10-28T12:00:00Z"
      };

      final task = Task.fromJson(json);

      expect(task.name, 'test_task');
      expect(task.description, 'asjdahlksdjh');
      expect(task.priority, TaskPriority.high); // "100" -> High
      expect(task.status, TaskStatus.done); 
      
      expect(task.assignedTo, isNotNull);
      expect(task.assignedTo!.name, 'shishir_kc');

      expect(task.addedAt, isNotNull);
      expect(task.addedAt!.year, 2023);
      
      expect(task.completedAt, isNotNull);
      expect(task.completedAt!.day, 28);
    });

    test('defaults status to In Progress if task_completed is null', () {
      final json = {
        "task_id": "123",
        "task_name": "Incomplete Task",
        "task_priority": "medium",
        "task_status": "todo", // Even if backend says todo
        "task_description": "desc",
        "task_added_at": "2023-10-27T10:00:00Z",
        "task_completed": null 
      };

      final task = Task.fromJson(json);

      // Requirement: if task_completed is null, show in progress
      expect(task.status, TaskStatus.inProgress);
      expect(task.completedAt, isNull);
    });

    test('defaults status to Done if task_completed is NOT null but status missing', () {
       final json = {
        "task_id": "123",
        "task_name": "Completed Task",
        "task_priority": "medium",
        // "task_status": missing
        "task_description": "desc",
        "task_completed": "2023-10-29T10:00:00Z" 
      };

      final task = Task.fromJson(json);
      expect(task.status, TaskStatus.done);
    });

    test('parses task_added correctly when task_added_at is missing', () {
      final json = {
        "task_id": "999",
        "task_name": "Legacy Task",
        "task_priority": "low",
        "task_status": "todo",
        "task_description": "desc",
        "task_added": "2024-01-01T10:00:00Z", // Different key
        "task_completed": null
      };

      final task = Task.fromJson(json);
      expect(task.addedAt, isNotNull);
      expect(task.addedAt!.year, 2024);
      expect(task.addedAt!.month, 1);
      expect(task.addedAt!.day, 1);
    });
  });
}
