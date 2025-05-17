import 'package:flutter/material.dart';
import '../services/voice_assistant_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VoiceAssistantService _voiceAssistant = VoiceAssistantService();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _startVoiceAssistant();
  }

  Future<void> _startVoiceAssistant() async {
    await _voiceAssistant.startListening();
    setState(() {
      _isListening = true;
    });
  }

  @override
  void dispose() {
    _voiceAssistant.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to\nDisaster Management',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              'Choose your role',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/citizen'),
              child: const Text('I am a Citizen'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/supplier'),
              child: const Text('I am a Supplier'),
            ),
            const SizedBox(height: 32),
            Text(
              'Voice Assistant: ${_isListening ? 'Listening' : 'Not Listening'}',
              style: TextStyle(
                color: _isListening ? Colors.green : Colors.red,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Say "disaster help" for emergency assistance',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 