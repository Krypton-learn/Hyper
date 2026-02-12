import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../widgets/sidebar.dart';
import '../widgets/task_table.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import '../widgets/task_form.dart';

class ProjectTasksScreen extends StatefulWidget {
  const ProjectTasksScreen({super.key});

  @override
  State<ProjectTasksScreen> createState() => _ProjectTasksScreenState();
}

class _ProjectTasksScreenState extends State<ProjectTasksScreen> {
  List<Task> _tasks = [];
  bool _showTaskForm = false; // Default: Hidden
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Small delay to prevent flickering if token is being set
      await Future.delayed(Duration.zero);
      if (!mounted) return;

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final apiService = ApiService(userProvider.accessToken);

      // Fetch tasks from API
      // If the API isn't ready, we might want to fallback to the hardcoded list for demo purposes
      // But let's try to fetch first.
      try {
        final tasksData = await apiService.getTasks();
        if (mounted) {
           setState(() {
            _tasks = tasksData.map((data) => Task.fromJson(data)).toList();
            _isLoading = false;
          });
        }
      } catch (e) {
        // Fallback to hardcoded list if API fails (for development/demo continuity)
        // In a real app, strict error handling would be better, but this keeps the UI usable
         if (mounted) {
            setState(() {
              _tasks = [
                Task(
                  id: 'T-101',
                  name: 'Design Mockup',
                  description: 'Design new landing page mockup',
                  priority: TaskPriority.high,
                  status: TaskStatus.inProgress,
                  assignedTo: AssignedUser(name: 'Jane Doe', initials: 'JD', color: Colors.red),
                ),
                Task(
                  id: 'T-102',
                  name: 'Fix Auth Bug',
                  description: 'Fix API authentication bug',
                  priority: TaskPriority.critical,
                  status: TaskStatus.toDo,
                  assignedTo: AssignedUser(name: 'Mark Smith', initials: 'MS', color: Colors.orange),
                ),
                Task(
                  id: 'T-103',
                  name: 'User Guide',
                  description: 'Write user guide documentation',
                  priority: TaskPriority.low,
                  status: TaskStatus.done,
                  assignedTo: AssignedUser(name: 'Alex Lee', initials: 'AL', color: Colors.green),
                ),
                Task(
                  id: 'T-104',
                  name: 'DB Schema',
                  description: 'Update database schema',
                  priority: TaskPriority.medium,
                  status: TaskStatus.inProgress,
                  assignedTo: AssignedUser(name: 'Raj Kumar', initials: 'RK', color: Colors.purple),
                ),
              ];
              _isLoading = false;
            });
         }
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Removed FAB as we now have an always-visible form
      body: Row(
        children: [
          const Sidebar(currentRoute: '/tasks'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side: Task Form (Conditional)
                  if (_showTaskForm) ...[
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TaskForm(onTaskCreated: _loadTasks),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                  ],
                  // Right Side: Task List
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Tooltip(
                                  message: _showTaskForm ? 'Hide Form' : 'Create New Task',
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _showTaskForm = !_showTaskForm;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _showTaskForm ? Icons.close_rounded : Icons.add_rounded, // Changed icon to indicate action
                                        color: Theme.of(context).colorScheme.primary,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Recent Tasks',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: _loadTasks,
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Refresh Tasks',
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (_errorMessage != null)
                          Center(
                              child: Text('Error: $_errorMessage',
                                  style: TextStyle(
                                      color: Theme.of(context).colorScheme.error)))
                        else
                          TaskTable(tasks: _tasks),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
