import 'package:flutter/material.dart';

class PlaceholderPage extends StatelessWidget {
  final String pageName;
  const PlaceholderPage({super.key, required this.pageName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageName[0].toUpperCase() + pageName.substring(1)),
      ),
      body: Center(
        child: Text(
          'This is the $pageName page.\nImplementation coming soon!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
