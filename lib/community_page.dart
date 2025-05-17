import 'package:flutter/material.dart';
import 'notifications_page.dart';

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

  void _loadPosts() {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _posts = List.generate(5, (index) {
          return {
            'userName': 'Jasce Belia',
            'content': 'Lorem Ipsum sit amet, consectetur adipiscing elit.',
            'timeAgo': '6h ago',
            'likes': 1,
            'dislikes': 0,
          };
        });
        _isLoading = false;
      });
    });
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Ask Community feature coming soon!')));
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              'assets/images/vegetables_bg.png',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post['content'],
                          style: const TextStyle(color: Colors.black87)),
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
          _buildCircularProfileButton(),
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

  Widget _buildCircularProfileButton() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.8), shape: BoxShape.circle),
      child: const Icon(Icons.person, color: Colors.white, size: 24),
    );
  }
}
