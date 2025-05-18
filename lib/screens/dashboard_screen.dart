import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supplier_layout.dart';
import '../services/clustering_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalCitizens = 0;
  int _totalClusters = 0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    
    try {
      // Get total emergency locations (citizens in need)
      final emergencyResponse = await SupabaseConfig.client
          .from('emergency_locations')
          .select('id');
      
      // Get total active clusters
      final clusterResponse = await SupabaseConfig.client
          .from('clusters')
          .select('id');

      if (mounted) {
        setState(() {
          _totalCitizens = (emergencyResponse as List).length;
          _totalClusters = (clusterResponse as List).length;
          _loading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildInfoCard(String title, int value, IconData icon, Color color) {
    return Card(
      color: const Color(0xFF1E2428),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SupplierLayout(
      currentRoute: '/dashboard',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loading ? null : _fetchData,
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'System Overview',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoCard(
                      'Total Citizens',
                      _totalCitizens,
                      Icons.people,
                      Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      'Active Clusters',
                      _totalClusters,
                      Icons.hub,
                      Colors.green,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
} 