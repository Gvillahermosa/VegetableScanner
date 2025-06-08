import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class AskCommunityPage extends StatefulWidget {
  @override
  _AskCommunityPageState createState() => _AskCommunityPageState();
}

class _AskCommunityPageState extends State<AskCommunityPage> {
  PageController _pageController = PageController();
  TextEditingController _questionController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  int _currentImageIndex = 0;
  int _questionCharCount = 0;
  int _descriptionCharCount = 0;

  List<dynamic> _images = []; // Can be String (URL) or File (local)

  Future<void> _submitPost() async {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Unknown User';
    if (user == null) return;

    try {
      // 1. Convert images to base64 strings
      List<String> base64Images = [];

      for (var img in _images) {
        if (img is File) {
          List<int> imageBytes = await img.readAsBytes();
          String base64String = base64Encode(imageBytes);

          // Check if image size exceeds 1MB
          if (base64String.length > 1 * 1024 * 1024) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("One of your images exceeds 1MB limit")),
            );
            return;
          }

          base64Images.add(base64String);
        } else if (img is String) {
          base64Images.add(img); // If already base64 string
        }
      }

      // 2. Save to Firestore
      await FirebaseFirestore.instance.collection('community_posts').add({
        'userPhoto': user.photoURL ?? '',
        'userId': user.uid,
        'userName': userName,
        'question': _questionController.text,
        'description': _descriptionController.text,
        'images': base64Images, // base64 strings
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 3. Reset form
      _questionController.clear();
      _descriptionController.clear();
      setState(() {
        _images.clear();
        _questionCharCount = 0;
        _descriptionCharCount = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Post submitted successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error submitting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit post")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _questionController.addListener(() {
      setState(() {
        _questionCharCount = _questionController.text.length;
      });
    });

    _descriptionController.addListener(() {
      setState(() {
        _descriptionCharCount = _descriptionController.text.length;
      });
    });
  }

  void _deleteCurrentImage() {
    if (_images.isNotEmpty) {
      setState(() {
        _images.removeAt(_currentImageIndex);
        if (_currentImageIndex >= _images.length && _images.isNotEmpty) {
          _currentImageIndex = _images.length - 1;
          _pageController.animateToPage(
            _currentImageIndex,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Widget _buildImageSection() {
    if (_images.isEmpty) {
      return Container(
        height: 200,
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 48, color: Colors.grey[400]),
              SizedBox(height: 8),
              Text(
                'No images added',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 200,
      margin: EdgeInsets.all(16),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  final image = _images[index];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: image is File
                        ? Image.file(image, fit: BoxFit.cover)
                        : Image.memory(base64Decode(image), fit: BoxFit.cover),
                  );
                }),
          ),
          // Delete button overlay
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _deleteCurrentImage,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          // Dot pagination
          if (_images.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_images.length, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentImageIndex ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _currentImageIndex
                          ? Colors.green
                          : Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ask Community',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding:
                EdgeInsets.only(bottom: 80), // Prevent overlap with nav bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(),

                // Add image button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  size: 20, color: Colors.grey[600]),
                              SizedBox(width: 8),
                              Text(
                                'Add image',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Question section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your question to the community',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _questionController,
                          maxLength: 200,
                          maxLines: 3,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                            counterText: '',
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '$_questionCharCount / 200 Characters',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Description section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description of your problem',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          maxLength: 2500,
                          maxLines: 6,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                            counterText: '',
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '$_descriptionCharCount / 2500 Characters',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12),

                // Send button
                Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Send',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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

  @override
  void dispose() {
    _pageController.dispose();
    _questionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
