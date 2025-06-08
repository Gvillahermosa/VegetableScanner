import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'notifications_page.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // User information - all editable
  String? name;
  String? email;
  DateTime? birthdate;
  String? gender;
  bool biometricsEnabled = false;
  // For profile image
  String? photoURL;
  final ImagePicker _picker = ImagePicker();
  // Edit mode tracking
  bool isEditingName = false;
  bool isEditingEmail = false;
  // Controllers
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateUserData(String field, dynamic value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          field: value,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$field updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior
                .floating, // Optional: Makes it float above the bottom
            shape: RoundedRectangleBorder(
              // Optional: Adds rounded corners
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update $field: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior
                .floating, // Optional: Makes it float above the bottom
            shape: RoundedRectangleBorder(
              // Optional: Adds rounded corners
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        print('Error updating $field: $e');
      }
    }
  }

  // Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {});
    }
  }

  // Show image source selection dialog
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => DateFormat('MMMM d, yyyy').format(date);

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: birthdate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      await _updateUserData('birthdate', Timestamp.fromDate(picked));
    }
  }

  // Show gender selection dialog
  void _showGenderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Gender'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Female'),
              onTap: () async {
                await _updateUserData('gender', 'Female');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Male'),
              onTap: () async {
                await _updateUserData('gender', 'Male');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Show sign out confirmation
  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out', style: TextStyle(color: Colors.green)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first
              await FirebaseAuth.instance.signOut();

              // Navigate to LoginPage and clear history
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
            },
            child: const Text(
              'SIGN OUT',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // For change email dialog
  void _showChangeEmailDialog() {
    final newEmailController = TextEditingController();
    final currentPasswordController = TextEditingController();
    bool isLoading = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your current email is $email',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newEmailController,
                decoration: const InputDecoration(
                  labelText: 'New Email Address',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              if (isLoading) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ]
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (newEmailController.text.isEmpty ||
                          currentPasswordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill in all fields')),
                        );
                        return;
                      }
                      final emailRegex =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(newEmailController.text)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter a valid email'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior
                                .floating, // Optional: Makes it float above the bottom
                            shape: RoundedRectangleBorder(
                              // Optional: Adds rounded corners
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        final user = FirebaseAuth.instance.currentUser!;
                        final credential = EmailAuthProvider.credential(
                          email: user.email!,
                          password: currentPasswordController.text,
                        );

                        await user.reauthenticateWithCredential(credential);
                        await user.updateEmail(newEmailController.text);
                        await _updateUserData('email', newEmailController.text);

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Email updated successfully'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior
                                .floating, // Optional: Makes it float above the bottom
                            shape: RoundedRectangleBorder(
                              // Optional: Adds rounded corners
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
              child: const Text('UPDATE'),
            ),
          ],
        ),
      ),
    );
  }

  // For change password dialog
  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                  ),
                  obscureText: true,
                ),
                TextField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                  ),
                  obscureText: true,
                ),
                TextField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (currentPasswordController.text.isEmpty ||
                            newPasswordController.text.isEmpty ||
                            confirmPasswordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please complete all fields'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior
                                  .floating, // Optional: Makes it float above the bottom
                              shape: RoundedRectangleBorder(
                                // Optional: Adds rounded corners
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                          return;
                        }
                        if (newPasswordController.text !=
                            confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Passwords do not match"),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior
                                  .floating, // Optional: Makes it float above the bottom
                              shape: RoundedRectangleBorder(
                                // Optional: Adds rounded corners
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                          return;
                        }
                        try {
                          setState(() => isLoading = true);
                          final user = FirebaseAuth.instance.currentUser!;
                          final credential = EmailAuthProvider.credential(
                            email: user.email!,
                            password: currentPasswordController.text,
                          );
                          await user.reauthenticateWithCredential(credential);
                          await user.updatePassword(newPasswordController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Password updated successfully'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior
                                  .floating, // Optional: Makes it float above the bottom
                              shape: RoundedRectangleBorder(
                                // Optional: Adds rounded corners
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        } finally {
                          setState(() => isLoading = false);
                        }
                      },
                child: const Text('Update'),
              ),
            ],
          ),
        );
      },
    );
  }

  // For account deletion
  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    bool isLoading = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This action cannot be undone. All your data will be permanently deleted.',
                style: TextStyle(fontSize: 14, color: Colors.red),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Enter Your Password to Confirm',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              const Text(
                'Type "DELETE" to confirm',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              if (isLoading) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ]
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (confirmController.text != 'DELETE') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please type DELETE to confirm'),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        final user = FirebaseAuth.instance.currentUser!;
                        final credential = EmailAuthProvider.credential(
                          email: user.email!,
                          password: passwordController.text,
                        );

                        await user.reauthenticateWithCredential(credential);
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .delete();
                        await user.delete();

                        Navigator.pop(context);
                        // Navigate to login screen
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('DELETE'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: user != null
              ? FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots()
              : null,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasData && snap.data!.data() != null) {
              final data = snap.data!.data()! as Map<String, dynamic>;
              name = data['name'] ?? user?.displayName ?? 'No name';
              email = data['email'] ?? user?.email ?? 'No email';
              gender = data['gender'] ?? 'Not specified';
              photoURL = data['photoURL'] ?? user?.photoURL;
              birthdate = data['birthdate'] != null
                  ? (data['birthdate'] as Timestamp).toDate()
                  : null;
            } else {
              name = user?.displayName ?? 'No name';
              email = user?.email ?? 'No email';
              photoURL = user?.photoURL;
            }
            if (!isEditingName) nameController.text = name ?? '';
            return Column(
              children: [
                /* ─────────── Header with picture ─────────── */
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: screenHeight * 0.24,
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
                    Positioned(
                      bottom: -50,
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Stack(
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    photoURL != null ? null : Colors.green[300],
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                image: photoURL != null
                                    ? DecorationImage(
                                        image: NetworkImage(photoURL!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: photoURL == null
                                  ? const Icon(Icons.person,
                                      size: 60, color: Colors.white)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit,
                                    size: 20, color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 55),
                Text(name ?? 'No name',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                /* ─────────── Details Scroll ─────────── */
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Basic Information'),
                        ProfileDetailCard(children: [
                          !isEditingName
                              ? ProfileDetailItem(
                                  label: 'Full Name',
                                  value: name ?? 'No name',
                                  onEdit: () {
                                    // DEFER the state change until after the tap completes
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (mounted) {
                                        setState(() => isEditingName = true);
                                        // Focus the text field after a small delay
                                        Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {
                                          // The TextField will auto-focus because of autofocus: true
                                        });
                                      }
                                    });
                                  },
                                )
                              : _editTextField(
                                  label: 'Full Name',
                                  controller: nameController,
                                  onSave: () async {
                                    await _updateUserData(
                                        'name', nameController.text);
                                    setState(() => isEditingName = false);
                                  },
                                ),
                          const Divider(),
                          ProfileDetailItem(
                            label: 'Birthdate',
                            value: birthdate != null
                                ? _formatDate(birthdate!)
                                : 'Not specified',
                            onEdit: _selectDate,
                          ),
                          const Divider(),
                          ProfileDetailItem(
                            label: 'Gender',
                            value: gender ?? 'Not specified',
                            onEdit: _showGenderDialog,
                          ),
                        ]),
                        const SizedBox(height: 20),
                        const SectionHeader(title: 'Account & Security'),
                        ProfileDetailCard(children: [
                          ListTile(
                            leading: const Icon(Icons.email_outlined,
                                color: Colors.green),
                            title: const Text('Change Email'),
                            subtitle: Text(email ?? 'No email',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _showChangeEmailDialog,
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.lock_outline,
                                color: Colors.green),
                            title: const Text('Change Password'),
                            subtitle: const Text('Update your password',
                                style: TextStyle(fontSize: 12)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _showChangePasswordDialog,
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            title: const Text('Delete Account',
                                style: TextStyle(color: Colors.red)),
                            subtitle: const Text(
                              'Permanently delete your account and all data',
                              style: TextStyle(fontSize: 12),
                            ),
                            trailing: const Icon(Icons.chevron_right,
                                color: Colors.red),
                            onTap: _showDeleteAccountDialog,
                          ),
                        ]),
                        const SizedBox(height: 20),
                        /* ───────── Sign out button ───────── */
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _showSignOutDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('SIGN OUT',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Text('App Version 1.0.0',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12)),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
                _buildBottomNavigationBar(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _editTextField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onSave,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    autofocus: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green, size: 20),
              onPressed: onSave,
            ),
          ],
        ),
      );

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
                builder: (context) => const NotificationsPage(),
              ),
            ),
          ),
          _buildNavBarItem(
            icon: Icons.home,
            isSelected: false,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            ),
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

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );
}

class ProfileDetailCard extends StatelessWidget {
  final List<Widget> children;
  const ProfileDetailCard({super.key, required this.children});
  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: Column(children: children),
      );
}

class ProfileDetailItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onEdit;
  const ProfileDetailItem(
      {super.key,
      required this.label,
      required this.value,
      required this.onEdit});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(value, style: const TextStyle(fontSize: 16)),
                  ]),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 18, color: Colors.green),
              onPressed: onEdit,
            ),
          ],
        ),
      );
}
