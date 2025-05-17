import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../config/supabase.dart';
import '../services/clustering_service.dart';
import 'supplier_layout.dart';

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
  LatLng _center = const LatLng(0, 0);
  bool _loading = true;
  bool _showEmergencies = true;

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
            _markers.add(
              Marker(
                markerId: MarkerId(supplier['id'].toString()),
                position: LatLng(
                  location['latitude'] as double,
                  location['longitude'] as double,
                ),
                infoWindow: InfoWindow(
                  title: supplier['name'] ?? 'Unknown Supplier',
                  snippet: supplier['type'] ?? 'No type specified',
                ),
                onTap: () => _showSupplierDetails(
                  supplier['id'].toString(),
                  supplier,
                ),
              ),
            );
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading suppliers: $e')),
      );
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

      setState(() {
        _emergencyMarkers.clear();
        _clusterMarkers.clear();

        // Add individual emergency markers
        for (var emergency in emergencies) {
          _emergencyMarkers.add(
            Marker(
              markerId: MarkerId('emergency_${emergency['id']}'),
              position: LatLng(
                emergency['latitude'] as double,
                emergency['longitude'] as double,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              infoWindow: InfoWindow(
                title: 'Emergency Alert',
                snippet: 'Reported: ${emergency['created_at']}',
              ),
            ),
          );
        }

        // Add cluster markers
        for (var cluster in clusters) {
          _clusterMarkers.add(
            Marker(
              markerId: MarkerId('cluster_${cluster.center.latitude}_${cluster.center.longitude}'),
              position: cluster.center,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
              infoWindow: InfoWindow(
                title: 'Emergency Cluster',
                snippet: '${cluster.size} emergencies in this area',
              ),
            ),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading emergency locations: $e')),
      );
    }
  }

  void _showSupplierDetails(String id, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['name'] ?? 'Unknown Supplier',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Type: ${data['type'] ?? 'Not specified'}'),
            Text('Contact: ${data['contact'] ?? 'Not specified'}'),
            Text('Address: ${data['address'] ?? 'Not specified'}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement contact functionality
                Navigator.pop(context);
              },
              child: const Text('Contact Supplier'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _loading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              title: const Text('Supplier Locations'),
              actions: [
                IconButton(
                  icon: Icon(_showEmergencies ? Icons.emergency : Icons.emergency_outlined),
                  onPressed: () {
                    setState(() {
                      _showEmergencies = !_showEmergencies;
                    });
                  },
                  tooltip: 'Toggle Emergency Locations',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    _loadSuppliers();
                    _loadEmergencyLocations();
                  },
                ),
              ],
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.green,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Supplier Portal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Menu Options',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: const Text('Dashboard'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/dashboard');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.attach_money),
                    title: const Text('Funding'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/funding');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.map),
                    title: const Text('Supplier Map'),
                    selected: true,
                    selectedTileColor: Colors.green.withOpacity(0.1),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.support),
                    title: const Text('Provide Assistance'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/provide_assistance');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Back to Home'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                  ),
                ],
              ),
            ),
            body: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
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
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // TODO: Implement add new supplier functionality
              },
              child: const Icon(Icons.add_location),
            ),
          );

    return SupplierLayout(
      currentRoute: '/supplier',
      child: content,
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
} 