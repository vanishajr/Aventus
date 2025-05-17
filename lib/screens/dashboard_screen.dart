import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/supabase.dart';
import 'supplier_layout.dart';
import '../models/supply_report.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  SupplyReport? _latestReport;

  void _updateReport(SupplyReport report) {
    setState(() {
      _latestReport = report;
    });
  }

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
              const SizedBox(height: 24),
              _latestReport == null
                  ? const Center(
                      child: Text(
                        'No supply reports available.\nGenerate a report from the AI Assistant.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : _buildSupplyReport(),
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

  Widget _buildSupplyReport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReportHeader(),
        const SizedBox(height: 24),
        _buildUrgentSupplyCard(),
        const SizedBox(height: 16),
        _buildSupplyList(),
        const SizedBox(height: 24),
        _buildNextShipmentCard(),
      ],
    );
  }

  Widget _buildReportHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161A1C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Supply Status Report',
            style: TextStyle(
              color: Color(0xFF4CAF50),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generated on: ${_latestReport!.timestamp.toString().split('.')[0]}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            'Number of people: ${_latestReport!.numberOfPeople}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentSupplyCard() {
    Color statusColor;
    switch (_latestReport!.mostUrgentStatus) {
      case 'Critical':
        statusColor = Colors.red;
        break;
      case 'Low':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = const Color(0xFF4CAF50);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        border: Border.all(color: statusColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning,
            color: statusColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Urgent Attention Required',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_latestReport!.mostUrgent} (${_latestReport!.mostUrgentStatus})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplyList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Supply Status',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...(_latestReport!.supplies.entries.map((entry) {
          final supply = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF161A1C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      supply['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: supply['status'] == 'Critical'
                            ? Colors.red.withOpacity(0.2)
                            : supply['status'] == 'Low'
                                ? Colors.orange.withOpacity(0.2)
                                : const Color(0xFF4CAF50).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        supply['status'],
                        style: TextStyle(
                          color: supply['status'] == 'Critical'
                              ? Colors.red
                              : supply['status'] == 'Low'
                                  ? Colors.orange
                                  : const Color(0xFF4CAF50),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Remaining: ${supply['remaining']}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Required: ${supply['required']}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Will last: ${supply['days']} days',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }).toList()),
      ],
    );
  }

  Widget _buildNextShipmentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_shipping,
            color: Color(0xFF4CAF50),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next Shipment Due',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'In ${_latestReport!.nextShipmentDue} days',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 