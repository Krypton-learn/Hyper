import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/sidebar.dart';
import '../widgets/skeleton.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final token = Provider.of<UserProvider>(context, listen: false).accessToken;
      if (token == null) {
        setState(() {
          _error = 'Authentication required';
          _isLoading = false;
        });
        return;
      }
      final data = await ApiService(token).getTeamMembers();
      setState(() {
        _users = data.map((e) => User.fromMap(e)).toList();
        _isLoading = false;
        _error = null; // Clear any previous error on success
      });
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      if (_users.isNotEmpty) {
        // If we already have data, show a snackbar instead of replacing the screen
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to refresh: $errorMessage'),
              backgroundColor: Colors.red[400],
            ),
          );
        }
      } else {
        // Only show full screen error if we have no data
        setState(() {
          _error = errorMessage;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF27272A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final roleTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final dividerColor = isDark ? const Color(0xFF3F3F46) : Colors.grey[100]!;

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
                  // Content
                  if (_isLoading)
                    _buildLoadingList(cardColor, dividerColor)
                  else if (_error != null)
                    _buildErrorState(textColor)
                  else
                    _buildUserList(cardColor, dividerColor, textColor, roleTextColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingList(Color cardColor, Color dividerColor) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (context, index) => Divider(
          color: dividerColor,
          height: 1,
        ),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                const Skeleton(width: 48, height: 48, radius: 24),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Skeleton(width: 120, height: 20, radius: 4),
                    const SizedBox(height: 8),
                    const Skeleton(width: 80, height: 16, radius: 4),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            _error ?? 'An error occurred',
            style: TextStyle(color: textColor, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _fetchUsers();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(Color cardColor, Color dividerColor, Color textColor, Color? roleTextColor) {
    if (_users.isEmpty) {
      return Center(
        child: Text(
          'No team members found.',
          style: TextStyle(color: textColor, fontSize: 16),
        ),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Theme.of(context).brightness == Brightness.dark ? [] : [
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
        itemCount: _users.length,
        separatorBuilder: (context, index) => Divider(
          color: dividerColor,
          height: 1,
        ),
        itemBuilder: (context, index) {
          final user = _users[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: user.color.withValues(alpha: 0.2),
                  backgroundImage: user.image != null ? NetworkImage(user.image!) : null,
                  child: user.image == null
                      ? Text(
                          user.initials,
                          style: TextStyle(
                            color: user.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : null,
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
                const Spacer(),
                if (Provider.of<UserProvider>(context).isOwner && 
                    user.name != Provider.of<UserProvider>(context).currentUser?.name)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    color: roleTextColor,
                    onPressed: () => _editUserRole(user),
                    tooltip: 'Edit Role',
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _editUserRole(User user) async {
    final List<String> roles = [
      'Back_end_developer',
      'Fron_end_developer', 
      'Ui_ux_developer',
      'Mentor',
      'Visitor'
    ];
    String? selectedRole = roles.contains(user.role) ? user.role : roles.first;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF27272A) : Colors.white,
        title: Text('Edit Role', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update role for ${user.name}',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: InputDecoration(
                labelText: 'Role',
                labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              dropdownColor: isDark ? const Color(0xFF27272A) : Colors.white,
              items: roles.map((String role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(
                    role,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                selectedRole = newValue;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final token = Provider.of<UserProvider>(context, listen: false).accessToken;
                if (token == null) throw Exception('Authentication required');
                
                if (selectedRole != null) {
                  await ApiService(token).updateUserRole(user.id, selectedRole!);
                  if (mounted) {
                    Navigator.of(context).pop();
                    await _fetchUsers(); // Refresh list and wait for it
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User role updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
