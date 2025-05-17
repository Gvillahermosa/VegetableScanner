import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'notifications_page.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // User information - all editable
  String fullName = "Jasce Belia";
  String displayName = "Jasce Belia";
  DateTime birthdate = DateTime(2004, 5, 15);
  String gender = "Female";
  String email = "jasce.belia@example.com";
  String phoneNumber = "+1 (555) 123-4567";

  bool biometricsEnabled = false;

  // For profile image
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Edit mode tracking
  bool isEditingName = false;
  bool isEditingEmail = false;
  bool isEditingPhone = false;

  // Controllers
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: fullName);
    emailController = TextEditingController(text: email);
    phoneController = TextEditingController(text: phoneNumber);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
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

  // Format date for display
  String _formatDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthdate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != birthdate) {
      setState(() {
        birthdate = picked;
      });
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
              onTap: () {
                setState(() {
                  gender = 'Female';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Male'),
              onTap: () {
                setState(() {
                  gender = 'Male';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Non-binary'),
              onTap: () {
                setState(() {
                  gender = 'Non-binary';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Prefer not to say'),
              onTap: () {
                setState(() {
                  gender = 'Prefer not to say';
                });
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
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement your sign out logic here
              // e.g., Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
            },
            child: const Text('SIGN OUT'),
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
                  : () {
                      // Validate input
                      if (newEmailController.text.isEmpty ||
                          currentPasswordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill in all fields')),
                        );
                        return;
                      }

                      // Email validation regex
                      final emailRegex =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$');
                      if (!emailRegex.hasMatch(newEmailController.text)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter a valid email')),
                        );
                        return;
                      }

                      // Set loading state
                      setState(() {
                        isLoading = true;
                      });

                      // Simulate API call
                      Future.delayed(const Duration(seconds: 1), () {
                        Navigator.pop(context);

                        // Update email in parent widget
                        this.setState(() {
                          email = newEmailController.text;
                        });

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Email updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      });
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
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureCurrentPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureCurrentPassword = !obscureCurrentPassword;
                      });
                    },
                  ),
                ),
                obscureText: obscureCurrentPassword,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureNewPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureNewPassword = !obscureNewPassword;
                      });
                    },
                  ),
                ),
                obscureText: obscureNewPassword,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                obscureText: obscureConfirmPassword,
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
                  : () {
                      // Validate input
                      if (currentPasswordController.text.isEmpty ||
                          newPasswordController.text.isEmpty ||
                          confirmPasswordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill in all fields')),
                        );
                        return;
                      }

                      // Password match validation
                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('New passwords don\'t match')),
                        );
                        return;
                      }

                      // Password strength validation (example)
                      if (newPasswordController.text.length < 8) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Password must be at least 8 characters')),
                        );
                        return;
                      }

                      // Set loading state
                      setState(() {
                        isLoading = true;
                      });

                      // Simulate API call
                      Future.delayed(const Duration(seconds: 1), () {
                        Navigator.pop(context);

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      });
                    },
              child: const Text('UPDATE'),
            ),
          ],
        ),
      ),
    );
  }

  // For account deletion
  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();
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
                  : () {
                      // Set loading state
                      setState(() {
                        isLoading = true;
                      });

                      // Simulate API call
                      Future.delayed(const Duration(seconds: 1), () {
                        Navigator.pop(context);

                        // Show a confirmation and redirect to login
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => AlertDialog(
                            title: const Text('Account Deleted'),
                            content: const Text(
                              'Your account has been successfully deleted. You will be redirected to the login screen.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // Here you would navigate to login screen
                                  // Navigator.of(context).pushAndRemoveUntil(
                                  //   MaterialPageRoute(builder: (context) => LoginPage()),
                                  //   (route) => false,
                                  // );
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      });
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Vegetable pattern background and profile picture
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Vegetable pattern background
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
                // Profile picture container
                Positioned(
                  bottom: -50,
                  child: GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Stack(
                      children: [
                        // Profile picture or default icon
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _profileImage != null
                                ? null
                                : Colors.green[300],
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            image: _profileImage != null
                                ? DecorationImage(
                                    image: FileImage(_profileImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          // Use child only when there's no profile image
                          child: _profileImage == null
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        // Edit icon overlay
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Space for profile picture overflow
            const SizedBox(height: 55),
            // Display name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: !isEditingName
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () {
                            setState(() {
                              isEditingName = true;
                            });
                          },
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              hintText: 'Full Name',
                            ),
                            autofocus: true,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              fullName = nameController.text;
                              displayName = nameController.text;
                              isEditingName = false;
                            });
                          },
                        ),
                      ],
                    ),
            ),
            // Profile details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Info Section
                    const SectionHeader(title: 'Basic Information'),
                    ProfileDetailCard(
                      children: [
                        ProfileDetailItem(
                          label: 'Full Name',
                          value: fullName,
                          onEdit: () {
                            setState(() {
                              isEditingName = true;
                            });
                          },
                        ),
                        const Divider(),
                        ProfileDetailItem(
                          label: 'Birthdate',
                          value: _formatDate(birthdate),
                          onEdit: () => _selectDate(context),
                        ),
                        const Divider(),
                        ProfileDetailItem(
                          label: 'Gender',
                          value: gender,
                          onEdit: _showGenderDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Contact Info Section
                    const SectionHeader(title: 'Contact Information'),
                    ProfileDetailCard(
                      children: [
                        !isEditingEmail
                            ? ProfileDetailItem(
                                label: 'Email',
                                value: email,
                                onEdit: () {
                                  setState(() {
                                    isEditingEmail = true;
                                  });
                                },
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Email',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                          TextField(
                                            controller: emailController,
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
                                      icon: const Icon(Icons.check,
                                          color: Colors.green, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          email = emailController.text;
                                          isEditingEmail = false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                        const Divider(),
                        !isEditingPhone
                            ? ProfileDetailItem(
                                label: 'Phone Number',
                                value: phoneNumber,
                                onEdit: () {
                                  setState(() {
                                    isEditingPhone = true;
                                  });
                                },
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Phone Number',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                          TextField(
                                            controller: phoneController,
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
                                      icon: const Icon(Icons.check,
                                          color: Colors.green, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          phoneNumber = phoneController.text;
                                          isEditingPhone = false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Account & Security Section
                    const SectionHeader(title: 'Account & Security'),
                    ProfileDetailCard(
                      children: [
                        // Change Email
                        ListTile(
                          leading: const Icon(Icons.email_outlined,
                              color: Colors.green),
                          title: const Text('Change Email'),
                          subtitle: Text(email,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600])),
                          trailing: const Icon(Icons.chevron_right),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          onTap: () {
                            _showChangeEmailDialog();
                          },
                        ),
                        const Divider(height: 1),

                        // Change Password
                        ListTile(
                          leading: const Icon(Icons.lock_outline,
                              color: Colors.green),
                          title: const Text('Change Password'),
                          subtitle: const Text('Last changed 30 days ago',
                              style: TextStyle(fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          onTap: () {
                            _showChangePasswordDialog();
                          },
                        ),
                        const Divider(height: 1),

                        // Delete Account
                        ListTile(
                          leading: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          title: const Text('Delete Account',
                              style: TextStyle(color: Colors.red)),
                          subtitle: const Text(
                              'Permanently delete your account and all data',
                              style: TextStyle(fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right,
                              color: Colors.red),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          onTap: () {
                            _showDeleteAccountDialog();
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    // Sign Out Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _showSignOutDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'SIGN OUT',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // App version
                    Center(
                      child: Text(
                        'App Version 1.0.0',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
            // Bottom Navigation Bar
            _buildBottomNavigationBar(context),
          ],
        ),
      ),
    );
  }
}

// Helper widgets
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ProfileDetailCard extends StatelessWidget {
  final List<Widget> children;
  const ProfileDetailCard({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// Add these new methods for the bottom navigation
Widget _buildBottomNavigationBar(context) {
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
        _buildCircularProfileButton(),
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
        color: isSelected ? Colors.green.withOpacity(0.1) : Colors.transparent,
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

Widget _buildCircularProfileButton() {
  return Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: Colors.green.withOpacity(0.8),
      shape: BoxShape.circle,
    ),
    child: const Icon(
      Icons.person,
      color: Colors.white,
      size: 24,
    ),
  );
}

class ProfileDetailItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onEdit;
  const ProfileDetailItem({
    Key? key,
    required this.label,
    required this.value,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            color: Colors.green,
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}
