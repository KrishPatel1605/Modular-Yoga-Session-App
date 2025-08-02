// screens/home_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modular_yoga_session_app/screens/preview_screen.dart';
import '../models/yoga_session.dart';
import 'session_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<YogaSession> sessions = [];

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  Future<void> loadSessions() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final jsonFiles = manifestMap.keys.where(
      (path) => path.startsWith('assets/poses/') && path.endsWith('.json'),
    );

    List<YogaSession> loadedSessions = [];
    for (final path in jsonFiles) {
      final jsonStr = await rootBundle.loadString(path);
      final jsonMap = json.decode(jsonStr);
      loadedSessions.add(YogaSession.fromJson(jsonMap));
    }

    setState(() => sessions = loadedSessions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yoga Sessions')),
      body:
          sessions.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (_, i) {
                  final session = sessions[i];
                  // In itemBuilder inside ListView.builder
                  return ListTile(
                    title: Text(session.metadata.title),
                    subtitle: Text(session.metadata.category),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye),
                          tooltip: 'Preview',
                          onPressed:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => PreviewScreen(session: session),
                                ),
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          tooltip: 'Start Session',
                          onPressed:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => SessionScreen(session: session),
                                ),
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
