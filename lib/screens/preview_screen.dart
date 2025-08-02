import 'package:flutter/material.dart';
import '../models/yoga_session.dart';

class PreviewScreen extends StatelessWidget {
  final YogaSession session;

  const PreviewScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final imagePaths = <String>{};
    for (final segment in session.sequence) {
      for (final line in segment.script) {
        imagePaths.add(session.assets.images[line.imageRef] ?? '');
      }
    }

    final filteredPaths = imagePaths.where((p) => p.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Preview: ${session.metadata.title}'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: filteredPaths.isEmpty
          ? const Center(
              child: Text(
                'No preview images available.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: filteredPaths.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3 / 4,
                ),
                itemBuilder: (_, index) {
                  final imagePath = 'assets/images/${filteredPaths[index]}';
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
