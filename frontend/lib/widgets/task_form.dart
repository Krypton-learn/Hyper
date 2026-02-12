import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';

class TaskForm extends StatefulWidget {
  final VoidCallback onTaskCreated;

  const TaskForm({super.key, required this.onTaskCreated});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  TaskStatus _status = TaskStatus.toDo;
  String? _assignedToUserId;
  bool _isLoading = false;
  String? _errorMessage;
  List<User> _teamMembers = [];
  bool _isLoadingMembers = false;

  @override
  void initState() {
    super.initState();
    _fetchTeamMembers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchTeamMembers() async {
    setState(() {
      _isLoadingMembers = true;
    });
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.accessToken != null) {
        final apiService = ApiService(userProvider.accessToken);
        final membersData = await apiService.getTeamMembers();
        if (mounted) {
          setState(() {
            _teamMembers = membersData.map((e) => User.fromMap(e)).toList();
            _isLoadingMembers = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMembers = false;
          // Optionally handle error here, or just fail silently for the dropdown
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final apiService = ApiService(userProvider.accessToken);

        await apiService.createTask(
          name: _nameController.text,
          description: _descriptionController.text,
          priority: _priority.toString().split('.').last,
          status: _status.toString().split('.').last,
          assignedToUserId: _assignedToUserId,
        );

        if (mounted) {
          _nameController.clear();
          _descriptionController.clear();
          setState(() {
            _priority = TaskPriority.medium;
            _status = TaskStatus.toDo;
            _assignedToUserId = null;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task created successfully')),
          );
          widget.onTaskCreated();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = e.toString().replaceAll('Exception: ', '');
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF27272A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final inputFillColor = isDark ? const Color(0xFF3F3F46).withValues(alpha: 0.5) : Colors.grey[100];
    final borderSide = BorderSide(color: isDark ? const Color(0xFF52525B) : Colors.grey[300]!);

    InputDecoration buildDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        filled: true,
        fillColor: inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: borderSide,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: borderSide,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );
    }

    return Container(
      padding: const EdgeInsets.all(32), // Increased padding
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24), // More rounded
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: isDark ? Border.all(color: const Color(0xFF3F3F46)) : null,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add_task_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Create New Task',
                  style: TextStyle(
                    fontSize: 22, // Slightly larger
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            TextFormField(
              controller: _nameController,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
              decoration: buildDecoration('Task Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a task name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descriptionController,
              style: TextStyle(color: textColor),
              decoration: buildDecoration('Description').copyWith(
                alignLabelWithHint: true,
              ),
              maxLines: 4, // More lines for description
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TaskPriority>(
                    value: _priority,
                    style: TextStyle(color: textColor),
                    dropdownColor: cardColor,
                    decoration: buildDecoration('Priority'),
                    items: TaskPriority.values.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Row(
                          children: [
                            Icon(Icons.flag_rounded, 
                              size: 16, 
                              color: priority == TaskPriority.critical ? Colors.red : 
                                     priority == TaskPriority.high ? Colors.orange : 
                                     priority == TaskPriority.medium ? Colors.blue : Colors.green
                            ),
                            const SizedBox(width: 8),
                            Text(priority.toString().split('.').last.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _priority = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: DropdownButtonFormField<TaskStatus>(
                    value: _status,
                    style: TextStyle(color: textColor),
                    dropdownColor: cardColor,
                    decoration: buildDecoration('Status'),
                    items: TaskStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.toString().split('.').last.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _status = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _assignedToUserId,
              style: TextStyle(color: textColor),
              dropdownColor: cardColor,
              decoration: buildDecoration('Assign To'),
              items: _teamMembers.map((user) {
                return DropdownMenuItem(
                  value: user.id,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: user.color,
                        backgroundImage: user.image != null ? NetworkImage(user.image!) : null,
                        child: user.image == null
                            ? Text(user.initials, style: const TextStyle(fontSize: 8, color: Colors.white))
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(user.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _isLoadingMembers ? null : (value) {
                setState(() {
                  _assignedToUserId = value;
                });
              },
              hint: _isLoadingMembers ? const Text('Loading members...') : const Text('Select a member'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 0,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add, size: 20),
                          SizedBox(width: 8),
                          Text('Create Task'),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
