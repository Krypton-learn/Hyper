import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'test_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSidebarOpen = true;
  int _selectedIndex = 0; // 0 for Meetings, 1 for Tasks, 2 for Test Sections
  Timer? _timeUpdateTimer;

  @override
  void initState() {
    super.initState();
    // Update every 50 seconds as requested to keep the time somewhat fresh
    _timeUpdateTimer = Timer.periodic(const Duration(seconds: 50), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isSidebarOpen ? 280 : 72,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Material(
              color: Colors.transparent, 
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: SizedBox(
                   width: 280,
                   child: SingleChildScrollView(
                    child: Column(
                     children: [
                      // Logo / Header Area
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18), // customized padding
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () {
                                setState(() {
                                  _isSidebarOpen = !_isSidebarOpen;
                                });
                              },
                              color: const Color(0xFF5f6368),
                            ),
                            const SizedBox(width: 4),
                            // Mimicking the logo with text
                            // Note: Real logo would be an asset
                            AnimatedOpacity(
                              opacity: _isSidebarOpen ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: Row(
                                children: [
                                  // Placeholder icon mimicking the colored meet icon roughly
                                  const Icon(Icons.videocam, color: Color(0xFF1a73e8), size: 28), 
                                  const SizedBox(width: 8),
                                  Text(
                                    'Hyper Meet',
                                    overflow: TextOverflow.clip,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF5f6368),
                                      fontSize: 22,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Variable "New meeting" button could go here if mimicking sidebar closely, 
                      // but user prompt specifically asked for Sidebar items: Meetings, Tasks.
                      
                      // Navigation Items
                      _buildNavItem(0, Icons.event, 'Meetings', Icons.event_outlined),
                      _buildNavItem(1, Icons.check_circle, 'Tasks', Icons.check_circle_outline),
                      _buildNavItem(2, Icons.science, 'Test Sections', Icons.science_outlined),
                    ],
                   ),
                  ),
                  ),
                ),
            ),
          ),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Right Header (Time, Settings, Avatar)
                // We moved the logo/menu to sidebar, so this is just the actions now
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                       _buildHeaderTime(),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.help_outline, color: Colors.black54),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.feedback_outlined, color: Colors.black54),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.black54),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 10),
                      const CircleAvatar(
                        backgroundColor: Colors.purple,
                        child: Text('A', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                
                // Content Body (Hero + Carousel)
                Expanded(
                  child: _selectedIndex == 2
                    ? const TestScreen()
                    : LayoutBuilder(
                    builder: (context, constraints) {
                       if (constraints.maxWidth > 900) {
                         return Row(
                           children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: _buildHeroSection(context),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(child: _buildCarouselSection()),
                              ),
                           ],
                         );
                       } else {
                         return SingleChildScrollView(
                           child: Padding(
                             padding: const EdgeInsets.all(24.0),
                             child: Column(
                               children: [
                                 _buildHeroSection(context),
                                 const SizedBox(height: 40),
                                 _buildCarouselSection(),
                               ],
                             ),
                           ),
                         );
                       }
                    }
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData selectedIcon, String label, IconData unselectedIcon) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: Container(
        height: 48,
        margin: const EdgeInsets.only(right: 12), // Gap for the rounded shape
        decoration: isSelected
            ? const BoxDecoration(
                color: Color(0xFFe8f0fe), // Selected background
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              )
            : null,
        padding: const EdgeInsets.only(left: 24),
        child: Row(
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: isSelected ? const Color(0xFF1967d2) : const Color(0xFF5f6368),
               size: 24,
            ),
             const SizedBox(width: 16),
             AnimatedOpacity(
               opacity: _isSidebarOpen ? 1.0 : 0.0,
               duration: const Duration(milliseconds: 200),
               child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: isSelected ? const Color(0xFF1967d2) : const Color(0xFF3c4043),
                ),
              ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderTime() {
    final now = DateTime.now();
    final timeStr = DateFormat('h:mm a').format(now);
    final dateStr = DateFormat('EEE, MMM d').format(now);
    
    return Row(
      children: [
        Text(
          '$timeStr • $dateStr',
           style: GoogleFonts.roboto(
             color: Colors.black54,
             fontSize: 16,
           ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Video calls and meetings for everyone',
          style: GoogleFonts.outfit(
            fontSize: 44,
            height: 1.2,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Connect, collaborate, and celebrate from anywhere with Hyper',
          style: GoogleFonts.roboto(
            fontSize: 18,
            color: const Color(0xFF5f6368),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.video_call, color: Colors.white),
              label: Text(
                'New meeting',
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1a73e8),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(
              width: 260,
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.keyboard, color: Colors.grey),
                  hintText: 'Enter a code or link',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
             TextButton(
               onPressed: () {}, 
               child: Text(
                 'Join',
                 style: GoogleFonts.openSans(
                   fontSize: 16,
                   color: Colors.grey, // Disabled look for now
                   fontWeight: FontWeight.w500,
                 )
               )
             )
          ],
        ),
        const SizedBox(height: 40),
        const Divider(),
         SizedBox(height: 20),
         Row(
           children: [
             TextButton(
               onPressed: () {},
               style: TextButton.styleFrom(padding: EdgeInsets.zero),
               child: const Text('Learn more', style: TextStyle(color: Color(0xFF1a73e8))),
             ),
             Text(' about Hyper', style: TextStyle(color: Color(0xFF5f6368))),
           ],
         )
      ],
    );
  }

  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _carouselItems = [
    {
      'title': 'Get a link you can share',
      'subtitle': 'Click **New meeting** to get a link you can send to people you want to meet with',
      'icon': Icons.link,
      'color': Color(0xFF1a73e8),
    },
    {
      'title': 'Plan ahead',
      'subtitle': 'Click **New meeting** to schedule meetings in Google Calendar and send invites to participants',
      'icon': Icons.calendar_today,
      'color': Colors.orange,
    },
    {
      'title': 'Your meeting is safe',
      'subtitle': 'No one can join a meeting unless invited or admitted by the host',
      'icon': Icons.security,
      'color': Colors.green,
    },
    {
      'title': 'Join via phone',
      'subtitle': 'Dial in to meetings using the provided phone number and PIN when you are on the go',
      'icon': Icons.phone_in_talk,
      'color': Colors.purple,
    },
    {
      'title': 'Present to everyone',
      'subtitle': 'Share your screen or a specific window with everyone in the meeting for effective collaboration',
      'icon': Icons.present_to_all,
      'color': Colors.teal,
    },
  ];

  @override
  void dispose() {
    _timeUpdateTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildCarouselSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 450, // Fixed height for carousel content
          child: PageView.builder(
            controller: _pageController,
            itemCount: _carouselItems.length,
            itemBuilder: (context, index) {
              final item = _carouselItems[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(
                     width: 300,
                     height: 300,
                     decoration: const BoxDecoration(
                       shape: BoxShape.circle,
                       color: Color(0xFFe8f0fe), 
                     ),
                     child: Stack(
                       alignment: Alignment.center,
                       children: [
                          Positioned(
                            left: 60,
                            bottom: 80,
                            child: Icon(Icons.person, size: 80, color: Colors.orange.withOpacity(0.5)),
                          ),
                           Positioned(
                            right: 60,
                            bottom: 80,
                            child: Icon(Icons.person, size: 80, color: Colors.green.withOpacity(0.5)),
                          ),
                           Positioned(
                            top: 60,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: item['color'],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(item['icon'], color: Colors.white, size: 40)
                            )
                          ),
                       ],
                     ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    item['title'],
                     style: GoogleFonts.openSans(
                       fontSize: 24,
                       fontWeight: FontWeight.w400,
                       color: Colors.black87,
                     ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 350,
                    child: Text(
                      item['subtitle'].replaceAll('**', ''), // Removing markdown for simplicity in this basic Text widget
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: const Color(0xFF5f6368),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             IconButton(
               onPressed: () {
                 _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
               }, 
               icon: const Icon(Icons.chevron_left, color: Colors.grey,),
               style: IconButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
              ),
             ),
              const SizedBox(width: 40),
              // Optional: Dot indicators could go here
              
             IconButton(
               onPressed: () {
                 _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
               }, 
               icon: const Icon(Icons.chevron_right, color: Colors.grey),
               style: IconButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
              ),
             ),
           ],
        )
      ],
    );
  }
}
