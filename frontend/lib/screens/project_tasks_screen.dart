import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/sidebar.dart';
import '../widgets/task_table.dart';

class ProjectTasksScreen extends StatelessWidget {
  const ProjectTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Task> tasks = [
      Task(
        id: 'T-101',
        description: 'Design new landing page mockup',
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        assignedTo: AssignedUser(name: 'Jane Doe', initials: 'JD', color: Colors.red),
      ),
      Task(
        id: 'T-102',
        description: 'Fix API authentication bug',
        priority: TaskPriority.critical,
        status: TaskStatus.toDo,
        assignedTo: AssignedUser(name: 'Mark Smith', initials: 'MS', color: Colors.orange),
      ),
      Task(
        id: 'T-103',
        description: 'Write user guide documentation',
        priority: TaskPriority.low,
        status: TaskStatus.done,
        assignedTo: AssignedUser(name: 'Alex Lee', initials: 'AL', color: Colors.green),
      ),
      Task(
        id: 'T-104',
        description: 'Update database schema',
        priority: TaskPriority.medium,
        status: TaskStatus.inProgress,
        assignedTo: AssignedUser(name: 'Raj Kumar', initials: 'RK', color: Colors.purple),
      ),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          const Sidebar(currentRoute: '/tasks'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project Tasks',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TaskTable(tasks: tasks),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
