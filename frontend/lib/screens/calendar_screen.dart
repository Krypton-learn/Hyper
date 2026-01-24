import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? const Color(0xFF27272A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF3F3F46) : Colors.grey[300]!;
    final weekdayColor = isDark ? Colors.grey[400] : Colors.grey[600];

    final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          const Sidebar(currentRoute: '/calendar'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calendar',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                        boxShadow: isDark ? [] : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header (Month Year)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${months[now.month - 1]} ${now.year}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF3F3F46) : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Today',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Weekdays Row
                          Row(
                            children: weekdays.map((day) => Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: weekdayColor,
                                  ),
                                ),
                              ),
                            )).toList(),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          // Days Grid
                          Expanded(
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 1.2,
                              ),
                              itemCount: daysInMonth + (startingWeekday - 1),
                              itemBuilder: (context, index) {
                                if (index < startingWeekday - 1) {
                                  return const SizedBox.shrink();
                                }
                                final day = index - (startingWeekday - 1) + 1;
                                final isToday = day == now.day;

                                return Container(
                                  decoration: BoxDecoration(
                                    color: isToday ? Colors.blue : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isToday ? null : Border.all(
                                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$day',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                        color: isToday ? Colors.white : textColor,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
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
