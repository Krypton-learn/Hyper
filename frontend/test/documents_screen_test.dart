import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:frontend/screens/documents_screen.dart';
import 'package:frontend/widgets/skeleton.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/services/api_service.dart';
import 'dart:convert';

void main() {
  testWidgets('DocumentsScreen displays media from API', (WidgetTester tester) async {
    // Mock API response
    final mockResponse = [
      "https://ebwdjkhtuejhmijayzyj.supabase.co/storage/v1/object/public/images_media/2d8422f2-302b-4346-b36b-7174a34bb038", // No extension, but in images_media -> Should be Image
      "https://example.com/files/test_doc.pdf"
    ];

    // Create Mock Client
    final mockClient = MockClient((request) async {
      if (request.url.path == '/api/v1/get/media/') {
        return http.Response(jsonEncode(mockResponse), 200);
      }
      return http.Response('Not Found', 404);
    });

    // Create UserProvider with dummy token
    final userProvider = UserProvider();
    userProvider.setToken("dummy_token");


    // Create ApiService with mock client
    final apiService = ApiService("dummy_token", mockClient);

    // Set surface size to avoid overflow
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>.value(value: userProvider),
          Provider<ApiService>.value(value: apiService),
        ],
        child: const MaterialApp(
          home: DocumentsScreen(),
        ),
      ),
    );

    // Verify loading state (both sections show loading)
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(Skeleton), findsWidgets); // Should find about 10 (5+5)

    // Wait for async operations
    await tester.pumpAndSettle();

    // Verify images are displayed
    expect(find.byType(Image), findsOneWidget); // One image in the horizontal list

    // Verify only document is displayed in the list
    expect(find.text('test_doc.pdf'), findsOneWidget); 
    // Image should NOT be in the vertical list (so filename text won't be found there as a simple Text widget title)
    // However, HoverableImageCard might display text on hover, but initially it's hidden or checks for specific widget. 
    // Simply checking that 'uploaded by :' count is 1 is a good proxy that only 1 item is in the list.
    expect(find.text('uploaded by : Unknown'), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
  });
}
