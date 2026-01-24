import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/sidebar.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<User> users = [
      User(name: 'Jane Doe', role: 'UI/UX Designer', initials: 'JD', color: Colors.red),
      User(name: 'Mark Smith', role: 'Backend Developer', initials: 'MS', color: Colors.orange),
      User(name: 'Alex Lee', role: 'Technical Writer', initials: 'AL', color: Colors.green),
      User(name: 'Raj Kumar', role: 'Database Admin', initials: 'RK', color: Colors.purple),
      User(name: 'Sarah Jones', role: 'Project Manager', initials: 'SJ', color: Colors.blue),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF27272A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final roleTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final dividerColor = isDark ? const Color(0xFF3F3F46) : Colors.grey[100];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          const Sidebar(currentRoute: '/users'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Team Members',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Using a card-like list for users
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isDark ? [] : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: users.length,
                      separatorBuilder: (context, index) => Divider(
                        color: dividerColor,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: user.color.withValues(alpha: 0.2),
                                child: Text(
                                  user.initials,
                                  style: TextStyle(
                                    color: user.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.role,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: roleTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
    );
  }
}
