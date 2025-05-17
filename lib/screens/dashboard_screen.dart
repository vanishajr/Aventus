import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/supabase.dart';
import 'supplier_layout.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return SupplierLayout(
      currentRoute: '/dashboard',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(),
              const SizedBox(height: 24),
              _buildDisasterChart(),
              const SizedBox(height: 24),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchDisasters(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final activeDisasters = snapshot.data?.length ?? 0;
        
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildSummaryCard(
              'Active Disasters',
              activeDisasters.toString(),
              Icons.warning,
              Colors.red,
            ),
            _buildSummaryCard(
              'Total Funding',
              '\$1.2M',
              Icons.attach_money,
              Colors.green,
            ),
            _buildSummaryCard(
              'Volunteers',
              '250',
              Icons.people,
              Colors.blue,
            ),
            _buildSummaryCard(
              'Resources',
              '15',
              Icons.inventory,
              Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Future<List<dynamic>> _fetchDisasters() async {
    final response = await SupabaseConfig.client
        .from('disasters')
        .select();

    return response as List<dynamic>;
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisasterChart() {
    return SizedBox(
      height: 300,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Disaster Types Distribution',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: 35,
                        title: '35%',
                        color: Colors.red,
                        radius: 50,
                        titleStyle: const TextStyle(color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: 25,
                        title: '25%',
                        color: Colors.blue,
                        radius: 50,
                        titleStyle: const TextStyle(color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: 20,
                        title: '20%',
                        color: Colors.green,
                        radius: 50,
                        titleStyle: const TextStyle(color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: 20,
                        title: '20%',
                        color: Colors.orange,
                        radius: 50,
                        titleStyle: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegendItem('Flood', Colors.red),
                  _buildLegendItem('Fire', Colors.blue),
                  _buildLegendItem('Storm', Colors.green),
                  _buildLegendItem('Other', Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<dynamic>>(
              stream: _activityStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final activities = snapshot.data ?? [];

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return ListTile(
                      leading: const Icon(Icons.notifications),
                      title: Text(activity['description'] ?? ''),
                      subtitle: Text(activity['timestamp']?.toString() ?? ''),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Stream<List<dynamic>> _activityStream() {
  return SupabaseConfig.client
      .from('activity')
      .stream(primaryKey: ['id'])
      .order('timestamp', ascending: false)
      .limit(5)
      .execute();
}

} 