import 'package:flutter/services.dart';
import 'package:location/location.dart';
import '../config/supabase.dart';

class VoiceAssistantService {
  static const platform = MethodChannel('com.example.disaster/voice_assistant');
  final Location _location = Location();
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
      LocationData locationData = await _location.getLocation();

      // Record emergency call in Supabase
      await SupabaseConfig.client.from('emergency_calls').insert({
        'phone_number': number,
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
        'description': 'Emergency call initiated through voice command',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Make the actual phone call
      await platform.invokeMethod('makePhoneCall', {'number': number});
    } on PlatformException catch (e) {
      print('Failed to make phone call: ${e.message}');
    }
  }
} 