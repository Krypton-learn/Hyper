
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../utils/session_manager.dart';
import 'toast_service.dart';
import '../widgets/custom_toast.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
  final String? token;
  final http.Client client;

  ApiService([this.token, http.Client? client]) : client = client ?? http.Client();

  /// Get the MediaType based on file extension
  MediaType? _getMediaType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      case 'pdf':
        return MediaType('application', 'pdf');
      default:
        return MediaType('application', 'octet-stream'); // Default to binary data
    }
  }

  Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    required String code,
    File? image,
  }) async {
    final url = Uri.parse('$baseUrl/user/signup/');
    
    try {
      var request = http.MultipartRequest('POST', url);
      
      request.fields['user_name'] = username;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['code'] = code;

      if (image != null) {
        final mediaType = _getMediaType(image.path);
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            image.path,
            contentType: mediaType,
          ),
        );
      }

      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid code');
      } else if (response.statusCode == 400) {
        throw Exception('Email is already registered!');
      } else if (response.statusCode == 429) {
        ToastService.showGlobal("daam looks like you have hit the api limit try again after 1min", ToastType.error);
        throw Exception('Too many requests. Try again after 1 min');
      } else {
        // Attempt to parse error message from body, fallback to status code
        try {
          final errorBody = jsonDecode(response.body);
          throw Exception(errorBody['detail'] ?? 'Signup failed: ${response.statusCode}');
        } catch (e) {
             if (e.toString().contains('Signup failed')) rethrow;
             if (e.toString().contains('Invalid code')) rethrow;
             if (e.toString().contains('Email is already registered!')) rethrow;
             throw Exception('Signup failed: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Remove "Exception: " prefix if present to avoid doubling it in the UI if logic fails
      final message = e.toString().replaceAll('Exception: ', '');
      if (message.contains('Invalid code')) {
        throw Exception('Invalid code');
      }
      if (message.contains('Email is already registered!')) {
        throw Exception('Email is already registered!');
      }
       // Only wrap actual network errors (like socket exception), not our own thrown exceptions
      if (e is http.ClientException || e.toString().contains('SocketException') || e.toString().contains('Network error')) {
           throw Exception('Network error: Please check your connection');
      }
      throw Exception(message);
    }
  }
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/user/login/');
    
    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'accept': 'application/json',
        },
        body: {
          'grant_type': 'password',
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 429) {
        ToastService.showGlobal("daam looks like you have hit the api limit try again after 1min", ToastType.error);
        throw Exception('Too many requests. Try again after 1 min');
      } else {
        // Attempt to parse error message from body, fallback to status code
        try {
          final errorBody = jsonDecode(response.body);
          throw Exception(errorBody['detail'] ?? 'Login failed: ${response.statusCode}');
        } catch (e) {
             throw Exception('Login failed: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Remove "Exception: " prefix if present
      final message = e.toString().replaceAll('Exception: ', '');
      
       // Only wrap actual network errors
      if (e is http.ClientException || e.toString().contains('SocketException') || e.toString().contains('Network error')) {
           throw Exception('Network error: Please check your connection');
      }
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String accessToken) async {
    final url = Uri.parse('$baseUrl/users/me/');
    
    try {
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 429) {
        ToastService.showGlobal("daam looks like you have hit the api limit try again after 1min", ToastType.error);
        throw Exception('Too many requests. Try again after 1 min');
      } else if (response.statusCode == 401) {
        SessionManager.handleSessionExpired();
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Session expired')) rethrow;
      throw Exception('Failed to load user profile: $e');
    }
  }

  Future<List<dynamic>> getTeamMembers() async {
    if (token == null) throw Exception('Authentication required');
    final url = Uri.parse('$baseUrl/team_members/');
    
    try {
      final response = await client.get(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 429) {
        ToastService.showGlobal("daam looks like you have hit the api limit try again after 1min", ToastType.error);
        throw Exception('Too many requests. Try again after 1 min');
      } else if (response.statusCode == 401) {
        SessionManager.handleSessionExpired();
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to load team members: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Session expired')) rethrow;
      if (e is http.ClientException || e.toString().contains('SocketException')) {
           throw Exception('Network error: Please check your connection');
      }
      throw Exception('Failed to load team members: $e');
    }
  }

  Future<void> updateUserRole(String userId, String role) async {
    if (token == null) throw Exception('Authentication required');
    final url = Uri.parse('$baseUrl/update/user/role/');
    
    try {
      final response = await client.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'user_role': role
        }),
      );

      if (response.statusCode == 200) {
        return; // Success
      } else if (response.statusCode == 429) {
        ToastService.showGlobal("daam looks like you have hit the api limit try again after 1min", ToastType.error);
        throw Exception('Too many requests. Try again after 1 min');
      } else if (response.statusCode == 401) {
        SessionManager.handleSessionExpired();
        throw Exception('Session expired');
      } else if (response.statusCode == 304) {
        throw Exception('User does not exist!');
      } else {
         // Attempt to parse error message
        try {
          final errorBody = jsonDecode(response.body);
          throw Exception(errorBody['detail'] ?? 'Failed to update user role: ${response.statusCode}');
        } catch (e) {
           if (e.toString().contains('User does not exist!')) rethrow;
           throw Exception('Failed to update user role: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is http.ClientException || e.toString().contains('SocketException')) {
           throw Exception('Network error: Please check your connection');
      }
      // Clean up exception message
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> createTask({
    required String name,
    required String description,
    required String priority,
    required String status,
    String? assignedToUserId,
  }) async {
    if (token == null) throw Exception('Authentication required');
    final url = Uri.parse('$baseUrl/upload/task/');

    try {
      final body = {
        'task_name': name,
        'task_description': description,
        'task_priority': priority,
        'task_status': status,
        if (assignedToUserId != null) 'task_assigned_user_id': assignedToUserId,
      };

      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return; // Success
      } else if (response.statusCode == 429) {
        ToastService.showGlobal("daam looks like you have hit the api limit try again after 1min", ToastType.error);
        throw Exception('Too many requests. Try again after 1 min');
      } else if (response.statusCode == 401) {
        SessionManager.handleSessionExpired();
        throw Exception('Session expired');
      } else {
        // Attempt to parse error message
        try {
          final errorBody = jsonDecode(response.body);
          throw Exception(errorBody['detail'] ?? 'Failed to create task: ${response.statusCode}');
        } catch (e) {
          throw Exception('Failed to create task: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is http.ClientException || e.toString().contains('SocketException')) {
        throw Exception('Network error: Please check your connection');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    if (token == null) throw Exception('Authentication required');
    final url = Uri.parse('$baseUrl/get/tasks/');

    try {
      final response = await client.get(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else if (response.statusCode == 429) {
        ToastService.showGlobal("daam looks like you have hit the api limit try again after 1min", ToastType.error);
        throw Exception('Too many requests. Try again after 1 min');
      } else if (response.statusCode == 401) {
        SessionManager.handleSessionExpired();
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException || e.toString().contains('SocketException')) {
        throw Exception('Network error: Please check your connection');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    if (token == null) throw Exception('Authentication required');
    final url = Uri.parse('$baseUrl/update/task/status/');

    try {
      final response = await client.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'task_id': taskId,
          'task_status': status,
        }),
      );

      if (response.statusCode == 200) {
        return; // Success
      } else if (response.statusCode == 429) {
        ToastService.showGlobal("daam looks like you have hit the api limit try again after 1min", ToastType.error);
        throw Exception('Too many requests. Try again after 1 min');
      } else if (response.statusCode == 401) {
        SessionManager.handleSessionExpired();
        throw Exception('Session expired');
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          throw Exception(errorBody['detail'] ?? 'Failed to update task status: ${response.statusCode}');
        } catch (e) {
          throw Exception('Failed to update task status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is http.ClientException || e.toString().contains('SocketException')) {
        throw Exception('Network error: Please check your connection');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
  Future<void> uploadMedia(File file, String name, String type) async {
    if (token == null) throw Exception('Authentication required');
    final url = Uri.parse('$baseUrl/upload/media/');

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['media_name'] = name;
      request.fields['media_type'] = type; // 'image' or 'file'

      final mediaType = _getMediaType(file.path);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: mediaType,
        ),
      );

      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return; // Success
      } else if (response.statusCode == 429) {
        ToastService.showGlobal("daam looks like you have hit the api limit try again after 1min", ToastType.error);
        throw Exception('Too many requests. Try again after 1 min');
      } else if (response.statusCode == 401) {
        SessionManager.handleSessionExpired();
        throw Exception('Session expired');
      } else {
         try {
          final errorBody = jsonDecode(response.body);
          throw Exception(errorBody['detail'] ?? 'Failed to upload media: ${response.statusCode}');
        } catch (e) {
          throw Exception('Failed to upload media: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is http.ClientException || e.toString().contains('SocketException')) {
        throw Exception('Network error: Please check your connection');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<List<String>> getMedia() async {
    if (token == null) throw Exception('Authentication required');
    final url = Uri.parse('$baseUrl/get/media/');

    try {
      final response = await client.get(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return List<String>.from(jsonDecode(response.body));
      } else if (response.statusCode == 429) {
        ToastService.showGlobal("daam looks like you have hit the api limit try again after 1min", ToastType.error);
        throw Exception('Too many requests. Try again after 1 min');
      } else if (response.statusCode == 401) {
        SessionManager.handleSessionExpired();
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to load media: ${response.statusCode}');
      }
    } catch (e) {
      if (e is http.ClientException || e.toString().contains('SocketException')) {
        throw Exception('Network error: Please check your connection');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
