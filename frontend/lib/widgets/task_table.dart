import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import 'pills.dart';
import '../services/toast_service.dart';
import '../widgets/custom_toast.dart';

class TaskTable extends StatefulWidget {
  final List<Task> tasks;
  final VoidCallback? onTaskUpdated;

  const TaskTable({super.key, required this.tasks, this.onTaskUpdated});

  @override
  State<TaskTable> createState() => _TaskTableState();
}

class _TaskTableState extends State<TaskTable> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Total animation duration
    )..forward();
  }

  @override
  void didUpdateWidget(TaskTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tasks != oldWidget.tasks) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF27272A) : Colors.white; // Soft surface
    final textColor = isDark ? Colors.white : Colors.black87;
    final headerBgColor = isDark ? const Color(0xFF27272A) : Colors.grey[50]; // Match card color or slightly different
    final headerBorderColor = isDark ? const Color(0xFF3F3F46) : Colors.grey[200]!; // Soft border
    final rowBorderColor = isDark ? const Color(0xFF3F3F46) : Colors.grey[100]!;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
        border: isDark ? Border.all(color: const Color(0xFF3F3F46)) : null,
      ),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(80),  // ID (truncated)
          1: FlexColumnWidth(1.5),  // Title
          2: FlexColumnWidth(2),    // Description
          3: FixedColumnWidth(120), // Priority
          4: FixedColumnWidth(140), // Status
          5: FixedColumnWidth(180), // Assigned To
          6: FixedColumnWidth(80),  // View
          7: FixedColumnWidth(80),  // Edit
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Header Row (Static, no animation)
          TableRow(
            decoration: BoxDecoration(
              color: headerBgColor,
              border: Border(bottom: BorderSide(color: headerBorderColor)),
            ),
            children: [
              _buildHeaderCell('ID', textColor),
              _buildHeaderCell('Title', textColor),
              _buildHeaderCell('Description', textColor),
              _buildHeaderCell('Priority', textColor),
              _buildHeaderCell('Status', textColor),
              _buildHeaderCell('Assigned To', textColor),
              _buildHeaderCell('View', textColor),
              _buildHeaderCell('Edit', textColor),
            ],
          ),
          // Data Rows (Animated)
          ...widget.tasks.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;
            
            // Calculate delay based on index for staggered effect
            final double start = (index * 0.1).clamp(0.0, 0.8);
            final double end = (start + 0.4).clamp(0.0, 1.0);
            
            final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(start, end, curve: Curves.easeOut),
              ),
            );

            return TableRow(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: rowBorderColor)),
              ),
              children: [
                _buildAnimatedCell(
                  animation,
                  _buildDataCell('#${task.id.length > 5 ? task.id.substring(0, 5) : task.id}', textColor),
                ),
                _buildAnimatedCell(
                  animation,
                  _buildDataCell(task.name, textColor),
                ),
                _buildAnimatedCell(
                  animation,
                  _buildDataCell(task.description, textColor),
                ),
                _buildAnimatedCell(
                  animation,
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: PriorityPill(priority: task.priority),
                    ),
                  ),
                ),
                _buildAnimatedCell(
                  animation,
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: StatusPill(status: task.status),
                    ),
                  ),
                ),
                _buildAnimatedCell(
                  animation,
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        if (task.assignedTo != null) ...[
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: task.assignedTo!.color.withValues(alpha: 0.2),
                            backgroundImage: task.assignedTo!.image != null 
                                ? NetworkImage(task.assignedTo!.image!) 
                                : null,
                            child: task.assignedTo!.image == null 
                                ? Text(
                                    task.assignedTo!.initials,
                                    style: TextStyle(
                                      color: task.assignedTo!.color,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              task.assignedTo!.name,
                              style: TextStyle(color: textColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ] else ...[
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.grey.withValues(alpha: 0.2),
                            child: const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Unassigned',
                            style: TextStyle(color: textColor.withValues(alpha: 0.5)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // View Column
                _buildAnimatedCell(
                  animation,
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: IconButton(
                      icon: Icon(Icons.visibility_outlined, color: textColor.withValues(alpha: 0.7)),
                      onPressed: () => _showTaskDetails(context, task),
                      tooltip: 'View Details',
                    ),
                  ),
                ),
                // Edit Column
                _buildAnimatedCell(
                  animation,
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        final bool isAssignedById = task.assignedUserId != null && 
                                                  task.assignedUserId == userProvider.currentUser?.id;
                        final bool isAssignedByName = task.assignedTo != null && 
                                                    task.assignedTo!.name == userProvider.currentUser?.name;
                        
                        final canEdit = isAssignedById || isAssignedByName;
                        
                        if (canEdit) {
                           return IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                            onPressed: () => _showEditTaskDialog(context, task),
                            tooltip: 'Edit Status',
                          );
                        } else {
                          return Tooltip(
                            message: 'Only the assigned user can edit this task',
                            child: Icon(Icons.lock_outline, color: textColor.withValues(alpha: 0.3), size: 20),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAnimatedCell(Animation<double> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation,
          child: Transform.translate(
            offset: Offset(0, -20 * (1 - animation.value)), // Slide from top
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildHeaderCell(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
    );
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.name),
        content: SizedBox(
          width: 500, // Make it wider
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${task.id}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                const SizedBox(height: 4),
                Text(task.description),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Priority: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    PriorityPill(priority: task.priority),
                  ],
                ),
                 const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    StatusPill(status: task.status),
                  ],
                ),
                 const SizedBox(height: 16),
                Row(
                  children: [
                     const Icon(Icons.person_outline, size: 20, color: Colors.grey),
                     const SizedBox(width: 8),
                     Text('Assigned To: ${task.assignedTo?.name ?? "Unassigned"}'),
                  ],
                ),
                if (task.addedAt != null) ...[
                   const SizedBox(height: 16),
                   const Divider(),
                   const SizedBox(height: 8),
                   Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                         const SizedBox(width: 8),
                         Text(
                          'Created: ${DateFormat('MMM d, yyyy h:mm a').format(task.addedAt!.add(const Duration(hours: 5, minutes: 45)))}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                   ),
                ],
                 if (task.completedAt != null) ...[
                   const SizedBox(height: 8),
                   Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                         const SizedBox(width: 8),
                         Text(
                          'Completed: ${DateFormat('MMM d, yyyy h:mm a').format(task.completedAt!.add(const Duration(hours: 5, minutes: 45)))}',
                           style: TextStyle(color: Colors.green[700], fontSize: 13),
                        ),
                      ],
                   ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    TaskStatus selectedStatus = task.status;
    bool isUpdating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Update Task Status'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUpdating)
                  const LinearProgressIndicator(),
                ...TaskStatus.values.map((status) {
                return RadioListTile<TaskStatus>(
                  title: StatusPill(status: status),
                  value: status,
                  groupValue: selectedStatus,
                  onChanged: isUpdating ? null : (TaskStatus? value) {
                    if (value != null) {
                      setState(() {
                        selectedStatus = value;
                      });
                    }
                  },
                );
              }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isUpdating ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isUpdating ? null : () async {
                  setState(() {
                    isUpdating = true;
                  });
                  
                  try {
                    final userProvider = Provider.of<UserProvider>(context, listen: false);
                    // Use a fallback empty token if null, though it should handle auth error
                    final apiService = ApiService(userProvider.accessToken ?? '');
                    
                    await apiService.updateTaskStatus(
                      task.id, 
                      selectedStatus.toApiString
                    );
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      ToastService.show(context, 'Status updated to ${selectedStatus.toApiString}', ToastType.success);
                      widget.onTaskUpdated?.call();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      setState(() {
                        isUpdating = false;
                      });
                      ToastService.show(context, 'Failed to update status: $e', ToastType.error);
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
