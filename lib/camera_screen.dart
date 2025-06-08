import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Required for File class

class CameraScreen extends StatefulWidget {
  final bool isRealTimeDetection;

  const CameraScreen({super.key, required this.isRealTimeDetection});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage; // To store the selected image

  @override
  void initState() {
    super.initState();

    // Initialize cameras and CameraController
    availableCameras().then((cameras) {
      final firstCamera = cameras.first;

      _controller = CameraController(firstCamera, ResolutionPreset.high);
      _initializeControllerFuture = _controller.initialize();

      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedImage =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() {
          _selectedImage = pickedImage;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Picture selected!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isRealTimeDetection ? 'Instant Detection' : 'Identify'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Use a LayoutBuilder to get available space
            return LayoutBuilder(builder: (context, constraints) {
              // Calculate appropriate heights to avoid overflow
              final previewHeight =
                  constraints.maxHeight * 0.8; // 80% of height for camera
              final thumbnailHeight =
                  constraints.maxHeight * 0.15; // 15% for thumbnail (if any)

              return Column(
                children: [
                  // Camera preview
                  Padding(
                    padding: const EdgeInsets.all(0.5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        height: previewHeight,
                        width: constraints.maxWidth,
                        child: CameraPreview(_controller),
                      ),
                    ),
                  ),

                  // Display the selected image below (if any)
                  if (_selectedImage != null)
                    Container(
                      height: thumbnailHeight,
                      padding: const EdgeInsets.all(8.0),
                      child: AspectRatio(
                        aspectRatio: 1, // Square thumbnail
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_selectedImage!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            });
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),

      // Bottom bar with buttons
      // Bottom bar with buttons - completely removed in Instant mode
      bottomNavigationBar: widget.isRealTimeDetection
          ? null // No bottom app bar at all in Instant mode
          : BottomAppBar(
              shape: const CircularNotchedRectangle(),
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Upload picture button on the left
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: IconButton(
                        icon: const Icon(Icons.photo_library),
                        color: Colors.green,
                        iconSize: 32,
                        onPressed: _pickImageFromGallery,
                        tooltip: 'Upload from gallery',
                      ),
                    ),

                    // Center space for camera button
                    const Spacer(),
                  ],
                ),
              ),
            ),

      // Camera button in center of bottom app bar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: widget.isRealTimeDetection
          ? null
          : SizedBox(
              height: 72,
              width: 72,
              child: FloatingActionButton(
                backgroundColor: Colors.green,
                child: const Icon(Icons.camera, color: Colors.white, size: 32),
                onPressed: () async {
                  await _initializeControllerFuture;
                  final image = await _controller.takePicture();
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Picture captured!')),
                  );
                },
              ),
            ),
    );
  }
}
