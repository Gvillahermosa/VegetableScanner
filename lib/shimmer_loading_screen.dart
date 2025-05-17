  import 'package:flutter/material.dart';
  import 'package:shimmer/shimmer.dart';
  import 'dart:async';
  import 'home_page.dart'; // Import your home page

  class ShimmerLoadingScreen extends StatefulWidget {
    const ShimmerLoadingScreen({Key? key}) : super(key: key);

    @override
    State<ShimmerLoadingScreen> createState() => _ShimmerLoadingScreenState();
  }

  class _ShimmerLoadingScreenState extends State<ShimmerLoadingScreen> {
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
              // Background pattern (vegetables)
              Shimmer.fromColors(
                baseColor: Colors.green.withOpacity(0.2),
                highlightColor: Colors.green.withOpacity(0.1),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.15,
                  width: double.infinity,
                  color: Colors.green.withOpacity(0.2),
                ),
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
                            child: _buildShimmerFeatureBox(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildShimmerFeatureBox(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Second row with 2 feature boxes
                      Row(
                        children: [
                          Expanded(
                            child: _buildShimmerFeatureBox(
                              baseColor: Colors.blue.withOpacity(0.15),
                              highlightColor: Colors.blue.withOpacity(0.05),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildShimmerFeatureBox(
                              baseColor: Colors.green.withOpacity(0.15),
                              highlightColor: Colors.green.withOpacity(0.05),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Third row with 2 feature boxes
                      Row(
                        children: [
                          Expanded(
                            child: _buildShimmerFeatureBox(
                              baseColor: Colors.orange.withOpacity(0.15),
                              highlightColor: Colors.orange.withOpacity(0.05),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildShimmerFeatureBox(
                              baseColor: Colors.purple.withOpacity(0.15),
                              highlightColor: Colors.purple.withOpacity(0.05),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom navigation bar
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
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
                      _buildNavItem(),
                      _buildNavItem(),
                      _buildNavItem(isCircular: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Shimmer feature box
    Widget _buildShimmerFeatureBox({
      Color baseColor = Colors.grey,
      Color highlightColor = Colors.white,
    }) {
      return Shimmer.fromColors(
        baseColor: baseColor.withOpacity(0.3),
        highlightColor: highlightColor,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon area
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              // Title placeholder
              Container(
                width: 80,
                height: 14,
                color: Colors.white,
              ),
              const SizedBox(height: 6),
              // Subtitle placeholder
              Container(
                width: 100,
                height: 10,
                color: Colors.white,
              ),
            ],
          ),
        ),
      );
    }

    // Navigation item
    Widget _buildNavItem({bool isCircular = false}) {
      return Container(
        width: isCircular ? 45 : 35,
        height: isCircular ? 45 : 35,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircular ? null : BorderRadius.circular(8),
        ),
      );
    }
  }
