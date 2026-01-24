import 'package:flutter/material.dart';
import '../screens/project_tasks_screen.dart';
import '../screens/users_screen.dart';
import '../screens/documents_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/home_screen.dart';
import '../screens/calendar_screen.dart';

class Sidebar extends StatelessWidget {
  final String currentRoute;

  const Sidebar({super.key, this.currentRoute = '/home'});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF18181B) : Colors.white; // Soft background
    final iconColorActive = isDark ? Colors.white : Colors.black87;
    final activeBgColor = isDark ? const Color(0xFF27272A) : Colors.grey[100]; // Soft active bg
    final logoBgColor = isDark ? const Color(0xFF27272A) : Colors.grey[200];

    return Container(
      width: 80,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          // Logo placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: logoBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.dashboard, color: Colors.grey),
          ),
          const SizedBox(height: 48),
          
          // Navigation Items
          _buildNavItem(
            context,
            Icons.home_outlined,
            currentRoute == '/home',
            iconColorActive: iconColorActive,
            activeBgColor: activeBgColor,
            onTap: () {
              if (currentRoute != '/home') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const HomeScreen(),
                    transitionDuration: Duration.zero,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 24),
          _buildNavItem(
            context,
            Icons.assignment,
            currentRoute == '/tasks',
            iconColorActive: iconColorActive,
            activeBgColor: activeBgColor,
            onTap: () {
              if (currentRoute != '/tasks') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const ProjectTasksScreen(),
                    transitionDuration: Duration.zero,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 24),
          _buildNavItem(
            context,
            Icons.people_outlined,
            currentRoute == '/users',
            iconColorActive: iconColorActive,
            activeBgColor: activeBgColor,
            onTap: () {
              if (currentRoute != '/users') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const UsersScreen(),
                    transitionDuration: Duration.zero,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 24),
          _buildNavItem(
            context,
            Icons.folder_open,
            currentRoute == '/documents',
            iconColorActive: iconColorActive,
            activeBgColor: activeBgColor,
            onTap: () {
              if (currentRoute != '/documents') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const DocumentsScreen(),
                    transitionDuration: Duration.zero,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 24),
          _buildNavItem(
            context,
            Icons.calendar_today_outlined,
            currentRoute == '/calendar',
            iconColorActive: iconColorActive,
            activeBgColor: activeBgColor,
            onTap: () {
              if (currentRoute != '/calendar') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const CalendarScreen(),
                    transitionDuration: Duration.zero,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 24),
          _buildNavItem(
            context,
            Icons.settings_outlined,
            currentRoute == '/settings',
            iconColorActive: iconColorActive,
            activeBgColor: activeBgColor,
            onTap: () {
              if (currentRoute != '/settings') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const SettingsScreen(),
                    transitionDuration: Duration.zero,
                  ),
                );
              }
            },
          ),
          
          const Spacer(),
          
          _buildNavItem(context, Icons.exit_to_app, false,
            iconColorActive: iconColorActive, activeBgColor: activeBgColor),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, bool isActive, 
      {VoidCallback? onTap, required Color iconColorActive, required Color? activeBgColor}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? activeBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isActive ? iconColorActive : Colors.grey,
          size: 24,
        ),
      ),
    );
  }
}
