import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Emergency call records collection
  CollectionReference get emergencyCalls => _firestore.collection('emergency_calls');

  // Record emergency call
  Future<void> recordEmergencyCall({
    required String phoneNumber,
    required String location,
    String? description,
  }) async {
    try {
      await emergencyCalls.add({
        'phoneNumber': phoneNumber,
        'location': location,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'initiated',
      });
    } catch (e) {
      print('Error recording emergency call: $e');
      throw e;
    }
  }

  // Update emergency call status
  Future<void> updateEmergencyCallStatus(String callId, String status) async {
    try {
      await emergencyCalls.doc(callId).update({
        'status': status,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating emergency call status: $e');
      throw e;
    }
  }

  // Get emergency call history
  Stream<QuerySnapshot> getEmergencyCallHistory() {
    return emergencyCalls
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get active emergency calls
  Stream<QuerySnapshot> getActiveEmergencyCalls() {
    return emergencyCalls
        .where('status', isEqualTo: 'active')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Store voice recording
  Future<String> storeVoiceRecording(String filePath, String callId) async {
    try {
      final ref = _storage.ref().child('voice_recordings/$callId.wav');
      await ref.putFile(File(filePath));
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error storing voice recording: $e');
      throw e;
    }
  }
} 