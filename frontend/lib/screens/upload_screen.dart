import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:provider/provider.dart';
import '../widgets/sidebar.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _nameController = TextEditingController();
  String _selectedFileType = 'Auto'; // Auto, Image, PDF
  File? _selectedFile;
  String? _fileName;
  bool _isDragging = false;
  bool _isUploading = false;

  final List<String> _fileTypes = ['Auto', 'Image', 'PDF'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
        // Auto-fill name if empty
        if (_nameController.text.isEmpty) {
          _nameController.text = _fileName!.split('.').first;
        }
        _updateFileTypeFromExtension(_selectedFile!.path);
      });
    }
  }

  void _onDragDone(DropDoneDetails details) {
    if (details.files.isNotEmpty) {
      setState(() {
        _selectedFile = File(details.files.first.path);
        _fileName = details.files.first.name;
         if (_nameController.text.isEmpty) {
          _nameController.text = _fileName!.split('.').first;
        }
        _updateFileTypeFromExtension(_selectedFile!.path);
      });
    }
  }

  void _updateFileTypeFromExtension(String path) {
    final ext = path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
      _selectedFileType = 'Image';
    } else if (ext == 'pdf') {
      _selectedFileType = 'PDF';
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first.')),
      );
      return;
    }

    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a media name.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final apiService = ApiService(userProvider.accessToken);

      String mediaType = 'image';
      if (_selectedFileType == 'PDF') {
        mediaType = 'file';
      } else if (_selectedFileType == 'Image') {
        mediaType = 'image';
      } else {
        // Auto fallback
        final ext = _selectedFile!.path.split('.').last.toLowerCase();
        if (ext == 'pdf') {
          mediaType = 'file';
        } else {
          mediaType = 'image';
        }
      }

      await apiService.uploadMedia(_selectedFile!, _nameController.text, mediaType);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload successful!')),
        );
        setState(() {
          _selectedFile = null;
          _fileName = null;
          _nameController.clear();
          _selectedFileType = 'Auto';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          const Sidebar(currentRoute: '/upload'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Input Section (Left) ---
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upload Media',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Media Name Input
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Media Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF27272A) : Colors.grey[100],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // File Type Selection
                        DropdownButtonFormField<String>(
                          value: _selectedFileType,
                          decoration: InputDecoration(
                            labelText: 'File Type',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF27272A) : Colors.grey[100],
                          ),
                          items: _fileTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedFileType = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Drag and Drop Area
                        Expanded(
                          child: DropTarget(
                            onDragDone: _onDragDone,
                            onDragEntered: (details) => setState(() => _isDragging = true),
                            onDragExited: (details) => setState(() => _isDragging = false),
                            child: InkWell(
                              onTap: _pickFile,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _isDragging
                                      ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                                      : (isDark ? const Color(0xFF27272A) : Colors.grey[100]),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _isDragging
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.withValues(alpha: 0.5),
                                    width: 2,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Center(
                                  child: _selectedFile != null
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            size: 64,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'File Selected!',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Currently previewing',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context).primaryColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _fileName ?? '',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDark ? Colors.white70 : Colors.grey[700],
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Click to change file',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? Colors.white38 : Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.cloud_upload_outlined,
                                          size: 64,
                                          color: isDark ? Colors.white70 : Colors.grey[600],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Drag & Drop files here',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'or click to browse',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDark ? Colors.white54 : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                ),
                              ),
                            ),
                          ),
                        ),
                         const SizedBox(height: 24),
                         SizedBox(
                           width: double.infinity,
                           height: 50,
                           child: ElevatedButton(
                             onPressed: _isUploading ? null : _uploadFile,
                             style: ElevatedButton.styleFrom(
                               backgroundColor: Theme.of(context).primaryColor,
                               foregroundColor: Colors.white,
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(12),
                               ),
                             ),
                             child: _isUploading
                                 ? const CircularProgressIndicator(color: Colors.white)
                                 : const Text('Upload', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                           ),
                         ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 32),

                  // --- Preview Section (Right) ---
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF18181B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preview',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: _selectedFile != null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (['jpg', 'jpeg', 'png', 'gif']
                                            .contains(_selectedFile!.path.split('.').last.toLowerCase()))
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.file(
                                              _selectedFile!,
                                              height: 300,
                                              fit: BoxFit.contain,
                                            ),
                                          )
                                        else if (_selectedFile!.path.split('.').last.toLowerCase() == 'pdf')
                                            const Icon(Icons.picture_as_pdf, size: 100, color: Colors.red)
                                        else
                                            const Icon(Icons.insert_drive_file, size: 100, color: Colors.grey),
                                        
                                        const SizedBox(height: 16),
                                        Text(
                                          _fileName ?? 'Unknown file',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: isDark ? Colors.white70 : Colors.black87,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${(_selectedFile!.lengthSync() / 1024).toStringAsFixed(2)} KB',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDark ? Colors.white38 : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 80,
                                          color: isDark ? Colors.white24 : Colors.grey[300],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No file selected',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: isDark ? Colors.white38 : Colors.grey[400],
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
            ),
          ),
        ],
      ),
    );
  }
}
