import 'package:flutter/material.dart';

class User {
  final String name;
  final String role;
  final String initials;
  final String? image;
  final Color color;

  final String id;
  final bool owner;

  User({
    required this.name,
    required this.role,
    required this.initials,
    this.image,
    required this.color,
    required this.id,
    required this.owner,
  });

  factory User.fromMap(Map<String, dynamic> map) {


    
    return User(
      id: map['id'] ?? '', // Map id field
      name: map['user_name'] ?? 'Guest',
      role: map['role'] ?? (map['owner'] == true ? 'Owner' : 'Not Assigned'), // Handle null role, default to Owner if owner is true
      initials: (map['user_name'] ?? 'Guest').isNotEmpty ? (map['user_name'] ?? 'Guest')[0].toUpperCase() : '?',
      image: map['user_image'], // Map user_image
      color: Colors.blue, // Default color for now
      owner: map['owner'] ?? false, // Map owner field, default false
    );
  }
}
