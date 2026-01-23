
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../widgets/screen_select_dialog.dart';


class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}


class _TestScreenState extends State<TestScreen> with SingleTickerProviderStateMixin {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final AudioRecorder _audioRecorder = AudioRecorder();
  MediaStream? _localStream;
  bool _isCameraInitialized = false;
  bool _isMicOn = true;
  bool _isCameraOn = true;
  bool _isScreenSharing = false;
  String? _errorMessage;

  List<InputDevice> _audioInputs = [];
  List<MediaDeviceInfo> _videoInputs = [];
  String? _selectedAudioInputId;
  String? _selectedVideoInputId;

  StreamSubscription<Amplitude>? _amplitudeSubscription;
  late AnimationController _rodController;
  MediaStream? _screenShareStream;

  @override
  void initState() {
    super.initState();
    _rodController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // Smooth transition time
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _initializeCamera();
    _getAudioInputs();
    _getVideoInputs();
  }



  Future<void> _getAudioInputs() async {
    try {
      final devices = await _audioRecorder.listInputDevices();
      if (mounted) {
        setState(() {
          _audioInputs = devices;
          // If we have devices and none selected, pick the first one or default
          if (_selectedAudioInputId == null && _audioInputs.isNotEmpty) {
             _selectedAudioInputId = _audioInputs.first.id;
          }
        });
      }
    } catch (e) {
      debugPrint('Error listing audio devices: $e');
    }
  }

  Future<void> _getVideoInputs() async {
    try {
      final devices = await navigator.mediaDevices.enumerateDevices();
      final videoInputs = devices.where((d) => d.kind == 'videoinput').toList();
      if (mounted) {
        setState(() {
          _videoInputs = videoInputs;
          if (_selectedVideoInputId == null && _videoInputs.isNotEmpty) {
            _selectedVideoInputId = _videoInputs.first.deviceId;
          }
        });
      }
    } catch (e) {
      debugPrint('Error listing video devices: $e');
    }
  }

  Future<void> _initializeCamera() async {
    await _localRenderer.initialize();
    await _startStream();
    await _startRecording();
  }
  
  Future<void> _startStream() async {
    // We disable audio for WebRTC preview so 'record' package can take exclusive control (or at least avoid conflict)
    // and we can get amplitude data easily.
    final Map<String, dynamic> mediaConstraints = {
      'audio': false,
      'video': {
        'facingMode': 'user',
      }
    };

    try {
      debugPrint('Initializing camera with constraints: $mediaConstraints');
      MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      debugPrint('Got User Media Stream: ${stream.id}, AudioTracks: ${stream.getAudioTracks().length}');
      _localStream = stream;
      _localRenderer.srcObject = _localStream;
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isCameraOn = true;
          _errorMessage = null; 
        });
      }
    } catch (e) {
       debugPrint('Error initializing media: $e');
       if (mounted) {
        setState(() {
          _errorMessage = 'Error initializing camera/mic: $e';
        });
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _amplitudeSubscription?.cancel();
        _amplitudeSubscription = null;

        final dir = await getApplicationDocumentsDirectory();
        final micDir = Directory(p.join(dir.path, 'recordings', 'mic'));
        if (!await micDir.exists()) {
          await micDir.create(recursive: true);
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final path = p.join(micDir.path, 'recording_$timestamp.m4a');
        
        final config = RecordConfig(
          encoder: AudioEncoder.aacLc,
          device: _selectedAudioInputId != null ? InputDevice(id: _selectedAudioInputId!, label: 'selected') : null,
        );
        
        // Start recording
        await _audioRecorder.start(config, path: path);
        
        // Listen to amplitude
        _amplitudeSubscription = _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 50)).listen((amp) {
          if (!mounted) return;
          
          // Amp is usually -160 to 0 dB. Normalize for visual.
          double current = amp.current;
          const double minDb = -45.0; 
          
          if (current < minDb) current = minDb;
          double normalized = (current - minDb) / (0 - minDb); 
          
          // Apply a curve 
          normalized =  (normalized * 1.2).clamp(0.0, 1.0);

          // Noise gate 
          if (normalized < 0.05) normalized = 0.0;

          // Target minimal visibility if speaking
          double targetValue = normalized;
          if (targetValue > 0) {
             targetValue = 0.3 + (targetValue * 0.7);
             if (targetValue > 1.0) targetValue = 1.0;
          }

          // Smoothly animate to new target
          _rodController.animateTo(targetValue, curve: Curves.easeOut);
          

        });
        
        debugPrint('Started recording to $path');
      }
    } catch (e) {
       debugPrint('Error starting recording: $e');
       if (mounted) {
         setState(() => _errorMessage = 'Recording Error: $e');
       }
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;
      await _audioRecorder.stop();
      if (mounted) {

      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _audioRecorder.dispose();
    _rodController.dispose();
    _localStream?.dispose(); 
    _screenShareStream?.dispose();
    _localRenderer.dispose();
    super.dispose();
  }

  Future<void> _toggleScreenShare() async {
    if (_isScreenSharing) {
      await _stopScreenShare();
    } else {

        DesktopCapturerSource? source;
        if (mounted) {
           source = await showDialog<DesktopCapturerSource>(
            context: context,
            builder: (context) => const ScreenSelectDialog(),
          );
        }
        
        if (source == null) return; // User cancelled
        
        Map<String, dynamic> mediaConstraints = {
          'audio': false,
          'video': {
            'deviceId': {'exact': source.id},
          },
        };

        
        debugPrint('Requesting display media with constraints: $mediaConstraints');
        
        try {
          final stream = await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
          
          // Handle stream ending from system UI side
          stream.getTracks().first.onEnded = () {
            _stopScreenShare();
          };
          
          if (mounted) {
            setState(() {
              _isScreenSharing = true;
              _screenShareStream = stream;
              _localRenderer.srcObject = _screenShareStream;
            });
          }
        } catch (e) {
          debugPrint('Error getting display media: $e');
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text('Failed to share screen: $e'),
                 backgroundColor: Colors.red,
                 duration: const Duration(seconds: 5),
               )
             );
          }
        }
    }
  }

  Future<void> _stopScreenShare() async {
    try {
      if (_screenShareStream != null) {
        _screenShareStream!.getTracks().forEach((t) => t.stop());
        await _screenShareStream!.dispose();
        _screenShareStream = null;
      }
      
      if (mounted) {
        setState(() {
          _isScreenSharing = false;
          // Restore camera if it was on
          if (_isCameraOn && _localStream != null) {
            _localRenderer.srcObject = _localStream;
          } else {
            _localRenderer.srcObject = null;
          }
        });
      }
    } catch (e) {
      debugPrint('Error stopping screen share: $e');
    }
  }

  void _toggleMic() {
    setState(() {
      _isMicOn = !_isMicOn;
    });

    // Stop recording completely when muted to release mic
    if (_isMicOn) {
       _startRecording();
    } else {
       _stopRecording();
    }
  }

  bool _isToggling = false;

  Future<void> _switchAudioInput(String? deviceId) async {
    if (deviceId == null || deviceId == _selectedAudioInputId) return;
    
    setState(() {
      _selectedAudioInputId = deviceId;
    });
    
    // Restart stream with new audio device
    // Restart recording
    await _stopRecording();
    await _startRecording(); // will pick up new _selectedAudioInputId
  }

  Future<void> _switchVideoInput(String? deviceId) async {
    if (deviceId == null || deviceId == _selectedVideoInputId) return;

    setState(() {
      _selectedVideoInputId = deviceId;
    });

    if (_isCameraOn) {
      // Restart camera with new device
      await _toggleCamera(restartWithNewConfig: true);
    }
  }

  Future<void> _toggleCamera({bool restartWithNewConfig = false}) async {
    if (_isToggling) return;

    setState(() {
      _isToggling = true;
    });

    try {
      if (_isCameraOn && !restartWithNewConfig) {
        // Turn OFF
        if (!_isScreenSharing) {
          _localRenderer.srcObject = null;
        }
        setState(() => _isCameraOn = false);
        
        if (_localStream != null) {
          _localStream!.getTracks().forEach((t) => t.stop());
          await _localStream!.dispose();
          _localStream = null;
        }

      } else {
        // Turn ON (or Restart)
        if (_localStream != null) {
           _localStream!.getTracks().forEach((t) => t.stop());
           await _localStream!.dispose();
           _localStream = null;
        }

        final mediaConstraints = {
            'audio': _selectedAudioInputId != null 
                ? {'deviceId': _selectedAudioInputId} 
                : true,
            'video': {
              'facingMode': 'user',
              if (_selectedVideoInputId != null)
                'deviceId': _selectedVideoInputId,
            }
          };
          
          MediaStream newStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
          _localStream = newStream;
          if (!_isScreenSharing) {
            _localRenderer.srcObject = _localStream;
          }
          
          if (mounted) {
            setState(() {
              _isCameraOn = true;
              _errorMessage = null;
              // Sync mic state. If we were muted, we should apply that to new stream
            });
          }
      }
    } catch (e) {
      debugPrint('Error toggling camera: $e');
      if (mounted) setState(() => _errorMessage = 'Error: $e');
    } finally {
      if (mounted) setState(() => _isToggling = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _errorMessage!,
            style: GoogleFonts.roboto(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (!_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: const Color(0xFF202124), 
      child: Stack(
        children: [
          // Camera Preview
          Center(
            child: _isCameraOn || _isScreenSharing
              ? RTCVideoView(
                  _localRenderer,
                  objectFit: _isScreenSharing 
                      ? RTCVideoViewObjectFit.RTCVideoViewObjectFitContain 
                      : RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  mirror: !_isScreenSharing, 
                )
              : Container(
                  width: double.infinity,
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Avatar with AUDIO VISUALIZER
                         Container(
                           width: 150,
                           height: 150,
                           clipBehavior: Clip.hardEdge,
                           decoration: const BoxDecoration(
                             color: Colors.black26, 
                             shape: BoxShape.circle,
                           ),
                           child: Stack(
                             alignment: Alignment.center,
                             children: [
                               // Case 1: Muted -> Show Mic Off Icon
                               if (!_isMicOn)
                                 const Icon(
                                   Icons.mic_off,
                                   color: Colors.white,
                                   size: 48, 
                                 )
                               else
                               // Case 2: Active (Silent or Speaking) -> Show Waveform
                                  SizedBox(
                                    width: 100, // Limit width of the waveform area
                                    height: 100,
                                    child: AnimatedBuilder(
                                      animation: _rodController,
                                      builder: (context, child) {
                                        // Base height from audio volume
                                        double baseHeight = _rodController.value * 60.0; // Max 60 height
                                        if (baseHeight < 5.0) baseHeight = 5.0; // Min height so they are visible dots

                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            // Bar 1 (Left) - Slightly delayed/smaller
                                            _buildWaveformBar(baseHeight * 0.7),
                                            const SizedBox(width: 4),
                                            // Bar 2 (Center) - Main height (tallest)
                                            _buildWaveformBar(baseHeight),
                                            const SizedBox(width: 4),
                                            // Bar 3 (Right) - Mirrored/Simulated variation
                                            _buildWaveformBar(baseHeight * 0.8),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                             ],
                           ),
                         ),
                         const SizedBox(height: 16),
                         Text(
                           'Camera is off',
                           style: GoogleFonts.openSans(color: Colors.white, fontSize: 18),
                         ),
                      ],
                    ),
                  ),
                ),
          ),
          

          
          // Control Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   // Mic Control
                   _buildMicControl(),
                   const SizedBox(width: 16),
                   
                   // Camera Control
                   _buildCameraControl(),
                   const SizedBox(width: 16),
                   
                   // Screen Share Control
                   _buildScreenShareControl(),
                   const SizedBox(width: 16),

                   // End Call
                   _buildEndCallBtn(),
                ],
              ),
            ),
          ),
          
          // Header info
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Test Session',
                style: GoogleFonts.roboto(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveformBar(double height) {
    return Container(
      width: 12,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50), 
      ),
    );
  }

  Widget _buildControlPill({
    required Widget mainIcon,
    required bool isOn,
    required Color activeColor,
    required Color inactiveColor,
    required VoidCallback onToggle,
    required List<PopupMenuEntry<String>> menuItems,
    required void Function(String) onMenuSelected,
  }) {
    final bgColor = isOn ? activeColor : inactiveColor;
    final hasMenu = menuItems.isNotEmpty;
    
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(50),
         boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.2),
             blurRadius: 4,
             offset: const Offset(0, 2),
           )
         ]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main Button
          InkWell(
            onTap: onToggle,
            borderRadius: hasMenu 
              ? const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                )
              : BorderRadius.circular(50),
            child: SizedBox(
               width: 50,
               height: 56,
               child: Center(child: mainIcon),
            ),
          ),
          
          if (hasMenu) ...[
            // Divider
            Container(
               width: 1,
               height: 24,
               color: Colors.black26,
            ),

            // Menu Button
            Theme(
              data: Theme.of(context).copyWith(
                 popupMenuTheme: PopupMenuThemeData(
                   color: const Color(0xFF3c4043),
                   textStyle: GoogleFonts.roboto(color: Colors.white),
                 ),
              ),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 20),
                offset: const Offset(0, -10), // open upwards slightly
                position: PopupMenuPosition.over, // Position over the anchor
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                tooltip: 'Select Device',
                itemBuilder: (context) => menuItems,
                onSelected: onMenuSelected,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildMicControl() {
    bool isSpeaking = _isMicOn && (_rodController.value > 0.01);
    
    Widget icon = isSpeaking
        ? AnimatedBuilder(
            animation: _rodController,
            builder: (context, child) {
              double baseHeight = _rodController.value * 20.0;
              if (baseHeight < 3.0) baseHeight = 3.0;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   _buildWaveformBar(baseHeight * 0.7),
                   const SizedBox(width: 3),
                   _buildWaveformBar(baseHeight),
                   const SizedBox(width: 3),
                   _buildWaveformBar(baseHeight * 0.8),
                ],
              );
            },
          )
        : Icon(
            _isMicOn ? Icons.mic : Icons.mic_off,
            color: Colors.white,
            size: 24,
          );

    return _buildControlPill(
      mainIcon: icon,
      isOn: _isMicOn,
      activeColor: const Color(0xFF3c4043),
      inactiveColor: const Color(0xFFea4335),
      onToggle: _toggleMic,
      onMenuSelected: _switchAudioInput,
      menuItems: _audioInputs.map((device) {
        bool isSelected = device.id == _selectedAudioInputId;
        return PopupMenuItem<String>(
          value: device.id,
          child: Row(
            children: [
               if (isSelected) 
                 const Icon(Icons.check, color: Colors.blueAccent, size: 16),
               if (isSelected) const SizedBox(width: 8),
               Expanded(
                 child: Text(
                   device.label.isNotEmpty ? device.label : 'Unknown Mic',
                   overflow: TextOverflow.ellipsis,
                   style: TextStyle(
                     fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                   ),
                 ),
               ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCameraControl() {
    return _buildControlPill(
      mainIcon: Icon(
        _isCameraOn ? Icons.videocam : Icons.videocam_off,
        color: Colors.white,
        size: 24
      ),
      isOn: _isCameraOn,
      activeColor: const Color(0xFF3c4043),
      inactiveColor: const Color(0xFFea4335),
      onToggle: () => _toggleCamera(restartWithNewConfig: false),
      onMenuSelected: _switchVideoInput,
      menuItems: _videoInputs.map((device) {
        bool isSelected = device.deviceId == _selectedVideoInputId;
        return PopupMenuItem<String>(
          value: device.deviceId,
          child: Row(
            children: [
               if (isSelected) 
                 const Icon(Icons.check, color: Colors.blueAccent, size: 16),
               if (isSelected) const SizedBox(width: 8),
               Expanded(
                 child: Text(
                   device.label.isNotEmpty ? device.label : 'Unknown Camera',
                   overflow: TextOverflow.ellipsis,
                   style: TextStyle(
                     fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                   ),
                 ),
               ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScreenShareControl() {
    return _buildControlPill(
      mainIcon: Icon(
        _isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
        color: _isScreenSharing ? const Color(0xFF8ab4f8) : Colors.white, // Blue when active
        size: 24,
      ),
      isOn: _isScreenSharing,
      activeColor: const Color(0xFF3c4043),
      inactiveColor: const Color(0xFF3c4043), // Keep generic dark grey when inactive too, or maybe red? usually screen share is just a toggle. Let's stick to dark grey for inactive and active, but change icon color
      onToggle: _toggleScreenShare,
      onMenuSelected: (_) {},
      menuItems: [],
    );
  }

  Widget _buildEndCallBtn() {
    return InkWell(
      onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('End call pressed')),
            );
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 70, // Wider pill for End Call
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFea4335),
          borderRadius: BorderRadius.circular(50),
           boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.2),
               blurRadius: 4,
               offset: const Offset(0, 2),
             )
           ]
        ),
        child: const Icon(Icons.call_end, color: Colors.white, size: 28),
      ),
    );
  }
}
