
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:frontend/services/api_service.dart';


void main() {
  group('ApiService Upload Media', () {
    test('uploadMedia sets correct content type for PDF', () async {
      // Create a temporary PDF file
      final tempDir = Directory.systemTemp.createTempSync();
      final file = File('${tempDir.path}/test.pdf');
      file.writeAsStringSync('dummy pdf content');

      // Create a MockClient to intercept the request
      final client = MockClient((request) async {
        // Verify it's a multipart request
        // The content-type header on the request object itself might not be set until finalization, 
        // but let's check if the body contains the correct content-type for the part.
        
        final body = request.body; // MockClient passes a Request which has the body
        
        // Check for the Content-Type header in the multipart body
        expect(body, contains('content-type: application/pdf'));
        
        return http.Response('{"status": "ok"}', 200);
      });

      final apiService = ApiService('fake_token', client);

      try {
        await apiService.uploadMedia(file, 'Test PDF', 'file');
      } finally {
        // Cleanup
        if (file.existsSync()) file.deleteSync();
        if (tempDir.existsSync()) tempDir.deleteSync();
      }
    });

    test('uploadMedia sets correct content type for JPG', () async {
      // Create a temporary JPG file
      final tempDir = Directory.systemTemp.createTempSync();
      final file = File('${tempDir.path}/test.jpg');
      file.writeAsStringSync('dummy image content');

      // Create a MockClient to intercept the request
      final client = MockClient((request) async {
        final body = request.body;
        expect(body, contains('content-type: image/jpeg'));
        return http.Response('{"status": "ok"}', 200);
      });

      final apiService = ApiService('fake_token', client);

      try {
        await apiService.uploadMedia(file, 'Test JPG', 'image');
      } finally {
         if (file.existsSync()) file.deleteSync();
        if (tempDir.existsSync()) tempDir.deleteSync();
      }
    });
    
     test('uploadMedia uses default octet-stream for unknown types', () async {
      // Create a temporary unknown file
      final tempDir = Directory.systemTemp.createTempSync();
      final file = File('${tempDir.path}/test.xyz');
      file.writeAsStringSync('dummy content');

      // Create a MockClient to intercept the request
      final client = MockClient((request) async {
        final body = request.body;
        expect(body, contains('content-type: application/octet-stream'));
        return http.Response('{"status": "ok"}', 200);
      });

      final apiService = ApiService('fake_token', client);

      try {
        await apiService.uploadMedia(file, 'Test Unknown', 'file');
      } finally {
         if (file.existsSync()) file.deleteSync();
        if (tempDir.existsSync()) tempDir.deleteSync();
      }
    });
  });
}
