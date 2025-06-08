import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'askcommunity_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';




class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  String _formatTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Some time ago';
    final now = DateTime.now();
    final postTime = timestamp.toDate();
    final difference = now.difference(postTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('community_posts')
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> loadedPosts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'userName': data['userName'] ?? 'Unknown',
          'content': data['question'] ?? '',
          'userPhoto': data['userPhoto'] ?? '',
          'timeAgo': _formatTimeAgo(data['timestamp']),
          'likes': data['likes'] ?? 0,
          'dislikes': data['dislikes'] ?? 0,
          'imageBase64': data['imageUrl'] ?? '', // rename properly here
        };
      }).toList();

      setState(() {
        _posts = loadedPosts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return _buildPostItem(post);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AskCommunityPage(),
            ),
          );
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.edit, color: Colors.white),
        label:
            const Text('Ask Community', style: TextStyle(color: Colors.white)),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildPostItem(Map<String, dynamic> post) {
    Uint8List? imageBytes;

    try {
      if (post['imageBase64'] != null && post['imageBase64'].isNotEmpty) {
        imageBytes = base64Decode(post['imageBase64']);
      }
    } catch (e) {
      print('Error decoding image: $e');
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageBytes != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.memory(
                imageBytes,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 120,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 50, color: Colors.grey),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      post['userPhoto'] != null && post['userPhoto'].isNotEmpty
                          ? NetworkImage(post['userPhoto'])
                          : null,
                  child:
                      (post['userPhoto'] == null || post['userPhoto'].isEmpty)
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${post['userName']}: ${post['content']}',
                        style: const TextStyle(
                            color: Colors.black87, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(post['timeAgo'],
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.thumb_up_outlined),
                    onPressed: () {},
                    iconSize: 18),
                Text('${post['likes']}'),
                const SizedBox(width: 12),
                IconButton(
                    icon: const Icon(Icons.thumb_down_outlined),
                    onPressed: () {},
                    iconSize: 18),
                Text('${post['dislikes']}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0),
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
                      builder: (context) => const NotificationsPage()))),
          _buildNavBarItem(
              icon: Icons.home,
              isSelected: false,
              onTap: () => Navigator.of(context).pop()),
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
        child: Icon(icon,
            color: isSelected ? Colors.green : Colors.grey, size: 28),
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
        padding: const EdgeInsets.all(2),
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
