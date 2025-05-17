import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'firebase_service.dart';

class VoiceAssistantService {
  static const platform = MethodChannel('com.example.disaster/voice_assistant');
  final FirebaseService _firebaseService = FirebaseService();
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

  Future<void> makeEmergencyCall(String number) async {
    try {
      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Record emergency call in Firebase
      await _firebaseService.recordEmergencyCall(
        phoneNumber: number,
        location: '${position.latitude},${position.longitude}',
        description: 'Emergency call initiated through voice command',
      );

      // Make the actual phone call
      await platform.invokeMethod('makePhoneCall', {'number': number});
    } on PlatformException catch (e) {
      print('Failed to make phone call: ${e.message}');
    }
  }
} 