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
      appBar: AppBar(
        title: const Text('Yoga Sessions'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body:
          sessions.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: sessions.length,
                itemBuilder: (_, i) {
                  final session = sessions[i];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: const CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Icon(
                          Icons.self_improvement,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        session.metadata.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          session.metadata.category,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_red_eye),
                            tooltip: 'Preview',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => PreviewScreen(session: session),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.play_arrow),
                            tooltip: 'Start Session',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => SessionScreen(session: session),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
