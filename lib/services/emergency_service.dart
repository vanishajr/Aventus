import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

class EmergencyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Location _location = Location();

  Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permission;

    // Test if location services are enabled.
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission == PermissionStatus.denied) {
        return false;
      }
    }
    
    if (permission == PermissionStatus.deniedForever) {
      return false;
    }

    return true;
  }

  Future<LocationData?> getCurrentLocation() async {
    try {
      return await _location.getLocation();
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Future<void> sendEmergencySignal() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission not granted');
      }

      final locationData = await getCurrentLocation();
      if (locationData == null) {
        throw Exception('Could not get current location');
      }

      await _firestore.collection('emergency_signals').add({
        'timestamp': FieldValue.serverTimestamp(),
        'location': GeoPoint(locationData.latitude!, locationData.longitude!),
        'status': 'pending',
        'accuracy': locationData.accuracy,
        'altitude': locationData.altitude,
        'speed': locationData.speed,
        'speedAccuracy': locationData.speedAccuracy,
      });
    } catch (e) {
      print('Error sending emergency signal: $e');
      rethrow;
    }
  }
} 