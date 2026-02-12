import 'package:flutter/material.dart';
import '../models/task.dart';
import 'pills.dart';

class TaskTable extends StatelessWidget {
  final List<Task> tasks;

  const TaskTable({super.key, required this.tasks});

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
        borderRadius: BorderRadius.circular(24), // Increased to match TaskForm
        boxShadow: isDark ? [] : [
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
          0: FixedColumnWidth(100), // ID
          1: FlexColumnWidth(2),    // Description
          2: FixedColumnWidth(120), // Priority
          3: FixedColumnWidth(140), // Status
          4: FixedColumnWidth(180), // Assigned To
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Header Row
          TableRow(
            decoration: BoxDecoration(
              color: headerBgColor,
              border: Border(bottom: BorderSide(color: headerBorderColor)),
            ),
            children: [
              _buildHeaderCell('ID', textColor),
              _buildHeaderCell('Description', textColor),
              _buildHeaderCell('Priority', textColor),
              _buildHeaderCell('Status', textColor),
              _buildHeaderCell('Assigned To', textColor),
            ],
          ),
          // Data Rows
          ...tasks.map((task) => TableRow(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: rowBorderColor)),
            ),
            children: [
              _buildDataCell('#${task.id}', textColor),
              _buildDataCell(task.description, textColor),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: PriorityPill(priority: task.priority),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: StatusPill(status: task.status),
                ),
              ),
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
                      Text(
                        task.assignedTo!.name,
                        style: TextStyle(color: textColor),
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
            ],
          )),
        ],
      ),
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
}
