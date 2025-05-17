import 'package:flutter/services.dart';

class VoiceAssistantService {
  static const platform = MethodChannel('com.example.disaster/voice_assistant');
  bool _isListening = false;

  bool get isListening => _isListening;

  Future<void> startListening() async {
    if (!_isListening) {
      try {
        await platform.invokeMethod('startListening');
        _isListening = true;
      } on PlatformException catch (e) {
        print('Failed to start listening: ${e.message}');
      }
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      try {
        await platform.invokeMethod('stopListening');
        _isListening = false;
      } on PlatformException catch (e) {
        print('Failed to stop listening: ${e.message}');
      }
    }
  }

  Future<void> speak(String text) async {
    try {
      await platform.invokeMethod('speak', {'text': text});
    } on PlatformException catch (e) {
      print('Failed to speak: ${e.message}');
    }
  }

  Future<void> makePhoneCall(String number) async {
    try {
      await platform.invokeMethod('makePhoneCall', {'number': number});
    } on PlatformException catch (e) {
      print('Failed to make phone call: ${e.message}');
    }
  }
} 