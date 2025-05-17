import 'package:flutter/material.dart';
import 'package:location/location.dart';
import '../config/supabase.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'supply_assistant_screen.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class CitizenDashboard extends StatefulWidget {
  const CitizenDashboard({super.key});

  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends State<CitizenDashboard> {
  bool _isLoading = false;
  final _deviceInfo = DeviceInfoPlugin();

  Future<String> _getDeviceId() async {
    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id; // Unique Android device ID
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown'; // Unique iOS device ID
      }
      return 'unknown';
    } catch (e) {
      print('Error getting device ID: $e');
      return 'unknown';
    }
  }

  Future<void> _handleEmergency() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Location location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          throw Exception(Provider.of<LanguageProvider>(context, listen: false).translate('location_disabled'));
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          throw Exception(Provider.of<LanguageProvider>(context, listen: false).translate('location_permission_denied'));
        }
      }

      final locationData = await location.getLocation();
      final deviceId = await _getDeviceId();
      
      // Store location coordinates and device ID in Supabase
      await SupabaseConfig.client
          .from('emergency_locations')
          .insert({
            'device_id': deviceId,
            'latitude': locationData.latitude,
            'longitude': locationData.longitude,
            'created_at': DateTime.now().toIso8601String(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Provider.of<LanguageProvider>(context, listen: false).translate('emergency_sent')),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(languageProvider.translate('citizen_dashboard')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              languageProvider.translate('emergency_assistance'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              languageProvider.translate('emergency_description'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              height: 200,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleEmergency,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(24),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.emergency,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            languageProvider.translate('emergency_button'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, controller) => Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: const SupplyAssistantScreen(),
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.support_agent, color: Colors.white),
        label: Text(
          languageProvider.translate('ai_assistant_label'),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
} 