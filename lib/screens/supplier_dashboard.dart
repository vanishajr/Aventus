import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/supabase.dart';
import '../services/clustering_service.dart';
import '../theme/app_theme.dart';
import 'supplier_layout.dart';
import 'donation_screen.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'supplier_ai_assistant.dart';

class SupplierDashboard extends StatefulWidget {
  const SupplierDashboard({super.key});

  @override
  State<SupplierDashboard> createState() => _SupplierDashboardState();
}

class _SupplierDashboardState extends State<SupplierDashboard> {
  GoogleMapController? _mapController;
  final Location _location = Location();
  final Set<Marker> _markers = {};
  final Set<Marker> _emergencyMarkers = {};
  final Set<Marker> _clusterMarkers = {};
  final Set<Circle> _clusterCircles = {};
  LatLng _center = const LatLng(0, 0);
  bool _loading = true;
  bool _showEmergencies = true;

  // Constants for cluster visualization
  static const double _highDensityThreshold = 5; // Minimum points for high-density cluster
  static const double _metersPerKilometer = 1000.0; // Conversion factor from km to meters

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadSuppliers();
    _loadEmergencyLocations();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locationData = await _location.getLocation();
      setState(() {
        _center = LatLng(locationData.latitude!, locationData.longitude!);
        _loading = false;
      });
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _center, zoom: 12),
        ),
      );
    } catch (e) {
      // Default to a central location if permission is denied
      setState(() {
        _center = const LatLng(0, 0);
        _loading = false;
      });
    }
  }

  // Launch Google Maps navigation
  Future<void> _launchNavigation(LatLng location) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${location.latitude},${location.longitude}&travelmode=driving'
    );
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch navigation')),
        );
      }
    }
  }

  Future<void> _loadSuppliers() async {
    try {
      final response = await SupabaseConfig.client
          .from('suppliers')
          .select();

      final suppliers = response as List<dynamic>;

      setState(() {
        _markers.clear();
        for (var supplier in suppliers) {
          final location = supplier['location'];
          if (location != null) {
            final position = LatLng(
              location['latitude'] as double,
              location['longitude'] as double,
            );
            _markers.add(
              Marker(
                markerId: MarkerId(supplier['id'].toString()),
                position: position,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                infoWindow: InfoWindow(
                  title: supplier['name'] ?? 'Unknown Supplier',
                  snippet: supplier['type'] ?? 'No type specified',
                ),
                onTap: () {
                  _showSupplierDetails(supplier['id'].toString(), supplier);
                  _launchNavigation(position);
                },
              ),
            );
          }
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading suppliers: $e'),
            backgroundColor: AppTheme.orange,
          ),
        );
      }
    }
  }

  Future<void> _loadEmergencyLocations() async {
    try {
      final response = await SupabaseConfig.client
          .from('emergency_locations')
          .select()
          .eq('status', 'active');

      final emergencies = response as List<dynamic>;
      final List<LatLng> emergencyPoints = [];

      // Convert emergency locations to LatLng points
      for (var emergency in emergencies) {
        final latitude = emergency['latitude'] as double;
        final longitude = emergency['longitude'] as double;
        emergencyPoints.add(LatLng(latitude, longitude));
      }

      // Apply clustering
      final clusters = ClusteringService.clusterLocations(emergencyPoints);
      print('Generated ${clusters.length} clusters'); // Debug log

      // Save clusters to Supabase
      for (var cluster in clusters) {
        try {
          print('Processing cluster with name: ${cluster.name}'); // Debug log
          
          // Check if a cluster exists at this location (within a small radius)
          final existingClusters = await SupabaseConfig.client
              .from('clusters')
              .select()
              .eq('name', cluster.name);

          final existingClustersList = existingClusters as List;
          
          if (existingClustersList.isNotEmpty) {
            final existingCluster = existingClustersList.first;
            
            // If properties have changed, delete old and create new
            if (existingCluster['radius'] != cluster.radius ||
                existingCluster['size'] != cluster.size) {
              
              // Delete the old cluster
              await SupabaseConfig.client
                  .from('clusters')
                  .delete()
                  .eq('name', cluster.name);

              // Create new cluster
              final data = {
                'name': cluster.name,
                'latitude': cluster.center.latitude,
                'longitude': cluster.center.longitude,
                'size': cluster.size,
                'radius': cluster.radius,
                'priority': cluster.priority,
              };
              
              await SupabaseConfig.client
                  .from('clusters')
                  .insert(data);
              
              print('Updated existing cluster: ${cluster.name}');
            } else {
              print('Cluster exists and unchanged: ${cluster.name}');
            }
          } else {
            // Create new cluster if it doesn't exist
            final data = {
              'name': cluster.name,
              'latitude': cluster.center.latitude,
              'longitude': cluster.center.longitude,
              'size': cluster.size,
              'radius': cluster.radius,
              'priority': cluster.priority,
            };
            
            await SupabaseConfig.client
                .from('clusters')
                .insert(data);
            
            print('Created new cluster: ${cluster.name}');
          }
        } catch (e, stackTrace) {
          print('Error processing cluster ${cluster.name}: $e');
          print('Stack trace: $stackTrace');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error processing cluster: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Dismiss',
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        }
      }

      setState(() {
        _emergencyMarkers.clear();
        _clusterMarkers.clear();
        _clusterCircles.clear();

        // Add individual emergency markers
        for (var emergency in emergencies) {
          final position = LatLng(
            emergency['latitude'] as double,
            emergency['longitude'] as double,
          );
          _emergencyMarkers.add(
            Marker(
              markerId: MarkerId('emergency_${emergency['id']}'),
              position: position,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              infoWindow: InfoWindow(
                title: 'Emergency Alert',
                snippet: 'Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
              ),
              onTap: () => _launchNavigation(position),
            ),
          );
        }

        // Add cluster markers and circles
        for (var cluster in clusters) {
          _clusterMarkers.add(
            Marker(
              markerId: MarkerId('cluster_${cluster.center.latitude}_${cluster.center.longitude}'),
              position: cluster.center,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
              infoWindow: InfoWindow(
                title: 'Emergency Cluster',
                snippet: '${cluster.size} emergencies - Radius: ${cluster.radius.toStringAsFixed(2)}km',
              ),
              onTap: () => _launchNavigation(cluster.center),
            ),
          );

          // Add circle for all clusters
          _clusterCircles.add(
            Circle(
              circleId: CircleId('circle_${cluster.center.latitude}_${cluster.center.longitude}'),
              center: cluster.center,
              radius: cluster.radius * _metersPerKilometer, // Convert km to meters
              fillColor: cluster.color.withOpacity(0.15),
              strokeWidth: 2,
              strokeColor: cluster.color.withOpacity(0.3),
            ),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading emergency locations: $e'),
            backgroundColor: AppTheme.orange,
          ),
        );
      }
    }
  }

  void _showSupplierDetails(String id, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: AppTheme.elevation2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.greenGradient,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? 'Unknown Supplier',
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['type'] ?? 'No type specified',
                    style: TextStyle(
                      color: AppTheme.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailItem(
                    icon: Icons.phone,
                    label: 'Contact',
                    value: data['contact'] ?? 'Not specified',
                  ),
                  const SizedBox(height: 12),
                  _DetailItem(
                    icon: Icons.location_on,
                    label: 'Address',
                    value: data['address'] ?? 'Not specified',
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement contact functionality
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.message),
                      label: const Text('Contact Supplier'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final content = _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.green))
        : Scaffold(
      appBar: AppBar(
              title: Text(languageProvider.translate('emergency_response_map')),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.volunteer_activism, color: Colors.orange),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DonationScreen()),
                      );
                    },
                    tooltip: languageProvider.translate('donations'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: _showEmergencies ? AppTheme.orange.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _showEmergencies ? Icons.emergency : Icons.emergency_outlined,
                      color: _showEmergencies ? AppTheme.orange : AppTheme.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _showEmergencies = !_showEmergencies;
                      });
                    },
                    tooltip: languageProvider.translate('toggle_emergency_locations'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: AppTheme.green),
                    onPressed: () {
                      _loadSuppliers();
                      _loadEmergencyLocations();
                    },
                    tooltip: languageProvider.translate('refresh_map'),
                  ),
                ),
              ],
            ),
            drawer: Drawer(
              child: Column(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      gradient: AppTheme.greenGradient,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Supplier Portal',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Emergency Response Network',
                          style: TextStyle(
                            color: AppTheme.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dashboard, color: AppTheme.primaryGrey),
                    title: const Text('Dashboard'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/dashboard');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.attach_money, color: AppTheme.primaryGrey),
                    title: const Text('Funding'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/funding');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.map, color: AppTheme.green),
                    title: const Text('Supplier Map'),
                    selected: true,
                    selectedTileColor: AppTheme.green.withOpacity(0.1),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.support, color: AppTheme.primaryGrey),
                    title: const Text('Provide Assistance'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/provide_assistance');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.home, color: AppTheme.primaryGrey),
                    title: const Text('Back to Home'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
        child: Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: AppTheme.primaryGrey.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                    controller.setMapStyle(_mapStyle);
                  },
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 12,
                  ),
                  markers: {
                    ..._markers,
                    if (_showEmergencies) ..._emergencyMarkers,
                    if (_showEmergencies) ..._clusterMarkers,
                  },
                  circles: _showEmergencies ? _clusterCircles : {},
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  compassEnabled: true,
                  zoomControlsEnabled: false,
                ),
                // Info Card
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    color: AppTheme.surfaceGrey.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.emergency,
                                color: AppTheme.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Emergency Response Hub',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Monitor and respond to emergencies in real-time.',
                            style: TextStyle(
                              color: AppTheme.white.withOpacity(0.9),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Clusters: red (7+ alerts), orange (4-6), green (<4)',
                            style: TextStyle(
                              color: AppTheme.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _LegendItem(
                                color: AppTheme.green,
                                label: 'Suppliers',
                              ),
                              _LegendItem(
                                color: Colors.red,
                                label: 'High',
                              ),
                              _LegendItem(
                                color: Colors.orange,
                                label: 'Medium',
                              ),
                              _LegendItem(
                                color: Colors.green,
                                label: 'Low',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Zoom Controls
                Positioned(
                  right: 16,
                  bottom: 96,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceGrey,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppTheme.elevation1,
                    ),
                    child: FloatingActionButton(
                      heroTag: 'zoomIn',
                      backgroundColor: AppTheme.surfaceGrey,
                      elevation: 0,
                      mini: true,
                      child: const Icon(Icons.add, color: AppTheme.white),
                      onPressed: () {
                        _mapController?.animateCamera(CameraUpdate.zoomIn());
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 32,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceGrey,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppTheme.elevation1,
                    ),
                    child: FloatingActionButton(
                      heroTag: 'zoomOut',
                      backgroundColor: AppTheme.surfaceGrey,
                      elevation: 0,
                      mini: true,
                      child: const Icon(Icons.remove, color: AppTheme.white),
                      onPressed: () {
                        _mapController?.animateCamera(CameraUpdate.zoomOut());
                      },
                    ),
                  ),
                ),
                // My Location Button
                Positioned(
                  right: 16,
                  bottom: 160,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceGrey,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppTheme.elevation1,
                    ),
                    child: FloatingActionButton(
                      heroTag: 'myLocation',
                      backgroundColor: AppTheme.surfaceGrey,
                      elevation: 0,
                      mini: true,
                      child: const Icon(Icons.my_location, color: AppTheme.white),
                      onPressed: _getCurrentLocation,
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.greenGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.elevation2,
              ),
              child: FloatingActionButton(
                elevation: 0,
                backgroundColor: Colors.transparent,
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
                        child: const SupplierAIAssistant(),
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.smart_toy, color: AppTheme.white),
              ),
            ),
          );

    return SupplierLayout(
      currentRoute: '/supplier',
      child: content,
    );
  }

  // Custom map style
  static const _mapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#1E2428"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#FFFFFF"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#161A1C"
      }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#262B2F"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#262B2F"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1E2428"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#161A1C"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#1E2428"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#1E2428"
      }
    ]
  }
]
  ''';

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.green, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.primaryGrey.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.primaryGrey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
} 