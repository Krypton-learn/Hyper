import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/task.dart';


void main() {
  group('Task Model Parsing', () {
    test('parses task from API response correctly', () {
      final json = {
        "task_assigned_user_id": "13aae716-3830-48b5-8f12-4d6a63d690a0",
        "task_name": "test_task",
        "task_priority": "100",
        "task_status": "jkdahlkashdlkjasdh",
        "task_description": "asjdahlksdjh",
        "task_assigned_to": {
          "user_name": "shishir_kc",
          "user_image": "https://ebwdjkhtuejhmijayzyj.supabase.co/storage/v1/object/public/images/810cbab2-8f5a-40d2-bf2d-2b50816a6352",
          "owner": true
        }
      };

      final task = Task.fromJson(json);

      expect(task.name, 'test_task');
      expect(task.description, 'asjdahlksdjh');
      // "100" -> High priority (assumption for now, or just map "100" to something)
      // "jkdahlkashdlkjasdh" -> TaskStatus.toDo (fallback)
      expect(task.status, TaskStatus.toDo); 
      
      expect(task.assignedTo, isNotNull);
      expect(task.assignedTo!.name, 'shishir_kc');
      // We might need to handle image URL in the model if we want to use it
    });
  });
}
