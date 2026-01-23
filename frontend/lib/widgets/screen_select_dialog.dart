import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';

class ScreenSelectDialog extends StatelessWidget {
  const ScreenSelectDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black12)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Share your screen',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TabBar(
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      tabs: const [
                        Tab(text: 'Entire Screen'),
                        Tab(text: 'Window'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _SourceList(types: [SourceType.Screen]),
                    _SourceList(types: [SourceType.Window]),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceList extends StatefulWidget {
  final List<SourceType> types;

  const _SourceList({required this.types});

  @override
  State<_SourceList> createState() => _SourceListState();
}

class _SourceListState extends State<_SourceList> {
  List<DesktopCapturerSource> _sources = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // On Linux, we don't fetch windows yet.
    if (Platform.isLinux && widget.types.contains(SourceType.Window)) {
      _isLoading = false;
    } else {
      _fetchSources();
    }
  }

  Future<void> _fetchSources() async {
    try {
      if (mounted) setState(() => _isLoading = true);
      
      final sources = await desktopCapturer.getSources(
        types: widget.types,
        thumbnailSize: ThumbnailSize(200, 200), 
      );
      if (mounted) {
        setState(() {
          _sources = sources;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading sources: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isLinux && widget.types.contains(SourceType.Window)) {
      return const Center(
        child: Text(
          'This feature will be added later on.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                 setState(() {
                   _error = null;
                 });
                 _fetchSources();
              }, 
              child: const Text('Retry'),
            )
          ],
        )
      );
    }

    if (_sources.isEmpty) {
      return const Center(child: Text('No sources found'));
    }

    return ListView.builder(
      itemCount: _sources.length,
      itemBuilder: (context, index) {
        final item = _sources[index];
        return ListTile(
            leading: item.thumbnail != null 
                ? Image.memory(item.thumbnail!, width: 40, height: 40, errorBuilder: (_,__,___) => const Icon(Icons.window))
                : const Icon(Icons.window),
            title: Text(item.name),
            subtitle: Text('ID: ${item.id}'),
            onTap: () {
              Navigator.of(context).pop(item);
            },
          );
      },
    );
  }
}
