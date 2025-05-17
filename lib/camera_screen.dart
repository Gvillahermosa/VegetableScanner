import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  // Ensure you pass the required camera information (if you have multiple cameras)
  final bool isRealTimeDetection;

  const CameraScreen({super.key, required this.isRealTimeDetection});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // For demo purposes, you might want to handle camera selection differently.
    // Replace availableCameras() with the one from your camera package initialization.
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
            return Padding(
              padding: const EdgeInsets.all(0.5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  width: MediaQuery.of(context).size.width,
                  child: CameraPreview(_controller),
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                      const SnackBar(content: Text('Picture captured!')));
                },
              ),
            ),
    );
  }
}
