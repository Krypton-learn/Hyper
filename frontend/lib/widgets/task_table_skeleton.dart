import 'package:flutter/material.dart';
import 'skeleton.dart';

class TaskTableSkeleton extends StatelessWidget {
  const TaskTableSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF27272A) : Colors.white;
    final headerBgColor = isDark ? const Color(0xFF27272A) : Colors.grey[50];
    final headerBorderColor = isDark ? const Color(0xFF3F3F46) : Colors.grey[200]!;
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
              _buildHeaderCell('ID'),
              _buildHeaderCell('Title'),
              _buildHeaderCell('Description'),
              _buildHeaderCell('Priority'),
              _buildHeaderCell('Status'),
              _buildHeaderCell('Assigned To'),
            ],
          ),
          // Skeleton Rows
          ...List.generate(5, (index) => TableRow(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: rowBorderColor)),
            ),
            children: [
              _buildSkeletonCell(width: 40),
              _buildSkeletonCell(width: 100), // Title
              _buildSkeletonCell(width: 150),
              _buildSkeletonCell(width: 60, height: 24, radius: 12), // Pill shape
              _buildSkeletonCell(width: 80, height: 24, radius: 12), // Pill shape
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: const [
                     Skeleton(width: 28, height: 28, radius: 14), // Avatar
                     SizedBox(width: 8),
                     Skeleton(width: 80, height: 16), // Name
                  ],
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSkeletonCell({double? width, double height = 16, double radius = 8}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Skeleton(width: width, height: height, radius: radius),
      ),
    );
  }
}