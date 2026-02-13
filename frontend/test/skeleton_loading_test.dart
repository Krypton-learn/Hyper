import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend/screens/project_tasks_screen.dart';
import 'package:frontend/widgets/task_table_skeleton.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/models/user.dart';

// Mock UserProvider
class MockUserProvider extends ChangeNotifier implements UserProvider {
  String _accessToken = 'mock_token';
  
  @override
  String get accessToken => _accessToken;

  @override
  void setToken(String token) {
     _accessToken = token;
     notifyListeners();
  }
  
  @override
  User? get currentUser => null;

  @override
  void setUser(Map<String, dynamic> userData) {}

  @override
  void clearUser() {}

  @override
  bool get isOwner => false;
}

void main() {
  testWidgets('ProjectTasksScreen shows TaskTableSkeleton when loading', (WidgetTester tester) async {
    // Set a large screen size to avoid overflows
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;

    // Build the widget
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>(create: (_) => MockUserProvider()),
        ],
        child: const MaterialApp(
          home: ProjectTasksScreen(),
        ),
      ),
    );

    // Expect TaskTableSkeleton to be present initially (as isLoading is true by default)
    expect(find.byType(TaskTableSkeleton), findsOneWidget);

    // Pump to allow any Future.delayed to complete and animations to tick
    await tester.pump(); 
    await tester.pump(const Duration(milliseconds: 50));
    
    // Clear the screen size
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
