
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/upload_screen.dart';


void main() {
  group('FileSizeValidator', () {
    test('validate returns valid for small image', () {
      final file = File('small_image.jpg');
      // Mocking file length is hard with just File.
      // We might need to wrap the file or use IOOverrides, but IOOverrides.runZoned is effective.
      // Or just create a real temp file.
      
      final tempDir = Directory.systemTemp.createTempSync();
      final tempFile = File('${tempDir.path}/small.jpg');
      tempFile.writeAsBytesSync(List.filled(100, 0)); // 100 bytes
      
      final result = FileSizeValidator.validate(tempFile);
      expect(result.isValid, true);
      expect(result.errorMessage, null);
      
      tempDir.deleteSync(recursive: true);
    });

    test('validate returns invalid for large image (>1MB)', () {
      final tempDir = Directory.systemTemp.createTempSync();
      final tempFile = File('${tempDir.path}/large.jpg');
      // 1MB + 1 byte
      // Writing actual 1MB might be slow? 1MB is fast.
      tempFile.writeAsBytesSync(List.filled(1024 * 1024 + 1, 0));
      
      final result = FileSizeValidator.validate(tempFile);
      expect(result.isValid, false);
      expect(result.errorMessage, 'Image size exceeds 1MB limit.');
       
      tempDir.deleteSync(recursive: true);
    });

    test('validate returns valid for small PDF', () {
      final tempDir = Directory.systemTemp.createTempSync();
      final tempFile = File('${tempDir.path}/small.pdf');
      tempFile.writeAsBytesSync(List.filled(1024, 0)); // 1KB
      
      final result = FileSizeValidator.validate(tempFile);
      expect(result.isValid, true);
      
      tempDir.deleteSync(recursive: true);
    });

    test('validate returns invalid for large PDF (>10MB)', () {
      final tempDir = Directory.systemTemp.createTempSync();
      final tempFile = File('${tempDir.path}/large.pdf');
      
      // Creating 10MB file.
      final raf = tempFile.openSync(mode: FileMode.write);
      raf.truncateSync(10 * 1024 * 1024 + 1); // Set length directly
      raf.closeSync();
      
      final result = FileSizeValidator.validate(tempFile);
      expect(result.isValid, false);
      expect(result.errorMessage, 'PDF size exceeds 10MB limit.');
      
      tempDir.deleteSync(recursive: true);
    });
    
     test('validate returns valid for unknown file type', () {
      final tempDir = Directory.systemTemp.createTempSync();
      final tempFile = File('${tempDir.path}/unknown.xyz');
      tempFile.writeAsBytesSync(List.filled(20 * 1024 * 1024, 0)); // 20MB
      
      final result = FileSizeValidator.validate(tempFile);
      expect(result.isValid, true); // No limit for unknown types defined in requirements
      
      tempDir.deleteSync(recursive: true);
    });
  });
}
