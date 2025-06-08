import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'notifications_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';
import 'login_page.dart';

final User? user = FirebaseAuth.instance.currentUser;
final String? photoUrl = user?.photoURL;

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Icon(
                    Icons.email_outlined,
                    size: 80,
                    color: Colors.green[400],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Get In Touch section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get In Touch',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Email row
                    Row(
                      children: [
                        Icon(Icons.mail, color: Colors.red[400], size: 20),
                        const SizedBox(width: 10),
                        const Text(
                          'innov8tor@gmail.com',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Phone row
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.red[400], size: 20),
                        const SizedBox(width: 10),
                        const Text(
                          '+63 956 768 6637',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Location row
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            color: Colors.red[400], size: 20),
                        const SizedBox(width: 10),
                        const Text(
                          'Argao, Cebu, Philippines',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Send Us A Message section
              Text(
                'Send Us A Message',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.green[700],
                ),
              ),

              const SizedBox(height: 20),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Message field
                    const Text('Message', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Type your message here...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your message';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 25),

                    // Send Message button
                    SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    onPressed: () => sendMessage(context, _messageController),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    child: const Text(
      'Send Message',
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
)


                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  void sendMessage(BuildContext context, dynamic messageController) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // User not logged in, redirect to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    // Proceed with sending message (your Firestore logic here)
    try {
      await FirebaseFirestore.instance.collection('messages').add({
        'uid': user.uid,
        'email': user.email,
        'message': messageController.text,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Message Sent!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior
              .floating, // Optional: Makes it float above the bottom
          shape: RoundedRectangleBorder(
            // Optional: Adds rounded corners
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to send Message!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior
              .floating, // Optional: Makes it float above the bottom
          shape: RoundedRectangleBorder(
            // Optional: Adds rounded corners
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
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
            builder: (context) => const ProfilePage(), // Navigate to profile
          ),
        );
      },
      child: Container(
        width: 48, // Adjust size if needed
        height: 48,
        padding: const EdgeInsets.all(2), // Space for the border
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.green, // Green border color
            width: 2.5, // Border thickness
          ),
        ),
        child: CircleAvatar(
          backgroundColor: Colors.grey[200],
          backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
              ? NetworkImage(photoUrl)
              : null,
          child: (photoUrl == null || photoUrl.isEmpty)
              ? const Icon(Icons.person, color: Colors.green)
              : null,
        ),
      ),
    );
  }
}
