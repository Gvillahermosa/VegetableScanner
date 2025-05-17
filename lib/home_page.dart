import 'package:flutter/material.dart';
import 'about_us_page.dart';
import 'community_page.dart';
import 'notifications_page.dart';
import 'camera_screen.dart';
import 'placeholder_page.dart';
import 'vegetable_calendar_page.dart';
import 'vegetable_storage_page.dart';
import 'profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Top half with green background and vegetables
              Container(
                height: screenHeight * 0.34,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF8BC34A),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/images/vegetables_bg.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(child: Container(color: Colors.white)),
            ],
          ),
          // Overlapping grid of buttons
          Positioned(
            top: screenHeight * 0.18,
            left: 20,
            right: 20,
            child: GridView.count(
              // Adjust grid height here if needed
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              childAspectRatio: 0.95,
              children: [
                _buildFeatureButton(
                  context,
                  title: 'Identify',
                  subtitle: 'Image Detection',
                  iconWidget: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset('assets/images/identify_icon.png',
                        height: 45),
                  ),
                  backgroundColor: Colors.white,
                  onTap: () => _openCamera(context, 'identify'),
                ),
                _buildFeatureButton(
                  context,
                  title: 'Instant',
                  subtitle: 'Real-time detection',
                  iconWidget: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset('assets/images/realtime_icon.png',
                        height: 45),
                  ),
                  backgroundColor: Colors.white,
                  onTap: () => _openCamera(context, 'instant'),
                ),
                _buildFeatureButton(
                  context,
                  title: 'Vegetable Storage',
                  subtitle: '',
                  iconWidget:
                      Image.asset('assets/images/storage_icon.png', height: 75),
                  backgroundColor: const Color(0xFF8BB5F8),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const VegetableStoragePage()),
                    );
                  },
                ),
                _buildFeatureButton(
                  context,
                  title: 'Calendar',
                  subtitle: '',
                  iconWidget: Image.asset('assets/images/calendar_icon.png',
                      height: 75),
                  backgroundColor: const Color(0xFF95ECBC),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const VegetableCalendarPage()),
                    );
                  },
                ),
                _buildFeatureButton(
                  context,
                  title: 'Community',
                  subtitle: '',
                  iconWidget: Image.asset('assets/images/community_icon.png',
                      height: 75),
                  backgroundColor: const Color(0xFFFFC178),
                  onTap: () => _navigateToPage(context, 'community'),
                ),
                _buildFeatureButton(
                  context,
                  title: 'About us',
                  subtitle: '',
                  iconWidget:
                      Image.asset('assets/images/about_icon.png', height: 75),
                  backgroundColor: const Color(0xFFE0B4E2),
                  onTap: () => _navigateToPage(context, 'about'),
                ),
              ],
            ),
          ),
          // Bottom navigation bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavigationBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(BuildContext context,
      {required String title,
      required String subtitle,
      required Widget iconWidget,
      required Color backgroundColor,
      required Function() onTap}) {
    // Check if this title should have white text
    final bool useWhiteText = (title == 'Vegetable Storage' ||
        title == 'Calendar' ||
        title == 'Community' ||
        title == 'About us');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(top: 15, child: iconWidget),
            Positioned(
              top: useWhiteText ? 120 : 90,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: useWhiteText ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (subtitle.isNotEmpty)
              Positioned(
                top: 115,
                child: SizedBox(
                  width: 100,
                  child: Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavBarItem(
            icon: Icons.notifications_outlined,
            isSelected: false,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NotificationsPage()),
            ),
          ),
          _buildNavBarItem(icon: Icons.home, isSelected: true),
          _buildCircularProfileButton(context),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(
      {required IconData icon, required bool isSelected, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.green.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Icon(
          icon,
          color: isSelected ? Colors.green : Colors.grey,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildCircularProfileButton(context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.person, color: Colors.white, size: 24),
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ProfilePage(),
            ),
          );
        },
      ),
    );
  }

  void _openCamera(BuildContext context, String mode) async {
    try {
      // The CameraScreen handles displaying the camera
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(
              isRealTimeDetection:
                  mode == 'instant'), // Pass additional params as needed
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error accessing camera: $e')));
    }
  }

  void _navigateToPage(BuildContext context, String page) {
    if (page == 'about') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AboutUsPage()),
      );
    } else if (page == 'community') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CommunityPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PlaceholderPage(pageName: page)),
      );
    }
  }
}
