import 'package:flutter/material.dart';
import '../models/yoga_session.dart';

class PreviewScreen extends StatelessWidget {
  final YogaSession session;

  const PreviewScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    // Gather unique imageRefs from all script lines
    final imagePaths = <String>{};
    for (final segment in session.sequence) {
      for (final line in segment.script) {
        imagePaths.add(session.assets.images[line.imageRef] ?? '');
      }
    }

    // Remove any empty paths
    final filteredPaths = imagePaths.where((p) => p.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Preview: ${session.metadata.title}')),
      body: filteredPaths.isEmpty
          ? const Center(child: Text('No preview images available.'))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: filteredPaths.length,
              itemBuilder: (_, index) {
                final imagePath = 'assets/images/${filteredPaths[index]}';
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                );
              },
            ),
    );
  }
}
