import 'package:flutter/material.dart';
import 'dart:async';
import 'home_page.dart'; // Import your home page

class SkeletonLoadingScreen extends StatefulWidget {
  const SkeletonLoadingScreen({super.key});

  @override
  State<SkeletonLoadingScreen> createState() => _SkeletonLoadingScreenState();
}

class _SkeletonLoadingScreenState extends State<SkeletonLoadingScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to home page after 2.5 seconds
    Timer(const Duration(milliseconds: 2500), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Background pattern skeleton (vegetables pattern area)
            Container(
              height: MediaQuery.of(context).size.height * 0.15,
              width: double.infinity,
              color: Colors.green.withOpacity(0.2),
            ),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row with 2 feature boxes
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureBoxSkeleton(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFeatureBoxSkeleton(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    // Second row with 2 feature boxes
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureBoxSkeleton(
                            color: Colors.blue.withOpacity(0.1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFeatureBoxSkeleton(
                            color: Colors.green.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    // Third row with 2 feature boxes
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureBoxSkeleton(
                            color: Colors.orange.withOpacity(0.1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFeatureBoxSkeleton(
                            color: Colors.purple.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom navigation bar skeleton
            Container(
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItemSkeleton(),
                  _buildNavItemSkeleton(),
                  _buildNavItemSkeleton(isCircular: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Feature box skeleton
  Widget _buildFeatureBoxSkeleton({Color color = Colors.grey}) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon area
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          // Title placeholder
          Container(
            width: 80,
            height: 14,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 6),
          // Subtitle placeholder
          Container(
            width: 100,
            height: 10,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  // Navigation bar item skeleton
  Widget _buildNavItemSkeleton({bool isCircular = false}) {
    return Container(
      width: isCircular ? 45 : 35,
      height: isCircular ? 45 : 35,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular ? null : BorderRadius.circular(8),
      ),
    );
  }
}
