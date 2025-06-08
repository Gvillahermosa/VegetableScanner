import 'package:flutter/material.dart';
import 'notifications_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';
import 'login_page.dart';

class OurTeamPage extends StatelessWidget {
  const OurTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Team'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Meet The Team header
            Center(
              child: Text(
                'Meet The Team',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[400],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Team description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Our diverse team combines expertise in agriculture, AI technology, and app development to bring you the best vegetable freshness detection solution.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Team members list
            _buildTeamMemberCard(
              name: 'Ma. Jasce Nova E. Belia',
              role: 'Team Leader / Backend Developer',
              bio:
                  'Jasce specializes in AI algorithms and has 5+ years of experience in developing machine learning solutions for agriculture technology.',
              imagePath: 'assets/images/members_pic/jasce.png',
            ),

            _buildTeamMemberCard(
              name: 'Pearly L. Rellon',
              role: 'Technical Writer',
              bio:
                  'Maria has a PhD in Agricultural Sciences and contributes expert knowledge on vegetable freshness indicators and storage conditions.',
              imagePath: 'assets/images/members_pic/pearly.png',
            ),

            _buildTeamMemberCard(
              name: 'Claudine A. Amancio',
              role: 'QA specialists',
              bio:
                  'David brings 8 years of experience in creating intuitive user interfaces for mobile applications focused on agricultural solutions.',
              imagePath: 'assets/images/members_pic/claudine.png',
            ),

            _buildTeamMemberCard(
              name: 'Jehn Clara Dhel Delicano',
              role: 'Frontend Developer',
              bio:
                  'Elena specializes in computer vision and has trained multiple neural networks to accurately detect vegetable conditions.',
              imagePath: 'assets/images/members_pic/jhen.png',
            ),

            _buildTeamMemberCard(
              name: 'Bartt Johngil Sayago',
              role: 'Backend Developer',
              bio:
                  'Elena specializes in computer vision and has trained multiple neural networks to accurately detect vegetable conditions.',
              imagePath: 'assets/images/members_pic/bartt.png',
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildTeamMemberCard({
    required String name,
    required String role,
    required String bio,
    required String imagePath, // ← new parameter
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile image as a circle
            ClipOval(
              child: Image.asset(
                imagePath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    textAlign: TextAlign.justify,
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[800],
                      height: 1.3,
                    ),
                  ),
                ],
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
          _buildNavBarItem(
            icon: Icons.home,
            isSelected: false,
            onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
          _buildCircularProfileButton(context),
        ],
      ),
    );
  }

  Widget _buildNavBarItem({
    required IconData icon,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
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

  Widget _buildCircularProfileButton(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? photoUrl = user?.photoURL;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                user != null ? const ProfilePage() : const LoginPage(),
          ),
        );
      },
      child: Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(2), // space for border
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.green,
            width: 2.5,
          ),
        ),
        child: CircleAvatar(
          backgroundColor: Colors.grey[200],
          backgroundImage:
              (user != null && photoUrl != null && photoUrl.isNotEmpty)
                  ? NetworkImage(photoUrl)
                  : null,
          child: (user == null || photoUrl == null || photoUrl.isEmpty)
              ? const Icon(Icons.person, color: Colors.green)
              : null,
        ),
      ),
    );
  }
}
